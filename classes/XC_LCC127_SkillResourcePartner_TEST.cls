/**
* @author Valeria Martino - valeria.martino@nttdata.com
* @date Creation 5/07/2019
* @description  – XC_LCC127_SkillResourcePartner_TEST - Class test for XC_LCC127_SkillResourcePartner
*/

@isTest
public class XC_LCC127_SkillResourcePartner_TEST {

    @TestSetup 
    static void setup(){ 
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<Account> listAccount = XC_DF_Account.insertPartnerAccounts(1);
        //insert listAccount;
        List<ServiceResource> listServiceResource = XC_DF_ServiceResource.createServiceResourcesFromAccount(listAccount);
        ServiceResourceSkill serviceResourceSkill = XC_DF_ServiceResource.createServiceResourcesSkill(listServiceResource[0]);
        insert serviceResourceSkill;
    }
    
    static testMethod void retrievePartners() {     
        
        Test.startTest();
        XC_LCC127_SkillResourcePartner.retrievePartners();
        Test.stopTest();
        System.assertEquals(5, Limits.getDmlStatements());
    }
    
}