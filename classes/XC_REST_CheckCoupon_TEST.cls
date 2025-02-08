/**
 * The Class XC_REST_CheckCoupon_TEST.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it
 * @date Creation     : 15/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Test Class for XC_REST_CheckCoupon - XC_REST_CheckCoupon_U - XC_REST_CheckCoupon_V - XC_REST_CheckCoupon_W
 **/


@isTest
public without sharing class XC_REST_CheckCoupon_TEST {

    @TestSetup
    static void setup(){ 
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;

        List<Account> accList = XC_DF_Account.createResidentialAccounts(2);
        accList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Soho').getRecordTypeId();
        accList[0].XC_DocumentCountry__c = 'Spain';
        accList[0].IdentityType__c = 'NIF';
        accList[0].IdentityNumber__c = '14331883P';
        accList[0].Name = 'Test Account';
        insert accList;
        
        List<XC_Voucher__c> couponList = XC_DF_Voucher.generateSingleVoucher(3);
        couponList[0].XC_Account__c = accList[0].Id;
        couponList[1].XC_Status__c = 'Not Active';
        insert couponList;
    }

    
    // GET Correct No Specific Account
    @isTest
    static void testDoGetNoSpecificAccount(){

        test.startTest();

        System.RestContext.request = generateRestRequestGETGood();
        List<XC_Voucher__c> voucherList = [SELECT Id, XC_VoucherCode__c FROM XC_Voucher__c WHERE XC_Status__c = 'Active' AND XC_Account__c = null];
        System.RestContext.request.addParameter('couponCode', voucherList[0].XC_VoucherCode__c);
        List<Account> accList = [SELECT Id, IdentityNumber__c FROM Account];
        System.RestContext.request.addParameter('AccountID', accList[0].Id);

        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doGet();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // GET Correct With Specific Account
    @isTest
    static void testDoGetWithSpecificAccount(){

        test.startTest();
        System.RestContext.request = generateRestRequestGETGood();
        List<XC_Voucher__c> voucherList = [SELECT Id, XC_VoucherCode__c, XC_Account__c, XC_Account__r.IdentityNumber__c FROM XC_Voucher__c WHERE XC_Status__c = 'Active' AND XC_Account__c != null];
        System.RestContext.request.addParameter('couponCode', voucherList[0].XC_VoucherCode__c);
        System.RestContext.request.addParameter('IdentityNumber', voucherList[0].XC_Account__r.IdentityNumber__c);

        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doGet();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // GET Different Specific Account
    @isTest
    static void testDoGetDifferentSpecificAccount(){

        test.startTest();
        System.RestContext.request = generateRestRequestGETGood();
        List<XC_Voucher__c> voucherList = [SELECT Id, XC_VoucherCode__c, XC_Account__c FROM XC_Voucher__c WHERE XC_Status__c = 'Active' AND XC_Account__c != null];
        System.RestContext.request.addParameter('couponCode', voucherList[0].XC_VoucherCode__c);
        List<Account> accList = [SELECT Id FROM Account WHERE Id != :voucherList[0].XC_Account__c];
        System.RestContext.request.addParameter('AccountID', accList[0].Id);

        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doGet();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // GET Voucher Not Active
    @isTest
    static void testDoGetNotActive(){

        test.startTest();
        System.RestContext.request = generateRestRequestGETGood();
        List<XC_Voucher__c> voucherList = [SELECT Id, XC_VoucherCode__c, XC_Account__c FROM XC_Voucher__c WHERE XC_Status__c = 'Not Active'];
        System.RestContext.request.addParameter('couponCode', voucherList[0].XC_VoucherCode__c);
        List<Account> accList = [SELECT Id FROM Account];
        System.RestContext.request.addParameter('AccountID', accList[0].Id);

        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doGet();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // GET Wrong Header
    @isTest
    static void testDoGetWrongHeader(){

        test.startTest();
        System.RestContext.request = generateRestRequestGETGood();
        String t = System.RestContext.request.headers.remove('TransactionID');

        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doGet();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // GET Wrong Coupon
    @isTest
    static void testDoGetWrongCoupon(){

        test.startTest();
        System.RestContext.request = generateRestRequestGETGood();
        System.RestContext.request.addParameter('couponCode', 'WRONG');
        List<Account> accList = [SELECT Id FROM Account];
        System.RestContext.request.addParameter('AccountID', accList[0].Id);

        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doGet();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // GET Wrong Account
    @isTest
    static void testDoGetWrongAccount(){

        test.startTest();
        System.RestContext.request = generateRestRequestGETGood();
        List<XC_Voucher__c> voucherList = [SELECT Id, XC_VoucherCode__c FROM XC_Voucher__c WHERE XC_Status__c = 'Active'];
        System.RestContext.request.addParameter('couponCode', voucherList[0].XC_VoucherCode__c);
        System.RestContext.request.addParameter('PrimaryEmail', 'yuuwef@test.com');

        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doGet();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // GET Wrong Functionality
    @isTest
    static void testDoGetWrongFunctionality(){

        test.startTest();
        System.RestContext.request = generateRestRequestGETGood();
        System.RestContext.request.addHeader('Functionality', 'WRONG');

        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doGet();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // GET No CouponCode
    @isTest
    static void testDoGetNoCouponCode(){

        test.startTest();

        System.RestContext.request = generateRestRequestGETGood();
        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doGet();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // GET No Account
    @isTest
    static void testDoGetNoAccount(){

        test.startTest();

        System.RestContext.request = generateRestRequestGETGood();
        List<XC_Voucher__c> voucherList = [SELECT Id, XC_VoucherCode__c FROM XC_Voucher__c WHERE XC_Status__c = 'Active' AND XC_Account__c = null];
        System.RestContext.request.addParameter('couponCode', voucherList[0].XC_VoucherCode__c);

        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doGet();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // GET Wrong Counter
    @isTest
    static void testDoGetWrongCounter(){

        test.startTest();

        System.RestContext.request = generateRestRequestGETGood();
        List<XC_Voucher__c> voucherList = [SELECT Id, XC_VoucherCode__c FROM XC_Voucher__c WHERE XC_Status__c = 'Active' AND XC_Account__c = null];
        System.RestContext.request.addParameter('couponCode', voucherList[0].XC_VoucherCode__c);
        List<Account> accList = [SELECT Id, IdentityNumber__c FROM Account];
        System.RestContext.request.addParameter('AccountID', accList[0].Id);

        voucherList[0].XC_Usage_Counter__c = 10;
        update voucherList[0];

        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doGet();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // GET No Specific Account With Utilization
    @isTest
    static void testDoGetNoSpecificAccountWithUtilization(){

        test.startTest();

        System.RestContext.request = generateRestRequestGETGood();
        List<XC_Voucher__c> voucherList = [SELECT Id, XC_VoucherCode__c FROM XC_Voucher__c WHERE XC_Status__c = 'Active' AND XC_Account__c = null];
        System.RestContext.request.addParameter('couponCode', voucherList[0].XC_VoucherCode__c);
        List<Account> accList = [SELECT Id, IdentityNumber__c FROM Account];
        System.RestContext.request.addParameter('AccountID', accList[0].Id);

        XC_VoucherUtilization__c utilization = new XC_VoucherUtilization__c();
        utilization.XC_Account__c = accList[0].Id;
        utilization.XC_Voucher__c = voucherList[0].Id;
        insert utilization;

        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doGet();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // PUT Correct No Specific Account
    @isTest
    static void testDoPutNoSpecificAccount(){

        test.startTest();

        System.RestContext.request = generateRestRequestPUTGood();
        XC_REST_CheckCoupon_W.WrapperCheckCouponRequest body = new XC_REST_CheckCoupon_W.WrapperCheckCouponRequest();
        XC_REST_CheckCoupon_W.WrapperRequestElement wa = new XC_REST_CheckCoupon_W.WrapperRequestElement();
        List<XC_Voucher__c> voucherList = [SELECT Id, XC_VoucherCode__c FROM XC_Voucher__c WHERE XC_Status__c = 'Active' AND XC_Account__c = null];
        wa.couponCode = voucherList[0].XC_VoucherCode__c;
        List<Account> accList = [SELECT Id, IdentityNumber__c FROM Account];
        wa.AccountID = accList[0].Id;
        body.requestElement = new List<XC_REST_CheckCoupon_W.WrapperRequestElement>();
        body.requestElement.add(wa); 
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doPut();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // PUT Correct With Specific Account
    @isTest
    static void testDoPutWithSpecificAccount(){

        test.startTest();

        System.RestContext.request = generateRestRequestPUTGood();
        XC_REST_CheckCoupon_W.WrapperCheckCouponRequest body = new XC_REST_CheckCoupon_W.WrapperCheckCouponRequest();
        XC_REST_CheckCoupon_W.WrapperRequestElement wa = new XC_REST_CheckCoupon_W.WrapperRequestElement();
        List<XC_Voucher__c> voucherList = [SELECT Id, XC_VoucherCode__c, XC_Account__c, XC_Account__r.IdentityNumber__c FROM XC_Voucher__c WHERE XC_Status__c = 'Active' AND XC_Account__c != null];
        wa.couponCode = voucherList[0].XC_VoucherCode__c;
        wa.IdentityNumber = voucherList[0].XC_Account__r.IdentityNumber__c;
        body.requestElement = new List<XC_REST_CheckCoupon_W.WrapperRequestElement>();
        body.requestElement.add(wa); 
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doPut();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // PUT Wrong Functionality
    @isTest
    static void testDoPutWrongFunctionality(){

        test.startTest();
        System.RestContext.request = generateRestRequestPUTGood();
        System.RestContext.request.addHeader('Functionality', 'WRONG');
        XC_REST_CheckCoupon_W.WrapperCheckCouponRequest body = new XC_REST_CheckCoupon_W.WrapperCheckCouponRequest();
        XC_REST_CheckCoupon_W.WrapperRequestElement wa = new XC_REST_CheckCoupon_W.WrapperRequestElement();
        List<XC_Voucher__c> voucherList = [SELECT Id, XC_VoucherCode__c FROM XC_Voucher__c WHERE XC_Status__c = 'Active' AND XC_Account__c = null];
        wa.couponCode = voucherList[0].XC_VoucherCode__c;
        List<Account> accList = [SELECT Id, IdentityNumber__c FROM Account];
        wa.AccountID = accList[0].Id;
        body.requestElement = new List<XC_REST_CheckCoupon_W.WrapperRequestElement>();
        body.requestElement.add(wa); 
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        
        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doPut();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // PUT No RequestElement
    @isTest
    static void testDoPutNoRequestElement(){

        test.startTest();

        System.RestContext.request = generateRestRequestPUTGood();
        XC_REST_CheckCoupon_W.WrapperCheckCouponRequest body = new XC_REST_CheckCoupon_W.WrapperCheckCouponRequest();
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doPut();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // PUT No CouponCode
    @isTest
    static void testDoPutNoCouponCode(){

        test.startTest();

        System.RestContext.request = generateRestRequestPUTGood();
        XC_REST_CheckCoupon_W.WrapperCheckCouponRequest body = new XC_REST_CheckCoupon_W.WrapperCheckCouponRequest();
        XC_REST_CheckCoupon_W.WrapperRequestElement wa = new XC_REST_CheckCoupon_W.WrapperRequestElement();
        body.requestElement = new List<XC_REST_CheckCoupon_W.WrapperRequestElement>();
        body.requestElement.add(wa); 
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doPut();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // PUT No Account
    @isTest
    static void testDoPutNoAccount(){

        test.startTest();

        System.RestContext.request = generateRestRequestPUTGood();
        XC_REST_CheckCoupon_W.WrapperCheckCouponRequest body = new XC_REST_CheckCoupon_W.WrapperCheckCouponRequest();
        XC_REST_CheckCoupon_W.WrapperRequestElement wa = new XC_REST_CheckCoupon_W.WrapperRequestElement();
        List<XC_Voucher__c> voucherList = [SELECT Id, XC_VoucherCode__c, XC_Account__c, XC_Account__r.IdentityNumber__c FROM XC_Voucher__c WHERE XC_Status__c = 'Active' AND XC_Account__c != null];
        wa.couponCode = voucherList[0].XC_VoucherCode__c;
        body.requestElement = new List<XC_REST_CheckCoupon_W.WrapperRequestElement>();
        body.requestElement.add(wa); 
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doPut();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // PUT Catch
    @isTest
    static void testDoPutCatch(){

        test.startTest();
        System.RestContext.request = generateRestRequestPUTGood();
        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doPut();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // PUT No Specific Account With Utilization
    @isTest
    static void testDoPutNoSpecificAccountWithUtilization(){

        test.startTest();

        System.RestContext.request = generateRestRequestPUTGood();
        XC_REST_CheckCoupon_W.WrapperCheckCouponRequest body = new XC_REST_CheckCoupon_W.WrapperCheckCouponRequest();
        XC_REST_CheckCoupon_W.WrapperRequestElement wa = new XC_REST_CheckCoupon_W.WrapperRequestElement();
        List<XC_Voucher__c> voucherList = [SELECT Id, XC_VoucherCode__c FROM XC_Voucher__c WHERE XC_Status__c = 'Active' AND XC_Account__c = null];
        wa.couponCode = voucherList[0].XC_VoucherCode__c;
        List<Account> accList = [SELECT Id, IdentityNumber__c FROM Account];
        wa.AccountID = accList[0].Id;
        body.requestElement = new List<XC_REST_CheckCoupon_W.WrapperRequestElement>();
        body.requestElement.add(wa); 
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        XC_VoucherUtilization__c utilization = new XC_VoucherUtilization__c();
        utilization.XC_Account__c = accList[0].Id;
        utilization.XC_Voucher__c = voucherList[0].Id;
        insert utilization;

        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doPut();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // POST Wrong Functionality
    @isTest
    static void testDoPostWrongFunctionality(){

        test.startTest();
        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.addHeader('Functionality', 'WRONG');
        XC_REST_CheckCoupon_W.WrapperCheckCouponRequest body = new XC_REST_CheckCoupon_W.WrapperCheckCouponRequest();
        XC_REST_CheckCoupon_W.WrapperRequestElement wa = new XC_REST_CheckCoupon_W.WrapperRequestElement();
        List<XC_Voucher__c> voucherList = [SELECT Id, XC_VoucherCode__c FROM XC_Voucher__c WHERE XC_Status__c = 'Active' AND XC_Account__c = null];
        wa.couponCode = voucherList[0].XC_VoucherCode__c;
        List<Account> accList = [SELECT Id, IdentityNumber__c FROM Account];
        wa.AccountID = accList[0].Id;
        body.requestElement = new List<XC_REST_CheckCoupon_W.WrapperRequestElement>();
        body.requestElement.add(wa); 
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        
        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doPost();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // POST Wrong Operation
    @isTest
    static void testDoPostWrongOperation(){

        test.startTest();
        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.addHeader('Operation', 'WRONG');
        XC_REST_CheckCoupon_W.WrapperCheckCouponRequest body = new XC_REST_CheckCoupon_W.WrapperCheckCouponRequest();
        XC_REST_CheckCoupon_W.WrapperRequestElement wa = new XC_REST_CheckCoupon_W.WrapperRequestElement();
        List<XC_Voucher__c> voucherList = [SELECT Id, XC_VoucherCode__c FROM XC_Voucher__c WHERE XC_Status__c = 'Active' AND XC_Account__c = null];
        wa.couponCode = voucherList[0].XC_VoucherCode__c;
        List<Account> accList = [SELECT Id, IdentityNumber__c FROM Account];
        wa.AccountID = accList[0].Id;
        body.requestElement = new List<XC_REST_CheckCoupon_W.WrapperRequestElement>();
        body.requestElement.add(wa); 
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        
        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doPost();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // POST No RequestElement
    @isTest
    static void testDoPostNoRequestElement(){

        test.startTest();

        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_CheckCoupon_W.WrapperCheckCouponRequest body = new XC_REST_CheckCoupon_W.WrapperCheckCouponRequest();
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doPost();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // POST No CouponCode
    @isTest
    static void testDoPostNoCouponCode(){

        test.startTest();

        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_CheckCoupon_W.WrapperCheckCouponRequest body = new XC_REST_CheckCoupon_W.WrapperCheckCouponRequest();
        XC_REST_CheckCoupon_W.WrapperRequestElement wa = new XC_REST_CheckCoupon_W.WrapperRequestElement();
        body.requestElement = new List<XC_REST_CheckCoupon_W.WrapperRequestElement>();
        body.requestElement.add(wa); 
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doPost();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // POST Catch
    @isTest
    static void testDoPostCatch(){

        test.startTest();
        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doPost();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // POST Wrong Operation ReadBulk
    @isTest
    static void testDoPostWrongOperationReadBulk(){

        test.startTest();
        System.RestContext.request = generateRestRequestPOSTGoodReadBulk();
        System.RestContext.request.addHeader('Operation', 'WRONG');
        XC_REST_CheckCoupon_W.WrapperCheckCouponRequest body = new XC_REST_CheckCoupon_W.WrapperCheckCouponRequest();
        XC_REST_CheckCoupon_W.WrapperRequestElement wa = new XC_REST_CheckCoupon_W.WrapperRequestElement();
        List<XC_Voucher__c> voucherList = [SELECT Id, XC_VoucherCode__c FROM XC_Voucher__c WHERE XC_Status__c = 'Active' AND XC_Account__c = null];
        wa.couponCode = voucherList[0].XC_VoucherCode__c;
        List<Account> accList = [SELECT Id, IdentityNumber__c FROM Account];
        wa.AccountID = accList[0].Id;
        body.requestElement = new List<XC_REST_CheckCoupon_W.WrapperRequestElement>();
        body.requestElement.add(wa); 
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        
        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doPost();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // POST Read Bulk Missing Legal Entity
    @isTest
    static void testDoPostReadBulkMissingLegalEntity(){

        test.startTest();
        System.RestContext.request = generateRestRequestPOSTGoodReadBulk();
        XC_REST_CheckCoupon_W.WrapperCheckCouponRequest body = new XC_REST_CheckCoupon_W.WrapperCheckCouponRequest();
        XC_REST_CheckCoupon_W.WrapperRequestElement wa = new XC_REST_CheckCoupon_W.WrapperRequestElement();
        wa.LegalEntity = null;
        wa.RecordTypeName = 'AAA';
        body.requestElement = new List<XC_REST_CheckCoupon_W.WrapperRequestElement>();
        body.requestElement.add(wa); 
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        
        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doPost();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // POST Read Bulk Missing RT Name
    @isTest
    static void testDoPostReadBulkMissingRTName(){

        test.startTest();
        System.RestContext.request = generateRestRequestPOSTGoodReadBulk();
        XC_REST_CheckCoupon_W.WrapperCheckCouponRequest body = new XC_REST_CheckCoupon_W.WrapperCheckCouponRequest();
        XC_REST_CheckCoupon_W.WrapperRequestElement wa = new XC_REST_CheckCoupon_W.WrapperRequestElement();
        wa.LegalEntity = 'AAA';
        wa.RecordTypeName = null;
        body.requestElement = new List<XC_REST_CheckCoupon_W.WrapperRequestElement>();
        body.requestElement.add(wa); 
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        
        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doPost();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // POST Read Bulk Error Size
    @isTest
    static void testDoPostReadBulkErrorSize(){

        test.startTest();
        System.RestContext.request = generateRestRequestPOSTGoodReadBulk();
        XC_REST_CheckCoupon_W.WrapperCheckCouponRequest body = new XC_REST_CheckCoupon_W.WrapperCheckCouponRequest();
        XC_REST_CheckCoupon_W.WrapperRequestElement wa = new XC_REST_CheckCoupon_W.WrapperRequestElement();
        wa.LegalEntity = 'AAA';
        wa.RecordTypeName = 'AAA';
        XC_REST_CheckCoupon_W.WrapperRequestElement wb = new XC_REST_CheckCoupon_W.WrapperRequestElement();
        wb.LegalEntity = 'BBB';
        wb.RecordTypeName = 'BBB';
        body.requestElement = new List<XC_REST_CheckCoupon_W.WrapperRequestElement>();
        body.requestElement.add(wa); 
        body.requestElement.add(wb); 
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        
        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doPost();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // POST Read Bulk No Items
    @isTest
    static void testDoPostReadBulkNoItems(){

        test.startTest();
        System.RestContext.request = generateRestRequestPOSTGoodReadBulk();
        XC_REST_CheckCoupon_W.WrapperCheckCouponRequest body = new XC_REST_CheckCoupon_W.WrapperCheckCouponRequest();
        XC_REST_CheckCoupon_W.WrapperRequestElement wa = new XC_REST_CheckCoupon_W.WrapperRequestElement();
        wa.LegalEntity = 'AAA';
        wa.RecordTypeName = 'AAA';
        body.requestElement = new List<XC_REST_CheckCoupon_W.WrapperRequestElement>();
        body.requestElement.add(wa); 
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        
        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doPost();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    // POST Read Bulk correct
    @isTest
    static void testDoPostReadBulk(){

        test.startTest();
        System.RestContext.request = generateRestRequestPOSTGoodReadBulk();
        XC_REST_CheckCoupon_W.WrapperCheckCouponRequest body = new XC_REST_CheckCoupon_W.WrapperCheckCouponRequest();
        XC_REST_CheckCoupon_W.WrapperRequestElement wa = new XC_REST_CheckCoupon_W.WrapperRequestElement();
        List<XC_Voucher__c> voucherList = [SELECT Id, XC_VoucherCode__c, XC_LegalEntity__c, XC_RecordTypeName__c FROM XC_Voucher__c WHERE XC_Status__c = 'Active' AND XC_Account__c = null];
        wa.LegalEntity = voucherList[0].XC_LegalEntity__c;
        wa.RecordTypeName = voucherList[0].XC_RecordTypeName__c;
        body.requestElement = new List<XC_REST_CheckCoupon_W.WrapperRequestElement>();
        body.requestElement.add(wa); 
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
        
        System.RestContext.response = new RestResponse();

		XC_REST_CheckCoupon.doPost();
        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = (XC_REST_CheckCoupon_W.WrapperCheckCouponResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_CheckCoupon_W.WrapperCheckCouponResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');
        test.stopTest();
    }


    private static RestRequest generateRestRequestGETGood(){
            
        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'CheckCoupon');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'GET');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'GET';
        request.requestURI = '/v1/CheckCoupon/*';

        return request; 
    }


    private static RestRequest generateRestRequestPUTGood(){
            
        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'BurnCoupon');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'PUT');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'PUT';
        request.requestURI = '/v1/CheckCoupon/*';

        return request; 
    }


    private static RestRequest generateRestRequestPOSTGood(){
            
        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'CheckCoupon');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'Create');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'POST';
        request.requestURI = '/v1/CheckCoupon/*';

        return request; 
    }


    private static RestRequest generateRestRequestPOSTGoodReadBulk(){
            
        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'ReadBulk');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'ReadBulk');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'POST';
        request.requestURI = '/v1/CheckCoupon/*';

        return request; 
    }
    
}