@isTest
public class XC_ActionPlanTemplateTest {
   /**
    * Test Methods
    */

    
    @isTest
    public static void constructorTest(){
    
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );  
        ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
        
        Test.StopTest();
    }
    
   @isTest
    public static  void removeTemplateTask(){
     //  List<APTTaskTemplate__c> aptTasksList= new List<APTTaskTemplate__c>();
      // List<APTTaskTemplate__c>     aptTasks=new List<APTTaskTemplate__c>();
       System.currentPageReference().getParameters().put( 'remove', '2') ;
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
       //insert ap;
       ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
          apTemplate.aptTasks = new List<APTTaskTemplate__c>();
        apTemplate.aptTasks = [ select a.Type__c, a.Subject__c, a.Priority__c, a.Dependent__c, a.Name, a.User__c,
                                 a.User__r.Name, a.Id, a.DaysFromStart__c, a.CreatedById, a.Action_Plan_Template__c, 
                                 a.APTTaskTemplate__r.Subject__c, a.Reminder__c, a.SendEmail__c, a.Comments__c 
                                 From APTTaskTemplate__c a 
                                 where a.Action_Plan_Template__c =: actionPlanTemplate.Id ];
        /*for(APTTaskTemplate__c a:apTemplate.aptTasks){
          a.Dependent__c='2'; 
          break;  
        }*/
        apTemplate.aptTasks[0].Dependent__c='3';
        apTemplate.aptTasks[1].Dependent__c='2';
        update apTemplate.aptTasks;
       test.startTest();
       /*ActionPlanTemplates apTemplate.
       boolean bo=apTemplate.removeTemplateTask();*/
       apTemplate.removeTemplateTask(); 
       test.stopTest();
    }
    @isTest
    public static void checkCycleDependentError(){
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
       //insert ap;
       ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
          apTemplate.aptTasks = new List<APTTaskTemplate__c>();
        apTemplate.aptTasks = [ select a.Type__c, a.Subject__c, a.Priority__c, a.Dependent__c, a.Name, a.User__c,
                                 a.User__r.Name, a.Id, a.DaysFromStart__c, a.CreatedById, a.Action_Plan_Template__c, 
                                 a.APTTaskTemplate__r.Subject__c, a.Reminder__c, a.SendEmail__c, a.Comments__c 
                                 From APTTaskTemplate__c a 
                                 where a.Action_Plan_Template__c =: actionPlanTemplate.Id ];
        apTemplate.aptTasks[0].Dependent__c='0';
        update apTemplate.aptTasks;
        test.startTest();
        apTemplate.checkCycleDependent();
        test.stopTest();
    }
    @isTest
    public static void saveTemplateError(){
         ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
        ActionPlanTemplate__c actionPlanTemplate2=testUtil.createNewActionPlanTemplate( 3 );
        actionPlanTemplate.XC_LegalEntity__c='EndesaX';
        update actionPlanTemplate; 
        actionPlanTemplate2.name=actionPlanTemplate.Name;
        actionPlanTemplate2.XC_LegalEntity__c='EndesaX';
        update actionPlanTemplate2;
          ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate2 );
        test.startTest();
        apTemplate.saveTemplate();
        test.stopTest();
        
    }
    /**
    * Test Methods
    */
    @isTest
    public static void testRetrievingTemplateTasks(){
        
        //clear all action plan templates
        List<ActionPlanTemplate__c> apTemplateList = [ select id from ActionPlanTemplate__c ];
        delete apTemplateList;
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
        
        ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
        
        List<ActionPlanTemplate__c> apTemplates = apTemplate.getActionPlanTemplates();
        
        System.assert( !apTemplates.isEmpty(), 'action plan template list is empty' );
        
        Test.StopTest();
    }
    
    /**
    * Test Methods
    */
    //TODO finish this test for all condicionals
    @isTest
    public static void testRetrievingActionPlanTemplate(){
    
        //clear all action plan templates
        List<ActionPlanTemplate__c> apTemplateList = [ select id from ActionPlanTemplate__c ];
        delete apTemplateList;
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
        
        ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );

        ActionPlanTemplate__c resultActionPlanTemplate = apTemplate.getActionPlanTemplate();
        
        Test.StopTest();
    }
    
    /**
    * Test Methods
    */
    //TODO finish this big method
    @isTest
    public static void checkSavingActionPlanTemplate(){
    
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
        
        ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
        
        Test.StopTest();
    }
    
    /**
    * Test Methods
    */
    @isTest
    public static void testActionPlanTemplateDelete(){
    
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
        
        ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
        
        apTemplate.actionPlanTemplate = actionPlanTemplate;
        apTemplate.deleteTemplate();
        
        List<ActionPlanTemplate__c> results = [ select id from ActionPlanTemplate__c where Id =: actionPlanTemplate.Id ];
        
        System.assert( results.isEmpty(), 'Action plan template not deleted' );
        
        Test.StopTest();
    }
    
    /**
    * Test Methods
    */
    @isTest
    public static void testActionPlanTemplateCancel(){
    
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
        
        ActionPlanTemplates apTemplate  = new ActionPlanTemplates( actionPlanTemplate );
        apTemplate.actionPlanTemplate   = actionPlanTemplate;
        apTemplate.cancelTemplate();
        
        ActionPlanTemplate__c apTemplate2 = new ActionPlanTemplate__c();
        apTemplate = new ActionPlanTemplates( apTemplate2 );
        apTemplate.cancelTemplate();
        
        Test.StopTest();
    }
    
    /**
    * Test Methods
    */
    @isTest
    public static void testRetrievingActionPlanTemplateTasks(){
    
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
        
        System.currentPageReference().getParameters().put( 'id', actionPlanTemplate.Id );
        ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
        
        apTemplate.actionPlanTemplate           = actionPlanTemplate;
        List<APTTaskTemplate__c> templateTasks  = apTemplate.getTemplateTasks();
        
        System.assert( !templateTasks.isEmpty(), 'template task list is empty');
        System.assert( templateTasks.size() == 3, 'template tasks size not correct' );
        
        System.currentPageReference().getParameters().put( 'id', null );
        apTemplate = new ActionPlanTemplates( actionPlanTemplate );
        
        apTemplate.actionPlanTemplate               = actionPlanTemplate;
        List<APTTaskTemplate__c> templateTasks2     = apTemplate.getTemplateTasks();
        
        System.assert( !templateTasks2.isEmpty(), 'template task list is empty');
        System.assert( templateTasks2.size() == 1, 'template tasks size not correct' );
        
        System.currentPageReference().getParameters().put( 'clone', '1') ;
        apTemplate = new ActionPlanTemplates( actionPlanTemplate );
        
        apTemplate.actionPlanTemplate               = actionPlanTemplate;
        List<APTTaskTemplate__c> templateTasks3     = apTemplate.getTemplateTasks();
        
        Test.StopTest();
    }
    
    /**
    * Test Methods
    */
    @isTest
    public static void testAddNewActionPlanTemplateTask(){
    
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
        
        System.currentPageReference().getParameters().put( 'add', '1') ;
        ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
        apTemplate.aptTasks = new List<APTTaskTemplate__c>();
        apTemplate.aptTasks = [ select a.Type__c, a.Subject__c, a.Priority__c, a.Dependent__c, a.Name, a.User__c,
                                 a.User__r.Name, a.Id, a.DaysFromStart__c, a.CreatedById, a.Action_Plan_Template__c, 
                                 a.APTTaskTemplate__r.Subject__c, a.Reminder__c, a.SendEmail__c, a.Comments__c 
                                 From APTTaskTemplate__c a 
                                 where a.Action_Plan_Template__c =: actionPlanTemplate.Id ];
        
        Boolean error = apTemplate.addTemplateTask();
        
        System.assert( apTemplate.errorMsg == null, 'A error was returned when adding a template task ');
        
        ActionPlanTemplate__c actionPlanTemplate2 = testUtil.createNewActionPlanTemplate( 75 );
        
        System.currentPageReference().getParameters().put( 'add', '1') ;
        apTemplate          = new ActionPlanTemplates( actionPlanTemplate );
        apTemplate.aptTasks = new List<APTTaskTemplate__c>();
        apTemplate.aptTasks = [ select a.Type__c, a.Subject__c, a.Priority__c, a.Dependent__c, a.Name, a.User__c,
                                 a.User__r.Name, a.Id, a.DaysFromStart__c, a.CreatedById, a.Action_Plan_Template__c, 
                                 a.APTTaskTemplate__r.Subject__c, a.Reminder__c, a.SendEmail__c, a.Comments__c 
                                 From APTTaskTemplate__c a 
                                 where a.Action_Plan_Template__c =: actionPlanTemplate2.Id ];
        
        error = apTemplate.addTemplateTask();
        
        System.assert( apTemplate.errorMsg != null, 'A error was not returned when adding a template task' );
        
        Test.StopTest();
    }
    
    /**
    * Test Methods
    */
    @isTest
    public static void testRemovingActionPlanTemplateTask(){
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
        
        System.currentPageReference().getParameters().put( 'remove', '1') ;
        ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
        
        apTemplate.aptTasks = new List<APTTaskTemplate__c>();
        apTemplate.aptTasks = [ select a.Type__c, a.Subject__c, a.Priority__c, a.Dependent__c, a.Name, a.User__c,
                                 a.User__r.Name, a.Id, a.DaysFromStart__c, a.CreatedById, a.Action_Plan_Template__c, 
                                 a.APTTaskTemplate__r.Subject__c, a.Reminder__c, a.SendEmail__c, a.Comments__c 
                                 From APTTaskTemplate__c a 
                                 where a.Action_Plan_Template__c =: actionPlanTemplate.Id ];
        
        apTemplate.removeTemplateTask();
        
        System.assert( apTemplate.aptTasks.size() == 2, 'Task was not deleted correctly' );
        
        Test.StopTest();
    }
    
    /**
    * Test Methods
    */
    @isTest

    public static void checkRetrievingTemplateTasks(){
    
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 4 );
        
        ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
        
        apTemplate.aptTasks = new List<APTTaskTemplate__c>();
        apTemplate.aptTasks = [ select a.Type__c, a.Subject__c, a.Priority__c, a.Dependent__c, a.Name, a.User__c,
                                 a.User__r.Name, a.Id, a.DaysFromStart__c, a.CreatedById, a.Action_Plan_Template__c, 
                                 a.APTTaskTemplate__r.Subject__c, a.Reminder__c, a.SendEmail__c, a.Comments__c 
                                 From APTTaskTemplate__c a 
                                 where a.Action_Plan_Template__c =: actionPlanTemplate.Id ];
                                 
        List<APTTaskTemplate__c> apTemplateTasks = apTemplate.getTemplateTasks();
        
        System.assert( apTemplateTasks.size() == 4, 'Incorrect size returned' );
        
        Test.StopTest();
    }
    
    /**
    * Test Methods
    */
    @isTest
    public static void checkRetrievingTemplateTasksListSize(){
    
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 4 );
        
        ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
        
        apTemplate.aptTasks = new List<APTTaskTemplate__c>();
        apTemplate.aptTasks = [ select a.Type__c, a.Subject__c, a.Priority__c, a.Dependent__c, a.Name, a.User__c,
                                 a.User__r.Name, a.Id, a.DaysFromStart__c, a.CreatedById, a.Action_Plan_Template__c, 
                                 a.APTTaskTemplate__r.Subject__c, a.Reminder__c, a.SendEmail__c, a.Comments__c 
                                 From APTTaskTemplate__c a 
                                 where a.Action_Plan_Template__c =: actionPlanTemplate.Id ];
                                 
        List<APTTaskTemplate__c> apTemplateTasks    = apTemplate.getTemplateTasks();
        Integer numTasks                            = apTemplate.getTemplateTaskSize();
        
        System.assert( apTemplateTasks.size() == numTasks, 'Incorrect size returned' );
        
        Test.StopTest();
    }
    
    /**
    * Test Methods
    */
    @isTest
    public static void checkRetrievingSubjectItems(){
    
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 5 );
        
        ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
        
        apTemplate.aptTasks = new List<APTTaskTemplate__c>();
        apTemplate.aptTasks = [ select a.Type__c, a.Subject__c, a.Priority__c, a.Dependent__c, a.Name, a.User__c,
                                 a.User__r.Name, a.Id, a.DaysFromStart__c, a.CreatedById, a.Action_Plan_Template__c, 
                                 a.APTTaskTemplate__r.Subject__c, a.Reminder__c, a.SendEmail__c, a.Comments__c 
                                 From APTTaskTemplate__c a 
                                 where a.Action_Plan_Template__c =: actionPlanTemplate.Id ];
        
        List<Selectoption> options = apTemplate.getTemplateSubjectItems();
        
        System.assert( options.size() == 6 , 'Incorrect Size for select options' );
        
        Test.StopTest();
    }
    
    /**
    * Test Methods
    */
    @isTest
    public static void testActionPlanTemplateTaskDependencySuccess(){
    
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
        
        ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
        
        APTTaskTemplate__c newAPTTask   = new APTTaskTemplate__c();
        APTTaskTemplate__c newAPTTask2  = new APTTaskTemplate__c();
        
        newAPTTask.Subject__c           = testUtil.createRandomWord();
        newAPTTask.DaysFromStart__c     = 2;
        newAPTTask.Dependent__c         = 'None';
        newAPTTask.Type__c              = 'Email';
        newAPTTask.Priority__c          = 'High';
        
        newAPTTask2.Subject__c          = testUtil.createRandomWord();
        newAPTTask2.DaysFromStart__c    = 2;
        newAPTTask2.Dependent__c        = '0';
        newAPTTask2.Type__c             = 'Email';
        newAPTTask2.Priority__c         = 'High';
        
        apTemplate.aptTasks = new List<APTTaskTemplate__c>();
        apTemplate.aptTasks.add( newAPTTask );
        apTemplate.aptTasks.add( newAPTTask2 );     
                                 
        Boolean result = apTemplate.checkCycleDependent();
        
        System.assert( !result, 'Dependency check failed' );
        
        Test.StopTest();
    }
    
    /**
    * Test Methods
    */
    @isTest
    public static void testActionPlanTemplateTaskDependencyFail(){
    
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
        
        ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
        
        APTTaskTemplate__c newAPTTask   = new APTTaskTemplate__c();
        APTTaskTemplate__c newAPTTask2  = new APTTaskTemplate__c();
        APTTaskTemplate__c newAPTTask3  = new APTTaskTemplate__c();
        
        newAPTTask.Subject__c           = testUtil.createRandomWord();
        newAPTTask.DaysFromStart__c     = 2;
        newAPTTask.Dependent__c         = '1';
        newAPTTask.Type__c              = 'Email';
        newAPTTask.Priority__c          = 'High';
        
        newAPTTask2.Subject__c          = testUtil.createRandomWord();
        newAPTTask2.DaysFromStart__c    = 2;
        newAPTTask2.Dependent__c        = '2';
        newAPTTask2.Type__c             = 'Email';
        newAPTTask2.Priority__c         = 'High';
        
        newAPTTask3.Subject__c          = testUtil.createRandomWord();
        newAPTTask3.DaysFromStart__c    = 2;
        newAPTTask3.Dependent__c        = '0';
        newAPTTask3.Type__c             = 'Email';
        newAPTTask3.Priority__c         = 'High';
        
        apTemplate.aptTasks = new List<APTTaskTemplate__c>();
        apTemplate.aptTasks.add( newAPTTask );
        apTemplate.aptTasks.add( newAPTTask2 );     
        apTemplate.aptTasks.add( newAPTTask3 );     
                                 
        Boolean result = apTemplate.checkCycleDependent();
        
        System.assert( result, 'Dependency did not fail' );
        
        Test.StopTest();
    }
    
    /**
    * Test getActionPlanTemplate Method : 
    */
    @isTest
    private static void Run(){
        
        ActionPlansTestUtil_Test ge = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c   apt = ge.createNewActionPlanTemplate( 5 );
        System.currentPageReference().getParameters().put( 'Id', apt.Id );
        Test.StartTest();
            //Gets a specific Action Plan based on query Id 
            ActionPlanTemplates apTemplate = new ActionPlanTemplates( apt );
            apTemplate.actionPlanTemplate = null;
            apTemplate.getActionPlanTemplate();
            System.assert( apTemplate.actionPlanTemplate != null );
            
            //In case the Id is not passed by URL then create a new instance of the object.
            System.currentPageReference().getParameters().remove( 'Id' );
            apTemplate = new ActionPlanTemplates( apt );
            apTemplate.actionPlanTemplate = null;
            apTemplate.getActionPlanTemplate();
            System.assert( apTemplate.actionPlanTemplate != null );
            
            //Then if the method is called trying to clone an Action Plane Template, clone the template without Id.
            System.currentPageReference().getParameters().put( 'clone', '1' );
            apTemplate = new ActionPlanTemplates( apt );
            apTemplate.actionPlanTemplate = null;
            apTemplate.getActionPlanTemplate();
            System.assert( apTemplate.actionPlanTemplate != null );
        Test.StopTest();
    }
    
    /** 
    * Test Saves Action Plan Template and all tasks
    */
    @isTest
    private static void testSaveTemplate(){
        ActionPlansTestUtil_Test ge = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c   apt = ge.createNewActionPlanTemplate( 5 );
        apt.XC_LegalEntity__c = 'EndesaX';
        User tUser = ge.createTestUser();
        ActionPlanTemplates apTemplate = new ActionPlanTemplates( apt );
        Test.StartTest();

            apTemplate.pendingTemplateDeletes = new List<APTTaskTemplate__c>();
            apTemplate.aptTasks = new List<APTTaskTemplate__c>(); 
            apTemplate.pendingTemplateDeletes.add( ge.createNewActionPlanTemplateTask(apt, 3, tUser, 'Email', 'High') );
            apTemplate.aptTasks.add( ge.createNewActionPlanTemplateTask(apt, 3, tUser, 'Email', 'High') );
            apTemplate.aptTasks.add( ge.createNewActionPlanTemplateTask(apt, 3, tUser, 'Email', 'High') );
            apTemplate.aptTasks.get(0).Dependent__c = '1';
            apTemplate.aptTasks.get(0).Subject__c = 'test';
            apTemplate.saveTemplate();
            
            System.assert( apTemplate.actionPlanTemplate != null );
            System.assert( !apTemplate.pendingTemplateDeletes.isEmpty() );
            
            //Enter to Task Catch()
            /*apTemplate.pendingTemplateDeletes = new List<APTTaskTemplate__c>();
            apTemplate.aptTasks.clear();
            apTemplate.aptTasks.add( new APTTaskTemplate__c( DaysFromStart__c = 3, Subject__c = 'test' ) );  
            apTemplate.saveTemplate();*/
            
            //System.assert( !apTemplate.aptTasks.isEmpty());
            
            //Enter to APT Catch()
            /*apTemplate.actionPlanTemplate = null;
            apTemplate.saveTemplate();
            System.assert( !apTemplate.aptTasks.isEmpty());*/
            
        Test.StopTest();
    }
}