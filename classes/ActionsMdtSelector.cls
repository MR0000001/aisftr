public with sharing class ActionsMdtSelector {
    public static List<Azioni_Gestione_Case__mdt> getActionsByOperator(String operator) {
        List<Azioni_Gestione_Case__mdt> actions = [SELECT Label, DeveloperName FROM Azioni_Gestione_Case__mdt WHERE Operatore__c =: operator ORDER BY Label];
        return actions;

    }
}