/**
 * @author            : Davide Desideri
 * @created date      : 
 * @description       : 
 * @testClasses       : 
 * @last modified by  : Davide Desideri
 * @last modified on  : 07-02-2023
**/

@IsTest
public with sharing class TestBatchBonificaQueueAndStructure {
    
    @TestSetup
    public static void setup() {
        
        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        cases[0].Estimated_Queue__c = 'DIP. TUTELA AMBIENTALE';
        cases[0].Current_Queue_CDC__c = 'Roma capitale';
        cases[0].Status = 'New';
        cases[1].Estimated_Queue__c = 'Farmacap';
        cases[1].Status = 'New';
        cases[1].Current_Queue_CDC__c = 'Roma capitale';
        update cases;

        QueueTranscoding__c trans = new QueueTranscoding__c();
        trans.Name_Queue_SFDC__c = 'DIP. TUTELA AMBIENTALE';
        trans.Name_Queue_CDC__c = 'dip tutela ambiente';
        trans.Struttura_CDC__c = 'struttura';
        insert trans;

        QueueTranscoding__c trans1 = new QueueTranscoding__c();
        trans1.Name_Queue_SFDC__c = 'Farmacap';
        trans1.Name_Queue_CDC__c = 'dip tutela ambiente';
        trans1.Struttura_CDC__c = 'struttura1';
        insert trans1;
    }
    
           
    @IsTest
    public static void TestBatchBonificaQueueAndStructure() {


        List<Case> cases = [SELECT id, Estimated_Queue__c, Estimated_Queue_CDC__c, Estimated_Structure__c,Status,Current_Queue_CDC__c  FROM Case WHERE Estimated_Queue__c != null AND Estimated_Queue_CDC__c != NULL AND Status != 'In Creazione' AND Current_Queue_CDC__c != null];
        Test.startTest();
        BatchBonificaQueueAndStructure batch = new BatchBonificaQueueAndStructure();
        Database.executeBatch(batch, 100);
        batch.execute(null, cases);

        System.schedule('TestBatchGEDCase', '0 17 * ? * * *', batch);
        Test.stopTest();

    }
}