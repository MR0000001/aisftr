/**
 * Created by SNEKKANTI00 on 22/12/2020.
 */

public with sharing class UserRoleSelector {
    public static String getParentRoleIdUserRoleId(String userRoleId) {
        String currentUserParentRoleId =  [SELECT DeveloperName, Name, ParentRoleId FROM UserRole WHERE ID =: userRoleId].ParentRoleId;

        return currentUserParentRoleId;
    }

    public static Map<id, UserRole> getUserRoleHierarchy() {
        Map<id, UserRole> userRoles = new Map<id, UserRole>([SELECT DeveloperName, Name, ParentRoleId FROM UserRole]);

        return userRoles;
    }
}