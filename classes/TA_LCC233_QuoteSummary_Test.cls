@isTest
public with sharing class TA_LCC233_QuoteSummary_Test {
    
    @testSetup
    static void setup() {
            LIst<XC_Address__c> add = XC_DF_Address.createAddress(1);
            insert add;
            List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_CommercialVisit);
            for (WorkOrder wo : woList){
                wo.XC_Address__c = add[0].Id;
            }
            insert woList;
            List<Opportunity> oppList = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
            oppList[0].XC_WorkOrder__c = woList[0].Id;
            insert oppList;
            woList[0].XC_Opportunity__c = oppList[0].Id;
            update woList;


            NE__Order__c order = new NE__Order__c();
            order.XC_Country__c = 'Spain';
            order.XC_Segment__c = 'B2C';
            order.XC_LegalEntity__c ='EndesaX';
            order.XC_FinancialInstitution__c ='institutionFinancial';
            order.XC_FinancialPracticeNumber__c ='testFinancial01';
            order.XC_FinancialPracticeStatus__c ='OK';
            order.NE__OptyId__c = oppList[0].id;
            Id opty = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId();
            order.RecordTypeId = opty;
            insert order;
            String param = '{"quoteToAccept":"' + order.Id + '"}';

            NE__OrderItem__c orderItem = new NE__OrderItem__c(NE__OrderId__c = order.id,
                                                            XC_BillingModel__c = 'One Shot',
                                                            NE__OneTimeFeeOv__c = 1,
                                                            NE__Qty__c = 1);
            insert orderItem;
    }

    @isTest
    static void getQuotes_Test() {
            Test.startTest();
            NE__Order__c order = [SELECT Id, RecordType.DeveloperName FROM NE__Order__c LIMIT 1];
            List<WorkOrder> woList = [SELECT Id, XC_Opportunity__c FROM WorkOrder];
            TA_LCC233_QuoteSummary.getQuotes(woList[0], order.RecordType.DeveloperName, 'test');
            Test.stopTest();
    }

    @isTest
    static void updateToPhaseEvaluation_Test() {
            Test.startTest();
            List<WorkOrder> woList = [SELECT Id, XC_Opportunity__c FROM WorkOrder];
            List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
            String parameters = '{"quoteToModify" : "' + orderList[0].Id + '", "actionModify" : "edit"}';
            TA_LCC233_QuoteSummary.updateToPhaseEvaluation(woList[0], parameters);
            Test.stopTest();
    }

    @isTest
    static void moveOrdersToMainOppty_Test() {
            Test.startTest();
            List<WorkOrder> woList = [select id,XC_Opportunity__c from WorkOrder];
            TA_LCC233_QuoteSummary.moveOrdersToMainOppty(woList[0]);
            Test.stopTest();
    }

    @isTest
    static void changeOrderRecordType_Test(){
            Test.startTest( );
            List<WorkOrder> woList = [select id,XC_Opportunity__c from WorkOrder];
            List<NE__Order__c> orderList = [SELECT id FROM NE__Order__c WHERE RecordType.Developername = 'Opty'];
            TA_LCC233_QuoteSummary.changeOrderRecordType(woList[0], orderList[0].Id);
            Test.stopTest( );
       
    }

    @isTest
    static void updateBit2winConfiguration_Test(){
            Test.startTest( );
            List<WorkOrder> woList = [select id,XC_Opportunity__c from WorkOrder];
            List<NE__Order__c> orderList = [SELECT id FROM NE__Order__c WHERE RecordType.Developername = 'Opty'];
            TA_LCC233_QuoteSummary.updateBit2winConfiguration(orderList[0].Id, 'Order', null);
            TA_LCC233_QuoteSummary.updateBit2winConfiguration(orderList[0].Id, 'Quote', null);
            Test.stopTest( );
       
    }

    @isTest
    static void updateQuote_Test(){
            Test.startTest( );
            List<WorkOrder> woList = [select id,XC_Opportunity__c, XC_Address__c from WorkOrder];
            List<NE__Order__c> orderList = [SELECT id FROM NE__Order__c LIMIT 1];
            NE__Order__c order = orderList[0];
            Id quote = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
            order.RecordTypeId = quote;  
            update order;
            TA_LCC233_QuoteSummary.updateQuote(woList[0], 'Rejected', null);        
            Test.stopTest( );
    }

    @isTest
    static void updateQuote_Test_2(){
            Test.startTest( );
            List<WorkOrder> woList = [select id,XC_Opportunity__c, XC_Address__c from WorkOrder];
            List<NE__Order__c> orderList = [SELECT id FROM NE__Order__c LIMIT 1];
            NE__Order__c order = orderList[0];
            Id quote = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
            order.RecordTypeId = quote;  
            update order;
            TA_LCC233_QuoteSummary.updateQuote(woList[0], 'Accepted', null);        
            Test.stopTest( );
    }

    @isTest
    static void manageOptyToQuote_Test(){
            Test.startTest( );
            Map<String, Object> mapOrder = new Map<String,Object>{'recordTypeOrder' => 'Quote'};
            XC_REST_Order_U.WrapperRes wr = new XC_REST_Order_U.WrapperRes();       
            TA_LCC233_QuoteSummary.manageOptyToQuote(mapOrder, wr, 'Quote');        
            Test.stopTest( );
    }
}