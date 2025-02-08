/**
 * Created by LCONATO00 on 01/06/2020.
 */

public with sharing class RoleDAO {
    public static List<Role__c> getRolesByEmployeeSerialNumberAndStructureId(String employeeSerialNumber){
        List<Role__c> roles = new List<Role__c>();
        roles = [SELECT Id, StructureId__c, StructureId__r.TechMacrostructureId__c FROM Role__c WHERE EmployeeId__r.SerialNumber__c =: employeeSerialNumber];
        return roles;
    }
    public static List<Role__c> getRolesModifiedInTheLastHoursByWSO2(){
        List<Role__c> rolesModified = new List<Role__c>();
        Datetime forHoursAgo = datetime.now().addHours(-24);
        rolesModified = [SELECT Id, LastModifiedWSO2__c, IsDeleted__c FROM Role__c WHERE LastModifiedWSO2__c <:forHoursAgo ORDER BY LastModifiedDate DESC  LIMIT 1];
        return rolesModified;
    }

    public static void deleteRoles(List<Role__c> roles, Boolean allOrNone) {
        try {
            Database.DeleteResult[] results = Database.delete(roles, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            System.debug('Exception at RoleDAO.deleteRoles: ' + e.getMessage());

            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }

    public static void updateRoles(List<Role__c> roles, Boolean allOrNone) {
        try {
            Database.SaveResult[] results = Database.update(roles, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            System.debug('Exception at RoleDAO.updateRoles: ' + e.getMessage());

            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }
}