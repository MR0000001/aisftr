/**
 * @author Luigi Porcelli - luporcelli@deloitte.it
 * @description classes.XC_TR_User_U_ManageFederationId_TEST - Test class for XC_TR_User_U_ManageFederationId
 * @date Creation 10/02/2022
 */

@isTest
public without sharing class XC_TR_User_U_ManageFederationId_TEST {

    /**
     * @author Luigi Porcelli
     * @param 
     * @description Test for the positive cases, hence the cases where the trigger should work on.
     */
    @isTest
    public static void manageFederationId_TestPositive(){
        Profile pid = [SELECT ID, NAME FROM PROFILE WHERE NAME = 'XC_ITA_B2BG_CaringManager' LIMIT 1];
        String fedId = 'TP00000';
        //[Username, Email, Alias, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey]
        User u = new User(FirstName='Mario', LastName='Rossi', profileId=pid.id, FederationIdentifier=fedId, UserName = 'mruserfortesting2@fakeacc.com', 
        Email='fake@domain.com', Alias='guest', TimeZoneSidKey='GMT', LocaleSidKey='it_IT', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');

        Test.startTest();
        insert u;
        Test.stopTest();

        User checkUser = [SELECT NAME, FederationIdentifier, user_owner__c FROM USER WHERE FederationIdentifier LIKE :fedId LIMIT 1];
        System.assertEquals(fedId, checkUser.Name);
        System.assertEquals(checkUser.user_owner__c, 'Mario Rossi');
        
    }

    /**
     * @author Luigi Porcelli
     * @param 
     * @description Test for the negative cases, hence the cases where the trigger should NOT work on.
     */
    @isTest
    public static void manageFederationId_TestNegative(){
        Profile profileIds = [SELECT ID FROM PROFILE WHERE NAME LIKE 'XC_COL_BackOffice' LIMIT 1];
        User userNew = new User(profileId=profileIds.id, FirstName = 'Luigi', LastName='Verdi', FederationIdentifier = 'TN00001', Username='luigi@verdi.it',
        Email='fake@domain.com', Alias='guest', TimeZoneSidKey='GMT', LocaleSidKey='it_IT', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');

        Test.startTest();

        insert userNew;

        Test.stopTest();
        
        User checkUser = [SELECT NAME, FederationIdentifier, user_owner__c FROM USER WHERE FederationIdentifier ='TN00001' LIMIT 1];
        System.assertEquals(checkUser.Name, 'Luigi Verdi');
        System.assertEquals(checkUser.user_owner__c, null);
        
    }

    /**
     * @author Luigi Porcelli
     * @param 
     * @description Test for the cases where the federation identifier is blank, hence when the trigger should not work on the user(s)
     */
    @isTest
    public static void manageFederationId_TestBlankFederationId(){
        Profile profileIds = [SELECT ID FROM PROFILE WHERE NAME LIKE 'XC_ITA_B2BG_CaringAgent' LIMIT 1];
        User userNew = new User(profileId=profileIds.id, FirstName = 'Gianni', LastName='Gialli', Username='gianni@gialli.it',
        Email='fake@domain.com', Alias='guest', TimeZoneSidKey='GMT', LocaleSidKey='it_IT', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');

        Test.startTest();

        insert userNew;

        Test.stopTest();
        
        User checkUser = [SELECT NAME, FederationIdentifier, user_owner__c FROM USER WHERE Name LIKE 'Gianni Gialli' LIMIT 1];
        System.assertEquals(checkUser.Name, 'Gianni Gialli');
        System.assertEquals(checkUser.user_owner__c, null);
        System.assertEquals(checkUser.FederationIdentifier, null);
    }
}