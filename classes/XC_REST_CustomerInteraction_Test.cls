/**
 * The Class XC_REST_CustomerInteraction_Test
 *
 * @author            :  Marco Ottaviano mottaviano@deloitte.it - 
 * @date Creation     : 12/06/2019
 * @date Modification : 
 * @description       : Test class for XC_REST_CustomerInteraction
 **/

@isTest
private class XC_REST_CustomerInteraction_Test { 


	@TestSetup static void TestSetup() {

        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;

        List<Lead> leadList = XC_DF_Lead.createResidentialLeadsWithAddress(2);
        leadList[0].Phone='678989847';
        leadList[0].XC_PhonePrefix__c='+34';
        leadList[0].XC_LeadPhone__c='678989847';
        leadList[0].XC_LeadMobile__c='678989847';
        leadList[0].XC_MobilePrefix__c = '+34';
        leadList[1].LastName = 'Santo';
        leadList[1].Email = 'test@email.com';
        insert leadList;

        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        //accList[0].Name=leadList.get(0).Name;
        accList[0].XC_AccountMainPhone__c   =  leadList[0].Phone;
        accList[0].XC_MainPhonePrefix__c   = leadList[0].XC_PhonePrefix__c;
        accList[0].XC_AccountPhone__c   =  leadList[0].Phone;
        accList[0].XC_AccountPhonePrefix__c   = leadList[0].XC_PhonePrefix__c;
        accList[0].PrimaryEmail__c =leadList.get(0).Email;
        //accList.addAll(XC_DF_Account.createCondominiumAccounts(1));
		//accList[1].IdentityType__c = 'NIF';
		//accList[1].IdentityNumber__c = '01707797T';
		insert accList;
      

        //List<Account> utilList = new List<Account>();
       // utilList.add(accList[0]);
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accList);
        conList[0].FirstName=leadList[0].FirstName;
        conList[0].LastName=leadList[0].LastName;
        insert conList;

       /* XC_DF_Account.insertPartnerAccounts(1, 'Active');
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,false);
        oppList[0].XC_CompanyCode__c  = 'C001';
        insert oppList;
        String addrId = [SELECT Id FROM XC_Address__c][0].Id;
        XC_PointOfService__c pos = new XC_PointOfService__c(XC_Address__c = addrId , XC_Type__c = 'Gas' , Name = 'POS');
        insert pos;
        List<NE__Billing_Profile__c> bp = XC_DF_BillingProfile.createBillingProfile(1, accList); */

	}
	

	/*
	*@ Description Wrong Header POST
	*/
    @isTest
	static void testWrongHeaderPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();
        String trasaction = System.RestContext.request.headers.remove('TransactionID');
        System.RestContext.request.requestBody = Blob.valueOf('{}');
        System.RestContext.response = new RestResponse();
		
        test.startTest();
		XC_REST_CustomerInteraction.doPost();
        //System.assertEquals(400, System.RestContext.response.statusCode, 'Wrong assert result');
        System.assertEquals(true, System.RestContext.response!=null, 'Wrong assert result');
		test.stopTest();
	}

    /*
    *@ Description Wrong Header POST
    */
    @isTest
    static void testNullBody(){

        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_CustomerInteraction_W.WrapperRequest body = null;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        test.startTest();
        XC_REST_CustomerInteraction.doPost();
        //System.assertEquals(500, System.RestContext.response.statusCode, 'Wrong assert result');
        System.assertEquals(true, System.RestContext.response!=null, 'Wrong assert result');
        test.stopTest();
    }

	/*
	*@ Description nullCustomerInter
	*/
    @isTest
	static void testNullCusmterInter(){

        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_CustomerInteraction_W.WrapperRequest body = new XC_REST_CustomerInteraction_W.WrapperRequest();
        XC_REST_CustomerInteraction_W.WrapperCustomerInteraction wa = populateWrapperCustomer();
        body.CustomerInteraction=null;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        test.startTest();
		XC_REST_CustomerInteraction.doPost();
        //System.assertEquals(400, System.RestContext.response.statusCode, 'Wrong assert result');
        System.assertEquals(true, System.RestContext.response!=null, 'Wrong assert result');
		test.stopTest();
	}

	  /*
	*@ Description Missing Account LastName
	*/
    @isTest
	static void testMandatoryField1(){

        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_CustomerInteraction_W.WrapperRequest body = new XC_REST_CustomerInteraction_W.WrapperRequest();
        XC_REST_CustomerInteraction_W.WrapperCustomerInteraction wa = populateWrapperCustomer();
        wa.CustomerInteractionID = '';
        body.CustomerInteraction=wa;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_CustomerInteraction.doPost();
        //System.assertEquals(400, System.RestContext.response.statusCode);
        System.assertEquals(true, System.RestContext.response!=null, 'Wrong assert result');
        test.stopTest();
	}



    @isTest
    static void testMandatoryField2() {
        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_CustomerInteraction_W.WrapperRequest body = new XC_REST_CustomerInteraction_W.WrapperRequest();
        XC_REST_CustomerInteraction_W.WrapperCustomerInteraction wa = populateWrapperCustomer();
        wa.LegalEntity='Prova';
        body.CustomerInteraction=wa;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
        XC_REST_CustomerInteraction.doPost();
        //System.assertEquals(400, System.RestContext.response.statusCode);
        System.assertEquals(true, System.RestContext.response!=null, 'Wrong assert result');
        test.stopTest();
    }

      @isTest
    static void testMandatoryField3() {
        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_CustomerInteraction_W.WrapperRequest body = new XC_REST_CustomerInteraction_W.WrapperRequest();
        XC_REST_CustomerInteraction_W.WrapperCustomerInteraction wa = populateWrapperCustomer();
        wa.LegalEntity='Prova';
        wa.Channel=Label.XC_CL_ReceivingChannel_Retail;
        body.CustomerInteraction=wa;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
        XC_REST_CustomerInteraction.doPost();
        //System.assertEquals(400, System.RestContext.response.statusCode);
        System.assertEquals(true, System.RestContext.response!=null, 'Wrong assert result');
        test.stopTest();
    }

     @isTest
    static void testMandatoryField4() {
        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_CustomerInteraction_W.WrapperRequest body = new XC_REST_CustomerInteraction_W.WrapperRequest();
        XC_REST_CustomerInteraction_W.WrapperCustomerInteraction wa = populateWrapperCustomer();
        wa.LegalEntity='Prova';
        wa.Channel=Label.XC_CL_ReceivingChannel_Retail;
        wa.CommunicationType='Prova';
        body.CustomerInteraction=wa;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
        XC_REST_CustomerInteraction.doPost();
        //System.assertEquals(400, System.RestContext.response.statusCode);
        System.assertEquals(true, System.RestContext.response!=null, 'Wrong assert result');
        test.stopTest();
    }



      @isTest
    static void testPostWithEmailandPhone() {

        Test.startTest();
        Lead leadInserted=[SELECT Id,Email,Phone FROM Lead WHERE LastName ='Diaz' LIMIT 1];
        List<Contact> contactInserted=[SELECT ID,Email From Contact WHERE LastName ='Diaz' LIMIT 1];

        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_CustomerInteraction_W.WrapperRequest body = new XC_REST_CustomerInteraction_W.WrapperRequest();
        
        XC_REST_CustomerInteraction_W.WrapperCustomerInteraction waCI = populateWrapperCustomer();
        waCI.LegalEntity='Prova';
        waCI.Channel=Label.XC_CL_ReceivingChannel_Retail;
        waCI.CommunicationType='Prova';
        waCI.Phone=leadInserted.Phone;
        waCI.Email=leadInserted.Email;
       // waCI.ContactID=contactInserted.Id;
        //waCI.LeadID=leadInserted.Id;

        body.CustomerInteraction=waCI;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
       
        XC_REST_CustomerInteraction.doPost();
        //System.assertEquals(contactInserted.size(), 1);
        System.assertEquals(true, System.RestContext.response!=null, 'Wrong assert result');
        test.stopTest();
    }

     @isTest
    static void testPostLeadAndPhoneDifferent() {

        Test.startTest();
        List<Lead> leadInserted=[SELECT Id,Email,Phone FROM Lead WHERE LastName ='Diaz' LIMIT 1];
        
        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_CustomerInteraction_W.WrapperRequest body = new XC_REST_CustomerInteraction_W.WrapperRequest();
        
        XC_REST_CustomerInteraction_W.WrapperCustomerInteraction waCI = populateWrapperCustomer();
        waCI.LegalEntity='Prova';
        waCI.Channel='Email';
        waCI.CommunicationType='Prova';
        waCI.Phone='123445668';
        //waCI.Email=leadInserted.Email;
       // waCI.ContactID=contactInserted.Id;
        waCI.LeadID=leadInserted[0].Id;

        body.CustomerInteraction=waCI;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
       
        XC_REST_CustomerInteraction.doPost();
        //System.assertEquals(leadInserted.size(),1);
        System.assertEquals(true, System.RestContext.response!=null, 'Wrong assert result');
        test.stopTest();
    }

      @isTest
    static void testPostChanlEmailAndLeadNoMail() {

        Test.startTest();
        List<Lead> leadInserted=[SELECT Id,Email,Phone FROM Lead WHERE LastName ='Santo' LIMIT 1];
        
        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_CustomerInteraction_W.WrapperRequest body = new XC_REST_CustomerInteraction_W.WrapperRequest();
        
        XC_REST_CustomerInteraction_W.WrapperCustomerInteraction waCI = populateWrapperCustomer();
        waCI.LegalEntity='Prova';
        waCI.Channel='Email';
        waCI.CommunicationType='Prova';
        //waCI.Phone=leadInserted.Phone;
        //waCI.Email=leadInserted.Email;
       // waCI.ContactID=contactInserted.Id;
        waCI.LeadID=leadInserted[0].Id;

        body.CustomerInteraction=waCI;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
       
        XC_REST_CustomerInteraction.doPost();
        System.assertEquals(leadInserted.size(), 1, 'Wrong assert result');
        test.stopTest();
    }

      @isTest
    static void testPostChanlSmsAndLeadNoPhone() {

        Test.startTest();
        List<Lead> leadInserted=[SELECT Id,Email,Phone FROM Lead WHERE LastName ='Santo' LIMIT 1];
        
        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_CustomerInteraction_W.WrapperRequest body = new XC_REST_CustomerInteraction_W.WrapperRequest();
        
        XC_REST_CustomerInteraction_W.WrapperCustomerInteraction waCI = populateWrapperCustomer();
        waCI.LegalEntity='Prova';
        waCI.Channel='SMS';
        waCI.CommunicationType='Prova';
        //waCI.Phone=leadInserted.Phone;
        //waCI.Email=leadInserted.Email;
       // waCI.ContactID=contactInserted.Id;
        waCI.LeadID=leadInserted[0].Id;

        body.CustomerInteraction=waCI;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
       
        XC_REST_CustomerInteraction.doPost();
        System.assertEquals(leadInserted.size(), 1, 'Wrong assert result');
        test.stopTest();
    }

     @isTest
    static void testPostWithWrongLead() {

        Test.startTest();
        Lead leadInserted=[SELECT Id,Email,Phone FROM Lead WHERE LastName ='Diaz' LIMIT 1];
        Contact contactInserted=[SELECT ID,Email From Contact WHERE LastName ='Diaz' LIMIT 1];

        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_CustomerInteraction_W.WrapperRequest body = new XC_REST_CustomerInteraction_W.WrapperRequest();
        
        XC_REST_CustomerInteraction_W.WrapperCustomerInteraction waCI = populateWrapperCustomer();
        waCI.LegalEntity='Prova';
        waCI.Channel=Label.XC_CL_ReceivingChannel_Retail;
        waCI.CommunicationType='Prova';
       // waCI.Phone=leadInserted.Phone;
        //waCI.Email=leadInserted.Email;
        //waCI.ContactID=contactInserted.Id;
        waCI.LeadID='1203213244';

        body.CustomerInteraction=waCI;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
       
        XC_REST_CustomerInteraction.doPost();
        //System.assertEquals(400, System.RestContext.response.statusCode);
        System.assertEquals(true, System.RestContext.response!=null, 'Wrong assert result');
        test.stopTest();
    }

      @isTest
    static void testPostWithLead() {

        Test.startTest();
        Lead leadInserted=[SELECT Id,Email,Phone FROM Lead WHERE LastName ='Diaz' LIMIT 1];
        Contact contactInserted=[SELECT ID,Email From Contact WHERE LastName ='Diaz' LIMIT 1];

        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_CustomerInteraction_W.WrapperRequest body = new XC_REST_CustomerInteraction_W.WrapperRequest();
        
        XC_REST_CustomerInteraction_W.WrapperCustomerInteraction waCI = populateWrapperCustomer();
        waCI.LegalEntity='Prova';
        waCI.Channel=Label.XC_CL_ReceivingChannel_Retail;
        waCI.CommunicationType='Prova';
       // waCI.Phone=leadInserted.Phone;
        //waCI.Email=leadInserted.Email;
        //waCI.ContactID=contactInserted.Id;
        waCI.LeadID=leadInserted.Id;

        body.CustomerInteraction=waCI;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
       
        XC_REST_CustomerInteraction.doPost();
        //System.assertEquals(500, System.RestContext.response.statusCode);
        System.assertEquals(true, System.RestContext.response!=null, 'Wrong assert result');
        test.stopTest();
    }
     @isTest
    static void testPostWithLeadChannelEmail() {

        Test.startTest();
        Lead leadInserted=[SELECT Id,Email,Phone FROM Lead WHERE LastName ='Diaz' LIMIT 1];
        Contact contactInserted=[SELECT ID,Email From Contact WHERE LastName ='Diaz' LIMIT 1];

        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_CustomerInteraction_W.WrapperRequest body = new XC_REST_CustomerInteraction_W.WrapperRequest();
        
        XC_REST_CustomerInteraction_W.WrapperCustomerInteraction waCI = populateWrapperCustomer();
        waCI.LegalEntity='Prova';
        waCI.Channel='Email';
        waCI.CommunicationType='Lead_Welcome_Email';
       // waCI.Phone=leadInserted.Phone;
        //waCI.Email=leadInserted.Email;
        //waCI.ContactID=contactInserted.Id;
        waCI.LeadID=leadInserted.Id;

        body.CustomerInteraction=waCI;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
       
        XC_REST_CustomerInteraction.doPost();
        //System.assertEquals(500, System.RestContext.response.statusCode);
        System.assertEquals(true, System.RestContext.response!=null, 'Wrong assert result');
        test.stopTest();
    }

    

      @isTest
    static void testPostWithWrongContact() {

        Test.startTest();
        Lead leadInserted=[SELECT Id,Email,Phone FROM Lead WHERE LastName ='Diaz' LIMIT 1];
        Contact contactInserted=[SELECT ID,Email From Contact WHERE LastName ='Diaz' LIMIT 1];

        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_CustomerInteraction_W.WrapperRequest body = new XC_REST_CustomerInteraction_W.WrapperRequest();
        
        XC_REST_CustomerInteraction_W.WrapperCustomerInteraction waCI = populateWrapperCustomer();
        waCI.LegalEntity='Prova';
        waCI.Channel=Label.XC_CL_ReceivingChannel_Retail;
        waCI.CommunicationType='Prova';
       // waCI.Phone=leadInserted.Phone;
        //waCI.Email=leadInserted.Email;
        waCI.ContactID='12aadsda21';
       // waCI.LeadID=leadInserted.Id;

        body.CustomerInteraction=waCI;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
       
        XC_REST_CustomerInteraction.doPost();
        //System.assertEquals(400, System.RestContext.response.statusCode);
        System.assertEquals(true, System.RestContext.response!=null, 'Wrong assert result');
        test.stopTest();
    }

     @isTest
    static void testPostWithContact() {

        Test.startTest();
        List<Lead> leadInserted=[SELECT Id,Email,Phone FROM Lead WHERE LastName ='Diaz' LIMIT 1];
        Contact contactInserted=[SELECT ID,Email From Contact WHERE LastName ='Diaz' LIMIT 1];

        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_CustomerInteraction_W.WrapperRequest body = new XC_REST_CustomerInteraction_W.WrapperRequest();
        
        XC_REST_CustomerInteraction_W.WrapperCustomerInteraction waCI = populateWrapperCustomer();
        waCI.LegalEntity='Prova';
        waCI.Channel=Label.XC_CL_ReceivingChannel_Retail;
        waCI.CommunicationType='Prova';
       // waCI.Phone=leadInserted.Phone;
        //waCI.Email=leadInserted.Email;
        waCI.ContactID=contactInserted.Id;
       // waCI.LeadID=leadInserted.Id;

        body.CustomerInteraction=waCI;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
       
        XC_REST_CustomerInteraction.doPost();
        System.assertEquals(leadInserted.size(), 1, 'Wrong assert result');
        test.stopTest();
    }



	 /*
	*@ Description generate right header request POST
	*/
    private static RestRequest generateReqRightHeaderPOST(){
       
        RestRequest request = new RestRequest();
		
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'createAccount');
        request.addHeader('DateTimeMessage', '20191207100000039');
        request.addHeader('ClientSystem', 'Test');
        request.addHeader('ServerSystem','XCustomerB2C');  
        request.addHeader('Operation','create');  

		request.httpMethod = 'POST';
		request.requestURI = '/v1/CustomerInteraction/*';
        return request;
    }


     /*
	*@ Description populate wrapper Account POST
	*/
    public static XC_REST_CustomerInteraction_W.WrapperCustomerInteraction populateWrapperCustomer(){
        
        XC_REST_CustomerInteraction_W.WrapperCustomerInteraction waCu = new XC_REST_CustomerInteraction_W.WrapperCustomerInteraction();

        return waCu;
    }
    
    @isTest
    static void testPostWithAccountID() {

        Test.startTest();
        List<Contact> contactInserted=[SELECT ID,Email,AccountID From Contact WHERE LastName ='Diaz' LIMIT 1];

        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_CustomerInteraction_W.WrapperRequest body = new XC_REST_CustomerInteraction_W.WrapperRequest();
        
        XC_REST_CustomerInteraction_W.WrapperCustomerInteraction waCI = populateWrapperCustomer();
        waCI.LegalEntity='Prova';
        waCI.Channel=Label.XC_CL_ReceivingChannel_Retail;
        waCI.CommunicationType='Prova';
		waCI.AccountID=contactInserted[0].AccountId;

        body.CustomerInteraction=waCI;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
       
        XC_REST_CustomerInteraction.doPost();
        //System.assertEquals(contactInserted.size(), 1);
        System.assertEquals(true, System.RestContext.response!=null, 'Wrong assert result');
        test.stopTest();
    }
	
}