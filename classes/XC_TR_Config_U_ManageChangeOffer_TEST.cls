/**
* @author: Marco Ottaviano - mottaviano@deloitte.it 
* @fileName XC_LCC194_ChangeComOff_TEST
* @date Creation Date: 19/06/2020
* @description TEST CLASS FOR XC_TR_Config_U_ManageChangeOffer
**/

@isTest
public without sharing class XC_TR_Config_U_ManageChangeOffer_TEST {
    @TestSetup
    static void makeData(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
       
        List<Account>  accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accountList);
        conList[0].XC_PrimaryContact__c = true;
        insert conList;
        List<XC_Address__c> address =  XC_DF_Address.createAddress(accountList);
        insert address;

        Opportunity opportunityToInsert = new Opportunity();
        opportunityToInsert.Name = 'OP00001';
        opportunityToInsert.XC_Contact__c = conList[0].Id;
        opportunityToInsert.AccountId = conList[0].AccountId;
        opportunityToInsert.XC_ProductCategoryOfInterest__c = 'Caldera';
        opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
        opportunityToInsert.StageName = 'Draft';
        opportunityToInsert.XC_Source__c = 'BLOG';
        opportunityToInsert.XC_ReceivingChannel__c = 'Web';
        opportunityToInsert.XC_Address__c = address[0].Id;
        opportunityToInsert.XC_LegalEntity__c = 'EndesaX';
        insert opportunityToInsert;

        Test.startTest();             
            NE__Order__c order = new NE__Order__c();
            order.NE__Type__c = 'Order';
            order.NE__OptyId__c = opportunityToInsert.Id;
            order.NE__AccountId__c = opportunityToInsert.AccountId;
            order.XC_Country__c = 'Spain';
            order.XC_Segment__c = 'B2C';
            order.XC_LegalEntity__c ='EndesaX';
            order.XC_FinancialInstitution__c ='institutionFinancial';
            order.XC_FinancialPracticeNumber__c ='testFinancial01';
            order.XC_FinancialPracticeStatus__c ='OK';
            insert order;
            NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
            insert item;
            update order;

            XC_DocumentSignature__c docSign=new XC_DocumentSignature__c();
            docSign.XC_Order__c=order.id;
            docSign.XC_SignerId__c=order.id;
            docSign.XC_Status__c='test';
            docSign.XC_Step__c='4';
            docSign.XC_DossierId__c='112';
            insert docSign;

            XC_DocumentType__c docType = new XC_DocumentType__c();
            docType.Category__c ='SF_CONTRACT_SIGNED';
            docType.XC_Configuration__c = order.Id;
            insert docType;

        Test.stopTest();
    }


    @isTest
    static void test_onAfterUpdateOrder() {

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_interfaceName__c = 'FileDelete';
        ic.name = 'FileDelete';
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'asd';
        insert ic;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_SendSMS_Mock());
        NE__Order__c order=[SELECT Id,XC_CommercialChange__c FROM NE__Order__c LIMIT 1][0];
        order.XC_CommercialChange__c = true;
        
        Test.startTest();
            update order;
        Test.stopTest();
    }
}