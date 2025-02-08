/**
* @author Nicola Mariniello - nmariniello@deloitte.it
* @date Creation 02/03/2021
* @description XC_SC041_SetSubscriptionName_TEST – Test class for XC_SC041_SetSubscriptionName
*/ 

@isTest
private class XC_SC041_SetSubscriptionName_TEST {
    static testMethod void extecuteBatch() {
        
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;

        Zuora__Subscription__c sub = new Zuora__Subscription__c();
        sub.Zuora__OriginalId__c = '123';
        sub.Zuora__PreviousSubscriptionId__c = '123';
        sub.Zuora__External_Id__c = '123';
        sub.Zuora__SubscriptionNumber__c = '123';
        sub.Zuora__Account__c = accList[0].Id;
        insert sub;
        
        Zuora__Subscription__c sub2 = new Zuora__Subscription__c();
        sub2.Zuora__OriginalId__c = '456';
        sub2.Zuora__PreviousSubscriptionId__c = '456';
        sub2.Zuora__External_Id__c = '456';
        sub2.Zuora__SubscriptionNumber__c = '456';
        sub2.Zuora__Account__c = accList[0].Id;
        insert sub2;

        zqu__Quote__c z = new zqu__Quote__c();
        z.zqu__ZuoraSubscriptionID__c = '123';
        z.zqu__Status__c = 'Sent to Z-Billing';
        z.zqu__Account__c = accList[0].Id;
        insert z;
        
        zqu__Quote__c z2 = new zqu__Quote__c();
        z2.zqu__ZuoraSubscriptionID__c = '123456';
        z2.XC_LastSubscriptionId__c = '456';
        z2.zqu__Status__c = 'Sent to Z-Billing';
        z2.zqu__Account__c = accList[0].Id;
        insert z2;

        Test.startTest();
        Database.executeBatch(new XC_SC041_SetSubscriptionName(), 2);
		Test.stopTest();
    }

}