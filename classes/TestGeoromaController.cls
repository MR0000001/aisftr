/**
 * Created by snekkanti002 on 06/09/2022.
 */

@IsTest
public class TestGeoromaController {

    @TestSetup
    public static void setup() {
        TestDataFactory.createWSO2Keys();
    }

    @IsTest
    public static void getStreetsList() {
        Test.startTest();
        try {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeoroma(true));
            GeoromaController.getStreetsList('sartorio', '10');
        } catch (Exception e) {
            System.debug('Exception at getStreetsList: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    public static void getStreetDetails() {
        Test.startTest();
        try {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeoroma(true));
            GeoromaController.getStreetDetails('VIA GIUSEPPE PEREGO', '10');
        } catch (Exception e) {
            System.debug('Exception at getStreetDetails: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    public static void getStreetDetailsKO() {
        Test.startTest();
        try {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeoroma(false));
            GeoromaController.getStreetDetails('VIA GIUSEPPE PEREGO', '10');
        } catch (Exception e) {
            System.debug('Exception at getStreetDetails: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    public static void getGeoromaMetadata() {
        Test.startTest();
        try {
            GeoromaController.getGeoromaMetadata();
        } catch (Exception e) {
            System.debug('Exception at getGeoromaMetadata: ' + e.getMessage());
        }
        Test.stopTest();
    }
}