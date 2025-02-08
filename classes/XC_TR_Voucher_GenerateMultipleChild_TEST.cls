/**
* @author Roberta Porrega - roberta.porrega@nttdata.com  
* @date Creation 20/05/2019 
* @description XC_TR_Voucher_GenerateMultipleChild_TEST 
*/
@isTest
private class XC_TR_Voucher_GenerateMultipleChild_TEST {
    
    static testMethod void onMultipleVoucherInsert() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        
        XC_Voucher__c v = new XC_Voucher__c();
        v.Name = 'Test dev';
        v.XC_Status__c = 'ACTIVE';
        v.XC_StartDate__c = Date.newInstance(2019, 05, 22);
        v.XC_EndDate__c = Date.newInstance(2040, 05, 26);
        v.XC_Voucher_To_Be_Created__c = 3;
        v.XC_Type_of_Discount__c = 'Percentage';
        v.XC_Amount__c = 50;
        insert v;
         
        List< XC_Voucher__c > vouchList = [SELECT Id,XC_Status__c FROM XC_Voucher__c ];
        System.assertEquals('Active', vouchList[0].XC_Status__c);
    }
    }