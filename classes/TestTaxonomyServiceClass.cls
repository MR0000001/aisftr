/**
 * Created by SNEKKANTI00 on 22/02/2021.
 */

@isTest
public with sharing class TestTaxonomyServiceClass {

    @testSetup static void setup() {
        TestDataFactory.createWSO2Keys();
    }

    @isTest
    public static void setTaxonomyBackupAndManageCallouSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseTaxonomy(200));

        Test.startTest();
        List<Taxonomy__c> taxes = TestDataFactory.createTaxonomys();
        Map<Id, Taxonomy__c> oldMap = new Map<Id, Taxonomy__c>();

        for(Taxonomy__c tax : taxes) {
            oldMap.put(tax.id, tax);
        }

        for(Taxonomy__c tax : taxes) {
            tax.Tax_Geolocalization__c = true;
            tax.Tax_Timestamp_Chiamata_CDC__c = Datetime.Now();
        }

        TaxonomyService.setTaxonomyBackupAndManageCallout(taxes, oldMap);
        Test.stopTest();
    }

    @isTest
    public static void setTaxonomyBackupAndManageCallouFailedTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseTaxonomy(400));

        Test.startTest();
        List<Taxonomy__c> taxes = TestDataFactory.createTaxonomys();

        for(Taxonomy__c tax : taxes) {
            tax.Tax_Geolocalization__c = true;
        }

        UPDATE taxes;
        Test.stopTest();
    }

    @isTest
    public static void clearBackupFieldsTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseTaxonomy(400));

        Test.startTest();
        List<Taxonomy__c> taxes = TestDataFactory.createTaxonomys();

        TaxonomyService.clearBackupFields(taxes[0]);

        Test.stopTest();
    }
}