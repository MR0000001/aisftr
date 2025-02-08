/**
 * Created by snekkanti002 on 24/09/2021.
 */

@IsTest
public with sharing class TestDebugService {

    @TestSetup
    public static void setup() {
        TestDataFactory.createCasesWithoutCities();
    }

    @IsTest
    public static void printLimits() {
        Test.startTest();
        DebugService.printLimits('TestDebugService', 'printLimits', 'start');
        Test.stopTest();
    }

    @IsTest
    public static void printException() {
        Test.startTest();
        try {
            Integer x = 1/0;
        } catch(Exception e) {
            DebugService.printException('TestDebugService', 'printException', e);
        }
        Test.stopTest();
    }

    @IsTest
    public static void printResponse() {
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody('test');

        Test.startTest();
        DebugService.printResponse('TestDebugService', 'printResponse', res);
        Test.stopTest();
    }

    @IsTest
    public static void printRequest() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('www.google.com');
        req.setBody('test');

        Test.startTest();
        DebugService.printRequest('TestDebugService', 'printResponse', req);
        Test.stopTest();
    }

    @IsTest
    public static void printList() {
        List<Case> cases = [SELECT Id FROM Case];
        Test.startTest();
        DebugService.printList('TestDebugService', 'printList', 'cases', cases);
        Test.stopTest();
    }

    @IsTest
    public static void printList2() {
        List<Case> cases = [SELECT Id FROM Case];
        Test.startTest();
        DebugService.printList('TestDebugService', 'printList2', 'cases', cases, true);
        Test.stopTest();
    }

    @IsTest
    public static void printMap() {
        Map<String, Case> caseMap = new Map<String, Case>([SELECT Id FROM Case]);
        Test.startTest();
        DebugService.printMap('TestDebugService', 'printMap', 'caseMap', new List<String>(caseMap.keySet()), new List<Case>(caseMap.values()), true);
        DebugService.printMap('TestDebugService', 'printMap', 'caseMap', new List<String>(caseMap.keySet()), new List<Case>(caseMap.values()), false);
        Test.stopTest();
    }

    @IsTest
    public static void printMap2() {
        Map<String, Case> caseMap = new Map<String, Case>([SELECT Id FROM Case]);
        Test.startTest();
        DebugService.printMap('TestDebugService', 'printMap', 'caseMap', new List<String>(caseMap.keySet()), new List<List<Case>>(), true);
        DebugService.printMap('TestDebugService', 'printMap', 'caseMap', new List<String>(caseMap.keySet()), new List<List<Case>>(), false);
        Test.stopTest();
    }

    @IsTest
    public static void printRestResponse() {
        RestResponse res = RestContext.response;

        Test.startTest();
        try {
            DebugService.printRestResponse('TestDebugService', 'printRestResponse', res);
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    public static void printDatabaseResults() {
        List<Case> cases = [SELECT Id FROM Case];

        List<Database.SaveResult> results = Database.update(cases);
        List<Database.UpsertResult> upsertResults = Database.upsert(cases);
        Test.startTest();
        DebugService.printDatabaseResults('TestDebugService', 'printDatabaseResults', 'cases', results);
        DebugService.printDatabaseResults('TestDebugService', 'printDatabaseResults', 'cases', upsertResults);
        DebugService.printDatabaseResults('TestDebugService', 'printDatabaseResults', 'new list', new List<Database.DeleteResult>());
        DebugService.printDatabaseResults('TestDebugService', 'printDatabaseResults', 'new list', new List<Database.UndeleteResult>());
        Test.stopTest();
    }
}