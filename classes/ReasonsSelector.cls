public with sharing class ReasonsSelector {
    public static List<Motivo__mdt> getReasonByActionAndRole(String role, String action) {
        List<Motivo__mdt> reasons = [SELECT Label, DeveloperName FROM Motivo__mdt WHERE Azione__c =: action AND Operatore__c =: role];
        return reasons;
    }
}