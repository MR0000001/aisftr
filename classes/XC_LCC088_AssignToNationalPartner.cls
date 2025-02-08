/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com/ Marco Rosa - marco.rosa@nttdata.com / Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 25/02/2019
* @date Modification 26/06/2020 : Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @description XC_LCC088_AssignToNationalPartner - Controller for XC_LCP088_AssignToNationalPartner Component. 
*/
public without sharing class XC_LCC088_AssignToNationalPartner { 

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC088_AssignToNationalPartner'); 
     
    /** @description UpdateWoSaWrapper */
    private class UpdateWoSaWrapper {
        ServiceAppointment sa = new ServiceAppointment();
        XC_UTIL_Sobject.WrapperResult dmlSAResult = new XC_UTIL_Sobject.WrapperResult();
    }

    /**
     * @description The Class ResultWrapper.
     */
    public class ResultWrapper { 
        /** The success. */
        @AuraEnabled
        public Boolean success = false;  
        /** The message. */
        @AuraEnabled
        public String message = ''; 
    }

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 22/06/2020 
    * @param recordId 
    * @param documentsAcceptedMap 
    * @return List<String> 
    **/
    @AuraEnabled
    public  static List<String> retrieveNationalPartner(String recordId){
        List<String> nationalPartnerList = new List<String>();
        List<WorkOrder> woList = new List<WorkOrder>([SELECT Id, XC_LegalEntity__c 
                                                    FROM WorkOrder 
                                                    WHERE Id =: recordId]);
        if(woList.isEmpty()){
            return nationalPartnerList;
        }
        WorkOrder wo = woList[0];
        
        List<ServiceResource> serviceResourceList = new List<ServiceResource>( [SELECT XC_Account__r.Name 
                                                                                FROM ServiceResource 
                                                                                WHERE XC_IsManager__c = true AND XC_LegalEntity__c  =: wo.XC_LegalEntity__c AND IsActive  = true AND XC_Account__r.XC_NationalPartner__c = true] );
        
        for(ServiceResource serviceRes : serviceResourceList){
            nationalPartnerList.add(serviceRes.XC_Account__r.Name);
        }
        
        return nationalPartnerList;
    }

    /**
     * @description Assign to national partner. 
     * @param recordId the record id
     * @return the result wrapper
     */
    @AuraEnabled
    public static ResultWrapper assignToNationalPartner(String accountName, String recordId){ 
        List<WorkOrder> woList = new List<WorkOrder>();
        List<ServiceResource> serviceResourceList = new List<ServiceResource>();
        ResultWrapper rw = new ResultWrapper();
        rw.success = true;
        rw.message = 'Ok';
        if(!String.isBlank(accountName) && !String.isBlank(recordId)){
            String query = XC_UTIL_SObject.selectAllFieldsGetSelect('WorkOrder'); 
            query += ', (SELECT Id,Duration,Status,XC_Country__c,XC_AssignToPartner__c,ArrivalWindowEndTime,ArrivalWindowStartTime,ServiceTerritoryId,XC_AssignedResource__c,XC_ZipCedeWorkType__c, SchedStartTime, SchedEndTime, DueDate, EarliestStartTime FROM Serviceappointments)';
            query += ', (SELECT Id,ServiceResource.name, PreferenceType FROM ResourcePreferences) ';
            query += ' FROM WorkOrder WHERE id =: recordId'; 
            woList = Database.query(query);  
            if(woList.isEmpty()){
                rw.success = false;
                rw.message = 'Record not found'; 
                return rw;
            }
            serviceResourceList = new List<ServiceResource>( [SELECT Id, XC_Account__r.Name 
                                                                                FROM ServiceResource 
                                                                                WHERE XC_Account__r.Name =: accountName
                                                                                AND XC_IsManager__c =: true] );
            if(serviceResourceList.isEmpty()){
                rw.success = false;
                rw.message = Label.XC_CL_NationalPartnerNotFound;      
                return rw;
            }                                                                      
        } else {
            rw.success = false;
            rw.message = Label.XC_CL_NationalPartnerNotFound;      
            return rw;
        }
        if(woList[0].Status != Label.XC_CL_WorkOrder_New){
            rw.success = false;
            rw.message = Label.XC_CL_WorkOrder_ErrorAssignment;      
            return rw;
        }
        rw = manageAssignment(woList[0],serviceResourceList);
        return rw;
    } 

    private static ResultWrapper manageAssignment(WorkOrder wo, List<ServiceResource> nationalPartnerServiceResources ){ 
        ResultWrapper rw = new ResultWrapper();
        XC_UTIL_Sobject.WrapperResult result = new XC_UTIL_Sobject.WrapperResult();
        System.Savepoint beforeDMLSavepoint = Database.setSavepoint();
        List<XC_UTIL_Sobject.WrapperResult> wrapperList = XC_UTIL_ResourcePreference.removeRequiredResourcePreferences(new List<WorkOrder>{wo});
        
        if(!XC_UTIL_Sobject.checkDMLResults(wrapperList)){
            rw.success = false;
            rw.message = wrapperList[0].errorMessage;
            Database.rollback(beforeDMLSavepoint);
            return rw;
        } 
        // insertPreference(wo.Id, nationalPartnerServiceResources, wo); // SS 23/06/2020

        UpdateWoSaWrapper updateWrapper = updateWOAndSA(wo);
        if(updateWrapper.dmlSAResult.success) {
            // XC_UTIL_AutoSchedule.AutoSchedulingResult schedResult = XC_UTIL_AutoSchedule.autoscheduleAppointment(updateWrapper.sa); // creazione manuale assigned resource
            AssignedResource ar = new AssignedResource();
            ar.ServiceAppointmentId = updateWrapper.sa.Id;
            ar.ServiceResourceId = nationalPartnerServiceResources[0].Id;
            result = XC_UTIL_Sobject.insertRecord(ar);
            system.debug('@@@ ERROR MESSAGE @@@ -->' + result.errorMessage);
            rw.success = result.success;
            rw.message = result.errorMessage;
        } else {
            rw.success = false;
            rw.message = updateWrapper.dmlSAResult.errorMessage;
        }                
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'assignToNationalPartner rw->' + rw);
        if(!rw.success){
            Database.rollback(beforeDMLSavepoint);
        }
        return rw;
    }

    private static UpdateWoSaWrapper updateWOAndSA(WorkOrder wo){
        UpdateWoSaWrapper updateWrapper = new UpdateWoSaWrapper();
        if(!wo.ServiceAppointments.isEmpty()){
            updateWrapper.sa = populateFieldsServiceAppointment(wo);
            updateWrapper.sa.SchedStartTime = updateWrapper.sa.EarliestStartTime;
            Integer duration = (Integer) updateWrapper.sa.Duration;
            updateWrapper.sa.SchedEndTime = updateWrapper.sa.EarliestStartTime.addHours(duration);//updateWrapper.sa.DueDate;
            populateFieldsWorkOrder(wo);
            updateWrapper.dmlSAResult = XC_UTIL_Sobject.updateRecord(wo);
            if(updateWrapper.dmlSAResult.success){ 
                updateWrapper.dmlSAResult = XC_UTIL_Sobject.updateRecord(updateWrapper.sa); 
            } 
        } else {
            updateWrapper.sa.ParentRecordId = wo.Id; 
            updateWrapper.sa.XC_Country__c = wo.XC_Country__c;
            updateWrapper.sa.XC_SkipCheckZipCodeWorkType__c = true;
            updateWrapper.dmlSAResult = XC_UTIL_Sobject.insertRecord(updateWrapper.sa);
            if(updateWrapper.dmlSAResult.success){
                updateWrapper.sa.XC_AssignToPartner__c = true;
                ServiceAppointment saQueried = getSAFields(updateWrapper.dmlSAResult.recordId);
                updateWrapper.sa.SchedStartTime = saQueried.EarliestStartTime;
                Integer duration = (Integer) saQueried.Duration;
                
                if(wo.DurationType == 'Hours'){
                	updateWrapper.sa.SchedEndTime = saQueried.EarliestStartTime.addHours(duration);
                }else if(wo.DurationType == 'Minutes'){
                    updateWrapper.sa.SchedEndTime = saQueried.EarliestStartTime.addMinutes(duration);
                }
                
                updateWrapper.dmlSAResult = XC_UTIL_Sobject.updateRecord(updateWrapper.sa); 
            }
        }
        return updateWrapper; 
    }

    private static ServiceAppointment getSAFields(String recordId){
        List<ServiceAppointment> saList = new List<ServiceAppointment>([SELECT Id,EarliestStartTime,DueDate,Duration FROM ServiceAppointment WHERE Id =: recordId]);
        return saList[0];
    }

    private static ServiceAppointment populateFieldsServiceAppointment(WorkOrder wo){
        ServiceAppointment newSa = new ServiceAppointment();
        newSa = wo.ServiceAppointments[0]; 
        //Boolean assignToPartnerValueForWorkType = (XC_UTIL_WorkType.getMapAssignToPartnerByWorkTypeName(new List<String>{wo.XC_WorkTypeName__c})).get(wo.XC_WorkTypeName__c);
        newSa.XC_AssignToPartner__c = true;
        newSa.XC_Country__c = wo.XC_Country__c;
        newSa.ServiceTerritoryId = null;
        newSa.XC_AssignedResource__c = null;
        newSa.XC_AssignedPartner__c = null;
        newSa.XC_SkipCheckZipCodeWorkType__c = true;
        return newSa;
    }

    private static void populateFieldsWorkOrder(WorkOrder wo){ 
        wo.ServiceTerritoryId = null;
        wo.XC_AssignedResource__c = null;
        wo.XC_AssignedPartner__c = null;
    }

    /**
     * @description Insert preference. 
     * @param recordId the record id
     * @param nationalPartnerServiceResources the national partner service resources
     * @param wo WorkOrder
     */
    /*public static void insertPreference(Id recordId, List<ServiceResource> nationalPartnerServiceResources, WorkOrder wo){
        Boolean preferenceExists = false;
        for(ResourcePreference rp : wo.ResourcePreferences){
            if(rp.ServiceResourceId == nationalPartnerServiceResources[0].Id){
                preferenceExists = true;
                break;
            }
        }
        if(!preferenceExists){
            Map<Id, Set<Id>> mapWorkOrderListServiceResources = new Map<Id, Set<Id>>();
            List<Id> listId =  XC_UTIL_Sobject.getIds(nationalPartnerServiceResources);
            mapWorkOrderListServiceResources.put(recordId, new Set<Id>(listId)); 
            XC_UTIL_ResourcePreference.insertRequiredResourcePreferences(mapWorkOrderListServiceResources);
        }
    } */
}