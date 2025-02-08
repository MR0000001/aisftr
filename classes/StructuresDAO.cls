/**
 * Created by LCONATO00 on 15/06/2020.
 */

public with sharing class StructuresDAO {
    public static List<Structure__c> getStructuresByIds(List<String> structuresId){
        List<Structure__c> structures = new List<Structure__c>();
        structures = [SELECT Id, TechMacrostructureId__c FROM Structure__c WHERE Id IN:structuresId];
        return structures;
    }
    public static List<Structure__c> getStructuresModifiedInTheLastHoursByWSO2(){
        List<Structure__c> structuresModified = new List<Structure__c>();
        Datetime forHoursAgo = datetime.now().addHours(-24);
        structuresModified = [SELECT Id, LastModifiedWSO2__c, IsDeleted__c FROM Structure__c WHERE LastModifiedWSO2__c <:forHoursAgo ORDER BY LastModifiedDate DESC  LIMIT 1];
        return structuresModified;
    }

    public static void deleteStructures(List<Structure__c> structures, Boolean allOrNone) {
        try {
            Database.DeleteResult[] results = Database.delete(structures, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            System.debug('Exception at StructuresDAO.deleteStructures: ' + e.getMessage());

            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }

    public static void updateStructures(List<Structure__c> structures, Boolean allOrNone) {
        try {
            Database.SaveResult[] results = Database.update(structures, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            System.debug('Exception at StructuresDAO.updateStructures: ' + e.getMessage());

            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }
}