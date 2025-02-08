/**
 * Created by snekkanti002 on 11/07/2022.
 */

@IsTest
public with sharing class TestRequestOpenData {
    @IsTest
    public static void requestOpenData() {
        Test.startTest();
        new RequestOpenData(new Map<String, OpenData_Setting__mdt>(), new Map<String, String>());
        Test.stopTest();
    }
}