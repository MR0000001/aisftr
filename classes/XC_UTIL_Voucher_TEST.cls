/**
* @author Roberta Porrega - roberta.porrega@nttdata.com  
* @date Creation 20/05/2019 
* @description XC_UTIL_Voucher_TEST – Test class 
*/
@isTest
private  class XC_UTIL_Voucher_TEST {
    
	 static testMethod void onInsert() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_Voucher__c v = new XC_Voucher__c();
        v.Name = 'voucher';
        v.XC_Status__c = 'ACTIVE';
        v.XC_StartDate__c = Date.newInstance(2019, 05, 22);
        v.XC_EndDate__c = Date.newInstance(2040, 05, 26);
        v.XC_Voucher_To_Be_Created__c = 3;
        v.XC_Type_of_Discount__c = 'Percentage';
        v.XC_Amount__c = 50;
        v.XC_GenerateMultipleVoucher__c = true;
       
        System.assertEquals(true, v.XC_GenerateMultipleVoucher__c);
        
        Test.startTest();
        XC_UTIL_Voucher.generateCouponCode(1);
        XC_UTIL_Voucher.createNvoucherFromSingleVoucher(v);
        insert v;
		Test.stopTest();        
    }
}