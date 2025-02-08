/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 13/02/2019
* @date Modification 08/05/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_LCC084_AssignToBackOffice - Controller for XC_LCP084_AssignToBackOffice Component. This class is linked to a button o the Work Order
                                              to set to Excluded all the preferred resource of the same partner of the current user; moreover set to an queueu the ownership of the work order.
*/

public without sharing class XC_LCC084_AssignToBackOffice {

    /** @description ResultWrapper */
    public without sharing class ResultWrapper {
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String result = ''; 
    }

    /**
    *@author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    *@description Assignation to back office
    *@param recordId - Id
    *@return ResultWrapper
    */ 
    @AuraEnabled 
    public static ResultWrapper assignationToBackOffice(Id recordId){         
        ResultWrapper rw = new ResultWrapper();
        XC_UTIL_Sobject.WrapperResult wrResultCheck = checkRelatedExcludedPreferencies(recordId);
        List<WorkOrder> listWo = new List<WorkOrder>([
            SELECT Id, AccountId, ContactId, XC_LegalEntity__c
            FROM WorkOrder
            WHERE Id = :recordId
        ]);
        XC_UTIL_Sobject.WrapperResult wrResultSend = sendToBackOffice(listWo[0]); 
        XC_UTIL_Sobject.WrapperResult wrResultCase = XC_LCC033_RefuseServiceAppointment.createCaseForRefuse(listWo[0]); 
        if(wrResultCheck.success && wrResultSend.success && wrResultCase.success){
            rw.success = true;
        } else {
            rw.success = false;
        }
        return rw;
    }
 
    /**
     *@author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     *@description Check related excluded preferencies
     *@param recordId - Id
     *@return XC_UTIL_Sobject.WrapperResult
     */
    public static XC_UTIL_Sobject.WrapperResult checkRelatedExcludedPreferencies(Id recordId){
        String partnerAccountId;
        List<ResourcePreference> resourcePreferenceToUpdateList = new List<ResourcePreference>();
        User currentUser = getUserInformation();
        if(!currentUser.ServiceResources.isEmpty() && currentUser.ServiceResources[0] != null) {      
            partnerAccountId = currentUser.ServiceResources[0].XC_Account__c;
            
            Map<Id, ResourcePreference> excludedPreferenciesMap = new Map<Id, ResourcePreference>([SELECT Id, PreferenceType, ServiceResource.XC_Account__c
                                                            FROM ResourcePreference 
                                                            WHERE RelatedRecordId =: recordId 
                                                            AND PreferenceType != 'Excluded'
                                                            AND ServiceResource.XC_Account__c =: partnerAccountId  
                                                            ]);
            List<ResourcePreference> excludedPreferenciesList = excludedPreferenciesMap.values();

            for(ResourcePreference resource : excludedPreferenciesList){
                system.debug('resource.serviceResource.XC_Account__c -->' + resource.serviceResource.XC_Account__c);
                system.debug('partnerAccountId -->' + partnerAccountId);
                resource.PreferenceType = 'Excluded';
                resourcePreferenceToUpdateList.add(resource);
            } 
        }
        List<XC_UTIL_Sobject.WrapperResult> wrapperResult  = XC_UTIL_Sobject.updateListRecords(resourcePreferenceToUpdateList);
        return wrapperResult[0];                          
    } 

    /**
     *@author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     *@description Method to send WO to back office (by Country)
     *@param wo - WorkOrder
     *@return XC_UTIL_Sobject.WrapperResult
     */
    public static XC_UTIL_Sobject.WrapperResult sendToBackOffice(WorkOrder wo) {
        List<XC_CM_LegalEntity_Configuration__mdt> listCM = new List<XC_CM_LegalEntity_Configuration__mdt>([
            SELECT Id, XC_BODispatcherQueue__c  
            FROM XC_CM_LegalEntity_Configuration__mdt 
            WHERE XC_LegalEntity__c =: wo.XC_LegalEntity__c AND XC_BODispatcherQueue__c != null
        ]);
        if(!listCM.isEmpty()) {
            Map<String, String> mapQueue = XC_UTIL_WorkOrder.getMapQueueIds(new List<String>{listCM[0].XC_BODispatcherQueue__c});
            if(!mapQueue.values().isEmpty() && String.isNotBlank(mapQueue.values()[0])) {
                wo.OwnerId = mapQueue.values()[0];
            }
        }
        wo.ServiceTerritoryId = null;
        wo.XC_StatusReason__c = Label.XC_CL_StatusReason_NoAvailability;
        return XC_UTIL_Sobject.updateRecord(wo);
    }    

    /**
     *@author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     *@description Gets the user information
     *@return User 
     */
    public static User getUserInformation(){
        User currentUser = [SELECT Id,
                            (SELECT Id, XC_Account__c FROM ServiceResources)
                            FROM User 
                            WHERE Id =: UserInfo.getUserId()];
        return currentUser;
    }

}