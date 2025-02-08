/*
@author            : De Blasio Valentina
@group             : ACN Team
@last modified on  : 23-12-2021
@last modified by  : De Blasio Valentina
@description       : Test Class for XC_IN_QRS13_ChangeOrder_U.cls
Ver   Date         Author                                        Modification
1.0   20-12-2021   De Blasio Valentina       Initial Version

**/
@isTest
public without sharing class  XC_IN_QRS13_ChangeOrder_U_TEST {
 

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
       
        List<Account>  accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;

        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accountList);
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
        ass.ContactId=conList[0].id;
        insert ass; 

        List<Account> acc = [SELECT Id, (SELECT Id, XC_BillingProfile__c  FROM XC_BillingProfileLineItems__r), (SELECT Id  FROM Addresses__r) FROM Account LIMIT 1];
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(acc);
        contacts[0].XC_Segment__c = 'B2C'; 
        contacts[0].XC_CountryLegalEntity__c = 'ITALY';
        contacts[0].XC_MainLegalEntity__c = 'EnelXItalia';
        insert contacts;

        XC_UTIL_QueuedRequest_W.WrapperRequest wr = generateRequestBody();
        wr.Order.VASContractExtID='Test1234567';
        wr.Account.Phone='3485812402';

        XC_QueuedRequest__c qr = new XC_QueuedRequest__c();
        qr.XC_ClientSystem__c = 'CommodityItalyB2C';
        qr.XC_TransactionId__c = 'Test';
        qr.XC_RequestBody__c = JSON.serialize(wr);
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

        XC_CS004_Bit2WinCredentials__c xccs=new XC_CS004_Bit2WinCredentials__c();
        xccs.XC_ServerURL__c='test';
        xccs.XC_ClientId__c='client';
        xccs.XC_OrganizationId__c='111';
        xccs.XC_EngineVersion__c='2';
        xccs.XC_Country__c='SPAIN';
        insert xccs;

        XC_CS005_Bit2WinChangeAPI__c xcba = new XC_CS005_Bit2WinChangeAPI__c();
        xcba.XC_Password__c='1111'; 
        xcba.XC_PasswordToken__c='222'; 
        xcba.XC_ServerURL__c='22222';
        xcba.XC_UserToken__c='2222';
        xcba.XC_Country__c = 'SPAIN';
        insert xcba;   
    }

    @isTest
    static void populateWrResTest(){    
        Map<String,Object> utilMap = populateUtilMap();
        test.startTest();       
        XC_IN_QRS13_ChangeOrder_U.populateWrRes(utilMap);
        test.stopTest();
    }
    @isTest
    static void searchCatalogItemestTest(){
        List<NE__Catalog_Item__c> catalogItems=new List<NE__Catalog_Item__c>();
        XC_UTIL_QueuedRequest_W.WrapperRequest wrReq = generateRequestBody();
        XC_REST_Order_U.WrapperPOSTRequest ord=new XC_REST_Order_U.WrapperPOSTRequest();
        ord.Order=wrReq.Order;
        test.startTest();
        catalogItems=XC_IN_QRS13_ChangeOrder_U.searchCatalogItem(ord);
        test.stopTest();
    }
    @isTest
    static void manageCaseCreationTest(){
        
       List<XC_CM_Case_Type_Setting__mdt> caseTypeSettingsMtd = [SELECT id, DeveloperName,XC_Resolution__c, XC_Case_Reason__c, XC_Sub_Cause__c, XC_Sub_Type__c, XC_Priority__c, 
                                                                    XC_Origin__c, XC_Status__c, XC_Result__c, XC_CaseRemarks__c, XC_CaseRemarksEnelXItalia__c
                                                                    FROM XC_CM_Case_Type_Setting__mdt 
                                                                  limit 1];
        List<String> caseSettingNames=new List<String>();
        caseSettingNames.add(caseTypeSettingsMtd[0].DeveloperName);
        Map<String,Object> utilMap = populateUtilMap();
        test.startTest();
        XC_IN_QRS13_ChangeOrder_U.manageCaseCreation(utilMap,caseSettingNames);
        test.stopTest();

    
    }
    @isTest
    static void changeOfferTest(){
        
        Map<String, String> infos=new Map<String, String>();  
        test.startTest();
        XC_IN_QRS13_ChangeOrder_U.changeOffer(infos);
        test.stopTest(); 
    }
    @isTest
    static void manageUpdateTest(){      
        XC_QueuedRequestStep__c qrChangeOwnership = [SELECT Id, XC_StepSequence__c, XC_QueuedRequest__r.XC_RequestBody__c FROM XC_QueuedRequestStep__c limit 1];
        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(qrChangeOwnership.XC_QueuedRequest__r.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        XC_REST_Order_U.WrapperPOSTRequest wrReq = new XC_REST_Order_U.WrapperPOSTRequest();
        wrReq.Order = fullQRReqBody.Order;
        XC_REST_Order_U.WrapperRes wrResp = new XC_REST_Order_U.WrapperRes();     
        Map<String,Object> utilMap = populateUtilMap();
        test.startTest();
        XC_IN_QRS13_ChangeOrder_U.manageUpdate(wrReq,wrResp,utilMap);
        test.stopTest();

    
    }
    @isTest
    static void changeOrderTest(){     
        Asset ass=[Select id,Contact.AccountId,XC_BillingProfileLineItem__c,XC_BillingProfileLineItem__r.XC_BillingProfile__c,XC_Address__c,NE__Order_Config__r.NE__OptyId__r.XC_Province__c from Asset limit 1];
        List<NE__Catalog_Item__c> ct=[select id,NE__UsageCode__c from NE__Catalog_Item__c limit 1];
        XC_QueuedRequestStep__c qrChangeOwnership = [SELECT Id, XC_StepSequence__c, XC_QueuedRequest__r.XC_RequestBody__c FROM XC_QueuedRequestStep__c limit 1];
        XC_UTIL_QueuedRequest_W.WrapperRequest wrReq = generateRequestBody();
        XC_REST_Order_U.WrapperPOSTRequest ord=new XC_REST_Order_U.WrapperPOSTRequest();
        XC_UTIL_BillingProfile.BillingProfileIFWrapper bpWr = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
        ord.Order=wrReq.Order;
        ct[0].NE__UsageCode__c='ECMAN24';
        update ct;
        XC_REST_Order_U.WrapperRes wrResp = new XC_REST_Order_U.WrapperRes();         
        Map<String,Object> utilMap = populateUtilMap();
        Map<String, String> infos=new Map<String, String>();    
        test.startTest();
        XC_IN_QRS13_ChangeOrder_U.changeOrder(ord,wrResp,utilMap,ass);
        test.stopTest();

    
    }

    static XC_UTIL_QueuedRequest_W.WrapperRequest generateRequestBody(){
        
        XC_UTIL_QueuedRequest_W.WrapperRequest req = new XC_UTIL_QueuedRequest_W.WrapperRequest();
        
        //POPULATE ACCOUNT SECTION
        req.Account = new XC_UTIL_Account.AccountIFWrapper();
        req.Account.AccountType = 'Residential';
        req.Account.UniqueID = 'd72face1-5088-4f16-9fd4-80a412a1ce6c';
        req.Account.FirstName = 'GIOVANNI';
        req.Account.LastName = 'MORI';
        req.Account.Name = 'MORI GIOVANNI';
        req.Account.MainPhonePrefix = '+39';
        req.Account.MainPhone = '3485812402';
        req.Account.PrimaryEmail = 'giovanni.mori@enel.com';
        req.Account.PhonePrefix = '+39';
        req.Account.Phone = '0683052323';

        //IDENTITY SECTION
        req.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
        XC_UTIL_Account.IdentityIFWrapper idWr = new XC_UTIL_Account.IdentityIFWrapper();
        idWr.Country = 'Italy';
        idWr.IdentityType = 'CF';
        idWr.IdentityNumber = 'MROGNN80E01C662L';
        req.Identity.add(idWr);

        //CONTACT SECTION
        req.Contact = new List<XC_UTIL_Account.ContactIFWrapper>();
        XC_UTIL_Account.ContactIFWrapper contactWr = new XC_UTIL_Account.ContactIFWrapper();
        contactWr.LastName = 'MORI';
        contactWr.FirstName = 'GIOVANNI';
        contactWr.PrimaryContact = true;
        contactWr.Email = 'giovanni.mori@enel.com';
        contactWr.MainPhonePrefix = '+39';
        contactWr.MainPhone = '3485812402';
        contactWr.PhonePrefix = '+39';
        contactWr.Phone = '0683052323';
        contactWr.ShippingContact = true;
        contactWr.BillingContact = true;
        //GDPR AND LE
        contactWr.GDPR = new XC_UTIL_Account.gdprWrapper();
        contactWr.GDPR.LegalEntity = new List<XC_UTIL_Account.LegalEntityWrapper>();
        XC_UTIL_Account.LegalEntityWrapper leWr = new XC_UTIL_Account.LegalEntityWrapper();
        contactWr.GDPR.GiveDataToThirdParties = 'N';
        leWr.LegalEntity = 'EnelXItalia';
        leWr.GiveDataToLegalEntity = 'Y';
        leWr.GiveDataForMarketing = 'N';
        leWr.GiveDataForProfiling = 'N';
        contactWr.GDPR.LegalEntity.add(leWr);
        req.Contact.add(contactWr);

        //ORDER SECTION
        req.Order = new XC_UTIL_Order.OrderIFWrapper();
        req.Order.OrderItem = new List<XC_UTIL_Order.OrderItemWrapper>();
        req.Order.Document = new List<XC_UTIL_Order.DocumentWrapper>();

        req.Order.LegalEntity = 'EnelXItalia';
        req.Order.Channel = 'EnelEnergiaItalia';
        req.Order.OrderType = 'New';
        req.Order.IntegrationID = '12378128381823';

        

        //DOCUMENT
        XC_UTIL_Order.DocumentWrapper dwr = new XC_UTIL_Order.DocumentWrapper();
        dwr.ContractUrl = 'https://test.salesforce.com';
        req.Order.Document.add(dwr);

        //ORDER ITEM 
        XC_UTIL_Order.OrderItemWrapper oiWr = new XC_UTIL_Order.OrderItemWrapper();
        req.Order.OrderItem.add(oiWr);
        oiWr.ProdID = 'ECMAN24';
        oiWr.Quantity = 1;
        oiWr.BaseOneTimeFee = 0.0;
        oiWr.BaseRecurringCharge = 6.0;
        oiWr.ContractType = 'Gas';

        oiWr.Attribute = new List<XC_UTIL_Order.WrapperAttribute>();
        XC_UTIL_Order.WrapperAttribute attrWr1 = new XC_UTIL_Order.WrapperAttribute();
        attrWr1.Name = 'Payment details:Payment Method';
        attrWr1.Value = 'Monthly';
        attrWr1.ProductFamilyPropertyID = 'a1V1l000000PNaMEAW';

        oiWr.Attribute.add(attrWr1);
        req.Order.OrderItem.add(oiWr);

        //BILLING PROFILE SECTION
        req.BillingProfile = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
        XC_UTIL_BillingProfile.BillingProfileIFWrapper bpWr = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
        bpWr.LegalEntity = 'EnelXItalia';
        bpWr.PaymentMethod = 'Commodity Bill';
        bpWr.InvoicePreferredLanguage = 'Italian';
        bpWr.InvoiceDeliveryPref = 'Email';
        bpWr.CupsID = '00994599809123';
        bpWr.CommodityContractNum = '0039256378';
        bpWr.CommodityBP = '0039636921';
        bpWr.Email = 'giovanni.mori@enel.com';
        bpWr.RecipientCode = '0000000';
        req.BillingProfile.add(bpWr);        
        return req;
    }

    

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