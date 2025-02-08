/**
 * Created by snekkanti002 on 11/07/2022.
 */

@IsTest
public with sharing class TestSendContentVersionToGedService {

    @TestSetup
    public static void setup() {
        TestDataFactory.createContentVersionToGeds(TestDataFactory.createCasesWithoutCities());
    }

    @IsTest
    public static void sendContentVersionToGed() {
        Test.startTest();
        SendContentVersionToGedService.sendContentVersionToGed();
        Test.stopTest();
    }

    public static List<Database.SaveResult> insertCases(List<Case> cases, Boolean allOrNone) {
        DebugService.printLimits('TestSendContentVersionToGedService', 'insertCases', 'start');
        List<Database.SaveResult> results = new List<Database.SaveResult>();
        if (cases != null && !cases.isEmpty()) {
            System.debug(cases + ' is not null or empty');
            try {
                results = Database.update(cases, allOrNone);
            } catch (Exception e) {
                ErrorLogEventHandler.standardExceptionLog('TestSendContentVersionToGedService', 'insertCases', e);
            }
            DebugService.printDatabaseResults('TestSendContentVersionToGedService', 'insertCases', 'cases', results);
            DebugService.printLimits('TestSendContentVersionToGedService', 'insertCases', 'end');
        }
        DebugService.printLimits('TestSendContentVersionToGedService', 'insertCases', 'end empty results');
        return results;
    }
}