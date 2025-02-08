/**
 * Created by SNEKKANTI00 on 11/06/2021.
 */

@IsTest
public with sharing class TestCitizenWalletCardInfoCallout {
    @TestSetup
    public static void setup() {
        TestDataFactory.createWSO2Keys();
    }

    @IsTest
    public static void citizenWalletCardInfoCalloutOK() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCitizenWallet('OK'));

        Test.startTest();
        try {
            CitizenWalletCardInfoCallout.citizenWalletCardInfoCallout('0280092416710000218857295764336494');
        } catch(Exception e) {
            System.debug('Exception at TestCitizenWalletCardInfoCallout.citizenWalletCardInfoCalloutOK: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    public static void citizenWalletCardInfoCalloutKO() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCitizenWallet('KO'));

        Test.startTest();
        try {
            CitizenWalletCardInfoCallout.citizenWalletCardInfoCallout('0280092416710000218857295764336494');
        } catch(Exception e) {
            System.debug('Exception at TestCitizenWalletCardInfoCallout.citizenWalletCardInfoCalloutKO: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    public static void citizenWalletCardInfoCalloutException() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCitizenWallet('exception'));

        Test.startTest();
        try {
            CitizenWalletCardInfoCallout.citizenWalletCardInfoCallout('0280092416710000218857295764336494');
        } catch(Exception e) {
            System.debug('Exception at TestCitizenWalletCardInfoCallout.citizenWalletCardInfoCalloutException: ' + e.getMessage());
        }
        Test.stopTest();
    }
}