/**
 * @author            : Davide Desideri
 * @created date      : 
 * @description       : 
 * @testClasses       : TestCaseManagementController
 * @last modified by  : Davide Desideri
 * @last modified on  : 07-02-2023
**/

public with sharing class CaseManagementController {
    private static OrgManagement__c orgSetting = OrgManagement__c.getOrgDefaults();

    @AuraEnabled
    public static void postToChatter(String caseId, String caseNumber, String groupId, String groupName) {
        DebugService.printLimits('CaseManagementController', 'postToChatter', 'start');
        if(!orgSetting.Disable_Post_to_Chatter__c) {
            System.debug('case: ' + caseId + ' groupId: ' + groupId);
            List<String> userIds = new List<String>();
            List<ConnectApi.BatchInput> feedItemInputs = new List<ConnectApi.BatchInput>();


            for(GroupMember gm : [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId =: groupId]) {
                if(String.valueOf(gm.UserOrGroupId).startsWithIgnoreCase('005')) {
                    userIds.add(gm.UserOrGroupId);
                }
            }
            DebugService.printList('CaseManagementController', 'postToChatter', 'userIds', userIds, false);

            for(User u : [SELECT Id, Name FROM User WHERE Profile.Name = 'Istruttore' AND IsActive = TRUE AND Id IN: userIds]) {
                System.debug('User Id: ' + u.Id + ' Name: ' + u.Name);
                ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

                ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                mentionSegmentInput.id = u.Id;
                messageBodyInput.messageSegments.add(mentionSegmentInput);

                ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                textSegmentInput.text = '\n'+Label.CRM_di_Roma_Capitale + ' ' + u.Name + ', il caso ' + caseNumber + ' risulta essere assegnato alla coda ' + groupName + ' ' + Label.Working_Case + '\n' +
                        Label.Istruttore_Queue + ' ' + groupName + ' ' + Label.HelpDesk + '\n\n';
                messageBodyInput.messageSegments.add(textSegmentInput);

                feedItemInput.body = messageBodyInput;
                feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                feedItemInput.subjectId = caseId;
                feedItemInputs.add(new ConnectApi.BatchInput(feedItemInput));
            }
            DebugService.printList('CaseManagementController', 'postToChatter', 'feedItemInputs.messageSegments', feedItemInputs, true);

            List<ConnectApi.BatchResult> feedBatchResults = ConnectApi.ChatterFeeds.postFeedElementBatch(null, feedItemInputs);
        }

        DebugService.printLimits('CaseManagementController', 'postToChatter', 'end');
    }

    @AuraEnabled
    public static Map<String, String> getAllRolesMetadata() {
        Map<String, String> options = new Map<String, String>();
        List<Role_Orchestrator__mdt> roles = RoleOrchestratorMdtSelector.getAllRoles();

        for(Role_Orchestrator__mdt role : roles){
            options.put(role.Label, role.Label);
        }

        return options;
    }

    @AuraEnabled
    public static Boolean queuesAreActive(String queueId, String queueName){
        System.debug('@@@ queueId '+queueId);
        System.debug('@@@ queueName '+queueName);
        List<Group> queues = GroupsSelector.getAllQueues();
        Boolean isActiveQueueId = false;
        Boolean isActiveQueueName = false;

        for(Group queue:queues){
            System.debug('@@@ queue '+ queue);
            if(queue.Name == queueName){
                isActiveQueueName = true;
            }
            if(queue.Id == queueId){
                isActiveQueueId = true;
            }
        }
        System.debug('@@@ isActiveQueueId && isActiveQueueName '+(isActiveQueueId && isActiveQueueName));
        return isActiveQueueId && isActiveQueueName;
    }
    @AuraEnabled
    public static String getCurrentUserRole() {
        Id currentUserId = UserInfo.getUserId();
        User currentUser = UserSelector.getUserbyId(currentUserId);
        return currentUser.UserRole.Name;
    }
    @AuraEnabled
    public static String getQueueId(String queueName) {
        System.debug('@@@ queueName '+queueName);
        String groupId;
        List<Group> queriedGroup = GroupsSelector.getGroupsByName(queueName);
        if(queriedGroup!= null && !queriedGroup.isEmpty()){
            groupId = queriedGroup[0].Id;
        }
        return groupId;
    }
    @AuraEnabled
    public static Map<String, String> getActionsCaseManagement(String userRole) {
        Map<String, String> options = new Map<String, String>();

        List<Azioni_Gestione_Case__mdt> actions = ActionsMdtSelector.getActionsByOperator(userRole);
        for(Azioni_Gestione_Case__mdt action : actions){
            options.put(action.Label,action.Label);
        }
        return options;
    }
    @AuraEnabled
    public static Map<String, String> getReasonsCaseManagement(String userRole, String action) {
        Map<String, String> options = new Map<String, String>();
        System.debug('@@@ userRole '+userRole);
        System.debug('@@@ action '+action);
        List<Motivo__mdt> reasons = ReasonsSelector.getReasonByActionAndRole(userRole, action);
        for(Motivo__mdt reason : reasons){
            options.put(reason.Label,reason.Label);
        }
        return options;
    }
    @AuraEnabled
    public static Map<String, String> getQueuesCaseManagement() {
        System.debug('@@@ get');
        Map<String, String> options = new Map<String, String>();
        Map<String,String> queuesMdtDevNameLabelMap = new Map<String, String>();
        List<Queue__mdt> queuesMdt = QueueMdtSelector.getCallBackQueue();
        System.debug('@@@ queuesMdt '+queuesMdt);
        for(Queue__mdt queueMdt : queuesMdt){
            queuesMdtDevNameLabelMap.put(queueMdt.DeveloperName,queueMdt.Label);
        }
        System.debug('@@@ queuesMdtDevNameLabelMap '+queuesMdtDevNameLabelMap);
        List<String> queuesDevNames = new List<String>(queuesMdtDevNameLabelMap.keySet());
        System.debug('@@@ queuesDevNames '+queuesDevNames);
        List<Group> queues = GroupsSelector.getQueuesByDevNames(queuesDevNames);
        if(!queues.isEmpty()){
            for(Group queue : queues){
                options.put(queue.Id,queuesMdtDevNameLabelMap.get(queue.DeveloperName));
            }
        }
        return options;
    }
    @AuraEnabled
    public static Map<String, String> getModalitiesCaseManagement(String userRole, String action) {
        Map<String, String> options = new Map<String, String>();
        System.debug('@@@ userRole '+userRole);
        System.debug('@@@ action '+action);
        List<Modalit_Passaggio__mdt> modalities = ModalitiesSelector.getModalityByActionAndRole(userRole, action);
        for(Modalit_Passaggio__mdt modality : modalities){
            options.put(modality.Label,modality.Label);
        }
        return options;
    }
    @AuraEnabled
    public static Map<String,String> getQueuesURP(String currentQueue){
        Map<String, String> options = new Map<String, String>();
        List<Terzi_Livelli__c> levels = ThirdLevelsSelector.getThirdLevelsByUfficioURP(currentQueue);
        for(Terzi_Livelli__c level : levels){
            options.put(level.Ufficio_Istruttore__c,level.Ufficio_Istruttore__c);
        }
        return options;
    }

    @AuraEnabled
    public static String getDefaultQueueLabel(){
        return OrgManagement__c.getOrgDefaults().Default_Queue_Label__c;
    }
}