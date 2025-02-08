public without sharing class Giic_LCC017_TransferOrderPath {
    
    
    @AuraEnabled
    public static XC_UTIL_ResultWrapper saveStatus(String recordId, String stepName){
        
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        gii__TransferOrder__c t = new gii__TransferOrder__c(id=recordId,giic_status__c=stepName);
        rw = XC_UTIL_Glovia.updateRecord(t);
        return rw;
    }

}