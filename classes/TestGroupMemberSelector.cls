/**
 * Created by SNEKKANTI00 on 03/02/2021.
 */

@isTest
public with sharing class TestGroupMemberSelector {
    @isTest
    public static void testGroupMemberSelector() {
        List<Group> groups = TestDataFactory.createGroups();
        List<GroupMember> groupMembers = TestDataFactory.createGroupMembers(groups);

        Test.startTest();
        GroupMemberSelector.getGroupMemberByUserId(groupMembers[0].UserOrGroupId);
        GroupMemberSelector.getGroupMembersNonExternalAndEtcByUserOrGroupIds(new Set<Id>{groupMembers[0].id});
        GroupMemberSelector.getGroupMemberQueuesNonExternalAndEtcByUserOrGroupIds(new Set<Id>{groupMembers[0].id});
        Test.stopTest();

    }
}