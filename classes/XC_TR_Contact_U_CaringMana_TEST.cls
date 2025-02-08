/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  10/06/2019 
* @description XC_TR_Contact_U_CaringMana_TEST – Test class for XC_TR_Contact_U_CaringManagement
*/ 
@isTest
public with sharing class XC_TR_Contact_U_CaringMana_TEST {
    //Test method manageCaseCreation
    static testMethod void manageCaseCreation(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> accts = XC_DF_Account.createResidentialAccounts(1);
        insert accts; 
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(accts); 
        insert cont; 
        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSettings = XC_UTIL_Case.retriveCaseTypeSettings( new List<String>{Label.XC_CL_PersonalInfoChangeWithAuth});
        Case caseSetting=XC_UTIL_Case.initCaseFromCaseSettings(mapCaseSettings.get(Label.XC_CL_PersonalInfoChangeWithAuth));
        caseSetting.ContactId=cont[0].Id;
        caseSetting.Status=Label.XC_CL_Case_Open;
        caseSetting.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Case').getRecordTypeId();
        insert caseSetting;

        List<NE__Billing_Profile__c> billingProfList = XC_DF_BillingProfile.createBillingProfile(1);
        List<XC_BillingProfileLineItem__c> billingProfLineItem = [SELECT Id, XC_BillingProfile__r.NE__Account__c FROM XC_BillingProfileLineItem__c LIMIT 1];
        billingProfLineItem[0].XC_BillToContactId__c=cont[0].Id;
        billingProfLineItem[0].XC_SoldToContactId__c=cont[0].Id;
        billingProfLineItem[0].XC_LegalEntity__c = Label.XC_CL_EndesaX;
        update billingProfLineItem;
        Test.setMock(HttpCalloutMock.class, new UpdateContact_Mock());

        cont[0].XC_ChangeApproved__c = false;
        cont[0].Phone ='699780658' ;
        cont[0].MobilePhone='699787658';
        cont[0].XC_HourToBeRecontacted__c='Morning';
        cont[0].LastName='MILENA GARCIA'; 
        cont[0].FirstName='LUCIA';    
        cont[0].XC_Nationality__c='Spanish';
        cont[0].XC_Preferredlanguageofcontact__c='Spanish';
        cont[0].Email='test@test.it';     
        update cont; 
   

        System.assertEquals(1, cont.size());
        Test.stopTest(); 
    }


        //Test method manageCaseCreation1
    static testMethod void manageCaseCreation1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> accts = XC_DF_Account.createResidentialAccounts(1);
        insert accts; 
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(accts);  
        cont[0].Email='test3@test.it';  
        insert cont; 
        cont[0].Email='test@test.it';      
        update cont; 
        System.assertEquals(1, cont.size());
        Test.stopTest(); 
    }

            //Test method manageCaseCreation2
    static testMethod void manageCaseCreation2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> accts = XC_DF_Account.createCondominiumAccounts(1);
        insert accts; 
        List<Contact> cont = XC_DF_Contact.createCondominiumContacts(accts);
        cont[0].FirstName='MARIA';
        cont[0].LastName='LOPEZ RODRIGUE';  
        cont[0].Email='test3@test.it';  
        cont[0].XC_Preferredlanguageofcontact__c = 'Italian';

        insert cont; 

        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSettings = XC_UTIL_Case.retriveCaseTypeSettings( new List<String>{Label.XC_CL_PersonalInfoChangeWithAuth});
        Case caseSetting=XC_UTIL_Case.initCaseFromCaseSettings(mapCaseSettings.get(Label.XC_CL_PersonalInfoChangeWithAuth));
        caseSetting.ContactId=cont[0].Id;
        caseSetting.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Case').getRecordTypeId();
        insert caseSetting;

       

        List<NE__Billing_Profile__c> billingProfList = XC_DF_BillingProfile.createBillingProfile(1);
        List<XC_BillingProfileLineItem__c> billingProfLineItem = [SELECT Id, XC_BillingProfile__r.NE__Account__c, XC_ZuoraId__c FROM XC_BillingProfileLineItem__c LIMIT 1];
        Zuora__CustomerAccount__c custAcc = new Zuora__CustomerAccount__c(XC_BillingProfLineItem_LookUp__c = billingProfLineItem[0].Id, Zuora__Account__c = accts[0].Id, Zuora__Zuora_Id__c = '4957589' );
        insert custAcc; 
       
        billingProfLineItem[0].XC_BillToContactId__c=cont[0].Id;
        billingProfLineItem[0].XC_SoldToContactId__c=cont[0].Id;
        billingProfLineItem[0].XC_LegalEntity__c = Label.XC_CL_EndesaX;
        billingProfLineItem[0].XC_CustomerAccount__c = custAcc.Id;
        update billingProfLineItem;

        Test.setMock(HttpCalloutMock.class, new UpdateContact_Mock());

        cont[0].XC_Dealignment_with_Zuora__c=true;  
        cont[0].XC_ChangeApproved__c = false;
        cont[0].Phone ='699780658' ;
        cont[0].MobilePhone='699787658';
        cont[0].XC_HourToBeRecontacted__c='Morning';
        cont[0].LastName='MILENA GARCIA'; 
        cont[0].FirstName='LUCIA';    
        cont[0].XC_Nationality__c='Spanish';
        cont[0].XC_Preferredlanguageofcontact__c='Spanish';
        cont[0].Email='test@test.it';         
        update cont; 
 
        System.assertEquals(1, cont.size());
        Test.stopTest(); 
    }

     //Test method checkCond1
    static testMethod void checkCond1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        
        List<Case> ca = XC_DF_Case.createCases(1);

         List<Account> accts = XC_DF_Account.createResidentialAccounts(1);
        insert accts; 
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(accts); 
        insert cont; 
        
        List<XC_CM_Case_Type_Setting__mdt> settingsWithAuth =new List<XC_CM_Case_Type_Setting__mdt>([SELECT XC_Sub_Cause__c, XC_Sub_Type__c, XC_Case_Reason__c 
                                                                                                     FROM XC_CM_Case_Type_Setting__mdt 
                                                                                                     LIMIT 1 ]);
        ca[0].AccountId = accts[0].Id; 
        ca[0].ContactId = cont[0].Id; 
        ca[0].Reason = settingsWithAuth[0].XC_Case_Reason__c;
        ca[0].Subcause__c = settingsWithAuth[0].XC_Sub_Cause__c ; 
        ca[0].XC_Subtype__c =settingsWithAuth[0].XC_Sub_Type__c ; 
        ca[0].Status= 'ESTA001';
      
        insert ca;
        
        /*List<Case> ca1 = XC_DF_Case.createCases(1);
        insert ca1; */

        System.debug('??TEST ' + ca );
        //update ca; 
        cont[0].Email='test3@test.it';     
        update cont;
       
        System.assertEquals(1, ca.size());
        Test.stopTest(); 
    }

    public without sharing class UpdateContact_Mock implements HttpCalloutMock{
    
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();

            if( req.getEndpoint().contains('/v1/accounts')) {               
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"accountId":"a0001", "accountNumber":"A01807438", "paymentMethodId":null, "processId":null, "reasons":null,"status":"OK", "success":true}');
                res.setStatusCode(200); 
            }
            return res;
        }
    }

}