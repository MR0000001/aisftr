public with sharing class ModalitiesSelector {
    public static List<Modalit_Passaggio__mdt > getModalityByActionAndRole(String role, String action) {
        List<Modalit_Passaggio__mdt > modalities = [SELECT Label, DeveloperName FROM Modalit_Passaggio__mdt  WHERE Azione__c =: action AND Operatore__c =: role];
        return modalities;
    }
}