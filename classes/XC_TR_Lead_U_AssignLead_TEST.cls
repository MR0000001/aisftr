/**
* @author Federico Amici - federico.amici@nttdata.com
* @date Creation  TO FILL/05/2019 
* @description XC_TR_Lead_U_AssignLead_TEST – Test class for XC_TR_Lead_U_AssignLead
*/ 
@isTest
private class XC_TR_Lead_U_AssignLead_TEST { 

    /*
    @TestSetup
    private static void setup(){
        
        List<User> listUser = new List<User>();
        List<QueueSObject> listQueues = new List<QueueSObject>();
        List<GroupMember> listGMember = new List<GroupMember>();
        List<Group> listGroup = new List<Group>();
        
        Id rtId = Schema.SObjectType.XC_LeadAssignmentMaster__c.getRecordTypeInfosByName().get('Spain').getRecordTypeId();

        //Create a Lead Assignment Master record (Per ora sono indicati solo i campi obbligatori)
        XC_LeadAssignmentMaster__c lam = new XC_LeadAssignmentMaster__c();
        lam.RecordTypeId = rtId;
        lam.XC_OrderOfEvaluation__c = 20;
        lam.XC_Status__c = 'Assigned';
        lam.XC_AssignedToCreator__c = true;
        insert lam;
        
        User u  = XC_DF_User.createUserAdmin();
        u.alias = 'Test';
        u.Username = 'pablo1@gmail.com';
        u.isActive = true;
        listUser.add(u);

        User u1 = XC_DF_User.createUserAdmin();
        u1.Alias = 'Test1';
        u1.isActive = true;
        u1.Username='pablo2@gmail.com';
        u1.CommunityNickname ='fsdfse';
        listUser.add(u1);
       
        XC_UTIL_SObject.insertListRecords(listUser);


        System.debug(listUser);

        System.runAs(u1) {        
            OneOrg__c org            = new OneOrg__c(); 
            org.Name                 = 'OneOrg (User)';
            org.XC_Spain_Triggers__c = true;
            insert org;
        }
        
        Group techGroup = new Group();
        Group marketingGroup = new Group();

        System.runAs(u1) {
            
            techGroup.Name = 'Technology Partner Content';
            techGroup.Type = 'Queue';

            marketingGroup.Name = 'Marketing Partner Content';
            marketingGroup.Type = 'Queue';
            listGroup.add(techGroup);
            listGroup.add(marketingGroup);
            insert listGroup;

            GroupMember gM = new GroupMember ();
            gM.UserOrGroupId = u.Id;
            gM.GroupId = techGroup.Id;

            GroupMember gM1 = new GroupMember ();
            gM1.UserOrGroupId = u1.Id;
            gM1.GroupId = marketingGroup.Id;
            listGMember.add(gm);
            listGMember.add(gm1);
            insert listGMember;

            QueuesObject queueTech = new QueueSObject(QueueID = techGroup.id, SobjectType = 'Lead');
            listQueues.add(queueTech);    
            QueuesObject queueMarketing = new QueueSObject(QueueID = marketingGroup.id, SobjectType = 'Lead');
            listQueues.add(queueMarketing);
            insert listQueues;
        }


        OperatingHours opOne = XC_DF_OperatingHours.createOperatingHours('Happy hour');
        insert opOne;

        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(8);
        leadList[0].Status = 'Assigned';
        leadList[0].OwnerId = marketingGroup.ID;
        leadList[1].Status = 'Take Charge';
        leadList[1].OwnerId = marketingGroup.ID;
        leadList[2].Status = 'Customer Contacted';
        leadList[2].OwnerId = marketingGroup.ID;
        leadList[3].Status = 'Assigned';
        leadList[3].OwnerId = techGroup.ID;  
        leadList[4].Status = 'Assigned';
        leadList[4].OwnerId = u.ID;
        leadList[5].Status = 'Take Charge';
        leadList[5].OwnerId = u.ID;
        leadList[6].Status = 'Assigned';
        leadList[6].OwnerId = u.ID;
        leadList[7].Status = 'Take Charge';
        leadList[7].OwnerId = u.ID;
        insert leadList;
       
    }*/

    /** @Federico Amici - federico.amici@nttdata.com
    *   This method tests a lead taken in charge by an user belonging
    *   to the same queue
    */
    /*@isTest
    static void processLeadQueueTest() {

        User u = [Select id FROM user WHERE alias='Test1' LIMIT 1];
        Group g = [SELECT Id                            //If the running user belongs to the queue
                   FROM Group           
                   WHERE Name = 'Marketing Partner Content' LIMIT 1];

        List<Lead> leadList  = [SELECT Name, Id, OwnerId, Status, Email
                               FROM Lead
                               WHERE OwnerId = :g.Id
                               ORDER BY Email ASC];
        List<Lead> leadList1  = [SELECT Name, Id, OwnerId, Status, Email
                               FROM Lead
                               WHERE OwnerId = :g.Id
                               ORDER BY Email ASC]; 
      
       
        leadList.get(0).OwnerId = u.Id;
        leadList.get(1).Status = 'Working - Not Contacted';

        test.startTest();
        System.runAs(u) {
            update leadList;
        }
        test.stopTest(); 
        
        System.assertEquals(leadList[0].Name,leadList1[0].Name);
    }*/
   
    /** @Federico Amici - federico.amici@nttdata.com
    *   This method tests that a user that doesn't belong to the same queue of the lead
    *   cannot take it in charge
    */
    /*@isTest
    static void processLeadQueueTest1() {

        User u = [Select id FROM user WHERE ProfileId IN (SELECT Id FROM Profile WHERE Name = 'System Administrator') 
                                            AND isActive = true LIMIT 1];

        System.debug([SELECT Id, name FROM User]);

        Group g = [SELECT Id                            //If the running user belongs to the queue
                   FROM Group           
                   WHERE Name = 'Marketing Partner Content' LIMIT 1];

        Lead l  = [SELECT Name, Id, OwnerId, Status
                               FROM Lead
                               WHERE OwnerId = :g.Id AND
                                    Status = 'Customer Contacted'
                               LIMIT 1]; 

        
        l.OwnerId = u.Id ;

        test.startTest();
        System.runAs(u) {
            XC_UTIL_SObject.updateRecord(l);
        }
        test.stopTest(); 
        Lead l1  = [SELECT Name, Id, OwnerId, Status
                               FROM Lead
                               WHERE OwnerId = :g.Id AND
                                    Status = 'Customer Contacted'
                               LIMIT 1]; 
        System.assertEquals(l.Name,l1.Name);
    }*/

    /** @Federico Amici - federico.amici@nttdata.com
    *   This method tests a lead edited by the same owner
    */    
    /*@isTest
    static void processLeadUserTest() {

        User u = [Select id FROM user WHERE Username='pablo1@gmail.com' LIMIT 1];

        Lead l  = [SELECT Name, Id, OwnerId, Status
                   FROM Lead
                   WHERE OwnerId = :u.Id LIMIT 1]; 

        l.Status = 'Assigned';

        test.startTest();
        System.runAs(u) {
            XC_UTIL_SObject.updateRecord(l);
        }
        test.stopTest(); 
        Lead l1  = [SELECT Name, Id, OwnerId, Status
                   FROM Lead
                   WHERE OwnerId = :u.Id LIMIT 1]; 
          System.assertEquals(l.Name,l1.Name);

    }*/
    
    /** @Federico Amici - federico.amici@nttdata.com
    *   This method tests a lead edited by the same owner
    */    
    /*@isTest
    static void processLeadUserTest1() {

        User u = [Select id FROM user WHERE Username='pablo1@gmail.com' LIMIT 1];

        Lead l  = [SELECT Name, Id, OwnerId, Status
                   FROM Lead
                   WHERE OwnerId = :u.Id AND
                        Status = :Label.XC_CL_Lead_OpenNotContacted LIMIT 1]; 
        Lead l1  =  [SELECT Name, Id, OwnerId, Status
                   FROM Lead
                   WHERE OwnerId = :u.Id AND
                        Status = :Label.XC_CL_Lead_OpenNotContacted LIMIT 1]; 
        
        l.Status = 'Assigned';

        test.startTest();
        System.runAs(u) {
            XC_UTIL_SObject.updateRecord(l);
        }
        test.stopTest(); 
        
          System.assertEquals(l.Name,l1.Name);

    }*/
    
    /** @Federico Amici - federico.amici@nttdata.com
    *   This method tests a lead coming from web to lead
    */    
    /*@isTest
    static void processLeadWTLTest() {

        Map<Id, Lead> mapOld = new Map<Id, Lead>();
        
        /* In this case, we fake the default user that is assigned to lead */
        /*User u = [Select id FROM user WHERE Username='pablo1@gmail.com' LIMIT 1];
        
        Group g = [SELECT Id                            
                   FROM Group           
                   WHERE Name = 'Marketing Partner Content' LIMIT 1];
        
        List<Lead> l  = [SELECT Name, Id, OwnerId, Status
                   FROM Lead
                   WHERE OwnerId = :u.ID AND Status = :Label.XC_CL_Lead_OpenNotContacted LIMIT 1 ];
        l[0].XC_ReceivingChannel__c = Label.XC_CL_Web;
        l[0].OwnerId = u.Id;
        mapOld.put(l[0].Id, l[0]);
        
        Map<Id, Lead> mapNew = new Map<Id, Lead>();
        mapNew.put(l[0].ID, l[0]);
        mapNew.get(l[0].Id).OwnerId = g.ID;

        test.startTest();
            System.debug('@@@@@@@ ' + mapOld.get(l[0].id).Status + 'g.ID ' + g.ID);
            XC_TR_Lead_U_AssignLead.processLeadWTL(mapNew.values(), null, null, mapOld);
        test.stopTest(); 
        List<Lead> l1  =  [SELECT Name, Id, OwnerId, Status
                   FROM Lead
                   WHERE OwnerId = :u.ID AND Status = :Label.XC_CL_Lead_OpenNotContacted LIMIT 1 ];
        System.assertEquals(l[0].Name,l1[0].Name);
 
    }*/
    

}