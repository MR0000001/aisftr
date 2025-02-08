/**
* @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 17/10/2019
* @description giic_TR_PurchaseOrder_ManageUpdate  to close Delivery WO
*/
public without sharing class giic_TR_PurchaseOrder_ManageUpdate {
    
     private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('giic_TR_PurchaseOrder_ManageUpdate');   
    
    /**
* @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
* @date 05/07/2019
* @description To create case on update of 'New Inventory Date' field on Purchase Order.
* @param listNew List of Purchase Order Id
* @param mapNew
* @param mapOld
*/   
    public static void createCaseFromPO(List<gii__PurchaseOrder__c > listNew, Map<Id, gii__PurchaseOrder__c > mapNew ,Map<Id, gii__PurchaseOrder__c > mapOld){  
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In createCaseFromPO----->>' );
        List<String> fieldToCheck = new List<String> {'giic_NewDeliveryDate__c'};
        List<gii__PurchaseOrder__c > listPOChanged = XC_UTIL_Sobject.getListChanged(fieldTocheck, mapOld, mapNew);
        List<Id> poIdList = XC_UTIL_Sobject.getIds(listPOChanged);
        if(listPOChanged.size()>0){
            createCaseFromPO(poIdList); 
            createCustomerInteraction(listPOChanged);
        }
    }   
    /**
* @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
* @date 05/07/2019
* @description To create case on update of 'New Inventory Date' field on Purchase Order.
* @param toIdList List of Purchase Order Id
*/   
    public static void createCaseFromPO(List<Id> poIdList){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In createCaseFromPO----->>' );
        
        List<gii__PurchaseOrder__c> poList = new List<gii__PurchaseOrder__c>([SELECT Id,giic_NewDeliveryDate__c,gii__SalesOrder__c,gii__SalesOrder__r.giic_WorkOrder__r.WorkOrderNumber,gii__SalesOrder__r.giic_FSLWorkOrder__c,gii__ShipToCountry__c, giic_legalEntity__c FROM gii__PurchaseOrder__c WHERE ID IN:poIdList ]);
        Set<string> woNumbers=new Set<string>();
        Map<Id,Case> mapWoIdCase=new Map<Id,Case>();
        List<Case> caseToInsert = new List<Case>();
        map<Id,String> workOrderRejectReason = new  map<Id,String>();
        try{
            for(gii__PurchaseOrder__c po : poList){
                woNumbers.add(po.gii__SalesOrder__r.giic_WorkOrder__r.WorkOrderNumber);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE,'woNumbers----->>' +woNumbers);
            
            List<ServiceAppointment> sapList=Giic_TransferOrderUtility_D.getServiceAppoinmentList(woNumbers);                
            mapWoIdCase = createCaseFromPOHelper(sapList,poList); 
            XC_UTIL_Debug.debug(DEBUGACTIVE,'mapWoIdCase----->>' +mapWoIdCase);
            if(mapWoIdCase.size()>0 ) {
                AssignmentRule AR = new AssignmentRule();
        		AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
       	 		Database.DMLOptions dmlOpts = new Database.DMLOptions();
        		dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
                List<Id> listWoIds = new List<Id>();
                for(Case c : mapWoIdCase.values()){
                    c.setOptions(dmlOpts);
                    caseToInsert.add(c);
                    listWoIds.add(c.XC_WorkOrder__c);
                }
                system.debug('@@@ INSERISCO CASE' );
                XC_UTIL_Glovia.insertAndLogError(caseToInsert);
                Map<Id,WorkOrder> workOrderDelayMap = new  Map<Id,WorkOrder>();     
                workOrderDelayMap = giic_TR_PurchaseOrder_ManageUpdate.getWoMap(listWoIds); 
                List<XC_Customer_Interaction__c> customInterList = giic_TR_PurchaseOrder_ManageUpdate.populateCustomInterListFromPO(workOrderDelayMap.values(),  'Orders_Pickup_Delay_Installation',workOrderRejectReason);
                XC_UTIL_Debug.debug(DEBUGACTIVE,'end createCustomerInteraction');
                XC_UTIL_Glovia.insertAndLogError(customInterList);
            }         
        }catch(Exception ex){
            String message=ex.getMessage()+'Line>>>>'+ex.getLineNumber(); 
        }
        
    }
    
    /**
* @author FirstName :Roberta Porrega - roberta.porrega@nttdata.com
* @date 05/07/2019
* @description To create case on update of 'New Inventory Date' field on Purchase Order.
* @param sapList List<ServiceAppointment> 
* @param poList List<gii__TransferOrderLine__c>
*@return Map<Id,Case>
*/   
    public static Map<Id,Case> createCaseFromPOHelper(List<ServiceAppointment> sapList,List<gii__PurchaseOrder__c> poList){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In createCaseFromPOHelper----->>');
        Map<string,List<ServiceAppointment>> mapWoIdSrvcApmnt=new Map<string,List<ServiceAppointment>>();
        Map<Id,Case> mapWoIdCase=new Map<Id,Case>();
        
        if(sapList.size()>0){
            map<string,Id> mapWorkOrderNumberWithId=new map<string,Id>();
            for(ServiceAppointment sp: sapList){
                if(!mapWoIdSrvcApmnt.containsKey(sp.ParentRecord.Name)){
                    mapWoIdSrvcApmnt.put(sp.ParentRecord.Name,new List<ServiceAppointment>());
                }  
                mapWoIdSrvcApmnt.get(sp.ParentRecord.Name).add(sp);   
                mapWorkOrderNumberWithId.put(sp.ParentRecord.Name,sp.ParentRecordId);
                
            }
            
            for(gii__PurchaseOrder__c po : poList){
                if(po.gii__SalesOrder__c!= null && po.gii__SalesOrder__r.giic_WorkOrder__r.WorkOrderNumber != null && po.giic_LegalEntity__c!=null){
                    Giic_GloviaCapabilitiesByLE__c cs = Giic_GloviaCapabilitiesByLE__c.getValues(po.giic_LegalEntity__c);
                    if(cs.Giic_CreateCase__c){
                        List<ServiceAppointment> serviceAppList= mapWoIdSrvcApmnt.get(po.gii__SalesOrder__r.giic_WorkOrder__r.WorkOrderNumber);
                        mapWoIdCase.putAll(createCaseFromPOHelperFillMap(mapWorkOrderNumberWithId,po,serviceAppList));
                    }
                    
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'End createCaseFromPOHelper con----->>' +mapWoIdCase);
        return mapWoIdCase;
    }
    /**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date 05/07/2019
* @description To create case on update of 'New Inventory Date' field on Transfer Order.
* @param mapWorkOrderNumberWithId map<string,Id>  
* @param po gii__TransferOrderLine__c 
* @param serviceAppList List<ServiceAppointment> 
*@return Map<Id,Case>
*/  
    public static Map<Id,Case> createCaseFromPOHelperFillMap(map<string,Id> mapWorkOrderNumberWithId,gii__PurchaseOrder__c po, List<ServiceAppointment> serviceAppList){
         XC_UTIL_Debug.debug(DEBUGACTIVE,'In createCaseFromPOHelperFillMap----->>');
        String origin;
        if(po.giic_LegalEntity__c == 'EnelXItalia'){
            origin = 'CAN009';
        }else{
            origin = Label.giic_CaseOrigin;
        }
          XC_UTIL_Debug.debug(DEBUGACTIVE,'origin = '+origin);
        map<Id,WorkOrder> mapWorkOrder=new map<Id,WorkOrder>([select id,accountid,contactid,WorkOrderNumber from workorder where id in:mapWorkOrderNumberWithId.values() and (XC_WorkTypeCategory__c =:System.Label.XC_CL_WorkType_DeliveryInstallation OR XC_WorkTypeCategory__c =:System.Label.XC_CL_WorkType_Installation) ]);
        Map<Id,Case> mapWoIdCase=new Map<Id,Case>();
        if(serviceAppList.size()>0){
            for(ServiceAppointment sp: serviceAppList){
                Datetime  schStartDate=sp.SchedStartTime.addDays(-1);
                if(po.giic_NewDeliveryDate__c > schStartDate && mapWorkOrder.containsKey(sp.ParentRecordId)){           
                    Case cc = new Case(Status=System.Label.giic_CaseStatus,  Reason=System.Label.giic_CaseReason, SubCause__c=System.Label.giic_CaseSubCause, Origin = origin,XC_Subtype__c=System.Label.giic_CaseSubtype,Priority=System.Label.giic_CasePriority,XC_WorkOrder__c=sp.ParentRecordId, XC_LegalEntity__c = po.giic_LegalEntity__c, Country__c = po.gii__ShipToCountry__c, AccountId=mapWorkOrder.get(sp.ParentRecordId).AccountId, ContactId=mapWorkOrder.get(sp.ParentRecordId).ContactId);
                    
                    if(!mapWoIdCase.containsKey(sp.ParentRecordId)){ mapWoIdCase.put(sp.ParentRecordId,cc); }
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'end createCaseFromPOHelperFillMap con '+mapWoIdCase);
        return mapWoIdCase;
    }
    
    
  
     
      /**
     * @author Parveen Kaur Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record,mapNewS -map Id -> new value of record,lstIds,poIdtoIntegrate,poIdtocancel
    */  
    public static void processAfterUpdate(Map<Id, gii__PurchaseOrder__c> mapOldS, Map<Id, gii__PurchaseOrder__c> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In processAfterUpdate----->>');
        List<Id> lstIds=new List<Id>();
        for(gii__PurchaseOrder__c objPO : mapNewS.values()){
            if((objPO.giic_status__c== System.Label.giic_POStatusCancelled && 
               objPO.giic_IntegrationStatus__c==System.Label.giic_IntegrationStatusSuccess && objPO.giic_IntegrationOperation__c==System.Label.giic_CancellationRequest && objPO.giic_MultiTargetSystem__c.contains(System.Label.giic_TargetSystemGlovia)) 
               || (objPO.giic_status__c== System.Label.giic_POStatusCancelled && 
              		 objPO.giic_POCode__c == null) ){ lstIds.add(objPO.Id); }
         }
        if(lstIds.size() > 0){ giic_PurchaseOrderUtility.cancelPOL(lstIds); }
         XC_UTIL_Debug.debug(DEBUGACTIVE,'end processAfterUpdate');
     }
    
    
    
    public static void checkIfNeedCustomerInteraction(List<gii__PurchaseOrder__c> listNew, Map<Id, gii__PurchaseOrder__c > mapOld){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In checkIfNeedCustomerInteraction----->>');
        List<Id> woReviewedIds = new List<Id>();
        List<Id> woClosedIds = new List<Id>();
        List<Id> woRejectIds = new List<Id>();
        map<Id,String> workOrderRejectReason = new  map<Id,String>();
        for(gii__PurchaseOrder__c po : listNew ){
            if(po.gii__Dropship__c){
                if(mapOld.get(po.Id).giic_Status__c!='Reviewed' && po.giic_Status__c == 'Reviewed' ){
                    woReviewedIds.add(po.giic_WorkOrder__c);
                }else if(mapOld.get(po.Id).giic_Status__c!='Closed' && po.giic_Status__c == 'Closed' ){ 
                    woClosedIds.add(po.giic_WorkOrder__c); 
                }else if(mapOld.get(po.Id).giic_Status__c=='Sent to Supplier' && po.giic_Status__c == 'Open' && po.giic_SupplierRejectReason__c != null){ 
                    woRejectIds.add(po.giic_WorkOrder__c); 
                    workOrderRejectReason.put(po.giic_WorkOrder__c,po.giic_SupplierRejectReason__c);
                }
            }
        }
        map<Id,WorkOrder> workOrderPickupMap = new  map<Id,WorkOrder>();
        map<Id,WorkOrder> workOrderClosedMap  = new  map<Id,WorkOrder>();
        map<Id,WorkOrder> workOrderRejectMap  = new  map<Id,WorkOrder>();
        if(!woReviewedIds.isEmpty()){
        	workOrderPickupMap = getWoMap(woReviewedIds);
        }
        if(!woClosedIds.isEmpty()){ 
            workOrderClosedMap = getWoMap(woClosedIds); 
        }
         if(!woRejectIds.isEmpty()){ 
            workOrderRejectMap = getWoMap(woRejectIds); 
        }
        List<XC_Customer_Interaction__c> customInterList = populateCustomInterListFromPO(workOrderPickupMap.values(),  'Orders_Pickup',workOrderRejectReason);
        if(!workOrderClosedMap.isEmpty()){
             customInterList.addAll(populateCustomInterListFromPO(workOrderClosedMap.values(),  'Orders_Pickup_Closed', workOrderRejectReason));
        }
        if(!workOrderRejectMap.isEmpty()){
             customInterList.addAll(populateCustomInterListFromPO(workOrderRejectMap.values(),  'Orders_Pickup_NoStock', workOrderRejectReason));
        }
         XC_UTIL_Debug.debug(DEBUGACTIVE,'end checkIfNeedCustomerInteraction');
        XC_UTIL_Glovia.insertAndLogError(customInterList);
        
    }

    public static void customInteractionDeliveryTracking(List<gii__PurchaseOrder__c> listNew,Map<Id,gii__PurchaseOrder__c> mapOld, Map<Id,gii__PurchaseOrder__c> mapNew){
        List<String> fieldList = new List<String>{'giic_DeliveryTracking__c'};
        List<gii__PurchaseOrder__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        System.debug('@@@@@ List Changed Delivery Tracking');
        System.debug(listChanged);
        if(listChanged.isEmpty()){
            return;
        }
        List<Id> woList = new List<Id>();
        map<Id,String> mapPOId = new  map<Id,String>();
        Map<Id,gii__PurchaseOrder__c> mapWoB2C  = new Map<Id,gii__PurchaseOrder__c>([SELECT Id, giic_WorkOrder__c, giic_WorkOrder__r.XC_Segment__c FROM gii__PurchaseOrder__c WHERE Id IN :listNew AND giic_WorkOrder__c!=null AND giic_WorkOrder__r.XC_Segment__c='B2C']);
        for(gii__PurchaseOrder__c po : mapWoB2C.values()){
                woList.add(po.giic_WorkOrder__c);
                mapPOId.put(po.giic_WorkOrder__c,po.Id);
            }
        map<Id,WorkOrder> workOrderMap = new  map<Id,WorkOrder>();
        map<Id,String> workOrderRejectReason = new  map<Id,String>();
        if(!woList.isEmpty()){
        	workOrderMap = getWoMap(woList);
        }
        List<XC_Customer_Interaction__c> customInterList = populateCustomInterListFromPO(workOrderMap.values(), 'Delivery Tracking Number',workOrderRejectReason);
        List<XC_Customer_Interaction__c> customInterToInsert = new List<XC_Customer_Interaction__c>();
        for (XC_Customer_Interaction__c ci : customInterList){
            ci.XC_AdditionalInfo2__c=(!String.isBlank(mapPOId.get(ci.XC_WorkOrderId__c))) ? mapPOId.get(ci.XC_WorkOrderId__c) : null;
            customInterToInsert.add(ci);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ New CI Delivery Tracking Number to create = ' + customInterToInsert);
         List<XC_UTIL_SObject.WrapperResult> insCIResults = XC_UTIL_DML.insertRecords(customInterToInsert);
 		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ CI Delivery Tracking Number results = ' + insCIResults);
    }
         
         
     public static List<XC_Customer_Interaction__c> populateCustomInterListFromPO(List<WorkOrder> workOrderList, String communicationType, Map<Id,String> workOrderRejectReason) {
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In populateCustomInterListFromPO con ----->>'+workOrderList);
        System.debug('In populateCustomInterListFromPO con ----->>'+workOrderList);
        List<XC_Customer_Interaction__c> customInterList = new List<XC_Customer_Interaction__c>();
        for(WorkOrder workOr : workOrderList){
            XC_Customer_Interaction__c cInteraction = new XC_Customer_Interaction__c();
            cInteraction.XC_WorkOrderId__c = workOr.Id;
            cInteraction.XC_SkipCommunication__c = false;
            cInteraction.XC_Source__c = Label.XC_CL_CustomerInter_SourceCRM;
            cInteraction.XC_Channel__c = Label.XC_CL_CustomerInter_ChannelEmail;
            cInteraction.XC_Communication_Type__c = communicationType;
            cInteraction.XC_Segment__c = workOr.XC_Segment__c;
            cInteraction.XC_AccountId__c = WorkOr.AccountId;
            cInteraction.XC_LegalEntity__c = WorkOr.XC_LegalEntity__c;
            cInteraction.XC_AssetId__c = WorkOr.AssetId;
            cInteraction.XC_AdditionalInfo1__c = workOrderRejectReason.containskey(workOr.Id) ? workOrderRejectReason.get(workOr.Id) : '' ;
            if(!WorkOr.ServiceAppointments.isEmpty()){
                cInteraction.XC_ServiceAppointmentId__c = WorkOr.ServiceAppointments[0].Id;
            }
            if(WorkOr.XC_Configuration_Item__c != null){
            	cInteraction.XC_ConfigurationItem__c = WorkOr.XC_Configuration_Item__c; // Marketing Cloud required for Orders_Pickup
            }
            
             cInteraction.XC_OrderId__c = workOr.XC_Configuration__c;
            
    
            if(!String.isBlank(workOr.XC_Opportunity__c)) {         // Marketing Cloud opportunityID required issue
                cInteraction.XC_OpportunityId__c = workOr.XC_Opportunity__c;   
            } else if(!String.isBlank(workOr.XC_Configuration__r.NE__OptyId__c)) {
                cInteraction.XC_OpportunityId__c = workOr.XC_Configuration__r.NE__OptyId__c;
            }
    
            if(!String.isBlank(workOr.Contact.Email)) {
                XC_UTIL_Debug.debug(DEBUGACTIVE,'email from contact');
                cInteraction.XC_ContactId__c = workOr.ContactId;
                cInteraction.XC_Recipient__c = workOr.Contact.Name;
                cInteraction.XC_Email__c = workOr.Contact.Email;
                cInteraction.XC_Preferredlanguageofcontact__c = workOr.Contact.XC_Preferredlanguageofcontact__c;
                customInterList.add(cInteraction);
            } else if (!String.isBlank(workOr.XC_Opportunity__r.XC_Contact__r.Email)) {
                XC_UTIL_Debug.debug(DEBUGACTIVE,'email from opportunity->contact');
                cInteraction.XC_ContactId__c = workOr.XC_Opportunity__r.XC_Contact__c;
                cInteraction.XC_Recipient__c = workOr.XC_Opportunity__r.XC_Contact__r.Name;
                cInteraction.XC_Email__c = workOr.XC_Opportunity__r.XC_Contact__r.Email;
                cInteraction.XC_Preferredlanguageofcontact__c = workOr.XC_Opportunity__r.XC_Contact__r.XC_Preferredlanguageofcontact__c;
                customInterList.add(cInteraction);
            } else if (!String.isBlank(workOr.XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Email)) {
                cInteraction.XC_ContactId__c = workOr.XC_Configuration__r.NE__OptyId__r.XC_Contact__c;
                cInteraction.XC_Recipient__c = workOr.XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Name;
                cInteraction.XC_Email__c = workOr.XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Email;
                cInteraction.XC_Preferredlanguageofcontact__c = workOr.XC_Configuration__r.NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c;
                customInterList.add(cInteraction);
            }
        }
         XC_UTIL_Debug.debug(DEBUGACTIVE,'End populateCustomInterListFromPO con ----->>'+customInterList);
         return customInterList;
    }
    
    public static void createCustomerInteraction(List<gii__PurchaseOrder__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In createCustomerInteraction----->>');
        Map<Id,String> workOrderRejectReason = new  Map<Id,String>();
        List<Id> woDelayIds = new List<Id>();
        for(gii__PurchaseOrder__c po : listNew ){
            if(po.gii__Dropship__c){
                    woDelayIds.add(po.giic_WorkOrder__c);             
            }
        }
        map<Id,WorkOrder> workOrderDelayMap = new  map<Id,WorkOrder>();
        if(!woDelayIds.isEmpty()){
        XC_UTIL_Debug.debug(DEBUGACTIVE,' get WO delay');
        	workOrderDelayMap = getWoMap(woDelayIds);
        }
        List<XC_Customer_Interaction__c> customInterList = populateCustomInterListFromPO(workOrderDelayMap.values(),  'Orders_Pickup_Delay', workOrderRejectReason);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'end createCustomerInteraction');
        XC_UTIL_Glovia.insertAndLogError(customInterList);
    }
         
    
    
     
    public static Map<Id, WorkOrder> getWoMap(List<Id> allChangedWo){
         XC_UTIL_Debug.debug(DEBUGACTIVE,'In getWoMap----->>');
        return new Map<Id, WorkOrder>([SELECT Id, XC_CongaDynamicAPI__c, XC_Check_Final_Status__c, XC_StatusReason__c, ContactId, Contact.Name, AccountId, AssetId, XC_WorkTypeCategory__c, Contact.Email, XC_LegalEntity__c, XC_Opportunity__r.XC_Contact__c, XC_Opportunity__r.AccountId,
                                                            XC_Lead__c, XC_Opportunity__c, XC_Opportunity__r.XC_Contact__r.Name, XC_Opportunity__r.XC_Contact__r.Email, 
                                                            XC_Lead__r.XC_MainLegalEntity__c, XC_Lead__r.Email, XC_Lead__r.Name, WorkType.Name, Contact.XC_Preferredlanguageofcontact__c, XC_Opportunity__r.XC_Contact__r.XC_Preferredlanguageofcontact__c,
                                                            XC_Configuration__c, XC_Configuration__r.NE__OptyId__c, XC_Configuration_Item__c,
                                                            XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Email, XC_Configuration__r.NE__OptyId__r.XC_Contact__c,
                                                            XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Name, XC_Configuration__r.NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c,
                                                            Contact.Phone, Contact.XC_PhonePrefix__c, Contact.XC_ContactPhone__c,    XC_Segment__c,   
                                                            Contact.MobilePhone, Contact.XC_MobilePrefix__c, Contact.XC_ContactMobile__c, XC_Opportunity__r.XC_LegalEntity__c,
                                                                (SELECT ID, XC_StatusReason__c, Status, XC_AssignedResource__r.FSL__Picture_Link__c FROM ServiceAppointments order by CreatedDate desc)
                                                            FROM WorkOrder                                                                                                                                  
                                                            WHERE Id IN: allChangedWo]);
    }

/**
     * @author  
     * @description Method to be executed on before update
     * @param mapOld - map Id -> old value of record,mapNewS -map Id -> new value of record,lstIds,poIdtoIntegrate,poIdtocancel
    */  
    public static void checkContractEndDate(List<gii__PurchaseOrder__c> listNew,Map<Id,gii__PurchaseOrder__c> mapOld, Map<Id,gii__PurchaseOrder__c> mapNew){
        List<String> fieldList = new List<String>{'giic_Status__c'}; 
        List<gii__PurchaseOrder__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In checkContractEndDate----->>'); 
        List<String> contractToCheck = XC_UTIL_SObject.getListFieldValues(listChanged,'giic_Contract__c');
        Map<Id,Contract> contractList = new Map<Id,Contract> ([SELECT Id, EndDate FROM Contract WHERE Id IN:contractToCheck]);
        for(gii__PurchaseOrder__c objPO : listChanged ){
               if(contractList.containsKey(objPO.giic_Contract__c) && contractList.get(objPO.giic_Contract__c).EndDate < Date.today() && objPO.giic_Status__c == 'Approved' ){ 
                mapNew.get(objPO.id).addError('You cannot approve the Purchase Order since the Contract End Date is less than today'); 
            }
        }     
        XC_UTIL_Debug.debug(DEBUGACTIVE,'end processAfterUpdate');
    }
    
}