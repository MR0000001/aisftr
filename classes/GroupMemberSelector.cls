public with sharing class GroupMemberSelector {
    public static List<GroupMember> getGroupMemberByUserId(String userId){
        List<GroupMember> groupMembers = [select groupId from GroupMember where UserOrGroupId=:userId];
        return groupMembers;
    }
    
    public static List<GroupMember> getGroupMembersNonExternalAndEtcByUserOrGroupIds(Set<Id> userOrGroupIds) {
        system.debug('getGroupMembersNonExternalAndEtcByUserOrGroupIds-userOrGroupIds -> '+userOrGroupIds);
        List<GroupMember> groupMembers = [SELECT groupId, UserOrGroupId, Group.Type
                                          FROM GroupMember 
                                          WHERE UserOrGroupId IN: userOrGroupIds AND (Group.type = 'Regular' OR  Group.type = 'Queue')
                                          AND (NOT Group.DeveloperName LIKE '%External%')
                                          AND (NOT Group.DeveloperName LIKE '%ETC%')
                                         ];
        return groupMembers;
    }
    public static List<GroupMember> getGroupMembersExcludeCustomSettingsListByUserOrGroupIds(Set<Id> userOrGroupIds) {
        system.debug('getGroupMembersExcludeCustomSettingsListByUserOrGroupIds-userOrGroupIds -> '+userOrGroupIds);
        List<Current_Queue_Excluded_List__c> cqel = Current_Queue_Excluded_List__c.getall().values();
        system.debug('cqel -> '+ cqel);
        String inClause= '';
        for (Current_Queue_Excluded_List__c single_cqel: cqel ) {
            inClause += ' AND (NOT Group.DeveloperName LIKE \'%'+single_cqel.Name+'%\')';
        }
        system.debug('inClause -> '+ inClause);

        String query = 'SELECT groupId, UserOrGroupId, Group.Type FROM GroupMember WHERE (Group.type = \'Regular\' OR  Group.type = \'Queue\')' + inClause;

        if ( userOrGroupIds != null && userOrGroupIds.size() > 0 ) {
            String finalListIds = '';
            for(Id singleUserOrGroupIds: userOrGroupIds ) {
                finalListIds += '\'' + singleUserOrGroupIds + '\', ';
            }
            finalListIds = finalListIds.left(finalListIds.length()-2);

            query += ' AND UserOrGroupId IN ('+finalListIds+')';
        } else {
            query += ' AND UserOrGroupId IN (null)';
        }

        system.debug('query -> '+ query);
        List<GroupMember> groupMembers = Database.query(query);

        return groupMembers;
    }

    public static List<GroupMember> getGroupMemberQueuesNonExternalAndEtcByUserOrGroupIds(Set<Id> userOrGroupIds) {
        List<GroupMember> groupMembers = [SELECT groupId, UserOrGroupId, Group.Type
                                          FROM GroupMember 
                                          WHERE UserOrGroupId IN: userOrGroupIds
                                          AND Group.Type = 'Queue'
                                          AND (NOT Group.DeveloperName LIKE '%External%') 
                                          AND (NOT Group.DeveloperName LIKE '%ETC%')
                                         ];
        return groupMembers;
    }

    public static List<GroupMember> getGroupMemberQueuesExcludeCustomSettingsListByUserOrGroupIds(Set<Id> userOrGroupIds) {
        system.debug('getGroupMemberQueuesNonCustomSettingsListByUserOrGroupIds-userOrGroupIds -> '+userOrGroupIds);
        List<Current_Queue_Excluded_List__c> cqel = Current_Queue_Excluded_List__c.getall().values();
        system.debug('cqel -> '+ cqel);
        String inClause= '';
        for (Current_Queue_Excluded_List__c single_cqel: cqel ) {
            inClause += ' AND (NOT Group.DeveloperName LIKE \'%'+single_cqel.Name+'%\')';
        }
        system.debug('inClause -> '+ inClause);

        String query = 'SELECT groupId, UserOrGroupId, Group.Type FROM GroupMember WHERE Group.Type = \'Queue\'' + inClause;
        if ( userOrGroupIds != null && userOrGroupIds.size() > 0 ) {
            String finalListIds = '';
            for(Id singleUserOrGroupIds: userOrGroupIds ) {
                finalListIds += '\'' + singleUserOrGroupIds + '\', ';
            }
            finalListIds = finalListIds.left(finalListIds.length()-2);

            query += ' AND UserOrGroupId IN ('+finalListIds+')';
        } else {
            query += ' AND UserOrGroupId IN (null)';
        }

        system.debug('query -> '+ query);
        List<GroupMember> groupMembers = Database.query(query);

        return groupMembers;
    }
}