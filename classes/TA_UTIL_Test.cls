/**
 * Created by alericci on 17/12/2020.
 */
@isTest
public with sharing class TA_UTIL_Test {
    @isTest

    public static void loadSetup() {
        List<PermissionSetAssignment> permSetAss = [SELECT AssigneeId FROM PermissionSetAssignment WHERE (PermissionSet.Label = 'Italy Set')];
        if(!permSetAss.isEmpty()) {
            delete permSetAss;
        }
        List<PermissionSet> permSet = [SELECT id FROM PermissionSet WHERE Name = 'Italy_Set'];
        if(!permSet.isEmpty()) {
            delete permSet;
        }
        String confSet = 'Italy_Set';
        PermissionSet p = new PermissionSet(Name = confSet, Label = 'Italy Set', Description = 'TA_Configuration_Language');
        insert p;
        PermissionSetAssignment pa = new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = p.Id);

        insert pa;
    }
    // @isTest
    // public static void loadSetupB2G() {
    //     List<PermissionSetAssignment> permSetAss = [SELECT AssigneeId FROM PermissionSetAssignment WHERE (PermissionSet.Label = 'B2G_Italy_Set')];
    //     if(!permSetAss.isEmpty()) {
    //         delete permSetAss;
    //     }
    //     List<PermissionSet> permSet = [SELECT id FROM PermissionSet WHERE Name = 'B2G_Italy_Set'];
    //     if(!permSet.isEmpty()) {
    //         delete permSet;
    //     }    
        
    //     PermissionSet p = new PermissionSet(Name = 'B2G_Italy_Set', Label = 'B2G_Italy_Set', Description = 'TA_Configuration_Language');
    //     insert p;
    //     PermissionSetAssignment pa = new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = p.Id);
    //     insert pa;
    // }
}