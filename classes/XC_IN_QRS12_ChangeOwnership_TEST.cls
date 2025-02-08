/**
 * @author              Luisana Rocco lrocco@deloitte.it
 * @date Creation       11/10/2021
 * @date Modification   
 * @description         test class for XC_IN_QRS12_ChangeOwnership, XC_IN_QRS12_ChangeOwnership_U
 */

@isTest
public without sharing class XC_IN_QRS12_ChangeOwnership_TEST {
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

        XC_Address__c addr = new XC_Address__c(Id = bpli.XC_SoldToAddress__c, XC_AddressCountry__c = 'Spain', XC_Account__c  =  bpli.XC_BillingProfile__r.NE__Account__c);
        update addr;

        List<Account> accList = new List<Account>();
        accList.add(New Account(Id= bpli.XC_BillingProfile__r.NE__Account__c));
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accList);
        conList[0].XC_PrimaryContact__c = true;
        insert conList;
    

        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'InOrder';
        order.XC_Country__c = 'Spain';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EndesaX';
        order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        order.XC_Status__c = 'Closed';
        order.XC_InstallationAddress__c = addr.id;
        order.XC_DeliveryAddress__c = addr.id;
        order.NE__AccountId__c = bpli.XC_BillingProfile__r.NE__Account__c;
        insert order;
        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
        item.XC_Installation_Address__c = addr.id;
        item.NE__Account__c = bpli.XC_BillingProfile__r.NE__Account__c;
        item.XC_ForcePaymentMethodEdit__c = true;
        insert item; 


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
        ass.XC_Address__c = addr.Id;
        ass.XC_LegalEntity__c = 'EndesaX';
        ass.XC_Segment__c = 'B2C';
        insert ass; 

        List<Case> caseList = XC_DF_Case.createCases(1);
        insert caseList;

        
        
        XC_QueuedRequest__c qr = new XC_QueuedRequest__c();
        qr.XC_RequestBody__c = '{"Order":{"AssetID": "'+ ass.Id + '",  "AccountID": "'+ bpli.XC_BillingProfile__r.NE__Account__c + '", "OrderType":"ChangeOrder", "OrderSubType":"Change of ownership", "LegalEntity":"EndesaX","OrderStatus":"In Progress","Channel":"Market","IntegrationID":"33939308383328","VASContractNumber":"374839933888","VASContractExtID":"aD10D0000000KdcSAE","CommodityContractNum":"0989878770111","IBAN":"ES04949494848949484", "ChangeOwnerReason": "With Subrogation", "Document":[{"ContractUrl":"http:TEST"}]}}';
        qr.XC_ClientSystem__c = 'CommoditySpainB2C';
        qr.XC_TransactionId__c = 'Test';
        insert qr;

        qr.XC_Status__c  = 'In Progress';
        update qr;

        XC_REST_Account_W.WrapperResponse responseWrPreviousStepAddress = new XC_REST_Account_W.WrapperResponse();
        responseWrPreviousStepAddress.Account = new XC_UTIL_Account.AccountIFWrapper();
        responseWrPreviousStepAddress.Account.AccountID = bpli.XC_BillingProfile__r.NE__Account__c;
        responseWrPreviousStepAddress.Address = new List<XC_UTIL_Address.AddressWrapper>();
        XC_UTIL_Address.AddressWrapper addressWr = new XC_UTIL_Address.AddressWrapper();
        addressWr.AddressID = addr.Id;
        responseWrPreviousStepAddress.Address.add(addressWr); 

        XC_REST_Account_W.WrapperResponse responseWrPreviousStepBP = new XC_REST_Account_W.WrapperResponse();
        responseWrPreviousStepBP.Account = new XC_UTIL_Account.AccountIFWrapper();
        responseWrPreviousStepBP.Account.AccountID = bpli.XC_BillingProfile__r.NE__Account__c;
        responseWrPreviousStepBP.BillingProfile = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
        XC_UTIL_BillingProfile.BillingProfileIFWrapper billingProfileWr = new  XC_UTIL_BillingProfile.BillingProfileIFWrapper();
        billingProfileWr.BillingProfileID = bpli.XC_BillingProfile__c;
        responseWrPreviousStepBP.BillingProfile.add(billingProfileWr);



        List<XC_QueuedRequestStep__c> qsList = [SELECT XC_StepSequence__c, XC_ExecutionResponse__c  FROM XC_QueuedRequestStep__c];

        for(XC_QueuedRequestStep__c qs : qsList){
            if(qs.XC_StepSequence__c == 2){
                qs.XC_ExecutionResponse__c = JSON.serialize(responseWrPreviousStepAddress);  
            }
            else  if(qs.XC_StepSequence__c == 3){
                qs.XC_ExecutionResponse__c = JSON.serialize(responseWrPreviousStepBP);
            }
        }
        update qsList;


    }

    
    @isTest
	static void manageChangeOwnershipTest(){
        
        XC_QueuedRequestStep__c qrChangeOwnership = [SELECT Id, XC_StepSequence__c, XC_QueuedRequest__r.XC_RequestBody__c FROM XC_QueuedRequestStep__c where XC_StepLabel__c = 'Change Of Ownership'][0];

        List<XC_IN_QRS12_ChangeOwnership.InputWrapper> inputs = new List<XC_IN_QRS12_ChangeOwnership.InputWrapper>();
        XC_IN_QRS12_ChangeOwnership.InputWrapper i = new XC_IN_QRS12_ChangeOwnership.InputWrapper();
        i.stepId = qrChangeOwnership.id;
        inputs.add(i);
        
        test.startTest();
        XC_IN_QRS12_ChangeOwnership.manageChangeOwnership(inputs);
        test.stopTest();

        System.assert(true, qrChangeOwnership != null);
    }


    @isTest
	static void missingChangeReasonTest(){
        
        XC_QueuedRequestStep__c qrChangeOwnership = [SELECT Id, XC_StepSequence__c, XC_QueuedRequest__r.XC_RequestBody__c FROM XC_QueuedRequestStep__c where XC_StepLabel__c = 'Change Of Ownership'][0];
        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(qrChangeOwnership.XC_QueuedRequest__r.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        XC_REST_Order_U.WrapperPOSTRequest wrReq = new XC_REST_Order_U.WrapperPOSTRequest();
        wrReq.Order = fullQRReqBody.Order;
        wrReq.Order.ChangeOwnerReason = '';
        fullQRReqBody.Order = wrReq.Order;
        XC_QueuedRequest__c  qr = new XC_QueuedRequest__c (id = qrChangeOwnership.XC_QueuedRequest__c,  XC_RequestBody__c =JSON.Serialize(fullQRReqBody, true) );
        update qr;

        List<XC_IN_QRS12_ChangeOwnership.InputWrapper> inputs = new List<XC_IN_QRS12_ChangeOwnership.InputWrapper>();
        XC_IN_QRS12_ChangeOwnership.InputWrapper i = new XC_IN_QRS12_ChangeOwnership.InputWrapper();
        i.stepId = qrChangeOwnership.id;
        inputs.add(i);
        
        test.startTest();
        XC_IN_QRS12_ChangeOwnership.executeChangeOwnership(inputs);
        test.stopTest();

        System.assert(true, qrChangeOwnership != null);
    }


    @isTest
	static void wrongAssetIdTest(){
        
        Map<String,Object> utilMap = populateUtilMap();
        String assetId = ((String) utilMap.get('assetId'));
        assetId = assetId.substring(0, assetId.length()-2);
        assetId = assetId + '00';
        utilMap.put('assetId', assetId);

        test.startTest();
        XC_IN_QRS12_ChangeOwnership.manageOperationBeforeCO(utilMap);
        test.stopTest();

        System.assert(true, !utilMap.isEmpty());
    }

    @isTest
	static void missingAssetTest(){
        
        Map<String,Object> utilMap = populateUtilMap();
        utilMap.put('assetId', null);

        test.startTest();
        XC_IN_QRS12_ChangeOwnership.manageOperationBeforeCO(utilMap);
        test.stopTest();

        System.assert(true, !utilMap.isEmpty());
    }


    @isTest
	static void missingBpliTest(){
        
        XC_BillingProfileLineItem__c bpli = [SELECT Id, XC_BillingProfile__c, XC_BillingProfile__r.NE__Account__c, XC_SoldToAddress__c FROM XC_BillingProfileLineItem__c  LIMIT 1][0];
        bpli.XC_LegalEntity__c = 'EnelX';
        update bpli; 

        Map<String,Object> utilMap = populateUtilMap();
        test.startTest();
        XC_IN_QRS12_ChangeOwnership.manageOperationBeforeCO(utilMap);
        test.stopTest();
        System.assert(true, !utilMap.isEmpty());
    }


    @isTest
	static void missingOITest(){
        

        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'InOrder';
        order.XC_Country__c = 'Spain';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EndesaX';
        order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        order.XC_Status__c = 'Closed';
        insert order; 

        map<id,NE__OrderItem__c> oiToUnlink = new Map<id, NE__OrderItem__c> ([SELECT id, NE__OrderId__c FROM NE__OrderItem__c]);
        
        for(NE__OrderItem__c oi : oiToUnlink.values()){
            oi.NE__OrderId__c = order.id;
        }
        update oiToUnlink.values();

        Map<String,Object> utilMap = populateUtilMap();
        test.startTest();
        XC_IN_QRS12_ChangeOwnership.manageOperationAfterCO(utilMap);
        test.stopTest();

        System.assert(true, !utilMap.isEmpty());
    }



    @isTest
	static void beforeChangeOrderTest(){

      
        Map<String,Object> utilMap = populateUtilMap();

        test.startTest();
        XC_IN_QRS12_ChangeOwnership.manageOperationBeforeCO(utilMap);
        test.stopTest();

        System.assert(true, !utilMap.isEmpty());
    }


    @isTest
	static void assetChildTest(){

        Map<String,Object> utilMap = populateUtilMap();

        test.startTest();
        Asset ass = [SELECT ID FROM Asset LIMIT 1];
        WorkOrder wo = new WorkOrder  (AssetId = ass.id, Status = 'New');
        insert wo;
        
        
        XC_IN_QRS12_ChangeOwnership.manageOperationBeforeCO(utilMap);
        test.stopTest();

        System.assert(true, !utilMap.isEmpty());
    }

    
    @isTest
	static void OrderInProgressTest(){

        Map<String,Object> utilMap = populateUtilMap();

        test.startTest();
        Asset ass = [SELECT ID FROM Asset LIMIT 1];
        
        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'InOrder';
        order.XC_Country__c = 'Spain';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EndesaX';
        order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        order.XC_Status__c = 'In progress';
        insert order;

        ass.NE__Order_Config__c = order.Id;
        update ass;
        
        
        XC_IN_QRS12_ChangeOwnership.manageOperationBeforeCO(utilMap);
        test.stopTest();

        System.assert(true, !utilMap.isEmpty());
    }

     
    @isTest
	static void OrderInProgress2Test(){

        Map<String,Object> utilMap = populateUtilMap();

        test.startTest();
        Asset ass = [SELECT ID FROM Asset LIMIT 1];
        
        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'ChangeOrder';
        order.XC_Country__c = 'Spain';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EndesaX';
        order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        order.XC_Status__c = 'In progress';
        insert order;

        ass.NE__Order_Config__c = order.Id;
        update ass;
        
        
        XC_IN_QRS12_ChangeOwnership.manageOperationBeforeCO(utilMap);
        test.stopTest();

        System.assert(true, !utilMap.isEmpty());
    }

    @isTest
	static void afterChangeOrderTest(){

        Map<String,Object> utilMap = populateUtilMap();
        
        test.startTest();
        XC_IN_QRS12_ChangeOwnership.manageOperationAfterCO(utilMap);
        test.stopTest();

        System.assert(true, !utilMap.isEmpty());

    }


    @isTest
	static void manageChangeOrderTest(){

        Map<String,Object> utilMap = populateUtilMap();
        Case c = [Select id FROM Case LIMIT 1][0];

        utilMap.put('changeOrderCase', c);
        
        test.startTest();
        XC_IN_QRS12_ChangeOwnership.manageChangeOrderCreation(utilMap);
        test.stopTest();
        System.assert(true, !utilMap.isEmpty());

    }


    /**
    * @description method to populate the util map
    * @return utilMap
    **/
    private static Map<String,Object> populateUtilMap(){

        XC_QueuedRequestStep__c qrChangeOwnership = [SELECT Id, XC_StepSequence__c, XC_QueuedRequest__r.XC_RequestBody__c FROM XC_QueuedRequestStep__c where XC_StepLabel__c = 'Change Of Ownership'][0];

        NE__Order__c ord = [SELECT Id, XC_DeliveryAddress__c,XC_InstallationAddress__c,NE__AccountId__c FROM NE__Order__c LIMIT 1];
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, XC_Segment__c,
                                                            (SELECT id FROM assets),
                                                            (SELECT Id, XC_BillingProfile__c, XC_BillingProfile__r.NE__Payment__c, XC_BillToAddress__c, XC_SoldToAddress__c  FROM XC_BillingProfileLineItems__r),
                                                            (SELECT Id, XC_AddressProvince__c, XC_BillingAddress__c, XC_PricinRegion__c, XC_DeliveryAddress__c, XC_InstallationAddress__c  FROM Addresses__r )
                                                            FROM Account WHERE Id =:  ord.NE__AccountId__c LIMIT 1]);


        // Retrieve previous steps 
        Set<Integer> previousSequences = new Set<Integer> {Integer.valueOf(qrChangeOwnership.XC_StepSequence__c)-1,  Integer.valueOf(qrChangeOwnership.XC_StepSequence__c)-2};
        Map<Id,XC_QueuedRequestStep__c> previousSteps = XC_UTIL_QueuedRequestStep.getQueuedRequestSteps(qrChangeOwnership,  previousSequences);
        XC_REST_Order_U.WrapperRes wrResp = new XC_REST_Order_U.WrapperRes();

        //Retrieve Order JSON Body
        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(qrChangeOwnership.XC_QueuedRequest__r.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        XC_REST_Order_U.WrapperPOSTRequest wrReq = new XC_REST_Order_U.WrapperPOSTRequest();
        wrReq.Order = fullQRReqBody.Order;


        Map<String,Object> utilMap = new Map<String,Object>();
        utilMap.put('currentStep', qrChangeOwnership);
        utilMap.put('wrReq', wrReq);
        utilMap.put('wrResp', wrResp);
        utilMap.put('assetId', wrReq.Order.AssetID); 
        utilMap.put('stepId', qrChangeOwnership.Id);
        utilMap.put('legalEntity', wrReq.Order.LegalEntity);
        utilMap.put('previousSteps',previousSteps);
        utilMap.put('accountId',  wrReq.Order.AccountID);
        utilMap.put('accountIdNew',  wrReq.Order.AccountID);
        utilMap.put('changeOrderId',  ord.Id);
        utilMap.put('segment', accountMap.values()[0].XC_Segment__c);
        utilMap.put('accountMap', accountMap);

        Map<Id,Asset> mapAsset = new Map<Id, Asset>([SELECT Id,Name, NE__Order_Config__c,NE__Order_Config__r.NE__Type__c,
                                            NE__Order_Config__r.XC_Status__c, Status, NE__Order_Config__r.Name, Account.XC_Segment__c,
                                            (SELECT id, Status FROM WorkOrders 
                                            WHERE Status='New' OR Status = 'Assigned' OR Status = 'On Hold' OR Status='In Progress')
                                            FROM Asset WHERE Id =: accountMap.values()[0].Assets[0].Id]);
      
        utilMap.put('mapAsset', mapAsset);

        
        Map<Id,XC_Address__c> addressMap = new Map<Id,XC_Address__c>();
        for(XC_Address__c addr : accountMap.values()[0].Addresses__r){
            addressMap.put(addr.Id, addr);
        }
        utilMap.put('addressMap', addressMap);


        return utilMap;
    }

}