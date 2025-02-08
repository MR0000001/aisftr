/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_LCC084_AssignToBackOffice_TEST – Test Class for XC_LCC084_AssignToBackOffice
*/ 

@isTest
public class XC_TR_Opportunity_U_CheckCV_TEST {

     @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }

    static testMethod void onInsertOpportunity() {
        insert XC_DF_Account.createResidentialAccounts(1);
        List<Account> accList = [SELECT Id FROM Account];
        insert XC_DF_Address.createAddress(accList);
        List<XC_Address__c> listAddress = [SELECT Id FROM XC_Address__c];
        insert XC_DF_Contact.createResidentialContacts(accList);
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        Test.startTest();
        insert XC_DF_Opportunity.createOpportunityWithVisit(contactList,listAddress[0]);
        List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
        System.assertEquals(oppinserted.size() , 1);
        Test.stopTest();
    }


}