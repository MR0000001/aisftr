/**
 * Created by SNEKKANTI00 on 11/06/2021.
 */

@IsTest
public with sharing class TestCitizenWalletTransactionsCallout {
    @TestSetup
    public static void setup() {
        TestDataFactory.createWSO2Keys();
    }

    @IsTest
    public static void citizenWalletTransactionsCalloutOK() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCitizenWallet('OK'));

        Test.startTest();
        try {
            CitizenWalletTransactionsCallout.citizenWalletTransactionsCallout('0280092416710000218857295764336494');
        } catch(Exception e) {
            System.debug('Exception at TestCitizenWalletTransactionsCallout.citizenWalletTransactionsCalloutOK: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    public static void citizenWalletTransactionsCalloutKO() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCitizenWallet('KO'));

        Test.startTest();
        try {
            CitizenWalletTransactionsCallout.citizenWalletTransactionsCallout('0280092416710000218857295764336494');
        } catch(Exception e) {
            System.debug('Exception at TestCitizenWalletTransactionsCallout.citizenWalletTransactionsCalloutKO: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    public static void citizenWalletTransactionsCalloutException() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCitizenWallet('exception'));

        Test.startTest();
        try {
            CitizenWalletTransactionsCallout.citizenWalletTransactionsCallout('0280092416710000218857295764336494');
        } catch(Exception e) {
            System.debug('Exception at TestCitizenWalletTransactionsCallout.citizenWalletTransactionsCalloutException: ' + e.getMessage());
        }
        Test.stopTest();
    }
}