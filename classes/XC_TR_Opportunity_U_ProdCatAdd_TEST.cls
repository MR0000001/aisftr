/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_Opportunity_U_ProdCatAdd_TEST – Test Class for XC_TR_Opportunity_U_ProdCatAddress
*/ 

@isTest
public class XC_TR_Opportunity_U_ProdCatAdd_TEST {
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }

    static testMethod void onUpdateOpportunity() {
        insert XC_DF_Account.createResidentialAccounts(1);
        List<Account> accList = [SELECT Id FROM Account];
        XC_Address__c address = new XC_Address__c();
        insert XC_DF_Contact.createResidentialContacts(accList);
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        Test.startTest();
        try{
            insert XC_DF_Opportunity.createOpportunityWithVisit(contactList,address);
        }
        catch(Exception e){
             Boolean expectedExceptionThrown =  e.getMessage().contains(Label.XC_CL_ProductCategoryInterest_Address) ? true : false;
             System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }


}