/**
* @author            : Luisana Rocco lrocco@deloitte.it
* @date Creation     : 15/05/2019
* @date Modification : 23/06/2020 - Dario Tramontin - dtramontin@deloitte.it
* @description       : XC_REST_ActivateRFID  TEST – XC_REST_ActivateRFID/XC_REST_ActivateRFID_U/XC_REST_ActivateRFID_D
*/

@isTest
public without sharing class XC_REST_ActivateRFID_TEST {
    @TestSetup
	static void setup(){ 
		OneOrg__c org            = new OneOrg__c(); 
	    org.Name                 = 'OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
	    insert org;

        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
		accList[0].IdentityType__c = 'NIF';
		accList[0].IdentityNumber__c = '01707796T';
		accList.addAll(XC_DF_Account.createCondominiumAccounts(1));
		accList[1].IdentityType__c = 'NIF';
		accList[1].IdentityNumber__c = '01707797T';
		insert accList;
		
		
		XC_RFID_Card__c card1 = new XC_RFID_Card__c();
		card1.XC_Status_RFID__c = 'STORED';
		card1.XC_Card_Id__c = '12345';
		insert card1;

		XC_RFID_Card__c card2 = new XC_RFID_Card__c();
		card2.XC_Status_RFID__c = 'ACTIVE';
		card2.XC_Card_Id__c = '56789';
		card2.XC_Account_RFID__c = accList[0].Id;
		insert card2;
        
	}

	/*
	*@ Description Wrong Header
	*/
    @isTest
	static void testWrongHeader(){

        System.RestContext.request = generateReqWrongHeader();
        System.RestContext.response = new RestResponse();
		
        test.startTest();
		XC_REST_ActivateRFID.doPut();
        XC_REST_ActivateRFID_U.WrapperRFIDResponse wrResp = (XC_REST_ActivateRFID_U.WrapperRFIDResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_ActivateRFID_U.WrapperRFIDResponse.class);
        System.assertEquals('KO', wrResp.responseElement[0].outcome, 'Wrong assert result');
		test.stopTest();
	}


    /*
	*@ Description Card Status is STORED and Account Lookup is Empty
	*/
    @isTest
	static void testCardStored(){

        System.RestContext.request = generateReqCardStored();
        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_ActivateRFID.doPut();
		XC_REST_ActivateRFID_U.WrapperRFIDResponse wrResp = (XC_REST_ActivateRFID_U.WrapperRFIDResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_ActivateRFID_U.WrapperRFIDResponse.class);
        System.assertEquals('OK', wrResp.responseElement[0].outcome, 'Wrong assert result');
		test.stopTest();
	}

	/*
	*@ Description Card Status is STORED and Account Lookup is Empty Util
	*/
	private static RestRequest generateReqCardStored(){
        
		RestRequest request = generateReqRightHeader();

		XC_REST_ActivateRFID_U.WrapperRFIDRequest body = new XC_REST_ActivateRFID_U.WrapperRFIDRequest();

		List<XC_REST_ActivateRFID_U.WrapperRequestElement> requestList = new List<XC_REST_ActivateRFID_U.WrapperRequestElement>();
        XC_REST_ActivateRFID_U.WrapperRequestElement requestElement = new XC_REST_ActivateRFID_U.WrapperRequestElement();
		requestElement.accountInfo = new XC_UTIL_Account.AccountIFWrapper();
		requestElement.accountInfo.AccountID = [SELECT Id FROM Account][0].Id;
		requestElement.accountInfo.Country = 'SPAIN';

        requestElement.card = new XC_REST_ActivateRFID_U.WrapperSfaCard();
		requestElement.card.CardID = '12345';
		requestList.add(requestElement);
        body.requestElement = requestList;
        request.requestBody = Blob.valueOf(JSON.serialize(body));
        return request;
    }


	/*
	*@ Description  Card Status is ACTIVE and Account Lookup is NOT Empty
	*/
    @isTest
	static void testCardActiveOK(){

        System.RestContext.request = generateReqCardActiveOK();
        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_ActivateRFID.doPut();
		XC_REST_ActivateRFID_U.WrapperRFIDResponse wrResp = (XC_REST_ActivateRFID_U.WrapperRFIDResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_ActivateRFID_U.WrapperRFIDResponse.class);
        System.assertEquals('OK', wrResp.responseElement[0].outcome, 'Wrong assert result');
		test.stopTest();
	}


	/*
	*@ Description  Card Status is ACTIVE and Account Lookup is NOT Empty Util
	*/
	private static RestRequest generateReqCardActiveOK(){
 
        RestRequest request = generateReqRightHeader();
		
		XC_REST_ActivateRFID_U.WrapperRFIDRequest body = new XC_REST_ActivateRFID_U.WrapperRFIDRequest();

		List<XC_REST_ActivateRFID_U.WrapperRequestElement> requestList = new List<XC_REST_ActivateRFID_U.WrapperRequestElement>();
        XC_REST_ActivateRFID_U.WrapperRequestElement requestElement = new XC_REST_ActivateRFID_U.WrapperRequestElement();
		requestElement.accountInfo = new XC_UTIL_Account.AccountIFWrapper();
		requestElement.accountInfo.PrimaryEmail = [SELECT Id, PrimaryEmail__c FROM Account][0].PrimaryEmail__c;
		requestElement.accountInfo.Country = 'SPAIN';

        requestElement.card = new XC_REST_ActivateRFID_U.WrapperSfaCard();
		requestElement.card.CardID = '56789';
		requestList.add(requestElement);

        body.requestElement = requestList;
        request.requestBody = Blob.valueOf(JSON.serialize(body));
        return request;
    }


	/*
	*@ Description  Card Status is ACTIVE and Account Lookup is NOT Empty but is not equal to primary account
	*/
	@isTest
	static void testCardActiveKO(){

        System.RestContext.request = generateReqCardActiveKO();
        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_ActivateRFID.doPut();
		XC_REST_ActivateRFID_U.WrapperRFIDResponse wrResp = (XC_REST_ActivateRFID_U.WrapperRFIDResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_ActivateRFID_U.WrapperRFIDResponse.class);
        System.assertEquals('KO', wrResp.responseElement[0].outcome, 'Wrong assert result');
		test.stopTest();
	}


	/*
	*@ Description  Card Status is ACTIVE and Account Lookup is NOT Empty but is not equal to primary account Util
	*/
	private static RestRequest generateReqCardActiveKO(){

        RestRequest request = generateReqRightHeader();
		XC_REST_ActivateRFID_U.WrapperRFIDRequest body = new XC_REST_ActivateRFID_U.WrapperRFIDRequest();
		List<XC_REST_ActivateRFID_U.WrapperRequestElement> requestList = new List<XC_REST_ActivateRFID_U.WrapperRequestElement>();
        XC_REST_ActivateRFID_U.WrapperRequestElement requestElement = new XC_REST_ActivateRFID_U.WrapperRequestElement();

		requestElement.accountInfo = new XC_UTIL_Account.AccountIFWrapper();
		requestElement.accountInfo.IdentityNumber  = '01707797T';
		requestElement.accountInfo.Country = 'SPAIN';

        requestElement.card = new XC_REST_ActivateRFID_U.WrapperSfaCard();
		requestElement.card.CardID = [SELECT Id, XC_Card_Id__c FROM XC_RFID_Card__c][1].XC_Card_Id__c; 
		requestList.add(requestElement);
        body.requestElement = requestList;
        request.requestBody = Blob.valueOf(JSON.serialize(body));
        return request;
    }



	/*
	*@ Description  Wrong Card
	*/
    @isTest
	static void testWrongCard(){

        System.RestContext.request = generateReqWrongCard();
        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_ActivateRFID.doPut();
		XC_REST_ActivateRFID_U.WrapperRFIDResponse wrResp = (XC_REST_ActivateRFID_U.WrapperRFIDResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_ActivateRFID_U.WrapperRFIDResponse.class);
        System.assertEquals('KO', wrResp.responseElement[0].outcome, 'Wrong assert result');
		test.stopTest();
	}

	
	/*
	*@ Description  Wrong Card util
	*/
	private static RestRequest generateReqWrongCard(){

        RestRequest request = generateReqRightHeader();
		XC_REST_ActivateRFID_U.WrapperRFIDRequest body = new XC_REST_ActivateRFID_U.WrapperRFIDRequest();
		List<XC_REST_ActivateRFID_U.WrapperRequestElement> requestList = new List<XC_REST_ActivateRFID_U.WrapperRequestElement>();
        XC_REST_ActivateRFID_U.WrapperRequestElement requestElement = new XC_REST_ActivateRFID_U.WrapperRequestElement();
		requestElement.accountInfo = new XC_UTIL_Account.AccountIFWrapper();
		requestElement.accountInfo.AccountID = [SELECT Id FROM Account][0].Id;
		requestElement.accountInfo.Country = 'SPAIN';
        requestElement.card = new XC_REST_ActivateRFID_U.WrapperSfaCard();
		requestElement.card.CardID = '5678933225';
		requestList.add(requestElement);
        body.requestElement = requestList;
        request.requestBody = Blob.valueOf(JSON.serialize(body));
        return request;
    }


	/*
	*@ Description  Account Document
	*/
    @isTest
	static void testAccountDocument(){

        System.RestContext.request = generateReqAccDoc();
        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_ActivateRFID.doPut();
		XC_REST_ActivateRFID_U.WrapperRFIDResponse wrResp = (XC_REST_ActivateRFID_U.WrapperRFIDResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_ActivateRFID_U.WrapperRFIDResponse.class);
        System.assertEquals('OK', wrResp.responseElement[0].outcome, 'Wrong assert result');
		test.stopTest();
	}


	/*
	*@ Description  Account Document util
	*/
	private static RestRequest generateReqAccDoc(){

        RestRequest request = generateReqRightHeader();
		XC_REST_ActivateRFID_U.WrapperRFIDRequest body = new XC_REST_ActivateRFID_U.WrapperRFIDRequest();
		List<XC_REST_ActivateRFID_U.WrapperRequestElement> requestList = new List<XC_REST_ActivateRFID_U.WrapperRequestElement>();
		XC_REST_ActivateRFID_U.WrapperRequestElement requestElement = new XC_REST_ActivateRFID_U.WrapperRequestElement();

		requestElement.accountInfo = new XC_UTIL_Account.AccountIFWrapper();
		requestElement.accountInfo.IdentityNumber = [SELECT Id, IdentityNumber__c FROM Account][0].IdentityNumber__c;
		requestElement.accountInfo.Country = 'SPAIN';	
 
		requestElement.card = new XC_REST_ActivateRFID_U.WrapperSfaCard();
		requestElement.card.CardID = [SELECT Id, XC_Card_Id__c FROM XC_RFID_Card__c][1].XC_Card_Id__c;
		requestList.add(requestElement);
        body.requestElement = requestList;
        request.requestBody = Blob.valueOf(JSON.serialize(body));
        return request;
    }

	


	/*
	*@ Description  WrongFunctionality
	*/
    @isTest
	static void testWrongFunctionality(){

        System.RestContext.request = generateReqWrongFunc();
        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_ActivateRFID.doPut();
		XC_REST_ActivateRFID_U.WrapperRFIDResponse wrResp = (XC_REST_ActivateRFID_U.WrapperRFIDResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_ActivateRFID_U.WrapperRFIDResponse.class);
        System.assertEquals('KO', wrResp.responseElement[0].outcome, 'Wrong assert result');
		test.stopTest();
	}


	/*
	*@ Description  WrongFunctionality Util
	*/
	private static RestRequest generateReqWrongFunc(){

		XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        
        RestRequest request = generateReqRightHeader();
		request.headers.put('Functionality', 'WrongFunc');

		XC_REST_ActivateRFID_U.WrapperRFIDRequest body = new XC_REST_ActivateRFID_U.WrapperRFIDRequest();
        request.requestBody = Blob.valueOf(JSON.serialize(body));
        return request;
    }


	/*
	*@ Description  MissingAccountInfo
	*/
    @isTest
	static void testMissingAccountInfo(){

        System.RestContext.request = generateReqMissingAccountInfo();
        System.RestContext.response = new RestResponse();

        test.startTest();
		system.debug(System.RestContext.request);
		XC_REST_ActivateRFID.doPut();
		XC_REST_ActivateRFID_U.WrapperRFIDResponse wrResp = (XC_REST_ActivateRFID_U.WrapperRFIDResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_ActivateRFID_U.WrapperRFIDResponse.class);
        System.assertEquals('KO', wrResp.responseElement[0].outcome, 'Wrong assert result');
		test.stopTest();
	}

	/*
	*@ Description  MissingAccountIfo util
	*/
	private static RestRequest generateReqMissingAccountInfo(){

	XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
	RestRequest request = generateReqRightHeader();
	
	XC_REST_ActivateRFID_U.WrapperRFIDRequest body = new XC_REST_ActivateRFID_U.WrapperRFIDRequest();
	List<XC_REST_ActivateRFID_U.WrapperRequestElement> requestList = new List<XC_REST_ActivateRFID_U.WrapperRequestElement>();
	XC_REST_ActivateRFID_U.WrapperRequestElement requestElement = new XC_REST_ActivateRFID_U.WrapperRequestElement();
	requestList.add(requestElement);
	body.requestElement = requestList;
	request.requestBody = Blob.valueOf(JSON.serialize(body));
	return request;
    }


	/*
	*@ Description  MissingAccountID
	*/
    @isTest
	static void testMissingAccountMandatoryFields(){

        System.RestContext.request = generateReqMissingAccountMandatoryFields();
        System.RestContext.response = new RestResponse();

        test.startTest();
		system.debug(System.RestContext.request);
		XC_REST_ActivateRFID.doPut();
		XC_REST_ActivateRFID_U.WrapperRFIDResponse wrResp = (XC_REST_ActivateRFID_U.WrapperRFIDResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_ActivateRFID_U.WrapperRFIDResponse.class);
        System.assertEquals('KO', wrResp.responseElement[0].outcome, 'Wrong assert result');
		test.stopTest();
	}


	/*
	*@ Description  MissingAccountID util
	*/
	private static RestRequest generateReqMissingAccountMandatoryFields(){

	XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
	RestRequest request = generateReqRightHeader();
	XC_REST_ActivateRFID_U.WrapperRFIDRequest body = new XC_REST_ActivateRFID_U.WrapperRFIDRequest();
	List<XC_REST_ActivateRFID_U.WrapperRequestElement> requestList = new List<XC_REST_ActivateRFID_U.WrapperRequestElement>();
	XC_REST_ActivateRFID_U.WrapperRequestElement requestElement = new XC_REST_ActivateRFID_U.WrapperRequestElement();

	requestElement.accountInfo = new XC_UTIL_Account.AccountIFWrapper();
	requestElement.accountInfo.Country = 'SPAIN';
	requestList.add(requestElement);
	body.requestElement = requestList;
	request.requestBody = Blob.valueOf(JSON.serialize(body));
	return request;
    }



	/*
	*@ Description  MissingCountryInfo
	*/
    @isTest
	static void testMissingAccountCountry(){

        System.RestContext.request = generateReqMissingAccountCountry();
        System.RestContext.response = new RestResponse();

        test.startTest();
		system.debug(System.RestContext.request);
		XC_REST_ActivateRFID.doPut();
		XC_REST_ActivateRFID_U.WrapperRFIDResponse wrResp = (XC_REST_ActivateRFID_U.WrapperRFIDResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_ActivateRFID_U.WrapperRFIDResponse.class);
        System.assertEquals('KO', wrResp.responseElement[0].outcome, 'Wrong assert result');
		test.stopTest();
	}


	/*
	*@ Description  MissingCountryInfo util
	*/
	private static RestRequest generateReqMissingAccountCountry(){

	XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
	RestRequest request = generateReqRightHeader();

	
	XC_REST_ActivateRFID_U.WrapperRFIDRequest body = new XC_REST_ActivateRFID_U.WrapperRFIDRequest();
	List<XC_REST_ActivateRFID_U.WrapperRequestElement> requestList = new List<XC_REST_ActivateRFID_U.WrapperRequestElement>();
	XC_REST_ActivateRFID_U.WrapperRequestElement requestElement = new XC_REST_ActivateRFID_U.WrapperRequestElement();
	requestElement.accountInfo = new XC_UTIL_Account.AccountIFWrapper();
	requestElement.accountInfo.AccountID = [SELECT Id FROM Account][0].Id;
	requestList.add(requestElement);
	body.requestElement = requestList;
	request.requestBody = Blob.valueOf(JSON.serialize(body));
	return request;
    }


	/*
	*@ Description  MissingCard
	*/
    @isTest
	static void testMissingCard(){

        System.RestContext.request = generateReqMissingCard();
        System.RestContext.response = new RestResponse();

        test.startTest();
		system.debug(System.RestContext.request);
		XC_REST_ActivateRFID.doPut();
		XC_REST_ActivateRFID_U.WrapperRFIDResponse wrResp = (XC_REST_ActivateRFID_U.WrapperRFIDResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_ActivateRFID_U.WrapperRFIDResponse.class);
        System.assertEquals('KO', wrResp.responseElement[0].outcome, 'Wrong assert result');
		test.stopTest();
	}


	/*
	*@ Description  MissingCard
	*/
	private static RestRequest generateReqMissingCard(){

	XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
	RestRequest request = generateReqRightHeader();

	
	XC_REST_ActivateRFID_U.WrapperRFIDRequest body = new XC_REST_ActivateRFID_U.WrapperRFIDRequest();
	List<XC_REST_ActivateRFID_U.WrapperRequestElement> requestList = new List<XC_REST_ActivateRFID_U.WrapperRequestElement>();
	XC_REST_ActivateRFID_U.WrapperRequestElement requestElement = new XC_REST_ActivateRFID_U.WrapperRequestElement();
	requestElement.accountInfo = new XC_UTIL_Account.AccountIFWrapper();
	requestElement.accountInfo.AccountID = [SELECT Id FROM Account][0].Id;
	requestElement.accountInfo.Country = 'SPAIN';
	requestList.add(requestElement);
	body.requestElement = requestList;
	request.requestBody = Blob.valueOf(JSON.serialize(body));
	return request;
    }


	/*
	*@ Description  MissingCardID
	*/
    @isTest
	static void testMissingCardID(){

        System.RestContext.request = generateReqMissingCardID();
        System.RestContext.response = new RestResponse();

        test.startTest();
		system.debug(System.RestContext.request);
		XC_REST_ActivateRFID.doPut();
		XC_REST_ActivateRFID_U.WrapperRFIDResponse wrResp = (XC_REST_ActivateRFID_U.WrapperRFIDResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_ActivateRFID_U.WrapperRFIDResponse.class);
        System.assertEquals('KO', wrResp.responseElement[0].outcome, 'Wrong assert result');
		test.stopTest();
	}


	/*
	*@ Description  MissingCardID
	*/
	private static RestRequest generateReqMissingCardID(){

	XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
	RestRequest request = generateReqRightHeader();

	
	XC_REST_ActivateRFID_U.WrapperRFIDRequest body = new XC_REST_ActivateRFID_U.WrapperRFIDRequest();
	List<XC_REST_ActivateRFID_U.WrapperRequestElement> requestList = new List<XC_REST_ActivateRFID_U.WrapperRequestElement>();
	XC_REST_ActivateRFID_U.WrapperRequestElement requestElement = new XC_REST_ActivateRFID_U.WrapperRequestElement();
	requestElement.accountInfo = new XC_UTIL_Account.AccountIFWrapper();
	requestElement.accountInfo.AccountID = [SELECT Id FROM Account][0].Id;
	requestElement.accountInfo.Country = 'SPAIN';
	requestElement.card = new XC_REST_ActivateRFID_U.WrapperSfaCard();
	requestList.add(requestElement);
	body.requestElement = requestList;
	request.requestBody = Blob.valueOf(JSON.serialize(body, true));
	return request;
    }


	/*
	*@ Description  Catch
	*/
    @isTest
	static void testErrorCatch(){

        System.RestContext.request =  new RestRequest();
        System.RestContext.response = new RestResponse();

        test.startTest();
		system.debug(System.RestContext.request);
		XC_REST_ActivateRFID.doPut();
		XC_REST_ActivateRFID_U.WrapperRFIDResponse wrResp = (XC_REST_ActivateRFID_U.WrapperRFIDResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_ActivateRFID_U.WrapperRFIDResponse.class);
        System.assertEquals('KO', wrResp.responseElement[0].outcome, 'Wrong assert result');
		test.stopTest();
	}



	/*
	*@ Description generate wrong header request
	*/
    private static RestRequest generateReqWrongHeader(){

		XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        
        RestRequest request = new RestRequest();
		
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'ActivateRechargeCard');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('ClientSystem', 'XRecharge');
        request.addHeader('ServerSystem','XCustomerB2C');  

		request.httpMethod = 'PUT';
		request.requestURI = '/v1/ActivateRFID/*';
        
		XC_REST_ActivateRFID_U.WrapperRFIDRequest body = new XC_REST_ActivateRFID_U.WrapperRFIDRequest();
        
        request.requestBody = Blob.valueOf(JSON.serialize(body));
        return request;
    }

	/*
	*@ Description generate right header request
	*/
    private static RestRequest generateReqRightHeader(){
       
        RestRequest request = new RestRequest();
		
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'ActivateRechargeCard');
        request.addHeader('DateTimeMessage', '20191207100000039');
        request.addHeader('ClientSystem', 'XRecharge');
        request.addHeader('ServerSystem','XCustomerB2C');  
        request.addHeader('Operation','create');  

		request.httpMethod = 'PUT';
		request.requestURI = '/v1/ActivateRFID/*';
        return request;
    }
}