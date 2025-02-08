/**
* @author Roberta Porrega - roberta.porrega@nttdata.com  
* @date Creation 22/05/2019 
* @description XC_TR_Opp_U_AssignOpportunity_TEST – Test class 
*/
@isTest
private  class XC_TR_Opp_U_AssignOpportunity_TEST {
	   
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }
	@isTest
    static void onInsertOpportunity() {
        insert XC_DF_Account.createResidentialAccounts(1);
        List<Account> accList = [SELECT Id FROM Account];
        List<XC_Address__c> addList = XC_DF_Address.createAddress(accList);
        addList[0].XC_ElectricCUPS__c = 'ES0021000000396229WM0F';
        insert addList;
        List<XC_Address__c> listAddress = [SELECT Id FROM XC_Address__c];
        insert XC_DF_Contact.createResidentialContacts(accList);
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        Test.startTest();
        insert XC_DF_Opportunity.createOpportunityWithVisit(contactList,listAddress[0]);
        List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
        System.assertEquals(oppinserted.size() , 1);
        Test.stopTest();
    }
    @isTest
    static void onUpdateOpportunity() {
        insert XC_DF_Account.createResidentialAccounts(1);
        List<Account> accList = [SELECT Id FROM Account];
        List<XC_Address__c> addList = XC_DF_Address.createAddress(accList);
        addList[0].XC_GasCUPS__c = 'ES0220040008834874RW';
        insert addList;
        List<XC_Address__c> listAddress = [SELECT Id FROM XC_Address__c];
        insert XC_DF_Contact.createResidentialContacts(accList);
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        Test.startTest();
        insert XC_DF_Opportunity.createOpportunityWithVisit(contactList,listAddress[0]);
        List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
            for(Opportunity opp : oppinserted ){
                opp.XC_RunAssignmentsRules__c = true;
            }
        update oppinserted;
        System.assertEquals(oppinserted.size() , 1);
        Test.stopTest();
    }
    @isTest
    static void onUpdateOpportunity1() {
        insert XC_DF_Account.createResidentialAccounts(1);
        List<Account> accList = [SELECT Id FROM Account];
        insert XC_DF_Address.createAddress(accList);
        List<XC_Address__c> listAddress = [SELECT Id FROM XC_Address__c];
        insert XC_DF_Contact.createResidentialContacts(accList);
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        Test.startTest();
        insert XC_DF_Opportunity.createOpportunityWithoutVisit(contactList,listAddress[0]);
        List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
            for(Opportunity opp : oppinserted ){
                opp.XC_RunAssignmentsRules__c = true;
            }
        update oppinserted;
        System.assertEquals(oppinserted.size() , 1);
        Test.stopTest();
    }
}