@isTest
public class ZuoraWebservice_TEST {
    
    @testSetup static void setup() {
        // Init Custom Setting
       	Zuora_OAuth__c zoa = new  Zuora_OAuth__c();
        zoa.EntityName__c = 'Enel Spain B2C';
        zoa.Client_Id__c = '123456'; 
        zoa.Client_Secret__c = '78910'; 
        zoa.EntityId__c = '1234567890764332';
        zoa.Host__c = 'rest.sandbox.eu.zuora.com';
        zoa.apiToken__c = '171173687168716368713718736183';
        insert zoa;
    }
    
    /*@isTest
	public static void testgenerateToken() {	
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        generateToken();
	}
    
    @future(callout = true)
	public static void generateToken(){
        ZuoraWebservice zws = new ZuoraWebservice('Spain');
    	//do callout here rest or soap
    	String token = zws.token;
        System.debug('token -->'+token);
	
	}*/
    
    @isTest
	public static void testCreatePaymentMethod() {	
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        createPaymentMethod();
	}
    
    @future(callout = true)
	public static void createPaymentMethod(){
        ZuoraWebservice zws = new ZuoraWebservice('Spain');
    	//do callout here rest or soap
        zws.createPaymentMethod('{"accountId": "123456"}');
	}
    
    @isTest
	public static void testUpdatePaymentMethod() {	
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        updatePaymentMethod();
	}
    
    @future(callout = true)
	public static void updatePaymentMethod(){
        ZuoraWebservice zws = new ZuoraWebservice('Spain');
    	//do callout here rest or soap
        zws.updatePaymentMethod('{"accountId": "123456"}');
	}
    
    @isTest
	public static void testGenerateRSASignature() {	
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        generateRSASignature('123456567');
	}
    
    @future(callout = true)
	public static void generateRSASignature(String pageId){
        ZuoraWebservice zws = new ZuoraWebservice('Spain');
    	//do callout here rest or soap
        zws.generateRSASignature(pageId);
	}
    
    /*@isTest
	public static void testGetSubscriptionIdByAccountId() {	
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        getSubscriptionIdByAccountId('123456567');
	}
    
    @future(callout = true)
	public static void getSubscriptionIdByAccountId(String accountId){
        ZuoraWebservice zws = new ZuoraWebservice('Spain');
    	//do callout here rest or soap
        zws.getSubscriptionIdByAccountId(accountId);
	}
    
    @isTest
	public static void testGetProductRatePlans() {	
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        getProductRatePlans('123456567');
	}
    
    @future(callout = true)
	public static void getProductRatePlans(String productId){
        ZuoraWebservice zws = new ZuoraWebservice('Spain');
    	//do callout here rest or soap
        zws.getProductRatePlans(productId);
	}
    
    @isTest
	public static void testCreateDraftSubscription() {	
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        getProductRatePlans('123456567');
	}
    
    @future(callout = true)
	public static void createDraftSubscription(String productId){
        ZuoraWebservice zws = new ZuoraWebservice('Spain');
    	//do callout here rest or soap
        String accountId = '1234566';
        Boolean generateInvoice = true;
        Integer initialTerm = 12;
        Integer renewalTerm = 12;
        String termType = 'Net 30';
        String productRatePlanId = '123232423';
        String productRatePlanChargeId = '121413131';
        zws.createDraftSubscription(accountId, generateInvoice, initialTerm,renewalTerm, termType,productRatePlanId, productRatePlanChargeId);
	}
    
    @isTest
	public static void testActivateSubscription() {	
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        String subscriptionId = '1234566';
        String contractEffectiveDate = '2019-06-25';
        activateSubscription(subscriptionId, contractEffectiveDate);
	}
    
    @future(callout = true)
	public static void activateSubscription(String subscriptionId, String contractEffectiveDate){
        ZuoraWebservice zws = new ZuoraWebservice('Spain');
    	//do callout here rest or soap
        zws.activateSubscription(subscriptionId,contractEffectiveDate);
	}
    
    @isTest
	public static void testExecuteBillRun() {	
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        String accountId = '121323131'; 
        String invoiceDate = '2019-06-25'; 
        String targetDate = '2019-06-25'; 
        Boolean autoPost =  false;
        String chargeTypeToExclude = 'Recurring';
        executeBillRun(accountId, invoiceDate, targetDate, autoPost, chargeTypeToExclude);
	}
    
    @future(callout = true)
	public static void executeBillRun(String accountId, String invoiceDate, String targetDate, Boolean autoPost, String chargeTypeToExclude){
        ZuoraWebservice zws = new ZuoraWebservice('Spain');
    	//do callout here rest or soap
        zws.executeBillRun(accountId, invoiceDate, targetDate, autoPost, chargeTypeToExclude);
	}
    
    @isTest
	public static void testGetSubscription() {	
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
		String subscriptionId = '123556566';
        getSubscription(subscriptionId);
	}
    
    @future(callout = true)
	public static void getSubscription(String subscriptionId){
        ZuoraWebservice zws = new ZuoraWebservice('Spain');
    	//do callout here rest or soap
        zws.getSubscription(subscriptionId);
	}
    
    @isTest
	public static void testGetSubscriptionChargeTypes() {	
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
		getSubscriptionChargeTypes();
	}
    
    @future(callout = true)
	public static void getSubscriptionChargeTypes(){
        String subscriptionId = '123556566';
        ZuoraWebservice zws = new ZuoraWebservice('Spain');
        zws.getSubscriptionChargeTypes(subscriptionId);
	}
    
    @isTest
    public static void testCreateZuoraAccountF1(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
    	createZuoraAccountF1();
    }
    
    @future(callout = true)
	public static void createZuoraAccountF1(){
        ZuoraWebservice zws = new ZuoraWebservice('Spain');
        NE__Order__c order = new  NE__Order__c();
        Contact billTo = new Contact();
        Contact soldTo = new Contact();
        zws.createZuoraAccount(order, billTo, soldTo);
	} */
    
    
    @isTest
    public static void testLinkPaymentMethodToAccountF1(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        String zuoraAccountId = '54674722';
        String paymentMethodId = '1232323323'; 
        String paymentMethodType = 'SEPA';
    	linkPaymentMethodToAccountF1(zuoraAccountId, paymentMethodId, paymentMethodType);
    }
    
    
    @future(callout = true)
	public static void linkPaymentMethodToAccountF1(String zuoraAccountId, String paymentMethodId, String paymentMethodType){
        ZuoraWebservice zws = new ZuoraWebservice('Spain');
        zws.linkPaymentMethodToAccount(zuoraAccountId, paymentMethodId, paymentMethodType);
	}
    
    
    @isTest
    public static void testLinkPaymentMethodToAccountF2(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        String zuoraAccountId = '54674722';
        String paymentMethodId = '1232323323'; 
    	linkPaymentMethodToAccountF2(zuoraAccountId, paymentMethodId);
    }
    
    @future(callout = true)
	public static void linkPaymentMethodToAccountF2(String zuoraAccountId, String paymentMethodId){
        ZuoraWebservice zws = new ZuoraWebservice('Spain');
        zws.linkPaymentMethodToAccount(zuoraAccountId, paymentMethodId);
	}
    
    
    @isTest
    public static void testLinkPaymentMethodToAccountF3(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        String zuoraAccountId = '54674722';
        String paymentMethodId = '1232323323'; 
        String paymentGateway = 'SIA PH SDD'; 
    	linkPaymentMethodToAccountF3(zuoraAccountId, paymentMethodId, paymentGateway);
    }
    
    @future(callout = true)
	public static void linkPaymentMethodToAccountF3(String zuoraAccountId, String paymentMethodId, String paymentGateway){
        ZuoraWebservice zws = new ZuoraWebservice('Spain');
        zws.linkPaymentMethodToAccountWithGateWay(zuoraAccountId, paymentMethodId, paymentGateway);
	}
    
    /*@isTest
    public static void testCreateZuoraAccountF2(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
    	createZuoraAccountF2();
    }
    
    @future(callout = true)
	public static void createZuoraAccountF2(){
        ZuoraWebservice zws = new ZuoraWebservice('Spain');
        Account salesforceAccount = new Account(); 
        String hpmCreditCardPaymentMethodId = '12121212';
        Contact billTo = new Contact();
        Contact soldTo = new Contact();
        zws.createZuoraAccount(salesforceAccount, hpmCreditCardPaymentMethodId, billTo, soldTo);
	}*/
    
    @isTest
    public static void testCreateUnlinkedZuoraAccountF1(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
    	createUnlinkedZuoraAccountF1();
    }
    
    
    @isTest
	public static void createUnlinkedZuoraAccountF1(){

        List<NE__Billing_Profile__c> bpList = XC_DF_BillingProfile.createBillingProfile(1);
        bpList[0].XC_Segment__c = 'B2C';
        update bpList;
        XC_BillingProfileLineItem__c bpli = [SELECT Id FROM XC_BillingProfileLineItem__c LIMIT 1][0];
        bpli.XC_LegalEntity__c = 'EndesaX';
        update bpli;

        ZuoraWebservice zws = new ZuoraWebservice('Spain');
        //String zuoraPayment = '12313131';
        String zuoraPayment = '{"zuoraPayment": "12313131", "docNif" : "Passport", "docNumber": "PS098226", "personTypeCode": "F", "legalE": "EndesaX", "sequenceSetId": "9988", "countryCode":"ES", "contractId": "9874647"}';
        Account salesforceAccount = new Account(); 
        Contact billTo = new Contact();
        Contact soldTo = new Contact();
        String options = '{"mmm": "12"}';
        String billingProfLineItemId = bpli.id;
        
        test.startTest();

        Test.setMock(HttpCalloutMock.class, new CallZuora_Mock());
        zws.createUnlinkedZuoraAccount(salesforceAccount,billTo, soldTo, options, billingProfLineItemId, zuoraPayment);
        zws.createUnlinkedZuoraAccountB2B(salesforceAccount,billTo, soldTo, options, billingProfLineItemId, zuoraPayment);

        test.stopTest();
	
    }
    
    /*@isTest
    public static void testCreateUnlinkedZuoraAccountF2(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
    	createUnlinkedZuoraAccountF2();
    }
    

    @future(callout = true)
	public static void createUnlinkedZuoraAccountF2(){
        ZuoraWebservice zws = new ZuoraWebservice('Spain');
        Account salesforceAccount = new Account(); 
        Contact billTo = new Contact();
        Contact soldTo = new Contact();
        zws.createUnlinkedZuoraAccount(salesforceAccount, billTo, soldTo);
	}*/
    
    @isTest
    public static void testLinkAccountToExternalPaymentMethodF1(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        String accountId = '12131341';
        String externalPaymentMethodType = 'SEPA'; 
        String entityName = 'Spain';
    	linkAccountToExternalPaymentMethodF1(accountId, externalPaymentMethodType, entityName);
    }
    

    @future(callout = true)
	public static void linkAccountToExternalPaymentMethodF1(String accountId, String externalPaymentMethodType, String entityName){
        ZuoraWebservice.linkAccountToExternalPaymentMethod(accountId, externalPaymentMethodType, entityName);
	}

    /*@future(callout = true)
	public static void createDraftSubscriptionF1(String accountId, Boolean generateInvoice, Integer initialTerm, Integer renewalTerm, String termType, String productRatePlanId, String productRatePlanChargeId){
        ZuoraWebservice zws = new ZuoraWebservice('Spain');
        zws.createDraftSubscription(accountId, generateInvoice,  initialTerm,  renewalTerm, termType,  productRatePlanId,  productRatePlanChargeId);
	}
    
    @isTest
    public static void createDraftSubscriptionTest(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        String accountId = 'Test Account ID';
        Boolean generateInvoice = false;
        Integer initialTerm =1;
        Integer renewalTerm = 1;
        String termType = 'Test termtype';
        String productRatePlanId = 'testId';
        String productRatePlanChargeId= 'test';
    	createDraftSubscriptionF1( accountId,  generateInvoice,  initialTerm,  renewalTerm,  termType,  productRatePlanId,  productRatePlanChargeId);
	}*/
    
        @isTest
    public static void testCreateZuoraAccountF3(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
    	createZuoraAccountF3();
    }
    
    @future(callout = true)
	public static void createZuoraAccountF3(){
        ZuoraWebservice zws = new ZuoraWebservice('Spain');
        Account salesforceAccount = new Account(); 
        String hpmCreditCardPaymentMethodId = '12121212';
        String paymentMethodType = 'SEPA';
        Contact billTo = new Contact();
        Contact soldTo = new Contact();
        zws.createZuoraAccount(salesforceAccount, hpmCreditCardPaymentMethodId,paymentMethodType, billTo, soldTo);
	}


    @isTest
    public static void updateZuoraAccountTEST(){

        List<Account> accList =  XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accList);
        insert conList;
        List<XC_Address__c> addrList = XC_DF_Address.createAddress(accList);
        insert addrList;

        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());

        Test.startTest();
        Map<String, String> parametersMap = new Map<String, String>{'zuoraAccountId' => '123456',
                                                                    'billToId' => conList[0].Id,
                                                                    'soldToId' => conList[0].Id,
                                                                    'billAddrId' => addrList[0].Id,
                                                                    'soldAddrId' => addrList[0].Id,
                                                                    'newAccountName' => 'TestName',
                                                                    'newAccountIdentityType' => 'Passport',
                                                                    'newAccountIdentityNumber' => '2362456571',
                                                                    'newAccountDocumentCountry' => 'Spain',
                                                                    'newAccountDocumentReleaseDate' => '2019-01-01',
                                                                    'newAccountDocumentExpirationDate' => '2050-01-01'
                                                                    };
    	ZuoraWebservice zws = new ZuoraWebservice('Spain');
        ZuoraWebservice.CreateZuoraAccountResponse res = zws.updateZuoraAccount(parametersMap);
        Test.stopTest();

        System.assertEquals('true', res.success, 'Wrong assert equals');
    }
   
    
    /*
	*@ Description mock class to call zuora
	*/
    public without sharing class CallZuora_Mock implements HttpCalloutMock {
        public HttpResponse respond (HTTPRequest req){
            HttpResponse response = new HttpResponse();

            if(req.getEndpoint().endsWith('/v1/accounts')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"accountId":"a0001", "accountNumber":"A01807438", "paymentMethodId":null, "processId":null, "reasons":null, "success":true}');
                response.setStatusCode(200); 

            } 
            
            return response;
        }
    }

    //Mridul Begin
    @isTest
    public static void createSendInvoiceToCommodityLogTest(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        createSendInvoiceToCommodityLogTest1();
    }

    @future(callout=true)
    public static void createSendInvoiceToCommodityLogTest1(){
        ZuoraWebservice zws = new ZuoraWebservice('Spain');
        List<Account> accList =  XC_DF_Account.createResidentialAccounts(1);
        zws.createSendInvoiceToCommodityLog(Json.Serialize(accList));
    }
    //Mridul End

   
}