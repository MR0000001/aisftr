/**
 * @author            : Daniel Perrella
 * @created date      : 09-11-2023
 * @description       : Classe che crea le options da mostrare nel componente lwc caseCreation nel caso di campo Case_Tag__c
 * @testClasses       : TestCaseCreationController
 * @last modified by  : Daniel Perrella
 * @last modified on  : 13-11-2023
 **/
public with sharing class CaseCreationController {
  @AuraEnabled
  public static List<ComboboxOption> getCaseTag(String recordTypeId) {
    List<ComboboxOption> options = new List<ComboboxOption>();
    options.add(new ComboboxOption(System.Label.None));
    // La logica per querare i record del custom setting Case_Tag__c è prendere il developer name per recordtype passato
    // e filtrare sul campo che si chiama uguale sul custom setting
    String caseTagField = Schema.SObjectType.Case.getRecordTypeInfosById().get(recordTypeId).getDeveloperName() + '__c';

    if (Schema.SObjectType.Case_Tag__c.fields.getMap().keySet().contains(caseTagField.toLowerCase())) {
      String query = 'SELECT Name FROM Case_Tag__c WHERE isActive__c = true AND ' + caseTagField + ' = true';
      for (Case_Tag__c tag : Database.query(query)) {
        options.add(new ComboboxOption(tag.Name));
      }
    }
    return options;
  }
}