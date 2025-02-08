/**
* @author Nicola Mariniello nmariniello@deloitte.it
* @date Creation 12/07/2021
* @date Modification
* @description XC_TR_CatalogItem_TEST – Test Class for XC_TR_CatalogItem_Handler and XC_TR_CatalogItem_U_CheckWBEFields
*/ 


@isTest
public with sharing class XC_TR_CatalogItem_TEST {


    @testsetup
    static void setup() {

        XC_CS_UtilityGlobalValues__c a = new XC_CS_UtilityGlobalValues__c();
        a.Name = 'CheckBlankValuesWBE';
        a.Value__c = 'true';
        insert a;
        XC_CS_UtilityGlobalValues__c b = new XC_CS_UtilityGlobalValues__c();
        b.Name = 'CheckWBETracking';
        b.Value__c = 'true';
        insert b;
        XC_CS_UtilityGlobalValues__c c = new XC_CS_UtilityGlobalValues__c();
        c.Name = 'CheckWBEBasedOnExcludedCatalog';
        c.Value__c = 'AAA';
        insert c;
    }


    @isTest
    static void testHandler() {

        NE__Catalog_Item__c ci = XC_DF_CatalogItem.createCatalogItem();
        ci.NE__Type__c = 'Equipment';
        
        Test.startTest();
        insert ci;
        update ci;
        delete ci;
        Test.stopTest();
    }


    @isTest
    static void testMissingFieldsForProduct() {

        NE__Catalog_Item__c ci = XC_DF_CatalogItem.createCatalogItem();
        ci.NE__Active__c = true;
        ci.NE__Visible__c = true;
        ci.NE__Type__c = Label.XC_CL_ProductSubTypeValue;
        
        Test.startTest();
        try{
            insert ci;
        } catch (Exception e) {
            System.debug('ERROR MISSING FIELDS');
        }
        Test.stopTest();
    }


    @isTest
    static void testMissingWBETracking() {

        NE__Catalog_Item__c ci = XC_DF_CatalogItem.createCatalogItem();
        ci.NE__Active__c = true;
        ci.NE__Visible__c = true;
        ci.NE__Type__c = Label.XC_CL_ProductSubTypeValue;
        ci.XC_CostCenter__c = 'AAA';
        ci.XC_ProfitCenter__c = 'AAA';
        ci.XC_ProductServiceType__c = 'AAA';
        ci.XC_ProductLine__c = 'A100';
        
        Test.startTest();
        try{
            insert ci;
        } catch (Exception e) {
            System.debug('ERROR MISSING WBE TRACKING RECORD');
        }
        Test.stopTest();
    }


    @isTest
    static void onUpdateFields() {

        XC_CS_UtilityGlobalValues__c b = [SELECT Id FROM XC_CS_UtilityGlobalValues__c WHERE Name = 'CheckWBETracking' LIMIT 1];
        b.Value__c = 'false';
        update b;

        NE__Catalog_Item__c ci = XC_DF_CatalogItem.createCatalogItem();
        ci.NE__Active__c = true;
        ci.NE__Visible__c = true;
        ci.NE__Type__c = 'Equipment';
        insert ci;

        ci.XC_CostCenter__c = 'AAA';
        ci.XC_ProfitCenter__c = 'AAA';
        ci.XC_ProductServiceType__c = 'AAA';
        ci.XC_ProductLine__c = '';
        
        Test.startTest();
        try{
            update ci;
        } catch (Exception e) {
            System.debug('ERROR MISSING FIELDS ON UPDATE');
        }
        Test.stopTest();
    }

}