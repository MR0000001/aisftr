@isTest
public without  sharing class ActionPlanCreationController_TEST {
    @isTest 
    static void constructorTests(){
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        ActionPlan__c actionPlan = testUtil.createNewActionPlan( 'contacts', 2 );
         
        System.currentPageReference().getParameters().put( 'id', null );
        ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
        
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
        
        System.currentPageReference().getParameters().put( 'id', null );
        System.currentPageReference().getParameters().put( 'clone', '1' );
        apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
        
        ActionPlanTemplate__c apTemplate = testUtil.createNewActionPlanTemplate( 3 );
        
        System.currentPageReference().getParameters().put( 'id', null );
        System.currentPageReference().getParameters().put( 'clone', null );
        System.currentPageReference().getParameters().put( 'templateId', apTemplate.Id );
        apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
        
        Contact contact = testUtil.createNewContact();
        
        System.currentPageReference().getParameters().put( 'id', null );
        System.currentPageReference().getParameters().put( 'refId', contact.Id );
        System.currentPageReference().getParameters().put( 'refType', 'Contact' );
        apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
        String refid    = apCreateController.refId;
        String reftype  = apCreateController.refType;
        apCreateController.refreshRelatedObjectsLookUp();
        
        Test.StopTest();
    }
    
    @isTest 
    static void testActionPlanSave(){
        
        //Erase all Action Plans before begining test
        List<ActionPlan__c> apList = [ select Id from ActionPlan__c limit 10000];
        delete apList;
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlan__c actionPlan            = new ActionPlan__c();
        
        Contact contact = testUtil.createNewContact();
        
        actionPlan.Name         = testUtil.createRandomWord();
        actionPlan.Contact__c   = contact.Id;
        actionPlan.StartDate__c = Date.today();
        
        APTaskTemplate__c apTask = new APTaskTemplate__c();
        
        apTask.Subject__c           = testUtil.createRandomWord();
        apTask.User__c              = testUtil.createTestUser().Id;
        apTask.DaysFromStart__c     = 2;
        apTask.Type__c              = 'Email';
        apTask.Priority__c          = 'Hight';
                
        System.currentPageReference().getParameters().put( 'id', null );
        System.currentPageReference().getParameters().put( 'refId', contact.Id );
        System.currentPageReference().getParameters().put( 'refType', 'Contact' );
        ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( actionPlan ) );
        
        apCreateController.actionPlans.apTasks = new List<APTaskTemplate__c>();
        apCreateController.actionPlans.apTasks.add( apTask );
        apCreateController.save();
        
        Test.StopTest();
        
        List<ActionPlan__c> results = [ select Id from ActionPlan__c limit 10000];
        
        
        System.assert( !results.isEmpty(), 'Action Plan not created' );
        System.assert( results.size() == 1, 'Action Plan not created' );
        
        apCreateController.cancel();
    }
    
    @isTest 
    static void testActionPlanSaveAndNew(){
        
        //Erase all Action Plans before begining test
        List<ActionPlan__c> apList = [ select Id from ActionPlan__c limit 10000];
        delete apList;
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlan__c actionPlan            = new ActionPlan__c();
        
        Contact contact = testUtil.createNewContact();
        
        actionPlan.Name         = testUtil.createRandomWord();
        actionPlan.Contact__c   = contact.Id;
        actionPlan.StartDate__c = Date.today();
        
        APTaskTemplate__c apTask = new APTaskTemplate__c();
        
        apTask.Subject__c           = testUtil.createRandomWord();
        apTask.User__c              = testUtil.createTestUser().Id;
        apTask.DaysFromStart__c     = 2;
        apTask.Type__c              = 'Email';
        apTask.Priority__c          = 'Hight';
                
        System.currentPageReference().getParameters().put( 'id', null );
        System.currentPageReference().getParameters().put( 'refId', contact.Id );
        System.currentPageReference().getParameters().put( 'refType', 'Contact' );
        ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( actionPlan ) );
        
        apCreateController.actionPlans.apTasks = new List<APTaskTemplate__c>();
        apCreateController.actionPlans.apTasks.add( apTask );
        apCreateController.saveAndNew();
        Test.StopTest();
        List<ActionPlan__c> results = [ select Id from ActionPlan__c limit 10000];
        
        System.assert( !results.isEmpty(), 'Action Plan not created' );
        System.assert( results.size() == 1, 'Action Plan not created' );
        
        
    }
    
    @isTest 
    static void checkCompletedTasks(){
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlan__c actionPlan            = testUtil.createNewActionPlan( 'accounts', 2 );
        
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( actionPlan ) );
        
        Integer numTasksComplete = apCreateController.getCompleted();
        
        System.assert( numTasksComplete == 0 , 'Action plan task completed is incorrect' );
        
        Test.StopTest();
    }
    
    @isTest 
    static void testAddNewTask(){
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlan__c actionPlan            = testUtil.createNewActionPlan( 'accounts', 2 );
        
        APTaskTemplate__c apTask = new APTaskTemplate__c();
        
        apTask.Action_Plan__c       = actionPlan.Id;
        apTask.Subject__c           = testUtil.createRandomWord();
        apTask.User__c              = testUtil.createTestUser().Id;
        apTask.DaysFromStart__c     = 2;
        apTask.Type__c              = 'Email';
        apTask.Priority__c          = 'Hight';
                
        System.currentPageReference().getParameters().put( 'id', null );
        System.currentPageReference().getParameters().put( 'add', '1' );
        ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( actionPlan ) );
        apCreateController.actionPlans.apTasks = new List<APTaskTemplate__c>();
        apCreateController.actionPlans.apTasks.add( apTask );
        apCreateController.addTask();
        
        Test.StopTest();
    }
    
    @isTest 
    static void testRemoveActionPlanTask(){
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlan__c actionPlan            = testUtil.createNewActionPlan( 'accounts', 3 );
                
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        System.currentPageReference().getParameters().put( 'remove', '1' );
        ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( actionPlan ) );
        apCreateController.actionPlans.apTasks = [ select a.Type__c, a.Subject__c, a.ActivityDate__c, a.Priority__c, a.Status__c, a.Dependent__c, 
                                                        a.Name, a.User__c, a.User__r.Name, a.Id, a.DaysFromStart__c, a.CreatedById, a.APTaskTemplate__r.Name, 
                                                        a.APTaskTemplate__r.Subject__c, a.APTaskTemplate__c, a.Action_Plan__c, a.Reminder__c, 
                                                        a.SendEmail__c, a.Comments__c 
                                                        from APTaskTemplate__c a 
                                                        where a.Action_Plan__c =: actionPlan.Id order by a.createdDate asc ];
                                    
        apCreateController.removeTask();
        
        Test.StopTest();
    }
    
    @isTest 
    static void checkActionPlanTaskList(){
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlan__c actionPlan            = testUtil.createNewActionPlan( 'accounts', 2 );
        
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( actionPlan ) );
        
        List<ActionPlanCreationController.ApTaskWrapper> apTaskList = apCreateController.getTasks();
        
        System.assert( !apTaskList.isEmpty(), 'Action plan task list is empty' );
                
        Test.StopTest();
    }
    
    @isTest 
    static void checkActionPlanTaskListSize(){
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlan__c actionPlan            = testUtil.createNewActionPlan( 'accounts', 2 );
        
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( actionPlan ) );
        
        List<ActionPlanCreationController.ApTaskWrapper> apTaskList  = apCreateController.getTasks();
        Integer numTasks                    = apCreateController.getTaskSize();
        
        System.assert( !apTaskList.isEmpty(), 'Action plan task list is empty' );
                
        System.assert( numTasks == apTaskList.size(), 'Action Plan task size incorrect');
                        
        Test.StopTest();
    }
    
    @isTest 
    static void checkSubjectItems(){
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlan__c actionPlan            = testUtil.createNewActionPlan( 'accounts', 2 );
        
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( actionPlan ) );
        apCreateController.actionPlans.apTasks = [ select a.Type__c, a.Subject__c, a.ActivityDate__c, a.Priority__c, a.Status__c, a.Dependent__c, 
                                                        a.Name, a.User__c, a.User__r.Name, a.Id, a.DaysFromStart__c, a.CreatedById, a.APTaskTemplate__r.Name, 
                                                        a.APTaskTemplate__r.Subject__c, a.APTaskTemplate__c, a.Action_Plan__c, a.Reminder__c, 
                                                        a.SendEmail__c, a.Comments__c 
                                                        from APTaskTemplate__c a 
                                                        where a.Action_Plan__c =: actionPlan.Id order by a.createdDate asc ];
                                                        
        List<Selectoption> options = apCreateController.getSubjectItems();
        
        System.assert( !options.isEmpty(), 'select options is empty' );
        System.assert( options.size() == 3, 'incorrect number of select options' );
                        
        Test.StopTest();
    }
    
    @isTest 
    static void testCyclicDependencyTaskSuccess(){
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        
        ActionPlan__c actionPlan = testUtil.createNewActionPlan( 'accounts', 0 );
        
        APTaskTemplate__c newAPTask1 = new APTaskTemplate__c();
        APTaskTemplate__c newAPTask2 = new APTaskTemplate__c();
        APTaskTemplate__c newAPTask3 = new APTaskTemplate__c();
        
        newAPTask1.Subject__c           = testUtil.createRandomWord();
        newAPTask1.DaysFromStart__c     = 2;
        newAPTask1.Dependent__c         = '2';
        newAPTask1.Type__c              = 'Email';
        newAPTask1.Priority__c          = 'High';
        newAPTask1.Action_Plan__c       = actionPlan.Id;
        upsert newAPTask1;
        
        newAPTask2.Subject__c           = testUtil.createRandomWord();
        newAPTask2.DaysFromStart__c     = 2;
        newAPTask2.Dependent__c         = 'None';
        newAPTask2.Type__c              = 'Email';
        newAPTask2.Priority__c          = 'High';
        newAPTask2.Action_Plan__c       = actionPlan.Id;
        upsert newAPTask2;
        
        newAPTask3.Subject__c           = testUtil.createRandomWord();
        newAPTask3.DaysFromStart__c     = 2;
        newAPTask3.Dependent__c         = '1';
        newAPTask3.Type__c              = 'Email';
        newAPTask3.Priority__c          = 'High';
        newAPTask3.Action_Plan__c       = actionPlan.Id;
        upsert newAPTask3;
        
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( actionPlan ) );
        
        apCreateController.actionPlans.apTasks = new List<APTaskTemplate__c>();
        apCreateController.actionPlans.apTasks.add( newAPTask1 );
        apCreateController.actionPlans.apTasks.add( newAPTask2 );
        apCreateController.actionPlans.apTasks.add( newAPTask3 );
        
        apCreateController.save();
        
        System.assert( apCreateController.getErrorMsg() == '' );
        
        Test.StopTest();
    }
    
    @isTest 
    static void testCyclicDependencyTasksFail(){
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        
        ActionPlan__c actionPlan = testUtil.createNewActionPlan( 'accounts', 0 );
        
        APTaskTemplate__c newAPTask1 = new APTaskTemplate__c();
        APTaskTemplate__c newAPTask2 = new APTaskTemplate__c();
        APTaskTemplate__c newAPTask3 = new APTaskTemplate__c();
        
        newAPTask1.Subject__c           = testUtil.createRandomWord();
        newAPTask1.DaysFromStart__c     = 2;
        newAPTask1.Dependent__c         = '2';
        newAPTask1.Type__c              = 'Email';
        newAPTask1.Priority__c          = 'Hight';
        
        newAPTask2.Subject__c           = testUtil.createRandomWord();
        newAPTask2.DaysFromStart__c     = 2;
        newAPTask2.Dependent__c         = '0';
        newAPTask2.Type__c              = 'Email';
        newAPTask2.Priority__c          = 'Hight';
        
        newAPTask3.Subject__c           = testUtil.createRandomWord();
        newAPTask3.DaysFromStart__c     = 2;
        newAPTask3.Dependent__c         = '1';
        newAPTask3.Type__c              = 'Email';
        newAPTask3.Priority__c          = 'Hight';
        
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( actionPlan ) );
        
        apCreateController.actionPlans.apTasks = new List<APTaskTemplate__c>();
        apCreateController.actionPlans.apTasks.add( newAPTask1 );
        apCreateController.actionPlans.apTasks.add( newAPTask2 );
        apCreateController.actionPlans.apTasks.add( newAPTask3 );
        
        apCreateController.save();
        
        System.assert( apCreateController.getErrorMsg() != null );
        
        Test.StopTest();
    }
    
    @isTest 
    static void checkReferedObject(){
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        
        Contact contact         = testUtil.createNewContact();
        Account account         = testUtil.createNewAccount();
        Lead lead               = testUtil.createNewLead();
        Opportunity opportunity = testUtil.createNewOpportunity(); 
        System.currentPageReference().getParameters().put( 'id', null );
        System.currentPageReference().getParameters().put( 'refId', contact.id );
        System.currentPageReference().getParameters().put( 'refType', 'Contact' );
        
        ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
        apCreateController.referedObjectInit();
        apCreateController.referedObjectOwnerInit();
        
        System.assert( apCreateController.relatedObjNameList.size() == 2 );
        
        System.currentPageReference().getParameters().put( 'id', null );
        System.currentPageReference().getParameters().put( 'refId', account.Id );
        System.currentPageReference().getParameters().put( 'refType', 'Account' );
        
        apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
        apCreateController.referedObjectInit();
        apCreateController.referedObjectOwnerInit();
        
        System.assert( apCreateController.relatedObjNameList.size() == 2 );
        
        System.currentPageReference().getParameters().put( 'id', null );
        System.currentPageReference().getParameters().put( 'refId', lead.Id );
        System.currentPageReference().getParameters().put( 'refType', 'Lead' );
        
        apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
        apCreateController.referedObjectInit();
        apCreateController.referedObjectOwnerInit();
        
        System.assert( apCreateController.relatedObjNameList.size() == 2 );
        
        System.currentPageReference().getParameters().put( 'id', null );
        System.currentPageReference().getParameters().put( 'refId', opportunity.Id );
        System.currentPageReference().getParameters().put( 'refType', 'Opportunity' );
        
        apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
        apCreateController.referedObjectInit();
        apCreateController.referedObjectOwnerInit();
        
        System.assert( apCreateController.relatedObjNameList.size() == 2 );
        System.assert( apCreateController.getRelatedObjectOptions().size() == apCreateController.actionPlans.getRelatedObjectOptions().size() );
        
        Test.StopTest();
    }
    
    
    //aPTemplateExists
    @isTest 
    static void test_aPTemplateExists(){
        
        Test.StartTest();
        ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
        
        ApexPages.currentPage().getParameters().put( 'refType','FOO' );
        ApexPages.currentPage().getParameters().put( 'refId','FOO' );
        delete [select Id from ActionPlanTemplate__c];
        
        System.assertEquals(apCreateController.aPTemplateExists,false);
        
        Test.StopTest();
    }
}