/**
* @author Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation  04/02/2020 
* @description XC_TR_Lead_U_CheckStatus_TEST – Test class for XC_TR_Lead_U_CheckStatus
*/ 
@isTest
private class XC_TR_Campaign_TEST {

    @isTest
    private static void checkVoucherEmpty() {
        Campaign c = new Campaign();
        c.Name = 'Super Sconti';
        String test = '';
        try{
            insert c; 
            test = 'OK';
        } catch (Exception e){
            test = 'KO';
        }
        System.assertEquals('OK', test);
        delete c;
    }
  
    @isTest
    private static void checkVoucherCouponCode() {
        XC_Voucher__c v = new XC_Voucher__c();
        v.XC_StartDate__c = date.newInstance(2020, 01, 21);
        v.XC_EndDate__c = date.newInstance(2040, 01, 21);
        v.XC_VoucherCode__c = 'ABC pippo';
        insert v;
        Campaign c = new Campaign();
        c.Name = 'Super Sconti';
        c.XC_Code__c = 'ABC pippo';
        String test = '';
        try{
            insert c; 
            test = 'OK';
        } catch (Exception e){
            test = 'KO';
        }
        System.assertEquals('OK', test);
    }
    
    @isTest
    private static void checkVoucherupdatesuccess() {
        Campaign c = new Campaign();
        c.Name = 'Super Sconti';
        insert c; 
        XC_Voucher__c v = new XC_Voucher__c();
        v.XC_StartDate__c = date.newInstance(2020, 01, 21);
        v.XC_EndDate__c = date.newInstance(2040, 01, 21);
        v.XC_VoucherCode__c = 'ABC pippo';
        insert v;
        c.XC_Code__c = 'ABC pippo';
        String test = '';
        try{
            update c; 
            test = 'OK';
        } catch (Exception e){
            test = 'KO';
        }
        System.assertEquals('KO', test);
    }

    @isTest
    private static void checkVoucherupdatefail() {
        Campaign c = new Campaign();
        c.Name = 'Super Sconti';
        c.isActive = true;
        insert c; 
        XC_Voucher__c v = new XC_Voucher__c();
        v.XC_StartDate__c = date.newInstance(2020, 01, 21);
        v.XC_EndDate__c = date.newInstance(2040, 01, 21);
        v.XC_VoucherCode__c = 'ABC pippo';
        insert v;
        c.XC_Code__c = 'ABC pippo';
        String test = '';
        try{
            update c; 
            test = 'OK';
        } catch (Exception e){
            test = 'KO';
        }
        System.assertEquals('KO', test);
    }
}