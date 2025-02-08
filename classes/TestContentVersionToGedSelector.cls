/**
 * Created by snekkanti002 on 26/05/2022.
 */

@IsTest
public with sharing class TestContentVersionToGedSelector {

    @IsTest
    public static void getAllContentVersionToGeds() {
        Test.startTest();
        ContentVersionToGedSelector.getAllContentVersionToGeds();
        Test.stopTest();
    }

    @IsTest
    public static void getLimitedContentVersionToGeds() {
        Test.startTest();
        ContentVersionToGedSelector.getLimitedContentVersionToGeds(10);
        Test.stopTest();
    }

    @IsTest
    public static void getContentVersionToGedByCvIds() {
        Test.startTest();
        ContentVersionToGedSelector.getContentVersionToGedByCvIds(new List<String>());
        Test.stopTest();
    }

    @IsTest
    public static void insertContentVersionToGeds() {
        Test.startTest();
        ContentVersionToGedSelector.insertContentVersionToGeds(new List<ContentVersionToGed__c>(), true);
        Test.stopTest();
    }

    @IsTest
    public static void updateContentVersionToGeds() {
        Test.startTest();
        ContentVersionToGedSelector.updateContentVersionToGeds(new List<ContentVersionToGed__c>(), true);
        Test.stopTest();
    }

    @IsTest
    public static void deleteContentVersionToGeds() {
        Test.startTest();
        ContentVersionToGedSelector.deleteContentVersionToGeds(new List<String>(), true);
        Test.stopTest();
    }
}