@isTest
public class XC_TR_Opportunity_DealRegistration_TEST {
      static testMethod  void insertDealStatus(){
      test.startTest();      
      List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
      insert accList;
      List <Contact> cont = XC_DF_Contact.createCondominiumContacts(accList);
      cont[0].AccountId=accList.get(0).id;
      insert cont;                   
      List<Opportunity> opp = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1); 
      opp[0].AccountId = accList[0].id;
      insert opp;
      List<Case> casePartner = XC_DF_Case.createCases(1);
      casePartner[0].XC_Subtype__c = 'XC193';
      casePartner[0].XC_Resolution__c='R135';
      casePartner[0].XC_Opportunity__c= opp[0].id;
      User u = XC_DF_User.createCommunityUser(cont.get(0));
      Profile profile = [SELECT Id FROM Profile WHERE Name = 'XC_B2B_ITA_SalesPartnerManager' LIMIT 1]; 
      U.ProfileId = profile.id;
      insert u;          
      opp[0].OwnerId=u.Id;
      opp[0].AccountId = accList[0].id; 
      opp[0].XC_DealRegistrationStatus__c='Approval Needed';
      update opp;      
      system.runAs(u){ 
      XC_TR_Opportunity_DealRegistration.insertDealStatus(opp) ;  
      }
      test.stopTest();        
      }       
}