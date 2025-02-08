/**
 * Created by SNEKKANTI00 on 27/04/2021.
 */

@isTest
public with sharing class TestStructuresDAO {

    @TestSetup
    public static void setup() {
        TestDataFactory.listStructures();
    }

    @isTest
    public static void getStructuresByIds() {
        List<Structure__c> structures = [SELECT id FROM Structure__c];

        Test.startTest();
        StructuresDAO.getStructuresByIds(new List<String>{structures[0].id});
        Test.stopTest();
    }

    @isTest
    public static void getStructuresModifiedInTheLastHoursByWSO2() {
        Test.startTest();
        StructuresDAO.getStructuresModifiedInTheLastHoursByWSO2();
        Test.stopTest();
    }

    @isTest
    public static void deleteStructures() {
        List<Structure__c> structures = [SELECT id FROM Structure__c];

        Test.startTest();
        StructuresDAO.deleteStructures(structures, false);
        Test.stopTest();
    }

    @isTest
    public static void updateStructures() {
        Structure__c structure = new Structure__c();

        List<Structure__c> structures = [SELECT id FROM Structure__c];

        Test.startTest();
        StructuresDAO.updateStructures(structures, false);
        structures.add(structure);
        StructuresDAO.updateStructures(structures, true);
        Test.stopTest();
    }
}