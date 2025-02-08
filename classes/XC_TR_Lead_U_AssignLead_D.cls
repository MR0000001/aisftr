/**
 * The Class XC_TR_Lead_U_AssignLead_D.
 *
 * @author Federico Amici - federico.amici@nttdata.com
 * @date Creation 10/09/2018
 * @date Modification dd/mm/yyyy
 * @description XC_TR_Lead_U_AssignLead_D – DAO for the XC_TR_Lead_U_AssignLead class
 */

public without sharing class XC_TR_Lead_U_AssignLead_D {

    /**
     * @description Gets the task by lead id.
     * @param listId the list id
     * @return the task by lead id
     */
    public static List<Task> getTaskByLeadId(List<Id> listId) {
    	List<Task> listTask = new List<Task>();
        if(Schema.sObjectType.Task.isAccessible() && Schema.sObjectType.Task.fields.Id.isAccessible() && Schema.sObjectType.Task.fields.WhoId.isAccessible() && Schema.sObjectType.Task.fields.Subject.isAccessible() && Schema.sObjectType.Task.fields.Status.isAccessible()){
            listTask = [SELECT Id, WhoId, Subject, Status FROM Task
                        WHERE Whoid IN :listId AND Subject = :Label.XC_CL_Task_CallTheCustomer];
        }
    	return listTask;
    }

    /**
     * @description Gets the group member by queue id.
     * @param listQueueId the list queue id
     * @param newOwnerIdList the new owner id list
     * @return the group member by queue id
     */
  /*  public static Map<Id, List<Id>> getGroupMemberByQueueId(List<Id> listQueueId, List<Id> newOwnerIdList) {
		System.debug(LoggingLevel.FINEST,'@fedequeue@');
    	Id runningUserId = UserInfo.getUserId();
        List<GroupMember> listGroupMember = new List<GroupMember>([SELECT Id, GroupId, UserOrGroupId            //If the running user belongs to the queue
                            FROM GroupMember           
                            WHERE GroupId IN :listQueueId]);// AND UserOrGroupId IN :newOwnerIdList];
        
        Map<Id, List<Id>> mapNewIdToGroup = new Map<Id, List<Id>>();
        for(GroupMember g : listGroupMember) {
            if(mapNewIdToGroup.containsKey(g.GroupId)) {
                List<Id> userId = mapNewIdToGroup.get(g.GroupId);
                userId.add(g.UserOrGroupId);
                mapNewIdToGroup.put(g.GroupId, userId);
            } else {
                mapNewIdToGroup.put(g.GroupId, new List<Id> { g.UserOrGroupId });
            }
        }
        return mapNewIdToGroup;
    }*/


    /**
     * @description Gets the group member by queue id.
     * @param listQueueId the list queue id
     * @param newOwnerIdList the new owner id list
     * @return the group member by queue id
     */
    public static Map<Id, List<Id>> getGroupMemberByQueueId(List<Id> listQueueId, List<Id> newOwnerIdList) {
		System.debug(LoggingLevel.FINEST,'@fedequeue@');
    	Id runningUserId = UserInfo.getUserId();
        List<GroupMember> listGroupMember = new List<GroupMember>([SELECT Id, GroupId, UserOrGroupId            //If the running user belongs to the queue
                            FROM GroupMember           
                            WHERE GroupId IN :listQueueId]);// AND UserOrGroupId IN :newOwnerIdList];
        
        Map<Id, List<Id>> mapNewIdToGroup = new Map<Id, List<Id>>();
		List<Id> groupIdList = new List<Id>();
		Map<Id,Id> mapGroupOriginalQueue = new Map<Id,Id>();
        for(GroupMember g : listGroupMember) {
            if(!mapNewIdToGroup.containsKey(g.GroupId)) {
                mapNewIdToGroup.put(g.GroupId, new List<Id>());
            }
                List<Id> userId = mapNewIdToGroup.get(g.GroupId);
                userId.add(g.UserOrGroupId);
                mapNewIdToGroup.put(g.GroupId, userId);
				if(XC_UTIL_Sobject.getObjectType(g.UserOrGroupId)!='User') {
					groupIdList.add(g.UserOrGroupId);
					mapGroupOriginalQueue.put(g.UserOrGroupId,g.GroupId);
				}
           
        }
		Integer level=1;
		if(!groupIdList.isEmpty()) {
			nestedGroupMembership(groupIdList,mapNewIdToGroup,mapGroupOriginalQueue,level);
		}
		
        return mapNewIdToGroup;
    }
	
	
	
	public static void nestedGroupMembership(List<Id> groupIdList,Map<Id, List<Id>> mapNewIdToGroup,Map<Id,Id> mapGroupOriginalQueue,Integer level) {
		System.debug('nestedGroupMembership');
		System.debug('with level '+ level);
    	Id runningUserId = UserInfo.getUserId();
        List<GroupMember> listGroupMember = new List<GroupMember>([SELECT Id, GroupId, UserOrGroupId            //If the running user belongs to the queue
                            FROM GroupMember           
                            WHERE GroupId IN :groupIdList]);
		
		List<Id> newGroupIdList = new List<Id>();
		for(GroupMember g: listGroupMember) {
			if(mapGroupOriginalQueue.containsKey(g.GroupId)) {
				Id originalQueueId =mapGroupOriginalQueue.get(g.GroupId);
				List<Id> userId = mapNewIdToGroup.get(originalQueueId);
				userId.add(g.UserOrGroupId);
				mapNewIdToGroup.put(originalQueueId,userId);
				if(XC_UTIL_Sobject.getObjectType(g.UserOrGroupId)!='User') {
					newGroupIdList.add(g.UserOrGroupId);
					mapGroupOriginalQueue.put(g.UserOrGroupId,originalQueueId);
				}
			}
		}
		level++;
	
		if(!newGroupIdList.isEmpty()) {
			nestedGroupMembership(newGroupIdList,mapNewIdToGroup,mapGroupOriginalQueue,level);
		}
	
	}

    


    
}