/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Massimiliano Avallone - massimiliano.avallone@nttdata.com
* @date Creation 06/08/2019
* @date Mod 25/01/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_WorkOrder_U_ManageSATO – Trigger Work Order for SATO
*/

public without sharing class XC_TR_WorkOrder_U_ManageSATO {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_ManageSATO');
    
    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 25/01/2021
    * @description XC_Queueable_InsertRelatedSatoWorkOrder – Queueable to insert SATO WorkOrders 
    */
    public class XC_Queueable_InsertRelatedSatoWorkOrder implements Queueable {

        List<WorkOrder> woToInsert = new List<WorkOrder>();

        /**
        * @description Costructor for queueable with params
        * @param woToInsert - List <WorkOrder>
        **/
        public XC_Queueable_InsertRelatedSatoWorkOrder(List<WorkOrder> woToInsert){
            this.woToInsert = woToInsert;
        }
        
        /**
        * @description Execute method for queueable
        * @param context 
        **/
        public void execute(QueueableContext context) {
            List<WorkType> listWorkType = new List<WorkType>([
                SELECT Id
                FROM WorkType
                WHERE Name = 'Repair - SATO'
            ]);
            if(listWorkType.isEmpty()) {
                return;
            }
            for(WorkOrder wo : this.woToInsert) {
                wo.WorkTypeId = listWorkType[0].Id;
            }
            List<XC_UTIL_Sobject.WrapperResult> wrResult = XC_UTIL_Sobject.insertListRecords(this.woToInsert);
            if(XC_UTIL_Sobject.checkDMLResults(wrResult)) {
                List<String> listWoIds = new List<String>();
                for(XC_UTIL_Sobject.WrapperResult wr : wrResult) {
                    listWoIds.add(wr.recordId);
                }
                List<WorkOrder> listWoInserted = new List<WorkOrder>([
                    SELECT Id, XC_LegalEntity__c, XC_Segment__c, AccountId, ContactId
                    FROM WorkOrder
                    WHERE Id IN :listWoIds
                ]);
                List<Case> listCaseToInsert = new List<Case>();
                String nameCaseTypeSetting = 'XC_CaseToScheduleAppointment';
                XC_CM_Case_Type_Setting__mdt cts = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{nameCaseTypeSetting}).get(nameCaseTypeSetting);
                for(WorkOrder wo : listWoInserted) {
                    Case newCase = XC_UTIL_Case.initCaseFromCaseSettings(cts);
                    newCase.XC_LegalEntity__c = wo.XC_LegalEntity__c;
                    newCase.XC_Segment__c = wo.XC_Segment__c;
                    newCase.AccountId = wo.AccountId;
                    newCase.ContactId = wo.ContactId;
                    newCase.XC_WorkOrder__c = wo.Id;
                    listCaseToInsert.add(newCase); 
                }
                XC_UTIL_Sobject.insertListRecords(listCaseToInsert);
            }
        }

    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Massimiliano Avallone - massimiliano.avallone@nttdata.com
    * @date Creation 06/08/2019
    * @date Mod 25/01/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Method to create Work Order SATO
    * @param listNew - List<WorkOrder>
    * @param mapOld - Map<Id, WorkOrder>
    * @param mapNew - Map<Id, WorkOrder>
    */
    public static void createChildWorkOrderForSato(List<WorkOrder> listNew, Map<Id, WorkOrder> mapOld, Map<Id, WorkOrder> mapNew) {
        List<String> listFields = new List<String>{'XC_StatusReason__c'};
        List<WorkOrder> listWorkOrder =  XC_UTIL_Sobject.getListChanged(listFields, mapOld, mapNew);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In trigger for SATO: ' + listWorkOrder);
        List<WorkOrder> listWorkOrderToManage = new List<WorkOrder>();
        for(WorkOrder wo : listWorkOrder) {
            if(wo.XC_StatusReason__c == Label.XC_CL_WorkOrder_SATObreakdown && (wo.XC_LegalEntity__c == 'EndesaX' || wo.XC_LegalEntity__c == 'EnelXMobilitySpain') && wo.XC_Segment__c == 'B2C') {
                listWorkOrderToManage.add(wo);
            }
        }
        if(listWorkOrderToManage.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ No WorkOrder SATO to manage');
            return;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ WorkOrder SATO to manage: ' + listWorkOrderToManage);
        /*List<WorkOrder> listWorkOrderFiltered = new List<WorkOrder>([
            SELECT Id, Asset.NE__CatalogItem__r.XC_Brand__c, XC_WorkTypeLabel__c, Street, PostalCode, City, Country,
                    XC_Address__c, XC_Urgent_Repair__c, XC_Commitment__c, AccountId, ContactId, 
                    WorkTypeId, XC_SerialNumber__c, Duration, AssetId, XC_Comments__c, Subject, XC_Segment__c, XC_LegalEntity__c
            FROM WorkOrder
            WHERE Id IN: listWorkOrderToManage
        ]);

        List<String> listBrand = new List<String>();
        for(WorkOrder wo : listWorkOrderFiltered) {
            listBrand.add(wo.Asset.NE__CatalogItem__r.XC_Brand__c);
        }
        List<Account> listAccount = new List<Account>([
            SELECT Id, XC_Brand__c  
            FROM Account 
            WHERE XC_SATO__c = true AND XC_Brand__c IN: listBrand
            	AND RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId()
        ]);
        Map<String, String> mapBrandAccount = new Map<String, String>();
        for(Account acc : listAccount) {
            mapBrandAccount.put(acc.XC_Brand__c, acc.Id);
        }*/

        List<XC_CM_LegalEntity_Configuration__mdt> listCM = new List<XC_CM_LegalEntity_Configuration__mdt>([
            SELECT Id, XC_BODispatcherQueue__c, XC_LegalEntity__c
            FROM XC_CM_LegalEntity_Configuration__mdt 
            WHERE XC_LegalEntity__c =: XC_UTIL_Sobject.getListFieldValues(listWorkOrderToManage, 'XC_LegalEntity__c') AND XC_BODispatcherQueue__c != null
        ]);
        List<String> listNameQueue = listCM.isEmpty() ? new List<String>() : XC_UTIL_Sobject.getListFieldValues(listCM, 'XC_BODispatcherQueue__c');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listNameQueue: ' + listNameQueue);
        String query = 'SELECT Id, DeveloperName FROM Group ';
        if(listNameQueue.isEmpty()) {
            query += 'WHERE DeveloperName LIKE \'%DispatcherQueue%\'';
        } else {
            query += 'WHERE DeveloperName IN :listNameQueue';
        }
        List<Group> listGroups = Database.query(query);
        Map<String, String> mapLegalEntityGroup = new Map<String, String>();
        for(XC_CM_LegalEntity_Configuration__mdt cm : listCM) {
            for(Group gr : listGroups) {
                if(gr.DeveloperName == cm.XC_BODispatcherQueue__c) {
                    mapLegalEntityGroup.put(cm.XC_LegalEntity__c, gr.Id);
                    break;
                }
            }
        }
        if(mapLegalEntityGroup.keySet().isEmpty()) {
            for(String le : XC_UTIL_Sobject.getListFieldValues(listWorkOrderToManage, 'XC_LegalEntity__c')) {
                mapLegalEntityGroup.put(le, listGroups[0].Id);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapLegalEntityGroup: ' + mapLegalEntityGroup);

        List<WorkOrder> listWorkOrdertoUpdate = new List<WorkOrder>();
        List<WorkOrder> listWorkOrderSATO = new List<WorkOrder>();
        for(WorkOrder wo : listWorkOrderToManage)  {
            WorkOrder woSATO = createWorkOrderSATO(wo, mapLegalEntityGroup);
            listWorkOrderSATO.add(woSATO);      
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ WorkOrder SATO for batch: ' + listWorkOrderSATO);
        System.enqueueJob(new XC_Queueable_InsertRelatedSatoWorkOrder(listWorkOrderSATO));
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Massimiliano Avallone - massimiliano.avallone@nttdata.com
    * @date Creation 06/08/2019
    * @description Method to check if Status Parent Work Order has to be to change
    * @param listNew - List<WorkOrder>
    * @param mapOld - Map<Id, WorkOrder>
    * @param mapNew - Map<Id, WorkOrder>
    */
    /*public static void checkStatusChildWorkOrderForSato(List<WorkOrder> listNew, Map<Id, WorkOrder> mapOld, Map<Id, WorkOrder> mapNew) {
        List<String> listFields = new List<String>{'Status'};
        List<WorkOrder> listWorkOrder =  XC_UTIL_Sobject.getListChanged(listFields, mapOld, mapNew);
        List<WorkOrder> listWorkOrderToManage = new List<WorkOrder>();
        List<String> listAssignedPartner = new List<String>();
        for(WorkOrder wo : listWorkOrder) {
            if(wo.Status == Label.XC_CL_WorkOrder_Completed && wo.ParentWorkOrderId != null) {
                listWorkOrderToManage.add(wo);
                listAssignedPartner.add(wo.XC_AssignedPartner__c);
            }
        }
        if(listWorkOrderToManage.isEmpty()){
            return;
        }
        
        Map<String, Account> mapAccount = new Map<String, Account>([
            SELECT Id, XC_SATO__c  
            FROM Account 
            WHERE Id IN: listAssignedPartner
        ]);
        List<WorkOrder> listAssignPartnerTrue = new List<WorkOrder>();
        for(WorkOrder wo: listWorkOrderToManage) {
            if(mapAccount.containsKey(wo.XC_AssignedPartner__c) && mapAccount.get(wo.XC_AssignedPartner__c).XC_SATO__c) {
                WorkOrder parentWo = new WorkOrder();
                parentWo.Id = wo.ParentWorkOrderId;
                parentWo.Status = label.XC_CL_WorkOrder_Completed;
                listAssignPartnerTrue.add(parentWo);
            }
        }
        XC_UTIL_Sobject.updateListRecords(listAssignPartnerTrue);
    }*/

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Massimiliano Avallone - massimiliano.avallone@nttdata.com & Andrea Bravaccino - andrea.bravaccino@nttdata.com
    * @date Creation 08/08/2019
    * @date Mod 25/01/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Method to create Work Order SATO
    * @param woRoot - WorkOrder
    * @param mapBrandAccount - Map<String, String>
    * @param mapLegalEntityGroup - Map<String, String>
    * @return WorkOrder
    */
    private static WorkOrder createWorkOrderSATO(WorkOrder woRoot, Map<String, String> mapLegalEntityGroup) {
        WorkOrder wo = new WorkOrder();
        wo.XC_forSATO__c = true;
        //wo.XC_WorkTypeLabel__c = woRoot.XC_WorkTypeLabel__c;
        wo.XC_LegalEntity__c = woRoot.XC_LegalEntity__c;
        wo.XC_Segment__c = woRoot.XC_Segment__c;
        wo.Street = woRoot.Street;
        wo.PostalCode = woRoot.PostalCode;
        wo.City = woRoot.City;
        wo.Country = woRoot.Country;
        wo.XC_Address__c = woRoot.XC_Address__c;
        //wo.ParentWorkOrderId = woRoot.Id;
        wo.XC_Urgent_Repair__c = woRoot.XC_Urgent_Repair__c;
        wo.XC_Commitment__c = woRoot.XC_Commitment__c;
        wo.AccountId = woRoot.AccountId;
        wo.ContactId = woRoot.ContactId;
        //wo.WorkTypeId = woRoot.WorkTypeId;
        wo.XC_SerialNumber__c = woRoot.XC_SerialNumber__c;
        wo.Duration = woRoot.Duration;
        wo.AssetId = woRoot.assetId;
        wo.XC_ReadyToBeBooked__c = true;
        wo.Subject = woRoot.Subject;
        wo.Description = 'Related to Work Order ' + woRoot.WorkOrderNumber;
        wo.XC_CreatedAutomaticallyBySystem__c = true;
        /*if(mapBrandAccount.containsKey(woRoot.Asset.NE__CatalogItem__r.XC_Brand__c)) {
            wo.XC_AssignedPartner__c  = mapBrandAccount.get(woRoot.Asset.NE__CatalogItem__r.XC_Brand__c); 
        } else {
           wo.XC_AssignedPartner__c  = null;
        }*/
        wo.OwnerId = mapLegalEntityGroup.containsKey(woRoot.XC_LegalEntity__c) ? mapLegalEntityGroup.get(woRoot.XC_LegalEntity__c) : null;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ WorkOrder SATO updated: ' + wo);
        return wo;    
    }
    
}