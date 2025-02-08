/**
 * @description       : Test class for TA_LCC259_QualityCheckCreateRecord
 * @author            : benjamin.geronimo
 * @group             : WebResults
 * @last modified on  : 30-07-2021
 * @last modified by  : benjamin.geronimo
 * Modifications Log 
 * Ver   Date         Author              Modification
 * 1.0   07-07-2021   benjamin.geronimo   Initial Version
**/
@isTest
public with sharing class TA_LCC259_QualityCheckCreateRecord_Test {

    @testSetup
    private static void testSetup() {

        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        insert accounts;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        insert contacts;
        
        Case caso = new Case();
        caso.Status = 'ESTA003';
        caso.Reason = 'XCMOT007';
        caso.XC_Subtype__c = 'XC187';
        caso.SubCause__c = 'ATCL107';
        caso.AccountId = accounts[0].Id;
        caso.ContactId = contacts[0].Id;
        caso.XC_LegalEntity__c = 'EnelXItalia';
        caso.XC_Type_Intermediary__c = 'TI001';
        insert caso;
        
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName (1, 'Quality Check Inspection', 'Quality Check Inspection');
        for (WorkOrder wo : woList){
            wo.TA_Phase__c = 'Preservice';
            wo.XC_LegalEntity__c = 'EnelXItalia';
            wo.XC_WorkTypeLabel__c = 'Quality Check Inspection';
            wo.AccountId = accounts[0].Id;
            wo.CaseId = caso.Id;
            wo.XC_ScheduledStart__c = date.today();
        }
        insert woList;


        XC_B2BG_QualityCheck__c qc = XC_DF_QualityCheck.createQualityChecks(1)[0];
        qc.XC_Case__c = caso.Id;
        insert qc;


    }

    @IsTest
    static void getCurrentRecord(){
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        Test.startTest();
        TA_LCC259_QualityCheckCreateRecord.getCurrentRecords(wo.Id);
        TA_LCC259_QualityCheckCreateRecord.getCurrentRecords(null);
        Test.stopTest();
        
    }

    @IsTest
    static void deleteRecord(){
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        Test.startTest();
        TA_LCC259_QualityCheckCreateRecord.deleteRecord(wo.Id, 'WorkOrder');
        Test.stopTest();
        
    }

    @IsTest
    static void findRecordTypes(){
        Test.startTest();
        TA_LCC259_QualityCheckCreateRecord.findRecordTypes('XC_B2BG_QualityCheck__c');
        Test.stopTest();
        
    }

    @isTest
    static void getPredefinedValues_Test() {
        
        TA_LCC259_QualityCheckCreateRecord.PredefinedValue predefinedValue = new TA_LCC259_QualityCheckCreateRecord.PredefinedValue();
        predefinedValue.apiName = 'Id';
        predefinedValue.queryField = 'Id';

        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        Test.startTest();
        TA_LCC259_QualityCheckCreateRecord.getPredefinedValues(JSON.serialize(new List<TA_LCC259_QualityCheckCreateRecord.PredefinedValue> {predefinedValue}), wo.Id);
        Test.stopTest();
    }

}