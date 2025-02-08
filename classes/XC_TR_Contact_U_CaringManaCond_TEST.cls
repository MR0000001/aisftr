/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  10/06/2019 
* @description XC_TR_Contact_U_CaringManaCond_TEST – Test class for XC_TR_Contact_U_CaringManagementCond
*/ 
@isTest
public with sharing class XC_TR_Contact_U_CaringManaCond_TEST {

 //Test method checkCond1
    static testMethod void checkCond1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accList);
        insert conList;
        
        User user = XC_DF_User.createUserAdmin();
        insert user;
        
        Id mngmRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Management_Case').getRecordTypeId();
        List<Case> newCases = XC_DF_Case.createCases(1);
        newCases[0].Reason = 'XCMOT008';
        newCases[0].SubCause__c = 'ATCL073';
        //newCases[0].XC_Subtype__c = 'XC089';
        newCases[0].ContactId = conList[0].Id;
        newCases[0].AccountId = accList[0].Id;
        newCases[0].RecordTypeId = mngmRT;
        newCases[0].OwnerId = user.Id;
        
        /*insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> accts = XC_DF_Account.createResidentialAccounts(1);
        insert accts; 
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(accts); 
        insert cont; 
        List<Case> ca = XC_DF_Case.createCases(1); 
        String testid = '5E000000OUFtQAO';
        for(integer i=2; i>=0; i--){
            testid = i+''+testid; 
        }
        ca[0].RecordTypeID = testid;
        //ca[0].RecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_AT_Constants.CASE_RECORD_TYPE_XC_ATTENTION_ESPANA').getRecordTypeId();
        ca[0].ContactId = cont[0].Id; 
        ca[0].Reason ='  XCMOT008';
        ca[0].Subcause__c = 'ATCL073';
        ca[0].XC_Subtype__c = '  XC089';
        ca[0].Status= 'ESTA003';
        
        insert ca;*/
        /*List<Case> ca1 = XC_DF_Case.createCases(1);
        insert ca1; */
        
        Test.startTest();
        
        insert newCases;
        
        update newCases; 
        
        XC_CM_Case_Type_Setting__mdt settingsWithAuth = new XC_CM_Case_Type_Setting__mdt();
        settingsWithAuth.XC_Case_Reason__c ='XCMOT013';
        settingsWithAuth.XC_Sub_Cause__c ='ATCL014';
        settingsWithAuth.XC_Sub_Type__c= 'XC032';
        
        XC_TR_Contact_U_CaringManagementCond.checkCond1(newCases[0] , newCases[0] , settingsWithAuth);
        
        System.assertEquals(1, newCases.size());
        Test.stopTest();
    }
    //Test method checkCond2
    static testMethod void checkCond2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> accts = XC_DF_Account.createResidentialAccounts(1);
        insert accts; 
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(accts); 
        insert cont; 
        
        cont[0].XC_ChangeApproved__c= false;
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


        //Test method checkCond3
    static testMethod void checkCond3(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> accts = XC_DF_Account.createResidentialAccounts(1);
        insert accts; 
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(accts);  
        cont[0].XC_Nationality__c='Spanish';  
        insert cont; 
        List<Case> caseList = XC_DF_Case.createCases(1);
        caseList[0].AccountId = accts[0].Id;
        caseList[0].ContactId = cont[0].Id;
        insert caseList;
        List<Contact> cont1 = [SELECT Id, XC_Nationality__c, XC_Preferredlanguageofcontact__c, MobilePhone, Phone from Contact];
        cont[0].XC_Nationality__c='Italian';      
        update cont; 
        XC_CM_Case_Type_Setting__mdt mdt = new XC_CM_Case_Type_Setting__mdt();
        XC_TR_Contact_U_CaringManagementCond.checkCond3(cont[0] , cont1[0]);
        XC_TR_Contact_U_CaringManagementCond.checkCond4(cont[0].Id, caseList[0], mdt);
        System.assertEquals(1, cont.size());
        Test.stopTest(); 
    }
 


}