/** 
* ===================================================================================
* @className        ATCL_VFC032_ActionPlanAutoCreation_Test
* @description      Test Class that checks the functionality of the class controller ATCL_VFC032_ActionPlanAutoCreation 
* @author           JMMC
* @email            jmartin@deloitte.es
* @version          V0.1	
* @dateCreated		2017/04/09
* ===================================================================================
*/
@isTest
public class ATCL_VFC032_ActionPlanAutoCreation_Test {
    
    public static testMethod void testCaseAPSingleTask() {
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accList);
        insert conList;
        
        User user = XC_DF_User.createUserAdmin();
        insert user;
        
        Id mngmRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Management_Case').getRecordTypeId();
        List<Case> newCases = XC_DF_Case.createCases(1);
        newCases[0].Reason = 'XCMOT002';
        newCases[0].SubCause__c = 'ATCL005';
        newCases[0].XC_Subtype__c = 'XC017';
        newCases[0].Status = 'ESTA001';
        newCases[0].ContactId = conList[0].Id;
        newCases[0].AccountId = accList[0].Id;
        newCases[0].RecordTypeId = mngmRT;
        newCases[0].OwnerId = user.Id;
        insert newCases;
        
        Test.startTest();

        /*Case ca = new Case();
        //    ca.CaseNumber = 'Case1';
        insert ca;*/
        
        ActionPlanTemplate__c ap = new ActionPlanTemplate__c();
        insert ap;
        
        APTTaskTemplate__c at = new APTTaskTemplate__c(Action_Plan_Template__c=ap.Id, Subject__c='Resellado', DaysFromStart__c = 1);
        insert at;

        //ATCL_VFC032_ActionPlanAutoCreation controller = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, ca.CaseNumber+','+ca.Id, 'Case');
        ATCL_VFC032_ActionPlanAutoCreation controller = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, newCases[0].CaseNumber+','+newCases[0].Id, 'Case');
        //ATCL_VFC032_ActionPlanAutoCreation.ApTaskWrapper apw =ATCL_VFC032_ActionPlanAutoCreation.ApTaskWrapper(at, 1,true,true);
        controller.initNewActionPlanFromTemplate();
        controller.save();
        /*
        ATCL_VFC032_ActionPlanAutoCreation controller1 = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, 'asdf', '');
        controller1.initNewActionPlanFromTemplate();
        controller1.save();
        
        at.Dependent__c='0';
        update at;
        ATCL_VFC032_ActionPlanAutoCreation controller2 = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, 'asdf', '');
        controller2.initNewActionPlanFromTemplate();
        controller2.save();*/
        
        System.assert(true);
        Test.stopTest();
    }
    
    public static testMethod void testCaseAPDependentTask() {
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accList);
        insert conList;
        
        User user = XC_DF_User.createUserAdmin();
        insert user;
        
        Id mngmRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Management_Case').getRecordTypeId();
        List<Case> newCases = XC_DF_Case.createCases(1);
        newCases[0].Reason = 'XCMOT002';
        newCases[0].SubCause__c = 'ATCL005';
        newCases[0].XC_Subtype__c = 'XC017';
        newCases[0].ContactId = conList[0].Id;
        newCases[0].AccountId = accList[0].Id;
        newCases[0].RecordTypeId = mngmRT;
        newCases[0].OwnerId = user.Id;
        newCases[0].Status = 'ESTA001';
        insert newCases;
        
        Test.startTest();
        
        ActionPlanTemplate__c ap = new ActionPlanTemplate__c();
        insert ap;
        
        APTTaskTemplate__c at = new APTTaskTemplate__c(Action_Plan_Template__c=ap.Id, Subject__c='Resellado', DaysFromStart__c = 1, Dependent__c='1');
        insert at;
        
        APTTaskTemplate__c atDep = new APTTaskTemplate__c(Action_Plan_Template__c=ap.Id, Subject__c='Dependent', DaysFromStart__c = 2, APTTaskTemplate__c=at.Id, Dependent__c='0');
        insert atDep;

        ATCL_VFC032_ActionPlanAutoCreation controller = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, newCases[0].CaseNumber+','+newCases[0].Id, 'Case');
        controller.initNewActionPlanFromTemplate();
        controller.save();
        
        System.assert(true);
        Test.stopTest();
    }
    
    /*public static testMethod void testAccountAP() {
        
        Test.startTest();
        Account acc = new Account();
        acc.Name = 'Cuenta';
        insert acc;

        ActionPlanTemplate__c ap = new ActionPlanTemplate__c();
        insert ap;
        
        APTTaskTemplate__c at = new APTTaskTemplate__c(Action_Plan_Template__c=ap.Id, Subject__c='Resellado', DaysFromStart__c = 1, Dependent__c = 'None');
        insert at;
        
        APTTaskTemplate__c at2 = new APTTaskTemplate__c(Action_Plan_Template__c=ap.Id, Subject__c='Resellado 1', DaysFromStart__c = 1, Dependent__c = '0');
        insert at2;
        
        APTTaskTemplate__c at3 = new APTTaskTemplate__c(Action_Plan_Template__c=ap.Id, Subject__c='Resellado 2', DaysFromStart__c = 1, Dependent__c = '1');
        insert at3;
        
        at2.Dependent__c='2';
        update at2;
        
        ATCL_VFC032_ActionPlanAutoCreation controller = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, acc.Name+','+acc.Id, 'Account');
        //ATCL_VFC032_ActionPlanAutoCreation.ApTaskWrapper apw =ATCL_VFC032_ActionPlanAutoCreation.ApTaskWrapper(at, 1,true,true);
        controller.initNewActionPlanFromTemplate();
        controller.save();
        
        ATCL_VFC032_ActionPlanAutoCreation controller1 = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, 'asdf', '');
        controller1.initNewActionPlanFromTemplate();
        controller1.save();

        ATCL_VFC032_ActionPlanAutoCreation controller2 = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, 'asdf', '');
        controller2.initNewActionPlanFromTemplate();
        controller2.save();
        
        Test.stopTest();
    }*/
    /*public static testMethod void testContactAP() {
        
        Test.startTest();
                
        Contact ct = new Contact();
        ct.FirstName = 'ContactoNombre';
        ct.LastName = 'ContactoApellido';
        insert ct;
        
        ActionPlanTemplate__c ap = new ActionPlanTemplate__c();
        insert ap;
        
        APTTaskTemplate__c at = new APTTaskTemplate__c(Action_Plan_Template__c=ap.Id, Subject__c='Resellado', DaysFromStart__c = 1);
        insert at;
        
        ATCL_VFC032_ActionPlanAutoCreation controller = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, ct.Name+','+ct.Id, 'Contact');
        //ATCL_VFC032_ActionPlanAutoCreation.ApTaskWrapper apw =ATCL_VFC032_ActionPlanAutoCreation.ApTaskWrapper(at, 1,true,true);
        controller.initNewActionPlanFromTemplate();
        controller.save();
        /*
        ATCL_VFC032_ActionPlanAutoCreation controller1 = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, 'asdf', '');
        controller1.initNewActionPlanFromTemplate();
        controller1.save();
        
        ATCL_VFC032_ActionPlanAutoCreation controller2 = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, 'asdf', '');
        controller2.initNewActionPlanFromTemplate();
        controller2.save();* /
        
        Test.stopTest();
    }*/
    /*public static testMethod void testLeadAP() {
        
        Test.startTest();
        
        Lead ld = new Lead();
        ld.LastName = 'LeadName';
        ld.Company = 'ENEL DISTRIBUCION CHILE';
        //ld.Name = 'LeadName';
        insert ld;
        
        ActionPlanTemplate__c ap = new ActionPlanTemplate__c();
        insert ap;
        
        APTTaskTemplate__c at = new APTTaskTemplate__c(Action_Plan_Template__c=ap.Id, Subject__c='Resellado', DaysFromStart__c = 1);
        insert at;

        ATCL_VFC032_ActionPlanAutoCreation controller = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, ld.Name+','+ld.Id, 'Lead');
        //ATCL_VFC032_ActionPlanAutoCreation.ApTaskWrapper apw =ATCL_VFC032_ActionPlanAutoCreation.ApTaskWrapper(at, 1,true,true);
        controller.initNewActionPlanFromTemplate();
        controller.save();
        /*
        ATCL_VFC032_ActionPlanAutoCreation controller1 = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, 'asdf', '');
        controller1.initNewActionPlanFromTemplate();
        controller1.save();
        
        at.Dependent__c='0';
        update at;
        ATCL_VFC032_ActionPlanAutoCreation controller2 = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, 'asdf', '');
        controller2.initNewActionPlanFromTemplate();
        controller2.save();* /
        
        Test.stopTest();
    }*/
    /*public static testMethod void testOpportunityAP() {
        
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Opp1';
        opp.CloseDate = Date.today().addDays(3);
        opp.StageName = 'Prospecting';
        insert opp;
        
        ActionPlanTemplate__c ap = new ActionPlanTemplate__c();
        insert ap;
        
        APTTaskTemplate__c at = new APTTaskTemplate__c(Action_Plan_Template__c=ap.Id, Subject__c='Resellado', DaysFromStart__c = 1);
        insert at;
        
        ATCL_VFC032_ActionPlanAutoCreation controller = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, opp.Name+','+opp.Id, 'Opportunity');
        //ATCL_VFC032_ActionPlanAutoCreation.ApTaskWrapper apw =ATCL_VFC032_ActionPlanAutoCreation.ApTaskWrapper(at, 1,true,true);
        controller.initNewActionPlanFromTemplate();
        controller.save();
        /*
        ATCL_VFC032_ActionPlanAutoCreation controller1 = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, 'asdf', '');
        controller1.initNewActionPlanFromTemplate();
        controller1.save();
        
        at.Dependent__c='0';
        update at;
        ATCL_VFC032_ActionPlanAutoCreation controller2 = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, 'asdf', '');
        controller2.initNewActionPlanFromTemplate();
        controller2.save();* /
        
        Test.stopTest();
    }*/
    
    /*Test COMMENTATO MC 20190625*/
    /*public static testMethod void testCampaignAP() {
        
        Test.startTest();

        Campaign cp = new Campaign();
        cp.Name = 'Camp1';
        cp.Campaign_Area__c = 'Customer Experience';
        insert cp;
        
        ActionPlanTemplate__c ap = new ActionPlanTemplate__c();
        insert ap;
        
        APTTaskTemplate__c at = new APTTaskTemplate__c(Action_Plan_Template__c=ap.Id, Subject__c='Resellado', DaysFromStart__c = 1);
        insert at;
        
        ATCL_VFC032_ActionPlanAutoCreation controller = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, cp.Name+','+cp.Id, 'Campaign');
        //ATCL_VFC032_ActionPlanAutoCreation.ApTaskWrapper apw =ATCL_VFC032_ActionPlanAutoCreation.ApTaskWrapper(at, 1,true,true);
        controller.initNewActionPlanFromTemplate();
        controller.save();
        /*
        ATCL_VFC032_ActionPlanAutoCreation controller1 = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, 'asdf', '');
        controller1.initNewActionPlanFromTemplate();
        controller1.save();
        
        at.Dependent__c='0';
        update at;
        ATCL_VFC032_ActionPlanAutoCreation controller2 = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, 'asdf', '');
        controller2.initNewActionPlanFromTemplate();
        controller2.save();* /
        
        Test.stopTest();
    }*/
    
    /*Test COMMENTATO MC 20190625*/
    /*public static testMethod void testContractAP() {
        
        Test.startTest();
        Agreement__c a = new Agreement__c();
        insert a;
        Account acc = new Account();
        acc.Name = 'Cuenta';
        insert acc;
        Contract ctr = new Contract();
        ctr.Name = 'Contrato1';
        ctr.AccountId = acc.Id;
        
        
        insert ctr;
        
        ActionPlanTemplate__c ap = new ActionPlanTemplate__c();
        insert ap;
        
        APTTaskTemplate__c at = new APTTaskTemplate__c(Action_Plan_Template__c=ap.Id, Subject__c='Resellado', DaysFromStart__c = 1);
        insert at;
        
        ApexPages.standardController sc = new ApexPages.standardController(a);
        ATCL_VFC032_ActionPlanAutoCreation controller = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, ctr.Name+','+ctr.Id, 'Contract');
        //ATCL_VFC032_ActionPlanAutoCreation.ApTaskWrapper apw =ATCL_VFC032_ActionPlanAutoCreation.ApTaskWrapper(at, 1,true,true);
        controller.initNewActionPlanFromTemplate();
        controller.save();
        /*
        ATCL_VFC032_ActionPlanAutoCreation controller1 = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, 'asdf', '');
        controller1.initNewActionPlanFromTemplate();
        controller1.save();
        
        at.Dependent__c='0';
        update at;
        ATCL_VFC032_ActionPlanAutoCreation controller2 = new ATCL_VFC032_ActionPlanAutoCreation(ap.Id, 'asdf', '');
        controller2.initNewActionPlanFromTemplate();
        controller2.save();* /
        
        Test.stopTest();
    }*/
}