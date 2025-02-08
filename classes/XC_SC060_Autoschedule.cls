/**
* @author FSL Team: Salvatore Barbera - sbarbera@deloitte.it
* @date Creation 11/10/2021
* @description XC_SC060_Autoschedule Schedulable class to use FSL API call to autoschedule Service Appointments
*/

public without sharing class XC_SC060_Autoschedule implements Schedulable, Database.Batchable<sObject> {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC060_Autoschedule');

    /**
     * @date Creation 11/10/2021
     * @description Method to schedule class
     * @param sc - SchedulableContext
     */
    public void execute(SchedulableContext sc) { 
        System.debug('@# execute ' + sc);
        Integer batchSize = Integer.valueof(XC_CS_UtilityGlobalValues__c.getInstance('XC_SC060Autoschedule_batchSize').Value__c);
        Database.executeBatch(new XC_SC060_Autoschedule(), batchSize);
    } 
    
    /**
     * @date Creation 11/10/2021
     * @description Method to start batch
     * @param bc - Database.BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
		List<AsyncApexJob> instanceRunningList_XC_060 = [select Id from AsyncApexJob where ApexClass.Name = 'XC_SC060_Autoschedule' and JobType = 'BatchApexWorker' and (status !='Completed' and Status !='Aborted' and Status != 'Failed')];
        Integer parallelNumExec = Integer.valueof(XC_CS_UtilityGlobalValues__c.getInstance('XC_SC060Autoschedule_parallelNumExec').Value__c);
        if(instanceRunningList_XC_060.size() >= parallelNumExec){
            System.debug('STOP instanceRunningList_XC_060 (an instance already running)');
            return Database.getQueryLocator('SELECT Id FROM WorkOrder LIMIT 0');
        }
        
        System.debug('Execute instanceRunningList_XC_060');
        
        String query = 'SELECT id, XC_Country__c, XC_FSLAssignmentKey__c, Asset.XC_Original_Configuration_Item__c,XC_WorkTypeCategory__c, ' +
                'XC_AssignedPartner__c, XC_Configuration__c, ServiceTerritoryId,  ' +
                'XC_Configuration__r.NE__OptyId__r.CreatedBy.AccountId,XC_Configuration__r.NE__OptyId__r.CreatedBy.Account.XC_Technical_Service_Partner__c,' +
                ' ParentWorkOrder.XC_Configuration__r.NE__OptyId__r.CreatedBy.Account.XC_Technical_Service_Partner__c,' +
                'XC_Configuration__r.NE__OptyId__r.CreatedBy.Account.XC_Technical_Service__c,ParentWorkOrder.Id,ParentWorkOrder.XC_Configuration__c, ' +
                'ParentWorkOrder.XC_Configuration__r.NE__OptyId__r.CreatedBy.AccountId,' +
                ' ParentWorkOrder.XC_Configuration__r.NE__OptyId__r.CreatedBy.Account.XC_Technical_Service__c,' +
                'WorkTypeId,WorkType.Name,Account.XC_Technical_Service__c,XC_To_Be_Manually_Assigned__c,Country, State, City,PostalCode,' +
                'Street, Latitude, Longitude from WorkOrder ' +
                'WHERE XC_Auto_Schedulable__c = true and XC_To_Be_Manually_Assigned__c = false ' +
                'and ID not in (select ParentRecordId from ServiceAppointment ) and Status=\'New\' and ParentWorkOrderId = null ' +
                'and (XC_WorkTypeCategory__c = \'Delivery & Installation\' or XC_WorkTypeCategory__c = \'Site Inspection\' or XC_WorkTypeCategory__c = \'Installation\'';
        if(Test.isRunningTest()){
            //To add coverage
            query += 'or XC_WorkTypeCategory__c = \'Repair\' ';
        }
        query += ')';
        System.debug('@# query ' + query);
        return Database.getQueryLocator(query);
    }
    
    /**
     * @date Creation 11/10/2021
     * @description Method to execute batch
     * @param bc - Database.BatchableContext
     * @param workOrders - List of workorder with XC_Auto_Schedulable__c = true
     */
    public void execute(Database.BatchableContext bc, List<WorkOrder> workOrders) {
        System.debug('@# execute ' + bc + ' ' + workOrders );
        //retrive all account used if saturation check if needed
        Map<Id,Integer> mapElegiblePartnerSaturation =  XC_SC060_Autoschedule_U.getAccountsForSaturationCalculation();
        List<Account> accountForSaturation = XC_SC060_Autoschedule_U.getOrderedListSaturationFromMap(mapElegiblePartnerSaturation);

        //list of assigned partner for each WorkOrder Id
        Map<Id, Account> assignedPartner = XC_SC060_Autoschedule_U.getMapWorkOrderAssignedPartner(workOrders);

        //List of directly elegible account for WorkOrder Id
        Map<Id, Id> directElegibilityList = XC_SC060_Autoschedule_U.getMapWorkOrderWithAccountDirectlyElegible(workOrders);

        //List of ServiceResource manager
        Map<Id, ServiceResource> srManagerMap = XC_SC060_Autoschedule_U.getManagerFromAccount(accountForSaturation, directElegibilityList.values());
        
        //List of ServiceResource where field XC_Saturation__c is set
        List<ServiceResource> srListToClear =  XC_SC060_Autoschedule_U.setSaturationOnServiceResource( mapElegiblePartnerSaturation, srManagerMap);

        //map of CustomMetadata associated to WorkOrder (Key is country, value is XC_CM_Scheduling_Default_Value__mdt)
        Map<String,XC_CM_Scheduling_Default_Value__mdt> metadataMap = XC_SC060_Autoschedule_U.getMetadataFromWorkOrder(workOrders);

        //clear resource preference
        XC_SC060_Autoschedule_U.clearResourcePreference(XC_UTIL_Sobject.getIds(workOrders));
        
        //This map will be helpful to get ServiceAppointement to delete after schedulation
        //In order to avoid exceed governor limit we create all potentially ServiceAppointment that will be used
        //during autoschedule process
        Map<Id, ServiceAppointment> woServiceAppointmentMap = XC_SC060_Autoschedule_U.getServiceAppointmentsFromWorkOrder(workOrders,directElegibilityList,metadataMap,accountForSaturation);

        //map of OperatingHours
        Map<String, OperatingHours> operatingHoursMap = XC_SC060_Autoschedule_U.getOperatingHoursMapFromMetadataList(metadataMap.values());
        Map<String, FSL__Scheduling_Policy__c> policyMap = XC_SC060_Autoschedule_U.getPolicyFromMetadataList(metadataMap.values());

        //Map of ServiceResource related to account
        Map<ID, List<ServiceResource>> mapSr = XC_SC060_Autoschedule_U.getServiceResourcesFromAccount(accountForSaturation, directElegibilityList.values());

        for (WorkOrder wo : workOrders) {
            if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_SiteInspection){
                Account assignedPartnerAccount = assignedPartner.get(wo.Id);
                XC_CM_Scheduling_Default_Value__mdt metadataForCountry= metadataMap.get(wo.Country.toUpperCase());
                OperatingHours operatingHoursForCountry = operatingHoursMap.get(metadataForCountry.XC_Operating_Hours_Name__c);
                //Map<Id, ServiceAppointment> serviceAppointmentMap = woServiceAppointmentMap.get(wo.Id); works with getServiceAppointmentsFromWorkOrder_OLD
                ServiceAppointment serviceAppointment = woServiceAppointmentMap.get(wo.Id);
                FSL__Scheduling_Policy__c policyForCountry = policyMap.get(metadataForCountry.XC_Policy_Name_Autoschedule__c);
                XC_SC060_Autoschedule_U_SiteInspection autoscheduleSiteInspection = new XC_SC060_Autoschedule_U_SiteInspection(wo,assignedPartnerAccount,accountForSaturation,directElegibilityList,srManagerMap,metadataForCountry,operatingHoursForCountry,serviceAppointment, policyForCountry);
                autoscheduleSiteInspection.scheduleAppointment();
            }else if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Installation ){
                Account assignedPartnerAccount = assignedPartner.get(wo.Id);
                XC_CM_Scheduling_Default_Value__mdt metadataForCountry= metadataMap.get(wo.Country.toUpperCase());
                OperatingHours operatingHoursForCountry = operatingHoursMap.get(metadataForCountry.XC_Operating_Hours_Name__c);
                FSL__Scheduling_Policy__c policyForCountry = policyMap.get(metadataForCountry.XC_Policy_Name_Autoschedule__c);
                //Map<Id, ServiceAppointment> serviceAppointmentMap = woServiceAppointmentMap.get(wo.Id); works with getServiceAppointmentsFromWorkOrder_OLD
                ServiceAppointment serviceAppointment = woServiceAppointmentMap.get(wo.Id);
                XC_SC060_Autoschedule_U_DI autoscheduleDI = new XC_SC060_Autoschedule_U_DI(wo,assignedPartnerAccount,accountForSaturation,directElegibilityList,srManagerMap,metadataForCountry,operatingHoursForCountry,serviceAppointment, policyForCountry);
                autoscheduleDI.scheduleAppointment();
            }else if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair){
                Account assignedPartnerAccount = assignedPartner.get(wo.Id);
                XC_CM_Scheduling_Default_Value__mdt metadataForCountry= metadataMap.get(wo.Country.toUpperCase());
                OperatingHours operatingHoursForCountry = operatingHoursMap.get(metadataForCountry.XC_Operating_Hours_Name__c);
                //Map<Id, ServiceAppointment> serviceAppointmentMap = woServiceAppointmentMap.get(wo.Id); works with getServiceAppointmentsFromWorkOrder_OLD
                ServiceAppointment serviceAppointment = woServiceAppointmentMap.get(wo.Id);
                FSL__Scheduling_Policy__c policyForCountry = policyMap.get(metadataForCountry.XC_Policy_Name_Autoschedule__c);
                XC_SC060_Autoschedule_U_Repair autoscheduleRepair= new XC_SC060_Autoschedule_U_Repair(wo,assignedPartnerAccount,directElegibilityList,srManagerMap,metadataForCountry,operatingHoursForCountry,serviceAppointment, policyForCountry);
                autoscheduleRepair.scheduleAppointment();
            }
        }

        XC_SC060_Autoschedule_U.deleteServiceAppointNotUsed(workOrders,woServiceAppointmentMap);
        XC_SC060_Autoschedule_U.clearSaturationOnServiceResource(srListToClear);
        XC_SC060_Autoschedule_U.setWorkOrderAsManuallyAssigned(workOrders);

        //clear resource preference
        XC_SC060_Autoschedule_U.clearResourcePreference(XC_UTIL_Sobject.getIds(workOrders));

        //set resource preference
        XC_SC060_Autoschedule_U.setResourcePreferenceForScheduledWorkOrder(workOrders, mapSr);
    }
    
    /**
     * @date Creation 11/10/2021
     * @description Method to finish batch
     * @param bc - Database.BatchableContext
     */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Finish batch XC_SC060_Autoschedule');
    }
}