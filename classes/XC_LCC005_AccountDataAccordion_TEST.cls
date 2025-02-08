@isTest
public class XC_LCC005_AccountDataAccordion_TEST {


    @TestSetup
    static void makeData(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 

        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        account[0].IdentityNumber__c = '41550260R';
        account[0].IdentityType__c = 'NIF';
        insert account;
    }

      @isTest
    static void callToCommodity_Selectedaccount_Test() {

        List<XC_CS001_InterfaceConfiguration__c> interfaces = new List<XC_CS001_InterfaceConfiguration__c>();
        XC_CS001_InterfaceConfiguration__c ic1 = new XC_CS001_InterfaceConfiguration__c();
        ic1.XC_activeInterface__c = true;
        ic1.XC_URL_Required__c = 'test1';
        ic1.Name = Label.XC_CL_ReadAccountCommoditySpain;
        ic1.XC_interfaceName__c = Label.XC_CL_ReadAccountCommoditySpain;
        ic1.XC_ServerSystem__c = 'CommoditySpainB2C';
        ic1.XC_Country__c = 'Spain';
        interfaces.add(ic1);
        XC_CS001_InterfaceConfiguration__c ic2 = new XC_CS001_InterfaceConfiguration__c();
        ic2.XC_activeInterface__c = true;
        ic2.XC_URL_Required__c = 'test2';
        ic2.Name = Label.XC_CL_ContractOutbound;
        ic2.XC_interfaceName__c = Label.XC_CL_ContractOutbound;
        ic2.XC_ServerSystem__c = 'CommoditySpainB2C';
        ic2.XC_Country__c = 'Spain';
        interfaces.add(ic2);
        XC_CS001_InterfaceConfiguration__c ic3 = new XC_CS001_InterfaceConfiguration__c();
        ic3.XC_activeInterface__c = true;
        ic3.XC_URL_Required__c = 'test3';
        ic3.Name = Label.XC_CL_CaseOutbound;
        ic3.XC_interfaceName__c = Label.XC_CL_CaseOutbound;
        ic3.XC_ServerSystem__c = 'CommoditySpainB2C';
        ic3.XC_Country__c = 'Spain';
        interfaces.add(ic3);
        XC_CS001_InterfaceConfiguration__c ic4 = new XC_CS001_InterfaceConfiguration__c();
        ic4.XC_activeInterface__c = true;
        ic4.XC_URL_Required__c = 'test4';
        ic4.Name = Label.XC_CL_ReadInvoiceListCommoditySpain;
        ic4.XC_interfaceName__c = Label.XC_CL_ReadInvoiceListCommoditySpain;
        ic4.XC_ServerSystem__c = 'CommoditySpainB2C';
        ic4.XC_Country__c = 'Spain';
        interfaces.add(ic4);
        insert interfaces;

        List<Account> account=[SELECT Id FROM Account];
        Test.setMock(HttpCalloutMock.class, new XC_REST_ClassMock2(account[0].Id));
        XC_REST_Account_W.WrapperResponseGET wResp = new  XC_REST_Account_W.WrapperResponseGET();
        List<XC_UTIL_Account.AccountIFWrapper> AccountList = new List<XC_UTIL_Account.AccountIFWrapper>();
        XC_UTIL_Account.AccountIFWrapper acc = new XC_UTIL_Account.AccountIFWrapper();
        acc.IdentityType = 'NIF';
        acc.IdentityNumber = '41550260R';
        acc.AccountType = 'Residential';
        AccountList.add(acc);
        wResp.Account = AccountList;
        String selectedAccount = JSON.serialize(wResp);

        Test.startTest();
            XC_LCC005_AccountDataAccordion.ContinuationCommodityResult result = XC_LCC005_AccountDataAccordion.callToCommodity(account[0].Id,selectedAccount);
        	System.assert(result.success);
        Test.stopTest();
    }

      @isTest
    static void callToCommodity_Lead_WithoutDocNumber() {
        List<Lead> leads = XC_DF_Lead.createResidentialLeads(1);
        insert leads;

        Test.startTest();
            XC_LCC005_AccountDataAccordion.ContinuationCommodityResult result = XC_LCC005_AccountDataAccordion.callToCommodity(leads[0].Id, '');
        	result.sobjectTypeName = '';
        	result.sobjectId = '';
        	result.identityNumber = '';
        	System.assert(!result.success);
        Test.stopTest();
    }

    
    public class XC_REST_ClassMock_1 implements HttpCalloutMock {
    
        public HttpResponse respond (HttpRequest req){
            XC_REST_ReadAccont_U.WrapperResponseHR wrResp = new  XC_REST_ReadAccont_U.WrapperResponseHR();
            wrResp.message = 'ok';

            HttpResponse response = new  HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(wrResp, true));
            response.setStatusCode(200);
            return response;
        }
    }

    public class XC_REST_ClassMock2 implements HttpCalloutMock {

        public String accountId;

        public XC_REST_ClassMock2(String accountId) {
            accountId=accountId;
        }

         public HttpResponse respond (HttpRequest req) {

            String endpoint = req.getEndpoint();
            HttpResponse response = new  HttpResponse();
            response.setHeader('Content-Type', 'application/json');
           
            if(endpoint.contains('test_ReadAccount')) {        // when block 1
                XC_REST_Account_W.WrapperResponseGET wResp = new  XC_REST_Account_W.WrapperResponseGET();
                List<XC_UTIL_Account.AccountIFWrapper> AccountList = new List<XC_UTIL_Account.AccountIFWrapper>();
                XC_UTIL_Account.AccountIFWrapper acc = populateWrapperAccount();
                acc.Identity = populateWrapperIdentity();
                acc.Contact=populateWrapperContact();
                acc.BillingProfile=populateWrapperBillingProfile();
                acc.Address=populateWrapperAddress();
                AccountList.add(acc);

                wResp.Account = AccountList;
                response.setBody(JSON.serialize(wResp, true));
        		
             } else if(endpoint.contains('test_ReadContract')) {

                response.setBody('{"fake": "response"}');
            } else {
                response.setBody('{"key": "value"}');
            }
            
            response.setStatusCode(200);

            return response;
        }
    }


     /*
	*@ Description populate wrapper Account POST
	*/
    public static XC_UTIL_Account.AccountIFWrapper populateWrapperAccount(){

        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();

        wa.AccountType = 'Residential';
        wa.FirstName = 'Account';
        wa.LastName = 'Test';
        wa.MainPhone = '987876765';
        wa.MainPhonePrefix = '+34';
        wa.PrimaryEmail = 'test@accountemail.com';
        wa.Country = 'SPAIN';
        wa.IdentityType = 'NIF';
        wa.IdentityNumber = '41550260R';
        return wa;
    }


    /*
	*@ Description populate wrapperIdentity POST
	*/
    public static List<XC_UTIL_Account.IdentityIFWrapper> populateWrapperIdentity(){

        List<XC_UTIL_Account.IdentityIFWrapper> wiList = new List<XC_UTIL_Account.IdentityIFWrapper>();
        XC_UTIL_Account.IdentityIFWrapper wi = new XC_UTIL_Account.IdentityIFWrapper();

        wi.Country = 'Spain';
        wi.IdentityType = 'NIF';
        wi.IdentityNumber = '41550260R';
        wi.ReleaseDate = '2019-01-09T00:00:00'; // restore 
        wi.ExpiryDate = '2029-10-09T00:00:00';

        wiList.add(wi);

        return wiList;
    }


    /*
	*@ Description populate wrapper contact POST
	*/
    public static List<XC_UTIL_Account.ContactIFWrapper> populateWrapperContact(){

        List<XC_UTIL_Account.ContactIFWrapper> conList = new List<XC_UTIL_Account.ContactIFWrapper>();
        XC_UTIL_Account.ContactIFWrapper conWr = new XC_UTIL_Account.ContactIFWrapper();

        conWr.LastName = 'Contact';
        conWr.FirstName = 'Test';
        conWr.PrimaryContact = true;
        conWr.Email = 'test@contact.com';
        conWr.MainPhonePrefix = '+39';
        conWr.MainPhone = '678787656';
        conWr.ShippingContact = true;
        conWr.BillingContact = true;
        conWr.IdentityType = 'NIF';
        conWr.IdentityNumber = '41550260R';
        XC_UTIL_Account.gdprWrapper gdprWr = new XC_UTIL_Account.gdprWrapper();
        gdprWr.GiveDataToThirdParties = 'Y';
        List<XC_UTIL_Account.LegalEntityWrapper>  leWrList = new List<XC_UTIL_Account.LegalEntityWrapper>();
        XC_UTIL_Account.LegalEntityWrapper  leWr = new XC_UTIL_Account.LegalEntityWrapper();
        leWr.LegalEntity = 'EndesaX'; 
        leWr.GiveDataToLegalEntity = 'Y'; 
        leWr.GiveDataForMarketing = 'Y'; 
        leWrList.add(leWr);
        gdprWr.LegalEntity =  leWrList;
        conWr.GDPR = gdprWr;

        conList.add(conWr);

        return conList;
    }


    /*
	*@ Description populate wrapper billing POST
	*/
    public static List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> populateWrapperBillingProfile(){

        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> bfWrList = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
        XC_UTIL_BillingProfile.BillingProfileIFWrapper bfwr = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
        bfwr.LegalEntity = 'EndesaX';
        bfwr.PaymentMethod = 'Credit Card';
        bfwr.InvoicePreferredLanguage = 'Spanish';
        bfwr.InvoiceDeliveryPref = 'Email';
        bfWrList.add(bfwr);

        return bfWrList;
    }


    /*
	*@ Description populate wrapper address POST
	*/
    public static List<XC_UTIL_Address.AddressWrapper> populateWrapperAddress(){

        List<XC_UTIL_Address.AddressWrapper> addrWrList = new List<XC_UTIL_Address.AddressWrapper>();
        XC_UTIL_Address.AddressWrapper addrWr = new XC_UTIL_Address.AddressWrapper();
        addrWr.StreetType = 'Road';
        addrWr.Address = 'Deva';
        addrWr.StreetNumber = '3';
        addrWr.ZipCode = '28041';
        addrWr.City = 'Madrid';
        addrWr.Country = 'Spain';
        addrWr.DeliveryAddress = true;
        addrWr.BillingAddress = true;
        List<XC_UTIL_Address.PosWrapper> posWrList = new List<XC_UTIL_Address.PosWrapper>();
        XC_UTIL_Address.PosWrapper posWr = new XC_UTIL_Address.PosWrapper();
        posWr.POSType = 'Gas';
        poswr.POS = 'PosTest';
        posWrList.add(posWr);
        addrWr.PointOfService = posWrList;
        addrWrList.add(addrWr);

        return addrWrList;
    }
    
    
    
    /*static testMethod void firstCallCommodityContinuationFromAccount_NotActiveInterfaceExpetion(){
    
        List<Account> account=[SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        Object result = XC_LCC005_AccountDataAccordion.firstCallCommodityContinuation(account[0].Id);
        System.assert(result!=null);
        Test.stopTest();
    }

     static testMethod void firstCallCommodityContinuationFromAccount(){
    
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ReadAccountCommoditySpain;
        ic.XC_interfaceName__c = Label.XC_CL_ReadAccountCommoditySpain;
        insert ic;
        
        XC_CS001_InterfaceConfiguration__c ic2 = new XC_CS001_InterfaceConfiguration__c();
        ic2.XC_activeInterface__c = true;
        ic2.XC_URL_Required__c = 'test';
        ic2.Name = Label.XC_CL_ContractOutbound;
        ic2.XC_interfaceName__c = Label.XC_CL_ContractOutbound;
        insert ic2;
        Test.setMock(HttpCalloutMock.class, new XC_REST_ClassMock_1());

        List<Account> account=[SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        Object result = XC_LCC005_AccountDataAccordion.firstCallCommodityContinuation(account[0].Id);
        System.assert(result!=null);
        Test.stopTest();
    }


    
    static testMethod void firstCallCommodityContinuationFromLead(){
       
        List<Lead> lead = XC_DF_Lead.createResidentialLeads(1);
        lead[0].XC_DocumentNumber__c = '41550260R';
        lead[0].XC_DocumentType__c = 'NIF';
        lead[0].Country__c = 'SPAIN';
        lead[0].XC_DocumentCountry__c = 'Spain';
        insert lead;
        
        Test.startTest();
        Object result = XC_LCC005_AccountDataAccordion.firstCallCommodityContinuation(lead[0].Id);
        System.assert(result!=null);
        Test.stopTest();
    }
    
    static testMethod void firstCallCommodityContinuationDocNull(){
       
        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        account[0].IdentityNumber__c = null;
        account[0].IdentityType__c = null;
        insert account;
        
        Test.startTest();
        Object result = XC_LCC005_AccountDataAccordion.firstCallCommodityContinuation(account[0].Id);
        System.assert(result!=null);
        Test.stopTest();
    }
	
    static testMethod void processFirstCommodityResponse(){
       
        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        account[0].IdentityNumber__c = '41550260R';
        account[0].IdentityType__c = 'NIF';
        insert account;
        
        Map<String,Object> stateMap = new Map<String,Object>();
        stateMap.put('recordId', account[0].Id);
        stateMap.put('sobjectType', 'Account');
        stateMap.put('identityNumber', '41550260R');
        stateMap.put('isActiveInterface1', true);
        stateMap.put('isActiveInterface2', true);
        stateMap.put('requestLabel1', 'Continuation-1');
        stateMap.put('requestLabel2', 'Continuation-2');
        
        Test.startTest();
        Object result = XC_LCC005_AccountDataAccordion.processFirstCommodityResponse(new List<String>(), JSON.serialize(stateMap));
        System.assert(result!=null);
        Test.stopTest();
    }
	
    static testMethod void processFirstCommodityResponseInactiveInterface(){
        
        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        account[0].IdentityNumber__c = '41550260R';
        account[0].IdentityType__c = 'NIF';
        insert account;
        
        Map<String,Object> stateMap = new Map<String,Object>();
        stateMap.put('recordId', account[0].Id);
        stateMap.put('sobjectType', 'Account');
        stateMap.put('identityNumber', '41550260R');
        stateMap.put('isActiveInterface1', false);
        stateMap.put('isActiveInterface2', false);
        stateMap.put('requestLabel1', 'Continuation-1');
        stateMap.put('requestLabel2', 'Continuation-2');
        
        Test.startTest();
        Object result = XC_LCC005_AccountDataAccordion.processFirstCommodityResponse(new List<String>(), JSON.serialize(stateMap));
        System.assert(result!=null);
        Test.stopTest();
    }
	
    static testMethod void secondCallCommodityContinuation(){
       
        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        account[0].IdentityNumber__c = '41550260R';
        account[0].IdentityType__c = 'NIF';
        insert account;
        
        Test.startTest();
        Object result = XC_LCC005_AccountDataAccordion.secondCallCommodityContinuation(account[0].Id, '41550260R');
        System.assert(result!=null);
        Test.stopTest();
    }
	
    static testMethod void processSecondCommodityResponse(){
      
        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        account[0].IdentityNumber__c = '41550260R';
        account[0].IdentityType__c = 'NIF';
        insert account;
        
        Map<String,Object> stateMap = new Map<String,Object>();
        stateMap.put('recordId', account[0].Id);
        stateMap.put('sobjectType', 'Account');
        stateMap.put('identityNumber', '41550260R');
        stateMap.put('isActiveInterface1', true);
        stateMap.put('isActiveInterface2', true);
        stateMap.put('requestLabel1', 'Continuation-1');
        stateMap.put('requestLabel2', 'Continuation-2');
        
        Test.startTest();
        Object result = XC_LCC005_AccountDataAccordion.processSecondCommodityResponse(new List<String>(), JSON.serialize(stateMap));
        System.assert(result!=null);
        Test.stopTest();
    }
	
    static testMethod void processSecondCommodityResponseInactiveInterface(){
       
        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        account[0].IdentityNumber__c = '41550260R';
        account[0].IdentityType__c = 'NIF';
        insert account;
        
        Map<String,Object> stateMap = new Map<String,Object>();
        stateMap.put('recordId', account[0].Id);
        stateMap.put('sobjectType', 'Account');
        stateMap.put('identityNumber', '41550260R');
        stateMap.put('isActiveInterface1', false);
        stateMap.put('isActiveInterface2', false);
        stateMap.put('requestLabel1', 'Continuation-1');
        stateMap.put('requestLabel2', 'Continuation-2');
        
        Test.startTest();
        Object result = XC_LCC005_AccountDataAccordion.processSecondCommodityResponse(new List<String>(), JSON.serialize(stateMap));
        System.assert(result!=null);
        Test.stopTest();
    }

    @isTest
    static void callToCommodity_Test() {

         
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test_ReadAccount';
        ic.Name = Label.XC_CL_ReadAccountCommoditySpain;
        ic.XC_interfaceName__c = Label.XC_CL_ReadAccountCommoditySpain;
        insert ic;

        List<Account> account=[SELECT Id FROM Account];
        Test.setMock(HttpCalloutMock.class, new XC_REST_ClassMock2(account[0].Id));
        Test.startTest();
            XC_LCC005_AccountDataAccordion.callToCommodity(account[0].Id);
        Test.stopTest();
    }

     @isTest
    static void callToCommodity_Test_NoIdentity() {
        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        account[0].IdentityNumber__c = null;
        account[0].IdentityType__c = null;
        insert account;
         
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test_ReadAccount';
        ic.Name = Label.XC_CL_ReadAccountCommoditySpain;
        ic.XC_interfaceName__c = Label.XC_CL_ReadAccountCommoditySpain;
        insert ic;

        Test.setMock(HttpCalloutMock.class, new XC_REST_ClassMock2(account[0].Id));
        Test.startTest();
            XC_LCC005_AccountDataAccordion.callToCommodity(account[0].Id);
        Test.stopTest();
    }*/

}