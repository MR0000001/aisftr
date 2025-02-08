/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 07-13-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   07-13-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
@isTest
public  class XC_TR_QueuedRequest_Handler_TEST {

     @TestSetup
     static void setup(){
        List<XC_QueuedRequest__c> qrList = XC_DF_QueuedRequest.createQueuedRequest(1);
        insert qrList;
     }

     @isTest
     static void testCreation(){
        Test.startTest();
            List<XC_QueuedRequest__c> qrList = [SELECT Id,(SELECT Id FROM QueuedRequestSteps__r) FROM XC_QueuedRequest__c LIMIT 1];
            System.assertEquals(1, qrList.size()); 
        Test.stopTest();
     }

     @isTest
     static void testUpdateOnStepOK(){
        List<XC_QueuedRequest__c> qrList = [SELECT Id,(SELECT Id FROM QueuedRequestSteps__r) FROM XC_QueuedRequest__c LIMIT 1];
        XC_QueuedRequestStep__c qrs = qrList[0].QueuedRequestSteps__r[0];
        qrs.XC_Status__c = 'Completed OK';

        Test.startTest();
            update qrs;
        Test.stopTest();

     }

     @isTest
     static void testUpdateOnStepKO(){
        List<XC_QueuedRequest__c> qrList = [SELECT Id,(SELECT Id FROM QueuedRequestSteps__r) FROM XC_QueuedRequest__c LIMIT 1];
        XC_QueuedRequestStep__c qrs = qrList[0].QueuedRequestSteps__r[0];
        qrs.XC_Status__c = 'Completed KO';

        Test.startTest();
            update qrs;
        Test.stopTest();

     }

     @isTest
     static void testUpdateCompleteAllStep(){

        List<XC_QueuedRequest__c> qrList = [SELECT Id,(SELECT Id FROM QueuedRequestSteps__r) FROM XC_QueuedRequest__c LIMIT 1];
        for(XC_QueuedRequestStep__c qrs : qrList[0].QueuedRequestSteps__r){
            qrs.XC_Status__c = 'Completed OK';
        }

        Test.startTest();
            update qrList[0].QueuedRequestSteps__r;
        Test.stopTest();

     }

     @isTest
     static void testUpdateOnSkipCallbackUpdateStep(){
        List<XC_QueuedRequest__c> qrList = [SELECT Id,(SELECT Id FROM QueuedRequestSteps__r) FROM XC_QueuedRequest__c LIMIT 1];
        XC_QueuedRequestStep__c qrs = qrList[0].QueuedRequestSteps__r[0];
        qrs.XC_Status__c = XC_UTIL_QueuedRequestStep.SKIP_TO_CALLBACK_STATUS;

        Test.startTest();
            update qrs;
        Test.stopTest();

     }
    
    
    @isTest
    static void test_getFirstQueuedRequestStep() {
         List<XC_QueuedRequest__c> qrList = [SELECT Id,(SELECT Id,XC_StepSequence__c,XC_QueuedRequest__c FROM QueuedRequestSteps__r) FROM XC_QueuedRequest__c LIMIT 1];
         XC_QueuedRequestStep__c qrs = qrList[0].QueuedRequestSteps__r[0];
        XC_QueuedRequestStep__c qrs1 = qrList[0].QueuedRequestSteps__r[1];
        XC_QueuedRequestStep__c qrs2 = qrList[0].QueuedRequestSteps__r[2];
        qrs2.XC_Status__c ='Completed KO';
        update qrs2;
        Test.startTest();
        	XC_UTIL_QueuedRequestStep.getFirstQueuedRequestStep(qrs);
        	XC_UTIL_QueuedRequestStep.getPreviousStep(qrs);
        	XC_UTIL_QueuedRequestStep.getPreviousStep(qrs1);
        	XC_UTIL_QueuedRequestStep.getFullStepInfo(qrs.Id);
        	XC_UTIL_QueuedRequestStep.getQueuedRequestSteps(qrs1,new Set<Integer>{0});
            XC_UTIL_QueuedRequestStep.getLastCompletedKOStep(qrList[0].Id);
        	XC_UTIL_QueuedRequestStep.skipNotCallbackSteps(qrs1);
        Test.stopTest();
    }


     

}