/**
 * @description       : Test class for TA_LCC258_HSEQManagement
 * @author            : benjamin.geronimo
 * @group             : WebResults
 * @last modified on  : 30-07-2021
 * @last modified by  : benjamin.geronimo
 * Modifications Log 
 * Ver   Date         Author              Modification
 * 1.0   28-06-2021   benjamin.geronimo   Initial Version
**/
@isTest
public with sharing class TA_LCC258_HSEQManagement_Test {

    @testSetup
    private static void testSetup() {

        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        insert accounts;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        insert contacts;

        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName (1, 'Quality Check Inspection', 'Quality Check Inspection');
        for (WorkOrder wo : woList){
            wo.TA_Phase__c = 'Preservice';
            wo.XC_LegalEntity__c = 'EnelXItalia';
            wo.XC_WorkTypeLabel__c = 'Quality Check Inspection';
            wo.AccountId = accounts[0].Id;
            //wo.XC_CreatedAutomaticallyBySystem__c  = true;
            wo.XC_ScheduledStart__c = date.newInstance(2020, 12, 17);
        }
        insert woList;

        // Case caseTest = XC_DF_Case.createCaseFromType('XCMOT007','ATCL107','XC187');
        // caseTest.XC_WorkOrder__c = woList[0].Id;
        // insert caseTest;


        Case caso = new Case();
        caso.Status = 'ESTA003';
        caso.Reason = 'XCMOT007';
        caso.XC_Subtype__c = 'XC187';
        caso.SubCause__c = 'ATCL107';
        caso.AccountId = accounts[0].Id;
        caso.ContactId = contacts[0].Id;
        caso.XC_LegalEntity__c = 'EnelXItalia';
        caso.XC_Type_Intermediary__c = 'TI001';
        caso.XC_WorkOrder__c  = woList[0].Id;
        insert caso;
    }

    @IsTest
    static void checkProfileUser(){
        Test.startTest();
        TA_LCC258_HSEQManagement.checkProfileUser();
        Test.stopTest();
        
    }

    @IsTest
    static void getHSEQList_1(){
        String profileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1][0].Name;
        String condition = '[{"profile":"'+ profileName + '","object":"Case","whereCond":["SubCause__c = \'ATCL107\'","XC_Subtype__c = \'XC187\'"]}]';
        Test.startTest();
        TA_LCC258_HSEQManagement.getHSEQList(condition, false);
        Test.stopTest();
        
    }

    @IsTest
    static void getHSEQList_2(){
        String profileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1][0].Name;
        String condition = '[{"profile":"'+ profileName + '","object":"Case","whereCond":["SubCause__c = \'ATCL107\'","XC_Subtype__c = \'XC187\'"]}]';

        Test.startTest();
        TA_LCC258_HSEQManagement.getHSEQList(condition, true);
        Test.stopTest();
        
    }

    @IsTest
    static void createDummyWorkOrderFromCase(){
        Case caseRecord = [SELECT Id From Case LIMIT 1];

        Test.startTest();
        TA_LCC258_HSEQManagement.createDummyWorkOrderFromCase(caseRecord.Id);
        TA_LCC258_HSEQManagement.createDummyWorkOrderFromCase(null);
        Test.stopTest();
        
    }

}