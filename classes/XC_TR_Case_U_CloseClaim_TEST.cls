/**
* @author 
* @Creation 07/07/2022
* @description Test Class for XC_TR_Case_U_CloseClaim
*/

@isTest
private class XC_TR_Case_U_CloseClaim_TEST {
    
    @isTest
    static void Testcheckcase(){
        string Country = 'Italy';
        insert XC_DF_OneOrg.createOneOrg(Country);
        string legalEntity = 'EnelXMobilityItalia';
        string Segment = 'B2B';
        Id accountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        Id contactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        Id caseRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Complaint_Case').getRecordTypeId();

        test.startTest();

        Account acc = new Account();
        acc.RecordTypeID = accountRT;
        acc.Name = 'Test Account n.';
        acc.PrimaryEmail__c = 'test_con@email.com'; 
        acc.XC_DocumentCountry__c = Country;
        acc.IdentityType__c = 'NIF';
        acc.IdentityNumber__c = '84715536G';
        acc.XC_Account_Type__c='Utility';
        acc.XC_Country__c = Country;
        acc.XC_Segment__c = Segment;
        insert acc;
        Contact con = new Contact();
        con.RecordTypeID = contactRT;
        con.FirstName = 'Test contact';
        con.LastName = 'Doe';
        con.Email = 'test_condominium@email.com';  
        con.AccountId = acc.Id;
        con.XC_GiveDataToNew__c = 'Yes';
        con.XC_SkipTriggerIndividual__c = true; 
        con.XC_CountryLegalEntity__c = Country;
        con.XC_MainLegalEntity__c = legalEntity;
        insert con;

        Case nCase = new Case(
        ContactId = con.Id,
        AccountId = acc.Id,
        RecordTypeID = caseRT,
        origin = 'CAN008',
        XC_Result__c = 'RS003',
        Reason = 'XCMOT001',
        SubCause__c = 'ATCL015',
        Description = 'test',
        XC_LegalEntity__c = legalEntity,
        XC_Segment__c = Segment,
        Status = 'New');
        insert nCase;

        XC_DocumentURL__c doc = new XC_DocumentURL__c(XC_Url__c = 'google.it',XC_Case__c = nCase.Id);
        insert doc;

        nCase.XC_CreatorProfile__c = 'XC_ITA_CaringAgent';
        nCase.ParentId = null;
        nCase.Status = 'Closed';
        update nCase;
        List<XC_Customer_Interaction__c> ci = new List<XC_Customer_Interaction__c>([SELECT Id, CreatedDate, XC_CaseId__c FROM XC_Customer_Interaction__c WHERE XC_CaseId__c =: nCase.Id]);
        test.stopTest();
        System.assertEquals(1, ci.size());
    }
    
   
}