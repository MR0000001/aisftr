/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 18/12/2020
* @description XC_TR_CTIInteraction_TEST
*/ 

@isTest
private class XC_TR_CTIInteraction_TEST {
    
    @isTest
    static void onInsertDeleteUpdateCti() {
        /*
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Case> cc = XC_DF_Case.createCases(1);
        insert cc;
        XC_CTI_Interaction__c c = new XC_CTI_Interaction__c();
        c.XC_InteractionStatus__c = 'Open';
        c.XC_CaseId__c = cc[0].Id;
        insert c;
        
        c.XC_InteractionStatus__c = 'Close';
        update c;
        
        delete c;
        
        Test.stopTest();
*/
    }
    
    
    @isTest
    static void onInsertDeleteUpdateCti2() {
        /*
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        
        Account acc = XC_DF_Account.createResidentialAccounts(1)[0];
        acc.XC_Country__c = 'Italy';
        insert acc;
        
        List<Case> cc = XC_DF_Case.createCases(1);
        insert cc;
        XC_CTI_Interaction__c c = new XC_CTI_Interaction__c();
        c.XC_InteractionStatus__c = 'Open';
        c.XC_CaseId__c = cc[0].Id;
        c.XC_AccountId__c = acc.id;
        insert c;
        
        c.XC_InteractionStatus__c = 'Close';
        update c;
        
        
        
        Test.stopTest();
*/
    }

    //JJP 28-10-2021 - ENELX - NR1752 - Extend_Post_CallCenter_Survey - Start
    @isTest 
    static void onInsertDeleteUpdateCti3() {
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Test.startTest();
        
        XC_Survey_Post_CallCenter__c cp = new XC_Survey_Post_CallCenter__c();
        cp.Name = 'XCMOT001_ATCL033_XC114_EndesaX_B2C';
        cp.Reason__c = 'XCMOT001';
        cp.SubCause__c = 'ATCL033';
        cp.XC_Subtype__c = 'XC114';
        cp.XC_LegalEntity__c = 'EndesaX';
        cp.XC_Segment__c = 'B2C';
        cp.XC_Country__c = 'Spain';
        insert cp;
        
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        acc[0].XC_Country__c = 'Spain';
        insert acc;
        
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(acc);
        insert contList;
        /*
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'CEO' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
		*/
        User admin = XC_DF_User.createUserAdmin();
        admin.XC_LegalEntity__c = 'EndesaX';
        insert admin;

        System.runAs ( admin ) 
        {  
            XC_CTI_Interaction__c c = new XC_CTI_Interaction__c();
            c.XC_InteractionStatus__c = 'Open';
            c.XC_AccountId__c = acc[0].id;
            insert c;		
            List<Case> caseList= XC_DF_Case.createCases(1);
            caseList[0].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Case').getRecordTypeId();
            caseList[0].AccountId = acc[0].Id;
            caseList[0].ContactId = contList[0].Id;
            caseList[0].Reason = 'XCMOT001';
            caseList[0].SubCause__c = 'ATCL033';
            caseList[0].XC_Subtype__c = 'XC114';
            caseList[0].XC_LegalEntity__c = 'EndesaX';
            caseList[0].XC_Segment__c = 'B2C';
			caseList[0].XC_CTI_Interaction__c = c.id;
            System.debug('JJP 1 ' + caseList[0]);
            insert caseList;
            
            
            c.XC_InteractionStatus__c = 'Close';
            update c;
        }
        
        Test.stopTest();
    }
}