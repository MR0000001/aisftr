public without sharing class TA_LCC999_CreateNewLead {

    @AuraEnabled
    public static String initialize() {
        String recordTypeIdToReturn;
        List<RecordType> residentialLeadRTList = [SELECT Id FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'XC_GLO_Lead_Residential' LIMIT 1];
        
        if(!residentialLeadRTList.isEmpty()){
            recordTypeIdToReturn = residentialLeadRTList[0].Id;
            return recordTypeIdToReturn;
        }

        return recordTypeIdToReturn;
    }
}