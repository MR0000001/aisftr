/**
 * @description       : Test Class for XC_LCC196_RetryQRS 
 * @author            : Marco Ottaviano mottaviano@deloitte.it
 * @group             : 
 * @last modified on  : 
 * @last modified by  : 
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   14-07-2020   Marco Ottaviano mottaviano@deloitte.it   Initial Version
**/

@isTest
public without sharing class XC_LCC196_RetryQRS_TEST {
    @TestSetup
    static void makeData(){
        List<XC_QueuedRequest__c> qRlist = XC_DF_QueuedRequest.createQueuedRequest(1);
        insert qRlist;
    }

    @isTest
    static void testRetry() {

        XC_QueuedRequestStep__c qrs=[SELECT Id FROM XC_QueuedRequestStep__c LIMIT 1];

        Test.startTest();
            XC_LCC196_RetryQRS.retryCurrentQRS(qrs.Id);
        Test.stopTest();
    }
}