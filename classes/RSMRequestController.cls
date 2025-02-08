public with sharing class RSMRequestController {
    @AuraEnabled
    public static boolean sendRequest(String caseToSendString) {
        Case caseToSend = CaseSelector.getCaseById(caseToSendString);
        List<Case> casesToSend = new List<Case>();
        casesToSend.add(caseToSend);
        List<Case> casesSent = RSMCallout.RSMCallout(casesToSend);
        return (!casesSent.isEmpty());
    }

    @AuraEnabled
    public static String getRsmQueue() {
        OrgManagement__c setting = OrgManagement__c.getOrgDefaults();
        Group rsmQueue = GroupsSelector.getGroupByName(setting.ZTL_Queue_API__c);
        return rsmQueue.Id;
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