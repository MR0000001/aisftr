/**
* @author Marina Ciavarra - mciavarra@deloitte.it
* @date Creation 25/05/2021
* @description XC_SC056_ActivateBillingProfile_TEST – Test class for XC_SC056_ActivateBillingProfile
*/

@isTest
public class XC_SC056_ActivateBillingProfile_TEST {

    @isTest
    static void testBatch(){

        List<NE__Billing_Profile__c> listBP = XC_DF_BillingProfile.createBillingProfile(1);
        XC_BillingProfileLineItem__c bpli = [SELECT id, XC_Status__c, XC_BillingProfile__c, XC_BillingProfile__r.NE__Account__c FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__c = :listBP[0].id LIMIT 1];
        Zuora__CustomerAccount__c zuoraCA = new Zuora__CustomerAccount__c();
        zuoraCA.Name = 'BillingAccountTEST ';
        zuoraCA.Zuora__Zuora_Id__c = '8adcfb506ad3cb6f016ad55dabed7f1a';
        zuoraCA.Zuora__Account__c = bpli.XC_BillingProfile__r.NE__Account__c;
        zuoraCA.otherPaymentMethodType__c = 'Other';
        zuoraCA.XC_BillingProfLineItem_LookUp__c =bpli.ID;
        insert zuoraCA;

        bpli.XC_Status__c = 'Sent to Zuora';
        update bpli;
        
        Test.startTest();
        String chron = '0 0 23 * * ?';
        system.schedule('Test Sched053', chron,  new XC_SC056_ActivateBillingProfile());
        Test.stopTest();
    }

}