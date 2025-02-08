/**
 * @author              Luisana Rocco lrocco@deloitte.it
 * @date Creation       28/05/2021
 * @date Modification   
 * @description         test class for XC_IN_QRS09_Disconnect
 */

@isTest
public without sharing class XC_IN_QRS09_Disconnect_TEST {
    @TestSetup
	static void setup(){ 
        
        
        List<NE__Billing_Profile__c> bp = XC_DF_BillingProfile.createBillingProfile(1);
        bp[0].XC_CommodityContractID__c = '0989878770111';
        bp[0].NE__Payment__c = 'Commodity Bill';
        update(bp);

        XC_BillingProfileLineItem__c bpli = [SELECT Id, XC_BillingProfile__c, XC_BillingProfile__r.NE__Account__c, XC_SoldToAddress__c FROM XC_BillingProfileLineItem__c  WHERE XC_BillingProfile__c =: bp[0].Id][0];
        bpli.XC_LegalEntity__c = 'EndesaX';
        bpli.XC_DocumentType__c = 'NIF';
        bpli.XC_DocumentNumber__c = '53672895A';
        bpli.XC_DocumentCountry__c = 'Spain';
        update bpli; 

        XC_Address__c addr = new XC_Address__c(Id = bpli.XC_SoldToAddress__c, XC_AddressCountry__c = 'Spain');
        update addr;
       
        /*List<Account> accList = new List<Account>{new Account(Id = bpli.XC_BillingProfile__r.NE__Account__c)};
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accList);
        conList[0].XC_PrimaryContact__c = true;
        insert conList;*/
        
        /*Opportunity opportunityToInsert = new Opportunity();
        opportunityToInsert.Name = 'OP00001';
        //opportunityToInsert.XC_Contact__c = conList[0].Id;
        //opportunityToInsert.AccountId = conList[0].AccountId;
        opportunityToInsert.XC_ProductCategoryOfInterest__c = 'Caldera';
        opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
        opportunityToInsert.StageName = 'Draft';
        opportunityToInsert.XC_Source__c = 'BLOG';
        opportunityToInsert.XC_ReceivingChannel__c = 'Web';
        opportunityToInsert.XC_Address__c = addr.Id;
        opportunityToInsert.XC_LegalEntity__c = 'EndesaX';
        insert opportunityToInsert;*/

        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'InOrder';
        //order.NE__OptyId__c = opportunityToInsert.Id;
        //order.NE__AccountId__c = opportunityToInsert.AccountId;
        order.XC_Country__c = 'Spain';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EndesaX';
        order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        insert order;

       

        NE__Product__c prod = new NE__Product__c();
        prod.XC_LIC_Product_Name__c = 'OK Gas Basic';
        insert prod;

        
        Asset ass= new Asset();
        ass.XC_BillingProfileLineItem__c  = bpli.Id;
        ass.NE__ProdId__c = prod.id;
        ass.Name='Test';
        ass.NE__Order_Config__c = order.Id;
        ass.Status = 'Active';
        ass.AccountId = bpli.XC_BillingProfile__r.NE__Account__c;
        ass.XC_LegalEntity__c = 'EndesaX';
        ass.XC_Segment__c = 'B2C';
        insert ass; 
        

       
        XC_QueuedRequest__c qr = new XC_QueuedRequest__c();
        qr.XC_RequestBody__c = '{"Order":{"AccountID":"'+ ass.AccountId +'", "AssetID": "'+ ass.Id + '", "OrderType":"Disconnection", "PartnerSalesChannel":"Sales","PartnerContractDelivered":true,"LegalEntity":"EndesaX","OrderStatus":"In Progress","Channel":"Market","IntegrationID":"33939308383328","VASContractNumber":"374839933888","VASContractExtID":"aD10D0000000KdcSAE","CommodityContractNum":"0989878770111","IBAN":"ES04949494848949484","CommodityContractActivationDate":"2020-05-03","CommodityBsnLine":"Gas","CommodityCancellationReason":"Volunter","MarketSegment":"Residential","ContractedPowerFrom":"0","ContractedPowerTo":"10","Tariff":"Gas", "Document": [{"ContractUrl": "https:S5kb2N4"}]}}';
        qr.XC_ClientSystem__c = 'CommoditySpainB2C';
        qr.XC_TransactionId__c = 'Test';
        insert qr;

        qr.XC_Status__c  = 'In Progress';
        update qr; 

    }

    
    @isTest
	static void disconnectAsset(){
        
        XC_QueuedRequestStep__c qrDisconnect = [SELECT Id, XC_QueuedRequest__r.XC_RequestBody__c FROM XC_QueuedRequestStep__c where XC_StepLabel__c = 'Disconnect'][0];

        List<XC_IN_QRS09_Disconnect.InputWrapper> inputs = new List<XC_IN_QRS09_Disconnect.InputWrapper>();
        XC_IN_QRS09_Disconnect.InputWrapper i = new XC_IN_QRS09_Disconnect.InputWrapper();
        i.stepId = qrDisconnect.id;
        inputs.add(i);
        
        test.startTest();
        XC_IN_QRS09_Disconnect.manageDisconnect(inputs);
        test.stopTest();


    }
    

    @isTest
	static void disconnectAssetWrongStatus(){
        
        Asset ass = [SELECT Id FROM Asset][0];
        ass.Status = 'Inactive';
        update ass;

        XC_QueuedRequestStep__c qrDisconnect = [SELECT Id, XC_QueuedRequest__r.XC_RequestBody__c FROM XC_QueuedRequestStep__c where XC_StepLabel__c = 'Disconnect'][0];

        List<XC_IN_QRS09_Disconnect.InputWrapper> inputs = new List<XC_IN_QRS09_Disconnect.InputWrapper>();
        XC_IN_QRS09_Disconnect.InputWrapper i = new XC_IN_QRS09_Disconnect.InputWrapper();
        i.stepId = qrDisconnect.id;
        inputs.add(i);
        
        test.startTest();
        XC_IN_QRS09_Disconnect.manageDisconnect(inputs);
        test.stopTest();


    }

     @isTest
	static void disconnectAssetMissinAssteID(){
        
        
        XC_QueuedRequestStep__c qrDisconnect = [SELECT Id, XC_QueuedRequest__r.XC_RequestBody__c FROM XC_QueuedRequestStep__c where XC_StepLabel__c = 'Disconnect'][0];

        XC_QueuedRequest__c qr = new XC_QueuedRequest__c(Id = qrDisconnect.XC_QueuedRequest__c);
        qr.XC_RequestBody__c = '{"Order":{"AssetID": "", "OrderType":"Disconnection", "PartnerSalesChannel":"Sales","PartnerContractDelivered":true,"LegalEntity":"EndesaX","OrderStatus":"In Progress","Channel":"Market","IntegrationID":"33939308383328","VASContractNumber":"374839933888","VASContractExtID":"aD10D0000000KdcSAE","CommodityContractNum":"0989878770111","IBAN":"ES04949494848949484","CommodityContractActivationDate":"2020-05-03","CommodityBsnLine":"Gas","CommodityCancellationReason":"Volunter","MarketSegment":"Residential","ContractedPowerFrom":"0","ContractedPowerTo":"10","Tariff":"Gas"}}';
        update qr;

        List<XC_IN_QRS09_Disconnect.InputWrapper> inputs = new List<XC_IN_QRS09_Disconnect.InputWrapper>();
        XC_IN_QRS09_Disconnect.InputWrapper i = new XC_IN_QRS09_Disconnect.InputWrapper();
        i.stepId = qrDisconnect.id;
        inputs.add(i);
        
        test.startTest();
        XC_IN_QRS09_Disconnect.executeDisconnect(inputs);
        test.stopTest();
    }


    @isTest
	static void disconnectAssetOrderAlreadyOpened(){
        
        NE__Order__c ord = [SELECT ID FROM NE__Order__c][0];
        ord.NE__Type__c = 'Disconnection';
        ord.XC_Status__c = 'In Progress';
        update(ord);

        XC_QueuedRequestStep__c qrDisconnect = [SELECT Id, XC_QueuedRequest__r.XC_RequestBody__c FROM XC_QueuedRequestStep__c where XC_StepLabel__c = 'Disconnect'][0];


        List<XC_IN_QRS09_Disconnect.InputWrapper> inputs = new List<XC_IN_QRS09_Disconnect.InputWrapper>();
        XC_IN_QRS09_Disconnect.InputWrapper i = new XC_IN_QRS09_Disconnect.InputWrapper();
        i.stepId = qrDisconnect.id;
        inputs.add(i);
        
        test.startTest();
        XC_IN_QRS09_Disconnect.executeDisconnect(inputs);
        test.stopTest();


    }

    @isTest
	static void manageDisconnectOrderTest(){
        
        XC_QueuedRequestStep__c qrDisconnect = [SELECT Id, XC_QueuedRequest__r.XC_RequestBody__c FROM XC_QueuedRequestStep__c where XC_StepLabel__c = 'Disconnect'][0];

        //Retrieve Order JSON Body
        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(qrDisconnect.XC_QueuedRequest__r.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        XC_REST_Order_U.WrapperPOSTRequest wrReq = new XC_REST_Order_U.WrapperPOSTRequest();
        wrReq.Order = fullQRReqBody.Order;

        Map<String,Object> utilMap = new Map<String,Object>();
        utilMap.put('currentStep', qrDisconnect);
        utilMap.put('wrReq', wrReq);
        XC_REST_Order_U.WrapperRes wrResp = new XC_REST_Order_U.WrapperRes();
        
        test.startTest();
        XC_IN_QRS09_Disconnect.manageDisconnectOrder(utilMap,wrResp);
        test.stopTest();


    }
    
    @isTest
	static void manageDisconnectOrderWithDisconnectOrderIdTest(){
        
        XC_QueuedRequestStep__c qrDisconnect = [SELECT Id, XC_QueuedRequest__r.XC_RequestBody__c FROM XC_QueuedRequestStep__c where XC_StepLabel__c = 'Disconnect'][0];

        //Retrieve Order JSON Body
        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(qrDisconnect.XC_QueuedRequest__r.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        XC_REST_Order_U.WrapperPOSTRequest wrReq = new XC_REST_Order_U.WrapperPOSTRequest();
        wrReq.Order = fullQRReqBody.Order;

        Map<String,Object> utilMap = new Map<String,Object>();
        utilMap.put('currentStep', qrDisconnect);
        utilMap.put('disconnectOrderId', '123');
        utilMap.put('wrReq', wrReq);
        XC_REST_Order_U.WrapperRes wrResp = new XC_REST_Order_U.WrapperRes();
        
        test.startTest();
        XC_IN_QRS09_Disconnect.manageDisconnectOrder(utilMap,wrResp);
        test.stopTest();


    }
    
     @isTest
	static void getAssetInfo(){
        
        XC_QueuedRequestStep__c qrDisconnect = [SELECT Id, XC_QueuedRequest__r.XC_RequestBody__c FROM XC_QueuedRequestStep__c where XC_StepLabel__c = 'Disconnect'][0];

        //Retrieve Order JSON Body
        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(qrDisconnect.XC_QueuedRequest__r.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        XC_REST_Order_U.WrapperPOSTRequest wrReq = new XC_REST_Order_U.WrapperPOSTRequest();
        wrReq.Order = fullQRReqBody.Order;

        Map<String,Object> utilMap = new Map<String,Object>();
        utilMap.put('currentStep', qrDisconnect);
        utilMap.put('wrReq', wrReq);
        utilMap.put('clientSystem','CommodityRomaniaB2C');
        utilMap.put('ContractId','123');
        XC_REST_Order_U.WrapperRes wrResp = new XC_REST_Order_U.WrapperRes();
        
        test.startTest();
        XC_IN_QRS09_Disconnect.getAssetInfo(utilMap,qrDisconnect);
        test.stopTest();


    }
    
    

    @isTest
	static void manageDisconnectOrderTestKO(){
        
        XC_QueuedRequestStep__c qrDisconnect = [SELECT Id, XC_QueuedRequest__r.XC_RequestBody__c FROM XC_QueuedRequestStep__c where XC_StepLabel__c = 'Disconnect'][0];

        //Retrieve Order JSON Body
        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(qrDisconnect.XC_QueuedRequest__r.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        XC_REST_Order_U.WrapperPOSTRequest wrReq = new XC_REST_Order_U.WrapperPOSTRequest();
        wrReq.Order = fullQRReqBody.Order;

        Map<String,Object> utilMap = new Map<String,Object>();
        utilMap.put('currentStep', qrDisconnect);
        utilMap.put('wrReq', wrReq);
        utilMap.put('disconnectOrderId', 'test');
        XC_REST_Order_U.WrapperRes wrResp = new XC_REST_Order_U.WrapperRes();
        
        test.startTest();
        XC_IN_QRS09_Disconnect.manageDisconnectOrder(utilMap,wrResp);
        test.stopTest();


    }

}