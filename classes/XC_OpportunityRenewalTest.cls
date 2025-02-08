/*--------------------------------------------------
* This test class is used for XC_OpportunityRenewal trigger
* -------------------------------------------------------*/
@isTest
public class XC_OpportunityRenewalTest {
    
    @isTest
    private static void fetchRecord() {
        Account accountToInsert = new Account();
        accountToInsert.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global B2B').getRecordTypeId();
        accountToInsert.XC_FirstName__c = 'Test';
        accountToInsert.XC_LastName__c = 'Name';
        accountToInsert.PrimaryEmail__c = 'testsample@email.com';
        accountToInsert.XC_DocumentCountry__c = 'Italy';
        accountToInsert.IdentityType__c='Passport';
        accountToInsert.IdentityNumber__c='3526173'+ (Math.random()*Math.random());
        accountToInsert.XC_CommercialCode__c='AAA123';
        accountToInsert.XC_InternalCommercialCode__c='BBB123';
        accountToInsert.name = 'Test Account n ' + (Math.random()*Math.random());
        insert accountToInsert;
        Contact con = new Contact();
        con.Email = 'sample.emil@gmail.com';
        con.RecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Global B2B').getRecordTypeId();
        con.XC_Preferredlanguageofcontact__c = 'Spanish';
        con.Country__c = 'Italy';
        con.XC_GiveDataToNew__c = 'Yes';
        con.LastName = 'Ratish';
        con.FirstName = 'Ravish';
        con.AccountId = accountToInsert.Id;
        con.XC_CountryLegalEntity__c = 'Italy';
        con.XC_SkipTriggerIndividual__c = true; 
        con.XC_MainLegalEntity__c = 'EnelXMSP';
        insert con;
        Opportunity opp = new Opportunity();
        opp.AccountId = accountToInsert.Id;
        opp.XC_Contact__c = con.Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'Draft';
        opp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B Opportunity Italy').getRecordTypeId();
        opp.CloseDate = Date.today().addDays(30);
        opp.XC_LegalEntity__c = 'EnelXMSP';
        insert opp;
        Opportunity oppty1 = opp.clone();
        insert oppty1;
        System.debug('Oppppp is:'+opp);
    }  
}