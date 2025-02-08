/**
 * @author            : Andrea Di Cicco
 * @date Creation     : 18/03/2020
 * @date Modification : dd/mm/yyyy
 * @description       : Test Class for XC_REST_Account_B_TEST 
 **/

@isTest
public class XC_REST_Account_B_TEST {
	@isTest
    static void populateWrapperInfo(){
        
        XC_UTIL_BillingProfile.BillingProfileIFWrapper billingProfile = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
        billingProfile.BillingProfileID ='test';
        billingProfile.BillingMedia ='test';
        billingProfile.BillingProfileName ='test';
        billingProfile.Payment ='test';
        billingProfile.CurrencyName ='test';
        billingProfile.CardType ='test';
        billingProfile.ExpirationMonth ='test';
        billingProfile.ExpirationYear ='test';
        billingProfile.SecurityCode ='test';
        billingProfile.FirstName ='test';
        billingProfile.LastName ='test';
        billingProfile.MailTo ='test';
        billingProfile.InvoicePreferredLanguage='Chinese';
        Map<String,Object> mapInfos = new Map<String,Object> ();
        mapInfos.put('accountId','test');
        mapInfos.put('clientSystem', 'CommodityItalyB2C');//[TP-20211011-TPB]
        
        Test.startTest();
        XC_REST_Account_B.populateWrapperInfo( billingProfile,  mapInfos);
        Test.stopTest();
    }

    @isTest
    static void checkAddressToAssociate1(){
        Map<String,String> mapInfos = new Map<String,String> ();
        mapInfos.put('accountId','test');
        XC_REST_Account_W.WrapperResponse wrResp = new  XC_REST_Account_W.WrapperResponse();

        Test.startTest();
        XC_REST_Account_B.checkAddressToAssociate(mapInfos, wrResp);
        Test.stopTest();
    }
    @isTest
    static void checkAddressToAssociate2(){
        Map<String,String> mapInfos = new Map<String,String> ();
        mapInfos.put('billId','test');
        XC_REST_Account_W.WrapperResponse wrResp = new  XC_REST_Account_W.WrapperResponse();

        Test.startTest();
        XC_REST_Account_B.checkAddressToAssociate(mapInfos, wrResp);
        Test.stopTest();
    }
    
    @isTest
    static void checkBillingProfile(){
        
        List<NE__Billing_Profile__c> billingProf =  XC_DF_BillingProfile.createBillingProfile(1);
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> billingProfileList = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
        XC_UTIL_BillingProfile.BillingProfileIFWrapper billingProfile = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
        billingProfile.BillingProfileID =String.valueOf(billingProf.get(0).id);
        billingProfile.BillingMedia ='test';
        billingProfile.BillingProfileName ='test';
        billingProfile.Payment ='test';
        billingProfile.CurrencyName ='test';
        billingProfile.CardType ='test';
        billingProfile.ExpirationMonth ='test';
        billingProfile.ExpirationYear ='test';
        billingProfile.SecurityCode ='test';
        billingProfile.FirstName ='test';
        billingProfile.LastName ='test';
        billingProfile.MailTo ='test';
        billingProfile.InvoicePreferredLanguage='Chinese';
        billingProfileList.add(billingProfile);
        Map<String,String> mapInfos = new Map<String,String> ();
        mapInfos.put('accountId','test');
        XC_REST_Account_W.WrapperResponse wrResp = new  XC_REST_Account_W.WrapperResponse();
        
        Test.startTest();
        XC_REST_Account_B.checkBillingProfile(billingProfileList, mapInfos, wrResp);
        Test.stopTest();
    }
    
    @isTest
    static void checkMandatoryCCValues(){
        Map<String,Object> paymentMethod = new Map<String,Object>();
        paymentMethod.put('TokenId', 'test');
        paymentMethod.put('test', 'test');
		
        Test.startTest();
        XC_REST_Account_B.checkMandatoryCCValues(paymentMethod);
        Test.stopTest();
    }
    
    @isTest
    static void manageBpli(){
        
        List<NE__Billing_Profile__c> billingProfile = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfile[0].NE__Payment__c = 'Vale Vista';
        update billingProfile;
        
        XC_BillingProfileLineItem__c bpli = [SELECT id from XC_BillingProfileLineItem__c LIMIT 1];
        //bpli.XC_PaymentMethod__c = 'Vale Vista';
        update bpli;
        
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        oi[0].XC_BillingProfileLineItem__c = bpli.id;
        oi[0].XC_BillingModel__c   = 'One Shot';
        oi[0].XC_PaymentMethod__c = 'Vale Vista';
        insert oi;
        Map<String,Object> mapUtilBp = new Map<String,Object>();
        
        Map<Id, NE__Billing_Profile__c> mapBp = new Map<Id, NE__Billing_Profile__c>();
        mapBp.put(billingProfile[0].id, [SELECT Id, (SELECT id, XC_BillToAddress__c, XC_SoldToAddress__c, XC_LegalEntity__c,XC_TPBCode__c FROM 	Billing_Profile_Line_Items__r  ) 
                                                                                                 FROM NE__Billing_Profile__c  
                                                                                                 LIMIT 1]);
        
        Map<String, String> mapInfos = new Map<String, String>();
        mapInfos.put('soldId', String.valueOf( [Select id from XC_Address__c LIMIT 1].id));
        mapInfos.put('billId', String.valueOf( [Select id from XC_Address__c LIMIT 1].id));

        List<Account>  accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> conList = new List<Contact>();
        Contact contsoldTo = new Contact(FirstName = 'contsoldToName' ,LastName = 'contsoldToName', AccountId = accountList[0].Id, XC_GiveDataToNew__c = 'Yes', XC_CountryLegalEntity__c = 'Italy', XC_MainLegalEntity__c = 'EnelXItalia', Email = 'contsoldTo@test.it');
         insert contsoldTo;
         conList.add(contsoldTo);
		mapInfos.put('account', JSON.serialize(accountList[0] ));
        
        mapUtilBp.put( 'mapBp', mapBp);
        mapUtilBp.put('mapInfos', mapInfos);
        
        mapUtilBp.put('billProfListToInsert',billingProfile);
       /* mapUtilBp.put('billProfListToInsert', [SELECT Id, (SELECT id, XC_BillToAddress__c, XC_SoldToAddress__c, XC_LegalEntity__c FROM 	Billing_Profile_Line_Items__r  ) 
                                                                                                 FROM NE__Billing_Profile__c  
                                                                                                 LIMIT 1000] );*/
       
        Map<Id, Map<String,String>>  billingProfMapLe = new Map<Id, Map<String,String>>();
        Map<String,String> addressMap = new Map<String,String>();
        addressMap.put('soldAddressId','');
        addressMap.put('billingAddressId','');
        billingProfMapLe.put(billingProfile[0].id,addressMap );
        mapUtilBp.put('billingProfMapLe', billingProfMapLe);
        XC_REST_Account_W.WrapperResponse wrRes = new XC_REST_Account_W.WrapperResponse();
        
        Test.startTest();
        XC_REST_Account_B.manageBpli(mapUtilBp, wrRes);
        Test.stopTest();
    }
    
        @isTest
    static void manageBpli2(){
        
        List<NE__Billing_Profile__c> billingProfile = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfile[0].NE__Payment__c = 'Vale Vista';
        update billingProfile;
        
        XC_BillingProfileLineItem__c bpli = [SELECT id from XC_BillingProfileLineItem__c LIMIT 1];
        //bpli.XC_PaymentMethod__c = 'Vale Vista';
        update bpli;
        
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        oi[0].XC_BillingProfileLineItem__c = bpli.id;
        oi[0].XC_BillingModel__c   = 'One Shot';
        oi[0].XC_PaymentMethod__c = 'Vale Vista';
        insert oi;
        Map<String,Object> mapUtilBp = new Map<String,Object>();
        
        Map<Id, NE__Billing_Profile__c> mapBp = new Map<Id, NE__Billing_Profile__c>();
        mapBp.put(billingProfile[0].id, [SELECT Id,XC_InvoiceDeliveryPref__c,XC_InvoicePreferredLanguage__c, (SELECT id, Name, XC_BillToAddress__c, XC_BillToContactId__c, XC_SoldToContactId__c, XC_SoldToAddress__c, XC_LegalEntity__c,XC_TPBCode__c FROM 	Billing_Profile_Line_Items__r  ) 
                                                                                                 FROM NE__Billing_Profile__c  
                                                                                                 LIMIT 1]);
        
        Map<String, String> mapInfos = new Map<String, String>();
        mapInfos.put('soldId', String.valueOf( [Select id from XC_Address__c LIMIT 1].id));
        mapInfos.put('billId', String.valueOf( [Select id from XC_Address__c LIMIT 1].id));
        List<Account>  accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> conList = new List<Contact>();
        Contact contsoldTo = new Contact(FirstName = 'contsoldToName' ,LastName = 'contsoldToName', AccountId = accountList[0].Id, XC_GiveDataToNew__c = 'Yes', XC_CountryLegalEntity__c = 'Italy', XC_MainLegalEntity__c = 'EnelXItalia', Email = 'contsoldTo@test.it');
         insert contsoldTo;
         conList.add(contsoldTo);
		mapInfos.put('account', JSON.serialize(accountList[0] ));
        mapUtilBp.put( 'mapBp', mapBp);
        mapUtilBp.put('mapInfos', mapInfos);
        
        mapUtilBp.put('billProfListToInsert',billingProfile);
       /* mapUtilBp.put('billProfListToInsert', [SELECT Id,Name, (SELECT id, Name, XC_BillToAddress__c,XC_BillToContactId__c, XC_SoldToAddress__c, XC_SoldToContactId__c,  XC_LegalEntity__c FROM 	Billing_Profile_Line_Items__r  ) 
                                                                                                 FROM NE__Billing_Profile__c  
                                                                                                 LIMIT 1000] );*/
       
        Map<Id, Map<String,String>>  billingProfMapLe = new Map<Id, Map<String,String>>();
        Map<String,String> addressMap = new Map<String,String>();
        addressMap.put('soldAddressId','');
        addressMap.put('billingAddressId','');
        addressMap.put('legalEntity','EndesaX');
        billingProfMapLe.put(billingProfile[0].id,addressMap );
        mapUtilBp.put('billingProfMapLe', billingProfMapLe);
        XC_REST_Account_W.WrapperResponse wrRes = new XC_REST_Account_W.WrapperResponse();
        
        Test.startTest();
        XC_REST_Account_B.manageBpli(mapUtilBp, wrRes);
        Test.stopTest();
    }
            @isTest
    static void manageBpli3(){
        
        List<NE__Billing_Profile__c> billingProfile = XC_DF_BillingProfile.createBillingProfile(2);
        billingProfile[0].NE__Payment__c = 'Vale Vista';
        update billingProfile;
        
        XC_BillingProfileLineItem__c bpli = [SELECT id, XC_LegalEntity__c from XC_BillingProfileLineItem__c LIMIT 1];
        //bpli.XC_PaymentMethod__c = 'Vale Vista';
      	bpli.XC_LegalEntity__c = 'EndesaX';
        bpli.XC_BillingProfile__c = billingProfile[0].id;  
        update bpli;
        
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        oi[0].XC_BillingProfileLineItem__c = bpli.id;
        oi[0].XC_BillingModel__c   = 'One Shot';
        oi[0].XC_PaymentMethod__c = 'Vale Vista';
        insert oi;
        Map<String,Object> mapUtilBp = new Map<String,Object>();
        
        Map<Id, NE__Billing_Profile__c> mapBp = new Map<Id, NE__Billing_Profile__c>();
        mapBp.put(billingProfile[0].id, [SELECT Id, XC_InvoicePreferredLanguage__c,XC_InvoiceDeliveryPref__c,(SELECT id, Name, XC_BillToAddress__c, XC_Status__c, XC_BillToContactId__c, XC_SoldToContactId__c, XC_SoldToAddress__c, XC_LegalEntity__c,XC_TPBCode__c FROM 	Billing_Profile_Line_Items__r  ) 
                                                                                                 FROM NE__Billing_Profile__c  Where ID = : billingProfile[0].id
                                                                                                 LIMIT 1]);
        
        Map<String, String> mapInfos = new Map<String, String>();
        mapInfos.put('soldId', String.valueOf( [Select id from XC_Address__c LIMIT 1].id));
        mapInfos.put('billId', String.valueOf( [Select id from XC_Address__c LIMIT 1].id));
		mapInfos.put('account', JSON.serialize( new Account(IdentityType__c='CF',IdentityNumber__c='CRLPLA80A01H501H',XC_DocumentCountry__c='Italy' )));//[TP-20211011-TPB]
        
        mapUtilBp.put( 'mapBp', mapBp);
        mapUtilBp.put('mapInfos', mapInfos);
        mapUtilBp.put('billProfListToInsert',billingProfile);
       
       // mapUtilBp.put('billProfListToInsert', [SELECT Id,Name, (SELECT id, Name, XC_Status__c,  XC_BillToAddress__c,XC_BillToContactId__c, XC_SoldToAddress__c, XC_SoldToContactId__c,  XC_LegalEntity__c FROM 	Billing_Profile_Line_Items__r  ) 
                                                                                              //   FROM NE__Billing_Profile__c  
                                                                                              //   Where ID = : billingProfile[0].id] );//[TP-20211011-TPB]
       
        Map<Id, Map<String,String>>  billingProfMapLe = new Map<Id, Map<String,String>>();
        Map<String,String> addressMap = new Map<String,String>();
        List<XC_Address__c> addList = XC_DF_Address.createAddress(1);
        insert addList;
        addressMap.put('soldAddressId', String.valueOf(addList[0].id));
        addressMap.put('billingAddressId','');
        addressMap.put('legalEntity','EndesaX');
        billingProfMapLe.put(billingProfile[0].id,addressMap );
        mapUtilBp.put('billingProfMapLe', billingProfMapLe);
        XC_REST_Account_W.WrapperResponse wrRes = new XC_REST_Account_W.WrapperResponse();
        
        Map<NE__Billing_Profile__c, XC_UTIL_BillingProfile.BillingProfileIFWrapper> reverseBpMap = new Map<NE__Billing_Profile__c, XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
       XC_UTIL_BillingProfile.BillingProfileIFWrapper billingProfileIFW = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
        billingProfileIFW.BillingProfileID =billingProfile[0].id;
        billingProfileIFW.BillingMedia ='test';
        billingProfileIFW.BillingProfileName ='test';
        billingProfileIFW.Payment ='test';
        billingProfileIFW.CurrencyName ='test';
        billingProfileIFW.CardType ='test';
        billingProfileIFW.ExpirationMonth ='test';
        billingProfileIFW.ExpirationYear ='test';
        billingProfileIFW.SecurityCode ='test';
        billingProfileIFW.FirstName ='test';
        billingProfileIFW.LastName ='test';
        billingProfileIFW.MailTo ='test';
        billingProfileIFW.InvoicePreferredLanguage='Chinese';
        reverseBpMap.put( billingProfile[1], billingProfileIFW);
        mapUtilBp.put('reverseBpMap', reverseBpMap);
        Test.startTest();
        XC_REST_Account_B.manageBpli(mapUtilBp, wrRes);
        Test.stopTest();
    }
    @isTest
    static void insertUpdateBillingProfile1(){
        XC_UTIL_BillingProfile.BillingProfileIFWrapper billingProfile = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
        List<NE__Billing_Profile__c> billProfileList = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfile.BillingProfileID =billProfileList[0].id;
        billingProfile.BillingMedia ='test';
        billingProfile.BillingProfileName ='test';
        billingProfile.Payment ='test';
        billingProfile.CurrencyName ='test';
        billingProfile.CardType ='test';
        billingProfile.ExpirationMonth ='test';
        billingProfile.ExpirationYear ='test';
        billingProfile.SecurityCode ='test';
        billingProfile.FirstName ='test';
        billingProfile.LastName ='test';
        billingProfile.MailTo ='test';
        billingProfile.InvoicePreferredLanguage='Chinese';
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> billingProfileList = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
        billingProfileList.add(billingProfile);
        
        Map<String,String> mapInfo = new Map<String,String>();
        mapInfo.put('country', 'Spain');
        mapInfo.put('account', String.valueOf([Select id from Account Limit 1].id));
        List<XC_Address__c> address = XC_DF_Address.createAddress(1);
        insert address;
        mapInfo.put('billId', String.valueOf(address[0].id));
        mapInfo.put('soldId', String.valueOf(address[0].id));
        mapInfo.put('clientSystem', 'CommodityItalyB2C');//[TP-20211011-TPB]
        XC_REST_Account_W.WrapperResponse wrResp = new XC_REST_Account_W.WrapperResponse();
        
        Test.startTest();
        	XC_REST_Account_B.insertUpdateBillingProfile(billingProfileList, mapInfo, wrResp, true  );
        Test.stopTest();
    }
    
        @isTest
    static void insertUpdateBillingProfile2(){
        XC_UTIL_BillingProfile.BillingProfileIFWrapper billingProfile = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
        List<NE__Billing_Profile__c> billProfileList = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfile.BillingProfileID =billProfileList[0].id;
        //billingProfile.BillingMedia ='test';
        billingProfile.BillingProfileName ='Vale Vista';
        billingProfile.Payment ='Vale Vista';
        billingProfile.CurrencyName ='EUR';
        //billingProfile.CardType ='';
        billingProfile.ExpirationMonth ='12';
        billingProfile.ExpirationYear ='12';
        //billingProfile.SecurityCode ='test';
        billingProfile.FirstName ='test';
        billingProfile.LastName ='test';
        billingProfile.MailTo ='atest@test.it';
        billingProfile.InvoicePreferredLanguage='Spanish';
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> billingProfileList = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
        billingProfileList.add(billingProfile);
        
        Map<String,String> mapInfo = new Map<String,String>();
        mapInfo.put('country', 'Spain');
        mapInfo.put('accountId', String.valueOf([Select id from Account Limit 1].id));
        List<XC_Address__c> address = XC_DF_Address.createAddress(1);
        insert address;
        mapInfo.put('billId', String.valueOf(address[0].id));
        mapInfo.put('soldId', String.valueOf(address[0].id));
        mapInfo.put('clientSystem', 'CommodityItalyB2C');
        mapInfo.put('account', JSON.serialize( new Account(IdentityType__c='CF',IdentityNumber__c='CRLPLA80A01H501H',XC_DocumentCountry__c='Italy' )));

        XC_REST_Account_W.WrapperResponse wrResp = new XC_REST_Account_W.WrapperResponse();
        
        Test.startTest();
        	XC_REST_Account_B.insertUpdateBillingProfile(billingProfileList, mapInfo, wrResp, false  );
        Test.stopTest();
    }
    
    @isTest
    static void prepareBPinfoForZuora1(){
        List<NE__Billing_Profile__c> billingProfile = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfile[0].NE__Payment__c = 'Vale Vista';
        update billingProfile;
        
        XC_BillingProfileLineItem__c bpli = [SELECT id from XC_BillingProfileLineItem__c LIMIT 1];
        //bpli.XC_PaymentMethod__c = 'Vale Vista';
        update bpli;
        
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        oi[0].XC_BillingProfileLineItem__c = bpli.id;
        oi[0].XC_BillingModel__c   = 'One Shot';
        oi[0].XC_PaymentMethod__c = 'Vale Vista';
        insert oi;
        Map<String,Object> mapUtilBp = new Map<String,Object>();
        
        Map<Id, NE__Billing_Profile__c> mapBp = new Map<Id, NE__Billing_Profile__c>();
        mapBp.put(billingProfile[0].id, [SELECT Id, XC_InvoiceDeliveryPref__c, XC_InvoicePreferredLanguage__c, NE__Payment__c,XC_Token__c, NE__Card_Number__c, NE__Card_Type__c, XC_SepaMandate__c, XC_SepaMandateDate__c,XC_CommodityContractID__c, (SELECT id, XC_BillToAddress__c, XC_SoldToAddress__c, XC_LegalEntity__c,XC_TPBCode__c FROM 	Billing_Profile_Line_Items__r  ) 
                                                                                                 FROM NE__Billing_Profile__c  
                                                                                                 LIMIT 1]);//[TP-20211011-TPB]
        
        Map<String, String> mapInfos = new Map<String, String>();
        mapInfos.put('soldId', String.valueOf( [Select id from XC_Address__c LIMIT 1].id));
        mapInfos.put('billId', String.valueOf( [Select id from XC_Address__c LIMIT 1].id));

        mapUtilBp.put( 'mapBp', mapBp);
        mapUtilBp.put('mapInfos', mapInfos);
        mapUtilBp.put('billProfListToInsert', [SELECT Id, XC_InvoiceDeliveryPref__c,NE__Payment__c,XC_Token__c, NE__Card_Number__c, NE__Card_Type__c, XC_SepaMandate__c, XC_SepaMandateDate__c,XC_CommodityContractID__c, (SELECT id, XC_BillToAddress__c, XC_SoldToAddress__c, XC_LegalEntity__c FROM 	Billing_Profile_Line_Items__r  ) 
                                                                                                 FROM NE__Billing_Profile__c  
                                                                                                 LIMIT 1000] );
       
        Map<Id, Map<String,String>>  billingProfMapLe = new Map<Id, Map<String,String>>();
        Map<String,String> addressMap = new Map<String,String>();
        addressMap.put('soldAddressId','');
        addressMap.put('billingAddressId','');
        billingProfMapLe.put(billingProfile[0].id,addressMap );
        mapUtilBp.put('billingProfMapLe', billingProfMapLe);
        XC_BillingProfileLineItem__c bpliRetrieved = [Select XC_BillingProfile__c, id from XC_BillingProfileLineItem__c LIMIT 1];
        mapUtilBp.put('billingProfInserted', bpliRetrieved );
        
        XC_UTIL_BillingProfile.BillingProfileIFWrapper billingProfileIFWrapper = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
        List<NE__Billing_Profile__c> billProfileList = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfileIFWrapper.BillingProfileID =billProfileList[0].id;
        billingProfileIFWrapper.BillingMedia ='test';
        billingProfileIFWrapper.BillingProfileName ='test';
        billingProfileIFWrapper.Payment ='test';
        billingProfileIFWrapper.CurrencyName ='test';
        billingProfileIFWrapper.CardType ='test';
        billingProfileIFWrapper.ExpirationMonth ='test';
        billingProfileIFWrapper.ExpirationYear ='test';
        billingProfileIFWrapper.SecurityCode ='test';
        billingProfileIFWrapper.FirstName ='test';
        billingProfileIFWrapper.LastName ='test';
        billingProfileIFWrapper.MailTo ='test';
        billingProfileIFWrapper.InvoicePreferredLanguage='Chinese';
        Map<Id, XC_UTIL_BillingProfile.BillingProfileIFWrapper> bpliMap = new Map<Id, XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
        bpliMap.put(billProfileList[0].id, billingProfileIFWrapper );
        mapUtilBp.put('mapBPwr',bpliMap);
        
        Test.startTest();
        XC_REST_Account_B.prepareBPinfoForZuora(mapUtilBp);
        Test.stopTest();
    }
	
	@isTest
    static void manageBillingProfile(){
                List<NE__Billing_Profile__c> billingProfile = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfile[0].NE__Payment__c = 'Vale Vista';
        update billingProfile;
        
        XC_BillingProfileLineItem__c bpli = [SELECT id from XC_BillingProfileLineItem__c LIMIT 1];
        //bpli.XC_PaymentMethod__c = 'Vale Vista';
        update bpli;
        
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        oi[0].XC_BillingProfileLineItem__c = bpli.id;
        oi[0].XC_BillingModel__c   = 'One Shot';
        oi[0].XC_PaymentMethod__c = 'Vale Vista';
        insert oi;
        Map<String,Object> mapUtilBp = new Map<String,Object>();
        
        Map<Id, NE__Billing_Profile__c> mapBp = new Map<Id, NE__Billing_Profile__c>();
        mapBp.put(billingProfile[0].id, [SELECT Id, XC_InvoiceDeliveryPref__c, XC_InvoicePreferredLanguage__c, NE__Payment__c,XC_Token__c, NE__Card_Number__c, NE__Card_Type__c, XC_SepaMandate__c, XC_SepaMandateDate__c,XC_CommodityContractID__c, (SELECT id, XC_BillToAddress__c, XC_SoldToAddress__c, XC_LegalEntity__c FROM 	Billing_Profile_Line_Items__r  ) 
                                                                                                 FROM NE__Billing_Profile__c  
                                                                                                 LIMIT 1]);//[TP-20211011-TPB]
        
        Map<String, String> mapInfos = new Map<String, String>();
        mapInfos.put('soldId', String.valueOf( [Select id from XC_Address__c LIMIT 1].id));
        mapInfos.put('billId', String.valueOf( [Select id from XC_Address__c LIMIT 1].id));
        mapInfos.put('stream','B2B');
        mapInfos.put('clientSystem','CommodityItalyB2C'); 

        mapUtilBp.put( 'mapBp', mapBp);
        mapUtilBp.put('mapInfos', mapInfos);
        mapUtilBp.put('billProfListToInsert', [SELECT Id, XC_InvoiceDeliveryPref__c,NE__Payment__c,XC_Token__c, NE__Card_Number__c, NE__Card_Type__c, XC_SepaMandate__c, XC_SepaMandateDate__c, (SELECT id, XC_BillToAddress__c, XC_SoldToAddress__c, XC_LegalEntity__c FROM 	Billing_Profile_Line_Items__r  ) 
                                                                                                 FROM NE__Billing_Profile__c  
                                                                                                 LIMIT 1000] );
       
        Map<Id, Map<String,String>>  billingProfMapLe = new Map<Id, Map<String,String>>();
        Map<String,String> addressMap = new Map<String,String>();
        addressMap.put('soldAddressId','');
        addressMap.put('billingAddressId','');
        billingProfMapLe.put(billingProfile[0].id,addressMap );
        mapUtilBp.put('billingProfMapLe', billingProfMapLe);
        XC_BillingProfileLineItem__c bpliRetrieved = [Select XC_BillingProfile__c, id from XC_BillingProfileLineItem__c LIMIT 1];
        mapUtilBp.put('billingProfInserted', bpliRetrieved );
        
        XC_UTIL_BillingProfile.BillingProfileIFWrapper billingProfileIFWrapper = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
        List<NE__Billing_Profile__c> billProfileList = XC_DF_BillingProfile.createBillingProfile(1);
        //billingProfileIFWrapper.BillingProfileID =billProfileList[0].id;
        //billingProfile.BillingMedia ='test';
        billingProfileIFWrapper.BillingProfileName ='Vale Vista';
        billingProfileIFWrapper.Payment ='Vale Vista';
        billingProfileIFWrapper.CurrencyName ='EUR';
        //billingProfile.CardType ='';
        billingProfileIFWrapper.ExpirationMonth ='12';
        billingProfileIFWrapper.ExpirationYear ='12';
        //billingProfile.SecurityCode ='test';
        billingProfileIFWrapper.FirstName ='test';
        billingProfileIFWrapper.LastName ='test';
        billingProfileIFWrapper.MailTo ='atest@test.it';
        billingProfileIFWrapper.InvoicePreferredLanguage='Spanish';
        billingProfileIFWrapper.LegalEntity='Codensa'; //[DeAv 20/12/2021 Added for code coverage]
        Map<Id, XC_UTIL_BillingProfile.BillingProfileIFWrapper> bpliMap = new Map<Id, XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
        bpliMap.put(billProfileList[0].id, billingProfileIFWrapper );
        
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> billingProfileListIFW = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
        billingProfileListIFW.add(billingProfileIFWrapper);
        mapUtilBp.put('billingProfileList', billingProfileListIFW);
        mapUtilBp.put('mapBPwr',bpliMap);
  
        Map<XC_UTIL_BillingProfile.BillingProfileIFWrapper, NE__Billing_Profile__c> bpMap = new Map<XC_UTIL_BillingProfile.BillingProfileIFWrapper, NE__Billing_Profile__c>();
        mapUtilBp.put('bpMap', bpMap);
        
        
        XC_REST_Account_W.WrapperResponse wrResp = new XC_REST_Account_W.WrapperResponse();
        
        Test.startTest();
        	XC_REST_Account_B.manageBillingProfile(mapUtilBp, wrResp);
        Test.stopTest();
    }    
    @isTest
    static void prepareBPinfoForZuora2(){
		List<NE__Billing_Profile__c> billingProfile = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfile[0].XC_InvoiceDeliveryPref__c = 'Email';
        billingProfile[0].NE__Payment__c = 'External Financing';
        billingProfile[0].NE__Expiration_Year__c = '20';
        update billingProfile;
        
        XC_BillingProfileLineItem__c bpli = [SELECT id from XC_BillingProfileLineItem__c LIMIT 1];
        //bpli.XC_PaymentMethod__c = 'Vale Vista';
        update bpli;
        
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        oi[0].XC_BillingProfileLineItem__c = bpli.id;
        oi[0].XC_BillingModel__c   = 'One Shot';
        oi[0].XC_PaymentMethod__c = 'External Financing';
        insert oi;
        Map<String,Object> mapUtilBp = new Map<String,Object>();
        
        Map<Id, NE__Billing_Profile__c> mapBp = new Map<Id, NE__Billing_Profile__c>();
        mapBp.put(billingProfile[0].id, [SELECT Id, XC_InvoiceDeliveryPref__c, XC_InvoicePreferredLanguage__c, NE__Expiration__c, NE__Payment__c,XC_Token__c, NE__Card_Number__c, NE__Card_Type__c, XC_SepaMandate__c, XC_SepaMandateDate__c,XC_CommodityContractID__c, (SELECT id, XC_BillToAddress__c, XC_SoldToAddress__c, XC_LegalEntity__c FROM 	Billing_Profile_Line_Items__r  ) 
                                                                                                 FROM NE__Billing_Profile__c  
                                                                                                 LIMIT 1]);//[TP-20211011-TPB]
        
        Map<String, String> mapInfos = new Map<String, String>();
        mapInfos.put('soldId', String.valueOf( [Select id from XC_Address__c LIMIT 1].id));
        mapInfos.put('billId', String.valueOf( [Select id from XC_Address__c LIMIT 1].id));

        mapUtilBp.put( 'mapBp', mapBp);
        mapUtilBp.put('mapInfos', mapInfos);
        mapUtilBp.put('billProfListToInsert', [SELECT Id, XC_InvoiceDeliveryPref__c,NE__Expiration__c, NE__Payment__c,XC_Token__c, NE__Card_Number__c, NE__Card_Type__c, XC_SepaMandate__c, XC_SepaMandateDate__c,XC_CommodityContractID__c, (SELECT id, XC_BillToAddress__c, XC_SoldToAddress__c, XC_LegalEntity__c FROM 	Billing_Profile_Line_Items__r  ) 
                                                                                                 FROM NE__Billing_Profile__c  
                                                                                                 LIMIT 1000] );
       
        Map<Id, Map<String,String>>  billingProfMapLe = new Map<Id, Map<String,String>>();
        Map<String,String> addressMap = new Map<String,String>();
        addressMap.put('soldAddressId','');
        addressMap.put('billingAddressId','');
        billingProfMapLe.put(billingProfile[0].id,addressMap );
        mapUtilBp.put('billingProfMapLe', billingProfMapLe);
        XC_BillingProfileLineItem__c bpliRetrieved = [Select XC_BillingProfile__c, id from XC_BillingProfileLineItem__c LIMIT 1];
        mapUtilBp.put('billingProfInserted', bpliRetrieved );
        
        XC_UTIL_BillingProfile.BillingProfileIFWrapper billingProfileIFWrapper = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
        List<NE__Billing_Profile__c> billProfileList = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfileIFWrapper.BillingProfileID =billProfileList[0].id;
        billingProfileIFWrapper.BillingMedia ='test';
        billingProfileIFWrapper.BillingProfileName ='test';
        billingProfileIFWrapper.Payment ='test';
        billingProfileIFWrapper.CurrencyName ='test';
        billingProfileIFWrapper.CardType ='test';
        billingProfileIFWrapper.ExpirationMonth ='test';
        billingProfileIFWrapper.ExpirationYear ='test';
        billingProfileIFWrapper.SecurityCode ='test';
        billingProfileIFWrapper.FirstName ='test';
        billingProfileIFWrapper.LastName ='test';
        billingProfileIFWrapper.MailTo ='test';
        billingProfileIFWrapper.InvoicePreferredLanguage='Chinese';
        Map<Id, XC_UTIL_BillingProfile.BillingProfileIFWrapper> bpliMap = new Map<Id, XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
        bpliMap.put(billProfileList[0].id, billingProfileIFWrapper );
        mapUtilBp.put('mapBPwr',bpliMap);

        Test.startTest();
        XC_REST_Account_B.prepareBPinfoForZuora(mapUtilBp);
        Test.stopTest();
    }
        @isTest
    static void prepareBPinfoForZuora3(){
		List<NE__Billing_Profile__c> billingProfile = XC_DF_BillingProfile.createBillingProfile(1);
        //billingProfile[0].NE__Payment__c = 'Vale Vista';
        billingProfile[0].XC_InvoiceDeliveryPref__c = 'Email';
        billingProfile[0].NE__Payment__c = 'Credit Card';
        billingProfile[0].XC_Token__c = 'test';
        billingProfile[0].NE__Card_Number__c = '1234567890123456';
        billingProfile[0].NE__Expiration_Year__c = '20';

        update billingProfile;
        
        XC_BillingProfileLineItem__c bpli = [SELECT id from XC_BillingProfileLineItem__c LIMIT 1];
        //bpli.XC_PaymentMethod__c = 'Vale Vista';
        update bpli;
        
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        oi[0].XC_BillingProfileLineItem__c = bpli.id;
        oi[0].XC_BillingModel__c   = 'One Shot';
        oi[0].XC_PaymentMethod__c = 'Credit Card';
        insert oi;
        Map<String,Object> mapUtilBp = new Map<String,Object>();
        
        Map<Id, NE__Billing_Profile__c> mapBp = new Map<Id, NE__Billing_Profile__c>();
        mapBp.put(billingProfile[0].id, [SELECT Id, XC_InvoiceDeliveryPref__c, XC_InvoicePreferredLanguage__c,XC_PayPalUsername__c, NE__Payment__c,NE__Expiration__c, NE__Expiration_Year__c, XC_Token__c, NE__Card_Number__c, NE__Card_Type__c, XC_SepaMandate__c, XC_SepaMandateDate__c,XC_CommodityContractID__c, (SELECT id, XC_BillToAddress__c, XC_SoldToAddress__c, XC_LegalEntity__c FROM 	Billing_Profile_Line_Items__r  ) 
                                                                                                 FROM NE__Billing_Profile__c  
                                                                                                 LIMIT 1]);//[TP-20211011-TPB]
        
        Map<String, String> mapInfos = new Map<String, String>();
        mapInfos.put('soldId', String.valueOf( [Select id from XC_Address__c LIMIT 1].id));
        mapInfos.put('billId', String.valueOf( [Select id from XC_Address__c LIMIT 1].id));

        mapUtilBp.put( 'mapBp', mapBp);
        mapUtilBp.put('mapInfos', mapInfos);
        mapUtilBp.put('billProfListToInsert', [SELECT Id, XC_InvoiceDeliveryPref__c,NE__Payment__c,XC_Token__c, NE__Expiration_Year__c, NE__Expiration__c, NE__Card_Number__c, NE__Card_Type__c, XC_SepaMandate__c, XC_SepaMandateDate__c,XC_CommodityContractID__c, (SELECT id, XC_BillToAddress__c, XC_SoldToAddress__c, XC_LegalEntity__c FROM 	Billing_Profile_Line_Items__r  ) 
                                                                                                 FROM NE__Billing_Profile__c  
                                                                                                 LIMIT 1000] );
       
        Map<Id, Map<String,String>>  billingProfMapLe = new Map<Id, Map<String,String>>();
        Map<String,String> addressMap = new Map<String,String>();
        addressMap.put('soldAddressId','');
        addressMap.put('billingAddressId','');
        billingProfMapLe.put(billingProfile[0].id,addressMap );
        mapUtilBp.put('billingProfMapLe', billingProfMapLe);
        XC_BillingProfileLineItem__c bpliRetrieved = [Select XC_BillingProfile__c, id from XC_BillingProfileLineItem__c LIMIT 1];
        mapUtilBp.put('billingProfInserted', bpliRetrieved );
        
        XC_UTIL_BillingProfile.BillingProfileIFWrapper billingProfileIFWrapper = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
        List<NE__Billing_Profile__c> billProfileList = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfileIFWrapper.BillingProfileID =billProfileList[0].id;
        billingProfileIFWrapper.BillingMedia ='test';
        billingProfileIFWrapper.BillingProfileName ='test';
        billingProfileIFWrapper.Payment ='test';
        billingProfileIFWrapper.CurrencyName ='test';
        billingProfileIFWrapper.CardType ='test';
        billingProfileIFWrapper.ExpirationMonth ='test';
        billingProfileIFWrapper.ExpirationYear ='test';
        billingProfileIFWrapper.SecurityCode ='test';
        billingProfileIFWrapper.FirstName ='test';
        billingProfileIFWrapper.LastName ='test';
        billingProfileIFWrapper.MailTo ='test';
        billingProfileIFWrapper.InvoicePreferredLanguage='Chinese';
        Map<Id, XC_UTIL_BillingProfile.BillingProfileIFWrapper> bpliMap = new Map<Id, XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
        bpliMap.put(billProfileList[0].id, billingProfileIFWrapper );
        mapUtilBp.put('mapBPwr',bpliMap);

        Test.startTest();
        XC_REST_Account_B.prepareBPinfoForZuora(mapUtilBp);
        Test.stopTest();
    }
    
    @isTest
    static void prepareBPinfoForZuora4(){
        List<User> user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId()];
        user[0].XC_EnabledToSkip__c = true;
        update user;

        System.runAs(user[0]){
            Test.startTest();
            List<NE__Billing_Profile__c> billingProfile = XC_DF_BillingProfile.createBillingProfile(1);
            //billingProfile[0].NE__Payment__c = 'Vale Vista';
            billingProfile[0].XC_InvoiceDeliveryPref__c = 'Email';
            billingProfile[0].NE__Payment__c = 'Direct Debt';
            billingProfile[0].XC_Token__c = 'test';
            billingProfile[0].NE__Iban__c = '1234567890123456';

            update billingProfile;
            
            XC_BillingProfileLineItem__c bpli = [SELECT id from XC_BillingProfileLineItem__c LIMIT 1];
            //bpli.XC_PaymentMethod__c = 'Vale Vista';
            update bpli;
            
            List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
            oi[0].XC_BillingProfileLineItem__c = bpli.id;
            oi[0].XC_BillingModel__c   = 'One Shot';
            oi[0].XC_PaymentMethod__c = 'Direct Debt';
            insert oi;
            Map<String,Object> mapUtilBp = new Map<String,Object>();
            
            Map<Id, NE__Billing_Profile__c> mapBp = new Map<Id, NE__Billing_Profile__c>();
            mapBp.put(billingProfile[0].id, [SELECT Id, XC_InvoiceDeliveryPref__c, NE__Iban__c, NE__Payment__c,NE__Expiration__c, NE__Expiration_Year__c, XC_Token__c, 
                                            NE__Card_Number__c, NE__Card_Type__c, XC_SepaMandate__c, XC_SepaMandateDate__c,XC_CommodityContractID__c, XC_InvoicePreferredLanguage__c,
                                            (SELECT id, XC_BillToAddress__c, XC_SoldToAddress__c, XC_LegalEntity__c FROM 	Billing_Profile_Line_Items__r  ) 
                                            FROM NE__Billing_Profile__c  
                                            LIMIT 1]);//[TP-20211011-TPB]
            
            Map<String, String> mapInfos = new Map<String, String>();
            mapInfos.put('soldId', String.valueOf( [Select id from XC_Address__c LIMIT 1].id));
            mapInfos.put('billId', String.valueOf( [Select id from XC_Address__c LIMIT 1].id));

            mapUtilBp.put( 'mapBp', mapBp);
            mapUtilBp.put('mapInfos', mapInfos);
            mapUtilBp.put('billProfListToInsert', [SELECT Id, XC_InvoiceDeliveryPref__c,NE__Iban__c, NE__Payment__c,XC_Token__c, NE__Expiration_Year__c, NE__Expiration__c, NE__Card_Number__c, NE__Card_Type__c, XC_SepaMandate__c, XC_SepaMandateDate__c,XC_CommodityContractID__c, (SELECT id, XC_BillToAddress__c, XC_SoldToAddress__c, XC_LegalEntity__c FROM 	Billing_Profile_Line_Items__r  ) 
                                                                                                    FROM NE__Billing_Profile__c  
                                                                                                    LIMIT 1000] );
        
            Map<Id, Map<String,String>>  billingProfMapLe = new Map<Id, Map<String,String>>();
            Map<String,String> addressMap = new Map<String,String>();
            addressMap.put('soldAddressId','');
            addressMap.put('billingAddressId','');
            billingProfMapLe.put(billingProfile[0].id,addressMap );
            mapUtilBp.put('billingProfMapLe', billingProfMapLe);
            XC_BillingProfileLineItem__c bpliRetrieved = [Select XC_BillingProfile__c, id from XC_BillingProfileLineItem__c LIMIT 1];
            mapUtilBp.put('billingProfInserted', bpliRetrieved );
            
            XC_UTIL_BillingProfile.BillingProfileIFWrapper billingProfileIFWrapper = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
            List<NE__Billing_Profile__c> billProfileList = XC_DF_BillingProfile.createBillingProfile(1);
            billingProfileIFWrapper.BillingProfileID =billProfileList[0].id;
            billingProfileIFWrapper.BillingMedia ='test';
            billingProfileIFWrapper.BillingProfileName ='test';
            billingProfileIFWrapper.Payment ='test';
            billingProfileIFWrapper.CurrencyName ='test';
            billingProfileIFWrapper.CardType ='test';
            billingProfileIFWrapper.ExpirationMonth ='test';
            billingProfileIFWrapper.ExpirationYear ='test';
            billingProfileIFWrapper.SecurityCode ='test';
            billingProfileIFWrapper.FirstName ='test';
            billingProfileIFWrapper.LastName ='test';
            billingProfileIFWrapper.MailTo ='test';
            billingProfileIFWrapper.InvoicePreferredLanguage='Chinese';
            Map<Id, XC_UTIL_BillingProfile.BillingProfileIFWrapper> bpliMap = new Map<Id, XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
            bpliMap.put(billProfileList[0].id, billingProfileIFWrapper );
            mapUtilBp.put('mapBPwr',bpliMap);

           
            XC_REST_Account_B.prepareBPinfoForZuora(mapUtilBp);
            Test.stopTest();
        }
    }
    
        @isTest
    static void prepareBPinfoForZuora5(){
        List<User> user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId()];
        user[0].XC_EnabledToSkip__c = true;
        update user;

        System.runAs(user[0]){
		List<NE__Billing_Profile__c> billingProfile = XC_DF_BillingProfile.createBillingProfile(2);
        //billingProfile[0].NE__Payment__c = 'Vale Vista';
        billingProfile[0].XC_InvoiceDeliveryPref__c = 'Email';
        billingProfile[0].NE__Payment__c = 'Direct Debt';
        billingProfile[0].XC_Token__c = 'test';
        billingProfile[0].NE__Iban__c = '1234567890123456';

        update billingProfile;
        
        XC_BillingProfileLineItem__c bpli = [SELECT id from XC_BillingProfileLineItem__c LIMIT 1];
        //bpli.XC_PaymentMethod__c = 'Vale Vista';
        update bpli;
        
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        oi[0].XC_BillingProfileLineItem__c = bpli.id;
        oi[0].XC_BillingModel__c   = 'One Shot';
        oi[0].XC_PaymentMethod__c = 'Direct Debt';
        insert oi;
        Map<String,Object> mapUtilBp = new Map<String,Object>();
        
        Map<Id, NE__Billing_Profile__c> mapBp = new Map<Id, NE__Billing_Profile__c>();
        mapBp.put(billingProfile[0].id, [SELECT Id, XC_InvoiceDeliveryPref__c, NE__Iban__c, NE__Payment__c,NE__Expiration__c, NE__Expiration_Year__c, XC_Token__c, NE__Card_Number__c, NE__Card_Type__c, XC_SepaMandate__c, XC_SepaMandateDate__c, (SELECT id, XC_BillToAddress__c, XC_SoldToAddress__c, XC_LegalEntity__c FROM 	Billing_Profile_Line_Items__r  ) 
                                                                                                 FROM NE__Billing_Profile__c WHERE ID =: billingProfile[0].id 
                                                                                                 LIMIT 1]);
        
        Map<String, String> mapInfos = new Map<String, String>();
        mapInfos.put('soldId', String.valueOf( [Select id from XC_Address__c LIMIT 1].id));
        mapInfos.put('billId', String.valueOf( [Select id from XC_Address__c LIMIT 1].id));
		mapInfos.put('clientSystem', 'CommodityItalyB2C');//[TP-20211011-TPB]
        
        mapUtilBp.put( 'mapBp', mapBp);
        mapUtilBp.put('mapInfos', mapInfos);
        mapUtilBp.put('billProfListToInsert', [SELECT Id, XC_InvoiceDeliveryPref__c,NE__Iban__c, NE__Payment__c,XC_Token__c, NE__Expiration_Year__c, NE__Expiration__c, NE__Card_Number__c, NE__Card_Type__c, XC_SepaMandate__c, XC_SepaMandateDate__c,XC_CommodityContractID__c, (SELECT id, XC_BillToAddress__c, XC_SoldToAddress__c, XC_LegalEntity__c FROM 	Billing_Profile_Line_Items__r  ) 
                                                                                                 FROM NE__Billing_Profile__c WHERE ID =:  billingProfile[1].id
                                                                                                 ] );
       
        Map<Id, Map<String,String>>  billingProfMapLe = new Map<Id, Map<String,String>>();
        Map<String,String> addressMap = new Map<String,String>();
        addressMap.put('soldAddressId','');
        addressMap.put('billingAddressId','');
        billingProfMapLe.put(billingProfile[0].id,addressMap );
        mapUtilBp.put('billingProfMapLe', billingProfMapLe);
        XC_BillingProfileLineItem__c bpliRetrieved = [Select XC_BillingProfile__c, id from XC_BillingProfileLineItem__c where XC_BillingProfile__c = : billingProfile[1].id  LIMIT 1];
        mapUtilBp.put('billingProfInserted', bpliRetrieved );
        
        XC_UTIL_BillingProfile.BillingProfileIFWrapper billingProfileIFWrapper = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
        List<NE__Billing_Profile__c> billProfileList = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfileIFWrapper.BillingProfileID = billingProfile[1].id;
        billingProfileIFWrapper.IBAN ='1234567890123456';
        billingProfileIFWrapper.Token ='test';
        billingProfileIFWrapper.SEPAMandateId ='test';
        billingProfileIFWrapper.SEPAMandateDate ='test';
        billingProfileIFWrapper.InvoicePreferredLanguage='Chinese';
        billingProfileIFWrapper.InvoiceDeliveryPref = 'Email';
        billingProfileIFWrapper.PaymentMethod = 'Direct Debt';
        Map<Id, XC_UTIL_BillingProfile.BillingProfileIFWrapper> bpliMap = new Map<Id, XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
        bpliMap.put(billingProfile[1].id, billingProfileIFWrapper );
        mapUtilBp.put('mapBPwr',bpliMap);

        Test.startTest();
        XC_REST_Account_B.prepareBPinfoForZuora(mapUtilBp);
        Test.stopTest();
        }
    }
    
            @isTest
    static void prepareBPinfoForZuora6(){
        List<User> user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId()];
        user[0].XC_EnabledToSkip__c = true;
        update user;

        System.runAs(user[0]){
            Test.startTest();
            List<NE__Billing_Profile__c> billingProfile = XC_DF_BillingProfile.createBillingProfile(2);
            //billingProfile[0].NE__Payment__c = 'Vale Vista';
            billingProfile[0].XC_InvoiceDeliveryPref__c = 'Email';
            billingProfile[0].NE__Payment__c = 'Direct Debt';
            billingProfile[0].XC_Token__c = 'test';
            billingProfile[0].NE__Iban__c = '1234567890123456';

            update billingProfile;
            
            XC_BillingProfileLineItem__c bpli = [SELECT id from XC_BillingProfileLineItem__c LIMIT 1];
            //bpli.XC_PaymentMethod__c = 'Vale Vista';
            update bpli;
            
            List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
            oi[0].XC_BillingProfileLineItem__c = bpli.id;
            oi[0].XC_BillingModel__c   = 'One Shot';
            oi[0].XC_PaymentMethod__c = 'Direct Debt';
            insert oi;
            Map<String,Object> mapUtilBp = new Map<String,Object>();
            
            Map<Id, NE__Billing_Profile__c> mapBp = new Map<Id, NE__Billing_Profile__c>();
            mapBp.put(billingProfile[0].id, [SELECT Id, XC_InvoiceDeliveryPref__c, NE__Iban__c, NE__Payment__c,NE__Expiration__c, NE__Expiration_Year__c, XC_Token__c, NE__Card_Number__c, NE__Card_Type__c, XC_SepaMandate__c, XC_SepaMandateDate__c, (SELECT id, XC_BillToAddress__c, XC_SoldToAddress__c, XC_LegalEntity__c FROM 	Billing_Profile_Line_Items__r  ) 
                                                                                                    FROM NE__Billing_Profile__c WHERE ID =: billingProfile[0].id 
                                                                                                    LIMIT 1]);
            
            Map<String, String> mapInfos = new Map<String, String>();
            mapInfos.put('soldId', String.valueOf( [Select id from XC_Address__c LIMIT 1].id));
            mapInfos.put('billId', String.valueOf( [Select id from XC_Address__c LIMIT 1].id));
            mapInfos.put('clientSystem', 'CommodityItalyB2C');//[TP-20211011-TPB]
            
            mapUtilBp.put( 'mapBp', mapBp);
            mapUtilBp.put('mapInfos', mapInfos);
            mapUtilBp.put('billProfListToInsert', [SELECT Id, XC_InvoiceDeliveryPref__c,NE__Iban__c, NE__Payment__c,XC_Token__c, NE__Expiration_Year__c, NE__Expiration__c, NE__Card_Number__c, NE__Card_Type__c, XC_SepaMandate__c, XC_SepaMandateDate__c,XC_CommodityContractID__c, (SELECT id, XC_BillToAddress__c, XC_SoldToAddress__c, XC_LegalEntity__c FROM 	Billing_Profile_Line_Items__r  ) 
                                                                                                    FROM NE__Billing_Profile__c WHERE ID =:  billingProfile[1].id
                                                                                                    ] );
        
            Map<Id, Map<String,String>>  billingProfMapLe = new Map<Id, Map<String,String>>();
            Map<String,String> addressMap = new Map<String,String>();
            addressMap.put('soldAddressId','');
            addressMap.put('billingAddressId','');
            billingProfMapLe.put(billingProfile[0].id,addressMap );
            mapUtilBp.put('billingProfMapLe', billingProfMapLe);
            XC_BillingProfileLineItem__c bpliRetrieved = [Select XC_BillingProfile__c, id from XC_BillingProfileLineItem__c where XC_BillingProfile__c = : billingProfile[1].id  LIMIT 1];
            mapUtilBp.put('billingProfInserted', bpliRetrieved );
            
            XC_UTIL_BillingProfile.BillingProfileIFWrapper billingProfileIFWrapper = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
            List<NE__Billing_Profile__c> billProfileList = XC_DF_BillingProfile.createBillingProfile(1);
            billingProfileIFWrapper.BillingProfileID = billingProfile[1].id;
            billingProfileIFWrapper.ExpirationMonth ='12';
            billingProfileIFWrapper.ExpirationYear ='12';
            billingProfileIFWrapper.CreditCardHolder ='test';
            billingProfileIFWrapper.CreditCardLastFourNumber ='1234';
            billingProfileIFWrapper.CreditCardType ='Visa';
            billingProfileIFWrapper.InvoicePreferredLanguage='Chinese';
            billingProfileIFWrapper.InvoiceDeliveryPref = 'Email';
            billingProfileIFWrapper.PaymentMethod = 'Credit Card';
            Map<Id, XC_UTIL_BillingProfile.BillingProfileIFWrapper> bpliMap = new Map<Id, XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
            bpliMap.put(billingProfile[1].id, billingProfileIFWrapper );
            mapUtilBp.put('mapBPwr',bpliMap);
            
            Map<String,String> creditCardType = new Map<String,String>();
            creditCardType.put('VISA', 'VISA');
            mapUtilBp.put('creditCardType', creditCardType);
           
            XC_REST_Account_B.prepareBPinfoForZuora(mapUtilBp);
            Test.stopTest();
        }
    }
    
    @isTest
    static void manageDocument(){
        User u = XC_DF_User.createUserAdmin();
        insert u;
        
        Map<String,Object> mapAccountDocument = new Map<String,Object>();
        List<Account> acclist = XC_DF_Account.createResidentialAccounts(1);
        acclist[0].XC_Segment__c='B2C';
        insert acclist;
        List<NE__Billing_Profile__c> bpList = XC_DF_BillingProfile.createBillingProfile(1,acclist);
        List<XC_BillingProfileLineItem__c> billProfLineItemListToInsert = [Select id, XC_LegalEntity__c  from XC_BillingProfileLineItem__c];
        billProfLineItemListToInsert[0].XC_LegalEntity__c = 'EndesaX';
        update billProfLineItemListToInsert;
        mapAccountDocument.put('billProfLineItemListToInsert', billProfLineItemListToInsert);

        mapAccountDocument.put('acc', acclist[0]);
        
        XC_UTIL_Account.IdentityIFWrapper identityWr = new XC_UTIL_Account.IdentityIFWrapper();
        identityWr.IdentityType = 'test';
        identityWr.IdentityNumber ='test';
        identityWr.ReleaseDate='test';
        identityWr.ExpiryDate='test';
        identityWr.Country='Spain';
        mapAccountDocument.put('identityWr', identityWr);
        
        mapAccountDocument.put('methodPUT', false);
        
        Test.startTest();
        System.runAs(u){
            XC_REST_Account_B.manageDocument(mapAccountDocument);
        }
        Test.stopTest();
    }
    
    @isTest
    static void manageWrapperOption(){
        Map<String, Object> wrOptionMap = new Map<String, Object>();
        wrOptionMap.put('invoiceEmail', true);
        wrOptionMap.put('invoicePrint', false);
        wrOptionMap.put('splitPayment', true);
        wrOptionMap.put('payment', 'Net 7');
        wrOptionMap.put('docNif', 'test');
        XC_CM_LegalEntity_Configuration__mdt cm = [SELECT Id, XC_Country__c, XC_ValidDocuments__c, XC_SkipZuoraGuest__c, XC_ZuoraSequenceSetId__c FROM XC_CM_LegalEntity_Configuration__mdt LIMIT 1];//[TP-20211011-TPB]
        wrOptionMap.put('legalInfo', cm);
        
        Map<String,Object> mapInfos = new Map<String,Object>();
        mapInfos.put('isGuest', 'No');
        wrOptionMap.put('mapInfos', mapInfos);
        
        Test.startTest();
        	XC_REST_Account_B.manageWrapperOption(wrOptionMap);
        Test.stopTest();
    }
    
   /* @isTest
    static void checkMandatoryCBValues(){
        Map<String,Object> paymentMethod = new Map<String,Object>();
        paymentMethod.put('CupsID','');
        Test.startTest();
        	XC_REST_Account_B.checkMandatoryCBValues(paymentMethod);
        Test.stopTest();
    }*/
    
    @isTest
    static void manageContactSerialized(){
        Map<String,String> mapUtil = new Map<String,String>();
        
        List<Contact> contactList = XC_DF_Contact.createCondominiumContacts(1);
        insert contactList;
        
        List<XC_Address__c> addressList = XC_DF_Address.createAddress(1);
        insert addressList;
        
        mapUtil.put('bpli', '{"XC_BillToContactId__c":"'+ contactList[0].id +'",  "XC_SoldToAddress__c":"'+ addressList[0].id + '",	"XC_BillToAddress__c":"'+ addressList[0].id +'", "XC_LegalEntity__c":"EndesaX"}');
        mapUtil.put('country', 'Spain');
        
        Test.startTest();
        	XC_REST_Account_B.manageContactSerialized(mapUtil);
        Test.stopTest();
    }
    
    @isTest
    static void manageContactSerialized2(){
        Map<String,String> mapUtil = new Map<String,String>();
        
        List<Contact> contactList = XC_DF_Contact.createCondominiumContacts(1);
        insert contactList;
        
        List<XC_Address__c> addressList = XC_DF_Address.createAddress(2);
        insert addressList;
        
        mapUtil.put('bpli', '{"XC_BillToContactId__c":"'+ contactList[0].id +'",  "XC_SoldToAddress__c":"'+ addressList[0].id + '",	"XC_BillToAddress__c":"'+ addressList[1].id +'", "XC_LegalEntity__c":"EndesaX", "XC_SoldToContactId__c":"'+ contactList[0].id +'"}');
        mapUtil.put('country', 'Spain');
        
        Test.startTest();
        	XC_REST_Account_B.manageContactSerialized(mapUtil);
        Test.stopTest();
    }
    
    @isTest
    static void callZuora(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        Map<String,String> zuoraMap = new Map<String,String>();
        
        List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
        insert accList;
        zuoraMap.put('account', JSON.serialize(accList[0]));
        zuoraMap.put('legalEntity', 'EndesaX');
        zuoraMap.put('options', 'test');
		List<NE__Billing_Profile__c> bpList = XC_DF_BillingProfile.createBillingProfile(1);
        zuoraMap.put('billingProfLineItemId', [Select id  from XC_BillingProfileLineItem__c LIMIT 1].id);
        Map<String,Object> mapPayment = new Map<String,Object>();
        mapPayment.put('Type', 'BankTransfer');
        zuoraMap.put('mapPayment', JSON.serialize(mapPayment));
        XC_BillingProfileLineItem__c bpli = [Select id, XC_BillToContactId__c, XC_SoldToAddress__c, XC_LegalEntity__c,XC_SoldToContactId__c, XC_BillToAddress__c from XC_BillingProfileLineItem__c LIMIT 1];
        List<Contact> contactList = XC_DF_Contact.createCondominiumContacts(1);
        insert contactList;
        bpli.XC_BillToContactId__c = contactList[0].id;
        bpli.XC_SoldToContactId__c = contactList[0].id;
        bpli.XC_LegalEntity__c = 'EndesaX';
        List<XC_Address__c> add = XC_DF_Address.createAddress(accList);
        insert add;
        bpli.XC_SoldToAddress__c = add[0].id;
        bpli.XC_BillToAddress__c = add[0].id;
        bpli.XC_Account__c = accList[0].id; 
        update bpli;
        zuoraMap.put('bpli', JSON.serialize(bpli) );
        zuoraMap.put('country', 'Spain');
        zuoraMap.put('zuoraPayment', '{}');
        Test.startTest();
        XC_REST_Account_B.callZuora(zuoraMap);
		Test.stopTest();
        
    }
    
        @isTest
    static void callZuora2(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        Map<String,String> zuoraMap = new Map<String,String>();
        
        List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
        insert accList;
        zuoraMap.put('account', JSON.serialize(accList[0]));
        zuoraMap.put('legalEntity', 'TEST');
        zuoraMap.put('options', 'test');
		List<NE__Billing_Profile__c> bpList = XC_DF_BillingProfile.createBillingProfile(1);
        zuoraMap.put('billingProfLineItemId', [Select id  from XC_BillingProfileLineItem__c LIMIT 1].id);
        Map<String,Object> mapPayment = new Map<String,Object>();
        mapPayment.put('Type', 'BankTransfer');
        zuoraMap.put('mapPayment', JSON.serialize(mapPayment));
        XC_BillingProfileLineItem__c bpli = [Select id, XC_BillToContactId__c, XC_SoldToAddress__c, XC_LegalEntity__c,XC_SoldToContactId__c, XC_BillToAddress__c from XC_BillingProfileLineItem__c LIMIT 1];
        List<Contact> contactList = XC_DF_Contact.createCondominiumContacts(1);
        insert contactList;
        bpli.XC_BillToContactId__c = contactList[0].id;
        bpli.XC_SoldToContactId__c = contactList[0].id;
        bpli.XC_LegalEntity__c = 'EndesaX';
        List<XC_Address__c> add = XC_DF_Address.createAddress(accList);
        insert add;
        bpli.XC_SoldToAddress__c = add[0].id;
        bpli.XC_BillToAddress__c = add[0].id;
        bpli.XC_Account__c = accList[0].id; 
        update bpli;
        zuoraMap.put('bpli', JSON.serialize(bpli) );
        zuoraMap.put('country', 'Spain');
        zuoraMap.put('zuoraPayment', '{}');
        Test.startTest();
        XC_REST_Account_B.callZuora(zuoraMap);
		Test.stopTest();
        
    }
    
    @isTest
    static void createBillingProfile1(){
        List<NE__Billing_Profile__c> billingProfile = XC_DF_BillingProfile.createBillingProfile(1);
        
        Map<String, Object> optionsMap = new Map<String, Object>();
        optionsMap.put('paymentMethodType','Credit Card' );
        optionsMap.put('cardNumber', '1234567890123456');
        optionsMap.put('accountNumber','1234567890');
        optionsMap.put('contractId', '1234567890');
        optionsMap.put('fromBillingProfile', true);
        optionsMap.put('SEPAMandateType', 'One time');
        
        Map<String, Object> debtorCode = new  Map<String, Object>();
        debtorCode.put('debtorCode', '123456789');
        optionsMap.put('siaPayment',JSON.serialize(debtorCode));
        String info = JSON.serialize(optionsMap);
        Test.startTest();
        XC_REST_Account_B.createBillingProfile( info,  billingProfile[0]);
        Test.stopTest();
    }
    
        @isTest
    static void createBillingProfile2(){
        List<NE__Billing_Profile__c> billingProfile = XC_DF_BillingProfile.createBillingProfile(1);
        
        Map<String, Object> optionsMap = new Map<String, Object>();
        optionsMap.put('paymentMethodType','Commodity Bill' );
        optionsMap.put('cardNumber', '1234567890123456');
        optionsMap.put('accountNumber','1234567890');
        List<Contract> contract = XC_DF_Contract.createContracts(1);
        insert contract;
        optionsMap.put('contractId', contract[0].id);
        optionsMap.put('fromBillingProfile', true);
        optionsMap.put('SEPAMandateType', 'One time');
        
        Map<String, Object> debtorCode = new  Map<String, Object>();
        debtorCode.put('debtorCode', '123456789');
        optionsMap.put('siaPayment',JSON.serialize(debtorCode));
        String info = JSON.serialize(optionsMap);
        Test.startTest();
        XC_REST_Account_B.createBillingProfile( info,  billingProfile[0]);
        Test.stopTest();
    }
    
            @isTest
    static void createBillingProfile3(){
        List<NE__Billing_Profile__c> billingProfile = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfile[0].Name ='test sepa';
        update billingProfile;
        Map<String, Object> optionsMap = new Map<String, Object>();
        optionsMap.put('paymentMethodType','test' );
        optionsMap.put('cardNumber', '1234567890123456');
        optionsMap.put('accountNumber','1234567890');
        List<Contract> contract = XC_DF_Contract.createContracts(1);
        insert contract;
        optionsMap.put('contractId', contract[0].id);
        optionsMap.put('fromBillingProfile', true);
        optionsMap.put('SEPAMandateType', 'One time');
        
        Map<String, Object> debtorCode = new  Map<String, Object>();
        debtorCode.put('debtorCode', '123456789');
        optionsMap.put('siaPayment',JSON.serialize(debtorCode));
        String info = JSON.serialize(optionsMap);
        Test.startTest();
        XC_REST_Account_B.createBillingProfile( info,  billingProfile[0]);
        Test.stopTest();
    }
    
	@isTest
    static void createBillingProfile4(){
        List<NE__Billing_Profile__c> billingProfile = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfile[0].Name ='test direct debt';
        update billingProfile;
        Map<String, Object> optionsMap = new Map<String, Object>();
        optionsMap.put('paymentMethodType','test' );
        optionsMap.put('cardNumber', '1234567890123456');
        optionsMap.put('accountNumber','1234567890');
        List<Contract> contract = XC_DF_Contract.createContracts(1);
        insert contract;
        optionsMap.put('contractId', contract[0].id);
        optionsMap.put('fromBillingProfile', true);
        optionsMap.put('SEPAMandateType', 'One time');
        
        Map<String, Object> debtorCode = new  Map<String, Object>();
        debtorCode.put('debtorCode', '123456789');
        optionsMap.put('siaPayment',JSON.serialize(debtorCode));
        String info = JSON.serialize(optionsMap);
        Test.startTest();
        XC_REST_Account_B.createBillingProfile( info,  billingProfile[0]);
        Test.stopTest();
    }
	@isTest
    static void createBillingProfile5(){
        List<NE__Billing_Profile__c> billingProfile = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfile[0].Name ='test ';
        update billingProfile;
        Map<String, Object> optionsMap = new Map<String, Object>();
        optionsMap.put('paymentMethodType','test' );
        optionsMap.put('cardNumber', '1234567890123456');
        optionsMap.put('accountNumber','1234567890');
        List<Contract> contract = XC_DF_Contract.createContracts(1);
        insert contract;
        optionsMap.put('contractId', contract[0].id);
        optionsMap.put('fromBillingProfile', true);
        optionsMap.put('SEPAMandateType', 'One time');
        
        Map<String, Object> debtorCode = new  Map<String, Object>();
        debtorCode.put('debtorCode', '123456789');
        optionsMap.put('siaPayment',JSON.serialize(debtorCode));
        String info = JSON.serialize(optionsMap);
        Test.startTest();
        XC_REST_Account_B.wrapperInfo wrInfo = new XC_REST_Account_B.wrapperInfo();
        XC_REST_Account_B.WrapperOption wrOption = new XC_REST_Account_B.WrapperOption();
        XC_REST_Account_B.createBillingProfile( info,  billingProfile[0]);
        Test.stopTest();
    }


    // CallZuoraRefactoring Test
    @isTest
    static void callZuoraFromRetrieveButton(){

        List<NE__Billing_Profile__c> billingProfile = XC_DF_BillingProfile.createBillingProfile(1);
        XC_BillingProfileLineItem__c bpli = [SELECT id from XC_BillingProfileLineItem__c LIMIT 1];
      //  bpli.XC_ZuoralntegrationTechnicaParameter__c = 'lONG tEXT';
        //update bpli;
        Test.startTest();
        XC_REST_Account_B.callZuoraFromRetrieveButton(bpli.id);
        Test.stopTest();

    }

    // CallZuoraRefactoring Test
    @isTest
    static void manageRetry(){

        List<NE__Billing_Profile__c> billingProfile = XC_DF_BillingProfile.createBillingProfile(1);
        XC_BillingProfileLineItem__c bpli = [SELECT id from XC_BillingProfileLineItem__c LIMIT 1];
        bpli.XC_ZuoraIntegrationSubStatus__c = 'Test Substatus';
        update bpli;
        Test.startTest();
        XC_REST_Account_B.manageRetry(bpli.id,'Dummy Error Log','Dummy API Name',bpli.XC_ZuoraIntegrationSubStatus__c);
        Test.stopTest();

    }

  
}