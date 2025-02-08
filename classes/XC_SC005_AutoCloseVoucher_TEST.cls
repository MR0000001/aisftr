/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 31/05/2019
* @description XC_SC005_AutoCloseVoucher_TEST – Test class for XC_SC005_AutoCloseVoucher
*/ 

@isTest
private class XC_SC005_AutoCloseVoucher_TEST {
    static testMethod void extecuteBatch() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<XC_Voucher__c> listVoucher = XC_DF_Voucher.generateSingleVoucher(1);
        listVoucher[0].XC_GenerateMultipleVoucher__c = true;
        listVoucher[0].XC_Voucher_To_Be_Created__c = 0;
        listVoucher[0].XC_EndDate__c = Date.today().addDays(-1);
        insert listVoucher;
        System.assertEquals(2, Limits.getDmlStatements());
        
        Test.startTest();
        Database.executeBatch(new XC_SC005_AutoCloseVoucher(), 1);
		Test.stopTest();        
    }
}