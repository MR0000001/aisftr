public without sharing class TA_LCC209_BaseWizardCnt {
    public TA_LCC209_BaseWizardCnt() {}

    @AuraEnabled
    public static Map<String, Object> initialize() {
        return new Map<String, Object> {
            'communityBaseUrl' => Site.getBaseUrl(),
            'userLanguage' => UserInfo.getLanguage() != null ? UserInfo.getLanguage().substring(0, 2) : 'it',
            'userName' => getUserName(),
            'userPermissionSetName' => getUserPermissionSetName()
        };
    }

    private static String getUserName() {
        return [SELECT FirstName FROM User WHERE Id =:UserInfo.getUserId()].FirstName;
    }

    public static String getUserPermissionSetName() {
        String currentUserPermissionSetName = '';
        List<PermissionSetAssignment> currentUserPermissionSets = [SELECT PermissionSet.Name
                                                                      FROM PermissionSetAssignment
                                                                      WHERE AssigneeId =: UserInfo.getUserId()
                                                                      AND PermissionSet.Description = 'TA_Configuration_Language'];

        if(!currentUserPermissionSets.isEmpty()) currentUserPermissionSetName = currentUserPermissionSets[0].PermissionSet.Name;
        return currentUserPermissionSetName;
    }
}