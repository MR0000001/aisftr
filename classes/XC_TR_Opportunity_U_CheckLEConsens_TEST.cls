/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date Creation 07/02/2020
 * @description XC_TR_Opportunity_U_CheckLEConsens_TEST - Test class for XC_TR_Opportunity_U_CheckLEConsens
**/

@isTest
private class XC_TR_Opportunity_U_CheckLEConsens_TEST {

    @isTest
    static void onInsertCustomSetting (){
        insert new OneOrg__c(Name='OneOrg (User)', XC_Spain_Triggers__c = true);
        Individual individual = new Individual(); 
        individual.LastName= 'Test';
        individual.XC_LECollectedThirdParties__c = ' ';
        insert individual;
        
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<XC_Address__c> listAddress = XC_DF_Address.createAddress(accList);
        insert listAddress;
        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(accList);
        contactList[0].IndividualId = individual.Id;
        contactList[0].XC_PrimaryContact__c = true;
        insert contactList;
        
        Test.startTest();
        List<Opportunity> listOppRes = XC_DF_Opportunity.createOpportunityWithVisit(contactList, listAddress[0]);
        insert listOppRes;
        System.assertNotEquals(listOppRes[0].Id, null);
        Test.stopTest();
    }

    @isTest
    static void onInsertWithCommVisit(){
        insert new OneOrg__c(Name='OneOrg (User)', XC_Spain_Triggers__c = true);
        Individual individual = new Individual(); 
        individual.LastName= 'Test';
        individual.XC_LECollectedThirdParties__c = ' ';
        insert individual;
        
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<XC_Address__c> listAddress = XC_DF_Address.createAddress(accList);
        insert listAddress;
        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(accList);
        contactList[0].IndividualId = individual.Id;
        contactList[0].XC_PrimaryContact__c = true;
        insert contactList;
        List <XC_CM_CountryLegalEntityAssociation__mdt> listOfCMD = new List <XC_CM_CountryLegalEntityAssociation__mdt> 
                                                                    ([SELECT XC_LegalEntity__c 
                                                                        FROM XC_CM_CountryLegalEntityAssociation__mdt
                                                                        WHERE XC_LegalEntityGroup__c IN ('Group1', 'Group2') LIMIT 1]);
        Test.startTest();
        List<Opportunity> listOppRes = XC_DF_Opportunity.createOpportunityWithVisit(contactList,listAddress[0]);
        if(!listOfCMD.isEmpty()){
            listOppRes[0].XC_LegalEntity__c = listOfCMD[0].XC_LegalEntity__c; 
        }
        // Per il momento, il seguente metodo sarà chiamato esplicitamente:
        XC_TR_Opportunity_U_CheckLEConsens.checkLEnewV(listOppRes);
        System.assertNotEquals(listOppRes, null);
        Test.stopTest();
    }

}