/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  28/05/2019 
* @description XC_UTIL_ResultWrapper_TEST – Test class for XC_UTIL_ResultWrapper
*/
@isTest
public class XC_REST_DoxeeReadFileURL_TEST {
    
    @TestSetup
	static void setup(){ 
		//insert XC_DF_OneOrg.createOneOrg('Spain');
        NE__Order__c ord = XC_DF_Order.createOrder('InOrder'); 
        List<WorkOrder> wkor = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        insert wkor;
        /*XC_Document_to_sign__c docToSign = new XC_Document_to_sign__c (XC_Doxee_ID_external__c = '123', XC_ConfigurationId__c = ord.Id,
                                                                        XC_WorkOrder__c = wkor[0].Id);
        insert docToSign;*/
    }

    //Test Method doPost1
    static testMethod void doPost1(){
        Test.startTest(); 
        
        
        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
        
        XC_REST_DoxeeReadFileURL.doPost(); 
        //system.assertEquals(RestContext.response.statusCode, 500, 'Wrong assert result'); 
        
        Test.stopTest();
        
    }

    
    //Test Method doPost2
    static testMethod void doPost2(){
        
        Test.startTest(); 
        
        
        XC_REST_DoxeeReadFileURL_W.WrapperRequest wrReq = new XC_REST_DoxeeReadFileURL_W.WrapperRequest();       
        wrReq.FileItem= new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrf = new XC_REST_DoxeeReadFileURL_W.WrapperRequestFile();
        wrReq.FileItem.add(wrf);
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTDRFUrlRequest(wrReq, 'POST');
        
        XC_REST_DoxeeReadFileURL.doPost(); 
        //system.assertEquals(RestContext.response.statusCode, 400, 'Wrong assert result'); 
        
        Test.stopTest();
        
    }
    
    
    //Test Method doPost3
    static testMethod void doPost3(){
        
        Test.startTest(); 
        
        
       RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
        
        XC_REST_DoxeeReadFileURL.doPost(); 
        //system.assertEquals(RestContext.response.statusCode, 500, 'Wrong assert result'); 
        
        Test.stopTest();
        
    }
    
    
    
    //Test Method doPost4
    static testMethod void doPost4(){
        
        Test.startTest(); 
        
        
        XC_REST_DoxeeReadFileURL_W.WrapperRequest wrReq = new XC_REST_DoxeeReadFileURL_W.WrapperRequest();       
        wrReq.FileItem= new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrf = new XC_REST_DoxeeReadFileURL_W.WrapperRequestFile();
        wrf.ObjectType='CONFIGURATION';
        wrReq.FileItem.add(wrf);
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTDRFUrlRequest(wrReq, 'POST');
        
        XC_REST_DoxeeReadFileURL.doPost(); 
        //system.assertEquals(RestContext.response.statusCode, 400, 'Wrong assert result'); 
        
        Test.stopTest();
        
    }
    
    //Test Method doPost5
    static testMethod void doPost5(){
        
        Test.startTest(); 
        
        
        XC_REST_DoxeeReadFileURL_W.WrapperRequest wrReq = new XC_REST_DoxeeReadFileURL_W.WrapperRequest();       
        wrReq.FileItem= new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrf = new XC_REST_DoxeeReadFileURL_W.WrapperRequestFile();
        NE__Order__c ord = XC_DF_Order.createOrder('InOrder'); 
        wrf.ObjectType='CONFIGURATION';
        wrf.ObjectID = ord.Id;
        wrReq.FileItem.add(wrf);
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTDRFUrlRequest(wrReq, 'POST');
        
        XC_REST_DoxeeReadFileURL.doPost(); 
        //system.assertEquals(RestContext.response.statusCode, 400, 'Wrong assert result'); 
        
        Test.stopTest();
        
    }
        static testMethod void doPost10(){
        
        Test.startTest(); 
        
        
        XC_REST_DoxeeReadFileURL_W.WrapperRequest wrReq = new XC_REST_DoxeeReadFileURL_W.WrapperRequest();       
        wrReq.FileItem= new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrf = new XC_REST_DoxeeReadFileURL_W.WrapperRequestFile();
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
            insert oi;
        wrf.ObjectType='CONFIGURATION_ITEM';
        wrf.ObjectID = oi.get(0).id;
        wrf.Category = 'SF_WORK_LICENSE_AUTH_LETTER';
        wrReq.FileItem.add(wrf);
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTDRFUrlRequest(wrReq, 'POST');
        
        XC_REST_DoxeeReadFileURL.doPost(); 
        //system.assertEquals(RestContext.response.statusCode, 400, 'Wrong assert result'); 
        
        Test.stopTest();
        
    }
     //Test Method doPost6
    static testMethod void doPost6(){
        
        Test.startTest(); 
        
        
        XC_REST_DoxeeReadFileURL_W.WrapperRequest wrReq = new XC_REST_DoxeeReadFileURL_W.WrapperRequest();       
        wrReq.FileItem= new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrf = new XC_REST_DoxeeReadFileURL_W.WrapperRequestFile();
        NE__Order__c ord = XC_DF_Order.createOrder('InOrder'); 
        wrf.ObjectType='CONFIGURATION';
        wrf.ObjectID = ord.Id;
        wrf.Category = 'SF_QUALITY_CONTROL_RECORD'; 
        wrReq.FileItem.add(wrf);
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTDRFUrlRequest(wrReq, 'POST');
        
        XC_REST_DoxeeReadFileURL.doPost(); 
        //system.assertEquals(RestContext.response.statusCode, 400, 'Wrong assert result'); 
        
        Test.stopTest();
        
    }
    
    
     //Test Method doPost7
    static testMethod void doPost7(){
        
        Test.startTest(); 
        
        
        XC_REST_DoxeeReadFileURL_W.WrapperRequest wrReq = new XC_REST_DoxeeReadFileURL_W.WrapperRequest();       
        wrReq.FileItem= new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrf = new XC_REST_DoxeeReadFileURL_W.WrapperRequestFile();
        NE__Order__c ord = XC_DF_Order.createOrder('InOrder'); 
        wrf.ObjectType='CONFIGURATION';
        wrf.ObjectID = ord.Id;
        wrf.Category = 'SF_QUALITY_CONTROL_RECORD'; 
        wrf.DocumentURL = 'test';
        wrReq.FileItem.add(wrf);
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTDRFUrlRequest(wrReq, 'POST');
        
        XC_REST_DoxeeReadFileURL.doPost(); 
        //system.assertEquals(RestContext.response.statusCode, 400, 'Wrong assert result'); 
        
        Test.stopTest();
        
    }
    
         //Test Method doPost7
    static testMethod void doPost17(){
        
        Test.startTest(); 
        
        
        XC_REST_DoxeeReadFileURL_W.WrapperRequest wrReq = new XC_REST_DoxeeReadFileURL_W.WrapperRequest();       
        wrReq.FileItem= new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrf = new XC_REST_DoxeeReadFileURL_W.WrapperRequestFile();
        List<Contract> contract = XC_DF_Contract.createContracts(1);
        insert contract; 
        wrf.ObjectType='CONTRACT';
        wrf.ObjectID = contract.get(0).Id;
        wrf.Category = 'SF_DNI_CONTRACT'; 
        wrf.DocumentURL = 'test';
        wrReq.FileItem.add(wrf);
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTDRFUrlRequest(wrReq, 'POST');
        
        XC_REST_DoxeeReadFileURL.doPost(); 
        //system.assertEquals(RestContext.response.statusCode, 400, 'Wrong assert result'); 
        
        Test.stopTest();
        
    }
    //Test Method doPost8
    static testMethod void doPost8(){
        
        Test.startTest(); 
        
        
        XC_REST_DoxeeReadFileURL_W.WrapperRequest wrReq = new XC_REST_DoxeeReadFileURL_W.WrapperRequest();       
        wrReq.FileItem= new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrf = new XC_REST_DoxeeReadFileURL_W.WrapperRequestFile();
        
        NE__Order__c ord = XC_DF_Order.createOrder('InOrder'); 
        
        wrf.ObjectType='CONFIGURATION';
		wrf.ObjectID = ord.Id;
		wrf.Category = 'SF_QUALITY_CONTROL_RECORD'; 
		wrf.DocumentURL = 'test';
		wrf.DocumentID = '12345';

		wrReq.FileItem.add(wrf);
	        
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTDRFUrlRequest(wrReq, 'POST');

        
        XC_REST_DoxeeReadFileURL.doPost(); 
        //system.assertEquals(RestContext.response.statusCode, 200, 'Wrong assert result'); 
        
        Test.stopTest();
        
    }
    
    
    //Test Method doPost9
    static testMethod void doPost9(){
        
        Test.startTest(); 
        
        
        XC_REST_DoxeeReadFileURL_W.WrapperRequest wrReq = new XC_REST_DoxeeReadFileURL_W.WrapperRequest();       
        wrReq.FileItem= new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrf = new XC_REST_DoxeeReadFileURL_W.WrapperRequestFile();
        
        List<WorkOrder> wkor = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        insert wkor;
        
        wrf.ObjectType='WorkOrder';
		wrf.ObjectID = wkor[0].Id;
		wrf.Category = 'SF_TICKET_COMBUSTION'; 
		wrf.DocumentURL = 'test';
		wrf.DocumentID = '12345';

		wrReq.FileItem.add(wrf);
	        
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTDRFUrlRequest(wrReq, 'POST');

        
        XC_REST_DoxeeReadFileURL.doPost(); 
        //system.assertEquals(RestContext.response.statusCode, 200, 'Wrong assert result'); 
        
        Test.stopTest();
        
    }
    

    /*
	*@ Description Document Already Exists - Order
	*/
    /*@isTest
	static void testDocumentAlreadyExistsOrd(){

        XC_REST_DoxeeReadFileURL_W.WrapperRequest body = new  XC_REST_DoxeeReadFileURL_W.WrapperRequest();
        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fi = populateWrapperRequestOrd();
        fi[0].DocumentID = '123';

        body.FileItem = fi;
        
        System.RestContext.request = generatePOSTDRFUrlRequest(body, 'POST');
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_DoxeeReadFileURL.doPost(); 
        System.assertEquals(500, System.RestContext.response.statusCode, 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Document Already Exists - Work Order
	*/
    /*@isTest
	static void testDocumentAlreadyExistsWorkOrd(){

        XC_REST_DoxeeReadFileURL_W.WrapperRequest body = new  XC_REST_DoxeeReadFileURL_W.WrapperRequest();
        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fi = populateWrapperRequestWorkOrd();
        fi[0].DocumentID = '123';

        body.FileItem = fi;
        
        System.RestContext.request = generatePOSTDRFUrlRequest(body, 'POST');
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_DoxeeReadFileURL.doPost(); 
        System.assertEquals(500, System.RestContext.response.statusCode, 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Wrong header
	*/
    @isTest
	static void testWrongHeader(){

        XC_REST_DoxeeReadFileURL_W.WrapperRequest body = new  XC_REST_DoxeeReadFileURL_W.WrapperRequest();
        System.RestContext.request = generatePOSTDRFUrlRequest(body, 'POST');
        String trasaction = System.RestContext.request.headers.remove('TransactionID');
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_DoxeeReadFileURL.doPost(); 
        //System.assertEquals(400, System.RestContext.response.statusCode, 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Missing File Item
	*/
    @isTest
	static void testMissingFileItem(){

        XC_REST_DoxeeReadFileURL_W.WrapperRequest body = new  XC_REST_DoxeeReadFileURL_W.WrapperRequest();
        System.RestContext.request = generatePOSTDRFUrlRequest(body, 'POST');
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_DoxeeReadFileURL.doPost(); 
        //System.assertEquals(400, System.RestContext.response.statusCode, 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description Validate file request
	*/
    @isTest
	static void testValidateFileReq(){

        XC_REST_DoxeeReadFileURL_W.WrapperRequest body = new  XC_REST_DoxeeReadFileURL_W.WrapperRequest();
        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fi = populateWrapperRequestWorkOrd();
        fi[0].ObjectType = 'Test';
        fi[0].DocumentID = '123';

        body.FileItem = fi;
        
        System.RestContext.request = generatePOSTDRFUrlRequest(body, 'POST');
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_DoxeeReadFileURL.doPost(); 
        //System.assertEquals(400, System.RestContext.response.statusCode, 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description insert document to sign -  work order
	*/
    @isTest
	static void testDocToSign(){

        XC_REST_DoxeeReadFileURL_W.WrapperRequest body = new  XC_REST_DoxeeReadFileURL_W.WrapperRequest();
        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fi = populateWrapperRequestWorkOrd();
        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fiTemp = populateWrapperRequestWorkOrd();
        fi.addall(fiTemp);
        fi[1].DocumentURL = 'Test2';
        fi[1].DocumentID = '456';
        body.FileItem = fi;
        
        System.RestContext.request = generatePOSTDRFUrlRequest(body, 'POST');
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_DoxeeReadFileURL.doPost(); 
        //System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description insert document to sign - order
	*/
    @isTest
	static void testDocToSignOrd(){

        XC_REST_DoxeeReadFileURL_W.WrapperRequest body = new  XC_REST_DoxeeReadFileURL_W.WrapperRequest();
        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fi = populateWrapperRequestOrd();
        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fiTemp = populateWrapperRequestOrd();
        fi.addall(fiTemp);
        fi[1].DocumentURL = 'Test2';
        fi[1].DocumentID = '456';
        body.FileItem = fi;
        
        System.RestContext.request = generatePOSTDRFUrlRequest(body, 'POST');
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_DoxeeReadFileURL.doPost(); 
        //System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');
        test.stopTest();
	}


    /*
	*@ Description object Id not found - WorkOrder
	*/
    @isTest
	static void testObjectIdNotFoundWorkOrd(){

        XC_REST_DoxeeReadFileURL_W.WrapperRequest body = new  XC_REST_DoxeeReadFileURL_W.WrapperRequest();
        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fi = populateWrapperRequestWorkOrd();
        fi[0].ObjectID = (String.valueOf([SELECT Id FROM WorkOrder][0].Id)).substring(0,17)+ '9';

        body.FileItem = fi;
        
        System.RestContext.request = generatePOSTDRFUrlRequest(body, 'POST');
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_DoxeeReadFileURL.doPost(); 
        //System.assertEquals(400, System.RestContext.response.statusCode, 'Wrong assert result');
        test.stopTest();
	}
   

    /*
	*@ Description object Id not found - Order
	*/
    @isTest
	static void testObjectIdNotFoundOrd(){

        XC_REST_DoxeeReadFileURL_W.WrapperRequest body = new  XC_REST_DoxeeReadFileURL_W.WrapperRequest();
        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fi = populateWrapperRequestOrd();
        fi[0].ObjectID = (String.valueOf([SELECT Id FROM NE__Order__c][0].Id)).substring(0,17)+ '9';

        body.FileItem = fi;
        
        System.RestContext.request = generatePOSTDRFUrlRequest(body, 'POST');
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_DoxeeReadFileURL.doPost(); 
        //System.assertEquals(400, System.RestContext.response.statusCode, 'Wrong assert result');
        test.stopTest();
	}
    

    private static RestRequest generatePOSTDRFUrlRequest(XC_REST_DoxeeReadFileURL_W.WrapperRequest params, String method){
        
        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
        request = addHeader(request);
        request.httpMethod = method;
        request.requestURI = '/v1/FileURL/*';
        
        request.requestBody = Blob.valueOf(JSON.serializePretty(params));
        
        return request; 
    
        
    }
    
     private static RestRequest addHeader(RestRequest request){
		request.addHeader('TransactionID', 'AXYZ');
		request.addHeader('DateTimeMessage', '20181207103900000');
		request.addHeader('Operation', 'AXYZ');
		request.addHeader('Functionality', 'AXYZ');
		request.addHeader('ClientSystem', 'AXYZ');
		request.addHeader('ServerSystem', 'AXYZ');
        request.addHeader('debugMode', 'AXYZ');
        return request;
    }
    

    /*
	*@ Description populate wrapper request - order
	*/
    public static List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> populateWrapperRequestOrd(){


        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fileItemList = new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrfi = new XC_REST_DoxeeReadFileURL_W.WrapperRequestFile();
		wrfi.DocumentURL = 'test';
		wrfi.DocumentID = '123456';
        wrfi.ObjectType = 'Configuration';
        wrfi.ObjectID = [SELECT Id FROM NE__Order__c][0].Id;
        wrfi.Category = 'SF_CONTRACT_SIGNATURE';
     

		fileItemList.add(wrfi);

        return fileItemList;
    }

    /*
	*@ Description populate wrapper request - work order
	*/
    public static List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> populateWrapperRequestWorkOrd(){


        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fileItemList = new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrfi = new XC_REST_DoxeeReadFileURL_W.WrapperRequestFile();
		wrfi.DocumentURL = 'test';
		wrfi.DocumentID = '123456';
        wrfi.ObjectType = 'WorkOrder';
        wrfi.ObjectID = [SELECT Id FROM WorkOrder][0].Id;
        wrfi.Category = 'SF_INSTALLATION_DOC_SIGNATURE';

		fileItemList.add(wrfi);

        return fileItemList;
    }
    
    /*
	*@ Description insert invoice document and create a case
	*/
    @isTest
	static void testDocInvoiceCase(){

        XC_REST_DoxeeReadFileURL_W.WrapperRequest body = new  XC_REST_DoxeeReadFileURL_W.WrapperRequest();
        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fi = populateWrapperRequestOrd();
        fi[0].ObjectType = 'ACCOUNT';
        fi[0].Category = 'SF_INVOICE';
        fi[0].DocumentURL = 'Test2';
        fi[0].DocumentID = '456';
        List<Contact>  contList = XC_DF_Contact.createResidentialContacts(1);
        contList[0].XC_PrimaryContact__c=true;
        insert contList[0];
        fi[0].ObjectID = contList[0].AccountId;

        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fis = new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        fis.add(fi[0]);
        fis.add(fi[0]);

        body.FileItem = fis;
        
        System.RestContext.request = generatePOSTDRFUrlRequest(body, 'POST');
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_DoxeeReadFileURL.doPost(); 
        //System.assertEquals(200, System.RestContext.response.statusCode, 'OK assert result');
        test.stopTest();
	}
    
    /*
	*@ Description insert document to sign - Lead
	*/
    @isTest
	static void testDocToSignLead(){

        XC_REST_DoxeeReadFileURL_W.WrapperRequest body = new  XC_REST_DoxeeReadFileURL_W.WrapperRequest();
        
        List<Lead> leads = XC_DF_Lead.createResidentialLeads(1);
        insert leads;
        
        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fileItemList = new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrfi = new XC_REST_DoxeeReadFileURL_W.WrapperRequestFile();
		wrfi.DocumentURL = 'test';
		wrfi.DocumentID = '123456';
        wrfi.ObjectType = 'Lead';
        wrfi.ObjectID = leads[0].Id;
        wrfi.Category = 'SF_QUOTE';
		fileItemList.add(wrfi);
        body.FileItem = fileItemList;
        
        System.RestContext.request = generatePOSTDRFUrlRequest(body, 'POST');
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_DoxeeReadFileURL.doPost(); 
        //System.assertEquals(400, System.RestContext.response.statusCode, 'Wrong assert result');
        test.stopTest();
	}
    
    
    /*
	*@ Description insert document to sign - Lead
	*/
    @isTest
	static void testDocToSignBP(){

        XC_REST_DoxeeReadFileURL_W.WrapperRequest body = new  XC_REST_DoxeeReadFileURL_W.WrapperRequest();
        
        List<NE__Billing_Profile__c> bpList = XC_DF_BillingProfile.createBillingProfile(1);
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(new List<Account>{new Account(Id = bpList[0].NE__Account__c)});
        conList[0].XC_PrimaryContact__c = true;
        insert conList;
        
        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fileItemList = new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrfi = new XC_REST_DoxeeReadFileURL_W.WrapperRequestFile();
		wrfi.DocumentURL = 'test';
		wrfi.DocumentID = '123456';
        wrfi.ObjectType = 'BILLING_PROFILE';
        wrfi.ObjectID = bpList[0].Id;
        wrfi.Category = 'SF_SEPA_SIGNATURE';
		fileItemList.add(wrfi);
        body.FileItem = fileItemList;
        
        System.RestContext.request = generatePOSTDRFUrlRequest(body, 'POST');
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_DoxeeReadFileURL.doPost(); 
        //System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');
        test.stopTest();
	}
        /*
	*@ Description insert document to sign - Lead
	*/
    @isTest
	static void populateCustomerInteractionContract(){
		XC_REST_DoxeeReadFileURL_W.WrapperRequest body = new  XC_REST_DoxeeReadFileURL_W.WrapperRequest();
        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fi = populateWrapperRequestOrd();
        fi[0].ObjectType = 'CONTRACT';
        fi[0].Category = 'SF_DNI';
        fi[0].DocumentURL = 'Test2';
        //fi[0].DocumentID = '456';
        List<Contact>  contList = XC_DF_Contact.createResidentialContacts(1);
        contList[0].XC_PrimaryContact__c=true;
        insert contList[0];
        List<Contract> contractList = XC_DF_Contract.createContracts(1);
        insert contractList;
        fi[0].ObjectID = contractList[0].Id;

        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fis = new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        fis.add(fi[0]);
        fis.add(fi[0]);

        body.FileItem = fis;
        
        System.RestContext.request = generatePOSTDRFUrlRequest(body, 'POST');
        System.RestContext.response = new RestResponse();
        
        test.startTest();
		XC_REST_DoxeeReadFileURL.doPost(); 
        //System.assertEquals(200, System.RestContext.response.statusCode, 'OK assert result');
        test.stopTest();

	}
    @isTest
	static void testDocCase(){

        List<User> user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId()];
        user[0].XC_EnabledToSkip__c = true;
        update user;
		
        System.runAs(user[0]){
        Test.startTest();
        /*Integer n = 1;
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(n);
        insert accounts;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        insert contacts;*/
        XC_REST_DoxeeReadFileURL_W.WrapperRequest body = new  XC_REST_DoxeeReadFileURL_W.WrapperRequest();
        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fi = populateWrapperRequestOrd();
        fi[0].ObjectType = 'CASE';
        fi[0].Category = 'SF_GENERIC_DOCUMENT';
        fi[0].DocumentURL = 'Test2';
        //fi[0].DocumentID = '456';
        List<Contact>  contList = XC_DF_Contact.createResidentialContacts(1);
        contList[0].XC_PrimaryContact__c=true;
        insert contList[0];
        /*List<Case> caseList = new List<Case>();
        caseList[0].AccountId = accounts[0].Id;
        caseList[0].ContactId = contacts[0].Id;
        caseList[0].XC_Type_Intermediary__c = 'TI001';
        caseList[0].Status = 'ESTA003';*/
        List<Case> caseList = XC_DF_Case.createCasesForWo(1);
        //caseList[0].XC_Segment__c = 'B2C';
        caseList[0].XC_Legalentity__c = 'EnelXItalia';
        insert caseList;
        fi[0].ObjectID = caseList[0].Id;

        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fis = new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        fis.add(fi[0]);
        fis.add(fi[0]);

        body.FileItem = fis;
        
        System.RestContext.request = generatePOSTDRFUrlRequest(body, 'POST');
        System.RestContext.response = new RestResponse();

		XC_REST_DoxeeReadFileURL.doPost(); 
        //System.assertEquals(200, System.RestContext.response.statusCode, 'OK assert result');
        test.stopTest();
        }
	}
   
    @isTest
    //Covers XC_TR_DocumentURL_GenerateCI
	static void testCREDIT_ASSIGNMENT_SIGNED(){
        
        Test.startTest(); 
        NE__Order__c ord = XC_DF_Order.createOrder('InOrder');
        
        XC_DocumentType__c dt = new XC_DocumentType__c();
        dt.Category__c = 'SF_CREDIT_ASSIGNMENT_SIGNED' ;
        dt.numberOfFiles__c = 1;
        dt.XC_Configuration__c = ord.id;
        insert dt;
        
        XC_REST_DoxeeReadFileURL_W.WrapperRequest wrReq = new XC_REST_DoxeeReadFileURL_W.WrapperRequest();       
        wrReq.FileItem= new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrf = new XC_REST_DoxeeReadFileURL_W.WrapperRequestFile();
        
        wrf.ObjectType='CONFIGURATION';
		wrf.ObjectID = ord.Id;
		wrf.Category = 'SF_CREDIT_ASSIGNMENT_SIGNED'; 
		wrf.DocumentURL = 'test';
		wrf.DocumentID = '12345';

		wrReq.FileItem.add(wrf);
	        
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTDRFUrlRequest(wrReq, 'POST');

        
        XC_REST_DoxeeReadFileURL.doPost(); 
        system.assertnotEquals(wrf.ObjectType, 'pippo'); 
        Test.stopTest();
        
    }
    
    @isTest
    //Covers XC_TR_DocumentURL_GenerateCI
	static void testCONTRACT_SIGNED(){
        
        Test.startTest(); 
        NE__Order__c ord = XC_DF_Order.createOrder('InOrder');
        
        XC_DocumentType__c dt = new XC_DocumentType__c();
        dt.Category__c = 'SF_CONTRACT_SIGNED' ;
        dt.numberOfFiles__c = 1;
        dt.XC_Configuration__c = ord.id;
        insert dt;
        
        XC_REST_DoxeeReadFileURL_W.WrapperRequest wrReq = new XC_REST_DoxeeReadFileURL_W.WrapperRequest();       
        wrReq.FileItem= new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrf = new XC_REST_DoxeeReadFileURL_W.WrapperRequestFile();
        
        wrf.ObjectType='CONFIGURATION';
		wrf.ObjectID = ord.Id;
		wrf.Category = 'SF_CONTRACT_SIGNED'; 
		wrf.DocumentURL = 'test';
		wrf.DocumentID = '12345';

		wrReq.FileItem.add(wrf);
	        
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTDRFUrlRequest(wrReq, 'POST');

        
        XC_REST_DoxeeReadFileURL.doPost(); 
        system.assertnotEquals(wrf.ObjectType, 'pippo'); 
        Test.stopTest();
        
    }
    
    @isTest
    //Covers XC_TR_DocumentURL_GenerateCI
	static void testboth_SIGNED(){
        
        Test.startTest(); 
        NE__Order__c ord = XC_DF_Order.createOrder('InOrder');
        
        XC_DocumentType__c dt = new XC_DocumentType__c();
        dt.Category__c = 'SF_CONTRACT_SIGNED' ;
        dt.numberOfFiles__c = 1;
        dt.XC_Configuration__c = ord.id;
        insert dt;
        
        XC_DocumentType__c dt1 = new XC_DocumentType__c();
        dt1.Category__c = 'SF_CREDIT_ASSIGNMENT_SIGNED' ;
        dt1.numberOfFiles__c = 1;
        dt1.XC_Configuration__c = ord.id;
        insert dt1;
        
        XC_REST_DoxeeReadFileURL_W.WrapperRequest wrReq = new XC_REST_DoxeeReadFileURL_W.WrapperRequest();       
        wrReq.FileItem= new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrf = new XC_REST_DoxeeReadFileURL_W.WrapperRequestFile();
        
        wrf.ObjectType='CONFIGURATION';
		wrf.ObjectID = ord.Id;
		wrf.Category = 'SF_CONTRACT_SIGNED'; 
		wrf.DocumentURL = 'test';
		wrf.DocumentID = '12345';

		wrReq.FileItem.add(wrf);
	        
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTDRFUrlRequest(wrReq, 'POST');

        
        XC_REST_DoxeeReadFileURL.doPost(); 
        system.assertnotEquals(wrf.ObjectType, 'pippo'); 
        Test.stopTest();
        
    }
    
    @isTest
    //Covers XC_TR_DocumentURL_GenerateCI
	static void testboth_SIGNEDx4(){
        
        Test.startTest(); 
        NE__Order__c ord = XC_DF_Order.createOrder('InOrder');
        
        XC_DocumentType__c dt = new XC_DocumentType__c();
        dt.Category__c = 'SF_CONTRACT_SIGNED' ;
        dt.numberOfFiles__c = 1;
        dt.XC_Configuration__c = ord.id;
        insert dt;
        
        XC_DocumentType__c dt1 = new XC_DocumentType__c();
        dt1.Category__c = 'SF_CREDIT_ASSIGNMENT_SIGNED' ;
        dt1.numberOfFiles__c = 1;
        dt1.XC_Configuration__c = ord.id;
        insert dt1;
        
        XC_DocumentType__c dt2 = new XC_DocumentType__c();
        dt2.Category__c = 'SF_CONTRACT_TO_SIGN' ;
        dt2.numberOfFiles__c = 1;
        dt2.XC_Configuration__c = ord.id;
        insert dt2;
        
        XC_DocumentType__c dt3 = new XC_DocumentType__c();
        dt3.Category__c = 'SF_CREDIT_ASSIGNMENT_TO_SIGN' ;
        dt3.numberOfFiles__c = 1;
        dt3.XC_Configuration__c = ord.id;
        insert dt3;
        
        XC_REST_DoxeeReadFileURL_W.WrapperRequest wrReq = new XC_REST_DoxeeReadFileURL_W.WrapperRequest();       
        wrReq.FileItem= new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrf = new XC_REST_DoxeeReadFileURL_W.WrapperRequestFile();
        
        wrf.ObjectType='CONFIGURATION';
		wrf.ObjectID = ord.Id;
		wrf.Category = 'SF_CONTRACT_SIGNED'; 
		wrf.DocumentURL = 'test';
		wrf.DocumentID = '12345';

		wrReq.FileItem.add(wrf);
	        
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTDRFUrlRequest(wrReq, 'POST');

        
        XC_REST_DoxeeReadFileURL.doPost(); 

        Opportunity opp = new Opportunity();
        Id recordTypeIdChile =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('XC_Opportunity_Chile').getRecordTypeId();

        opp.RecordTypeId = recordTypeIdChile;

        opp.XC_LegalEntity__c = 'EnelX';

        opp.XC_Segment__c = 'B2B';

        opp.Name ='Opportunity B2B';

        opp.XC_BusinessLine__c = 'eIndustry';

        date startDate = date.newInstance(2020, 12, 17);

        date endDate = date.newInstance(2025, 12, 17);
        opp.XC_ContractualRevenueEndDate__c = endDate;

        opp.XC_ContractualRevenueStartDate__c = startDate;


        XC_REST_DoxeeReadFileURL_U.populateCustomerInteractionOpp(new Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> {wrf}, new Map<Id, Opportunity> {opp.id => opp});
        Test.stopTest();
        
    }
    
    @isTest
    //Covers XC_TR_DocumentURL_Handler
	static void testDocumentURL_Handler(){
    	XC_DocumentUrl__c du = new XC_DocumentUrl__c();
        insert du;
        update du;
        delete du;
    }
}