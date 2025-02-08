/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation 07/06/2019
* @description XC_TR_CustomerInteractionRelationship_TEST – Test Class of XC_TR_CustomerInteractionRelationship
*/ 

@isTest
public with sharing class XC_TR_CustomerInteractionRelat_TEST {
    
    
    // Test method for setInteractionIdOnOpportunity 
    static testMethod void setInteractionIdOnOpportunity(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();        
        String currentUser = UserInfo.getUserId();
        List<User> currentusers = ([SELECT id from User where id=:currentUser]);
        system.runAs(currentUsers[0]){
            List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
            insert acc; 
            List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
            insert cont; 
            List<XC_Address__c> address =  XC_DF_Address.createAddress(acc);
            insert address;
            XC_CTI_Interaction__c cti = new XC_CTI_Interaction__c();
            cti.XC_InteractionStatus__c ='Open';
            insert cti;
            XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
            ci.XC_InteractionStatus__c ='Open'; 
            ci.XC_Communication_Type__c='Inbound Call';
            ci.XC_ContactId__c= cont[0].Id;
            ci.XC_AccountId__c=acc[0].Id;
            insert ci;
            List<Opportunity> opp = XC_DF_Opportunity.createOpportunityWithVisit(cont, address[0]);
            insert opp; 
            List<Case> cas = XC_DF_Case.createCases(1);
            insert cas; 
            List<Lead> lds = XC_DF_Lead.createResidentialLeads(1);
            insert lds; 
        //system.assertEquals(1, opp.size());
        }
        
        Test.stopTest();
    }
}