/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date 08/04/2020
 * @description XC_SC029_DeactiveConsent - Batch to deactive Legal Entity Consent
 */

public without sharing class XC_SC029_DeactiveConsent implements Schedulable, Database.Batchable<sObject> {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC029_DeactiveConsent');

    /**
     * @description execute method
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC029_DeactiveConsent());
    }

    /**
     * @description start method
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start batch XC_SC029_DeactiveConsent');
        String responseConsent = 'Yes';
        String query = 'SELECT Id, XC_ProfilingConsent__c, XC_MarketingConsent__c, XC_ExpirationDateMarketingConsent__c, XC_ExpirationDateProfilingConsent__c';
        query += ' FROM XC_LegalEntityConsent__c';
        query += ' WHERE (XC_ProfilingConsent__c = :responseConsent AND XC_ExpirationDateProfilingConsent__c < TODAY) OR (XC_MarketingConsent__c = :responseConsent AND XC_ExpirationDateMarketingConsent__c < TODAY)';
        return Database.getQueryLocator(query);
    }

    /** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - List<XC_LegalEntityConsent__c>
    */
    public void execute(Database.BatchableContext bc, List<XC_LegalEntityConsent__c> scope){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Execute batch XC_SC029_DeactiveConsent');
        List<XC_LegalEntityConsent__c> listLecToUpdate = new List<XC_LegalEntityConsent__c>();
        for(XC_LegalEntityConsent__c lec : scope) {
            XC_LegalEntityConsent__c lecToUpdate = new XC_LegalEntityConsent__c();
            lecToUpdate.Id = lec.Id;
            if(lec.XC_ProfilingConsent__c == Label.XC_CL_YesText && lec.XC_ExpirationDateProfilingConsent__c < Date.today()) {
                lecToUpdate.XC_ProfilingConsent__c = '';
                lecToUpdate.XC_ExpirationDateProfilingConsent__c = null;
            }
            if(lec.XC_MarketingConsent__c == Label.XC_CL_YesText && lec.XC_ExpirationDateMarketingConsent__c < Date.today()) {
                lecToUpdate.XC_MarketingConsent__c = '';
                lecToUpdate.XC_ExpirationDateMarketingConsent__c = null;
            }
            listLecToUpdate.add(lecToUpdate);
        }
        XC_UTIL_Sobject.updateListRecords(listLecToUpdate, false);
    }    

    /**
     * @description finish method
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ End batch XC_SC029_DeactiveConsent');
    } 

}