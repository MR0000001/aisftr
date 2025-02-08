/**
 * Created by SNEKKANTI00 on 02/02/2021.
 */
@isTest
public with sharing class TestUserRoleSelector {

    @isTest
    public static void testUserRoleSelector() {
        List<UserRole> parentRoles = TestDataFactory.createParentUserRole();
        TestDataFactory.createUserRole(parentRoles[0].id);

        Test.startTest();
        UserRoleSelector.getParentRoleIdUserRoleId(parentRoles[0].id);
        UserRoleSelector.getUserRoleHierarchy();
        Test.stopTest();
    }

}