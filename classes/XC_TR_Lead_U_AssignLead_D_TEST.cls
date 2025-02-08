@isTest
public with sharing class XC_TR_Lead_U_AssignLead_D_TEST {

    @TestSetup
    static void makeData(){

            Group g1 = new Group(Name='QueueLead', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
            insert q1;

            Group g2 = new Group(Name='GroupTest');
            insert g2;

            List<GroupMember> groupMemberlist = new List<GroupMember>();
            GroupMember gm1 = new GroupMember();
            gm1.GroupId= g1.Id;
            gm1.UserOrGroupId = g2.Id;
            groupMemberlist.add(gm1);
            GroupMember gm2 = new GroupMember();
            gm2.GroupId = g2.Id;
            gm2.UserOrGroupId = UserInfo.getUserId();
            groupMemberlist.add(gm2);
            insert  groupMemberlist;
            
    }

    @isTest
    static void testCheckQueueMembership() {

        List<Group> listqueue = [SELECT Id FROM Group WHERE Type='Queue' and Name='QueueLead'];
        List<Id> listQueueId = new List<Id>();
        List<id> newOwnerIdList = new List<Id>();
        for(Group q : listqueue) {
            listQueueId.add(q.Id);
        }

        Test.startTest();
            XC_TR_Lead_U_AssignLead_D.getGroupMemberByQueueId(listQueueId, newOwnerIdList);
        Test.stopTest();
    }

  
}