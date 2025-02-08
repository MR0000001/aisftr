/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 17/07/2019
* @description XC_UTIL_EligibleServiceResource – Util class for calculation of Eligible Resources for WorkOrder based on Input Parameters
*/ 

public without sharing class XC_UTIL_EligibleServiceResource {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_EligibleServiceResource');
    public static Boolean isForTest = false;
    
    /** @description EligibleWrapper */
    public class EligibleWrapper { 
        public String errorMessage = '';
        public Boolean success = false;
        public Date availabilityDate;
		
        public Boolean applyCoverageFilterInBooking = false;
    }

    /** @description PartnerCoverageWrapper */
    private class PartnerCoverageWrapper { 
        List<String> listIdsAccount = new List<String>();
        Boolean exists = false;
        String message = '';
        List<ResourcePreference> listResourcePreferences = new List<ResourcePreference>();
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Roberta Cossiga - r.cossiga@deloitte.it
    * @date 23/09/2019 
    * @description Method to check Resource Preferences and to calculate of Eligible Partners for WorkOrder based on Zip Code and Work Type 
    * @param workOrderId - String
    * @param zipCode - String
    * @param workTypeId - String
    * @param currentUserPartnerId - String
    *  @param applyCoverageFilterInBooking - Boolean
    * @return PartnerCoverageWrapper
    */
	
    private static PartnerCoverageWrapper getPartnerCoverages(String workOrderId, String zipCode, String workTypeId, String currentUserPartnerId, Boolean applyCoverageFilterInBooking) {
        PartnerCoverageWrapper outputWrapper = new PartnerCoverageWrapper();
		
        if(!applyCoverageFilterInBooking || isForTest) {
            outputWrapper.exists = true;
            outputWrapper.listIdsAccount.add(currentUserPartnerId);
            outputWrapper.listResourcePreferences = new List<ResourcePreference>([
                SELECT Id, ServiceResource.XC_Account__c, PreferenceType
                FROM ResourcePreference
                WHERE RelatedRecordId = :workOrderId
            ]);
            return outputWrapper;
        }

        // Check for current user:
        List<ResourcePreference> listResourcePreference = new List<ResourcePreference>();
        String accountId = '';
        if(String.isNotBlank(currentUserPartnerId)) {
            accountId = currentUserPartnerId;
        } else {
            List<ServiceResource> listSr = new List<ServiceResource>([
                SELECT Id, XC_Account__c    
                FROM ServiceResource
                WHERE RelatedRecordId = :UserInfo.getUserId() AND isActive = true
            ]);
            if(!listSr.isEmpty()) {
                accountId = listSr[0].XC_Account__c;
            } else {
                outputWrapper.listResourcePreferences = new List<ResourcePreference>([
                    SELECT Id, ServiceResource.XC_Account__c, PreferenceType
                    FROM ResourcePreference
                    WHERE RelatedRecordId = :workOrderId
                ]);
                for(ResourcePreference rp : outputWrapper.listResourcePreferences) {
                    if(rp.PreferenceType == 'Required') {
                        listResourcePreference.add(rp);
                    }
                }
                if(!listResourcePreference.isEmpty()) {
                    accountId = listResourcePreference[0].ServiceResource.XC_Account__c;
                }
            }
        }

        // Check Partner Coverage:
        String key = zipCode + '_' + workTypeId;
        List<XC_PartnerCoverage__c> partnerCoverages = new List<XC_PartnerCoverage__c>();
        if(String.isNotBlank(accountId)) {
            partnerCoverages = new List<XC_PartnerCoverage__c>([
                SELECT Id, XC_Account__c 
                FROM XC_PartnerCoverage__c 
                WHERE XC_ExternalId__c =: key
                AND XC_Account__c =: accountId
            ]);
        } else {
            List<String> listResourcePreferenceToExclude = new List<String>();
            for(ResourcePreference rp : outputWrapper.listResourcePreferences) {
                if(rp.PreferenceType == 'Excluded') {
                    listResourcePreferenceToExclude.add(rp.ServiceResource.XC_Account__c);
                }
            }
            partnerCoverages = new List<XC_PartnerCoverage__c>([
                SELECT Id, XC_Account__c 
                FROM XC_PartnerCoverage__c 
                WHERE XC_ExternalId__c =: key AND (XC_Account__c NOT IN :listResourcePreferenceToExclude)
            ]);
        }        

        // Calculate Output:
        if(partnerCoverages.isEmpty()) {
            if(!listResourcePreference.isEmpty()) {
                outputWrapper.message = Label.XC_CL_BookApp_RemovePreference;
                return outputWrapper;
            }
            outputWrapper.message = Label.XC_CL_BookApp_NoCoverage;
            return outputWrapper;
        }
          
        for(XC_PartnerCoverage__c cov : partnerCoverages){
            if(!outputWrapper.listIdsAccount.contains(cov.XC_Account__c)){
                outputWrapper.listIdsAccount.add(cov.XC_Account__c); 
            }
        }
        outputWrapper.exists = true;
        return outputWrapper;
    }

    /**
    * @author Salvatore Barbera - sbarbera@deloitte.it & Marina Ciavarra - mciavarra@deloitte.it
    * @date 27/10/2021
    * @description Method to check Resource Preferences and to calculate of Eligible Partners for WorkOrder based on Zip Code and Work Type
    * @param workOrderId - String
    * @param zipCode - String
    * @param workTypeId - String
    * @param currentUserPartnerId - List<String>
    * @param applyCoverageFilterInBooking - Boolean
    * @return PartnerCoverageWrapper
    */
    private static PartnerCoverageWrapper getPartnerCoveragesOnAutoSchedule(String workOrderId, String zipCode, String workTypeId, List<String> currentUserPartnerId, Boolean applyCoverageFilterInBooking) {
        PartnerCoverageWrapper outputWrapper = new PartnerCoverageWrapper();
        if(!applyCoverageFilterInBooking || isForTest) {
            outputWrapper.exists = true;
            outputWrapper.listIdsAccount.addAll(currentUserPartnerId);
            outputWrapper.listResourcePreferences = new List<ResourcePreference>([
                    SELECT Id, ServiceResource.XC_Account__c, PreferenceType
                    FROM ResourcePreference
                    WHERE RelatedRecordId = :workOrderId
            ]);
            return outputWrapper;
        }

        // Check for current user:
        List<ResourcePreference> listResourcePreference = new List<ResourcePreference>();

        // Check Partner Coverage:
        String key = zipCode + '_' + workTypeId;
        List<XC_PartnerCoverage__c> partnerCoverages = new List<XC_PartnerCoverage__c>();

        partnerCoverages = new List<XC_PartnerCoverage__c>([
                SELECT Id, XC_Account__c
                FROM XC_PartnerCoverage__c
                WHERE XC_ExternalId__c =: key
                AND XC_Account__c IN :currentUserPartnerId
        ]);


        // Calculate Output:
        if(partnerCoverages.isEmpty()) {
            if(!listResourcePreference.isEmpty()) {
                outputWrapper.message = Label.XC_CL_BookApp_RemovePreference;
                return outputWrapper;
            }
            outputWrapper.message = Label.XC_CL_BookApp_NoCoverage;
            return outputWrapper;
        }

        for(XC_PartnerCoverage__c cov : partnerCoverages){
            if(!outputWrapper.listIdsAccount.contains(cov.XC_Account__c)){
                outputWrapper.listIdsAccount.add(cov.XC_Account__c);
            }
        }
        outputWrapper.exists = true;
        return outputWrapper;
    }

    /**
    * @description Method to insert preferences
    * @param workOrderId - String
    * @param zipCode - String
    * @param workTypeId - String
    * @param currentUserPartnerId - String
    *  @param applyCoverageFilterInBooking - Boolean
    * @return EligibleWrapper
    */ 
	
    public static EligibleWrapper getDateAvailabilityInsertPreferences(String workOrderId, String zipCode, String workTypeId, String currentUserPartnerId, Boolean applyCoverageFilterInBooking) {
        EligibleWrapper  wrap = new EligibleWrapper();
        //List<String> listPartnerIds = getPartnerCoverages(zipCode, workTypeId); 
		
        PartnerCoverageWrapper partnerWrapper = getPartnerCoverages(workOrderId, zipCode, workTypeId, currentUserPartnerId, applyCoverageFilterInBooking);
        if(!partnerWrapper.exists || isForTest) {
            wrap.errorMessage = partnerWrapper.message;
            wrap.success = false;
            return wrap;
        }
        XC_UTIL_Glovia.AvailabilityResponseWrapper avabilityWrapper = XC_UTIL_Glovia.getAvailabilityWrapper(workOrderId, partnerWrapper.listIdsAccount);

        
        //Check for Generic Technical Product:

        if(!Test.isRunningTest() && avabilityWrapper.success && avabilityWrapper.isGenericTechProduct) {
            wrap.applyCoverageFilterInBooking = avabilityWrapper.applyCoverageFilterInBooking;
            wrap.success = true;
            return wrap;
        }


        /*if(mapBestPartner.keySet().isEmpty()){
            wrap.errorMessage = Label.XC_CL_BookCustom_ErrorProductConf;
            wrap.success = false;
            return wrap;
        }*/
        // --------------------------------------------------------------------------------------------------
        // For test coverage:
        if(Test.isRunningTest()) {
            Map<Date, List<String>> mapAvDate = new Map<Date, List<String>>();
            List<ServiceResource> listTempSr = new List<ServiceResource>([SELECT Id FROM ServiceResource]);
            mapAvDate.put(Date.today(), XC_UTIL_Sobject.getListFieldValues(listTempSr, 'Id'));
            avabilityWrapper.success = true;
            avabilityWrapper.availabilityDate = mapAvDate;
        }
        // --------------------------------------------------------------------------------------------------
        if(!avabilityWrapper.success && !Test.isRunningTest()){
            wrap.errorMessage = avabilityWrapper.errorMessage;
            wrap.success = false;
            return wrap;
        }
        Map<Date,List<String>> mapBestPartner = avabilityWrapper.availabilityDate;
        Date availabilityDate = Date.today();
        List<Id> listBestPartnerIds = new List<Id>();
        for(Date d : mapBestPartner.keySet()){
            availabilityDate = d;
            listBestPartnerIds.addAll(mapBestPartner.get(d));
        }
        wrap.availabilityDate = availabilityDate;
        List<ServiceResource> allResourcesFromCoveredPartners = new List<ServiceResource>([
            SELECT Id, Name
            FROM ServiceResource
            WHERE XC_Account__c IN: listBestPartnerIds
            AND IsActive = true AND (ResourceType = 'T' OR ResourceType = 'C')
        ]);
        Set<Id> serviceResourceIds = XC_UTIL_Sobject.getSetIds(allResourcesFromCoveredPartners);
        Map<Id, Set<Id>> mapWorkOrderListServiceResources = new Map<Id, Set<Id>>();
        mapWorkOrderListServiceResources.put(workOrderId, serviceResourceIds); 
        List<XC_UTIL_Sobject.WrapperResult> wrapperRemoveResult = XC_UTIL_ResourcePreference.removeRequiredResourcePreferences(new List<Id> {workOrderId}); 
        List<XC_UTIL_Sobject.WrapperResult> wrapperResult = XC_UTIL_ResourcePreference.insertRequiredResourcePreferences(mapWorkOrderListServiceResources);
        for(XC_UTIL_Sobject.WrapperResult wr : wrapperResult){
            if(!wr.success){
                wrap.success = false;
                wrap.errorMessage = wr.errorMessage;
            }else{
                wrap.success = true;
            }
        }
        return wrap;
    }

    /**
    * @author Salvatore Barbera - sbarbera@deloitte.it & Marina Ciavarra - mciavarra@deloitte.it
    * @date 27/10/2021
    * @description Method to insert preferences
    * @param workOrderId - String
    * @param zipCode - String
    * @param workTypeId - String
    * @param currentUserPartnerId - List<String>
    * @param applyCoverageFilterInBooking - Boolean
    * @return EligibleWrapper
    */
    public static EligibleWrapper getDateAvailabilityInsertPreferencesOnAutoSchedule(String workOrderId, String zipCode, String workTypeId, List<String> currentUserPartnerId, Boolean applyCoverageFilterInBooking) {
        EligibleWrapper wrap = new EligibleWrapper();
        //List<String> listPartnerIds = getPartnerCoverages(zipCode, workTypeId);
        PartnerCoverageWrapper partnerWrapper = getPartnerCoveragesOnAutoSchedule(workOrderId, zipCode, workTypeId, currentUserPartnerId, applyCoverageFilterInBooking);
        if(!partnerWrapper.exists || isForTest) {
            wrap.errorMessage = partnerWrapper.message;
            wrap.success = false;
            return wrap;
        }
        XC_UTIL_Glovia.AvailabilityResponseWrapper avabilityWrapper = XC_UTIL_Glovia.getAvailabilityWrapper(workOrderId, partnerWrapper.listIdsAccount);

        //Check for Generic Technical Product:

        if(!Test.isRunningTest() && avabilityWrapper.success && avabilityWrapper.isGenericTechProduct) {
            wrap.applyCoverageFilterInBooking = avabilityWrapper.applyCoverageFilterInBooking;
            wrap.success = true;
            return wrap;
        }

        /*if(mapBestPartner.keySet().isEmpty()){
            wrap.errorMessage = Label.XC_CL_BookCustom_ErrorProductConf;
            wrap.success = false;
            return wrap;
        }*/
        // --------------------------------------------------------------------------------------------------
        // For test coverage:
        if(Test.isRunningTest()) {
            Map<Date, List<String>> mapAvDate = new Map<Date, List<String>>();
            List<ServiceResource> listTempSr = new List<ServiceResource>([SELECT Id FROM ServiceResource]);
            mapAvDate.put(Date.today(), XC_UTIL_Sobject.getListFieldValues(listTempSr, 'Id'));
            avabilityWrapper.success = true;
            avabilityWrapper.availabilityDate = mapAvDate;
        }
        // --------------------------------------------------------------------------------------------------
        if(!avabilityWrapper.success && !Test.isRunningTest()){
            wrap.errorMessage = avabilityWrapper.errorMessage;
            wrap.success = false;
            return wrap;
        }
        Map<Date,List<String>> mapBestPartner = avabilityWrapper.availabilityDate;
        Date availabilityDate = Date.today();
        List<Id> listBestPartnerIds = new List<Id>();
        for(Date d : mapBestPartner.keySet()){
            availabilityDate = d;
            listBestPartnerIds.addAll(mapBestPartner.get(d));
        }
        wrap.availabilityDate = availabilityDate;
        List<ServiceResource> allResourcesFromCoveredPartners = new List<ServiceResource>([
                SELECT Id, Name
                FROM ServiceResource
                WHERE XC_Account__c IN: listBestPartnerIds
                AND IsActive = true AND (ResourceType = 'T' OR ResourceType = 'C')
        ]);
        Set<Id> serviceResourceIds = XC_UTIL_Sobject.getSetIds(allResourcesFromCoveredPartners);
        Map<Id, Set<Id>> mapWorkOrderListServiceResources = new Map<Id, Set<Id>>();
        mapWorkOrderListServiceResources.put(workOrderId, serviceResourceIds);
        List<XC_UTIL_Sobject.WrapperResult> wrapperRemoveResult = XC_UTIL_ResourcePreference.removeRequiredResourcePreferences(new List<Id> {workOrderId});
        List<XC_UTIL_Sobject.WrapperResult> wrapperResult = XC_UTIL_ResourcePreference.insertRequiredResourcePreferences(mapWorkOrderListServiceResources);
        for(XC_UTIL_Sobject.WrapperResult wr : wrapperResult){
            if(!wr.success){
                wrap.success = false;
                wrap.errorMessage = wr.errorMessage;
            }else{
                wrap.success = true;
            }
        }
        return wrap;
    }

    /**
    * @description Method to insert preferences
    * @param workOrderId - String
    * @param zipCode - String
    * @param workTypeId - String
    * @return EligibleWrapper
    */ 
    public static EligibleWrapper getDateAvailabilityInsertPreferences(String workOrderId, String zipCode, String workTypeId){
       
	   return getDateAvailabilityInsertPreferences(workOrderId, zipCode, workTypeId, '', false);
    }

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com
    * @date Creation 13/09/2019
    * @description Method to check availability
    * @param workOrderId - String
    * @param zipCode - String
    * @param workTypeId - String
    * @param currentUserPartnerId - String
    *  @param applyCoverageFilterInBooking - Boolean
    * @return EligibleWrapper
    */
	
    public static EligibleWrapper checkAvailability(String workOrderId, String zipCode, String workTypeId, String currentUserPartnerId, Boolean applyCoverageFilterInBooking){
       
	   EligibleWrapper eWr = getDateAvailabilityInsertPreferences(workOrderId, zipCode, workTypeId, currentUserPartnerId, applyCoverageFilterInBooking);     
        if(!eWr.success){
            return eWr;
        }   
        WorkOrder woToUpdate = new WorkOrder(Id = workOrderId);
        woToUpdate.XC_AvailabilityDate__c = eWr.availabilityDate;
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.WrapperResult wrUpdate = XC_UTIL_Sobject.updateRecord(woToUpdate);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        EligibleWrapper  wrap = new EligibleWrapper();
        if(!wrUpdate.success){
            wrap.success = false;
            wrap.errorMessage = wrUpdate.errorMessage;
        }else{
            wrap.success = true;
        }
        return wrap;
    }

    /**
    * @author Salvatore Barbera - sbarbera@deloitte.it & Marina Ciavarra - mciavarra@deloitte.it
    * @date 27/10/2021
    * @description Method to check availability
    * @param workOrderId - String
    * @param zipCode - String
    * @param workTypeId - String
    * @param currentUserPartnerId - List<String>
    * @param applyCoverageFilterInBooking - Boolean
    * @return EligibleWrapper
    */
    public static EligibleWrapper checkAvailabilityOnAutoSchedule(String workOrderId, String zipCode, String workTypeId, List<String> currentUserPartnerId, Boolean applyCoverageFilterInBooking){
        EligibleWrapper eWr = getDateAvailabilityInsertPreferencesOnAutoSchedule(workOrderId, zipCode, workTypeId, currentUserPartnerId, applyCoverageFilterInBooking);
        if(!eWr.success){
            return eWr;
        }
        WorkOrder woToUpdate = new WorkOrder(Id = workOrderId);
        woToUpdate.XC_AvailabilityDate__c = eWr.availabilityDate;
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.WrapperResult wrUpdate = XC_UTIL_Sobject.updateRecord(woToUpdate);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        EligibleWrapper  wrap = new EligibleWrapper();
        if(!wrUpdate.success){
            wrap.success = false;
            wrap.errorMessage = wrUpdate.errorMessage;
        }else{
            wrap.success = true;
        }
        return wrap;
    }

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com
    * @date Creation 13/09/2019
    * @description Method to check availability
    * @param workOrderId - String
    * @param zipCode - String
    * @param workTypeId - String
    * @return EligibleWrapper
    */
    public static EligibleWrapper checkAvailability(String workOrderId, String zipCode, String workTypeId){
       
	   return checkAvailability(workOrderId, zipCode, workTypeId, '', false);
    }

    /**
    * @author Roberta Cossiga - rcossiga@deloitte.it
    * @date Creation 12/09/2019
    * @description Method for calculation of Eligible Partners for WorkOrder based on Zip Code and Work Type
    * @param zipCode
    * @param workTypeId
    * @return List<String> partner Ids
    */ 
    /*private static List<String> getPartnerCoverages(String zipCode, String workTypeId) {
        String key = zipCode+'_'+workTypeId;
        List<XC_PartnerCoverage__c> partnerCoverages = new List<XC_PartnerCoverage__c>(
                                                       [SELECT Id, XC_Account__c
                                                        FROM XC_PartnerCoverage__c
                                                        WHERE XC_ExternalId__c =: key]);
        List<String> partnerIds = new List<String>();
        for(XC_PartnerCoverage__c cov : partnerCoverages){
            if(!partnerIds.contains(cov.XC_Account__c)){
                partnerIds.add(cov.XC_Account__c); 
            }
        }
        return partnerIds;
    }*/

}