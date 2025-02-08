/**
* @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 05/03/2019
* @description XC_SC010_PopulateSkillsOnResources – Batch used to automatically populate skills on Service Resources based on Documents in XC_ServiceResourceDocument__c 
*/

public with sharing class XC_SC010_PopulateSkillsOnResources implements Schedulable, Database.Batchable<sObject> {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC010_PopulateSkillsOnResources');

    /**
     * @description execute method
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC010_PopulateSkillsOnResources(), 100);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'batch XC_SC010_PopulateSkillsOnResources ID ' + batchId); 
    }

    /**
     * @description start method
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, XC_ServiceResource__c FROM XC_ServiceResourceDocument__c WHERE SystemModstamp = TODAY and XC_ServiceResource__r.XC_LegalEntity__c =\'EndesaX\' ORDER BY XC_ServiceResource__c';
        return Database.getQueryLocator(query);
    }

    /** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<XC_ServiceResourceDocument__c> scope) {
        Map<Id, ServiceResource> mapServiceResource = XC_SC010_PopulateSkillsOnResources_U.getMapServiceResource(scope);
        Map<String, List<XC_SkillDocumentAssociation__c>> mapRecordTypeListSkillDocAss = XC_SC010_PopulateSkillsOnResources_U.getMapRecordTypeListSkillDocAss();
        XC_SC010_PopulateSkillsOnRes_U_Populate.executePopulateSkillOnResource(mapRecordTypeListSkillDocAss, mapServiceResource);   
    }   

    /**
     * @description finish method
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, ' finish ');
        //Database.executeBatch(new XC_SC014_RemoveTerritoryExpiredSkills(), 150); 
        Database.executeBatch(new XC_SC018_CreateCaseFromOverall(), 150); 
    }    
}