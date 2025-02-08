public with sharing class GroupsSelector {
    public static List<Group> getGroupsByName(String groupName) {
        List<Group> queriedGroup = [SELECT Id FROM Group WHERE Name =: groupName LIMIT 1];
        return queriedGroup;
    }
    public static List<Group> getQueuesByDevNames(List<String> groupNames) {
        List<Group> groups = [SELECT Id,DeveloperName FROM Group WHERE DeveloperName IN: groupNames ];
        return groups;
    }
    public static List<Group> getAllQueues() {
        List<Group> groups = [SELECT Id,Name FROM Group];
        return groups;
    }
    public static List<Group> getGroupsByIds(Set<String> groupsIds){
        List<Group> groups = [select id,name,developerName,Email from Group WHERE Id IN: groupsIds ORDER BY Name];
        return groups;
    }
    public static Group getGroupByName(String name) {
        Group queriedGroup = [SELECT id, DeveloperName  from Group WHERE DeveloperName =: name LIMIT 1];
        return queriedGroup;
    }

    public static List<Group> getGroupsByRelatedId(String currentUserRoleId, List<String> ancestralRoleIds) {
        String query = 'SELECT Name, developerName FROM Group ';
        query += 'WHERE (relatedId =: currentUserRoleId AND (Type = \'Role\' OR Type = \'RoleAndSubordinates\'))';
        query += (!ancestralRoleIds.isEmpty()) ? ' OR (relatedId IN: ancestralRoleIds AND Type = \'RoleAndSubordinates\')' : '';

        System.debug('query: ' + query);
        List<Group> groups = Database.query(query);
        return groups;
    }

    public static List<Group> getGroupsByType(String typeName) {
        List<Group> resultGroups = [ SELECT DeveloperName,Id,Name,OwnerId,RelatedId,Type FROM Group WHERE Type =: typeName];
        return resultGroups;
    }
}