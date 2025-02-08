/**
* @author Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation  06/02/2020 
* @description XC_TR_Case_ObjLinked_TEST – Test class for XC_TR_Case_U_CreateObjectsLinked
*/ 
@isTest
public class XC_TR_Case_ObjLinked_TEST {
      
    @isTest
    static void caseObjLink1(){ 
        
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
		List<User> us = XC_DF_User.generateMultipleUser(2);
        insert us;
        
        List<Case> caseList = XC_DF_Case.createCases(1);
        caseList[0].OwnerId = us[0].Id;
        insert caseList;
        
        Account a = [SELECT Id, PrimaryEmail__c FROM Account LIMIT 1];

        test.startTest();
        XC_REST_Case_W.WrapperAccount wrAcc = new XC_REST_Case_W.WrapperAccount(a);
        System.assertEquals(a.Id, wrAcc.AccountID, 'Wrong assert result');
        
        caseList[0].OwnerId = us[1].Id;
        update caseList;
        
        caseList[0].Origin = 'CAN001';
        caseList[0].Status = 'ESTA003';
        caseList[0].XC_SubStatus__c = 'SUB005';
        update caseList;
        
        test.stopTest();
    }
    
    @isTest
    static void caseObjLink2(){ 
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;

        List<Case> caseList = XC_DF_Case.createCases(2);
        caseList[0].Reason = 'XCMOT005';
        caseList[0].SubCause__c = 'ATCL070';
        caseList[0].XC_Subtype__c = 'XC069';
        caseList[0].XC_CompliantApplicable__c = true;
        caseList[1].Reason = 'XCMOT005';
        caseList[1].XC_CompliantApplicable__c = true;
        insert caseList;
        Account a = [SELECT Id, PrimaryEmail__c FROM Account LIMIT 1];

        test.startTest();
        XC_REST_Case_W.WrapperAccount wrAcc = new XC_REST_Case_W.WrapperAccount(a);
        System.assertEquals(a.Id, wrAcc.AccountID, 'Wrong assert result');
        test.stopTest();
    }
    
}