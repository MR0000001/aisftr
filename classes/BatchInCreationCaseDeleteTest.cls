@isTest
public with sharing class BatchInCreationCaseDeleteTest {
    @testSetup
    public static void setup() {
        TestDataFactory.createFisicalDeleteBatchSettings();
    }

    @isTest
    public static void BatchInCreationCaseDeleteTest() {
        Case newCase = TestDataFactory.createInCreationCase();
        Datetime tempTime = Datetime.now().addMinutes(5);

        Test.startTest();
        System.schedule('BatchInCreationCaseDelete ' + datetime.now(), '00 ' + String.valueOf(tempTime.minute()) + ' ' + String.valueOf(tempTime.hour()) + ' '
        + String.valueOf(tempTime.day()) + ' ' + String.valueOf(tempTime.month()) + ' ? ' + String.valueOf(tempTime.year()), new BatchInCreationCaseDelete());
        Database.executeBatch(new BatchInCreationCaseDelete());
        Test.stopTest();
    }
}