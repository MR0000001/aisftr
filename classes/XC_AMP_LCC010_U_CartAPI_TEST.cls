/**
 * The Class XC_AMP_LCC010_U_CartAPI_TEST.
 *
 * @author            : Luisana Rocco - lrocco@deloitte.it
 * @date Creation     : 25/01/2021
 * @date Modification : dd/mm/yyyy
 * @description       : Test Class for XC_AMP_LCC010_U_CartAPI - XC_AMP_LCC010_OrderComposer
 **/

@isTest
public without sharing class XC_AMP_LCC010_U_CartAPI_TEST {
    
    @TestSetup
    static void setup(){ 

        XC_AMP_Vehicle__c veh = new XC_AMP_Vehicle__c();
        veh.XC_AMP_ExpectedDeliveryDate__c = Date.today();
        insert veh;

        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, false); 
        oppList[0].XC_AMP_Vehicle__c = veh.Id;
        insert oppList;
     
        List<Account>  accountList = [Select id FROM Account LIMIT 1];
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(accountList);
        contList[0].XC_PrimaryContact__c = true;
        insert contList;
        
        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'Order';
        order.NE__AccountId__c =  accountList[0].Id;
        order.XC_Country__c = 'Spain';
        order.XC_Segment__c = 'B2C';
        insert order;
        

        NE__Product__c prod = new NE__Product__c();
        prod.XC_Product_Subtype__c = 'Solar Thermal';
        prod.XC_Product_Type__c = 'Equipment';
        prod.XC_LIC_Product_Name__c = 'Test';
        insert prod;

        NE__Catalog_Item__c catItem = XC_DF_CatalogItem.createCatalogItem();
        catItem.NE__ProductId__c = prod.id;
        insert catItem;

        List<NE__Billing_Profile__c> bp = XC_DF_BillingProfile.createBillingProfile(1, accountList);

        XC_BillingProfileLineItem__c bpli = [SELECT Id, XC_BillingProfile__c FROM XC_BillingProfileLineItem__c  WHERE XC_BillingProfile__c =: bp[0].Id][0];
        bpli.XC_DocumentType__c = 'Codice Fiscale';
        bpli.XC_DocumentNumber__c = 'TSTTST80A01F839I';
        bpli.XC_LegalEntity__c = 'EnelXItalia';
        update bpli; 

        

    }



    //retrieve token
    @isTest
    static void retrieveCartAPITokenTest(){
        
		XC_CS004_Bit2WinCredentials__c b2wCred = new XC_CS004_Bit2WinCredentials__c (XC_ClientId__c = '1234', XC_OrganizationId__c = '8393', XC_ServerURL__c = 'b2wCred', XC_Country__c ='SPAIN');
        insert b2wCred; 
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new XC_REST_CartAPI_TEST.generateRequestTrue_Mock());
		XC_AMP_LCC010_U_CartAPI.retrieveCartAPIToken();
        test.stopTest();

        System.assertNotEquals(null, b2wCred, 'Wrong assert result');
    }


    //retrieve cartAPI and catalog item
    @isTest
    static void retrieveCartAPICatalogAndItemsTest(){

        Map<String,Object> paramsMap = setParamsInfos();

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new XC_REST_CartAPI_TEST.generateRequestTrue_Mock());
		XC_AMP_LCC010_OrderComposer.retrieveProducts(paramsMap);
        test.stopTest();
        
        System.assertNotEquals(null, paramsMap.get('b2wInfos'), 'Wrong assert result');        
        
    }
    
    //upsert catalog item 
    @isTest
    static void firstUpsertCartAPICatalogItemstest(){

        Map<String,Object> paramsMap = setParamsInfos();

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new XC_REST_CartAPI_TEST.generateRequestTrue_Mock());
		XC_AMP_LCC010_OrderComposer.firstUpsertProduct(paramsMap);
        test.stopTest();
		
		System.assertNotEquals(null, paramsMap.get('b2wInfos'), 'Wrong assert result');        
    }

	//remove item 
    @isTest
    static void removeItemTest(){

        Map<String,Object> paramsMap = setParamsInfos();

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new XC_REST_CartAPI_TEST.generateRequestTrue_Mock());
        XC_AMP_LCC010_OrderComposer.removeItemFromCart(paramsMap);
        test.stopTest();
        
        System.assertNotEquals(null, paramsMap.get('b2wInfos'), 'Wrong assert result');        
        
    }
    
    //save configuration 
    @isTest
    static void finalSaveConfigurationTest(){

        Map<String,Object> paramsMap = setParamsInfos();
        

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new XC_REST_CartAPI_TEST.generateRequestTrue_Mock());
        XC_AMP_LCC010_OrderComposer.finalSaveConfiguration(paramsMap);
        test.stopTest();
        
        XC_AMP_Vehicle__c veh = [SELECT Id, XC_AMP_ExpectedDeliveryDate__c FROM XC_AMP_Vehicle__c LIMIT 1];
        System.assertEquals(Date.today().addDays(10),veh.XC_AMP_ExpectedDeliveryDate__c);
        
    }
    
    //method to set params
    public static Map<String,Object> setParamsInfos(){

        Map<Id,Account> accountMap = new Map<Id,Account> ([SELECT id, (SELECT id FROM Opportunities), (SELECT id FROM NE__Billing_Profiles__r), (SELECT id FROM  XC_BillingProfileLineItems__r) FROM Account LIMIT 1] );
        Map<Id,NE__Catalog_Item__c> catItemMap = new Map<Id,NE__Catalog_Item__c>([SELECT NE__Catalog_Id__c, NE__Catalog_Category_Name__c FROM  NE__Catalog_Item__c LIMIT 1]);
		
        Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped('{"listOfItems": [{"fields": {"id":"'+ catItemMap.values()[0].Id +'","eligible": "Y","NE__SmartPartNumber__c": "","eligibilitycomments": "","orderitemid": "","configurationstatus": "Valid"},"listOfAttributes": [{"id": "a2Y5E000000LcHzUAK","fields": {"propid": "a275E000001DZk3QAG","familyProperty": "Payment details:Payment Method"}}]}]}');
        List<Object> items = (List<Object>) result.get('listOfItems');
        List<Map<String,Object>> listOfItems = new List<Map<String,Object>>();
        for(Object obj : items) {
            Map<String,Object> item = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(obj));
            listOfItems.add(item);
        }
        
        Map<String,String> b2wInfos = new Map<String,String>();
        b2wInfos.put('getFullStructure','true');
        b2wInfos.put('NE__OptyId__c', accountMap.values()[0].Opportunities[0].Id);
        b2wInfos.put('itemsFullMap', JSON.Serialize(listOfItems));
        b2wInfos.put('clientSystem', 'test');
        
        Map<String,Object> paramsMap = new Map<String,Object>();
        paramsMap.put('accountId', accountMap.values()[0].Id);
        paramsMap.put('opportunityId', accountMap.values()[0].Opportunities[0].Id);
        paramsMap.put('defaultBpliId', accountMap.values()[0].XC_BillingProfileLineItems__r[0].Id);
        paramsMap.put('catalogId', catItemMap.values()[0].NE__Catalog_Id__c);
        paramsMap.put('categoryId', catItemMap.values()[0].NE__Catalog_Category_Name__c);
        paramsMap.put('directOrder', true);
        paramsMap.put('itemId', catItemMap.values()[0].Id);
        paramsMap.put('b2wInfos', b2wInfos);
        paramsMap.put('removeItemCode', '');
        
        Map<Object,Object> sectData = new Map<Object,Object>();
        sectData.put('sObjectName','Opportunity');
        sectData.put('sectionName','ElementiOrdineCSPS');
        sectData.put('isSectionValid',true);
        sectData.put('fields',new Map<Object,Object>());
        List<Object> validSections = new List<Object>();
        validSections.add(sectData);

        Map<Object,Object> sectDataVehicle = new Map<Object,Object>();
        sectDataVehicle.put('sObjectName','XC_AMP_Vehicle__c');
        sectDataVehicle.put('sectionName','Vettura_EnelXItalia_B2C');
        sectDataVehicle.put('isSectionValid',true);
        Map<Object,Object> newFieldAndValuesMap = new Map<Object,Object>();
        newFieldAndValuesMap.put('XC_AMP_ExpectedDeliveryDate__c', Date.today().addDays(10));
        newFieldAndValuesMap.put('XC_AMP_CarPlate__c', 'test car plate');
        sectDataVehicle.put('fields', newFieldAndValuesMap);
        validSections.add(sectDataVehicle);

		paramsMap.put('validSections',validSections);
        
        return paramsMap;
 
    }

}