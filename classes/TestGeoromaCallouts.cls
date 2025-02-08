/**
 * Created by snekkanti002 on 07/09/2022.
 */

@IsTest
public without sharing class TestGeoromaCallouts {

    @TestSetup
    public static void setup() {
        TestDataFactory.createWSO2Keys();
    }

    @IsTest
    public static void getStreetsListCallout() {
        Test.startTest();
        try {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeoroma(true));
            GeoromaCallouts.getStreetsListCallout('?indirizzo=sartorio&page=1&size=10');
        } catch (Exception e) {
            System.debug('Exception at getStreetsListCallout: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    public static void getStreetDetailsCallout() {
        Test.startTest();
        try {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeoroma(true));
            GeoromaCallouts.getStreetDetailsCallout('VIA GIUSEPPE PEREGO', '10');
        } catch (Exception e) {
            System.debug('Exception at getStreetDetailsCallout: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    public static void getStreetDetailsCalloutKO() {
        Test.startTest();
        try {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeoroma(false));
            GeoromaCallouts.getStreetDetailsCallout('VIA GIUSEPPE PEREGO', '10');
        } catch (Exception e) {
            System.debug('Exception at getStreetDetails: ' + e.getMessage());
        }
        Test.stopTest();
    }
}