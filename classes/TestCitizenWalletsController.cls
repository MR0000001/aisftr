/**
 * Created by SNEKKANTI00 on 11/06/2021.
 */

@IsTest
public with sharing class TestCitizenWalletsController {
    @TestSetup
    public static void setup() {
        TestDataFactory.createWSO2Keys();
        TestDataFactory.createCitizenWalletsTables();
    }

    @IsTest
    public static void getCitizenWalletsOK() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCitizenWallet('OK'));

        Test.startTest();
        CitizenWalletsController.getCitizenWallets('0280092416710000218857295764336494');
        Test.stopTest();
    }
}