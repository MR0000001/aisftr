@isTest
public class XC_LCC132_CallToCommodityContract_TEST {
    
    @isTest
	static void manageGetContractResponse(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Map<String,String> inputData = new Map<String,String>();
        inputData.put('ContractNumber','1234567890');
        Map<String,String> addrData = new Map<String,String>();
        Test.startTest();
        XC_LCC005_AccountCallToCommodity.ResultWrapper rw = XC_LCC132_CallToCommodityContract.manageGetContractResponse(new List<Object>{inputData}, addrData);
        System.assert(rw.success);
        Test.stopTest();
    }
    
    @isTest
	static void callReadInvoicePDF(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Map<String,String> inputData = new Map<String,String>();
        inputData.put('InvoiceNumber','1234567890');
        String inputDataStr = JSON.serialize(inputData);
        String inputDataStrStr = JSON.serialize(inputDataStr);
        Test.startTest();
        XC_UTIL_ResultWrapper rw = XC_LCC132_CallToCommodityContract.callReadInvoicePDF(inputDataStrStr,'Spain');
        System.assert(!rw.success);
        Test.stopTest();
    }
    
    @isTest
	static void manageInvoiceListResponse(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_REST_Invoice_W.InvoiceWrapper invoiceData = new XC_REST_Invoice_W.InvoiceWrapper();
        XC_UTIL_Address.AddressWrapper addr = new XC_UTIL_Address.AddressWrapper();
        addr.StreetType = 'via';
        addr.Street = 'milazzo';
        addr.StreetNumber = '33';
        addr.City = 'latina';
        invoiceData.Address = addr;
        Test.startTest();
        XC_LCC005_AccountCallToCommodity.ResultWrapper rw = XC_LCC132_CallToCommodityContract.manageInvoiceListResponse(new List<XC_REST_Invoice_W.InvoiceWrapper>{invoiceData});
        System.assert(rw.success);
        Test.stopTest();
    }
    
    @isTest
	static void manageGetCaseResponse(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_UTIL_Case.CaseRESTWrapper commodityCase = new XC_UTIL_Case.CaseRESTWrapper();
        Map<String,String> addrData = new Map<String,String>();
        Test.startTest();
        XC_LCC005_AccountCallToCommodity.ResultWrapper rw = XC_LCC132_CallToCommodityContract.manageGetCaseResponse(new List<XC_UTIL_Case.CaseRESTWrapper> {commodityCase}, addrData);
        System.assert(rw.success);
        Test.stopTest();
    }
	
    /*static testMethod void callCommodityEmptyDoc(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        account[0].IdentityType__c = '';
        account[0].IdentityNumber__c = '';
        insert account;
        
        //XC_LCC005_AccountCallToCommodity.ResultWrapper rw1= XC_LCC132_CallToCommodityContract.callCommodityContract(account[0].Id, '');
        //XC_LCC005_AccountCallToCommodity.ResultWrapper rw2 = XC_LCC132_CallToCommodityContract.callCommodityReadCase(account[0].Id, '');
        //XC_LCC005_AccountCallToCommodity.ResultWrapper rw3 = XC_LCC132_CallToCommodityContract.callCommodityInvoice(account[0].Id, '');
        //System.assert(!rw1.success && !rw2.success && !rw3.success);
        Test.stopTest();
    }
    
    static testMethod void callCommodityContract(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        account[0].IdentityNumber__c = '41550260R';
        account[0].IdentityType__c = 'NIF';
        insert account;
        
        //XC_LCC005_AccountCallToCommodity.ResultWrapper rw = XC_LCC132_CallToCommodityContract.callCommodityContract(account[0].Id, 'Account');
        //System.assert(rw.success);
        Test.stopTest();
    }
    
    static testMethod void callCommodityCase(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        account[0].IdentityNumber__c = '41550260R';
        account[0].IdentityType__c = 'NIF';
        insert account;
        
        //XC_LCC005_AccountCallToCommodity.ResultWrapper rw = XC_LCC132_CallToCommodityContract.callCommodityReadCase(account[0].Id, 'Account');
        //System.assert(rw.success);
        Test.stopTest();
    }
    
    static testMethod void callCommodityInvoice(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        account[0].IdentityNumber__c = '41550260R';
        account[0].IdentityType__c = 'NIF';
        insert account;
        
        //XC_LCC005_AccountCallToCommodity.ResultWrapper rw = XC_LCC132_CallToCommodityContract.callCommodityInvoice(account[0].Id, 'Account');
        //System.assert(rw.success);
        Test.stopTest();
    }*/
   
}