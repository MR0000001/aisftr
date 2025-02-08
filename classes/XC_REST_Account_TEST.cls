/**
 * @author              Luisana Rocco lrocco@deloitte.it
 * @date Creation       20/05/2019
 * @date Modification   
 * @description         XC_REST_Account – XC_REST_Account/_B/_U/_V/_VV/_VVV/_VVVV/_W/_Z/_ZZ/_ZZZ/_ZZZZ
 */


@isTest
public without sharing class XC_REST_Account_TEST {

    @TestSetup
	static void setup(){ 

		OneOrg__c org            = new OneOrg__c(); 
	    org.Name                 = 'OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
	    insert org;

        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        accList[0].XC_AccountMainPhone__c   = '678989847';
        accList[0].XC_MainPhonePrefix__c   = '+34';
        accList[0].XC_AccountPhone__c   = '678989847';
        accList[0].XC_AccountPhonePrefix__c   = '+34';
        accList[0].XC_ConfirmationByCustomer__c = true;
        accList[0].IdentityType__c = 'NIF';
        accList[0].IdentityNumber__c = '51142871W';
        accList.addAll(XC_DF_Account.createSohoAccounts(2));
		accList[1].IdentityType__c = 'NIF';
		accList[1].IdentityNumber__c = '01707797T';
        accList[1].XC_ConfirmationByCustomer__c = true;
        accList[2].IdentityType__c = 'NIF';
		accList[2].IdentityNumber__c = '10080737K';
        accList[2].XC_ConfirmationByCustomer__c = true;
		insert accList;

        List<Account> utilList = new List<Account>();
        utilList.add(accList[0]);
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(utilList);

        List<XC_Address__c> addrList = XC_DF_Address.createAddress(utilList);
        insert addrList;
        XC_PointOfService__c pos = new XC_PointOfService__c(XC_Account__c = accList[0].Id, XC_Address__c = addrList[0].Id , XC_Type__c = 'Gas' , Name = 'POS');
        insert pos;

        List<NE__Billing_Profile__c> bp = XC_DF_BillingProfile.createBillingProfile(1, utilList);
        bp[0].xc_status__c = 'Active';
        update bp;

        XC_BillingProfileLineItem__c bpli = [SELECT Id, XC_BillingProfile__c FROM XC_BillingProfileLineItem__c  WHERE XC_BillingProfile__c =: bp[0].Id][0];
        bpli.XC_LegalEntity__c = 'EndesaX';
        update bpli; 


        List<Account> accListTemp = XC_DF_Account.createResidentialAccounts(1); // temporary - to be modified
        accListTemp[0].PrimaryEmail__c = 'test@email.com';
        accListTemp[0].IdentityType__c = 'NIF';
        accListTemp[0].IdentityNumber__c = '30377810P';
        insert accListTemp; 

        List<XC_PersonalDocument__c> persDocList = new List<XC_PersonalDocument__c>();
        XC_PersonalDocument__c doc1 = new XC_PersonalDocument__c(XC_Account__c = accList[0].Id, XC_DocumentType__c = 'NIF', XC_DocumentNumber__c = '51142871W');
        XC_PersonalDocument__c doc2 = new XC_PersonalDocument__c(XC_Account__c = accListTemp[0].Id, XC_DocumentType__c = 'NIF', XC_DocumentNumber__c = '30377810P');
        XC_PersonalDocument__c doc3 = new XC_PersonalDocument__c(XC_Account__c = accListTemp[0].Id, XC_DocumentType__c = 'NIF', XC_DocumentNumber__c = '92098475N');
        persDocList.add(doc1);
        persDocList.add(doc2);
        insert persDocList; 
        insert doc3;
        doc3.XC_Country__c = 'Spain';
        update doc3;
        delete doc3;
        undelete doc3;
        

        accList.remove(0);
        conList.addAll(XC_DF_Contact.createSohoContacts(accList));
        insert conList;

        String  individualId = [SELECT Id, IndividualId FROM Contact][0].IndividualId; 
        /*system.debug('INDIVIDUALID'+individualId );
        XC_LegalEntityConsent__c legalEntity= new XC_LegalEntityConsent__c(XC_Individual__c = individualId, XC_LegalEntity__c = 'EndesaX', XC_GiveDataToNew__c = 'Yes', XC_LeCountry__c = 'Spain');
        insert legalEntity; */

        List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, 'InOrder');
        orderList[0].XC_EmobilityWebAppType__c  = Label.XC_CL_EmobilityWebAppType_Recharge;
        orderList[0].XC_Company_Code__c = 'C001';
        insert orderList;
	}


    /*
	*@ Description Wrong Header GET
	*/
    @isTest
	static void testWrongHeaderGET(){

        System.RestContext.request = generateReqRightHeaderGET();
        String trasaction = System.RestContext.request.headers.remove('TransactionID');
        System.RestContext.response = new RestResponse();
		
        test.startTest();
		XC_REST_Account.doGet();
        XC_REST_Account_W.WrapperResponseGET wrResp = (XC_REST_Account_W.WrapperResponseGET) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponseGET.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
		test.stopTest();
	}


    /*
	*@ Description Missing mandaory fields get
	*/
    @isTest
	static void testMissingMandatoryFieldsGET(){

        System.RestContext.request = generateReqRightHeaderGET();
        System.RestContext.response = new RestResponse();
        System.RestContext.request.headers.put('ClientSystem', 'E-Commerce');

        test.startTest();
		XC_REST_Account.doGet();
        XC_REST_Account_W.WrapperResponseGET wrResp = (XC_REST_Account_W.WrapperResponseGET) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponseGET.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
		test.stopTest();
	}

    
    /*
	*@ Description Missing mandaory fields get company Code with XRecharge as clientSystem
	*/
    @isTest
	static void testMissingFieldCompanyCodeGET(){

        System.RestContext.request = generateReqRightHeaderGET();
        System.RestContext.response = new RestResponse();
        System.RestContext.request.headers.put('ClientSystem', 'XRecharge');

        test.startTest();
		XC_REST_Account.doGet();
        XC_REST_Account_W.WrapperResponseGET wrResp = (XC_REST_Account_W.WrapperResponseGET) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponseGET.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
		test.stopTest();
	}


    /*
	*@ Description Missing mandatory fields GET IdentityNumber with client System CommoditySpainB2C
	*/
    @isTest
	static void testMissingFieldIdentityNumberGET(){

        System.RestContext.request = generateReqRightHeaderGET();
        System.RestContext.response = new RestResponse();
        System.RestContext.request.headers.put('ClientSystem', 'CommoditySpainB2C');

        test.startTest();
		XC_REST_Account.doGet();
        XC_REST_Account_W.WrapperResponseGET wrResp = (XC_REST_Account_W.WrapperResponseGET) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponseGET.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
		test.stopTest();
	}


    /*
	*@ Description get Account by AccountID
	*/
    @isTest
	static void testGETAccount(){

        System.RestContext.request = generateReqRightHeaderGET();
        System.RestContext.response = new RestResponse();
        System.RestContext.request.addParameter('AccountID', [SELECT Id FROM Account][0].Id);
        test.startTest();
		XC_REST_Account.doGet();
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');
		test.stopTest();
	}


    /*
	*@ Description get Account by CompanyCode // error account not found to be resolved
	*/
    @isTest
	static void testGETAccountbyCompanyCode(){

        System.RestContext.request = generateReqRightHeaderGET();
        System.RestContext.response = new RestResponse();
        System.RestContext.request.addParameter('CompanyCode', [SELECT XC_Company_Code__c FROM NE__Order__c][0].XC_Company_Code__c);

        test.startTest();
		XC_REST_Account.doGet();
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');
		test.stopTest();
	}


    /*
	*@ Description get Account by IdentityNumber Residential
	*/
    @isTest
	static void testGETAccountbyIdentityNumberR(){

        System.RestContext.request = generateReqRightHeaderGET();
        System.RestContext.response = new RestResponse();
        System.RestContext.request.addParameter('IdentityNumber', [SELECT IdentityNumber__c FROM Account][1].IdentityNumber__c);
        system.RestContext.request.addParameter('IdentityType', 'NIF');

        test.startTest();
		XC_REST_Account.doGet();
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');
		test.stopTest();
	}


    /*
	*@ Description get Account by IdentityNumber Not Residential
	*/
    @isTest
	static void testGETAccountbyIdentityNumber(){

        System.RestContext.request = generateReqRightHeaderGET();
        System.RestContext.response = new RestResponse();
        System.RestContext.request.addParameter('IdentityNumber', [SELECT IdentityNumber__c FROM Account][1].IdentityNumber__c);
        system.debug('IdentityNumber'+  [SELECT IdentityNumber__c FROM Account][1].IdentityNumber__c);
        system.RestContext.request.addParameter('IdentityType', 'NIF');

        test.startTest();
		XC_REST_Account.doGet();
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');
		test.stopTest();
	}


    /*
	*@ Description get Account by Wrong AccountID
	*/
    @isTest
	static void testGETAccountWrong(){

        System.RestContext.request = generateReqRightHeaderGET();
        System.RestContext.response = new RestResponse();
        System.RestContext.request.headers.put('AccountID', [SELECT Id FROM Account][0].Id);

        test.startTest();
		XC_REST_Account.doGet();
        XC_REST_Account_W.WrapperResponseGET wrResp = (XC_REST_Account_W.WrapperResponseGET) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponseGET.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
		test.stopTest();
	}


	/*
	*@ Description generate right header request GET
	*/
    private static RestRequest generateReqRightHeaderGET(){
       
        RestRequest request = new RestRequest();
		
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'readAccount');
        request.addHeader('DateTimeMessage', '20191207100000039');
        request.addHeader('ClientSystem', 'Test');
        request.addHeader('ServerSystem','XCustomerB2C');  
        request.addHeader('Operation','read');  

		request.httpMethod = 'GET';
		request.requestURI = '/v1/Account/*';
        return request;
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
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
		test.stopTest();
	}


    /*
	*@ Description Wrong Header POST
	*/
    @isTest
	static void testCatchPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();
        System.RestContext.response = new RestResponse();
		
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
		test.stopTest();
	}


    /*
	*@ Description Missing Account
	*/
    @isTest
	static void testMissingAccountPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        body.Account = null;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Missing AccountType
	*/
    @isTest
	static void testMissingAccountTypePOST(){

        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
    
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Wrong Account Status POST
	*/
    @isTest
	static void testWrongAccountStatusPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populateWrapperAccount();
        wa.Status = 'Test';
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        wi[0].IdentityType = 'NIF';
        wi[0].IdentityNumber = '21643061S';
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].IdentityType = 'NIF';
        wc[0].IdentityNumber = '21643061S';
        body.Contact = wc;

        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Missing Account LastName
	*/
    @isTest
	static void testMissingAccLastNamePOST(){

        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        wa.AccountType = 'Residential';
        wa.FirstName = null;
        wa.MainPhone = null;
        wa.MainPhonePrefix = null;
        wa.LastName = null;
        body.Account = wa;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Missing Account FirstName (Residential)
	*/
    @isTest
	static void testMissingAccFirstNamePOST(){

        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        wa.FirstName = null;
        wa.MainPhone = null;
        wa.MainPhonePrefix = null;
        body.Account = wa;

        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Missing Account primaryEmail and MainPhone(Residential)
	*/
    @isTest
	static void testMissingAccFieldsPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        wa.MainPhone = null;
        wa.primaryEmail = null;
      
        body.Account = wa;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Missing Account phone prefix (Residential)
	*/
    @isTest
	static void testMissingAccPrefixPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();
        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        wa.MainPhonePrefix = null;

        body.Account = wa;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Missing Account partnerId (Partner)
	*/
    @isTest
	static void testMissingAccPartnerIdPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        wa.AccountType = 'Partner';
        body.Account = wa;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*@ Description identity section must not be filled */
    @isTest
	static void testPartnerIdentitySecPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        wa.AccountType = 'Partner';
        wa.PartnerID = '12345';
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Missing Identity (Residential)
	*/
    @isTest
	static void testMissingIdentityPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        wi[0].IdentityType = null;
        body.Identity = wi;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Missing Identity Date (Residential)
	*/
    @isTest
	static void testMissingIdentityDatePOST(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        wi[0].ReleaseDate = null;
        body.Identity = wi;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description  wrong formatDate Identity
	*/
    @isTest
	static void testWrongFormatDatePOST(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        wi[0].ReleaseDate = '2098-09-091T00:00:00';
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        body.Contact = wc;
        
        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Missing Contact (Residential)
	*/
    @isTest
	static void testMissingContactPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        body.Contact = null;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Missing Contact Last Name (Residential)
	*/
    @isTest
	static void testMissingConLastNamePOST(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].LastName = null;
        body.Contact = wc;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Missing Contact Last Name (Residential)
	*/
    @isTest
	static void testMissingConFirstNamePOST(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].FirstName = null;
        body.Contact = wc;

        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Missing Contact Last Name (Residential)
	*/
    @isTest
	static void testMissingConEmailPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].Email = null;
        body.Contact = wc;

        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*@ Description Missing Contact email and mobile (CommoditySpainB2C) */
    /*@isTest
	static void testMissingConFieldsCommodityPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();
        System.RestContext.request.headers.put('ClientSystem', 'CommoditySpainB2C');

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].Email = null;
        wc[0].MainPhone = null;
        body.Contact = wc;

        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}*/


    /*
    *@ Description Missing Contact  mobile prefix(CommoditySpainB2C)
    */
    @isTest
	static void testMissingConPrefixCommodityPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();
        System.RestContext.request.headers.put('ClientSystem', 'CommoditySpainB2C');

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].MainPhonePrefix = null;
        body.Contact = wc;

        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Missing Primary Contact 
	*/
    @isTest
	static void testNoPrimaryContactPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].PrimaryContact = false;
        body.Contact = wc;

        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Missing GDPR
	*/
    @isTest
	static void testMissingGdprPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].GDPR = null;
        body.Contact = wc;

        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Missing LEgalEntity
	*/
    @isTest
	static void testMissingLegalEntityPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        system.debug('WC'+wc);
        wc[0].GDPR.LegalEntity = null;
        body.Contact = wc;

        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Missing LegalEntity.LegalEntity
	*/
    @isTest
	static void testMissingLeLePOST(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].GDPR.LegalEntity[0].LegalEntity = null;
        body.Contact = wc;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Missing LegalEntity.GiveDataToLegalEntity 
	*/
    @isTest
	static void testMissingGDLEPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].GDPR.LegalEntity[0].GiveDataToLegalEntity = null;
        body.Contact = wc;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description  LegalEntity.GiveDataToLegalEntity != Y 
	*/
    @isTest
	static void testMissingGDLENotYPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].GDPR.LegalEntity[0].GiveDataToLegalEntity = 'N';
        body.Contact = wc;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description  Missing addressType
	*/
    @isTest
	static void testMissingStreetTypePOST(){

        System.RestContext.request = generateReqRightHeaderPOST();
        
        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        body.Contact = wc;
        List<XC_UTIL_Address.AddressWrapper>  waddr = populateWrapperAddress();
        waddr[0].StreetType = null;
        body.Address = waddr;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description  Missing delivery or billing Address with client system CommoditySpainB2C
	*/
    @isTest
	static void testMissingDeliveryAddressPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();
        System.RestContext.request.headers.put('ClientSystem', 'CommoditySpainB2C');

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        body.Contact = wc;
        List<XC_UTIL_Address.AddressWrapper>  waddr = populateWrapperAddress();
        waddr[0].AddressValidated = true;
        waddr[0].DeliveryAddress = null;
        waddr[0].BillingAddress = null;
        body.Address = waddr;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}
    

    /*
	*@ Description  Missing posType
	*/
    @isTest
	static void testMissingPosTypePOST(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        body.Contact = wc;
        List<XC_UTIL_Address.AddressWrapper>  waddr = populateWrapperAddress();
        waddr[0].PointOfService[0].POSType = null;
        body.Address = waddr;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description  Missing pos
	*/
    @isTest
	static void testMissingPosPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        body.Contact = wc;
        List<XC_UTIL_Address.AddressWrapper>  waddr = populateWrapperAddress();
        waddr[0].PointOfService[0].POS = null;
        body.Address = waddr;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description  Missing Delivery Address and Billing Address for Billing Profile
	*/
    @isTest
	static void testMissingAddressForBillingProfPOST(){


        System.RestContext.request = generateReqRightHeaderPOST();
        System.RestContext.request.headers.put('ClientSystem', 'XInstaller');


        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        body.Contact = wc;
        List<XC_UTIL_Address.AddressWrapper>  waddr = populateWrapperAddress();
        body.Address = waddr;
        waddr[0].DeliveryAddress = null;
        waddr[0].BillingAddress = null;
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = populateWrapperBillingProfile();
        body.BillingProfile = wbp;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description  Missing PaymentMethod Billing Profile
	*/
    @isTest
	static void testMissingPaymentMethodPOST(){


        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        body.Contact = wc;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = populateWrapperBillingProfile();
        wbp[0].PaymentMethod = null;
        body.BillingProfile = wbp;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*
	*@ Description  Missing InvoicePreferredLanguage Billing Profile
	*/
    @isTest
	static void testMissingInvPrefLangdPOST(){


        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        body.Contact = wc;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = populateWrapperBillingProfile();
        wbp[0].InvoicePreferredLanguage = null;
        body.BillingProfile = wbp;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*
	*@ Description  Missing InvoiceDeliveryPref Billing Profile
	*/
    @isTest
	static void testMissingInvDelPrefdPOST(){


        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        body.Contact = wc;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = populateWrapperBillingProfile();
        wbp[0].InvoiceDeliveryPref = null;
        body.BillingProfile = wbp;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }

    
    /*
	*@ Description  Missing LegalEntity Billing Profile
	*/
    @isTest
	static void testMissinglegalEnBillingProfPOST(){


        System.RestContext.request = generateReqRightHeaderPOST();
        System.RestContext.request.headers.put('ClientSystem', 'XInstaller');

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        body.Contact = wc;
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = populateWrapperBillingProfile();
        wbp[0].LegalEntity = null;
        body.BillingProfile = wbp;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }

    
    /*
	*@ Description  Missing Shipping and Billing Contact POST
	*/
    @isTest
	static void testMissingContactFieldsPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();
        missingContactFieldUtil();

        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
	}



    /*
	*@ Description Wrong Header PUT
	*/
    @isTest
	static void testWrongHeaderPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();
        String trasaction = System.RestContext.request.headers.remove('TransactionID');
        System.RestContext.request.requestBody = Blob.valueOf('{}');
        System.RestContext.response = new RestResponse();
		
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
		test.stopTest();
	}

    /*
	*@ Description Wrong Header PUT
	*/
    @isTest
	static void testCatchPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();
        System.RestContext.response = new RestResponse();
		
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
		test.stopTest();
	}

     /*
	*@ Description  Missing AccountID and Email PUT
	*/
    @isTest
	static void testMissingAccIdEmailPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        wa.AccountID = null;
        wa.PrimaryEmail = null;
        body.Account = wa;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }

    /*
	*@ Description  Missing Shipping/ Billing Contact PUT
	*/
    @isTest
	static void testMissingShippingBillingConPUT(){


        System.RestContext.request = generateReqRightHeaderPUT();
        System.RestContext.request.headers.put('ClientSystem', 'CommoditySpainB2C');

        missingContactFieldUtil();

        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }

    /*
	*@ Description  Empty LastName Contact PUT
	*/
    @isTest
	static void testEmptyLastNameConPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].ContactID = [SELECT Id FROM Contact][0].Id;
        wc[0].LastName = '  ';
        body.Contact = wc;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*
	*@ Description  Empty email/mainPhone (CommoditySpainB2C) PUT
	*/
    @isTest
	static void testEmptyEmailmainPhoneConPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();
        System.RestContext.request.headers.put('ClientSystem', 'CommoditySpainB2C');

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].ContactID = [SELECT Id FROM Contact][0].Id;
        wc[0].Email = '  ';
        wc[0].MainPhone = '  ';
        body.Contact = wc;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*
	*@ Description  Empty mainPhonePrefix (CommoditySpainB2C) PUT
	*/
    @isTest
	static void testEmptyMainPhonePrefixConPUT(){


        System.RestContext.request = generateReqRightHeaderPUT();
        System.RestContext.request.headers.put('ClientSystem', 'CommoditySpainB2C');

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        wa.AccountId = [SELECT Id FROM Account][0].Id;
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].ContactID = [SELECT Id FROM Contact][0].Id;
        wc[0].MainPhonePrefix = '  ';
        body.Contact = wc;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*
	*@ Description  Empty email PUT
	*/
    @isTest
	static void testEmptyEmailConPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        wa.AccountId = [SELECT Id FROM Account][0].Id;
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].ContactID = [SELECT Id FROM Contact][0].Id;
        wc[0].Email = '  ';
        body.Contact = wc;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*
	*@ Description  Empty legalEntity PUT
	*/
    @isTest
	static void testEmptyLegalEntityConPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        wa.AccountId = [SELECT Id FROM Account][0].Id;
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].ContactID = [SELECT Id FROM Contact][0].Id;
        wc[0].GDPR.legalEntity[0].legalEntity = '  ';
        body.Contact = wc;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*
	*@ Description  Empty give data to legalEntity PUT
	*/
    @isTest
	static void testEmptyGiveDatatoLegalEntityConPUT(){


        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        wa.AccountId = [SELECT Id FROM Account][0].Id;
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].ContactID = [SELECT Id FROM Contact][0].Id;
        wc[0].GDPR.legalEntity[0].GiveDataToLegalEntity = '  ';
        body.Contact = wc;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*
	*@ Description  False give data to legalEntity PUT
	*/
    @isTest
	static void testFalseGiveDatatoLegalEntityConPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        wa.AccountId = [SELECT Id FROM Account][0].Id;
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].ContactID = [SELECT Id FROM Contact][0].Id;
        wc[0].GDPR.legalEntity[0].GiveDataToLegalEntity = 'N';
        body.Contact = wc;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*
	*@ Description  empty address field
	*/
    @isTest
	static void testEmptyAddressFieldPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        wa.AccountId = [SELECT Id FROM Account][0].Id;
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        body.Contact = wc;
        List<XC_UTIL_Address.AddressWrapper>  waddr = populateWrapperAddress();
        waddr[0].AddressID = [SELECT Id FROM XC_Address__c][0].Id;
        waddr[0].StreetType = '  ';
        body.Address = waddr;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*
	*@ Description  empty pos field
	*/
    @isTest
	static void testEmptyPosFieldPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        wa.AccountId = [SELECT Id FROM Account][0].Id;
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        body.Contact = wc;
        List<XC_UTIL_Address.AddressWrapper>  waddr = populateWrapperAddress();
        XC_Address__c addr = [SELECT Id, (SELECT Id FROM Points_of_Service__r) FROM XC_Address__c][0];
        waddr[0].AddressID = addr.Id;
        waddr[0].PointOfService[0].POSID = addr.Points_of_Service__r[0].Id;
        waddr[0].PointOfService[0].POS = '   ';
        body.Address = waddr;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*
	*@ Description  empty posType field
	*/
    @isTest
	static void testEmptyPosTypeFieldPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        wa.AccountId = [SELECT Id FROM Account][0].Id;
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        body.Contact = wc;
        List<XC_UTIL_Address.AddressWrapper>  waddr = populateWrapperAddress();
        XC_Address__c addr = [SELECT Id, (SELECT Id FROM Points_of_Service__r) FROM XC_Address__c][0];
        waddr[0].AddressID = addr.Id;
        waddr[0].PointOfService[0].POSID = addr.Points_of_Service__r[0].Id;
        waddr[0].PointOfService[0].POSType = '   ';
        body.Address = waddr;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*@ Description  empty PaymentMethod field */
    @isTest
	static void testEmptyPaymentMethodFieldPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
        wa.AccountId = [SELECT Id FROM Account][0].Id;
        body.Account = wa;
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = populateWrapperBillingProfile();
        wbp[0].BillingProfileID = [SELECT Id FROM NE__Billing_Profile__c][0].Id;
        wbp[0].PaymentMethod = '  ';
        body.BillingProfile = wbp;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*@ Description empty InvoicePreferredLanguage field */
    @isTest
	static void testEmptyInvoicePreferredLanguageFieldPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
        wa.AccountId = [SELECT Id FROM Account][0].Id;
        body.Account = wa;
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = populateWrapperBillingProfile();
        wbp[0].BillingProfileID = [SELECT Id FROM NE__Billing_Profile__c][0].Id;
        wbp[0].InvoicePreferredLanguage = '  ';
        body.BillingProfile = wbp;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*@ Description  empty InvoiceDeliveryPref field */
    @isTest
	static void testEmptyInvoiceDeliveryPrefLanguageFieldPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
        wa.AccountId = [SELECT Id FROM Account][0].Id;
        body.Account = wa;
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = populateWrapperBillingProfile();
        wbp[0].BillingProfileID = [SELECT Id FROM NE__Billing_Profile__c][0].Id;
        wbp[0].InvoiceDeliveryPref = '  ';
        body.BillingProfile = wbp;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*@ Description check language for account */
    @isTest
	static void testLanguageForAccount(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
        wa.AccountId = [SELECT Id FROM Account WHERE XC_AccountMainPhone__c =: '678989847'][0].Id;
        wa.PreferenceLanguage = 'English';
        body.Account = wa;
        body.Address = null;
        body.BillingProfile = null;
        body.Identity = null;
        body.Contact = null;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }

    
    /*@ Description check language for contact */
    @isTest
	static void testLanguageForContact(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
        List<Account> accList =  [SELECT Id, (SELECT Id FROM Contacts) FROM Account LIMIT 1];
        wa.AccountId = accList[0].Id;
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].GDPR = null;
        wc[0].ContactID = accList[0].Contacts[0].Id;
        wc[0].PreferenceLanguage = 'English';
        body.Contact = wc;
        //body.Address = null;
        body.BillingProfile = null;
        //body.Identity = null;

        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        List<XC_UTIL_Address.AddressWrapper>  waddr = populateWrapperAddress();
        body.Address = waddr;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*@ Description createObjectFromWrapper */
    @isTest
	static void testCreateObjectFromWrapper(){

        List<User> user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId()];
        user[0].XC_EnabledToSkip__c = true;
        update user;
       
        System.runAs(user[0]){
            test.startTest();
            System.RestContext.request = generateReqRightHeaderPOST();

            XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
            XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
            Account acc = [SELECT Id FROM Account][0];
            wa.AccountID = acc.Id;
            body.Account = wa;
            acc.XC_DocumentCountry__c = 'United Kingdom';
            update acc; 
            List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
            body.Contact = wc;
            List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = populateWrapperBillingProfile();
            wbp[0].CreditCardType = 'Visa';
            wbp[0].ExpirationMonth = '12';
            wbp[0].ExpirationYear = '19';
            wbp[0].CreditCardLastFourNumber = '0027';
            wbp[0].CreditCardExternalKey = '12234';
            wbp[0].Token = '12234';

            body.BillingProfile = wbp;
            List<XC_UTIL_Address.AddressWrapper> waddr =  populateWrapperAddress();
            body.Address = waddr;
            List<XC_UTIL_Account.IdentityIFWrapper>  wi = populateWrapperIdentity();
            body.Identity = wi;

            System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
            System.RestContext.response = new RestResponse();
            
            Zuora_OAuth__c zuoraAccess = new Zuora_OAuth__c (Client_Id__c = '1234', Client_Secret__c = '456', EntityId__c = '8393', Host__c = 'restZuora', apiToken__c = '383983djdk00', EntityName__c ='Enel Spain B2C');
            insert zuoraAccess;  

           // test.startTest();
            Test.setMock(HttpCalloutMock.class, new CallZuora_Mock());
            XC_REST_Account.doPost();
            XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
            //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
            test.stopTest();
        }
    }


     /*@ Description testDuplicateEmailCOmmodity */
    @isTest
	static void testDuplicateEmailCOmmodity(){
        List<User> user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId()];
        user[0].XC_EnabledToSkip__c = true;
        update user;
       
        System.runAs(user[0]){
            test.startTest();
            
            System.RestContext.request = generateReqRightHeaderPOST();
            System.RestContext.request.headers.put('ClientSystem', 'CommoditySpainB2C');

            XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
            XC_UTIL_Account.AccountIFWrapper wa = populateWrapperAccount();
            wa.PrimaryEmail = [SELECT Id, PrimaryEmail__c FROM Account LIMIT 1][0].PrimaryEmail__c;
            body.Account = wa;
            List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
            body.Contact = wc;
            List<XC_UTIL_Address.AddressWrapper> waddr =  populateWrapperAddress();
            body.Address = waddr;
            List<XC_UTIL_Account.IdentityIFWrapper>  wi = populateWrapperIdentity();
            body.Identity = wi;

            System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
            System.RestContext.response = new RestResponse();

            
            XC_REST_Account.doPost();
            XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
            test.stopTest();
        }
    }


    /*@ Description createObjectFromWrapper Residential Account*/
    @isTest
	static void testCreateObjectFromWrapperU(){
        List<User> user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId()];
        user[0].XC_EnabledToSkip__c = true;
        update user;
       
        System.runAs(user[0]){
            test.startTest();
            System.RestContext.request = generateReqRightHeaderPUT();

            XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
            XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
            Account acc = [SELECT Id FROM Account][0];
            wa.AccountID = acc.Id;
            body.Account = wa;
            acc.XC_DocumentCountry__c = 'United Kingdom';
            update acc; 
            List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
            wc[0].IdentityType = 'NIF';
            wc[0].IdentityNumber = '74042149C';
            wc[0].ReleaseDate = '2017-01-01';
            wc[0].ExpiryDate = '3040-01-01';
            body.Contact = wc;
            List<XC_UTIL_Address.AddressWrapper> waddr =  populateWrapperAddress();
            body.Address = waddr;
            List<XC_UTIL_Account.IdentityIFWrapper>  wi = populateWrapperIdentity();
            List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = populateWrapperBillingProfile();
            wbp[0].BillingProfileID = [SELECT Id FROM NE__Billing_Profile__c][0].Id;
            body.BillingProfile = wbp;

            System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
            System.RestContext.response = new RestResponse();
            
        
            XC_REST_Account.doPut();
            XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
            //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
            test.stopTest();
        }
    }


    /*@ Description create PaymentMethod - SEPA */
    @isTest
	static void testCreatePaymentMethodSepa(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
        wa.AccountID = [SELECT Id FROM Account][0].Id;
        body.Account = wa;
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = populateWrapperBillingProfile();
        wbp[0].PaymentMethod = 'SEPA';
        wbp[0].IBAN = 'ES1900817145331485214651';
        body.BillingProfile = wbp;
        body.Contact = null;
        body.Address = null;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        Zuora_OAuth__c zuoraAccess = new Zuora_OAuth__c (Client_Id__c = '1234', Client_Secret__c = '456', EntityId__c = '8393', Host__c = 'restZuora', apiToken__c = '383983djdk00', EntityName__c ='Enel Spain B2C');
        insert zuoraAccess;  

  
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CallZuora_Mock());
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        //System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*@ Description create PaymentMethod - CommodityBill */
    /*@isTest
	static void testCreatePaymentMethodCommodityBill(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
        wa.AccountID = [SELECT Id FROM Account][0].Id;
        body.Account = wa;
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = populateWrapperBillingProfile();
        wbp[0].PaymentMethod = 'Commodity Bill';
        wbp[0].CupsID = '9889878765676567';
        wbp[0].CommodityContractNum = '12343';
        body.BillingProfile = wbp;
        body.Contact = null;
        body.Address = null;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        Zuora_OAuth__c zuoraAccess = new Zuora_OAuth__c (Client_Id__c = '1234', Client_Secret__c = '456', EntityId__c = '8393', Host__c = 'restZuora', apiToken__c = '383983djdk00', EntityName__c ='Enel Spain B2C');
        insert zuoraAccess;  

  
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CallZuora_Mock());
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        //System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }*/
    

    /*@ Description create Account Guest FromWrapper */
    @isTest
	static void testCreateAccountGuestFromWrapper(){
        List<User> user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId()];
        user[0].XC_EnabledToSkip__c = true;
        update user;
       
        System.runAs(user[0]){
            test.startTest();
            System.RestContext.request = generateReqRightHeaderPOST();

            XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
            XC_UTIL_Account.AccountIFWrapper wa = populateWrapperAccount();
            wa.AccountType = 'Small Business';
            wa.RegisteredOnRechargeApp = false;
            wa.PrimaryEmail = 'test@enel.app.com';
            body.Account = wa;
            List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
            body.Contact = wc;
            /*List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = populateWrapperBillingProfile();
            body.BillingProfile = wbp;
            body.Address = null;
            /*List<XC_UTIL_Address.AddressWrapper> waddr =  populateWrapperAddress();
            body.Address = waddr;*/
            List<XC_UTIL_Account.IdentityIFWrapper>  wi = populateWrapperIdentity();
            body.Identity = wi;

            System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
            System.RestContext.response = new RestResponse();
            
        // test.startTest();
            XC_REST_Account.doPost();
            XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
            //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
            test.stopTest();
        }
    }


    /*@ Description update an Identity - Missing identityID */
    @isTest
	static void testMissingIdentityIdPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
        wa.AccountID = [SELECT Id FROM Account][1].Id ;
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper>  wi = populateWrapperIdentity();
        body.Identity = wi;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*@ Description create an Identity - Missing IdentityType */
    @isTest
	static void testMissingIdentityTypePUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
        wa.AccountID = [SELECT Id FROM Account][0].Id ;
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper>  wi = populateWrapperIdentity();
        wi[0].IdentityType = null;
        body.Identity = wi;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }

    
    /*@ Description duplication check with identity Number !Residential - !whereCondition */
    @isTest
	static void testDuplicationCheckIdenNumbPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populateWrapperAccount();
        wa.AccountType = 'Small Business';
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        wi[0].IdentityType = 'NIF';
        wi[0].IdentityNumber = '10080737K';
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].IdentityType = 'NIF';
        wc[0].IdentityNumber = '10080737K';
        body.Contact = wc;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(503, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*@ Description duplication check with identity Number !Residential - !whereCondition */
    @isTest
	static void testDuplicationCheckIdenNumbUPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populateWrapperAccount();
        wa.primaryEmail = null;
        wa.AccountType = 'Small Business';
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        wi[0].IdentityType = 'NIF';
        wi[0].IdentityNumber = '10080737K';
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].IdentityType = 'NIF';
        wc[0].IdentityNumber = '10080737K';
        body.Contact = wc;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
       XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(503, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*@ Description duplication check with identity Number Residential*/
    @isTest
	static void testDuplicationCheckIdenNumbResPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populateWrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        wi[0].IdentityType = 'NIF';
        wi[0].IdentityNumber = '51142871W';
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].IdentityType = 'NIF';
        wc[0].IdentityNumber = '51142871W';
        body.Contact = wc;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(503, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*@ Description duplication check with identity Number Residential*/
    @isTest
	static void testDuplicationCheckIdenNumbResUPOST(){

        System.RestContext.request = generateReqRightHeaderPOST();


        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populateWrapperAccount();
        wa.PrimaryEmail = 'test@email.com';
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        wi[0].IdentityType = 'NIF';
        wi[0].IdentityNumber = '30377810P';
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].IdentityType = 'NIF';
        wc[0].IdentityNumber = '30377810P';
        body.Contact = wc;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        //System.assertEquals(501, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }

    /*@ Description duplication check with identity Number Residential 503*/
    @isTest
	static void testDuplicationCheckIdenNumbResU2POST(){

        System.RestContext.request = generateReqRightHeaderPOST();


        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populateWrapperAccount();
        wa.PrimaryEmail = [SELECT PrimaryEmail__c FROM Account WHERE IdentityNumber__c = '10080737K'][0].PrimaryEmail__c;
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        wi[0].IdentityType = 'NIF';
        wi[0].IdentityNumber = '51142871W';
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].IdentityType = 'NIF';
        wc[0].IdentityNumber = '51142871W';
        body.Contact = wc;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
       
        test.stopTest();
    }


    /*@ Description duplication check with identity Number !Residential*/
    @isTest
	static void testDuplicationCheckIdenNumbPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
        wa.AccountID = [SELECT Id FROM Account WHERE IdentityNumber__c = '01707797T'][0].Id;
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper>  wi = populateWrapperIdentity();
        wi[0].IdentityType = 'NIF';
        wi[0].IdentityNumber = '10080737K';
        wi[0].IdentityID = wa.AccountID;
        body.Identity = wi;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        //System.assertEquals(501, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*@ Description duplication check with identity Number !Residential- whereCondition PUT*/
    @isTest
	static void testDuplicationCheckIdenNumbUPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
        wa.PrimaryEmail = 'test@email.com';
        wa.AccountID = [SELECT Id FROM Account WHERE IdentityNumber__c = '01707797T'][0].Id;
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper>  wi = populateWrapperIdentity();
        wi[0].IdentityType = 'NIF';
        wi[0].IdentityNumber = '10080737K';
        wi[0].IdentityID = wa.AccountID;
        body.Identity = wi;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        //System.assertEquals(501, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*@ Description duplication check with identity Number PUT Residential*/
    @isTest
	static void testDuplicationCheckIdenNumbResPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populateWrapperAccount();
        wa.AccountID = [SELECT Id, (SELECT Id, XC_DocumentNumber__c FROM Personal_Documents__r) FROM Account WHERE  Id IN (SELECT XC_Account__c FROM XC_PersonalDocument__c WHERE XC_DocumentNumber__c = '30377810P') ][0].Id;
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        wi[0].IdentityType = 'NIF';
        wi[0].IdentityNumber = '51142871W';
        body.Identity = wi;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        //System.assertEquals(501, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*@ Description duplication check with identity Number - !whereCondition PUT Residential*/
    @isTest
	static void testDuplicationCheckIdenNumbResUPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populateWrapperAccount();
        wa.primaryEmail = null;
        wa.AccountID = [SELECT Id, (SELECT Id, XC_DocumentNumber__c FROM Personal_Documents__r) FROM Account WHERE  Id IN (SELECT XC_Account__c FROM XC_PersonalDocument__c WHERE XC_DocumentNumber__c = '30377810P') ][0].Id;
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        wi[0].IdentityType = 'NIF';
        wi[0].IdentityNumber = '51142871W';
        body.Identity = wi;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        //System.assertEquals(501, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*@ Description manage Identity  */
    @isTest
	static void testManageIdentityPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
        wa.AccountID = [SELECT Id FROM Account WHERE IdentityNumber__c = '01707797T'][0].Id;
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        wi[0].IdentityID = wa.AccountID;
        wi[0].Country = null;
        wi[0].IdentityType = null;
        wi[0].IdentityNumber = null;
        body.Identity = wi;
        body.Contact = null;
        body.Address = null;
        body.BillingProfile = null;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }



      /*@ Description  testManageDuplicateAddressPUT  */
    @isTest
	static void testManageDuplicateAddressPUT(){

        List<Account> accList = [SELECT Id FROM Account WHERE IdentityNumber__c = '01707797T' limit 1];
        List<XC_Address__c> addrList = XC_DF_Address.createAddress(accList);
        addrList[0].XC_AddressProvince__c  = 'Madrid';
        addrList[0].XC_StreetTypeText__c = addrList[0].XC_StreetType__c;
        addrList[0].XC_Municipality__c  = 'Madrid';
        insert addrList;

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
        wa.AccountID = accList[0].id;
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = null;
        body.Identity = wi;

        List<XC_UTIL_Address.AddressWrapper> addrwr = populateWrapperAddress();
        addrwr[0].StreetType = addrList[0].XC_StreetType__c;
        addrwr[0].Address =  addrList[0].XC_Address__c;
        addrwr[0].StreetNumber =  addrList[0].XC_StreetNumber__c;
        addrwr[0].ZipCode =  addrList[0].XC_PostalCode__c;
        addrwr[0].City =  addrList[0].XC_City__c;
        addrwr[0].Country = addrList[0].XC_AddressCountry__c;
        addrwr[0].Province =  addrList[0].XC_AddressProvince__c;
        addrwr[0].Municipality =  addrList[0].XC_Municipality__c;

        body.Address = addrwr;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
    
        test.stopTest();
    }




    /*@ Description Account not found PUT  */
    @isTest
	static void testAccountNotFoundPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
        wa.PrimaryEmail = 'testAcc@email.it';
        body.Account = wa;
    
        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();

        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(404, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }
   

    /*@ DescriptionIdentity does not exists PUT  */
    @isTest
	static void testIdentityDoesNotExistPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
        wa.AccountID = [SELECT Id FROM Account][0].Id;
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        wi[0].IdentityID = [SELECT Id FROM XC_PersonalDocument__c WHERE  XC_DocumentNumber__c = '30377810P'][0].Id;
        body.identity = wi;
    
        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*@ Description Contact does not exists PUT  */
    @isTest
	static void testContactDoesNotExistPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
        wa.AccountID = [SELECT Id FROM Account][1].Id;
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].ContactID = [SELECT Id FROM Contact][0].Id;
        body.Contact = wc;
        body.Identity = null;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*@ Description Address does not exists PUT  */
    @isTest
	static void testAddressDoesNotExistPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
        wa.AccountID = [SELECT Id FROM Account][1].Id;
        body.Account = wa;
        body.Identity = null;
        body.Contact = null;
        List<XC_UTIL_Address.AddressWrapper> waddr =  populateWrapperAddress();
        waddr[0].AddressID = [SELECT Id FROM XC_Address__c][0].Id;
        body.Address = waddr;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*@ Description Billing Profile does not exists PUT */
    @isTest
	static void testBillingProfileDoesNotExistPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
        wa.AccountID = [SELECT Id FROM Account][1].Id;
        body.Account = wa;
        body.Identity = null;
        body.Contact = null;
        List<XC_UTIL_Address.AddressWrapper> waddr =  populateWrapperAddress();
        body.Address = waddr;
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = populateWrapperBillingProfile();
        wbp[0].BillingProfileID = [SELECT Id FROM NE__Billing_Profile__c][0].Id;
        body.BillingProfile = wbp;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }

    
    /*@ Description Wrong Status PUT */
    @isTest
	static void testWrongStatusPUT(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
        wa.AccountID = [SELECT Id FROM Account][0].Id;
        wa.Status = 'test';
        wa.PrimaryEmail = 'qwertyuuiopasdfgglkjh@email.com';
        body.Account = wa;
    
        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        //System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*@ Description Wrong PhonePrefix - 500 In contact Section */
    @isTest
	static void testWrongPhonePrefix(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populateWrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].PhonePrefix = 'test';
        body.Contact = wc;
        List<XC_UTIL_Account.IdentityIFWrapper>  wi = populateWrapperIdentity();
        body.Identity = wi;
    
        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }
    

    /*@ Description Wrong LegalEntity - 500 In LegalEntity Section */
    @isTest
	static void testWrongLegalEntity(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populateWrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        XC_UTIL_Account.LegalEntityWrapper  leWr = new XC_UTIL_Account.LegalEntityWrapper();
        leWr.LegalEntity = 'Test'; 
        leWr.GiveDataToLegalEntity = 'Y'; 
        leWr.GiveDataForMarketing = 'Y'; 
        wc[0].GDPR.LegalEntity.add(leWr);
       
        body.Contact = wc;
        List<XC_UTIL_Account.IdentityIFWrapper>  wi = populateWrapperIdentity();
        body.Identity = wi;
    
        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*@ Description Wrong CountryAddress - 500 In Address Section */
    @isTest
	static void testWrongCountryAddress(){
        List<User> user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId()];
        user[0].XC_EnabledToSkip__c = true;
        update user;
       
        System.runAs(user[0]){
            test.startTest();
        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populateWrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        wi[0].IdentityType = 'NIF';
        wi[0].IdentityNumber = '21643061S';
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].IdentityType = 'NIF';
        wc[0].IdentityNumber = '21643061S';
        body.Contact = wc;
        List<XC_UTIL_Address.AddressWrapper> waddr =  populateWrapperAddress();
        waddr[0].Country = 'Test';
        body.Address = waddr;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
      //  test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
        }
    }


    /*@ Description Wrong PosType Address - 500 In POS Section */
    @isTest
	static void testWrongPosTypeAddress(){
        List<User> user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId()];
        user[0].XC_EnabledToSkip__c = true;
        update user;
       
        System.runAs(user[0]){
            test.startTest();
            System.RestContext.request = generateReqRightHeaderPOST();

            XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
            XC_UTIL_Account.AccountIFWrapper wa = populateWrapperAccount();
            body.Account = wa;
            List<XC_UTIL_Account.IdentityIFWrapper>  wi = populateWrapperIdentity();
            body.Identity = wi;
            List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
            body.Contact = wc;
            List<XC_UTIL_Address.AddressWrapper> waddr =  populateWrapperAddress();
            waddr[0].PointOfService[0].POSType = 'Test';
            body.Address = waddr;

            System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
            System.RestContext.response = new RestResponse();
            
           // test.startTest();
            XC_REST_Account.doPost();
            XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
            //System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
            test.stopTest();
        }
    }


    /*@ Description Wrong Invoice Delivery Pref - 500 In Billing Profile Section */
    @isTest
	static void testWrongInvoiceDeliveryPref(){
        List<User> user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId()];
        user[0].XC_EnabledToSkip__c = true;
        update user;
       
        System.runAs(user[0]){
            test.startTest();
            System.RestContext.request = generateReqRightHeaderPOST();

            XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
            XC_UTIL_Account.AccountIFWrapper wa = populateWrapperAccount();
            body.Account = wa;
            List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
            body.Contact = wc;
            List<XC_UTIL_Account.IdentityIFWrapper>  wi = populateWrapperIdentity();
            body.Identity = wi;
            List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = populateWrapperBillingProfile();
            wbp[0].InvoiceDeliveryPref = 'Test';
            body.BillingProfile = wbp;
            List<XC_UTIL_Address.AddressWrapper> waddr =  populateWrapperAddress();
            body.Address = waddr;

            System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
            System.RestContext.response = new RestResponse();
            
           // test.startTest();
            XC_REST_Account.doPost();
            XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
           // System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
            test.stopTest();
        }
    }


    /*@ Description Missing Address to associate with BillingProfile */
    @isTest
	static void testMissingAddressToAssociateToBp(){

        System.RestContext.request = generateReqRightHeaderPUT();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
        wa.AccountID = [SELECT Id FROM Account][1].Id;
        body.Account = wa;
        body.Identity = null;
        body.Address = null;
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = populateWrapperBillingProfile();
        body.BillingProfile = wbp;


        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPut();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*@ Description New billingProfile without Address section*/
    @isTest
	static void testValidateBillingProfileWithoutAddress(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populateWrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        body.Contact = wc;
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = populateWrapperBillingProfile();
        body.BillingProfile = wbp;


        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    /*@ Description wrong - Customer Account  */
    /*@isTest
	static void testWrongCustomerAccountZuora(){
        
        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populateWrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].IdentityType = 'NIF';
        wc[0].IdentityNumber = '69300622N';
        body.Contact = wc;
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = populateWrapperBillingProfile();
        wbp[0].CreditCardType = 'Visa';
        wbp[0].ExpirationMonth = '12';
        wbp[0].ExpirationYear = '19';
        wbp[0].CreditCardLastFourNumber = '0027';
        wbp[0].CreditCardExternalKey = '12234';
        wbp[0].Token = '12234';

        body.BillingProfile = wbp;
        List<XC_UTIL_Address.AddressWrapper> waddr =  populateWrapperAddress();
        body.Address = waddr;
        List<XC_UTIL_Account.IdentityIFWrapper>  wi = populateWrapperIdentity();
        body.Identity = wi;

        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
        System.RestContext.response = new RestResponse();
        
        Zuora_OAuth__c zuoraAccess = new Zuora_OAuth__c (Client_Id__c = '1234', Client_Secret__c = '456', EntityId__c = '8393', Host__c = 'restZuora', apiToken__c = '383983djdk00', EntityName__c ='Enel Spain B2C');
        insert zuoraAccess;  

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CallZuoraWrongCustomerAcc_Mock());
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }*/


    /*@ Description wrong - Payment Method  */
    @isTest
	static void testWrongPaymentMethodZuora(){
        List<User> user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId()];
        user[0].XC_EnabledToSkip__c = true;
        update user;
       
        System.runAs(user[0]){
                test.startTest();
            System.RestContext.request = generateReqRightHeaderPOST();

             XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
            XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
            Account acc = [SELECT Id FROM Account][0];
            wa.AccountID = acc.Id;
            body.Account = wa;
            acc.XC_DocumentCountry__c = 'United Kingdom';
            update acc; 
            List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
            body.Contact = wc;
            List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = populateWrapperBillingProfile();
            wbp[0].CreditCardType = 'Visa';
            wbp[0].ExpirationMonth = '12';
            wbp[0].ExpirationYear = '19';
            wbp[0].CreditCardLastFourNumber = '0027';
            wbp[0].CreditCardExternalKey = '12234';
            wbp[0].Token = '12234';

            body.BillingProfile = wbp;
            List<XC_UTIL_Address.AddressWrapper> waddr =  populateWrapperAddress();
            body.Address = waddr;
            List<XC_UTIL_Account.IdentityIFWrapper>  wi = populateWrapperIdentity();
            body.Identity = wi;

            System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
            System.RestContext.response = new RestResponse();
            
            Zuora_OAuth__c zuoraAccess = new Zuora_OAuth__c (Client_Id__c = '1234', Client_Secret__c = '456', EntityId__c = '8393', Host__c = 'restZuora', apiToken__c = '383983djdk00', EntityName__c ='Enel Spain B2C');
            insert zuoraAccess;  

            //test.startTest();
            Test.setMock(HttpCalloutMock.class, new CallZuoraWrongPaymentMethod_Mock());
            XC_REST_Account.doPost();
            XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
            //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
            test.stopTest();
        }

    }


    /*@ Description wrong - Payment Method  */
    @isTest
	static void testWrongLinkAccountPaymentMethodZuora(){
        List<User> user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId()];
        user[0].XC_EnabledToSkip__c = true;
        update user;
       
        System.runAs(user[0]){
            test.startTest();
            System.RestContext.request = generateReqRightHeaderPOST();

            XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
            XC_UTIL_Account.AccountIFWrapper wa = new XC_UTIL_Account.AccountIFWrapper();
            Account acc = [SELECT Id FROM Account][0];
            wa.AccountID = acc.Id;
            body.Account = wa;
            acc.XC_DocumentCountry__c = 'United Kingdom';
            update acc; 
            
            List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
            body.Contact = wc;
            List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = populateWrapperBillingProfile();
            wbp[0].CreditCardType = 'Visa';
            wbp[0].ExpirationMonth = '12';
            wbp[0].ExpirationYear = '19';
            wbp[0].CreditCardLastFourNumber = '0027';
            wbp[0].CreditCardExternalKey = '12234';
            wbp[0].Token = '12234';

            body.BillingProfile = wbp;
            List<XC_UTIL_Address.AddressWrapper> waddr =  populateWrapperAddress();
            body.Address = waddr;
            List<XC_UTIL_Account.IdentityIFWrapper>  wi = populateWrapperIdentity();
            body.Identity = wi;

            System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
            System.RestContext.response = new RestResponse();
            
            Zuora_OAuth__c zuoraAccess = new Zuora_OAuth__c (Client_Id__c = '1234', Client_Secret__c = '456', EntityId__c = '8393', Host__c = 'restZuora', apiToken__c = '383983djdk00', EntityName__c ='Enel Spain B2C');
            insert zuoraAccess;  

           // test.startTest();
            Test.setMock(HttpCalloutMock.class, new CallZuoraWrongLinkAccToPayment_Mock());
            XC_REST_Account.doPost();
            XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
            //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
            test.stopTest();
        }
    }


    /*
	*@ Description util missing contact fields 
	*/
    private static void missingContactFieldUtil(){

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.IdentityIFWrapper> wi = populateWrapperIdentity();
        body.Identity = wi;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        wc[0].BillingContact = false;
        wc[0].ShippingContact = false;
        body.Contact = wc;
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = populateWrapperBillingProfile();
        body.BillingProfile = wbp;
        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));
    }


    /*
	*@ Description generate right header request POST
	*/
    private static RestRequest generateReqRightHeaderPOST(){
       
        RestRequest request = new RestRequest();
		
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'createAccount');
        request.addHeader('DateTimeMessage', '20191207100000039');
        request.addHeader('ClientSystem', 'XRecharge');
        request.addHeader('ServerSystem','XCustomerB2C');  
        request.addHeader('Operation','create');  

		request.httpMethod = 'POST';
		request.requestURI = '/v1/Account/*';
        return request;
    }


    /*
	*@ Description generate right header request PUT
	*/
    private static RestRequest generateReqRightHeaderPUT(){
       
        RestRequest request = new RestRequest();
		
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'updateAccount');
        request.addHeader('DateTimeMessage', '20191207100000039');
        request.addHeader('ClientSystem', 'XRecharge');
        request.addHeader('ServerSystem','XCustomerB2C');  
        request.addHeader('Operation','update');  

		request.httpMethod = 'PUT';
		request.requestURI = '/v1/Account/*';
        return request;
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

        return wa;
    }


    /*
	*@ Description populate wrapperIdentity POST
	*/
    public static List<XC_UTIL_Account.IdentityIFWrapper> populateWrapperIdentity(){

        List<XC_UTIL_Account.IdentityIFWrapper> wiList = new List<XC_UTIL_Account.IdentityIFWrapper>();
        XC_UTIL_Account.IdentityIFWrapper wi = new XC_UTIL_Account.IdentityIFWrapper();

        wi.Country = 'Spain';
        wi.IdentityType = 'NIE';
        wi.IdentityNumber = 'Y2600201L';
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
        conWr.MainPhonePrefix = '+34';
        conWr.MainPhone = '678787659';
        conWr.ShippingContact = true;
        conWr.BillingContact = true;
        conWr.IdentityType = 'NIF';
        conWr.IdentityNumber = '45232922H';
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

            } else if(req.getEndpoint().endsWith('/v1/object/payment-method')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"Errors":null, "Id":"a0002", "Success":true, "ZuoraAccountId":null}');
                response.setStatusCode(200); 

            } else if(req.getEndpoint().endsWith('/v1/object/account/a0001')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"Errors":null, "Id":"a0001", "Success":true}');
                response.setStatusCode(200); 

            }
            return response;
        }
    }


    /*
	*@ Description mock class to call zuora - wrong customer account
	*/
    public without sharing class CallZuoraWrongCustomerAcc_Mock implements HttpCalloutMock {
        public HttpResponse respond (HTTPRequest req){
            HttpResponse response = new HttpResponse();

            if(req.getEndpoint().endsWith('/v1/accounts')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"success":false,"reasons":[{"code":50000090,"message":"error"}]}');
                response.setStatusCode(200); 
            } 
            return response;
        }
    }


    /*
	*@ Description mock class to call zuora - wrong payment method
	*/
    public without sharing class CallZuoraWrongPaymentMethod_Mock implements HttpCalloutMock {
        public HttpResponse respond (HTTPRequest req){
            HttpResponse response = new HttpResponse();

            if(req.getEndpoint().endsWith('/v1/accounts')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"accountId":"a0001", "accountNumber":"A01807438", "paymentMethodId":null, "processId":null, "reasons":null, "success":true}');
                response.setStatusCode(200); 

            } else if(req.getEndpoint().endsWith('/v1/object/payment-method')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"Errors":null, "Success":false}');
                response.setStatusCode(200); 

            } 
            return response;
        }
    }


    /*
	*@ Description mock class to call zuora - wrong link account to payment method
	*/
    public without sharing class CallZuoraWrongLinkAccToPayment_Mock implements HttpCalloutMock {
        public HttpResponse respond (HTTPRequest req){
            HttpResponse response = new HttpResponse();

            if(req.getEndpoint().endsWith('/v1/accounts')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"accountId":"a0001", "accountNumber":"A01807438", "paymentMethodId":null, "processId":null, "reasons":null, "success":true}');
                response.setStatusCode(200); 

            } else if(req.getEndpoint().endsWith('/v1/object/payment-method')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"Errors":null, "Id":"a0002", "Success":true, "ZuoraAccountId":null}');
                response.setStatusCode(200); 

            } else if(req.getEndpoint().endsWith('/v1/object/account/a0001')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"Errors":null, "Success":false}');
                response.setStatusCode(200); 

            }
            return response;
        }
    }
   
    /*@isTest
    static void testGet(){
        User u3 = [SELECT Id FROM User WHERE username like '%@optimization.com'][0];

            system.RunAs(u3) {

                System.RestContext.response = new RestResponse();
                
                test.startTest();
                XC_REST_Account.doGet();
                test.stopTest();

                //	system.debug(JSON.deserializeUntyped(System.RestContext.response.getBody()).get('Result'));
            
        	}
    }*/

     /*@ Description wrong - Payment Method  */
    @isTest
	public static void manageContactDuplicationError(){
    
        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populateWrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        body.Contact = wc;
        body.Contact[0].email = [select id, email from contact][0].email;
        
        test.startTest();
        XC_REST_Account_U.manageContactDuplicationError( body, new XC_REST_Account_W.WrapperResponse(), 'No');
        test.stopTest();
        
    }
    
    
         /*@ Description wrong - Payment Method  */
    @isTest
	public static void manageContactDuplicationError2(){
        
        contact c = [select id, email, XC_isGuestContact__c from contact][0];
        c.XC_isGuestContact__c = 'Yes';
        update c;
    
        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populateWrapperAccount();
        body.Account = wa;
        List<XC_UTIL_Account.ContactIFWrapper> wc = populateWrapperContact();
        body.Contact = wc;
        body.Contact[0].email = c.email;
        
        test.startTest();
        XC_REST_Account_U.manageContactDuplicationError( body, new XC_REST_Account_W.WrapperResponse(), 'Yes');
        test.stopTest();
        
    }
    
    
          /*@ Description wrong - Payment Method  */
    @isTest
	public static void createMapAccIdAcc(){
        
       list <account> acc = [select id from account];
        
        test.startTest();
        XC_REST_Account_U.createMapAccIdAcc( acc);
        test.stopTest();
        
    }
    
    // START Leonardo Trinchieri-Del Tosto Edoardo 14/12
    @isTest
	public static void accountNameTest(){
        
        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        wa.AccountType = 'B2B';
        wa.Name = '';
        body.Account = wa;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();

    }

    @isTest
    public static void populateMainPhonePrefAccount(){

        System.RestContext.request = generateReqRightHeaderPOST();

        XC_REST_Account_W.WrapperRequest body = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_Account.AccountIFWrapper wa = populatewrapperAccount();
        //wa.AccountType = 'B2B';
        wa.PrimaryEmail = '';
        wa.MainPhone = '';
        body.Account = wa;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_Account.doPost();
        XC_REST_Account_W.WrapperResponse wrResp = (XC_REST_Account_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Account_W.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();

    }
    // END Leonardo Trinchieri-Del Tosto Edoardo 14/12
}