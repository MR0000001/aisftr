/**
 * Created by SNEKKANTI00 on 03/02/2021.
 */

@isTest
public with sharing class TestAUCCallout {
    @testSetup static void setup() {
        TestDataFactory.createWSO2Keys();
    }

    @isTest
    public static void aucCalloutTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAUC());

        Test.startTest();
        AUCCallout.AUCCallout('SLRMCL77S60H501S', 0, '1987', '');
        Test.stopTest();
    }
}