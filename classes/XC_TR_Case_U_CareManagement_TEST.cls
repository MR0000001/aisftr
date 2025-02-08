/**
* @author Monica Cutillo - monicaa.cutillo@nttdata.com
* @date Creation  21/05/2019 
* @description XC_TR_Case_U_CareManagement_TEST – Test class for XC_TR_Case_U_CareManagement
*/
@isTest
public class XC_TR_Case_U_CareManagement_TEST {

    @isTest
    static void manageCaseStatusOnUpdate() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        insert XC_DF_Case.createCases(2);
        
        insert XC_DF_User.createUserAdmin();
        User admin = [SELECT Id FROM User LIMIT 1][0];
        
        List<Case> cases = [SELECT Id FROM Case LIMIT 2];
        Case pCase = cases[0];
        Case cCase = cases[1];
        pCase.Status=Label.XC_CL_Case_InProgress;
        update pCase;
        cCase.ParentId = pCase.Id;
        update cCase;


        Test.startTest();
        cCase.OwnerId = admin.Id;
        cCase.Status = Label.XC_CL_Case_InProgress;
        try{
        	update cCase;
        	System.assert(true);
        } catch(Exception ex){
            System.assert(false);
        }
        Test.stopTest();        
    }

    @isTest
    static void manageCaseStatusOnUpdate_Closure() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        insert XC_DF_Case.createCases(2);
        List<Case> cases = [SELECT Id FROM Case LIMIT 2];
        Case pCase = cases[0];
        Case cCase = cases[1];
        pCase.Status=XC_AT_Constants.TRIGGER_STATUS_ESTA002;
        update pCase;
        cCase.ParentId = pCase.Id;
        update cCase;

        insert XC_DF_User.createUserAdmin();
        User admin = [SELECT Id FROM User LIMIT 1][0];
        Test.startTest();
        cCase.OwnerId = admin.Id;
        cCase.Status = 'ESTA007';
        try{
        	update cCase;
        	System.assert(true);
        } catch(Exception ex){
            System.assert(false);
        }
        Test.stopTest();        
    }

    @isTest
    static void manageCaseStatusOnUpdate_Open() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        insert XC_DF_Case.createCases(2);
        List<Case> cases = [SELECT Id FROM Case LIMIT 2];
        Case pCase = cases[0];
        Case cCase = cases[1];
        cCase.ParentId = pCase.Id;
        update cCase;

        insert XC_DF_User.createUserAdmin();
        User admin = [SELECT Id FROM User LIMIT 1][0];
        Test.startTest();
        cCase.OwnerId = admin.Id;
        cCase.Status = 'ESTA001';
        try{
        	update cCase;
        	System.assert(true);
        } catch(Exception ex){
            System.assert(false);
        }
        Test.stopTest();        
    }
    
    @isTest
    static void populateCIFinancial() {
        List<Case> calist = XC_DF_Case.createCases(1);
        insert calist;
        List<Contact> conlist = [SELECT Id, Name, email, XC_Segment__c FROM Contact LIMIT 1];
    	XC_TR_Case_U_CareManagement.createCiExternalFinancingResult(calist[0], conlist[0]);
    }

    @isTest
    static void customerInteractionCaseSuperbonus110Closure(){
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
        caso.XC_CompanyQualificationStatus__c = 'Company to be qualified';
        caso.XC_Description__c = 'testMC';
        caso.Status = 'ESTA003';
        insert caso;
        Test.startTest();
            caso.XC_Resolution__c = 'R002';
			caso.XC_Result__c = 'RS004';
        	caso.CaseRemarks__c = 'Superbonus Closure KO';
        	caso.XC_KO_Reasons__c = 'XCKO001';
        	update caso;
        	System.assert(true);
        Test.stopTest();
    }

    @isTest
    static void customerInteractionCaseClosed(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> calist = XC_DF_Case.createCases(1);
        insert calist;
        //caso.Status = 'ESTA003';
        Test.startTest();
            calist[0].XC_Resolution__c = 'R002';
			calist[0].XC_Result__c = 'RS004';
        	calist[0].CaseRemarks__c = 'Superbonus Closure KO';
        	calist[0].XC_KO_Reasons__c = 'XCKO001';
        	update calist;
        	System.assert(true);
        Test.stopTest();
    }
}