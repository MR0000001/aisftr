/**
* @author Federico Amici - federico.amici@nttdata.com   
* @date Creation 06/06/2019
* * @date Last Modification 13/06/2019 - Marco Ottaviano mottaviano@deloitte.it -
* @description XC_UTIL_NextStepOrderToProvisioning_TEST – Test class for XC_UTIL_NextStepOrderToProvisioning 
*/
@istest
public with sharing class XC_UTIL_NextStepOrderToProvisioning_TEST {
    
    @testSetup
    static void setup(){
        
        XC_DF_Order.createOrder('InOrder');
        
    }

    @isTest
    private static void testNextStep() {

       List< NE__Order__c> o = [SELECT Id FROM NE__Order__c LIMIT 1];

        Test.startTest();
            XC_UTIL_NextStepOrderToProvisioning.firstNextStep(o[0].Id);
            System.enqueueJob(new  XC_UTIL_NextStepOrderToProvisioning.SecondNextStepQueue(o[0].Id));
            System.enqueueJob(new  XC_UTIL_NextStepOrderToProvisioning.ThirdNextStepQueue(o[0].Id));
            System.assertEquals(o.size(),1);
        Test.stopTest();

    }
}