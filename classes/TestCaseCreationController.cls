/**
 * @author            : Daniel Perrella
 * @created date      : 10-11-2023
 * @description       : Classe di test per CaseCreationController e ComboboxOption
 * @testClasses       :
 * @last modified by  : Daniel Perrella
 * @last modified on  : 20-11-2023
 **/
@isTest
public with sharing class TestCaseCreationController {
  @TestSetup
  public static void setup() {
    insert new Case_Tag__c(Name = 'Test', Anomaly__c = true, isActive__c = true);
  }

  @isTest
  public static void TestOK() {
    String anomalyRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
      .get('Anomaly')
      .getRecordTypeId();
    Test.startTest();
    List<ComboboxOption> options = CaseCreationController.getCaseTag(anomalyRecordTypeId);
    System.debug(JSON.serialize(options));
    // Assert.areEqual(1, options.size());
    Test.stopTest();
  }
}