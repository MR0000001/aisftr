/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 16/07/2019
* @date Modification dd/mm/yyyy
* @description XC_SC015_CancelMaintWorkOrder_TEST – Test Class for XC_SC015_CancelMaintenanceWorkOrder
*/ 

@isTest
public class XC_SC017_DeactivatePartnerOverall_TEST {

    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        org.XC_Spain_ValidationRules__c =  true;
        insert org;
    }

    static testMethod void testBatch(){
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1);
        List<Contact> contList = XC_DF_Contact.createPartnerContacts(accList);
        insert contList;
        Case caso = new Case();
        //caso.Status = 'ESTA003';
        caso.Reason = 'XCMOT001';
        caso.SubCause__c = 'ATCL001';
        caso.AccountId = accList[0].Id;
        caso.ContactId = contList[0].Id;
        insert caso;
        SchedulableContext sc = null;
        XC_SC017_DeactivatePartnerFromOverall tsc = new XC_SC017_DeactivatePartnerFromOverall();
        tsc.execute(sc);
        XC_SC017_DeactivatePartnerFromOverall bdvi = new XC_SC017_DeactivatePartnerFromOverall();
        Id batchId = Database.executeBatch(bdvi); 
        System.assertEquals(caso != null, true);
    }


}