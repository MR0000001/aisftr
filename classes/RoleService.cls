/**
 * Created by LCONATO00 on 06/05/2020.
 */

public with sharing class RoleService {
    public static void TriggerHandlerPopolateBeforeInsertBeforeUpdate(List<Role__c> listRoles){
        if(EmployeeService.isNotWSO2()){
            return;
        }
        Datetime nowDatetime = Datetime.now();
        for(Role__c role : listRoles){
            role.LastModifiedWSO2__c = nowDatetime;
            role.IsDeleted__c = false;
        }
    }

    public static void deleteRoles(List<Role__c> roles, Boolean allOrNone) {
        if(roles != null && !roles.isEmpty()) RoleDAO.deleteRoles(roles, allOrNone);
    }

    public static void updateRoles(List<Role__c> roles, Boolean allOrNone) {
        if(roles != null && !roles.isEmpty()) RoleDAO.updateRoles(roles, allOrNone);
    }
}