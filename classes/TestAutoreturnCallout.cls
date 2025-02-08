/**
 * Created by snekkanti002 on 11/11/2022.
 */

@IsTest
private class TestAutoreturnCallout {

    @TestSetup
    public static void setup() {
        TestDataFactory.createWSO2Keys();
    }

    @IsTest
    public static void autoreturnCallout() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAutoreturn());

        Test.startTest();
        AutoreturnCallout.autoreturnCallout('FK527MH');
        Test.stopTest();
    }
}