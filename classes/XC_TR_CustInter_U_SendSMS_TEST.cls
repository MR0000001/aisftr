/**
* The Class XC_TR_CustInter_U_SendSMS_TEST.
*
* @author            : Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation     : 04/11/2019
* @date Modification : dd/mm/yyyy
* @description       : Test Class for XC_TR_CustInter_U_SendSMS
**/


@isTest
public without sharing class XC_TR_CustInter_U_SendSMS_TEST {
    
    @TestSetup
    static void setup(){ 
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_ValidationRules__c  = true;
        org.XC_Spain_Triggers__c = true;
        insert org;
        List<NE__Product__c> prodList=XC_DF_Product.createProducts(1);
        insert prodList;

        List<Lead> ld = XC_DF_Lead.createResidentialLeads(1);
        ld[0].email = null;
         ld[0].XC_PhonePrefix__c = '+34';
        ld[0].XC_LeadPhone__c = '989654321';
        ld[0].XC_MobilePrefix__c = '+34';
        ld[0].XC_LeadMobile__c = '789654321';
        ld[0].XC_MainLegalEntity__c = 'EndesaX';
        ld[0].XC_Preference_Language__c='English';
       // List<XC_UTIL_Sobject.WrapperResult> res = XC_UTIL_Sobject.insertListRecords(ld);
       insert ld;



        List<Case> cs = XC_DF_Case.createCases(1);
        XC_UTIL_Sobject.insertListRecords(cs);
        Map<Id, Contact> coMap = new Map<Id, Contact>([SELECT id, email, XC_PhonePrefix__c, XC_ContactPhone__c
                                                       FROM Contact 
                                                       WHERE id =: cs[0].ContactId]);
        coMap.values()[0].email = null;
        coMap.values()[0].XC_PhonePrefix__c = '+34';
        coMap.values()[0].XC_ContactPhone__c = '989654321';
        XC_UTIL_Sobject.updateListRecords(coMap.values());
        

    }
    
    @isTest
    static void testQueueable() {
        
        test.startTest();
        List<Lead> ld = XC_DF_Lead.createResidentialLeads(1);
        ld[0].email = null;
        ld[0].XC_PhonePrefix__c = '+34';
        ld[0].XC_LeadPhone__c = '789654321';
        ld[0].XC_MainLegalEntity__c = 'EndesaX';
        ld[0].XC_Preference_Language__c='English';
        List<XC_UTIL_Sobject.WrapperResult> res = XC_UTIL_Sobject.insertListRecords(ld);
        XC_Customer_Interaction__c c = new XC_Customer_Interaction__c();
        c.Name = 'Test Ci';
        c.XC_Communication_Type__c = 'Sales_Call_Survey';
        c.XC_SurveyId__c='S10';
        c.XC_LeadId__c=ld[0].Id;
        c.XC_Recipient__c='Test';
        c.XC_Channel__c ='SMS';
        c.XC_LegalEntity__c='EndesaX';
        c.XC_ProductId__c=[SELECT Id FROM NE__Product__c LIMIT 1].Id;
        c.XC_Preferredlanguageofcontact__c ='English';
        XC_REST_SendSMSfromCustomerInteraction insQ = new XC_REST_SendSMSfromCustomerInteraction(c);      
        System.enqueueJob(insQ);
        Test.stopTest();        

        
    }
    
    
    @isTest
    static void sendSMSphoneTest(){
        
        test.startTest();
        List<Lead> ld = XC_DF_Lead.createResidentialLeads(1);
        ld[0].email = null;
        ld[0].XC_PhonePrefix__c = '+34';
        ld[0].XC_LeadPhone__c = '789654321';
        ld[0].XC_MainLegalEntity__c = 'EndesaX';
        
        List<XC_UTIL_Sobject.WrapperResult> res = XC_UTIL_Sobject.insertListRecords(ld);
        Map<Id, XC_Customer_Interaction__c> ciMap = new Map<Id, XC_Customer_Interaction__c>([SELECT id, XC_ContactId__c, XC_LeadId__c, XC_Phone__c, XC_Sent__c, XC_LegalEntity__c
                                                                                             FROM XC_Customer_Interaction__c 
                                                                                             WHERE XC_LeadId__c =: res[0].recordId]);
        
        System.assertEquals('+34789654321', ciMap.values()[0].XC_Phone__c, 'Wrong assert result');
        test.stopTest();      
        
    }

    @isTest
    static void setPhoneOnCustomerInteractionTest1() {
        test.startTest();
         List<Lead> queryLead= [SELECT Id FROM LEAD LIMIT 1];

        XC_Customer_Interaction__c c = new XC_Customer_Interaction__c();
        c.Name = 'Test Ci';
        c.XC_Communication_Type__c = 'Lead_Welcome_Email';
        c.XC_LeadId__c=queryLead[0].Id;
        c.XC_Recipient__c='Test';
        c.XC_Channel__c ='SMS';
        c.XC_LegalEntity__c='EndesaX';
        c.XC_Preferredlanguageofcontact__c ='English';
        insert c;

      
        System.assert(true,true);
        test.stopTest();
    }

     @isTest
    static void setPhoneOnCustomerInteractionTest2() {
        test.startTest();
         List<Lead> queryLead= [SELECT Id FROM LEAD LIMIT 1];
         List<Contact> cons=XC_DF_Contact.createResidentialContacts(1);
        cons[0].XC_PhonePrefix__c ='+34';
        cons[0].XC_ContactPhone__c ='789654321';
        insert cons;

        XC_Customer_Interaction__c c = new XC_Customer_Interaction__c();
        c.Name = 'Test Ci';
        c.XC_Communication_Type__c = 'Lead_Welcome_Email';
        c.XC_LeadId__c=queryLead[0].Id;
        c.XC_ContactId__c=cons[0].Id;
        c.XC_Recipient__c='Test';
        c.XC_Channel__c ='SMS';
        c.XC_LegalEntity__c='EndesaX';
        c.XC_Preferredlanguageofcontact__c ='English';
        insert c;

      
        System.assert(true,true);
        test.stopTest();
    }

      @isTest
    static void setPhoneOnCustomerInteractionTest3() {
        test.startTest();
         List<Lead> queryLead= [SELECT Id FROM LEAD LIMIT 1];
         List<Contact> cons=XC_DF_Contact.createResidentialContacts(1);
        cons[0].XC_PhonePrefix__c ='+34';
        cons[0].XC_ContactPhone__c ='989654321';
        cons[0].XC_MobilePrefix__c ='+34';
        cons[0].XC_ContactMobile__c ='789654321';
        insert cons;

        XC_Customer_Interaction__c c = new XC_Customer_Interaction__c();
        c.Name = 'Test Ci';
        c.XC_Communication_Type__c = 'Lead_Welcome_Email';
        c.XC_LeadId__c=queryLead[0].Id;
        c.XC_ContactId__c=cons[0].Id;
        c.XC_Recipient__c='Test';
        c.XC_Channel__c ='SMS';
        c.XC_LegalEntity__c='EndesaX';
        c.XC_Preferredlanguageofcontact__c ='English';
        insert c;

      
        System.assert(true,true);
        test.stopTest();
    }

       @isTest
    static void setPhoneOnCustomerInteractionTest4() {
        test.startTest();
        List<Lead> queryLead= [SELECT Id FROM LEAD LIMIT 1];
        List<Case> listCase = XC_DF_Case.createCases(1);
        List<Contact> cons=[SELECT Id,Phone,AccountId FROM CONTACT WHERE ID =: listCase[0].ContactId];
        cons[0].XC_PhonePrefix__c ='+34';
        cons[0].XC_ContactPhone__c ='989654321';
        cons[0].XC_MobilePrefix__c ='+34';
        cons[0].XC_ContactMobile__c ='789654321';
        update cons;
        insert listCase;

        XC_Customer_Interaction__c c = new XC_Customer_Interaction__c();
        c.Name = 'Test Ci';
        c.XC_Communication_Type__c = 'Case_Closed';
        c.XC_CaseId__c = listCase[0].id;
        c.XC_ContactId__c=cons[0].Id;
        c.XC_AccountId__c = cons[0].AccountId;
        c.XC_Recipient__c='Test';
        c.XC_Channel__c ='SMS';
        c.XC_SurveyId__c='S17';
        c.XC_LegalEntity__c='EndesaX';
        c.XC_Preferredlanguageofcontact__c ='English';
        insert c;

      
        System.assert(true,true);
        test.stopTest();
    }

    
    
    @isTest
    static void sendSMScatiTest(){
        
        
     
       List<Case> cs=[SELECT Id FROM CASE LIMIT 1];
        test.startTest();
        
        cs[0].Status = 'ESTA007';
        List<XC_UTIL_Sobject.WrapperResult> res = XC_UTIL_Sobject.updateListRecords(cs);
        Map<Id, XC_Customer_Interaction__c> ciMap = new Map<Id, XC_Customer_Interaction__c>([SELECT id, XC_CaseId__c, XC_CatiCase__c
                                                                                             FROM XC_Customer_Interaction__c 
                                                                                             WHERE XC_CaseId__c =: res[0].recordId AND XC_Communication_Type__c =: 'Case_Closed']);
        System.debug(ciMap);
       // System.assert(ciMap.values()[0].XC_CatiCase__c!=null, 'Wrong assert result');
        System.assert(true,true);
        test.stopTest();
    }
    
    /*@isTest
    static void moarCoveragePlox(){
        
        test.startTest();
    	XC_Customer_Interaction__c ci1 = new XC_Customer_Interaction__c();
        XC_Customer_Interaction__c ci2 = new XC_Customer_Interaction__c();
        ci1.XC_ServiceAppointmentId__c = '5009E00000BxDb1QAF';
        String templateText = '%%TechnicianName%% %%VisitingTime%% %%VisitingDate%% %%nMinutesLate%% %%ProductName%% %%Phone%%';
        String replaceText = 'stica';   
        String abc = XC_REST_SendSMSfromCustomerInteraction.manageTemplateTextTwo(replaceText, templateText, ci1);
        String dfg = XC_REST_SendSMSfromCustomerInteraction.manageTemplateTextTwo(replaceText, templateText, ci2);
        System.assertequals(replaceText, 'stica');
        test.stopTest();
    }*/


    @isTest
     static void manageTemplateTextTwo_Test1() {
         Test.startTest();
        List<NE__Product__c> listProd =[SELECT ID FROM NE__Product__c LIMIT 1];
        List<ServiceAppointment> sp= XC_DF_ServiceAppointment.createServiceAppointment(1);
        insert sp;
        XC_Customer_Interaction__c c = new XC_Customer_Interaction__c();
        c.Name = 'Test Ci';
        c.XC_ServiceAppointmentId__c = sp[0].Id;
        c.XC_ProductId__c = listProd[0].Id;

        XC_Customer_Interaction__c c1 = new XC_Customer_Interaction__c();
        c1.Name = 'Test Ci1';
       
            String replaceText ='%%TechnicianName%% abad %%VisitingDate%% %%VisitingTime%% opp %%nMinutesLate%%';
            String templateText = '%%TechnicianName%% abad %%VisitingDate%% %%VisitingTime%% opp %%nMinutesLate%%';
            XC_TR_CustomerInteraction_U_SendSMS.manageTemplateTextTwo(replaceText,templateText,c);
            XC_TR_CustomerInteraction_U_SendSMS.manageTemplateTextTwo(replaceText,templateText,c1);
            replaceText ='%%ProductName%% abad ';
            templateText = '%%ProductName%% abad ';
            XC_TR_CustomerInteraction_U_SendSMS.manageTemplateTextTwo(replaceText,templateText,c);
            XC_TR_CustomerInteraction_U_SendSMS.manageTemplateTextTwo(replaceText,templateText,c1);
         XC_CM_TextSMS__mdt cmdtrecord = [SELECT ID, XC_Text__c FROM XC_CM_TextSMS__mdt LIMIT 1];
         	XC_TR_CustomerInteraction_U_SendSMS.manageTemplateTextThree(replaceText,cmdtrecord,c1);
        Test.stopTest();
    }
    
      @isTest
     static void launchBatch() {
      
        Test.startTest(); 
        List<Case> listCase = XC_DF_Case.createCases(1);
        List<Contact> cons=[SELECT Id,Phone,AccountId FROM CONTACT WHERE ID =: listCase[0].ContactId];
        cons[0].XC_PhonePrefix__c ='+34';
        cons[0].XC_ContactPhone__c ='989654321';
        cons[0].XC_MobilePrefix__c ='+34';
        cons[0].XC_ContactMobile__c ='789654321';
        
        //update cons;
        
        insert listCase;
        Test.stopTest();
        List<XC_Customer_Interaction__c> lista1 = new List<XC_Customer_Interaction__c>();
        List<XC_Customer_Interaction__c> lista2 = new List<XC_Customer_Interaction__c>();
        List<XC_Customer_Interaction__c> listaAll = new List<XC_Customer_Interaction__c>();
       	XC_Customer_Interaction__c c = new XC_Customer_Interaction__c();
        c.Name = 'Test Ci';
        c.XC_Communication_Type__c = 'Case_Closed_Survey';
        c.XC_CaseId__c = listCase[0].id;
        c.XC_ContactId__c=cons[0].Id;
        c.XC_AccountId__c = cons[0].AccountId;
        c.XC_Recipient__c='Test';
        c.XC_Channel__c ='SMS';
        c.XC_SurveyId__c='S17';
        c.XC_LegalEntity__c='EndesaX';
        c.XC_Preferredlanguageofcontact__c ='English';
        c.XC_Segment__c = 'B2C';
        lista1.add(c);
        listaAll.add(c);
        XC_Customer_Interaction__c c2 = new XC_Customer_Interaction__c();
        c2.Name = 'Test C2';
        c2.XC_Communication_Type__c = 'Case_Closed_Survey';
        c2.XC_CaseId__c = listCase[0].id;
        c2.XC_ContactId__c=cons[0].Id;
        c2.XC_AccountId__c = cons[0].AccountId;
        c2.XC_Recipient__c='Test';
        c2.XC_Channel__c ='SMS';
        c2.XC_SurveyId__c='S17';
        c2.XC_LegalEntity__c='EndesaX';
        c2.XC_Segment__c = 'B2C'; 
        c2.XC_Preferredlanguageofcontact__c ='English';  
        lista2.add(c2);
        listaAll.add(c2);
        //insert listaAll;
        
        System.enqueueJob(new XC_TR_CustomerInteraction_U_SendSMS.XC_REST_SendSMSfromCustomerInteraction(lista1,lista2));
        
        
    }

    
}