/** 
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 28/12/2018
* @date Modification dd/mm/yyyy
* @description XC_REST_WorkOrder_U_D - dao class for rest workOrder 
*/
public without sharing class XC_REST_WorkOrder_U_D {

    private static final String WORKORDER_FIELDS = 
    'WorkOrderNumber, WorkTypeId, WorkType.Name, Status, Priority, ParentWorkOrder.WorkOrderNumber, XC_Opportunity__c, CaseId, XC_Refusing_Reason__c, '+
    'XC_StatusReason__c, XC_MissingQuoteReason__c, XC_Reason_Cannot_Complete__c, Subject, OwnerId, Description, XC_InstallationDate__c, XC_DeliveryId__c, '+
    'XC_DeliveryDate__c, XC_LegalEntity__c, XC_DeliveryType__c, XC_EffectiveDeliveryDate__c, XC_EffectiveProductAvailabilityDate__c, XC_ProductReservationResult__c, '+
    'XC_Courier_Partner__c, XC_SiteOK__c, XC_GasAnalyzer__c, XC_ElectricityMeasurement__c, street, postalcode, city, state, country, XC_SerialNumber__c, '+
    'XC_Configuration__c, XC_Configuration_Item__c, Account.XC_MainPhonePrefix__c, XC_TypeOfSite__c, ContactId, XC_Delivery_Tracking_URL__c, '+
    'AccountId, Account.XC_AccountPhonePrefix__c, Account.XC_AccountPhone__c, Account.XC_LastName__c, Account.XC_FirstName__c, Account.PrimaryEmail__c, '+
    'Account.XC_AccountMainPhone__c, XC_Lead__r.id, XC_Lead__r.Name, XC_Lead__r.XC_PhonePrefix__c, XC_Lead__r.XC_LeadMobile__c, XC_Lead__r.XC_EmailCustom__c, '+
    'XC_Lead__r.XC_MobilePrefix__c, XC_Lead__r.XC_CondominiumName__c, XC_Lead__r.XC_LeadPhone__c, XC_ServiceTypeGP__c, AssetId, Asset.Name, Asset.XC_Model__c, '+
    'Asset.XC_Configuration_Item__r.NE__CatalogItem__r.XC_Brand__c, Asset.XC_CatalogCategory__c, XC_Comments__c, XC_ReturnComments__c, XC_AffectedEquipment__c, '+
    'XC_AffectedInstallation__c, XC_WorkTypeCategory__c, XC_WorkTypeLabel__c, XC_Urgent_Repair__c, XC_AwareOfBenefits__c, XC_WelcomePackReceived__c, '+
    'XC_ExternalPartner__c, XC_UpdatedByApp__c, XC_PartnerSparePartsCost__c, XC_PartnerWorkCost__c, XC_ActualEndDate__c, ' +
    'XC_Result__c, XC_MaxWallboxPower__c, (SELECT Id FROM ChildWorkOrders)';

    private static final String SERVICEAPPOINTEMENT_FIELDS = 
    'Id, XC_Reason_Cannot_Complete__c, Opportunity__c, AccountId, ParentRecordId, WorkTypeId, AppointmentNumber, Status, Subject, Description, EarliestStartTime, DueDate, '+
    'ArrivalWindowStartTime, ArrivalWindowEndTime, SchedStartTime, SchedEndTime, Duration, DurationType, ActualStartTime, ActualEndTime, ActualDuration, FSL__GanttLabel__c, '+         
    'FSL__InJeopardy__c, FSL__Emergency__c, FSL__Pinned__c, FSL__InJeopardyReason__c, FSL__GanttColor__c, FSL__IsMultiDay__c, street, postalcode, city, state, country, '+
    'FSL__InternalSLRGeolocation__c, XC_CheckLocationStart__c, XC_CheckLocationEnd__c, XC_LatitudeStart__c, XC_LatitudeEnd__c, XC_LongitudeStart__c, XC_LongitudeEnd__c, '+
    'XC_StatusReason__c, CreatedDate';
    
    private static final String WORKORDERLINEITEM_FIELDS = 
    'LineItemNumber, Status, XC_Action_Start__c, XC_Action_End__c, XC_ActivityName__c, XC_Required__c, XC_Operation__c, Description, XC_CompletionMode__c, AssetId, '+
    'RecordTypeId, XC_TechnicianResponse__c, XC_DefectType__c, XC_DefectRefer__c, WorkOrder.WorkOrderNumber, XC_ActionDescription__c, XC_MacroBlocNumber__c, XC_MacroBlocName__c, '+
    'XC_ActivityNumber__c, XC_ObservationsOne__c, XC_ObservationsTWO__c, XC_MeasurementValueOne__c, XC_MeasurementUnitOne__c, XC_MeasurementValueTwo__c, XC_MeasurementUnitTwo__c, '+
    'Asset.Name, Asset.XC_Configuration_Item__r.NE__CatalogItem__r.XC_Brand__c, Asset.XC_Model__c, Asset.XC_CatalogCategory__c, XC_Range__c, XC_TechnicianResponseForConfiguration__c';     

    /**
     * @description Gets the work order by id.
     *
     * @param woId the id 
     * @return the work order 
     */
    public static List<WorkOrder> getWorkOrderById(String woId){ 

        String condition = 'id =: woId';

        String queryString =  'SELECT '+ WORKORDER_FIELDS + ', '+
                              '(SELECT ' + SERVICEAPPOINTEMENT_FIELDS + ' FROM ServiceAppointments),'+
                              '(SELECT ' + WORKORDERLINEITEM_FIELDS + ' FROM WorkOrderLineItems)' +
                              'FROM WorkOrder WHERE '+ condition;

        return Database.query( String.escapeSingleQuotes(queryString) );
    }

    /**
     * @description Gets the work order by number.
     *
     * @param numb the numb
     * @return the work order by number
     */
    public static List<WorkOrder> getWorkOrderByNumber(String numb){

        String condition = 'WorkOrderNumber =: numb';

        String queryString =  'SELECT '+ WORKORDER_FIELDS + ', '+
                              '(SELECT ' + SERVICEAPPOINTEMENT_FIELDS + ' FROM ServiceAppointments),'+
                              '(SELECT ' + WORKORDERLINEITEM_FIELDS + ' FROM WorkOrderLineItems)' +
                              'FROM WorkOrder WHERE '+ condition;

        return Database.query( String.escapeSingleQuotes(queryString) );
    }

    /**
     * @description Gets the work order by asset.
     *
     * @param assetId the id 
     * @return the work order 
     */
    public static List<WorkOrder> getWorkOrderByAsset(String assetId){

        String condition = 'AssetId =: assetId';

        String queryString =  'SELECT '+ WORKORDER_FIELDS + ', '+
                              '(SELECT ' + SERVICEAPPOINTEMENT_FIELDS + ' FROM ServiceAppointments),'+
                              '(SELECT ' + WORKORDERLINEITEM_FIELDS + ' FROM WorkOrderLineItems)' +
                              'FROM WorkOrder WHERE '+ condition;

        return Database.query( String.escapeSingleQuotes(queryString) );
    }

    /**
     * @description Gets the work order by account and dates.
     *
     * @param accId the account id
     * @param startDate the start date
     * @param endDate the end date
     * @return the work order 
     */
    public static list<WorkOrder> getWorkOrderByAccountAndDates(Id accId, Date startDate, Date endDate){

        String servAppCondition = 'SchedStartTime >=: startDate AND SchedEndTime <=: endDate';

        String woCondition = 'AccountId =: accId';

        String queryString =  'SELECT '+ WORKORDER_FIELDS + ', '+
                              '(SELECT ' + SERVICEAPPOINTEMENT_FIELDS + ' FROM ServiceAppointments WHERE '+ servAppCondition +'),'+
                              '(SELECT ' + WORKORDERLINEITEM_FIELDS + ' FROM WorkOrderLineItems)' +
                              'FROM WorkOrder WHERE '+ woCondition;

        return Database.query( String.escapeSingleQuotes(queryString) );
    } 

    /**
     * @description Gets the work order by account and dates.
     *
     * @param accId the account id
     * @return the work order 
     */
    public static list<WorkOrder> getWorkOrderByAccount(Id accId){

        String woCondition = 'AccountId =: accId';

        String queryString =  'SELECT '+ WORKORDER_FIELDS + ', '+
                              '(SELECT ' + SERVICEAPPOINTEMENT_FIELDS + ' FROM ServiceAppointments),'+
                              '(SELECT ' + WORKORDERLINEITEM_FIELDS + ' FROM WorkOrderLineItems)' +
                              'FROM WorkOrder WHERE '+ woCondition;

        return Database.query( String.escapeSingleQuotes(queryString) );
    } 

    /**
     * @description Gets the work order by lead and dates.
     *
     * @param email the lead email
     * @param startDate the start date
     * @param endDate the end date
     * @return the work order 
     */
    public static list<WorkOrder> getWorkOrderByLeadEmailAndDates(String email, Date startDate, Date endDate){

        String servAppCondition = 'SchedStartTime >=: startDate AND SchedEndTime <=: endDate';

        String woCondition = 'XC_Lead__r.XC_EmailCustom__c =: email';

        String queryString =  'SELECT '+ WORKORDER_FIELDS + ', '+
                              '(SELECT ' + SERVICEAPPOINTEMENT_FIELDS + ' FROM ServiceAppointments WHERE '+ servAppCondition +'),'+
                              '(SELECT ' + WORKORDERLINEITEM_FIELDS + ' FROM WorkOrderLineItems)' +
                              'FROM WorkOrder WHERE '+ woCondition;

        return Database.query( String.escapeSingleQuotes(queryString) );
    } 

    /**
     * @description Gets the work order by account and dates.
     *
     * @param email the lead email
     * @return the work order 
     */
    public static list<WorkOrder> getWorkOrderByLeadEmail(String email){

        String woCondition = 'XC_Lead__r.XC_EmailCustom__c =: email';

        String queryString =  'SELECT '+ WORKORDER_FIELDS + ', '+
                              '(SELECT ' + SERVICEAPPOINTEMENT_FIELDS + ' FROM ServiceAppointments),'+
                              '(SELECT ' + WORKORDERLINEITEM_FIELDS + ' FROM WorkOrderLineItems)' +
                              'FROM WorkOrder WHERE '+ woCondition;

        return Database.query( String.escapeSingleQuotes(queryString) );
    } 

    /**
     * @description Gets the work order by resource and dates.
     *
     * @param srId the service resource id 
     * @param startDate the start date
     * @param endDate the end date
     * @return the work order 
     */
    public static list<WorkOrder> getWorkOrderByResourceAndDates(Id srId, Date startDate, Date endDate){

        String servAppCondition = 'SchedStartTime >=: startDate AND SchedEndTime <=: endDate';

        String woCondition = 'XC_AssignedResource__c =: srId and Id IN ( SELECT ParentRecordId FROM ServiceAppointment WHERE '+servAppCondition+')';

        String queryString =  'SELECT '+ WORKORDER_FIELDS + ', '+
                              '(SELECT ' + SERVICEAPPOINTEMENT_FIELDS + ' FROM ServiceAppointments WHERE '+ servAppCondition +'),'+
                              '(SELECT ' + WORKORDERLINEITEM_FIELDS + ' FROM WorkOrderLineItems)' +
                              'FROM WorkOrder WHERE '+ woCondition;

        return Database.query( String.escapeSingleQuotes(queryString) );
    } 

    /**
     * @description Gets the work order by lead or account.
     *
     * @param params the input map
     * @return the work order 
     */
    public static list<WorkOrder> getWoByLeadOrAccount(Map<String, String> params){

        String email = params.get('Email');
        String accId = params.get('AccountID');

        String woCondition = 'XC_Lead__r.XC_EmailCustom__c =: email OR AccountId =: accId';

        String queryString =  'SELECT '+ WORKORDER_FIELDS + ', '+
                              '(SELECT ' + SERVICEAPPOINTEMENT_FIELDS + ' FROM ServiceAppointments),'+
                              '(SELECT ' + WORKORDERLINEITEM_FIELDS + ' FROM WorkOrderLineItems)' +
                              'FROM WorkOrder WHERE '+ woCondition;

        return Database.query( String.escapeSingleQuotes(queryString) );
    } 

    /**
     * @description Gets the work order by lead or account with dates filter.
     *
     * @param params the input map
     * @return the work order 
     */
    public static list<WorkOrder> getWoByLeadOrAccountWithDates(Map<String, String> params){

        Date startDate = Date.valueOf(params.get('StartDate'));
        Date endDate = Date.valueOf(params.get('EndDate'));
        String email = params.get('Email');
        String accId = params.get('AccountID');

        String servAppCondition = 'SchedStartTime >=: startDate AND SchedEndTime <=: endDate';

        String woCondition = 'XC_Lead__r.XC_EmailCustom__c =: email OR AccountId =: accId';

        String queryString =  'SELECT '+ WORKORDER_FIELDS + ', '+
                              '(SELECT ' + SERVICEAPPOINTEMENT_FIELDS + ' FROM ServiceAppointments WHERE '+ servAppCondition +'),'+
                              '(SELECT ' + WORKORDERLINEITEM_FIELDS + ' FROM WorkOrderLineItems)' +
                              'FROM WorkOrder WHERE '+ woCondition;

        return Database.query( String.escapeSingleQuotes(queryString) );
    } 

    /**
     * @description Gets the work order by order 
     *
     * @param params the input map
     * @return the work order 
     */
    public static list<WorkOrder> getWoByOrder(Map<String, String> params){

        String ordId = params.get('OrderId');

        Map<Id, NE__OrderItem__c> oiMap = new Map<Id, NE__OrderItem__c>([
            SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: ordId AND Id IN (SELECT XC_Configuration_Item__c FROM WorkOrder)
        ]);

        String woCondition = 'XC_Configuration__c =: ordId';

        List<String> oiId = new List<String>(); 
        if(!oiMap.values().isEmpty()){
            for(NE__OrderItem__c oi:oiMap.values()){
                oiId.add(oi.Id);
            }
            woCondition +=' OR XC_Configuration_Item__c IN: oiId';
        }

        String queryString =  'SELECT '+ WORKORDER_FIELDS + ', '+
                              '(SELECT ' + SERVICEAPPOINTEMENT_FIELDS + ' FROM ServiceAppointments),'+
                              '(SELECT ' + WORKORDERLINEITEM_FIELDS + ' FROM WorkOrderLineItems)' +
                              'FROM WorkOrder WHERE '+ woCondition;

        return Database.query( String.escapeSingleQuotes(queryString) );
    } 

    /**
     * @description Gets the work order by order with dates filter.
     * @param types the input 
     * @param ordId the input 
     * @return the work order 
     */
    public static list<WorkOrder> getWoByOrderAndWorkType(List<String> types, String ordId){ 

        String woCondition = 'XC_Configuration__c =: ordId AND XC_WorkTypeCategory__c in: types';

        String queryString =  'SELECT '+ WORKORDER_FIELDS + ', '+
                              '(SELECT ' + SERVICEAPPOINTEMENT_FIELDS + ' FROM ServiceAppointments),'+
                              '(SELECT ' + WORKORDERLINEITEM_FIELDS + ' FROM WorkOrderLineItems)' +
                              'FROM WorkOrder WHERE '+ woCondition;

        return Database.query( String.escapeSingleQuotes(queryString) );
    } 

}