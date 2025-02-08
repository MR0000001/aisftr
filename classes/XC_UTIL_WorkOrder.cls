/**
* @author Marco Rosa - marco.rosa@nttdata.com & Nicolò Leonardi - nleonardi@deloitte.it
* @date Creation 28/09/2018
* @date Modification dd/mm/yyyy
* @description XC_UTIL_WorkOrder – Util class for WorkOrder methods
*/

public without sharing class XC_UTIL_WorkOrder {  

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_WorkOrder'); 

    /**
     * @description wrapper class for SendToBackOffice
    **/
    public class SendToBackOfficeWrapper{
        public ServiceAppointment serAppToChange;
        public WorkOrder workOrderToChange;
        public String partnerIdCurrentResource;
        public Id queueId;
        public Map<String,Boolean> mapWorkType;
    }

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com & Nicolò Leonardi - nleonardi@deloitte.it
    * @date Creation 28/09/2018
    * @date Modification dd/mm/yyyy
    * @description OpportunityWorkOrderWrapper
    */
    public class OpportunityWorkOrderWrapper{
        public Lead lead;
        public Opportunity opportunity;
        public WorkOrder workOrder; 
    } 

    /** 
     * @author Simone Trenta - strenta@deloitte.it
     * @description wrapper class for workOrders
    **/
    public class WorkOrderWrapper{
        public String WorkOrderID; 
        public String WorkOrderNumber; //WorkOrderNumber
        public String WorkType; //WorkTypeId
        public String ServiceType; // Work Order Service Type 
        public String Status; //Status
        public String Priority; //Priority
        public String Owner; //OwnerId
        public String ParentWorkOrderNumber; //ParentWorkOrder.WorkOrderNumber
        public String ContactID; //ContactId
        //public String UniqueID; //AccountId.UniqueIdentifier__c
        public String AccountID; //AccountId
        public String OpportunityID; //XC_Opportunity__c
        public String CaseID; //CaseId
        public String OrderID; //XC_Configuration__c
        public String OrderItemID; //XC_Configuration_Item__c
        public String RefusingReason; //XC_Refusing_Reason__c
        public String MissingQuoteReason; //XC_MissingQuoteReason__c
        public String CannotCompleteReason; //XC_Reason_Cannot_Complete__c
        public Boolean ExecuteAssignment; //    XC_RunAssignmentsRules__c
        public String WorkOrderSubject; //Subject 
        public String WorkOrderDescription; //  Description
        public Date InstallationDate; //XC_InstallationDate__c
        public String DeliveryID; //XC_DeliveryId__c 
        public Date DeliveryDate; //XC_DeliveryDate__c
        public String DeliveryType; //  XC_DeliveryType__c
        public Date EffectiveDeliveryDate; //XC_EffectiveDeliveryDate__c
        public String DeliverySerialNumber; //XC_SerialNumber__c
        public Date EffectiveProductAvailabilityDate; //    XC_EffectiveProductAvailabilityDate__c
        public String ProductReservationResult; //XC_ProductReservationResult__c
        public String DeliveryTracking; //  XC_Delivery_Tracking_URL__c
        public String CourierPartner; //XC_Courier_Partner__c
        public String SiteInspectionType; //XC_TypeOfSite__c
        public Boolean SiteOk; //XC_SiteOK__c
        public String SiteGasAnalyzer; //XC_GasAnalyzer__c
        public String SiteElectricityMeasurement; //XC_ElectricityMeasurement__c    
        public String Street; //street
        public String PostalCode; //postalcode
        public String City; //city
        public String State;  //state
        public string Country; //country 
        public string AccountMainPhonePrefix;   //Account.XC_MainPhonePrefix__c
        public string AccountMainPhone;         //Account.XC_AccountMainPhone__c
        public string AccountPhonePrefix;       //Account.XC_AccountPhonePrefix__c
        public string AccountPhone;             //Account.XC_AccountPhone__c
        public string AccountLastName;          //Account.XC_LastName__c
        public string AccountFirstName;         //Account.XC_FirstName__c
        public string AccountEmail;             //Account.PrimaryEmail__c 

        public String LegalEntity;
        public String AssetID;

        public String LeadId;
        public String LeadName;
        public String LeadCondominiumName;
        public String LeadEmail;
        public String LeadMainPhonePrefix;
        public String LeadMainPhone;
        public String LeadPhonePrefix;
        public String LeadPhone;

        public String AssetName;
        public String AssetBrand;
        public String AssetModel;
        public String AssetCatalogCategory;
        
        public String Comments;

        public String CarrierName;

        public String StatusReason;

        public String ReturnComments;
        public Boolean AffectedEquipment;  
        public Boolean AffectedInstallation;
        public String UrgentRepair;

        public String AwareOfBenefits;
        public String WelcomePackReceived;

        public String ExternalPartner;

        public Decimal PartnerWorkCost;
        public Decimal PartnerSparePartsCost;
        public Date ActualEndDate;
        public Boolean PartnerExtraCostInvoice;

        public String Result;
        public String MaxWallboxPower;

        public list<XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper> WorkOrderLineItem;
        public list<XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper> ServiceAppointment;
        //public list<XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper> WorkOrderLineItem = new list<XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper>();
        //public list<XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper> ServiceAppointment = new list<XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper>();
        public list<WorkOrderChildWrapper> WorkOrderChild; 
        public list<Document> Document;
    }


    /**
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     * @description wrapper class for Document
    **/
    public class Document{
        public String DocumentType;
        public Integer Quantity;
    }


    /** 
     * @author Simone Trenta - strenta@deloitte.it
     * @description wrapper class for workOrders
    **/
    public class WorkOrderChildWrapper{
        public string WorkOrderChildID;
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Method to create a Work Order.
     * @param workTypeCategory name of the WorkType
     * @param country country of the WorkOrder
     * @param parentId object related to WorkOrder
     * @return the correct WorkOrder
    **/
    public static WorkOrder createWorkOrder(String workTypeCategory, String country, String parentId){
        WorkOrder wo = new WorkOrder(); 
        String objectName = XC_UTIL_Sobject.getObjectType(parentId);
        if(objectName == 'Account'){
            wo.AccountId = parentId; 
        } else if(objectName == 'Lead'){
            wo.XC_Lead__c = parentId;
        }
        wo.XC_WorkTypeCategory__c = workTypeCategory;
        wo.XC_CreatedAutomaticallyBySystem__c = true; 
        //wo.RecordTypeId = getWorkOrderRecordTypeByCountry(country);
        return wo;
    }  
    
    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to create a Work Order 
     * @param newCase list of new cases
     * @param workTypeId id of the workType
     * @return the list of the work order
    **/
    public static List<WorkOrder> createWorkOrderRepair(List<Case> newCase, String workTypeId){
        List<WorkOrder> woList = new List<WorkOrder>();
        for(Case c : newCase){
            woList.add(createWorkOrderRepair(c,  workTypeId));
        }
        return woList;
    }
    
    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to create a Work Order 
     * @param newCase list of new cases
     * @param workTypeId id of the workType
     * @return the WorkOrder
    **/
    public static WorkOrder createWorkOrderRepair(Case newCase, String workTypeId){
        WorkOrder wo = new WorkOrder();
        wo.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_ESP_WorkOrder).getRecordTypeId();
        wo.XC_CreatedAutomaticallyBySystem__c = true;
        if ( newCase.AssetId != null ) {
            wo.AssetId =  newCase.AssetId;
        }
        wo.WorkTypeId = workTypeId;
        wo.CaseId =  newCase.Id;   
        wo.ContactId = newCase.ContactId;
        
        return wo;
    }
    
    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description Init a new WorkOrder of 'Q'uality Check Ispection', from a Case and a WorkOrder parent. *** Warning: Parent Work Order can be NULL!***
     * @param newCase list of new cases
     * @param workTypeId id of the workType
     * @param parentWO workOrder parent
     * @return the workorder
     */
    public static WorkOrder initWorkOrderIspection(Case newCase, Id workTypeId, WorkOrder parentWO){
        WorkOrder wo = new WorkOrder();
        wo.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_ESP_WorkOrder).getRecordTypeId();
        wo.WorkTypeId = workTypeId;
        wo.CaseId =  newCase.Id;
        wo.XC_CreatedAutomaticallyBySystem__c = true;
        if(parentWO!=null){
            wo.ParentWorkOrderId = newCase.XC_WorkOrder__c;
            wo.AssetId =  parentWO.AssetId;
            wo.City = parentWO.City;
            wo.Country = parentWO.Country;
            wo.PostalCode = parentWO.PostalCode;
            wo.Street = parentWO.Street;
            wo.State = parentWO.State;
            wo.AccountId = parentWO.AccountId;
            wo.ContactId = parentWO.ContactId;
        }else{
            wo.AccountId = newCase.AccountId;
            wo.ContactId = newCase.ContactId;
        }
        return wo;
    }  

    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @param newCase list of new cases
     * @param workTypeId id of the workType
     * @description Method to create a Work Order 
     * @return the workorder created
    **/
    public static WorkOrder createWorkOrderInspection(Case newCase, String workTypeId){
        WorkOrder wo = new WorkOrder(); 
        wo.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_ESP_WorkOrder).getRecordTypeId();
        if(newCase.AssetId != null) {
            wo.AssetId =  newCase.AssetId;
        }
        if(newCase.ContactId!=null) {
            wo.ContactId =  newCase.ContactId;
        }
        wo.WorkTypeId = workTypeId;
        wo.CaseId =  newCase.Id;  
        return wo;
    }  

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @date Modification 09/08/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param country the country
     * @description Method to get Work Order RecordTypeId By Country.
     * @return the correct record type
    **/
    public static String getWorkOrderRecordTypeByCountry(String country){
        String recordTypeDeveloperName = '';
        if(!String.isBlank(country) && (country.equalsIgnoreCase('Spain')|| country.equalsIgnoreCase('Italy'))){
            recordTypeDeveloperName = 'XC_ESP_WorkOrder';
        } else if(!String.isBlank(country) && country.equalsIgnoreCase('United Kingdom')) {
            recordTypeDeveloperName = 'XC_UK_WorkOrder';
        } else if(!String.isBlank(country) && country.equalsIgnoreCase('Colombia')) {
            recordTypeDeveloperName = 'XC_COL_WorkOrder';
        } else if(!String.isBlank(country) && country.equalsIgnoreCase('Chile')) {
            recordTypeDeveloperName = 'XC_CHL_WorkOrder';
        }
        if(!String.isBlank(recordTypeDeveloperName)){
            return Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
        }
        return null;
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @param typeName workType name
     * @description Method to get Work Type Id By Name.
     * @return the worktype id
    **/
    public static String getWorkTypeByName(String typeName){
        String wtId = '';
        if(!Schema.sObjectType.WorkType.isAccessible()){
            return wtId;
        }
        List<WorkType> wtList = [SELECT Id FROM WorkType WHERE Name =:typeName LIMIT 1];
        if(!wtList.isEmpty()){
            wtId = wtList[0].Id; 
        }
        return wtId;
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com 
     * @param wo the WorkOrder
     * @param addressWrapper the wrapper of the address
     * @description Method to populate a Work order address info
    **/
    public static void populateAddressFields(WorkOrder wo, XC_UTIL_Schedule_W.AddressWrapper addressWrapper) {
        wo.City = addressWrapper.city;
        wo.Country = addressWrapper.country;
        wo.PostalCode = addressWrapper.postalCode;
        wo.Street = addressWrapper.street;
        wo.State = addressWrapper.state;
        wo.XC_Address__c = addressWrapper.addressId;
    }

    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
     * @param wo the workorder
     * @param ld the lead
     * @description Method to populate a Work order address info with data incoming from a Lead
    **/
    public static void populateAddressFieldsFromLead(WorkOrder wo, Lead ld) {
        wo.City = ld.XC_City__c;
        wo.Country = ld.Country__c;
        wo.PostalCode = ld.XC_ZipCode__c;
        wo.Street = ld.XC_Address__c;
        wo.State = ld.XC_Province__c;
    } 
    
    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
     * @param workOrderList the list of the workorder
     * @description Method to check if the status of the work order is final, then return a list of WorkOrder with these records
     * @return List<WorkOrder>
    **/
    public static List<WorkOrder> workOrdersInFinalStatus(List<WorkOrder> workOrderList){
        List<WorkOrder> finalStatusWOList = new List<WorkOrder>();
        for(WorkOrder wo : workOrderList){
            if(wo.XC_Check_Final_Status__c){
                finalStatusWOList.add(wo);
            }
        }
        return finalStatusWOList;
    } 

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @date 07/02/2019
     * @param assetId the id of the asset
     * @description retrivs Planned Maintenance Work Order pending to be completed (in a status not final)
     * @return List<WorkOrder>
     */
    public static List<WorkOrder> retriveMaintenanceWOByAsset(Id assetId){
        String woRT = getWorkOrderRecordTypeByCountry('Spain');
        if(!Schema.sObjectType.WorkOrder.isAccessible()){
            return new List<WorkOrder>();
        }
        List<WorkOrder> workOrders = [SELECT Id 
                                        FROM WorkOrder
                                       WHERE AssetId =: AssetId
                                         AND RecordTypeId =: woRT
                                         AND XC_WorkTypeCategory__c =: Label.XC_CL_WorkType_PlannedMaintenance
                                         AND Status !=: Label.XC_CL_WorkOrder_Completed 
                                         AND Status !=: Label.XC_CL_WorkOrder_Canceled
                                         AND Status !=: Label.XC_CL_WorkOrder_CannotComplete ];
        return workOrders;
    }

    /**
     * @author Mario Rossi
     * @Date 07/02/2019
     * @Date Modify - Salvatore Agrillo - salvatore.agrillo@nttdata.com 
     * @param wr - SendToBackOfficeWrapper
     * @description Retrieves Planned Maintenance Work Order pending to be completed (in a status not final)
     * @return XC_UTIL_Sobject.WrapperResult
     */
    public static XC_UTIL_Sobject.WrapperResult sendToBackOffice(SendToBackOfficeWrapper wr){
        wr.serAppToChange.ServiceTerritoryId = null;
        wr.serAppToChange.XC_RequiredPartnerId__c = null;
        wr.workOrderToChange.XC_RequiredPartnerId__c = null;
        wr.serAppToChange.XC_AssignToPartner__c = wr.mapWorkType.get(wr.workOrderToChange.XC_WorkTypeLabel__c);
        //wr.serAppToChange.XC_AssignToPartner__c = XC_UTIL_WorkType.retrieveAssignToPartnerFlagByWorkType(workOrderToChange.XC_WorkTypeName__c);
        wr.workOrderToChange.ServiceTerritoryId = null;
        if(wr.queueId!= null){
            wr.serAppToChange.OwnerId = wr.queueId;
            wr.serAppToChange.XC_AssignedResource__c = null;
            wr.serAppToChange.XC_AssignedPartner__c  = null;
            wr.workOrderToChange.OwnerId = wr.queueId;
            wr.workOrderToChange.XC_AssignedResource__c = null; 
            wr.workOrderToChange.XC_AssignedPartner__c = null; 
        }
        if(!String.isBlank(wr.partnerIdCurrentResource)){
            XC_UTIL_ResourcePreference_U.excludeDispatcher(wr.workOrderToChange, wr.partnerIdCurrentResource); 
        }
        XC_UTIL_Sobject.WrapperResult res = XC_UTIL_Sobject.updateRecord(wr.workOrderToChange);
        if(res.success) {
            return XC_UTIL_Sobject.updateRecord(wr.serAppToChange);
        } 
        return res;
    }

    /**
    * @description sum children's duration and update parent with this sum
    * @author Andrea Bravaccino
    * @date 29/7/2019
    * @param mapNew Map<Id, WorkOrder>
    */
    public static void populateDurationFromChildren(Map<Id, WorkOrder> mapNew){
        List<WorkOrder> listNew = mapNew.values();
        List<WorkOrder> woToUpdate = new List<WorkOrder>();
        List<WorkOrder> childrenWo = new List<WorkOrder>([SELECT ID, ParentWorkOrderId, Duration FROM WorkOrder WHERE ParentWorkOrderId IN :listNew]);
        Map<Id, Decimal> mapParentDuration = new Map<Id, Decimal>();
        for (WorkOrder wo : childrenWo) {
            Decimal duration = mapParentDuration.get(wo.ParentWorkOrderId);
            if (duration == null){
                duration = wo.Duration;
            }else if (wo.Duration != null){
                duration += wo.Duration;
            }
            mapParentDuration.put(wo.ParentWorkOrderId, duration);
        }

        for (Id parentId : mapParentDuration.keySet()) {
            WorkOrder wo = mapNew.get(parentId);
            wo.Duration = mapParentDuration.get(parentId);
            if (wo.Duration != null){
                woToUpdate.add(wo);
            }
        }
        XC_UTIL_SOBject.updateListRecords(woToUpdate);
    }

    
    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 02/09/2019
    * @description Method to delete sharing rule when WO is assigned to BO
    * @param woId - String
    * @param saId - String
    */
    /*
    public static void unshareForBO(String woId, String saId) {
        List<WorkOrder> wo = new List<WorkOrder>([
            SELECT Account.Name, Account.Id
            FROM WorkOrder
            WHERE Id = :woId 
        ]);
        Map<String, String> mapGroup = XC_UTIL_Sharing.getMapGroupByAccountName(new List<String>{wo[0].Account.Name}); 

        if(mapGroup.containsKey(wo[0].Account.Name)) {
            List<sObject> listShareToDelete = new List<SObject>();

            // For WorkOrder:
            List<WorkOrderShare> listWoShare = new List<WorkOrderShare>([
                SELECT Id
                FROM WorkOrderShare
                WHERE ParentId = :woId AND UserOrGroupId = :mapGroup.get(wo[0].Account.Name)
            ]);
            listShareToDelete.addAll(listWoShare);

            // For Service Appointment:
            if(saId != null && saId != '') {
                List<ServiceAppointmentShare> listSaShare = new List<ServiceAppointmentShare>([
                    SELECT Id
                    FROM ServiceAppointmentShare
                    WHERE ParentId = :saId AND UserOrGroupId = :mapGroup.get(wo[0].Account.Name)
                ]);
                listShareToDelete.addAll(listSaShare);
            }

            // For Account:
            List<AggregateResult> listAggResult = new List<AggregateResult>([
                SELECT COUNT(Id) numberAccount
                FROM WorkOrderShare 
                WHERE Parent.AccountId = :wo[0].Account.Id
            ]); 
            if(listAggResult[0].get('numberAccount') == 0) {
                List<AccountShare> listAccountShare = new List<AccountShare>([
                    SELECT Id
                    FROM AccountShare
                    WHERE AccountId = :wo[0].Account.Id AND UserOrGroupId = :mapGroup.get(wo[0].Account.Name)
                ]);
                listShareToDelete.addAll(listAccountShare);
            }

            XC_UTIL_Sobject.deleteListRecords(listShareToDelete);
        }
    }
    */
    
    /**
    * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 15/04/2020
    * @description Method to check if a WorkOrder requires Serial Number checks for its Asset
    * @param mapWo - Map<Id, WorkOrder>
    * @param listWoIdToManage - List<Id>
    * @return Map<Id, String> 
    */
    public static Map<Id, String> getMapWorkOrderErrorSerialNumber(Map<Id, WorkOrder> mapWo, List<Id> listWoIdToManage){
        Map<Id, String> mapWOError = new Map<Id, String>();
        for(Id woId : listWoIdToManage){
            WorkOrder wo = mapWo.get(woId);
            Boolean checkStatusReason = wo.XC_StatusReason__c=='Technically unviable installation - No viable alternative' || wo.XC_StatusReason__c=='Technically unviable installation - With alternative' || wo.XC_StatusReason__c=='Customer wants modifications with an already accepted budget';
            Boolean checkStatus = wo.Status == Label.XC_CL_WorkOrder_Completed;
            if(!checkStatus || checkStatusReason){
               continue;
            }
            if(wo.ParentWorkOrderId != null){
                if(mapWo.containsKey(wo.ParentWorkOrderId)){
                    WorkOrder parentWO = mapWo.get(wo.ParentWorkOrderId);
                    if(!parentWO.ProductsRequired.isEmpty() && wo.AssetId != null){
                        for(ProductRequired pr: parentWO.ProductsRequired){
                            if(pr.XC_SerialControlled__c && String.isNotBlank(pr.XC_Concat_AssetId__c)){
                                if(pr.XC_Concat_AssetId__c.split(';').contains(wo.AssetId) && String.isBlank(wo.Asset.SerialNumber)){ 
                                    mapWOError.put(wo.Id, Label.XC_CL_ErrorWoAssetSerialNumber + '(' + wo.WorkOrderNumber + ')');
                                    continue;
                                }
                            }   
                        }
                    }
                }
                
            } else {
                if(wo.AssetId != null){
                    if(!wo.ProductsRequired.isEmpty()){
                        for(ProductRequired pr: wo.ProductsRequired){
                            if(pr.XC_SerialControlled__c && String.isNotBlank(pr.XC_Concat_AssetId__c)){
                                if(pr.XC_Concat_AssetId__c.split(';').contains(wo.AssetId) && String.isBlank(wo.Asset.SerialNumber)){ 
                                    mapWOError.put(wo.Id, Label.XC_CL_ErrorWoAssetSerialNumber + '(' + wo.WorkOrderNumber + ')');
                                    continue;
                                }
                            }   
                        }
                    }
                } else {
                    if(!wo.ProductsRequired.isEmpty() && !wo.ChildWorkOrders.isEmpty()){
                        Set<String> setIdAssetToCheck = new Set<String>();
                        for(ProductRequired pr: wo.ProductsRequired){
                            if(pr.XC_SerialControlled__c && String.isNotBlank(pr.XC_Concat_AssetId__c)){
                                setIdAssetToCheck.addAll(pr.XC_Concat_AssetId__c.split(';'));
                            }   
                        }
                        for(WorkOrder woChild : wo.ChildWorkOrders){
                            if(woChild.Status == Label.XC_CL_WorkOrder_Completed && setIdAssetToCheck.contains(woChild.AssetId) && String.isBlank(woChild.Asset.SerialNumber)){ 
                                mapWOError.put(wo.Id, Label.XC_CL_ErrorWoAssetSerialNumber + '(' + woChild.WorkOrderNumber + ')');
                                continue;
                            } 
                        }
                    }
                }
            }
        }
        return mapWOError;
    }
    
    /**
    * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 15/04/2020
    * @description Method to check if a WorkOrder requires Serial Number checks for its Asset
    * @param listWoIdToManage - List<Id>
    * @return Map<Id, String> 
    */
    public static Map<Id, String> getMapWorkOrderErrorSerialNumber(List<WorkOrder> listWoToManage){
        List<Id> listWoIdToManage = XC_UTIL_Sobject.getIds(listWoToManage);
        List<Id> listParentWOIds = XC_UTIL_Sobject.getListFieldValues(listWoToManage, 'ParentWorkOrderId'); 
        
        Map<Id, WorkOrder> mapWo = new Map<Id, WorkOrder>(
            [SELECT Id,WorkOrderNumber,ParentWorkOrderId,AssetId,Asset.SerialNumber,XC_StatusReason__c, Status,
                (SELECT Id,XC_SerialControlled__c,XC_Concat_AssetId__c FROM ProductsRequired),
                (SELECT Id,WorkOrderNumber,AssetId,Asset.SerialNumber, Status FROM ChildWorkOrders)
            FROM WorkOrder 
            WHERE ID IN: listWoIdToManage OR Id IN: listParentWOIds]
        );  
    
        return getMapWorkOrderErrorSerialNumber(mapWo, listWoIdToManage);
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 08/05/2020
    * @description Method to calculate a Map (LegalEntity -> Id Queue) [If input list is empty, map contains all queue]
    * @param listNameQueue - List<String>
    * @return Map<String, String>
    */
    public static Map<String, String> getMapQueueIds(List<String> listNameQueue) {
        String query = 'SELECT Id, DeveloperName FROM Group ';
        if(listNameQueue.isEmpty()) {
            query += 'WHERE DeveloperName LIKE \'%DispatcherQueue%\'';
        } else {
            query += 'WHERE DeveloperName IN :listNameQueue';
        }
        List<Group> listGroups = Database.query(query);

        Map<String, String> mapLegalEntityQueueId = new Map<String, String>();
        if(listGroups.isEmpty()) {
            return mapLegalEntityQueueId;
        }
        for(Group g : listGroups) {
            mapLegalEntityQueueId.put(g.DeveloperName, g.Id);
        }
        return mapLegalEntityQueueId;
    }
    
}