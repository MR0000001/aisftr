/**
 * The Class XC_LCC006_AccountCreditCheck_TEST.
 *
 * @author Sara Miozza - sara.miozza@nttdata.com
 * @date Creation 15/05/2019
 * @description XC_LCC006_AccountCreditCheck_TEST – Test class for  XC_LCC006_AccountCreditCheck
 */

@isTest

public class XC_LCC006_AccountCreditCheck_TEST {
	@isTest
    static void callCommoditySuccessTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = 'Account';
        ic.XC_URL_Required__c = '';
        ic.XC_interfaceName__c = 'Account';
        insert ic;
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        Id recordId = accList[0].Id;        
        XC_LCC006_AccountCreditCheck.ResultWrapper rw = XC_LCC006_AccountCreditCheck.callCommodity(recordId);
        System.assert(rw.success);
        Test.stopTest();
        
    }
    
    @isTest
    static void callCommodityFailedTest(){
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        Id recordId = accList[0].Id;
        XC_LCC006_AccountCreditCheck.ResultWrapper rw = XC_LCC006_AccountCreditCheck.callCommodity(recordId);
        System.assert(rw.success);
        Test.stopTest();
        
    }


}