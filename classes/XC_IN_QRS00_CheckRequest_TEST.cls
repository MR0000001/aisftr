/**
 * @author            : Elio Adami - elio.adami@accenture.com
 * @group             : ACN Team
 * @last modified on  : 18-12-2021
 * @last modified by  : Denise Avolio - denise.avolio@accenture.com
 * @description       : Test Class for XC_IN_QRS00_CheckRequest.cls
 * 
 * Ver   Date         Author                                        Modification
 * 1.0   10-19-2021   Elio Adami - elio.adami@accenture.com         Initial Version
 * 2.0   18-12-2021   Denise Avolio - denise.avolio@accenture.com   Modified to coverage the scenario of Disconnection
**/

@isTest
public with sharing class XC_IN_QRS00_CheckRequest_TEST {
    
    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;

        Account acc = new Account();

        acc.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();
        acc.PrimaryEmail__c = 'test_res' + (Math.random()*Math.random()) + '@email.com';
        acc.XC_DocumentCountry__c = 'Spain';
        acc.XC_CommercialCode__c='AAA123';
        acc.XC_InternalCommercialCode__c='BBB123';
        acc.Account_Type__c = 'Residential';
        acc.XC_UniqueId__c = 'd72face1-5088-4f16-9fd4-80a412a1ce6c';
        acc.XC_FirstName__c = 'GIOVANNI';
        acc.XC_LastName__c = 'MORI';
        acc.Name = 'MORI GIOVANNI';
        acc.XC_AccountPhonePrefix__c ='+39';
        acc.XC_MainPhonePrefix__c= '+39';
        acc.MainPhone__c = '3485812402';
        acc.PrimaryEmail__c = 'giovanni.mori@enel.com';
        acc.Phone = '3485812402';
        acc.IdentityNumber__c='3526173'+ (Math.random()*Math.random());
        acc.IdentityType__c= 'Passport';
        acc.XC_AccountMainPhone__c='3485812402';
        acc.XC_AccountPhone__c='3485812402';
        
        insert acc;
        
        XC_UTIL_QueuedRequest_W.WrapperRequest wr = generateRequestBody();
        //wr.Order.VASContractExtID='Test1234567'; //[DeAv 18/12/2021 Modified to coverage the scenario of Disconnection]
        wr.Account.Phone='3485812402';
        wr.Account.IdentityNumber=acc.IdentityNumber__c;

        XC_QueuedRequest__c qr = new XC_QueuedRequest__c();
        qr.XC_IntegrationId__c = 'Test1234';
        qr.XC_ClientSystem__c = 'ThirdPartyB2C';
        qr.XC_TransactionId__c = XC_UTIL_UUID.newGuid();
        qr.XC_RequestBody__c = JSON.serialize(wr);
        insert qr;

        XC_QueuedRequestStep__c qrs = new XC_QueuedRequestStep__c();
        qrs.XC_QueuedRequest__c  = qr.id;
        qrs.XC_StepLabel__c = 'Check Request';
        insert qrs;

        //[DeAv 10/01/2022 TPB Check Billing Model THIRDPARTY-1165 START]
        NE__Family__c fam = new NE__Family__c();
        fam.XC_LIC_Family_Name__c = 'Payment Details';
        insert fam;
        NE__DynamicPropertyDefinition__c dpd = new NE__DynamicPropertyDefinition__c();
        dpd.XC_LIC_DynamicPropertyDefinition__c = 'Payment model';
        insert dpd;
        NE__ProductFamilyProperty__c pfp = new NE__ProductFamilyProperty__c();
        pfp.NE__FamilyId__c = fam.Id;
        pfp.NE__PropId__c = dpd.Id;
        insert pfp;
        NE__PropertyDomain__c pd = new NE__PropertyDomain__c();
        pd.Name = 'Monthly';
        pd.NE__PropId__c = dpd.Id;
        insert pd;
        //[DeAv 10/01/2022 TPB Check Billing Model THIRDPARTY-1165 END]
    }

    @isTest
    static void testCheckRequestOne(){

        Asset asst = new Asset();
        asst.Name = 'TestAsset';
        asst.AccountId = [select id from account][0].id;
        asst.XC_VASContractExtID__c = 'Test1234567';
        asst.XC_Segment__c = 'B2C';
		asst.XC_LegalEntity__c = 'EnelX';
        insert asst;

        XC_QueuedRequestStep__c qrs = [SELECT ID FROM XC_QueuedRequestStep__c LIMIT 1];
        XC_IN_QRS00_CheckRequest.InputWrapper iw = new XC_IN_QRS00_CheckRequest.InputWrapper();
        iw.stepId = qrs.Id;
        
        Test.startTest();
        XC_IN_QRS00_CheckRequest.manageCheckRequest(new List<XC_IN_QRS00_CheckRequest.InputWrapper>{iw});
        Test.stopTest();
    }

    @isTest
    static void testCheckRequestTwo(){

        //[DeAv 18/12/2021 Modified to coverage the scenario of Disconnection START]
        XC_CS001_InterfaceConfiguration__c interfaceConf = new XC_CS001_InterfaceConfiguration__c();
        interfaceConf.XC_activeInterface__c = true;
        interfaceConf.XC_URL_Required__c = 'test';
        interfaceConf.Name = Label.XC_CL_ContractAccountValidation;
        interfaceConf.XC_interfaceName__c = Label.XC_CL_ContractAccountValidation;
        interfaceConf.XC_ServerSystem__c = 'CommodityChile';
        interfaceConf.XC_Country__c = 'Chile';
        insert interfaceConf;
        //[DeAv 18/12/2021 Modified to coverage the scenario of Disconnection END]

        XC_QueuedRequestStep__c qrs = [SELECT ID FROM XC_QueuedRequestStep__c LIMIT 1];
        XC_IN_QRS00_CheckRequest.InputWrapper iw = new XC_IN_QRS00_CheckRequest.InputWrapper();
        iw.stepId = qrs.Id;
        
        Test.startTest();
        XC_IN_QRS00_CheckRequest.executeCheckRequest(new List<XC_IN_QRS00_CheckRequest.InputWrapper>{iw});
        Test.stopTest();
    }

    //[DeAv 18/12/2021 Modified to coverage the scenario of Disconnection START]
    @isTest
    static void testCheckRequestThree(){

        XC_CS001_InterfaceConfiguration__c interfaceConf = new XC_CS001_InterfaceConfiguration__c();
        interfaceConf.XC_activeInterface__c = false;
        interfaceConf.XC_URL_Required__c = 'test';
        interfaceConf.Name = Label.XC_CL_ContractAccountValidation;
        interfaceConf.XC_interfaceName__c = Label.XC_CL_ContractAccountValidation;
        interfaceConf.XC_ServerSystem__c = 'CommodityChile';
        interfaceConf.XC_Country__c = 'Chile';
        insert interfaceConf;

        XC_QueuedRequestStep__c qrs = [SELECT ID FROM XC_QueuedRequestStep__c LIMIT 1];
        XC_IN_QRS00_CheckRequest.InputWrapper iw = new XC_IN_QRS00_CheckRequest.InputWrapper();
        iw.stepId = qrs.Id;
        
        Test.startTest();
        XC_IN_QRS00_CheckRequest.manageCheckRequest(new List<XC_IN_QRS00_CheckRequest.InputWrapper>{iw});
        Test.stopTest();
    }

    @isTest
    static void testCheckRequestDisconnectionOne(){

        XC_CS001_InterfaceConfiguration__c interfaceConf = new XC_CS001_InterfaceConfiguration__c();
        interfaceConf.XC_activeInterface__c = true;
        interfaceConf.XC_URL_Required__c = 'test';
        interfaceConf.Name = Label.XC_CL_ContractAccountValidation;
        interfaceConf.XC_interfaceName__c = Label.XC_CL_ContractAccountValidation;
        interfaceConf.XC_ServerSystem__c = 'CommodityChile';
        interfaceConf.XC_Country__c = 'Chile';
        insert interfaceConf;

        XC_UTIL_QueuedRequest_W.WrapperRequest wrQR = generateRequestBody();
        wrQR.Order.OrderType = 'Disconnection';
        
        XC_QueuedRequest__c qr = [SELECT Id, XC_RequestBody__c FROM XC_QueuedRequest__c LIMIT 1];
        qr.XC_RequestBody__c = JSON.serialize(wrQR);
        update qr;

        XC_QueuedRequestStep__c qrs = [SELECT ID FROM XC_QueuedRequestStep__c LIMIT 1];
        XC_IN_QRS00_CheckRequest.InputWrapper iw = new XC_IN_QRS00_CheckRequest.InputWrapper();
        iw.stepId = qrs.Id;
        
        Test.startTest();
        XC_IN_QRS00_CheckRequest.executeCheckRequest(new List<XC_IN_QRS00_CheckRequest.InputWrapper>{iw});
        Test.stopTest();
    }

    @isTest
    static void testCheckRequestChangeOrderOne(){

        User user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId() LIMIT 1];
        user.XC_EnabledToSkip__c = true;
        update user;
       
        System.runAs(user){

            XC_CS001_InterfaceConfiguration__c interfaceConf = new XC_CS001_InterfaceConfiguration__c();
            interfaceConf.XC_activeInterface__c = true;
            interfaceConf.XC_URL_Required__c = 'test';
            interfaceConf.Name = Label.XC_CL_ContractAccountValidation;
            interfaceConf.XC_interfaceName__c = Label.XC_CL_ContractAccountValidation;
            interfaceConf.XC_ServerSystem__c = 'CommodityChile';
            interfaceConf.XC_Country__c = 'Chile';
            insert interfaceConf;

            XC_UTIL_QueuedRequest_W.WrapperRequest wrQR = generateRequestBody();
            wrQR.Order.OrderType = 'Change Order';
            wrQR.Order.OrderSubType = 'Promocode Application';
            wrQR.Order.LegalEntity = 'EnelX';
            List<Account> accList = [SELECT Id, IdentityNumber__c, XC_DocumentCountry__c FROM Account LIMIT 1];
            accList.get(0).IdentityNumber__c = wrQR.Identity.get(0).IdentityNumber;
            accList.get(0).XC_DocumentCountry__c = 'Chile';
            update accList;

            Individual ind = new Individual();
            ind.LastName = 'Test';
            ind.XC_Status__c = 'Active';
            ind.XC_GDPRThirdPartiesRelated__c = true;
            insert ind;

            List<Contact> con = XC_DF_Contact.createResidentialContacts(accList);
            con.get(0).IndividualId = ind.Id;
            con.get(0).XC_CountryLegalEntity__c = 'Chile';
            con.get(0).XC_MainLegalEntity__c = 'EnelX';
            insert con;
            system.debug('@@@ Test class con.get(0).IndividualId: ' + con.get(0).IndividualId);

            NE__Order__c ord = XC_DF_Order.createOrder('InOrder');
            ord.XC_Status__c = 'Closed';
            ord.NE__AccountId__c = accList.get(0).Id;
            ord.XC_LegalEntity__c = 'EnelX';

            NE__OrderItem__c ordItem = [SELECT Id, NE__Account__c, NE__CatalogItem__c FROM NE__OrderItem__c LIMIT 1];
            ordItem.NE__Account__c = accList.get(0).Id;            

            Opportunity opt = [SELECT Id, AccountId, XC_Contact__c, XC_Address__c FROM Opportunity WHERE Id =: ord.NE__OptyId__c];
            opt.AccountId = accList.get(0).Id;
            opt.XC_Contact__c = con.get(0).Id;

            XC_Address__c addr = [SELECT Id, XC_Account__c FROM XC_Address__c LIMIT 1];
            addr.XC_Account__c = accList.get(0).Id;

            NE__Catalog_Item__c ci = [SELECT Id, NE__UsageCode__c FROM NE__Catalog_Item__c WHERE Id =: ordItem.NE__CatalogItem__c LIMIT 1];
            ci.NE__UsageCode__c = wrQR.Order.OrderItem.get(0).ProdID;
            
            update ci;
            update addr;
            update opt;
            update ord;
            update ordItem;

            List<NE__Billing_Profile__c> bp = XC_DF_BillingProfile.createBillingProfile(1, accList);
            XC_BillingProfileLineItem__c bpli = [SELECT id FROM XC_BillingProfileLineItem__c LIMIT 1];

            bp.get(0).XC_CommodityCupsID__c = '00994599809123';
            update bp;

            Asset ass = new Asset();
            ass.Name = 'TestAsset';
            ass.AccountId = accList.get(0).id;
            ass.XC_VASContractExtID__c = 'Test1234567';
            ass.XC_Segment__c = 'B2C';
            ass.XC_LegalEntity__c = 'EnelX';
            ass.Status = 'Active';
            ass.NE__Order_Config__c = ord.Id;
            ass.ContactId = con.get(0).Id;
            ass.XC_BillingProfileLineItem__c = bpli.id;
            ass.XC_BillingModel__c = 'Recurring';
            ass.NE__CatalogItem__c = ordItem.NE__CatalogItem__c;
            insert ass;

            List<Asset> assetList = new List<Asset>();
            assetList.add(ass);

            List<String> listAttributes = new List<String>{'Number of quotas'};

            List<NE__AssetItemAttribute__c> aia = XC_DF_Asset.createAssetItemAttributes(assetList, listAttributes);
            aia.get(0).NE__Value__c = '99';
            insert aia;

            XC_LegalEntityConsent__c lec = new XC_LegalEntityConsent__c();
            lec.XC_LeCountry__c = 'Chile';
            lec.XC_LegalEntity__c = ass.XC_LegalEntity__c;
            lec.XC_GiveDataToNew__c = 'Yes';
            lec.XC_Individual__c = ind.Id;
            insert lec;

            //Test.startTest();
            //XC_IN_QRS00_CheckRequest.checkDisconnectInfo(wrQR);
            //Test.stopTest();
            Test.startTest();
            XC_QueuedRequest__c qr = [SELECT Id, XC_RequestBody__c FROM XC_QueuedRequest__c LIMIT 1];
            qr.XC_RequestBody__c = JSON.serialize(wrQR);
            update qr;

            XC_QueuedRequestStep__c qrs = [SELECT ID FROM XC_QueuedRequestStep__c LIMIT 1];
            XC_IN_QRS00_CheckRequest.InputWrapper iw = new XC_IN_QRS00_CheckRequest.InputWrapper();
            iw.stepId = qrs.Id;
            
            XC_IN_QRS00_CheckRequest.executeCheckRequest(new List<XC_IN_QRS00_CheckRequest.InputWrapper>{iw});
            Test.stopTest();
        }
    }
    //[DeAv 18/12/2021 Modified to coverage the scenario of Disconnection END]


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
        req.Account.Country ='Chile'; //[DeAv 18/12/2021 Modified to coverage the scenario of Disconnection]

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
        req.Order.VASContractExtID='Test1234567'; //[DeAv 18/12/2021 Modified to coverage the scenario of Disconnection]

        

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

        //[DeAv 18/12/2021 Modified to coverage the scenario of Disconnection START]
        XC_UTIL_Order.WrapperAttribute attrWr2 = new XC_UTIL_Order.WrapperAttribute();
        attrWr2.Name = 'Number of quotas';
        attrWr2.Value = '98';
        oiWr.Attribute.add(attrWr2);
        //[DeAv 18/12/2021 Modified to coverage the scenario of Disconnection END]

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

        //[DeAv 18/12/2021 Modified to coverage the scenario of Disconnection START]

        //ADDRESS SECTION
        req.Address = new List<XC_UTIL_Address.AddressWrapper>();
        XC_UTIL_Address.AddressWrapper singleAddress = new XC_UTIL_Address.AddressWrapper();

        //POS SECTION
        singleAddress.PointOfService = new List<XC_UTIL_Address.PoSWrapper>();
        XC_UTIL_Address.PoSWrapper singlePos = new XC_UTIL_Address.PoSWrapper();
        singlePos.POSType = 'Light';
        singlePos.POS = '2584967-1';
        singleAddress.PointOfService.add(singlePos);
        req.Address.add(singleAddress);
        //[DeAv 18/12/2021 Modified to coverage the scenario of Disconnection END]

        return req;
    }

}