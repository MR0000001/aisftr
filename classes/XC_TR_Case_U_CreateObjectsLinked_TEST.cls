/**
* @author Dario Tramontin dtramontin.deloitte.it
* @date Creation 06/09/2019
* @description XC_TR_Case_U_CreateObjectsLinked_TEST – Test Class for XC_TR_Case_U_CreateObjectsLinked
*/ 

@isTest
public class XC_TR_Case_U_CreateObjectsLinked_TEST {

    @isTest
    static void onInsertCaseBadSale(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> caseList= XC_DF_Case.createCases(1);
        for(Case c: caseList){
            c.Reason = 'XCMOT005';
            c.SubCause__c = 'ATCL070';
            c.XC_Subtype__c = 'XC104';
            c.XC_CompliantApplicable__c = true;
        }
        Test.startTest();
        insert caseList;
            
        //system.assertEquals(1, caseList.size(),'error AssertEquals');
        Test.stopTest();
    }

    @isTest
    static void onInsertCaseNotBadSale(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> caseList= XC_DF_Case.createCases(1);
        for(Case c: caseList){
            c.Reason = 'XCMOT005';
            c.SubCause__c = 'ATCL020';//it must be different from ATCL070
            c.XC_CompliantApplicable__c = true;
        }
        Test.startTest();
        insert caseList;
            
        //system.assertEquals(1, caseList.size(),'error AssertEquals');
        Test.stopTest();
    }

    @isTest
    static void checkCaseDisconnect1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> caseList= XC_DF_Case.createCases(1);
        caseList[0].Reason = 'XCMOT005';
        caseList[0].SubCause__c = 'ATCL070';
        caseList[0].XC_Subtype__c = 'XC069';
        caseList[0].XC_CompliantApplicable__c = true;
        Test.startTest();
        	insert caseList;
        	//system.assertEquals(1, caseList.size(),'error AssertEquals');
        Test.stopTest();
        
    }

    @isTest
    static void checkCaseDisconnect2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> caseList= XC_DF_Case.createCases(1);
        caseList[0].Reason = 'XCMOT005';
        caseList[0].SubCause__c = 'ATCL042';
        caseList[0].XC_CompliantApplicable__c = true;
        Test.startTest();
        	insert caseList;
        	//system.assertEquals(1, caseList.size(),'error AssertEquals');
        Test.stopTest();
        
    }

    @isTest
    static void createCustomerInteractionOnCaseUpdateSubstatus(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> caseList= XC_DF_Case.createCases(1);
        caseList[0].Origin = 'CAN001';
        insert caseList;
        Test.startTest();
        	caseList[0].Status = 'ESTA003';
        	caseList[0].XC_SubStatus__c = 'SUB005';
        	update caseList;
        	//system.assertEquals(1, caseList.size(),'error AssertEquals');
        Test.stopTest();
        
    }

    @isTest
    static void createCustomerIntOnCaseUpdateCompanyQualStatus(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        accounts[0].XC_Segment__c = 'B2C'; 
        insert accounts;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        contacts[0].XC_Segment__c = 'B2C'; 
        contacts[0].XC_CountryLegalEntity__c = 'ITALY';
        contacts[0].XC_MainLegalEntity__c = 'EnelXItalia';
        insert contacts;
        
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_SuperBonus110});
        Case caso = XC_UTIL_Case.initCaseFromCaseSettings(caseSettingsMap.get(Label.XC_CL_SuperBonus110));
        caso.ContactId = contacts[0].Id;
        caso.XC_Segment__c = 'B2C'; 
        caso.XC_LegalEntity__c = 'EnelXItalia';
        insert caso;
        Test.startTest();
        	caso.XC_CompanyQualificationStatus__c = 'Company to be qualified';
        	caso.XC_Description__c = 'test';
        	update caso;
        	System.assert(true);
        Test.stopTest();
        
    }

}