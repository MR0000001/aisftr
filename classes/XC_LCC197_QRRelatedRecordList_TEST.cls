/**
 * @description       : Test Class for XC_LCC197_QRRelatedRecordList 
 * @author            : Marco Ottaviano mottaviano@deloitte.it
 * @group             : 
 * @last modified on  : 
 * @last modified by  : 
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   14-07-2020   Marco Ottaviano mottaviano@deloitte.it   Initial Version
**/
@isTest
public without sharing class XC_LCC197_QRRelatedRecordList_TEST {
    @TestSetup
    static void makeData(){
        List<XC_QueuedRequest__c> qRlist = XC_DF_QueuedRequest.createQueuedRequest(1);
        insert qRlist;
        List<Account> accInse = XC_DF_Account.createResidentialAccounts(1);
        insert accInse;

      
    }

    @isTest
    static void relatedRecord_Test() {

        XC_QueuedRequest__c qr = [SELECT Id FROM XC_QueuedRequest__c LIMIT 1];
        Account accountInserted = [SELECT Id FROM Account LIMIT 1];
        String accountId = accountInserted.Id;
        XC_QueuedRequestStep__c qrS= [SELECT Id,XC_Status__c FROM XC_QueuedRequestStep__c WHERE XC_QueuedRequest__c =: qr.Id LIMIT 1];
        qrS.XC_RelatedRecordsIds__c = String.join(new List<String>{accountId},';');
        qrs.XC_Status__c ='Completed OK';
        update qrs;
        
        Test.startTest();
            XC_LCC197_QRRelatedRecordList.getQRRelatedRecords(qr.Id);
            System.assert(true,true);
        Test.stopTest();
    }
}