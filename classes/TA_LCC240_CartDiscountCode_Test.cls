@isTest
public with sharing class TA_LCC240_CartDiscountCode_Test {
    
    @isTest
    static void getVoucherCode_Test() {
          
        TA_LCC240_CartDiscountCode cdd = new TA_LCC240_CartDiscountCode();

        NE__Catalog__c catalog = new NE__Catalog__c();
        insert catalog;

        XC_Voucher__c voucher = new XC_Voucher__c();
        voucher.XC_StartDate__c = Date.today();
        voucher.XC_EndDate__c = Date.today();        
        voucher.XC_Type_of_Discount__c = 'Percentage';
        voucher.RecordTypeId = Schema.SObjectType.XC_Voucher__c.getRecordTypeInfosByDeveloperName().get('XC_Voucher_Individual').getRecordTypeId();
        voucher.XC_Status__c ='Active';
        voucher.XC_VoucherCode__c = '1234';
        voucher.XC_Catalog__c = catalog.Id;
        insert voucher;   
        Test.startTest();    
        TA_LCC240_CartDiscountCode.getVoucherCode('1234', catalog.Id);
        Test.stopTest();
    }
}