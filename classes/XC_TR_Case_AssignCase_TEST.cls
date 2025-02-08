@Istest
public class XC_TR_Case_AssignCase_TEST {
    static testmethod void caseAssignmentTest(){
    test.startTest();
    
    List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
    insert accList;
    List <Contact> cont = XC_DF_Contact.createCondominiumContacts(accList);
    cont[0].AccountId=accList.get(0).id;
    insert cont;    
    List<Opportunity> opp = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
    insert opp;
    //List<Case> casePartner = XC_DF_Case.createCases(1);
    List<Case> casePartner=new List<Case>();
    User u = [Select id FROM user where XC_legalEntity__c ='EnelXItalia' order by createddate desc limit 1];
     Set<id> caseIdset = new Set<id> ();
     Map<Id,Id> mapcaseidAccount = new Map<Id,Id>();
    Case caso = new Case();
    caso.Status = 'ESTA001';
    caso.Reason = 'XCMOT010';
    caso.SubCause__c = null;
    caso.XC_Opportunity__c= opp[0].id;
    caso.XC_LegalEntity__c = 'EndesaX';
    caso.OwnerId=u.id;
    caso.AccountId = accList[0].Id;
    caso.ContactId = cont[0].Id;
    caso.XC_Type_Intermediary__c = 'TI001';
    casePartner.add(caso);
    
    caso = new Case();
    caso.Status = 'ESTA001';
    caso.Origin = 'CAN013';
    caso.Reason = 'XCMOT010';
    caso.SubCause__c = null;
    caso.XC_Opportunity__c= opp[0].id;
    caso.XC_LegalEntity__c = 'EndesaX';
    caso.OwnerId=u.id;
    caso.AccountId = accList[0].Id;
    caso.ContactId = cont[0].Id;
    caso.XC_Type_Intermediary__c = 'TI001';
    casePartner.add(caso);
    insert casePartner;
    caseIdset.add(caso.id);   
  mapcaseidAccount.put(caso.id,accList[0].Id);
   AccountTeamMember accountTeamMember=new AccountTeamMember();
   accountTeamMember.AccountId=accList[0].id;
   accountTeamMember.UserId=u.id;
   accountTeamMember.TeamMemberRole='Tecnico Gestionale';
   insert accountTeamMember;

 
        
    system.runAs(u){ 
        XC_TR_Case_AssignCase.caseAssignment(casePartner);
        XC_TR_Case_AssignCase.futureMethod(caseIdset);
        XC_TR_Case_AssignCase.futureCustomAssignment(mapcaseidAccount);
    }
    test.stopTest();
    }
}