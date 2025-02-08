/**
 * Created by SNEKKANTI00 on 22/02/2021.
 */

@isTest
public with sharing class TestSynonymousService {
    @testSetup static void setup() {
        TestDataFactory.createWSO2Keys();
    }

    @isTest
    public static void setSynonymousBackupAndManageCallouKOTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSynonimousKO());

        Test.startTest();
        List<Synonymous__c> synonymous = TestDataFactory.createSynonymous();

        synonymous[0].Synonym_value_1__c = 'xyz';
        synonymous[1].Synonym_value_2__c = 'zzz';

        UPDATE synonymous;
        Test.stopTest();
    }

    @isTest
    public static void setSynonymousBackupAndManageCallouSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSynonimous(200));

        Test.startTest();
        List<Synonymous__c> synonymous = TestDataFactory.createSynonymous();

        synonymous[0].Synonym_value_1__c = 'xyz';
        synonymous[1].Synonym_value_2__c = 'zzz';

        UPDATE synonymous;
        Test.stopTest();
    }

    @isTest
    public static void setSynonymousBackupAndManageCallouFailedTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSynonimous(400));

        Test.startTest();
        List<Synonymous__c> synonymous = TestDataFactory.createSynonymous();

        synonymous[0].Synonym_value_1__c = 'xyz';
        synonymous[1].Synonym_value_2__c = 'zzz';

        UPDATE synonymous;
        Test.stopTest();
    }
}