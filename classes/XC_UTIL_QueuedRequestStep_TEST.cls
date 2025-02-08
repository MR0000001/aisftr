/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 11-04-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   11-04-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
@isTest
public class XC_UTIL_QueuedRequestStep_TEST {

    @TestSetup
    static void setup(){
        List<XC_QueuedRequest__c> qrList = XC_DF_QueuedRequest.createQueuedRequest(1);
        insert qrList;

        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'InOrder';
        order.XC_Country__c = 'Spain';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EndesaX';
        order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        insert order;
    }

    @isTest
    static void getPreviousStep_TEST(){

        XC_QueuedRequestStep__c step = [SELECT Id,XC_StepSequence__c,XC_QueuedRequest__c FROM XC_QueuedRequestStep__c WHERE XC_StepSequence__c > 1 LIMIT 1];

        Test.startTest();
            XC_UTIL_QueuedRequestStep.getPreviousStep(step);
        Test.stopTest();

    }


    @isTest
    static void getFirstQueuedRequestStep_TEST(){

        XC_QueuedRequestStep__c step = [SELECT Id,XC_StepSequence__c,XC_QueuedRequest__c FROM XC_QueuedRequestStep__c WHERE XC_StepSequence__c > 1 LIMIT 1];

        Test.startTest();
            XC_UTIL_QueuedRequestStep.getFirstQueuedRequestStep(step);
        Test.stopTest();

    }


    @isTest
    static void getFullStepInfo_TEST(){

        XC_QueuedRequestStep__c step = [SELECT Id,XC_StepSequence__c,XC_QueuedRequest__c FROM XC_QueuedRequestStep__c  LIMIT 1];

        Test.startTest();
            XC_UTIL_QueuedRequestStep.getFullStepInfo(step.Id);
        Test.stopTest();

    }

    @isTest
    static void getQueuedRequestSteps_TEST(){

        XC_QueuedRequestStep__c step = [SELECT Id,XC_StepSequence__c,XC_QueuedRequest__c FROM XC_QueuedRequestStep__c WHERE XC_StepSequence__c > 1  LIMIT 1];

        Test.startTest();
            XC_UTIL_QueuedRequestStep.getQueuedRequestSteps(step,new Set<Integer>{1});
        Test.stopTest();

    }


    @isTest
    static void skipNotCallbackSteps_TEST(){

        XC_QueuedRequestStep__c step = [SELECT Id,XC_StepSequence__c,XC_QueuedRequest__c FROM XC_QueuedRequestStep__c WHERE XC_StepSequence__c > 1  LIMIT 1];

        Test.startTest();
            XC_UTIL_QueuedRequestStep.skipNotCallbackSteps(step);
        Test.stopTest();

    }

    @isTest
    static void getLastCompletedKOStep_TEST(){
        XC_QueuedRequest__c req = [SELECT Id FROM XC_QueuedRequest__c LIMIT 1];

        Test.startTest();
            XC_UTIL_QueuedRequestStep.getLastCompletedKOStep(req.Id);
        Test.stopTest();
    }
	
    
    @isTest
    static void initDisconnectCase_TEST(){
        Map<String,Object> utilMap = new Map<String,Object>();

        Test.startTest();
            XC_UTIL_QueuedRequestStep.initDisconnectCase(utilMap);
        Test.stopTest();
    }
    
    @isTest
    static void populateIntLog_TEST(){
        
        Map<String,Object> utilMap = new Map<String,Object>();
        XC_QueuedRequestStep__c step = [SELECT Id,XC_StepSequence__c,XC_QueuedRequest__c, XC_QueuedRequest__r.XC_ClientSystem__c, XC_QueuedRequest__r.XC_TransactionId__c FROM XC_QueuedRequestStep__c WHERE XC_StepSequence__c > 1  LIMIT 1];
        
        utilMap.put('currentStep', step);
        utilMap.put('intLog', new  XC_UTIL_IntegrationLog());
        utilMap.put('wrReq', new XC_REST_Order_U.WrapperPOSTRequest());
        

        Test.startTest();
            XC_UTIL_QueuedRequestStep.populateIntegrationLogInfo(utilMap);
        Test.stopTest();
    }
    
    @isTest
    static void externalDoc_TEST(){
        
        Map<String,Object> utilMap = new Map<String,Object>();
        NE__Order__c ord = [SELECT Id FROM NE__Order__c LIMIT 1];
        XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
        ordWr.Order = new XC_UTIL_Order.OrderIFWrapper();
        ordWr.Order.Document = new List<XC_UTIL_Order.DocumentWrapper>();
        utilMap.put('wrReq', ordWr);     

        Test.startTest();
            XC_UTIL_QueuedRequestStep.manageExternalDocument(ord.id, utilMap);
        Test.stopTest();
    }

    @isTest
    static void updateOrd_TEST(){
        
        Map<String,Object> utilMap = new Map<String,Object>();
        NE__Order__c ord = [SELECT Id FROM NE__Order__c LIMIT 1];  
        XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
        ordWr.Order = new XC_UTIL_Order.OrderIFWrapper();
        utilMap.put('wrReq', ordWr);           

        Test.startTest();
            XC_UTIL_QueuedRequestStep.updateFieldsonOrder(ord.id, utilMap);
        Test.stopTest();
    }


}