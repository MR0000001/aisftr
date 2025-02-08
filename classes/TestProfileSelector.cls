/**
 * Created by SNEKKANTI00 on 28/04/2021.
 */

@isTest
public with sharing class TestProfileSelector {

    @isTest
    public static void getProfileNameById() {
        String profileId = [SELECT Id FROM Profile LIMIT 1].Id;

        Test.startTest();
        ProfileSelector.getProfileNameById(profileId);
        ProfileSelector.getProfileNameById('');
        Test.stopTest();
    }
}