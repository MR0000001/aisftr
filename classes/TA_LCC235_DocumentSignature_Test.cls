/*
@CreatedBy      - Benjamin Geronimo (benjamindelina.geronimo@webresults.it), 2020/01/22
@Description    - Test class for TA_LCC235_DocumentSignature
*/
@isTest
public with sharing class TA_LCC235_DocumentSignature_Test 
{
    @testSetup 
    static void setup( ) 
    {
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

        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_CommercialVisit);
        wo[0].XC_Opportunity__c = opportunityToInsert.Id;
        insert wo;  

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
    }

    @isTest
    static void getDocumentSignatures_test( ) 
    {
        NE__Order__c order = [ SELECT Id FROM NE__Order__c LIMIT 1 ];

        Test.startTest( );
        TA_LCC235_DocumentSignature.getDocumentSignatures( order.Id );
        Test.stopTest( );
    }

    @isTest
    static void getInitInformation_test( ) 
    {
        WorkOrder wo = [ SELECT Id FROM WorkOrder LIMIT 1 ];

        Test.startTest( );
        TA_LCC235_DocumentSignature.getInitInformation( wo.Id );
        Test.stopTest( );
    }

}