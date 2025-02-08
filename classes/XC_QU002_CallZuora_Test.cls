/**
 * @description       : XC_QU002_CallZuora unit tests class
 * @author            : neeraj.saini@accenture.com
**/
@isTest
public with sharing class XC_QU002_CallZuora_Test {
    
    @testSetup static void setup() {       
        List<NE__Billing_Profile__c> billingProfile = XC_DF_BillingProfile.createBillingProfile(1);   
    }
    
    @IsTest
    static void methodTestQueueable(){
        Map<String,String> zuoraMap = new Map<String,String>();
        XC_BillingProfileLineItem__c bpli = [SELECT id from XC_BillingProfileLineItem__c LIMIT 1];
        zuoraMap.put('billingProfLineItemId',bpli.id);
        Test.startTest();
        System.enqueueJob(new XC_QU002_CallZuora(zuoraMap,true));
        Test.stopTest();
        
    }
}