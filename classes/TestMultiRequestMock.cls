/**
 * Created by SNEKKANTI00 on 04/02/2021.
 */
@isTest
public with sharing class TestMultiRequestMock {
    @isTest
    public static void multiRequestMockTest() {
        Test.startTest();
        MultiRequestMock mock = new MultiRequestMock(new Map<String, HttpCalloutMock>());
        mock.respond(new HttpRequest());
        mock.addRequestMock('', mock);
        Test.stopTest();
    }
}