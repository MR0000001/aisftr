/**
 * Created by SNEKKANTI00 on 09/02/2021.
 */

@IsTest
public with sharing class TestMesisCallout {
    @TestSetup static void setup() {
        TestDataFactory.createWSO2Keys();
    }

    @IsTest
    public static void mesisCalloutTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMesis());

        Test.startTest();
        MesisCallout.mesisCallout('NNNNLL69L58G813K', '392');
        Test.stopTest();
    }
}