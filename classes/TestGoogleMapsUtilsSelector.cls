/**
 * Created by SNEKKANTI00 on 03/02/2021.
 */
@isTest
public with sharing class TestGoogleMapsUtilsSelector {
    @testSetup static void setup() {
        TestDataFactory.createGoogleMaps();
    }

    @isTest
    public static void googleMapsUtilsSelectorTest() {
        Test.startTest();
        GoogleMapsUtilsSelector.GoogleMapsUtilsSelector();
        Test.stopTest();
    }
}