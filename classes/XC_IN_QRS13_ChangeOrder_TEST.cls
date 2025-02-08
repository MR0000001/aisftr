/**
 * @description       : 
 * @author            : De Blasio Valentina 
 * @group             : 
 * @last modified on  : 15-12-2021
 * @last modified by  : De Blasio Valentina 
 * Modifications Log 
 * Ver   Date         Author Modification
 * 1.0   15-12-2021   De Blasio Valentina  
**/
@isTest
public without sharing class XC_IN_QRS13_ChangeOrder_TEST {
  

    @TestSetup
    static void setup(){ 


        List<NE__Billing_Profile__c> bp = XC_DF_BillingProfile.createBillingProfile(1);

        XC_BillingProfileLineItem__c bpli = [SELECT Id, XC_BillingProfile__c, XC_BillingProfile__r.NE__Account__c, XC_SoldToAddress__c FROM XC_BillingProfileLineItem__c  WHERE XC_BillingProfile__c =: bp[0].Id][0];
        bpli.XC_LegalEntity__c = 'EnelXItalia';
        bpli.XC_DocumentType__c = 'Codice Fiscale';
        bpli.XC_DocumentNumber__c = 'BRMMRA72p95I438H';
        bpli.XC_DocumentCountry__c = 'Italy';
        update bpli; 

        XC_Address__c addr = new XC_Address__c(Id = bpli.XC_SoldToAddress__c, XC_AddressCountry__c = 'Italy', XC_Region__c = 'Basilicata');
        update addr;
       

        List<Account> accList = new List<Account>{new Account(Id = bpli.XC_BillingProfile__r.NE__Account__c)};
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accList);
        conList[0].XC_PrimaryContact__c = true;
        insert conList;
        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'InOrder';
        order.XC_Country__c = 'Spain';
        order.XC_Segment__c = 'B2B';
        order.XC_LegalEntity__c = 'Codensa';
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


        NE__Family__c fam = new NE__Family__c();
        fam.name = 'Test';
        insert fam;

        NE__DynamicPropertyDefinition__c propdef = new NE__DynamicPropertyDefinition__c();
        propdef.Name='Pfp';
        insert propdef;

        NE__ProductFamilyProperty__c famProp= new NE__ProductFamilyProperty__c();
        famProp.NE__FamilyId__c=fam.id;
        famProp.NE__PropId__c = propdef.id;
        insert famProp; 

        NE__Catalog_Item__c catItem = XC_DF_CatalogItem.createCatalogItem();
        catItem.Catalog_item_code__c = 'TestCatItem';
        catItem.NE__UsageCode__c = 'TestCatItem';
        insert catItem;

        NE__Catalog__c catalog = [Select id from NE__Catalog__c LIMIT 1];
        catalog.XC_LIC_Name__c = 'e-Home IT';
        update catalog;

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
        ass.XC_LegalEntity__c = 'Codensa';
        ass.XC_Segment__c = 'B2B';
        insert ass; 
        

        List<Account> acc = [SELECT Id, (SELECT Id, XC_BillingProfile__c  FROM XC_BillingProfileLineItems__r), (SELECT Id  FROM Addresses__r) FROM Account LIMIT 1];
        XC_QueuedRequest__c qr = new XC_QueuedRequest__c();
       // qr.XC_RequestBody__c = '{"Order":{"Channel":"EnelEnergiaItalia","Document":[{"ContractUrl":"http:z"}],"IntegrationID":"1231213123","LegalEntity":"Condensa","OrderItem":[{"Attribute":[{"Name":"Test:Pfp","ProductFamilyPropertyID":"a1V1l000000PNaMEAW","Value":"Monthly"}],"BaseOneTimeFee":0.00,"BaseRecurringCharge":7.50,"BundleConfiguration":null,"ContractType":"Light","ProdID":"TestCatItem","Quantity":1}],"OrderStatus":"In progress"}}';
        qr.XC_RequestBody__c ='{"Order":{"VASContractNumber":"20211122124459000","VASContractExtID":"20211122124459000","StartDate":"2021-11-19","OrderType":"Change Order","OrderSubType":"Promocode Application","OrderItem":[{"Quantity":1,"ProdID":"a1s7Z000001U4vSQAS","Attribute":[{"Value":"Monthly","Name":"Payment details:Payment Method"},{"Value":"Commodity Bill","Name":"Payment details:Payment type"},{"Value":83,"Name":"Third Party:Number of quotas"},{"Value":852,"Name":"Third Party:Price"},{"Value":"a1s7Z000001U4vSQAS","Name":"Third Party:Configuration Code"}]}],"LegalEntity":"Codensa","IntegrationID":"COL-PasaLaPagina_20211125013532322","Document":[{}]},"Identity":[{"ReleaseDate":"2016-12-06","IdentityType":"CC","IdentityNumber":"79771942","ExpiryDate":"2099-12-31","Country":"Colombia"}],"Contact":[{"ShippingContact":true,"Salutation":"Prof.","ReleaseDate":"2020-05-04","PrimaryContact":true,"MainPhonePrefix":"+57","MainPhone":"3454398163","LastName":"CLAVIJO CASTRILLON","GDPR":{"RobinsonCustomer":"Y","LegalEntity":[{"LegalEntity":"Codensa","GiveDataToLegalEntity":"Y","GiveDataForProfiling":"N","GiveDataForMarketing":"Y","Country":"Colombia"}],"GiveDataToThirdParties":"Y","DoNotDisturb":"Y","ConsentThirdPartyDate":"2021-10-19"},"FirstName":"ABELARDO","ExpiryDate":"2099-12-31","Email":"abelardo.castrillo@yopmail.com","Country":"Colombia","Birthdate":"1983-02-19"}],"BillingProfile":[{"PaymentMethod":"Commodity Bill","LegalEntity":"Codensa","InvoiceDeliveryPref":"Email","CupsID":"958037-9","Country":"Colombia","CommodityBillingCycleFrequency":"01"}],"Address":[{"ZipCode":"0","StreetType":"Calle","StreetNumber":"1","Stair":"","Province":"Bogotá D.C","PointOfService":[{"POSType":"Light","POS":"958037-9"}],"Floor":"","Door":"","Country":"Colombia","City":"Bogotà","Address":"CR 3 C N 92B 24 sur 002543"}],"Account":{"PrimaryEmail":"abelardo.castrillo@yopmail.com","PartnerClientSystem":"COL-PasaLaPagina","MainPhonePrefix":"+57","MainPhone":"3454398163","LastName":"CLAVIJO CASTRILLON","FirstName":"ABELARDO","Country":"Colombia","Birthdate":"1983-02-19","AccountType":"Residential"}}';
        qr.XC_ClientSystem__c = 'CommodityItalyB2C';
        qr.XC_TransactionId__c = 'Test';
        insert qr;

        XC_REST_Account_W.WrapperResponse responseWrPreviousStepAddress = new XC_REST_Account_W.WrapperResponse();
        responseWrPreviousStepAddress.Account = new XC_UTIL_Account.AccountIFWrapper();
        responseWrPreviousStepAddress.Account.AccountID = acc[0].Id;
        responseWrPreviousStepAddress.Address = new List<XC_UTIL_Address.AddressWrapper>();
        XC_UTIL_Address.AddressWrapper addressWr = new XC_UTIL_Address.AddressWrapper();
        addressWr.AddressID = acc[0].Addresses__r[0].Id;
        responseWrPreviousStepAddress.Address.add(addressWr); 

        XC_REST_Account_W.WrapperResponse responseWrPreviousStepBP = new XC_REST_Account_W.WrapperResponse();
        responseWrPreviousStepBP.Account = new XC_UTIL_Account.AccountIFWrapper();
        responseWrPreviousStepBP.Account.AccountID = acc[0].Id;
        responseWrPreviousStepBP.BillingProfile = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
        XC_UTIL_BillingProfile.BillingProfileIFWrapper billingProfileWr = new  XC_UTIL_BillingProfile.BillingProfileIFWrapper();
        billingProfileWr.BillingProfileID = acc[0].XC_BillingProfileLineItems__r[0].XC_BillingProfile__c;
        responseWrPreviousStepBP.BillingProfile.add(billingProfileWr);
        List<XC_QueuedRequest__c> qrList = XC_DF_QueuedRequest.createQueuedRequest(1);
        insert qrList;
       
     
    }

    @isTest
    static void manageChangeOrderTest(){
        XC_QueuedRequestStep__c qsOrder = [SELECT Id, XC_QueuedRequest__r.XC_RequestBody__c FROM XC_QueuedRequestStep__c limit 1];

        List<XC_IN_QRS13_ChangeOrder.InputWrapper> inputs = new List<XC_IN_QRS13_ChangeOrder.InputWrapper>();
        XC_IN_QRS13_ChangeOrder.InputWrapper i = new XC_IN_QRS13_ChangeOrder.InputWrapper();
        i.stepId = qsOrder.id;
        inputs.add(i);
        
        test.startTest();       
        System.enqueueJob(new XC_IN_QRS13_ChangeOrder.QueueableExecuteChangeOrder(new list<XC_IN_QRS13_ChangeOrder.InputWrapper> {i}));
        test.stopTest();


    }

    @isTest
    static void manageOperationBeforeCOTest(){
     
        Map<String,Object> utilMap = populateUtilMap();
        test.startTest();
        XC_IN_QRS13_ChangeOrder.manageOperationBeforeCO(utilMap);
        test.stopTest();
        System.assert(true, !utilMap.isEmpty());
    }
    @isTest
    static void manageChangeOrderCreationTest(){

        Map<String,Object> utilMap = populateUtilMap();
        /*Case c = [Select id FROM Case LIMIT 1][0];
        utilMap.put('changeOrderCase', c);  */
        XC_REST_Order_U.WrapperRes wrResp = new XC_REST_Order_U.WrapperRes();     
        test.startTest();
        XC_IN_QRS13_ChangeOrder.manageChangeOrderCreation(utilMap,wrResp);
        test.stopTest();
        System.assert(true, !utilMap.isEmpty());

    }
     /**
    * @description method to populate the util map
    * @return utilMap
    **/
    private static Map<String,Object> populateUtilMap(){

        XC_QueuedRequestStep__c qrChangeOwnership = [SELECT Id, XC_StepSequence__c, XC_QueuedRequest__r.XC_RequestBody__c FROM XC_QueuedRequestStep__c limit 1];

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