/**
 * Created by SNEKKANTI00 on 17/12/2020.
 */

@isTest
private with sharing class TestAnagraficaCallout {
    @testSetup static void setup() {
        TestDataFactory.createWSO2Keys();
    }

    @isTest
    private static void AnagraficaCalloutTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAnagrafica());

        Test.startTest();
        AnagraficaCallout.anagraficaCallout(2, 0, 'SLRMCL77S60H501S', null, null, null, 0, 0, 0);
        Test.stopTest();
    }

    @isTest
    private static void AnagraficaCalloutKOTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAnagraficaKO());

        Test.startTest();
        AnagraficaCallout.anagraficaCallout(2, 0, 'SLRMCL77S60H501S', null, null, null, 0, 0, 0);
        Test.stopTest();
    }

}