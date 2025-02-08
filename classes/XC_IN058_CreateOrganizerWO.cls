public without sharing class XC_IN058_CreateOrganizerWO {

    private static Map<String,WorkOrder> woByStep = new Map<String,WorkOrder>();
    private static Map<Id, Contract>     contrMap = new Map<Id, Contract>();
    private static Map<Id, Contract>     activeContrMap = new Map<Id, Contract>();																				  

    public class InputWrapper {

        /** The String. */
        @Invocablevariable
        public String stepId;

        @Invocablevariable
        public String stepType; //Partner Engagement or Material Request


    }

    private class WrapperCreateWOLI {
        Map<String,String> stepTypeById;
        Map<Id, XC_Provisioning_Step__c> stepMap;
        Map<Id, Map<id,NE__OrderItem__c>> orderItemsByStep;
        Map<Id,Integer> numExistingWoli;

        WrapperCreateWOLI(Map<String,String> stepTypeById,
                Map<Id, XC_Provisioning_Step__c> stepMap,
                Map<Id, Map<id,NE__OrderItem__c>> orderItemsByStep,
                Map<Id,Integer> numExistingWoli){

            this.stepTypeById = stepTypeById;
            this.stepMap = stepMap;
            this.orderItemsByStep = orderItemsByStep;
            this.numExistingWoli = numExistingWoli;

        }
    }

    /**
     * @author dpalamides - dpalamides@deloitte.it
     * @description createOrganizerWO manages the creation of the WO organizer for partner engagement steps
     * @param inputWrapperList the input wrapper list
     */
    @InvocableMethod
    public static void createOrganizerWO(List<InputWrapper> inputWrapperList) {
        Boolean toExit = inputWrapperList==null || inputWrapperList.isEmpty() || !Schema.sObjectType.WorkOrder.isAccessible() || !Schema.sObjectType.WorkType.isAccessible();
        if(toExit){
            return;
        }
        List<String> stepIds = new List<String>();
        Map<String,String> stepTypeById = new Map<String,String>();
        for(InputWrapper iw : inputWrapperList){
            stepIds.add(iw.stepId);
            stepTypeById.put(iw.stepId,iw.stepType);
        }


        Map<Id, XC_Provisioning_Step__c> stepMap = getProvisioningStepMap(stepIds);
        Map<Id, Map<id,NE__OrderItem__c>> orderItemsByStep = getOrderItemsByStep(stepMap.values());
        contrMap = getContractsByStepMap(stepMap.values());
        activeContrMap = getActiveContractsByStepsMap(stepMap.values());
        populateWorkOrderByItemMap(stepMap.values());
        List<WorkOrder> toInsertWO = woByStep.values(); //generateWO(stepMap);
        //XC_UTIL_Sobject.insertListRecords(toInsertWO);
        //upsert toInsertWO;

        Map<Id,Integer> numExistingWoli = getNumWOLI(XC_UTIL_Sobject.getListFieldValues(toInsertWO,'Id'));
        Set<Id> existingPR = getExistingProductRequest(XC_UTIL_Sobject.getListFieldValues(toInsertWO,'Id'));

        WrapperCreateWOLI genWOLIinput = new WrapperCreateWOLI(stepTypeById,stepMap,orderItemsByStep,numExistingWoli);
        List<WorkOrderLineItem> toInsertWOLI = generateWOLI(genWOLIinput);
        List<XC_UTIL_Sobject.WrapperResult> res = XC_UTIL_Sobject.insertListRecords(toInsertWOLI);


        /*List<XC_Provisioning_Step__c> toUpdateStep = new List<XC_Provisioning_Step__c>();
        for(WorkOrderLineItem w : toInsertWOLI){
            XC_Provisioning_Step__c s = new XC_Provisioning_Step__c();
            s.Id = w.XC_ProvisioningStep__c;
            if(w.Id != null){
                s.XC_Status__c = 'Completed OK';
            }else{
                s.XC_Status__c = 'Completed KO';
            }
            toUpdateStep.add(s);
        }
        XC_UTIL_Sobject.updateListRecords(toUpdateStep);*/



        /*List<ProductRequired> toInsertProdReq = new List<ProductRequired>();
        for(WorkOrderLineItem woli : toInsertWOLI){
           Map<id,NE__OrderItem__c> taskOI = orderItemsByStep.get(woli.XC_Project_Task__c);
           if(taskOI!=null){
               toInsertProdReq.addAll(generateProductRequired(taskOI,woli, existingPR));
           }
        }
        XC_UTIL_Sobject.insertListRecords(toInsertProdReq); */

    }


    private static Map<Id, XC_Provisioning_Step__c> getProvisioningStepMap(List<String> stepIds){
        Boolean toExit = stepIds==null || stepIds.isEmpty() || !Schema.sObjectType.XC_Provisioning_Step__c.isAccessible();
        if(toExit){
            return new Map<Id, XC_Provisioning_Step__c>();
        }

        Map<Id, XC_Provisioning_Step__c> retMap = new Map<Id, XC_Provisioning_Step__c>(
        [select Id, XC_Configuration_Item__r.XC_Provider__c, XC_Configuration_Item__c,XC_Configuration_Item__r.Id,
                XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c,
                XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c,
                XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__c,
                XC_Configuration_Item__r.NE__OrderId__r.NE__AccountId__c,
                XC_Configuration_Item__r.NE__OrderId__c,
                XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_City__c, XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_AddressCountry__c, XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_Region__c,
                XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_Address__c, XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_StreetNumber__c, XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_PostalCode__c, XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.Id,
                XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__c

        from XC_Provisioning_Step__c where id in :stepIds]
        );

        return retMap;
    }


    private static Map<Id, Contract> getContractsByStepMap(List<XC_Provisioning_Step__c> stepIds){
        Boolean toExit = stepIds==null || stepIds.isEmpty() || !Schema.sObjectType.Contract.isAccessible();
        if(toExit){
            return new Map<Id, Contract>();
        }
        List<String> accId = new List<String>();
        for(XC_Provisioning_Step__c s : stepIds){
            accId.add(s.XC_Configuration_Item__r.XC_Provider__c);
        }//XC_UTIL_Sobject.getListFieldValues(stepIds,'XC_Configuration_Item__r.XC_Provider__c');
        Map<Id, Contract> contMap = new Map<Id, Contract>(
        [select Id,AccountId from Contract where AccountId in :accId and 	RecordType.DeveloperName = 'XC_ContractPartner']
        );
        Map<Id, Contract> retMap = new Map<Id, Contract>();
        for(XC_Provisioning_Step__c pt : stepIds){
            for(Contract c : contMap.values()){
                if(pt.XC_Configuration_Item__r.XC_Provider__c == c.AccountId){
                    retMap.put(pt.Id,c);
                }
            }
        }
        return retMap;
    }

    private static void populateWorkOrderByItemMap(List<XC_Provisioning_Step__c> stepIds){
        Boolean toExit = stepIds==null || stepIds.isEmpty() || !Schema.sObjectType.WorkOrder.isAccessible();
        if(toExit){
            return;
        }
        List<String> itemId = XC_UTIL_Sobject.getListFieldValues(stepIds,'XC_Configuration_Item__c');
        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>(
        [select Id,XC_Configuration_Item__c,XC_PreferredPartner__c,OwnerId,XC_AssignedPartner__c, XC_Segment__c, XC_DueDate__c, XC_LegalEntity__c,CreatedById from WorkOrder where XC_Configuration_Item__c in :itemId and XC_WorkTypeLabel__c  like '%Installation%']
        );//NA25112020

        for(XC_Provisioning_Step__c st : stepIds) {
            for (WorkOrder wo : woMap.values()) {
                if(wo.XC_Configuration_Item__c == st.XC_Configuration_Item__c){
                    woByStep.put(st.Id, wo);
                }
            }
        }
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


    private static Map<Id, Map<id,NE__OrderItem__c>> getOrderItemsByStep(List<XC_Provisioning_Step__c> steps){
        Boolean toExit = steps==null || steps.isEmpty() || !Schema.sObjectType.XC_Provisioning_Step__c.isAccessible() || !Schema.sObjectType.NE__OrderItem__c.isAccessible();
        if(toExit){
            return new Map<Id, Map<id,NE__OrderItem__c>>();
        }
        List<String> configItemIds = new List<String>();
        List<String> configIds     = new List<String>();

        for(XC_Provisioning_Step__c t : steps){
            configItemIds.add(t.XC_Configuration_Item__c);
        }

        List<NE__OrderItem__c> oiByIdList = [select id,XC_Product2Id__c, NE__OrderId__c, XC_Segment__c, XC_LegalEntity__c, NE__One_Time_Cost__c, XC_Product2Id__r.XC_SapType__c, XC_Provider__c,
                XC_Wbe__c, XC_ParentCommercialItem__r.XC_Wbe__c, NE__Qty__c, XC_PartnerContract__c, XC_PartnerContract__r.Id, XC_CMCostCenter__c, XC_ParentCommercialItem__c,
        (select id from Work_Orders__r where XC_WorkTypeLabel__c = 'Installation')
        from NE__OrderItem__c where //XC_Product2Id__c != null and (XC_Product2Id__r.XC_SapType__c = 'Service' or XC_Product2Id__r.XC_SapType__c = 'Material') and //RecordType.DeveloperName = 'Technical_Item' and
                Id in :configItemIds ];


        Map<Id, Map<id,NE__OrderItem__c>> retMap = new Map<Id, Map<id,NE__OrderItem__c>>();
        for(XC_Provisioning_Step__c pt : steps){
            if (retMap.get(pt.id) == null) {
                retMap.put(pt.id, new Map<Id, NE__OrderItem__c>());
            }
            for(NE__OrderItem__c oi : oiByIdList) {
                if(oi.XC_ParentCommercialItem__c == pt.XC_Configuration_Item__c){
                    //woByStep.put(pt.Id,oi.Work_Orders__r[0]);
                    retMap.get(pt.id).put(oi.Id,oi);
                }
            }
        }

        return retMap;
    }


    /*private static List<WorkOrder> generateWO(Map<Id, XC_Provisioning_Step__c> stepMap, Id workTypeOrganizer){
        List<WorkOrder> retList = new List<WorkOrder>();
        for(XC_Provisioning_Step__c pt : stepMap.values()){
            if(woByStep.get(pt.Id) != null){
                retList.add(woByStep.get(pt.Id));
                continue;
            }

            WorkOrder wo = new WorkOrder();
            wo.Status = 'New';
            wo.StartDate = Date.today();
            wo.XC_DueDate__c = null;//Date.today();
            wo.XC_OriginalDueDate__c = Date.today();
            wo.XC_PreferredPartner__c = pt.XC_Configuration_Item__r.XC_Provider__c;
             String recTypeNameStr = 'XC_'+pt.XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c+'_'+pt.XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c+'_WorkOrder';
            System.debug('recTypeNameStr:'+recTypeNameStr);
            wo.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(recTypeNameStr).getRecordTypeId();
            wo.XC_WorkTypeCategory__c = 'Organizer';
            wo.XC_WorkTypeLabel__c = 'Organizer';
            wo.WorkTypeId = workTypeOrganizer;
            wo.AccountId = pt.XC_Configuration_Item__r.NE__OrderId__r.NE__AccountId__c;
            wo.XC_Opportunity__c = pt.XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__c;
            wo.XC_LegalEntity__c = pt.XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c;
            wo.XC_Segment__c = pt.XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c;//pt.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Segment__c;

            wo.XC_Configuration_Item__c = pt.XC_Configuration_Item__c;
            wo.XC_Configuration_Item__r = pt.XC_Configuration_Item__r;
            wo.XC_Configuration__c = pt.XC_Configuration_Item__r.NE__OrderId__c;
            woByStep.put(pt.Id,wo);
            retList.add(wo);
        }

        return retList;
    }*/

    private static List<WorkOrderLineItem> generateWOLI(WrapperCreateWOLI genWOLIinput){
        Map<String,String> stepTypeById = genWOLIinput.stepTypeById;
        Map<Id, XC_Provisioning_Step__c> stepMap = genWOLIinput.stepMap;
        Map<Id, Map<id,NE__OrderItem__c>> orderItemsByStep = genWOLIinput.orderItemsByStep;
        Map<Id,Integer> numExistingWoli =  genWOLIinput.numExistingWoli;


        List<WorkOrderLineItem> retList = new List<WorkOrderLineItem>();
        Set<String> stepKeys = woByStep.keySet();
        for(String stepId : woByStep.keySet()){
            WorkOrder wo = woByStep.get(stepId);
            XC_Provisioning_Step__c pt = stepMap.get(stepId);
            Boolean toExit = wo == null || pt == null;
            if(toExit){
                continue;
            }
            WorkOrderLineItem woli = new WorkOrderLineItem();
            Contract contr;
			woli.XC_ProjectManager__c=wo.CreatedById;
            String recTypeNameStr = null;
            Boolean isPE = stepTypeById.get(stepId) == 'Partner Engagement';
            Boolean isMR = stepTypeById.get(stepId)  == 'Material Supply' || stepTypeById.get(stepId)  == 'Delivery';
            Boolean isTA = stepTypeById.get(stepId)  == 'Technical Asset'; //DL 15/7
            if(isPE) {

                recTypeNameStr = 'XC_' + wo.XC_Segment__c + '_' + wo.XC_LegalEntity__c + '_PE_WOLI';
                woli.RecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get(recTypeNameStr).getRecordTypeId();
                //woli.RecordType.DeveloperName = 'XC_' + wo.XC_Segment__c + '_' + wo.XC_LegalEntity__c + '_PE_WOLI';
                woli.XC_WOLIType__c = stepTypeById.get(stepId);
                woli.XC_LCLDocumentRequired__c = false;

                woli.XC_PurchaseOrderPosition__c = numExistingWoli.get(wo.Id) != null ? (numExistingWoli.get(wo.Id)+1)*10 : 10;

                /*try{
                    contr = orderItemsByStep.get(pt.Id).values()[0].XC_PartnerContract__r;
                    woli.XC_ContractId__c = contr.Id;
                }catch(Exception e){
                    woli.XC_ContractId__c = null;
                }*/
                woli.XC_ContractId__c = contrMap.containsKey(stepId) ? contrMap.get(stepId).Id : null;

                //woli.XC_AccountAssignmentCategory__c = contr.FieldGiusto; //TODO Selezionabile dal'utente su SFA se sul contratto era presente la U (selezionare K o P), altrimenti preso come indicato sul contratto.

            }/*else if(isMR){
                recTypeNameStr = 'XC_' + wo.XC_Segment__c + '_' + wo.XC_LegalEntity__c + '_MR_WOLI';
                woli.RecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get(recTypeNameStr).getRecordTypeId();
                //woli.RecordType.DeveloperName = 'XC_' + wo.XC_Segment__c + '_' + wo.XC_LegalEntity__c + '_MR_WOLI';
                //Delivery field - Questo campo va valorizzato solo se il project task di partenza è di tipo delivery
                woli.XC_IsaDelivery__c = stepTypeById.get(stepId) == 'Delivery';
                woli.XC_WOLIType__c = stepTypeById.get(stepId);
                woli.XC_ShipToCity__c = pt.XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_City__c;
                woli.XC_ShipToCountry__c = pt.XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_AddressCountry__c;
                woli.XC_ShipToStateProvince__c = pt.XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_Region__c;
                woli.XC_ShipToStreet__c = pt.XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_Address__c+', '+pt.XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_StreetNumber__c;
                woli.XC_ShipToZipPostalCode__c = pt.XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_PostalCode__c;
            }*/

            else if(isTA){
                recTypeNameStr = 'XC_' + wo.XC_Segment__c + '_' + wo.XC_LegalEntity__c + '_TA_WOLI';
                woli.RecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get(recTypeNameStr).getRecordTypeId();
                woli.XC_WOLIType__c = stepTypeById.get(stepId);
                woli.XC_LCLDocumentRequired__c = false;

            } //DL 15/7


            woli.Status = 'New';
            woli.WorkOrderId = wo.Id;
            woli.WorkOrder = wo;
            woli.StartDate = Date.today();
            woli.EndDate = wo.XC_DueDate__c;

            woli.XC_AccountId__c = wo.XC_AssignedPartner__c;//pt.XC_Configuration_Item__r.XC_Provider__c;
            woli.XC_ProvisioningStep__c = pt.Id;
            woli.XC_ProvisioningStep__r = pt;

            String wbs;
            try{
                String wbe = orderItemsByStep.get(pt.Id).values()[0].XC_Wbe__c;
                wbs = wbe != null && wbe.length()>16 ? wbe.substring(0,16) : wbe;
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

    private static Map<Id, Contract> getActiveContractsByStepsMap(List<XC_Provisioning_Step__c> taskIds){
        Boolean toExit = taskIds==null || taskIds.isEmpty() || !Schema.sObjectType.Contract.isAccessible();
        if(toExit){
            return new Map<Id, Contract>();
        }
        List<String> confIds = new List<String>();
        for(XC_Provisioning_Step__c t : taskIds){
            confIds.add(t.XC_Configuration_Item__c);
        }
        Map<Id, Contract> contMap = new Map<Id, Contract>(
        [select Id,AccountId, XC_CIG__c,XC_CUP__c,XC_Configurations__c from Contract where XC_Configurations__c in :confIds]
        );
        Map<Id, Contract> retMap = new Map<Id, Contract>();
        for(XC_Provisioning_Step__c pt : taskIds){
            for(Contract c : contMap.values()){
                if(pt.XC_Configuration_Item__r.NE__OrderId__c == c.XC_Configurations__c){
                    retMap.put(pt.Id,c);
                }
            }
        }
        return retMap;
    }

}