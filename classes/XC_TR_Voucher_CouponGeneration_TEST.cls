/**
* @author Roberta Porrega - roberta.porrega@nttdata.com  
* @date Creation 20/05/2019 
* @description XC_TR_Voucher_CouponGeneration_TEST – Test class 
*/
@isTest
private  class XC_TR_Voucher_CouponGeneration_TEST {
	 
    static testMethod void manageInsertCouponGeneration() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        
        XC_Voucher__c v = new XC_Voucher__c();
        v.Name = 'voucher';
        v.XC_Status__c = 'ACTIVE';
        v.XC_StartDate__c = Date.newInstance(2019, 05, 22);
        v.XC_EndDate__c = Date.newInstance(2040, 05, 26);
        v.XC_Voucher_To_Be_Created__c = 3;
        v.XC_Type_of_Discount__c = 'Percentage';
        v.XC_Amount__c = 50;
        v.XC_GenerateMultipleVoucher__c = true;
        v.RecordTypeId  = Schema.SObjectType.XC_Voucher__c.getRecordTypeInfosByDeveloperName().get('XC_Voucher_General').getRecordTypeId();
        v.XC_ParentVoucher__c = null;
        v.XC_Unlimited__c = true;
        insert v;
        System.debug('RecordType: '+ v.RecordTypeId);
        System.debug('XC_RecordTypeName__c : '+ v.XC_RecordTypeName__c);

        
        XC_Voucher__c vChield = new XC_Voucher__c();
        vChield.Name = 'voucher';
        vChield.XC_Status__c = 'ACTIVE';
        vChield.XC_StartDate__c = Date.newInstance(2019, 05, 22);
        vChield.XC_EndDate__c = Date.newInstance(2040, 05, 26);
        vChield.XC_Voucher_To_Be_Created__c = 2;
        vChield.XC_Type_of_Discount__c = 'Percentage';
        vChield.XC_Amount__c = 20;
        vChield.XC_GenerateMultipleVoucher__c = true;
        vChield.RecordTypeId  = Schema.SObjectType.XC_Voucher__c.getRecordTypeInfosByDeveloperName().get('XC_Voucher_General').getRecordTypeId();
        vChield.XC_ParentVoucher__c = v.Id;
        vChield.XC_Unlimited__c = true;
        insert vChield;

        List< XC_Voucher__c > vouchList = [SELECT Id,XC_Status__c FROM XC_Voucher__c LIMIT 1];
        System.assertEquals('Active', vouchList[0].XC_Status__c);
    }
}