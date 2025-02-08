/**
* @author Eleni Tsiolaki - etsiolaki@deloitte.gr 
* @Creation 18/06/2021
* @Modification
* @description Test Class for XC_LCC253_DelegatedSignatureButton
*/

@isTest
private class XC_LCC253_DelegatedSignatureButton_TEST {
    @TestSetup
    static void insertRecords() {
        Account acc = new Account(Name='AccountTest',PrimaryEmail__c='testAcc@gmail.com');
        insert acc;
        Contact cont = new Contact(
            FirstName = 'contbilToName' , 
            LastName = 'contbilToName', 
            AccountId = acc.Id, 
            XC_GiveDataToNew__c = 'Yes', 
            XC_CountryLegalEntity__c = 'Italy', 
            XC_MainLegalEntity__c = 'EnelXItalia', 
            Email = 'contTest@test.it',
            XC_PrimaryContact__c = TRUE
        );
        insert cont;

        
        Contact contSecondary = new Contact(
            FirstName = 'conSecondary' , 
            LastName = 'Secondary', 
            XC_GiveDataToNew__c = 'Yes', 
            AccountId = acc.Id,
            XC_CountryLegalEntity__c = 'Italy', 
            XC_MainLegalEntity__c = 'EnelXItalia', 
            Email = 'contSecondaryTest@test.it'
        );
        insert contSecondary;
        /*  
        AccountContactRelation accContRel = new AccountContactRelation(
            AccountId = acc.Id, ContactId = contSecondary.Id
        );
        insert accContRel;
        */

        XC_PersonalDocument__c persDoc = new XC_PersonalDocument__c(
            XC_DocumentType__c = 'CI',
            XC_Contact__c = cont.Id
        );
        insert persDoc;

        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,false);
        oppList[0].XC_Contact__c = cont.Id;
        insert oppList;

        List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, 'InOrder');
        orderList[0].NE__AccountId__c = acc.Id;
        orderList[0].NE__OptyId__c = oppList[0].Id;
        insert orderList;
    }

    @isTest
    static void initializeComponentTest(){
        NE__Order__c o = [SELECT Id FROM NE__Order__c LIMIT 1];
        Test.startTest();
        XC_UTIL_ResultWrapper resultOK = XC_LCC253_DelegatedSignatureButton.initializeComponent(o.Id);
        System.assertEquals(true,resultOK.success);
        Test.stopTest();
    }

    @isTest
    static void getSecondaryContactDocumentTest(){
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        XC_UTIL_ResultWrapper resultOK = XC_LCC253_DelegatedSignatureButton.getSecondaryContactDocument(c.Id);
        system.assertNotEquals(null, resultOK.objectInfo);
        Test.stopTest();
    }

    @isTest
    static void updateOrderTest(){
        NE__Order__c o = [SELECT Id FROM NE__Order__c LIMIT 1];
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        XC_PersonalDocument__c perDoc = [SELECT Id FROM XC_PersonalDocument__c LIMIT 1];
        Map<String,Object> paramsMap = new Map<String,Object> ();
        paramsMap.put('recordId', o.Id);
        paramsMap.put('secondaryContact', c.Id);
        paramsMap.put('relationshipType', 'Other');
        paramsMap.put('primaryContactDocumentId', perDoc.Id);
        paramsMap.put('secondaryContactDocumentId', perDoc.Id);

        Test.startTest();
        XC_UTIL_ResultWrapper result = XC_LCC253_DelegatedSignatureButton.updateOrder(paramsMap); 
        NE__Order__c orderUpdated = [SELECT Id, XC_DelegatedContact__c, XC_DelegatedSignature__c FROM NE__Order__c LIMIT 1];        
        Test.stopTest();
        System.assertEquals(c.Id, orderUpdated.XC_DelegatedContact__c);
        System.assertEquals(true, orderUpdated.XC_DelegatedSignature__c);
    }
    
}