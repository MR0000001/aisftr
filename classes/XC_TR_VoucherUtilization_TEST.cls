/**
* @author Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation  06/02/2020 
* @description XC_TR_VoucherUtilization_TEST – Test class for XC_TR_VoucherUtilization_U_changeStatus
*/ 
@isTest
public class XC_TR_VoucherUtilization_TEST {
        
    @isTest 
    static void vuTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        XC_Voucher__c v = new XC_Voucher__c();
        v.XC_Uses__c = 10;
        v.XC_Usage_Counter__c = 11;
        Id recordTypeId = Schema.SObjectType.XC_Voucher__c.getRecordTypeInfosByName().get('Campaign General Voucher').getRecordTypeId();
        v.RecordTypeId = recordTypeId;
        v.XC_LegalEntity__c='EndesaX';
        insert v;
        
        List<Account> a = XC_DF_Account.createResidentialAccounts(1);
        insert(a);
        
		XC_VoucherUtilization__c vu = new XC_VoucherUtilization__c();
        vu.XC_Voucher__c = v.id;
        vu.XC_Account__c = a[0].id;
        insert vu;
        update vu;
        delete vu;
    }
}