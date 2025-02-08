public with sharing class AmaRequestController {
    @AuraEnabled
    public static List<Case> sendRequest(String caseToSendString) {
        system.debug('@@@ caseToSendString '+caseToSendString);
        Case caseToSend = CaseSelector.getCaseById(caseToSendString);
        List<Case> casesToSend = new List<Case>();
        casesToSend.add(caseToSend);
        List<Case> casesSent = AMACallout.AMACallout(casesToSend, true);
        return casesSent;
    }

    @AuraEnabled
    public static String getAmaQueue() {
        //sendToAMA
        OrgManagement__c setting = OrgManagement__c.getOrgDefaults();
        Group amaQueue = GroupsSelector.getGroupByName(setting.AMA_Queue_API__c);
        return amaQueue.Id;
    }

    @AuraEnabled
    public static List<String> getAnonymousIds() {
        List<String> anonIds = new List<String>();
        OrgManagement__c setting = OrgManagement__c.getOrgDefaults();
        if(setting?.AnonymuosID_del__c != null) anonIds.add(setting.AnonymuosID_del__c);
        if(setting?.Anonymous_ContactID__c != null) anonIds.add(setting.Anonymous_ContactID__c);

        if(!anonIds.isEmpty()) return anonIds;

        return null;
    }
}