/**
 * Created by snekkanti002 on 14/09/2021.
 */

@IsTest
public with sharing class TestOpenDataSelector {

    @IsTest
    public static void insertOpenDataLogs() {
        Opendata_log__c opendataLog = new Opendata_log__c();

        Test.startTest();
        OpenDataSelector.insertOpenDataLogs(new List<Opendata_log__c>{opendataLog}, false);
        OpenDataSelector.insertOpenDataLogs(new List<Opendata_log__c>{opendataLog}, true);
        Test.stopTest();
    }
}