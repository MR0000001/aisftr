/**
 * Created by LCONATO00 on 08/10/2020.
 */
@isTest
public with sharing class TestErrorLogEventHandler {
    /*
    @isTest
    static void testCreateEvent1() {

        Double d = TestDataFactory.initException();
        String note = TestDataFactory.initNote();
        String request = TestDataFactory.initRequest();
        String response = TestDataFactory.initResponse();

        Test.startTest();
        Error_Log_Event__e logEvent = ErrorLogEventHandler.createEvent(d, note, request, response);
        Test.stopTest();

        System.assertNotEquals(logEvent, null);
    }
*/
/*
    @isTest
    static void testCreateEvent2() {

        Double d = TestDataFactory.initException();
        String request = TestDataFactory.initRequest();
        String response = TestDataFactory.initResponse();

        Test.startTest();
        Error_Log_Event__e logEvent = ErrorLogEventHandler.createEvent(d, request, response);
        Test.stopTest();

        System.assertNotEquals(logEvent, null);
    }
*/
    @isTest
    static void testCreateEvent3() {

        String note = TestDataFactory.initNote();

        Test.startTest();
        Error_Log_Event__e logEvent = ErrorLogEventHandler.createEvent(note);
        Test.stopTest();

        System.assertNotEquals(logEvent, null);
    }

    @isTest
    static void testCreateEvent4() {

        String className = TestDataFactory.initClassName();
        String note = TestDataFactory.initNote();
        String methodName = TestDataFactory.initMethodName();
        String debugType = TestDataFactory.initDebugType();
        String message = TestDataFactory.initMessage();


        Test.startTest();
        Error_Log_Event__e logEvent = ErrorLogEventHandler.createEvent(className, methodName, debugType, message, note);
        Test.stopTest();

        System.assertNotEquals(logEvent, null);
    }

    @isTest
    static void testCreateEvent5() {

        String request = TestDataFactory.initRequest();
        String response = TestDataFactory.initResponse();

        Test.startTest();
        Error_Log_Event__e logEvent = ErrorLogEventHandler.createEvent(request, response);
        Test.stopTest();

        System.assertNotEquals(logEvent, null);
    }

    @isTest
    static void testCreateEvent6() {

        String request = TestDataFactory.initRequest();
        String response = TestDataFactory.initResponse();
        String note = TestDataFactory.initNote();

        Test.startTest();
        Error_Log_Event__e logEvent = ErrorLogEventHandler.createEvent(note, request, response);
        Test.stopTest();

        System.assertNotEquals(logEvent, null);
    }

    @isTest
    static void testCreateEvent7() {

        String request = TestDataFactory.initRequest();
        String response = TestDataFactory.initResponse();

        Test.startTest();
        Error_Log_Event__e logEvent = ErrorLogEventHandler.createEvent(request, response);
        Test.stopTest();

        System.assertNotEquals(logEvent, null);
    }

    @isTest
    static void testCreateEvent8() {

        List<Object> databaseResults = TestDataFactory.listStructures();
        System.debug('databaseResults: '+databaseResults);

        Test.startTest();
        Error_Log_Event__e logEvent = ErrorLogEventHandler.createEvent(databaseResults);
        Test.stopTest();

        System.assertEquals(logEvent, null);
    }

    @isTest
    static void testCreateEvent9() {
        String error = 'test exception';
        AuraHandledException testException = new AuraHandledException(error);
        String note = TestDataFactory.initNote();
        String request = TestDataFactory.initRequest();
        String response = TestDataFactory.initResponse();

        Test.startTest();
        ErrorLogEventHandler.createEvent('test error', true);
        ErrorLogEventHandler.createInfoEvent(testException);
        ErrorLogEventHandler.createEvent(testException);
        ErrorLogEventHandler.createEvent(testException, request, response);
        ErrorLogEventHandler.createEvent(testException, note);
        ErrorLogEventHandler.createEvent(testException, note, request, response);
        ErrorLogEventHandler.standardExceptionLog(testException);
        ErrorLogEventHandler.standardExceptionLogNote(testException, note);
        Test.stopTest();

    }

    @isTest
    public static void testCreateEvent10() {
        List<Account> accounts = new List<Account>();
        Account acc = new Account();
        accounts.add(acc);

        Test.startTest();
        Database.SaveResult[] saveResults = Database.insert(accounts, false);

        acc.Name = 'Test';
        insert accounts;

        Database.DeleteResult[] deleteResults = Database.delete(accounts, false);

        ErrorLogEventHandler.createErrorLogsFromFailedDML(saveResults);
        ErrorLogEventHandler.createErrorLogsFromFailedDML(deleteResults);
        Test.stopTest();
    }
}