/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  20/05/2019 
* @description XC_LCC042_EmailQuotes_TEST – Test class for XC_LCC042_EmailQuotes
*/ 
@isTest
public with sharing class XC_LCC042_EmailQuotes_TEST {
    //Test Method getConfigurationNotificationResult1
    static testMethod void getConfigurationNotificationResult1(){
    //insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunity(1, true);
        insert opp;
        opp[0].StageName = 'In Progress';
        update opp;
        opp[0].StageName = Label.XC_CL_Opportunity_ClosedWon;
        update opp;
        String oppId = opp[0].Id; 
        XC_LCC042_EmailQuotes.resultWrapper rw = XC_LCC042_EmailQuotes.getConfigurationNotificationResult(oppId);
        System.assertEquals(false, rw.success);
    Test.stopTest();
    }

       //Test Method getConfigurationNotificationResult2
    static testMethod void getConfigurationNotificationResult2(){
    //insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunity(1, true);
        insert opp;
        opp[0].StageName = 'In Progress';
        update opp;
        opp[0].StageName = Label.XC_CL_Opportunity_ClosedWon;
        update opp;
        String oppId = opp[0].Id; 
        XC_LCC042_EmailQuotes.resultWrapper rw = XC_LCC042_EmailQuotes.getConfigurationNotificationResult(oppId);
        System.assertEquals(false, rw.success);
    Test.stopTest();
    }

           //Test Method getConfigurationNotificationResult3
    static testMethod void getConfigurationNotificationResult3(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
        List<NE__Order__c> orders = XC_DF_Order.createOrders(1, 'InOrder');
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunity(1, true);
        insert opp;
        String oppId = opp[0].Id; 
        orders[0].NE__OptyId__c = oppId; 
        //update orders; 
        XC_LCC042_EmailQuotes.resultWrapper rw = XC_LCC042_EmailQuotes.getConfigurationNotificationResult(oppId);
        System.assertEquals(false, rw.success);
    Test.stopTest();
    }

//Test Method getConfigurationNotificationResult6
    static testMethod void getConfigurationNotificationResult6(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        List<NE__Order__c> orderList = [SELECT Id, NE__OptyId__c FROM NE__Order__c];
        XC_LCC042_EmailQuotes.resultWrapper rw = XC_LCC042_EmailQuotes.getConfigurationNotificationResult(orderList[0].NE__OptyId__c);
        System.assertEquals(false, rw.success);
    Test.stopTest();
    }

     //Test Method getConfigurationNotificationResult5
    static testMethod void getConfigurationNotificationResult5(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        order.XC_Status__c = Label.XC_CL_Configuration_Draft;
        order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Configuration_RtQuote).getRecordTypeId();
        update order;
        List<NE__Order__c> orderList = [SELECT Id, NE__OptyId__c FROM NE__Order__c];
        XC_LCC042_EmailQuotes.resultWrapper rw = XC_LCC042_EmailQuotes.getConfigurationNotificationResult(orderList[0].NE__OptyId__c);
        System.assertEquals(true, rw.success);
    Test.stopTest();
    }

}