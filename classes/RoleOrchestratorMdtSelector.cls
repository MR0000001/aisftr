/**
 * Created by SNEKKANTI00 on 24/05/2021.
 */

public with sharing class RoleOrchestratorMdtSelector {
    private static List<Role_Orchestrator__mdt> roles = new List<Role_Orchestrator__mdt>();

    public static List<Role_Orchestrator__mdt> getAllRoles() {
        roles = [SELECT Label, DeveloperName FROM Role_Orchestrator__mdt ORDER BY Label];

        return roles;
    }
}