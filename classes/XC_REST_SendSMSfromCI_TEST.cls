/**
* @author Andrea Di Cicco
* @date Creation  10/02/2020
* @description Test class 
*/

@isTest
public class XC_REST_SendSMSfromCI_TEST {
    
    static testMethod void execute(){

        NE__Product__c prod = XC_DF_Product.createProducts(1)[0];
        insert prod;
        XC_Customer_Interaction__c qc = new XC_Customer_Interaction__c();
        qc.XC_LegalEntity__c = 'EndesaX';
        qc.XC_Segment__c = 'B2C';
        qc.XC_Communication_Type__c ='Opportunity_QuoteCreated';
        qc.XC_Preferredlanguageofcontact__c ='Spanish';
        qc.XC_ProductId__c= prod.Id;
        XC_REST_SendSMSfromCustomerInteraction sendSMS = new XC_REST_SendSMSfromCustomerInteraction( qc);
        
        Test.setMock(HttpCalloutMock.class, new XC_LCC167_NewAddressXygo_MOCK());
        Test.startTest();
        System.enqueueJob(sendSMS);
        Test.stopTest();
    }

    static testMethod void execute2(){
        XC_Customer_Interaction__c qc = new XC_Customer_Interaction__c();
        qc.XC_LegalEntity__c = 'EndesaX';
        qc.XC_Segment__c = 'B2C';
        qc.XC_Communication_Type__c ='WorkOrder_ActivityReport';
        qc.XC_Preferredlanguageofcontact__c ='Catalan';
        XC_REST_SendSMSfromCustomerInteraction sendSMS = new XC_REST_SendSMSfromCustomerInteraction( qc);
        
        
        Test.setMock(HttpCalloutMock.class, new XC_LCC167_NewAddressXygo_MOCK());
        Test.startTest();
        System.enqueueJob(sendSMS);
        Test.stopTest();
    }
    
    static testMethod void execute3(){
        List<Case> c = XC_DF_Case.createCases(1);
        insert c;
        
        XC_Customer_Interaction__c qc = new XC_Customer_Interaction__c();
        qc.XC_LegalEntity__c = 'EndesaX';
        qc.XC_Segment__c = 'B2C';
        qc.XC_Communication_Type__c ='Case_Created';
        qc.XC_Preferredlanguageofcontact__c ='Spanish';
        qc.XC_CaseId__c = c.get(0).id;
        XC_REST_SendSMSfromCustomerInteraction sendSMS = new XC_REST_SendSMSfromCustomerInteraction( qc);
        
        
        
        Test.setMock(HttpCalloutMock.class, new XC_LCC167_NewAddressXygo_MOCK());
        Test.startTest();
        System.enqueueJob(sendSMS);
        Test.stopTest();
    }
    static testMethod void execute4(){
        List<Case> c = XC_DF_Case.createCases(1);
        insert c;
        
        XC_Customer_Interaction__c qc = new XC_Customer_Interaction__c();
        
        qc.XC_Communication_Type__c ='WorkOrder_QuoteCreated_Survey';
        qc.XC_Preferredlanguageofcontact__c ='Spanish';
        qc.XC_LegalEntity__c = 'EndesaX';
        qc.XC_Segment__c = 'B2C';
        qc.XC_CaseId__c = c.get(0).id;
        XC_REST_SendSMSfromCustomerInteraction sendSMS = new XC_REST_SendSMSfromCustomerInteraction( qc);
        
        
        
        Test.setMock(HttpCalloutMock.class, new XC_LCC167_NewAddressXygo_MOCK());
        Test.startTest();
        System.enqueueJob(sendSMS);
        Test.stopTest();
    }
    static testMethod void execute5(){
        List<Case> c = XC_DF_Case.createCases(1);
        insert c;
        
        XC_Customer_Interaction__c qc = new XC_Customer_Interaction__c();
        qc.XC_LegalEntity__c = 'EndesaX';
        qc.XC_Segment__c = 'B2C';
        qc.XC_CaseId__c = c.get(0).id;
        XC_REST_SendSMSfromCustomerInteraction sendSMS = new XC_REST_SendSMSfromCustomerInteraction( qc);
        
        
        
        Test.setMock(HttpCalloutMock.class, new XC_LCC167_NewAddressXygo_MOCK());
        Test.startTest();
        System.enqueueJob(sendSMS);
        Test.stopTest();
    }
    static testMethod void execute6(){
        List<Case> c = XC_DF_Case.createCases(1);
        insert c;
        
        XC_Customer_Interaction__c qc = new XC_Customer_Interaction__c();
        qc.XC_LegalEntity__c = 'EndesaX';
        qc.XC_Segment__c = 'B2C';
        qc.XC_Communication_Type__c ='WorkOrder_ActivityReport_Survey';
        qc.XC_Preferredlanguageofcontact__c ='Catalan';
        qc.XC_CaseId__c = c.get(0).id;
        XC_REST_SendSMSfromCustomerInteraction sendSMS = new XC_REST_SendSMSfromCustomerInteraction( qc);
        
        
        
        Test.setMock(HttpCalloutMock.class, new XC_LCC167_NewAddressXygo_MOCK());
        Test.startTest();
        System.enqueueJob(sendSMS);
        Test.stopTest();
    }
    
    static testMethod void manageTemplateTwoTest(){
	insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_Customer_Interaction__c qc = new XC_Customer_Interaction__c();
        qc.XC_LegalEntity__c = 'EndesaX';
        qc.XC_Segment__c = 'B2C';
        qc.XC_Communication_Type__c ='Opportunity_QuoteCreated';
        qc.XC_Preferredlanguageofcontact__c ='Spanish';     
        List<ServiceAppointment> sas = XC_DF_ServiceAppointment.createServiceAppointment(1);
        insert sas;
        qc.XC_ServiceAppointmentId__c = sas[0].id;
        insert qc;
        XC_REST_SendSMSfromCustomerInteraction.manageTemplateTextTwo('pippo', '%%TechnicianName%% %%ProductName%% %%Phone%%', qc);
    }

}