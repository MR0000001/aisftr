public with sharing class SynonymousSelector {
    public static List<Synonymous__c> getSynonymous(){
        List<Synonymous__c> synonymous = new List<Synonymous__c>();
        synonymous = [SELECT Name, Taxonomy_Value__c, Synonym_value_1__c, Synonym_value_10__c, Synonym_value_2__c, Synonym_value_3__c, Synonym_value_4__c, Synonym_value_5__c, Synonym_value_6__c, Synonym_value_7__c, Synonym_value_8__c, Synonym_value_9__c FROM Synonymous__c];
        return synonymous;
    }
}