/**
 * Created by SNEKKANTI00 on 09/12/2020.
 */

@isTest
private with sharing class TestIntegrazioneNICCallout {
    @isTest
    private static void integrazioneNICCalloutTest() {

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseIntegrazioneNIC());

        test.startTest();
        IntegrazioneNICCallout.IntegrazioneNICCallout('41.830142', '12.494440');
        test.stopTest();
    }

    @isTest
    private static void integrazioneNICCalloutErrorKOTest() {

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseIntegrazioneNICKO());

        test.startTest();
        IntegrazioneNICCallout.IntegrazioneNICCallout('', '12.494440');
        test.stopTest();
    }
    @isTest
    private static void integrazioneNICCalloutErrorTest() {

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseIntegrazioneNIC());

        test.startTest();
        IntegrazioneNICCallout.IntegrazioneNICCallout('', '12.494440');
        test.stopTest();
    }
}