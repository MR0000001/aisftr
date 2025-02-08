/**
* @author Marina Ciavarra - mciavarra@deloitte.it
* @date Creation 08/02/2021
* @description XC_SC040_CheckDocumentationsValidity – Set expired document if the current date is past the expiration date
*/

public with sharing class XC_SC040_CheckDocumentationsValidity implements Schedulable, Database.Batchable<sObject>  {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC040_CheckDocumentationsValidity');
    /**
        * @author Marina Ciavarra - mciavarra@deloitte.it
        * @description start
        * @param bc - BatchableContext 
        * @return Database.getQueryLocator
       */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        if(!Schema.sObjectType.Account.isAccessible()){
            return null;
        }
        String query =  'SELECT Id, XC_Account__c, XC_Contact__c, XC_Account__r.XC_CompanyDocumentsStatus__c, XC_Contact__r.AccountId, XC_Contact__r.Account.XC_WorkerDocumentsStatus__c ' +
                        ' FROM XC_DocumentType__c ' +
                        ' WHERE XC_ExpirationDate__c < TODAY'+
                        ' AND( XC_Account__r.XC_RecordTypeDeveloperName__c= \'' + Label.XC_CL_Account_Partner + '\''+ 
                        ' OR XC_Contact__r.XC_RecordTypeDeveloperName__c= \'' + Label.XC_CL_Contact_Partner + '\')';
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'query' + query);              
        return Database.getQueryLocator(query);
    }

    /**
    * @description execute method
    * @param sc - SchedulableContext
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC040_CheckDocumentationsValidity());
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'batch XC_SC040_CheckDocumentationsValidity ' + batchId); 
    }

    /** 
    * @description execute method
    * @param bc - BatchableContext 
    * @param scope - list to execute logic on
   */
    public void execute(Database.BatchableContext bc, List<XC_DocumentType__c> scope) {
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();  
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'scope ' + scope); 
        List<Account> accListToUpdate = new List<Account>();

        for(XC_DocumentType__c document : scope){
            if(String.isNotEmpty(document.XC_Account__c)){
                if (!document.XC_Account__r.XC_CompanyDocumentsStatus__c.equals(Label.XC_CL_Account_ExpiredDocuments)){
                    Account acc = new Account();
                    acc.Id = document.XC_Account__c;
                    acc.XC_CompanyDocumentsStatus__c = Label.XC_CL_Account_ExpiredDocuments;
                    accListToUpdate.add(acc);
                }
            }
            if(String.isNotEmpty(document.XC_Contact__c)){
                if (!document.XC_Contact__r.Account.XC_WorkerDocumentsStatus__c.equals(Label.XC_CL_Account_ExpiredDocuments)){
                    Account acc = new Account();
                    acc.Id = document.XC_Contact__r.AccountId;
                    acc.XC_WorkerDocumentsStatus__c = Label.XC_CL_Account_ExpiredDocuments;
                    accListToUpdate.add(acc);
                }
            }
        }

        List<XC_UTIL_Sobject.WrapperResult> listWrapperResult = XC_UTIL_Sobject.updateListRecords(accListToUpdate);
        for(XC_UTIL_Sobject.WrapperResult wr : listWrapperResult){
            if(!wr.success){
                XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                bel.Name = 'XC_SC040_CheckDocumentationsValidity';
                bel.XC_ErrorMessage__c = wr.errorMessage;
                bel.XC_TypeOfOperation__c = 'Set Expired Documents';
                bel.XC_RecordId__c = wr.errorObjectId;
                                    errorLog.add(bel);
            }
        }
        XC_UTIL_Sobject.insertListRecords(errorLog);
    }

    /** 
    * @description execute method
    * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch XC_SC040_CheckDocumentationsValidity ID');
    }
}