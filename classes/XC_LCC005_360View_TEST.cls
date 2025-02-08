@isTest
public class XC_LCC005_360View_TEST {

    @TestSetup
	static void setup(){
		OneOrg__c org            = new OneOrg__c(); 
	    org.Name                 = 'OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
	    insert org;
        
        List<XC_CS001_InterfaceConfiguration__c> interfaces = new List<XC_CS001_InterfaceConfiguration__c>();
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ReadAccountCommoditySpain;
        ic.XC_interfaceName__c = Label.XC_CL_ReadAccountCommoditySpain;
        ic.XC_ServerSystem__c = 'CommoditySpainB2C';
        ic.XC_Country__c = 'Spain';
        interfaces.add(ic);
        insert interfaces;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_ReadAccont_Mock());
    }
    
    @isTest
    static void callToCommodity_Account(){
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        Test.startTest();
            String result = XC_LCC005_360View.callToCommodity(acc[0].Id);
        	System.assert(result!=null);
        Test.stopTest();
    }
    
    @isTest
    static void callToCommodity_Account_Soho(){
        List<Account> acc = XC_DF_Account.createSohoAccounts(1);
        insert acc;
        Test.startTest();
            String result = XC_LCC005_360View.callToCommodity(acc[0].Id);
        	System.assert(result!=null);
        Test.stopTest();
    }
    
    @isTest
    static void callToCommodity_Lead(){
        List<Lead> leads = XC_DF_Lead.createResidentialLeads(1);
        leads[0].XC_DocumentNumber__c = '92343513P';
        leads[0].XC_DocumentType__c = 'NIF';
        leads[0].XC_DocumentCountry__c = 'Spain';
        insert leads;
        Test.startTest();
            String result = XC_LCC005_360View.callToCommodity(leads[0].Id);
        	System.assert(result!=null);
        Test.stopTest();
    }

    @isTest
    static void callToCommoditySecondPart() {
        List<Lead> leads = XC_DF_Lead.createResidentialLeads(1);
        insert leads;

        Test.startTest();
            XC_LCC005_AccountDataAccordion.ContinuationCommodityResult result = XC_LCC005_360View.callToCommoditySecondPart(leads[0].Id, '');
        	XC_LCC005_360View.ContinuationCommodityResult wrapper = new XC_LCC005_360View.ContinuationCommodityResult();
        	wrapper.message = '';
        	wrapper.sobjectId = '';
        	wrapper.identityNumber = '';
        	wrapper.commodityContractResult = '';
        	wrapper.commodityCaseResult = '';
        	wrapper.commodityInvoiceResult = '';
        	System.assert(!result.success);
        Test.stopTest();
    }
    
    @isTest
    static void areConsentsGiven(){
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        acc[0].XC_ConfirmationByCustomer__c = false;
        insert acc;
        Test.startTest();
            Boolean result = XC_LCC005_360View.areConsentsGiven(acc[0].Id);
        	System.assert(result);
        Test.stopTest();
    }
    
}