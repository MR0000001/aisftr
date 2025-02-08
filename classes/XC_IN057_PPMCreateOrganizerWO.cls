public without sharing class XC_IN057_PPMCreateOrganizerWO {

    private static Map<String,WorkOrder> woByTask = new Map<String,WorkOrder>();
    private static Map<id,String> wbeByTask = new Map<id,String>();
    private static Map<Id, Contract>     contrMap = new Map<Id, Contract>();
    private static Map<Id, Contract>     activeContrMap = new Map<Id, Contract>();

    private static Map<String, ProductRequired> prodReqByProduct2 = new Map<String, ProductRequired>();
    private static List<XC_RequiredPosition__c> allPositions = new List<XC_RequiredPosition__c>();

    public class InputWrapper {

        /** The String. */
        @Invocablevariable
        public String taskId;


    }

    /**
     * @author dpalamides - dpalamides@deloitte.it
     * @description createOrganizerWO manages the creation of the WO organizer for partner engagement tasks
     * @param inputWrapperList the input wrapper list
     */
    @InvocableMethod
    public static void createOrganizerWO(List<InputWrapper> inputWrapperList) {
        Boolean toExit = inputWrapperList==null || inputWrapperList.isEmpty() || !Schema.sObjectType.WorkOrder.isAccessible() || !Schema.sObjectType.WorkType.isAccessible();
        if(toExit){
            return;
        }
        List<String> taskIds = new List<String>();
        for(InputWrapper iw : inputWrapperList){
            taskIds.add(iw.taskId);
        }
         Map<Id, project_cloud__Project_Task__c> taskMap = getProjectTasksMap(taskIds);
        Id workTypeOrganizer = null;
        try {
          workTypeOrganizer = [
                    SELECT Id, Name, DurationInMinutes
                    FROM WorkType
                    WHERE Name = 'Organizer' and XC_LegalEntity__c = :taskMap.values()[0].project_cloud__Project_Phase__r.project_cloud__Project__r.XC_LegalEntity__c
                		and XC_Segment__c = :taskMap.values()[0].project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Segment__c
                    limit 1
            ][0].Id;
        }catch(Exception e){
            workTypeOrganizer = null;
        }
        Map<Id, Map<id,NE__OrderItem__c>> orderItemsByTask = getOrderItemsByTask(taskMap.values());
        contrMap = getContractsByTasksMap(taskMap.values());
        activeContrMap = getActiveContractsByTasksMap(taskMap.values());
        wbeByTask = getWbeByTask(taskMap.values());
        populateWorkOrderByItemMap(taskMap.values());

        List<WorkOrder> toInsertWO = generateWO(taskMap,workTypeOrganizer);
        //XC_UTIL_Sobject.insertListRecords(toInsertWO);
        upsert toInsertWO;

        Map<Id,Integer> numExistingWoli = getNumWOLI(XC_UTIL_Sobject.getListFieldValues(toInsertWO,'Id'));
        Set<Id> existingPR = getExistingProductRequest(XC_UTIL_Sobject.getListFieldValues(toInsertWO,'Id'));

        List<project_cloud__Project_Phase__c> phasesToUpdate = new List<project_cloud__Project_Phase__c>();
        for(WorkOrder w : toInsertWO){
            if(w.XC_Project_Task__r != null) {
                w.XC_Project_Task__r.project_cloud__Project_Phase__r.XC_WorkOrder__c = w.Id;
                phasesToUpdate.add(w.XC_Project_Task__r.project_cloud__Project_Phase__r);
            }
        }
        update phasesToUpdate;

        List<WorkOrderLineItem> toInsertWOLI = generateWOLI(taskMap,orderItemsByTask,numExistingWoli);
        //XC_UTIL_Sobject.insertListRecords(toInsertWOLI);
        insert toInsertWOLI;
        /*Map<Id,WorkOrderLineItem> organizerWOLIByTaskId = new Map<Id,WorkOrderLineItem>();
        for(WorkOrderLineItem woli : toInsertWOLI){
            organizerWOLIByTaskId.put(woli.WorkOrder.XC_Project_Task__c,woli);
        }*/

        Map<Id, Id> warehouseIdMAp = XC_UTIL_WOLICreateGoodIssue.getMapWorkOrderLineItemWarehouse(toInsertWOLI);
        for(WorkOrderLineItem woli : toInsertWOLI){
            woli.XC_WarehouseId__c = warehouseIdMAp.get(woli.Id);
            try{
                Map<id,NE__OrderItem__c> taskOI = orderItemsByTask.get(woli.XC_Project_Task__c);
                Id selectedContractID = taskOI != null && !taskOI.isEmpty() ?
                    (taskOI.values()[0].XC_ParentCommercialItem__r.XC_PartnerContract__c != null ?
                     taskOI.values()[0].XC_ParentCommercialItem__r.XC_PartnerContract__c : taskOI.values()[0].XC_PartnerContract__c) : null;
                
                if(selectedContractID!=null && taskOI.values()[0].XC_ParentCommercialItem__r.XC_Provider__c == woli.XC_AccountId__c && woli.XC_Project_Task__r.XC_TaskReason__c == 'Partner Engagement'){
                    woli.XC_ContractId__c = selectedContractID;
                }
            }catch(Exception e){
                System.debug('selectedContractID: '+e.getMessage());
                System.debug('selectedContractID: '+e.getStackTraceString());
            }
        }
        update toInsertWOLI;

        List<ProductRequired> toInsertProdReq = new List<ProductRequired>();
        for(WorkOrderLineItem woli : toInsertWOLI){
            Map<id,NE__OrderItem__c> taskOI = orderItemsByTask.get(woli.XC_Project_Task__c);
            if(taskOI!=null && !taskOI.isEmpty()) {
                toInsertProdReq.addAll(generateProductRequired(taskOI, woli, existingPR));
            }
        }
        XC_UTIL_Sobject.insertListRecords(toInsertProdReq);

        for(XC_RequiredPosition__c rpos : allPositions){
            ProductRequired pr = prodReqByProduct2.get(rpos.XC_WorkOrderLineItem__c+'§'+rpos.XC_ProductRequired__r.Product2Id);
            rpos.XC_ProductRequired__c = pr != null ? pr.Id : null;
        }
        XC_UTIL_Sobject.insertListRecords(allPositions);
        //Database.insert(toInsertProdReq,false);

    }


    private static Map<Id, project_cloud__Project_Task__c> getProjectTasksMap(List<String> taskIds){
        Boolean toExit = taskIds==null || taskIds.isEmpty() || !Schema.sObjectType.project_cloud__Project_Task__c.isAccessible();
        if(toExit){
            return new Map<Id, project_cloud__Project_Task__c>();
        }

        Map<Id, project_cloud__Project_Task__c> retMap = new Map<Id, project_cloud__Project_Task__c>(
        [select Id, XC_PreferredPartner__c, XC_Segment__c, XC_TaskReason__c, XC_OrderItem__c, XC_TaskType__c,
                project_cloud__Project_Phase__r.project_cloud__Project__r.project_cloud__Type__c,
                project_cloud__Project_Phase__r.project_cloud__Project__r.OwnerId, //NA25112020
                project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_LegalEntity__c,
                project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.NE__AccountId__c,
                project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_DeliveryAddress__c,
                project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_InstallationAddress__c,
                project_cloud__Project_Phase__r.project_cloud__Project__r.ccpe_ocp__Opportunity__c,
                project_cloud__Project_Phase__r.project_cloud__Project__r.ccpe_ocp__Account__c,
                project_cloud__Project_Phase__r.project_cloud__Project__r.XC_ConfigurationItem__c,
                project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__c,
                project_cloud__Project_Phase__r.project_cloud__Project__r.XC_LegalEntity__c,
                project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Segment__c,
				project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Contract__c,//NA04062021
                project_cloud__Project_Phase__r.Id, project_cloud__Project_Phase__c,
                project_cloud__Project_Phase__r.XC_WorkOrder__c,
                project_cloud__End__c,
                project_cloud__Project_Phase__r.XC_WorkOrder__r.Id,
                project_cloud__Project_Phase__r.XC_WorkOrder__r.XC_DueDate__c,
                project_cloud__Project_Phase__r.XC_WorkOrder__r.XC_LegalEntity__c,
                project_cloud__Project_Phase__r.XC_WorkOrder__r.XC_Segment__c,
                project_cloud__Project_Phase__r.XC_WorkOrder__r.XC_Project_Task__r.Id,
                project_cloud__Project_Phase__r.XC_WorkOrder__r.XC_Project_Task__r.XC_OrderItem__c,
                project_cloud__Project_Phase__r.XC_WorkOrder__r.XC_Project_Task__r.project_cloud__Project_Phase__r.Id,
                project_cloud__Project_Phase__r.XC_WorkOrder__r.XC_Project_Task__r.project_cloud__Project_Phase__r.XC_WorkOrder__c,
                XC_Address__r.XC_City__c, XC_Address__r.XC_AddressCountry__c, XC_Address__r.XC_Region__c,
                XC_Address__r.XC_Address__c, XC_Address__r.XC_StreetNumber__c, XC_Address__r.XC_PostalCode__c, XC_Address__r.Id, XC_Address__c,
                project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_InstallationAddress__r.XC_City__c, project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_InstallationAddress__r.XC_AddressCountry__c, project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_InstallationAddress__r.XC_Region__c,
                project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_InstallationAddress__r.XC_Address__c, project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_InstallationAddress__r.XC_StreetNumber__c, project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_InstallationAddress__r.XC_PostalCode__c, project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_InstallationAddress__r.Id,
                project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_DeliveryAddress__r.XC_City__c, project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_DeliveryAddress__r.XC_AddressCountry__c, project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_DeliveryAddress__r.XC_Region__c,
                project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_DeliveryAddress__r.XC_Address__c, project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_DeliveryAddress__r.XC_StreetNumber__c, project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_DeliveryAddress__r.XC_PostalCode__c, project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_DeliveryAddress__r.Id,
                XC_Contract__c,
                XC_Ordinary_Maintenance__c, //NR2059 - Eleni Tsiolaki - 30/11/2021 - Added the XC_Ordinary_Maintenance__c field
                XC_LCLHolder__c,
                XC_Executor__c


        from project_cloud__Project_Task__c where id in :taskIds]
        );

        return retMap;
    }


    private static Map<Id, Contract> getContractsByTasksMap(List<project_cloud__Project_Task__c> taskIds){
        Boolean toExit = taskIds==null || taskIds.isEmpty() || !Schema.sObjectType.Contract.isAccessible();
        if(toExit){
            return new Map<Id, Contract>();
        }
        List<String> accId = XC_UTIL_Sobject.getListFieldValues(taskIds,'XC_PreferredPartner__c');
        Map<Id, Contract> contMap = new Map<Id, Contract>(
        [select Id,AccountId from Contract where AccountId in :accId and 	RecordType.DeveloperName = 'XC_ContractPartner']
        );
        Map<Id, Contract> retMap = new Map<Id, Contract>();
        for(project_cloud__Project_Task__c pt : taskIds){
            for(Contract c : contMap.values()){
                if(pt.XC_PreferredPartner__c == c.AccountId){

                    if(!retMap.containsKey(pt.Id)){
                        retMap.put(pt.Id,c);
                    }else{
                        retMap.put(pt.Id,null);
                    }
                }
            }
        }
        return retMap;
    }

    private static Map<Id, Contract> getActiveContractsByTasksMap(List<project_cloud__Project_Task__c> taskIds){
        Boolean toExit = taskIds==null || taskIds.isEmpty() || !Schema.sObjectType.Contract.isAccessible();
        if(toExit){
            return new Map<Id, Contract>();
        }
        List<String> confIds = new List<String>();
        List<string> contractId=new List<String>();
        for(project_cloud__Project_Task__c t : taskIds){
            confIds.add(t.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__c);
            contractId.add(t.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Contract__c);
        }
        List<Contract> contractList=new List<Contract>();
        Map<Id, Contract> contMap = new Map<Id, Contract>();
        //NA0406
        if(confIds[0]!=null){
            system.debug('if confIds '+confIds);
            contractList =[select Id,AccountId, XC_CIG__c,XC_CUP__c,XC_Configurations__c from Contract where XC_Configurations__c in :confIds];                
        }else if(contractId[0]!=null){
            system.debug('if contractId '+contractId[0]);
            contractList =[select Id,AccountId, XC_CIG__c,XC_CUP__c,XC_Configurations__c from Contract where XC_Configurations__c in :contractId];
        }
      /*  for(contract c:contractList){
            contMap.put(c.id,c);
        }*/
        Map<Id, Contract> retMap = new Map<Id, Contract>();
        for(project_cloud__Project_Task__c pt : taskIds){
            for(Contract c : contractList){
                if(c.XC_Configurations__c!=null &&
                    pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__c == c.XC_Configurations__c){
                    retMap.put(pt.Id,c);
                }else if(pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Contract__c!=null &&
                          pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__c ==null &&
                          pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Contract__c==c.id ){
                            retMap.put(pt.Id,c);    
                }
            }
        }
        return retMap;
    }



    private static Map<Id, Integer> getNumWOLI(List<String> woID){
        Boolean toExit = woID==null || woID.isEmpty() || !Schema.sObjectType.WorkOrderLineItem.isAccessible();
        if(toExit){
            return new Map<Id, Integer>();
        }
        Map<id,Integer> retMap = new Map<Id, Integer>();
        List<AggregateResult> aggregateResultList = [SELECT WorkOrderId, count(Id) nomWoli FROM WorkOrderLineItem WHERE WorkOrderId in :woID and RecordType.DeveloperName like '%_PE_WOLI' group by WorkOrderId];
        for(AggregateResult aggr : aggregateResultList){
            retMap.put((id)aggr.get('WorkOrderId'),(Integer) aggr.get('nomWoli'));
        }

        return retMap;
    }

    private static Set<Id> getExistingProductRequest(List<String> woID){
        Boolean toExit = woID==null || woID.isEmpty() || !Schema.sObjectType.ProductRequired.isAccessible();
        if(toExit){
            return new Set<Id>();
        }
        Set<Id> ret = new Set<Id>();
        List<ProductRequired> prlist = [SELECT id, XC_OrderItem__c FROM ProductRequired WHERE XC_WorkOrderId__c in :woID];
        ret.addAll((List<Id>) XC_UTIL_Sobject.getListFieldValues(prlist, 'XC_OrderItem__c'));

        return ret;
    }

    private static Map<Id, String> getWbeByTask(List<project_cloud__Project_Task__c> tasks){
        Boolean toExit = tasks==null || tasks.isEmpty() || !Schema.sObjectType.project_cloud__Project_Task__c.isAccessible() || !Schema.sObjectType.NE__OrderItem__c.isAccessible();
        if(toExit){
            return new Map<Id, String>();
        }
        Map<Id, String> retMap = new Map<Id, String>();
        List<String> configItemIds = new List<String>();
        List<String> configIds     = new List<String>();

        for(project_cloud__Project_Task__c t : tasks){
            if(t.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_ConfigurationItem__c!=null){
                configItemIds.add(t.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_ConfigurationItem__c);
            } else if(t.XC_OrderItem__c != null){
                configItemIds.add(t.XC_OrderItem__c);
            }
            else{
                configIds.add(t.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__c);
            }
        }

        List<NE__OrderItem__c> oiByIdList = [select id,XC_Product2Id__c, NE__OrderId__c, XC_Segment__c, XC_LegalEntity__c, NE__One_Time_Cost__c, XC_Product2Id__r.XC_SapType__c,
                XC_Wbe__c, XC_ParentCommercialItem__r.XC_Wbe__c, NE__Qty__c, XC_PartnerContract__c, XC_PartnerContract__r.Id, XC_ParentCommercialItem__r.XC_CMCostCenter__c, XC_CMCostCenter__c, XC_ParentCommercialItem__c, XC_ServicePosition__c, XC_GiiPriceBookEntry_Id__c
        from NE__OrderItem__c where (id in :configItemIds or NE__Parent_Order_Item__c in :configItemIds or NE__OrderId__c in :configIds)];


        for(project_cloud__Project_Task__c pt : tasks){
            for(NE__OrderItem__c oi : oiByIdList) {
                if ((pt.XC_OrderItem__c == oi.Id || pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_ConfigurationItem__c == oi.Id ||
                        pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__c == oi.NE__OrderId__c) && oi.XC_Wbe__c != null) {
                    retMap.put(pt.id,oi.XC_Wbe__c);
                }
            }
        }
        return retMap;
    }

    private static Map<Id, Map<id,NE__OrderItem__c>> getOrderItemsByTask(List<project_cloud__Project_Task__c> tasks){
        Boolean toExit = tasks==null || tasks.isEmpty() || !Schema.sObjectType.project_cloud__Project_Task__c.isAccessible() || !Schema.sObjectType.NE__OrderItem__c.isAccessible();
        if(toExit){
            return new Map<Id, Map<id,NE__OrderItem__c>>();
        }
        List<String> configItemIds = new List<String>();
        List<String> configIds     = new List<String>();

        for(project_cloud__Project_Task__c t : tasks){
            if(t.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_ConfigurationItem__c!=null){
                configItemIds.add(t.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_ConfigurationItem__c);
            }else{
                configIds.add(t.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__c);
            }
        }

        List<NE__OrderItem__c> oiByIdList = [select id,XC_Product2Id__c, NE__OrderId__c, XC_Segment__c, XC_LegalEntity__c, NE__One_Time_Cost__c, XC_Product2Id__r.XC_SapType__c,
                XC_Wbe__c, XC_ParentCommercialItem__r.XC_Wbe__c, NE__Qty__c,XC_ParentCommercialItem__r.XC_Provider__c, XC_ParentCommercialItem__r.XC_PartnerContract__c, XC_PartnerContract__c, XC_PartnerContract__r.Id, XC_ParentCommercialItem__r.XC_CMCostCenter__c, XC_CMCostCenter__c, XC_ParentCommercialItem__c, XC_ServicePosition__c, XC_GiiPriceBookEntry_Id__c
        from NE__OrderItem__c where XC_Product2Id__c != null and (XC_Product2Id__r.XC_SapType__c = 'Service' or XC_Product2Id__r.XC_SapType__c = 'Material') and //RecordType.DeveloperName = 'Technical_Item' and
        (XC_ParentCommercialItem__c in :configItemIds or XC_ParentCommercialItem__r.NE__Parent_Order_Item__c in :configItemIds or NE__OrderId__c in :configIds)];
        //List<NE__OrderItem__c> oiByOrderList = [select id, NE__OrderId__c from NE__OrderItem__c where NE__OrderId__c in :configIds and XC_ParentCommercialItem__c = null];

        List<NE__OrderItem__c> allOrderItems = new List<NE__OrderItem__c>();
        Set<NE__OrderItem__c> remdupl = new Set<NE__OrderItem__c>();
        remdupl.addAll(oiByIdList);
        //remdupl.addAll(oiByOrderList);
        allOrderItems.addAll(remdupl);

        if(allOrderItems.isEmpty()){
            return new Map<Id, Map<id,NE__OrderItem__c>>();
        }

        Map<Id,List<NE__OrderItem__c>> oiByProjectIdMap = new Map<Id,List<NE__OrderItem__c>>();
        for(NE__OrderItem__c oi : allOrderItems){
            if(oiByProjectIdMap.get(oi.NE__OrderId__c)==null){
                oiByProjectIdMap.put(oi.NE__OrderId__c,new List<NE__OrderItem__c>());
            }
            oiByProjectIdMap.get(oi.NE__OrderId__c).add(oi);
        }

        Map<Id, Map<id,NE__OrderItem__c>> retMap = new Map<Id, Map<id,NE__OrderItem__c>>();
        for(project_cloud__Project_Task__c pt : tasks){
            retMap.put(pt.id,new Map<Id,NE__OrderItem__c>(oiByProjectIdMap.get(pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__c)));
        }

        return retMap;
    }


    private static void populateWorkOrderByItemMap(List<project_cloud__Project_Task__c> stepIds){
        Boolean toExit = stepIds==null || stepIds.isEmpty() || !Schema.sObjectType.WorkOrder.isAccessible();
        if(toExit){
            return;
        }
        List<String> partnerId = XC_UTIL_Sobject.getListFieldValues(stepIds,'XC_PreferredPartner__c');
        List<String> phaseId = XC_UTIL_Sobject.getListFieldValues(stepIds,'project_cloud__Project_Phase__c');
        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>(
        [select Id,XC_Configuration_Item__c, XC_Address__c, XC_ProjectPhase__c, XC_Project_Task__c, XC_PreferredPartner__c, XC_Segment__c, XC_DueDate__c, XC_LegalEntity__c,
                XC_Address__r.XC_AddressCountry__c,
                XC_Address__r.XC_Region__c,
                XC_Address__r.XC_Address__c,
                XC_Address__r.XC_StreetNumber__c,
                XC_Address__r.XC_City__c,
                XC_Address__r.XC_PostalCode__c,
                XC_ContractOwner__c
        from WorkOrder where XC_ProjectPhase__c in :phaseId and XC_WorkTypeLabel__c  like 'Organizer' and XC_ContractOwner__c in :partnerId ]
        );

        for(project_cloud__Project_Task__c pt : stepIds) {
            for (WorkOrder wo : woMap.values()) {
                Boolean isCorrectWO = wo.XC_PreferredPartner__c!=null && pt.XC_Executor__c != null && wo.XC_PreferredPartner__c == pt.XC_Executor__c && wo.XC_ProjectPhase__c == pt.project_cloud__Project_Phase__c;
                isCorrectWO = isCorrectWO && wo.XC_ContractOwner__c != null &&  pt.XC_PreferredPartner__c != null && wo.XC_ContractOwner__c == pt.XC_PreferredPartner__c;
                if(isCorrectWO){
                    woByTask.put(pt.Id, wo);
                }
            }
        }
    }

    private static List<WorkOrder> generateWO(Map<Id, project_cloud__Project_Task__c> taskMap, Id workTypeOrganizer){
        List<WorkOrder> retList = new List<WorkOrder>();

        String le = !taskMap.isEmpty() ? taskMap.values()[0].project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_LegalEntity__c : null;
        String str = !taskMap.isEmpty() ? taskMap.values()[0].XC_Segment__c : null;
        String orgId = UserInfo.getOrganizationId();
         if(le==null){
            le=!taskMap.isEmpty() ? taskMap.values()[0].project_cloud__Project_Phase__r.project_cloud__Project__r.XC_LegalEntity__c:null;
        }
        XC_CM_LegalEntity_Configuration__mdt currentLEConf =
        [
                SELECT ID,XC_LegalEntity__c,XC_AllowCreditAssignment__c,XC_RecordType_WorkOrder__c
                FROM XC_CM_LegalEntity_Configuration__mdt
                WHERE XC_LegalEntity__c = :le AND XC_OrgId__c = :orgId AND XC_Stream__c = :str
                LIMIT 1
        ];

        for(project_cloud__Project_Task__c pt : taskMap.values()){
            //if(pt.project_cloud__Project_Phase__r.XC_WorkOrder__r != null){
            if(woByTask.get(pt.Id) != null){
                //pt.project_cloud__Project_Phase__r.XC_WorkOrder__r.XC_Project_task__c = pt.id;
                //pt.project_cloud__Project_Phase__r.XC_WorkOrder__r.XC_Project_task__r = pt;
                retList.add(pt.project_cloud__Project_Phase__r.XC_WorkOrder__r);
                //woByTask.put(pt.Id,pt.project_cloud__Project_Phase__r.XC_WorkOrder__r);
                continue;
            }
            WorkOrder wo = new WorkOrder();
            wo.Status = 'New';
            wo.StartDate = Date.today();
            wo.XC_DueDate__c = pt.project_cloud__End__c;//Date.today();
            wo.XC_OriginalDueDate__c = Date.today();
            wo.XC_ContractOwner__c = pt.XC_PreferredPartner__c;
            wo.XC_PreferredPartner__c = pt.XC_Executor__c;
            wo.XC_Project_task__c = pt.id;
            wo.XC_Project_task__r = pt;
            String recTypeNameStr = 'XC_'+pt.XC_Segment__c+'_'+pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_LegalEntity__c+'_WorkOrder';

            recTypeNameStr = currentLEConf.XC_RecordType_WorkOrder__c;
            //String recTypeNameStr = 'XC_'+pt.XC_Segment__c+'_'+pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_LegalEntity__c+'_WorkOrder';
            System.debug('recTypeNameStr:'+recTypeNameStr);
            wo.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(recTypeNameStr).getRecordTypeId();
            wo.XC_WorkTypeCategory__c = 'Organizer';
            wo.XC_WorkTypeLabel__c = 'Organizer';
            wo.XC_ToProject__c = true;
            wo.WorkTypeId = workTypeOrganizer;
            wo.AccountId = pt.project_cloud__Project_Phase__r.project_cloud__Project__r.ccpe_ocp__Account__c;
            wo.XC_Opportunity__c = pt.project_cloud__Project_Phase__r.project_cloud__Project__r.ccpe_ocp__Opportunity__c;
            wo.XC_LegalEntity__c = pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_LegalEntity__c;
            wo.XC_Segment__c = pt.XC_Segment__c;//pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Segment__c;
            wo.XC_ProjectPhase__c = pt.project_cloud__Project_Phase__c;
            wo.XC_ProjectPhase__r = pt.project_cloud__Project_Phase__r;
            wo.XC_Configuration_Item__c = pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_ConfigurationItem__c;
            wo.XC_Configuration__c = pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__c;
            wo.XC_Ordinary_Maintenance__c = pt.XC_Ordinary_Maintenance__c; // NR2059 - Eleni Tsiolaki - 30/11/2021 - inherit the value from the project task
            //wo.XC_Address__c = pt.XC_Address__c != null ? pt.XC_Address__c : (pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_InstallationAddress__c != null ? pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_InstallationAddress__c : pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_DeliveryAddress__c);
            //wo.XC_Address__c = pt.XC_Address__c;
            //if(wo.XC_Address__c == null) {
            wo.XC_Address__c = pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_InstallationAddress__c != null ? pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_InstallationAddress__c : pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_DeliveryAddress__c;
            wo.XC_Address__r = pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_InstallationAddress__r != null ? pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_InstallationAddress__r : pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Configuration__r.XC_DeliveryAddress__r;
            //}
            woByTask.put(pt.Id,wo);
            retList.add(wo);
        }

        return retList;
    }

    private static List<WorkOrderLineItem> generateWOLI(Map<Id, project_cloud__Project_Task__c> taskMap,Map<Id, Map<id,NE__OrderItem__c>> orderItemsByTask, Map<Id,Integer> numExistingWoli){
        List<WorkOrderLineItem> retList = new List<WorkOrderLineItem>();

        for(String taskId : woByTask.keySet()){
            WorkOrder wo = woByTask.get(taskId);
            project_cloud__Project_Task__c pt = taskMap.get(taskId);
            if(wo == null || pt == null){
                continue;
            }
            WorkOrderLineItem woli = new WorkOrderLineItem();
            Contract contr;
            woli.XC_ProjectManager__c=pt.project_cloud__Project_Phase__r.project_cloud__Project__r.OwnerId; //NA25112020
            woli.XC_AccountId__c = pt.XC_PreferredPartner__c;

            String recTypeNameStr = null;
            if(pt.XC_TaskReason__c == 'Partner Engagement') {

                recTypeNameStr = 'XC_' + wo.XC_Segment__c + '_' + wo.XC_LegalEntity__c + '_PE_WOLI';
                woli.RecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get(recTypeNameStr).getRecordTypeId();
                woli.XC_WOLIType__c = pt.XC_TaskReason__c;
                woli.XC_LCLDocumentRequired__c = false;

                woli.XC_PurchaseOrderPosition__c = numExistingWoli.get(wo.Id) != null ? (numExistingWoli.get(wo.Id)+1)*10 : 10;

                /*try{
                    contr = orderItemsByTask.get(pt.Id).values()[0].XC_PartnerContract__r;
                    woli.XC_ContractId__c = contr.Id;
                }catch(Exception e){
                    woli.XC_ContractId__c = null;
                }*/
                woli.XC_ContractId__c = pt.XC_Contract__c != null ? pt.XC_Contract__c : contrMap.get(pt.Id) != null ? contrMap.get(pt.Id).Id : null;

                //woli.XC_AccountAssignmentCategory__c = gii__PriceBookEntry__c.giic_AccountAssignmentCategory__c; //TODO Selezionabile dal'utente su SFA se sul contratto era presente la U (selezionare K o P), altrimenti preso come indicato sul contratto.
                woli.XC_LCLHolder__c = pt.XC_LCLHolder__c;
            }else if(pt.XC_TaskReason__c == 'Material Supply' || pt.XC_TaskReason__c == 'Delivery'){
                recTypeNameStr = 'XC_' + wo.XC_Segment__c + '_' + wo.XC_LegalEntity__c + (pt.XC_TaskReason__c == 'Delivery' ? '_Delivery' : '_MR_WOLI');
                woli.RecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get(recTypeNameStr).getRecordTypeId();

                //Delivery field - Questo campo va valorizzato solo se il project task di partenza è di tipo delivery
                woli.XC_IsaDelivery__c = pt.XC_TaskReason__c == 'Delivery';
                woli.XC_WOLIType__c = pt.XC_TaskReason__c;
                if(pt.XC_Address__r != null && pt.XC_TaskReason__c == 'Delivery') {
                    woli.XC_ShipToCity__c = pt.XC_Address__r.XC_City__c;
                    woli.XC_ShipToCountry__c = pt.XC_Address__r.XC_AddressCountry__c;
                    woli.XC_ShipToStateProvince__c = pt.XC_Address__r.XC_Region__c;
                    woli.XC_ShipToStreet__c = pt.XC_Address__r.XC_Address__c + ', ' + pt.XC_Address__r.XC_StreetNumber__c;
                    woli.XC_ShipToZipPostalCode__c = pt.XC_Address__r.XC_PostalCode__c;
                    woli.XC_DropShip__c = pt.XC_TaskReason__c == 'Delivery';
                }else if(wo.XC_Address__r!=null && pt.XC_TaskReason__c == 'Delivery'){
                    woli.XC_ShipToCity__c = wo.XC_Address__r.XC_City__c;
                    woli.XC_ShipToCountry__c = wo.XC_Address__r.XC_AddressCountry__c;
                    woli.XC_ShipToStateProvince__c = wo.XC_Address__r.XC_Region__c;
                    woli.XC_ShipToStreet__c = wo.XC_Address__r.XC_Address__c + ', ' + wo.XC_Address__r.XC_StreetNumber__c;
                    woli.XC_ShipToZipPostalCode__c = wo.XC_Address__r.XC_PostalCode__c;
                    woli.XC_DropShip__c = pt.XC_TaskReason__c == 'Delivery';
                }
                woli.XC_AccountId__c = pt.XC_Executor__c;

            }


            woli.Status = 'New';
            woli.WorkOrderId = wo.Id;
            woli.WorkOrder = wo;
            woli.StartDate = Date.today();
            woli.EndDate = wo.XC_DueDate__c >Date.today() ? wo.XC_DueDate__c : Date.today();

            //woli.XC_AccountId__c = pt.XC_PreferredPartner__c;
            woli.XC_Project_Task__c = pt.Id;
            woli.XC_Project_Task__r = pt;

            String wbs;
            try{
                String wbe = wbeByTask.get(pt.Id); //orderItemsByTask.get(pt.Id).values()[0].XC_ParentCommercialItem__r.XC_Wbe__c;
                wbs = wbe != null && wbe.length()>12 ? wbe.substring(0,12) : wbe;
            }catch(Exception e){
                wbs = null;
            }
            woli.XC_WBSElement__c = wbs;

            Contract activeContr = activeContrMap.get(pt.Id);
            if(activeContr != null){
                woli.XC_CIG__c = activeContr.XC_CIG__c;
                woli.XC_CUP__c = activeContr.XC_CUP__c;
            }

            retList.add(woli);
        }

        return retList;
    }

    private static List<ProductRequired> generateProductRequired(Map<Id, NE__OrderItem__c> techItemMap,WorkOrderLineItem woli, Set<Id> existingPR){
        List<ProductRequired> retList = new List<ProductRequired>();
        Integer numPR = 0;
        for(id ptId : techItemMap.keySet()) {
            NE__OrderItem__c pt = techItemMap.get(ptId);
            ProductRequired pr = new ProductRequired();
            Boolean isMaterialOrdItem = pt.XC_Product2Id__r.XC_SapType__c == 'Material';

            // If ORder item is defined on the task, use only that item ---- if a product required already exist for that tech item -> skip
            Boolean skipOI = (woli.XC_Project_Task__r.XC_OrderItem__c != null && woli.XC_Project_Task__r.XC_OrderItem__c != pt.XC_ParentCommercialItem__c) || existingPR.contains(pt.Id);
            Boolean skipMaintenance = woli.XC_Project_Task__r.project_cloud__Project_Phase__r.project_cloud__Project__r.project_cloud__Type__c != null && woli.XC_Project_Task__r.project_cloud__Project_Phase__r.project_cloud__Project__r.project_cloud__Type__c == 'Maintenance Plan';
            Boolean skipDifferentPartner = pt.XC_ParentCommercialItem__r.XC_Provider__c != null && pt.XC_ParentCommercialItem__r.XC_Provider__c != woli.XC_AccountId__c;
            
            if (skipOI || skipMaintenance || skipDifferentPartner) {
                continue;
            }
            ////////////////////////
            if(!prodReqByProduct2.containsKey(woli.Id+'§'+pt.XC_Product2Id__c)){
                if (woli.XC_Project_Task__r.XC_TaskReason__c == 'Partner Engagement') {
                    if (isMaterialOrdItem) {
                        continue;
                    }
                    String recTypeNameStr = 'XC_' + pt.XC_Segment__c + '_' + pt.XC_LegalEntity__c + '_PartnerEngagement';
                    pr.RecordTypeId = Schema.SObjectType.ProductRequired.getRecordTypeInfosByDeveloperName().get(recTypeNameStr).getRecordTypeId();

                } else if (woli.XC_Project_Task__r.XC_TaskReason__c == 'Material Supply' || woli.XC_Project_Task__r.XC_TaskReason__c == 'Delivery') { //TODO check correct task reason
                    if (!isMaterialOrdItem) {
                        continue;
                    }
                    String recTypeNameStr = 'XC_' + pt.XC_Segment__c + '_' + pt.XC_LegalEntity__c + '_MaterialRequest';
                    pr.RecordTypeId = Schema.SObjectType.ProductRequired.getRecordTypeInfosByDeveloperName().get(recTypeNameStr).getRecordTypeId();
                    pr.XC_OrderQuantity__c = pt.NE__Qty__c;
                }
                pr.XC_OrderItem__c = pt.XC_ParentCommercialItem__c;
                pr.ParentRecordId = woli.Id;

                pr.Product2Id = pt.XC_Product2Id__c;
                pr.XC_PriceUnits__c = pt.NE__One_Time_Cost__c;
                //pr.XC_GrossPrice__c  = pt.XC_TotalAdded__c;
                pr.QuantityRequired = pt.NE__Qty__c;
                pr.XC_Quantity__c = pt.NE__Qty__c;

                pr.XC_WorkOrderLineItem__c = woli.Id;
                pr.XC_WorkOrderId__c = woli.WorkOrder.Id;

                pr.XC_PurchaseOderPositionOdA__c = String.valueOf((numPR + 1) * 10);
                numPR = numPR + 1;

                pr.XC_WBSElement__c = pt.XC_ParentCommercialItem__r.XC_Wbe__c;
                pr.XC_CostCenter__c = pt.XC_ParentCommercialItem__r.XC_CMCostCenter__c;
                retList.add(pr);
            }else{
                pr=prodReqByProduct2.get(woli.Id+'§'+pt.XC_Product2Id__c);
            }
            if(woli.XC_Project_Task__r.XC_TaskReason__c == 'Partner Engagement') {
                XC_RequiredPosition__c reqPosition = new XC_RequiredPosition__c();
                reqPosition.XC_PositionCode__c = pt.XC_ServicePosition__c;
                reqPosition.XC_PricebookEntry__c = String.valueOf(pt.XC_GiiPriceBookEntry_Id__c);
                reqPosition.XC_ProductRequired__c = pr.Id;
                reqPosition.XC_ProductRequired__r = pr;
                reqPosition.XC_WorkOrderLineItem__c = woli.Id;
                reqPosition.XC_Quantity__c =  pt.NE__Qty__c;
                reqPosition.XC_UnitPrice__c = pt.NE__One_Time_Cost__c;
                reqPosition.XC_WBE__c = pt.XC_ParentCommercialItem__r.XC_Wbe__c;
                reqPosition.XC_CostCenter__c = pt.XC_ParentCommercialItem__r.XC_CMCostCenter__c;
                allPositions.add(reqPosition);
                prodReqByProduct2.put(woli.Id+'§'+pr.Product2Id,pr);
            }


            //return retList; //TEST
        }
        return retList;
    }



    public static Map<Id, Id> getMapWorkOrderLineItemWarehouse(List<WorkOrderLineItem> listWOLI) {
        Map<Id, Id> mapWorkOrderIdWarehouseId = new Map<Id, Id>();
        Map<String, List<String>> mapAccountProvinces = new Map<String, List<String>>();
        List<String> leList = new List<String>();
        for(WorkOrderLineItem w : listWOLI){
            leList.add(w.workOrder.XC_LegalEntity__c);
        }
        Map<String,String> virtualWH = XC_UTIL_TechnicalCart.getVirtualWarehousesMap(leList);
        for(WorkOrderLineItem woli : listWOLI) {
            if(woli.XC_AccountId__c!=null && woli.XC_ShipToStateProvince__c!=null) {
                if (!mapAccountProvinces.containsKey(woli.XC_AccountId__c)) {
                    mapAccountProvinces.put(woli.XC_AccountId__c, new List<String>());
                }
                mapAccountProvinces.get(woli.XC_AccountId__c).add(woli.XC_ShipToStateProvince__c);
            }
        }
        if(mapAccountProvinces.isEmpty()) {
            return mapWorkOrderIdWarehouseId;
        }

        Map<String, gii__Warehouse__c> mapKeyWarehouse = XC_UTIL_Glovia.getMapWarehouses(mapAccountProvinces);
        for(WorkOrderLineItem woli : listWOLI) {
            if(woli.XC_WOLIType__c == 'Delivery'){
                mapWorkOrderIdWarehouseId.put(woli.Id, virtualWH.get(woli.workOrder.XC_LegalEntity__c));
                continue;
            }
            if(woli.XC_ShipToStateProvince__c != null && mapKeyWarehouse.containsKey(woli.XC_ShipToStateProvince__c+'_'+woli.XC_AccountId__c)) {
                Id warehouseId = mapKeyWarehouse.get(woli.XC_ShipToStateProvince__c+'_'+woli.XC_AccountId__c).Id;
                mapWorkOrderIdWarehouseId.put(woli.Id, warehouseId);
            }
        }
        return mapWorkOrderIdWarehouseId;
    }


}