/**
 * Created by snekkanti002 on 14/09/2021.
 */

@IsTest
public with sharing class TestOpenDataService {
    @IsTest
    public static void getIdQueryMap() {
        Map<String, OpenData_Setting__mdt> settings = OpenData_Setting__mdt.getAll();
        Map<String, String> settingIdQueryMap = OpenDataService.getSettingIdQueryMap();

        Test.startTest();
        OpenDataService.getIdQueryMap(settings.values(), settingIdQueryMap);
        Test.stopTest();
    }

    @IsTest
    public static void getIdFieldsMap() {
        Map<String, OpenData_Setting__mdt> settings = OpenData_Setting__mdt.getAll();

        Test.startTest();
        OpenDataService.getIdFieldsMap(settings.values(), 2);
        Test.stopTest();
    }

    @IsTest
    public static void insertOpenDataLogs() {
        Test.startTest();
        OpenDataService.insertOpenDataLogs(new List<Opendata_log__c>{new Opendata_log__c()}, false);
        Test.stopTest();
    }

    @IsTest
    public static void createOpenDataLogs() {

        RequestOpenDataWebService requestOpenDataWebService = TestDataFactory.createOpenDataWebService();

        Map<String, RequestOpenDataWebService.Esiti> outcomeIdOutcomeMap = new Map<String, RequestOpenDataWebService.Esiti>();

        outcomeIdOutcomeMap.put('1', requestOpenDataWebService.Esiti[0]);

        Test.startTest();
        OpenDataService.createOpenDataLogs(outcomeIdOutcomeMap);
        Test.stopTest();
    }
}