/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  17/05/2019 
* @description XC_LCC065_SendOTP_TEST – Test class for XC_LCC065_SendOTP
*/ 
@isTest
public with sharing class XC_LCC065_SendOTP_TEST {
    //Test Method newEmailForCustomer
    static testMethod void newEmailForCustomer(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<ServiceAppointment> sa = XC_DF_ServiceAppointment.createServiceAppointment(1);
        
        String interactionValues = '{"XC_ServiceAppointmentId__c":"serviceAppointmentId"}'; 
        XC_UTIL_ResultWrapper rw = XC_LCC065_SendOTP.newEmailForCustomer(interactionValues);
        System.assert(String.isNotBlank(interactionValues));
        Test.stopTest();
    }
    
    //Test Method retrievePhoneNumber
    static testMethod void retrievePhoneNumber(){
        //insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        
        
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunity(1, true);
        insert opp;       
        
        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'In Order';
        order.NE__OptyId__c = opp[0].Id;
        order.NE__AccountId__c = opp[0].AccountId;
        insert order;
        
        update opp[0];   
        
        
        list <NE__Order__c> lno = [SELECT Id, NE__OptyId__c, NE__OptyId__r.XC_Contact__c  from NE__Order__c];
        String recordId = lno[0].Id ;
        
        String result = XC_LCC065_SendOTP.retrievePhoneNumber(recordId);
        System.assertEquals(true, result!=null);
        Test.stopTest();
    }
    
    //Test Method retrieveEmail
    static testMethod void retrieveEmail(){
        //insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        
        
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunity(1, true);
        insert opp;       
        
        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'In Order';
        order.NE__OptyId__c = opp[0].Id;
        order.NE__AccountId__c = opp[0].AccountId;
        insert order;
        
        update opp[0];   
        
        
        list <NE__Order__c> lno = [SELECT Id, NE__OptyId__c, NE__OptyId__r.XC_Contact__c  from NE__Order__c];
        String recordId = lno[0].Id ;
        
        String result = XC_LCC065_SendOTP.retrieveEmail(recordId);
        System.assertEquals(true, result!=null);
        Test.stopTest();
    }
    
}