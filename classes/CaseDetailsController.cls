global with sharing class CaseDetailsController {
    public CaseDetailsController(ApexPages.StandardController stdController) {}
        /*GoogleMaps__c gmaps = getGoogleMaps();
        this.library = 'https://maps.googleapis.com/maps/api/js?key=' + gmaps.Google_Key__c + '&callback=initMap&libraries=drawing,places&v=weekly';
        this.vfOrigin = gmaps.Domain__c;
    }
    public String library { get; set; }
    public String vfOrigin { get; set; }
    @AuraEnabled
    global static GoogleMaps__c getGoogleMaps() {
        GoogleMaps__c gmaps = GoogleMapsUtilsSelector.GoogleMapsUtilsSelector();
        return gmaps;
    }

    @AuraEnabled
    public static ResponseNIC findMunicipality(String lat, String lng) {
        ResponseNIC respNic = IntegrazioneNICCallout.IntegrazioneNICCallout(lat, lng);
        return respNic;
    }*/
    @AuraEnabled
    public static string getQueueName(String queueId) {
        Set<String> queueIds = new Set<String>();
        queueIds.add(queueId);
        List<Group> queriedQueue = GroupsSelector.getGroupsByIds(queueIds);
        return queriedQueue[0].developerName;
        
    }
    @AuraEnabled
    public static Boolean isUserAdminOrSuperUser(){
        return FeatureManagement.checkPermission('SkipControl');
        
    }
    @AuraEnabled
    public static String getUserProfile(){
        String currentUserId = userinfo.getUserId();
        User currentUser = UserSelector.getUserbyId(currentUserId);
        return currentUser.Profile.Name;
        
    }
    @AuraEnabled
    public static Map<String,String> getCaseRecordTypes(){
        Map<String, String> options = new Map<String, String>();        
        List<Record_Type__mdt> recordTypes = RecordTypeMetadataSelector.getCaseRecordTypes();
        List<String> recordTypesDeveloperName = new List<String>();
        for(Record_Type__mdt rec : recordTypes){
            recordTypesDeveloperName.add(rec.DeveloperName);
        }
        List<RecordType> recTypes = RecordTypeSelector.getRecordTypeByObjectAndDeveloperName('Case',recordTypesDeveloperName);
        for(RecordType rec : recTypes){
            String addOn = (rec.Description != null)?' - '+rec.Description:'';
            options.put(rec.Id ,rec.Name + addOn);
        }
        return options;
    }

    @AuraEnabled
    public static Map<Id,Group> getUserQueues() {
        String currentUserId = UserInfo.getUserId();
        String currentUserRoleId = (UserInfo.getUserRoleId() != null) ? UserInfo.getUserRoleId() : null;
        List<GroupMember> groupMembers = new List<GroupMember>();
        List<GroupMember> publicGroupMembers = new List<GroupMember>();
        Set<String> groupsIds = new Set<String>();
        Set<Id> userOrGroupIds = new Set<Id>();
        Set<Id> userOrGroupRegularIds = new Set<Id>();
        Map<id, UserRole> userRoles = new Map<id, UserRole>();
        List<String> ancestralRoleIds = new List<String>();

        // for user role and user's parent role
        System.debug('currentUserId ' + currentUserId);
        System.debug('currentUserRoleId ' + currentUserRoleId);
        if(currentUserRoleId != null) {
            userRoles = UserRoleSelector.getUserRoleHierarchy();
            String tmpRoleId = currentUserRoleId;
            UserRole c = userRoles.get(tmpRoleId);
            while(c.ParentRoleId != null) {
                ancestralRoleIds.add(c.ParentRoleId);
                tmpRoleId = c.ParentRoleId;
                c = userRoles.get(tmpRoleId);
            }
        }
        //String currentUserParentRoleId = (currentUserRoleId != null) ? UserRoleSelector.getParentRoleIdUserRoleId(currentUserRoleId) : null;
        System.debug('ancestralRoleIds: ' + ancestralRoleIds);
        List<Group> groupsRelated = GroupsSelector.getGroupsByRelatedId(currentUserRoleId, ancestralRoleIds);
        System.debug('groupsRelated: ' + groupsRelated);
        for(Group g : groupsRelated) userOrGroupIds.add(g.id);

        // add user and query GroupMembers
        userOrGroupIds.add(currentUserId);
        System.debug('userOrGroupIds: ' + userOrGroupIds);
        groupMembers = GroupMemberSelector.getGroupMembersExcludeCustomSettingsListByUserOrGroupIds(userOrGroupIds);
        System.debug('groupMembers: ' + groupMembers);

        if(groupMembers.isEmpty()) return new Map<Id,Group>();

        for(GroupMember gm: groupMembers){
            if(gm.Group.Type.equalsIgnoreCase('Regular')) {
                userOrGroupRegularIds.add(gm.groupid);          // group ids of group members that contain public group that contains the user
            } else {
                groupsIds.add(gm.groupid);
            }
        }

		System.debug('userOrGroupRegularIds: ' + userOrGroupRegularIds);
        System.debug('groupsIds: ' + groupsIds);
        //query for group members that contain userOrGroupRegularIds as userOrGroupId
        publicGroupMembers = GroupMemberSelector.getGroupMemberQueuesExcludeCustomSettingsListByUserOrGroupIds(userOrGroupRegularIds);

        System.debug('publicGroupMembers: ' + publicGroupMembers);
        for(GroupMember gm : publicGroupMembers) {
            groupsIds.add(gm.groupid);
        }

        System.debug('groupsIds: ' + groupsIds);
        if(groupsIds.isEmpty()) return new Map<Id,Group>();

        Map<Id, Group> queuesMap = new Map<Id,Group>(GroupsSelector.getGroupsByIds(groupsIds));
        system.debug('queuesMap -> ' +queuesMap);

        return queuesMap;
    }

    @AuraEnabled
    public static String LabelQueueForFirstPosition() {
        OrgManagement__c setting = OrgManagement__c.getOrgDefaults();
        system.debug('setting.Label_first_value_queue__c -> ' + setting.Label_first_value_queue__c);
        return String.isNotBlank(setting.Label_first_value_queue__c) ? setting.Label_first_value_queue__c : '';
    }

    @AuraEnabled
    public static Boolean isUserForSortQueue() {
        OrgManagement__c setting = OrgManagement__c.getOrgDefaults();
        String profileId = UserInfo.getProfileId();
        system.debug('setting.Id_profile_for_sort_queue__c -> ' + setting.Id_profile_for_sort_queue__c);
        system.debug('profileId -> ' + profileId);
        return  String.isNotBlank(setting.Id_profile_for_sort_queue__c) ? (profileId.equals(setting.Id_profile_for_sort_queue__c) ? true: false) : false;
    }


    @AuraEnabled
    public static Map<String,String> getInteractions(String rtId){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeSObjectResult d = Schema.SObjectType.Case;
        Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
        String rtDeveloperName = rtMapById.get(rtId).getDeveloperName();

        List<Taxonomy__c> listTaxQueue = [SELECT toLabel(Tax_Type__c) FROM Taxonomy__c];
        Set<String> setUniqueTaxQueue = new Set<String>();
        if ( listTaxQueue != null && listTaxQueue.size() > 0 ) {
            setUniqueTaxQueue.add(listTaxQueue[0].Tax_Type__c.toUpperCase());
            for (Taxonomy__c singleTax : listTaxQueue) {
                if (!setUniqueTaxQueue.contains(singleTax.Tax_Type__c.toUpperCase())) {
                    setUniqueTaxQueue.add(singleTax.Tax_Type__c.toUpperCase());
                }
            }
        }

        List<Case_Type__mdt> caseTypes = new List<Case_Type__mdt>();
        caseTypes = CaseTypeMtdSelector.getCaseTypesByRTDeveloperName(rtDeveloperName);
        system.debug('setUniqueTaxQueue -> '+ setUniqueTaxQueue);
        system.debug('caseTypes -> '+ caseTypes);

        for(Case_Type__mdt ct : caseTypes){
            if (setUniqueTaxQueue.contains(ct.Label.toUpperCase())) {
                options.put(ct.Label,ct.Label);
            }
        }
        return options;
    }

    public class fieldsListWrapper {
        @AuraEnabled public  String fieldName{get;set;}
        @AuraEnabled public boolean isRequired {get;set;}
        @AuraEnabled public boolean isFirstColumn {get;set;}
        @AuraEnabled public boolean isSecondColumn {get;set;}
        public fieldsListWrapper(boolean isRequired, String fieldName, boolean isFirstColumn, boolean isSecondColumn){
            this.isRequired = isRequired;
            this.fieldName = fieldName;
            this.isFirstColumn = isFirstColumn;
            this.isSecondColumn = isSecondColumn;
        }
    }

    @AuraEnabled
    public static List<fieldsListWrapper> getCaseFields(String rtId){
        List<fieldsListWrapper> fieldsListWrapper = new List<fieldsListWrapper>();
        Schema.DescribeSObjectResult d = Schema.SObjectType.Case;
        Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
        String rtDeveloperName = rtMapById.get(rtId).getDeveloperName();
        List<RT_Field__mdt> rtFieldMtd = RTFieldMtdSelector.getCaseTypesByRTDeveloperName(rtDeveloperName);
        for(RT_Field__mdt rtField : rtFieldMtd){
            Boolean isFirstColumn = (rtField.ColumnNumber__c == 1);
            Boolean isSecondColumn = (rtField.ColumnNumber__c == 2);
            fieldsListWrapper.add(new fieldsListWrapper(rtField.Required__c,rtField.Label, isFirstColumn, isSecondColumn));
        }
    return fieldsListWrapper;
    }

    @AuraEnabled(cacheable = true)
    public static List<SObject> findRecords(String objectName, String searchField, String additionalTaxType){
        system.debug('additionalQueueFilter -> '+additionalTaxType);
        String QUERY = 'Select Id, '+searchField+' From '+objectName +' WHERE Tax_Active__c = TRUE';
        if ( String.isNotBlank(additionalTaxType) ) {
            QUERY += ' AND toLabel(Tax_Type__c) = \'' + additionalTaxType + '\'';
        }
        System.debug('query in findRecords');
        System.debug(System.LoggingLevel.DEBUG, QUERY);
        List<SObject> sObjectList = Database.query(QUERY);
        return sObjectList;
    }

    public class synonymous {
        @AuraEnabled public  String Id{get;set;}
        @AuraEnabled public String Name{get;set;}
        @AuraEnabled public String Synonymous{get;set;}
        public synonymous(String Id, String Name, String Synonymous){
            this.Id = Id;
            this.Name = Name;
            this.Synonymous = Synonymous;
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<synonymous> getSynonymous (){
        List<Synonymous__c> synonymous = SynonymousSelector.getSynonymous();
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Synonymous__c.fields.getMap();
        //Map<String,String> synonymousNameMap = new Map<String,String>();
        List<synonymous> synonymousNameMap = new List<synonymous>();
        Set<String> fieldsList = schemaFieldMap.keySet();
        for(Synonymous__c synonym : synonymous){
            for(String field : fieldsList){
                if((field.containsIgnoreCase('Synonym_value_') || field.equalsIgnoreCase('Taxonomy_Value__c')) && !field.containsIgnoreCase('Backup')){
                    String value = (String)synonym.get(field);
                    if(value != null){
                        synonymousNameMap.add(new synonymous(synonym.Taxonomy_Value__c.toUppercase(), synonym.Taxonomy_Value__c.toUppercase(), value));
                    }
                }
            }

        }
        return synonymousNameMap;
    }

    public class majorRoadsMapped {
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public Boolean PartialViability { get; set; }
        public majorRoadsMapped(String Id, String Name, Boolean PartialViability) {
            this.Id = Id;
            this.Name = Name;
            this.PartialViability = PartialViability;
        }
    }

    @AuraEnabled(cacheable = false)
    public static List<String> manageMajorRoards(String addressToFind) {
        try {
            return MajorRoadsController.isMajorRoards(addressToFind);
        } catch(Exception e) {
            System.debug('Exception at CaseService.TriggerHandler: ' + e.getMessage());

            ErrorLogEventHandler.standardExceptionLog(e);
        }
        return null;
    }
}