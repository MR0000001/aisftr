@isTest
public class XC_TR_Config_U_QItemAmCheck_TEST {
    @testSetup
    static void makeData(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,false);
        insert oppList;
        
        test.startTest();
        oppList[0].XC_Segment__c = 'B2G';
        oppList[0].XC_IndustrialKPI__c = 'Work Contract';
        oppList[0].XC_LegalEntity__c = 'EnelSole';
        oppList[0].XC_Invited_Checkbox__c = false;
        oppList[0].StageName = 'Abandoned';    
        oppList[0].XC_BusinessLine__c = 'eCity';
        oppList[0].RecordTypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2G_Opportunity_Italy').getRecordTypeId();
        oppList[0].XC_ProductCategory__c = 'Optimize';
        oppList[0].XC_ProductCategoryOfInterest__c = 'Architectural Lighting';
        update oppList;
        

        List<Account> acc = [SELECT Id FROM Account];
        List<XC_Address__c> address = [SELECT Id FROM XC_Address__c];

        NE__Order__c o = XC_DF_Order.createOrderWithAddress('InOrder',address[0].Id,acc[0].Id,oppList[0].Id);

        NE__OrderItem__c item = [SELECT id FROM NE__OrderItem__c where NE__OrderId__c=: o.Id];
        delete item;

        o.RecordTypeId = Schema.getGlobalDescribe().get('NE__Order__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        o.XC_Segment__c = 'B2G';
        o.XC_LegalEntity__c = 'EnelSole';
        o.NE__OptyId__c = oppList[0].Id;
        o.XC_Status__c = 'Draft';
        update o;
        test.stopTest();

        List<NE__Order__c> order = new List<NE__Order__c>();
        order.add(o);

        NE__OrderItem__c configItem = XC_DF_OrderItem.createOrderItem(order[0]);
        configItem.RecordTypeId = Schema.getGlobalDescribe().get('NE__OrderItem__c').getDescribe().getRecordTypeInfosByDeveloperName().get('StanStandarddard').getRecordTypeId();
        //configItem.XC_Wbe__c = '';
        configItem.XC_BillingModel__c = 'Capex';
        //configItem.XC_PaymentMethod__c = 'Commodity Bill';
        configItem.NE__Account__c = acc[0].Id;
        configItem.XC_Installation_Address__c = address[0].Id;
        

        insert configItem;
    }

    @isTest
    static void updateQuoteWithCapexItems(){
        
        List<NE__Order__c> order = [select Id from NE__Order__c];
        Test.startTest();
            order[0].XC_Status__c = 'Notified to client';
            try{
                update order;
            }
            catch(Exception e){

            }

            NE__Order__c result = [SELECT Id,XC_Status__c FROM NE__Order__c WHERE Id =: order[0].Id];
            system.assertEquals('Notified to client',result.XC_Status__c);
            
        Test.stopTest();
    }
}