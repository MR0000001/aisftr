/**
 * Created by snekkanti002 on 03/08/2021.
 */

@IsTest
public with sharing class TestOpenDataCallout {

    @TestSetup
    public static void setup() {
        TestDataFactory.createWSO2Keys();
    }

    @IsTest
    public static void openDataCallout() {
        String sch = '0 00 * * * ?';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseOpenData());

        Test.startTest();
        System.schedule('TestOpenDataCallout', sch, new OpenDataCallout());
        Test.stopTest();
    }
}