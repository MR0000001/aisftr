@isTest
public without sharing class ActionPlanTemplateCreationCon_TEST {

    @isTest
    public static void testContructor(){
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c apTemplate    = testUtil.createNewActionPlanTemplate( 2 );
        
        System.currentPageReference().getParameters().put( 'id', null );
        ActionPlanTemplateCreationController apTemplateController = new ActionPlanTemplateCreationController( new ApexPages.StandardController( new ActionPlanTemplate__c() ) );
        
        System.currentPageReference().getParameters().put( 'id', apTemplate.Id );
        apTemplateController = new ActionPlanTemplateCreationController( new ApexPages.StandardController( new ActionPlanTemplate__c() ) );
        
        System.currentPageReference().getParameters().put( 'clone', '1' );
        apTemplateController = new ActionPlanTemplateCreationController( new ApexPages.StandardController( new ActionPlanTemplate__c() ) );
        
        Test.StopTest();
    }
    
    @isTest
    public static void testSave(){
    
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c apTemplate    = new ActionPlanTemplate__c();
        
        apTemplate.Name = testUtil.createRandomWord();
        apTemplate.XC_LegalEntity__c = 'EndesaX';
        insert apTemplate;
        APTTaskTemplate__c newAPTTask = new APTTaskTemplate__c();
        
        newAPTTask.Subject__c           = testUtil.createRandomWord();
        newAPTTask.DaysFromStart__c     = 2;
        newAPTTask.Type__c              = 'Email';
        newAPTTask.Priority__c          = 'Hight';
        
        ActionPlanTemplateCreationController apTemplateController = new ActionPlanTemplateCreationController( new ApexPages.StandardController( apTemplate ) );
        apTemplateController.actionPlanTemplates.aptTasks = new List<APTTaskTemplate__c>();
        apTemplateController.actionPlanTemplates.aptTasks.add( newAPTTask );
        Pagereference page = apTemplateController.saveTemplate();
        
        System.assert( page != null );
        
        Test.StopTest();
    }
    
    @isTest
    public static void testCancel(){
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c apTemplate    = testUtil.createNewActionPlanTemplate( 2 );
        
        System.currentPageReference().getParameters().put( 'id', apTemplate.Id );
        ActionPlanTemplateCreationController apTemplateController = new ActionPlanTemplateCreationController( new ApexPages.StandardController( new ActionPlanTemplate__c() ) );
        apTemplateController.cancelTemplate();
        
        Test.StopTest();
    }
    
    @isTest
    public static void testAddTemplateTask(){
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c apTemplate    = testUtil.createNewActionPlanTemplate( 2 );
        
        System.currentPageReference().getParameters().put( 'id', apTemplate.Id );
        ActionPlanTemplateCreationController apTemplateController = new ActionPlanTemplateCreationController( new ApexPages.StandardController( new ActionPlanTemplate__c() ) );
        apTemplateController.addTemplateTask();
        
        Test.StopTest();
    }
    
    @isTest
    public static void testRemoveTemplateTask(){
    
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c apTemplate    = testUtil.createNewActionPlanTemplate( 2 );
        
        System.currentPageReference().getParameters().put( 'id', apTemplate.Id );
        ActionPlanTemplateCreationController apTemplateController = new ActionPlanTemplateCreationController( new ApexPages.StandardController( new ActionPlanTemplate__c() ) );
        apTemplateController.removeTemplateTask();
        
        Test.StopTest();
    }
    
    @isTest
    public static void testRetrievingTemplateTasks(){
    
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c apTemplate    = testUtil.createNewActionPlanTemplate( 2 );
        
        System.currentPageReference().getParameters().put( 'id', apTemplate.Id );
        ActionPlanTemplateCreationController apTemplateController = new ActionPlanTemplateCreationController( new ApexPages.StandardController( new ActionPlanTemplate__c() ) );
        List<ActionPlanTemplateCreationController.ApTTaskWrapper> taskList =  apTemplateController.getTemplateTasks();
        
        //checks that the list is not empty
        System.assert( !taskList.isEmpty(), 'Task list was not Empty' );
        
        Test.StopTest();
    }
    
    @isTest
    public static void checkTemplateTaskSize(){
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c apTemplate    = testUtil.createNewActionPlanTemplate( 2 );
        
        System.currentPageReference().getParameters().put( 'id', apTemplate.Id );
        ActionPlanTemplateCreationController apTemplateController = new ActionPlanTemplateCreationController( new ApexPages.StandardController( new ActionPlanTemplate__c() ) );
        List<ActionPlanTemplateCreationController.ApTTaskWrapper> taskList =  apTemplateController.getTemplateTasks();
        Integer numTasks = apTemplateController.getTemplateTaskSize();
        
        //checks that the list is not empty
        System.assert( !taskList.isEmpty(), 'Task list was not Empty' );
        
        //Checks to see if both methods return same task size
        System.assertEquals( taskList.size(), numTasks );
        
        Test.StopTest();
    }
    
    @isTest
    public static void checkTemplateSubjectItem(){  
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c apTemplate    = testUtil.createNewActionPlanTemplate( 2 );
        
        System.currentPageReference().getParameters().put( 'id', apTemplate.Id );
        ActionPlanTemplateCreationController apTemplateController = new ActionPlanTemplateCreationController( new ApexPages.StandardController( new ActionPlanTemplate__c() ) );
        
        List<ActionPlanTemplateCreationController.ApTTaskWrapper> taskList  = apTemplateController.getTemplateTasks();
        List<SelectOption> subjectItems     = apTemplateController.getTemplateSubjectItems();
        
        Test.StopTest();
    }
    
    @isTest
    public static void testCyclicDependencyFalse(){
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c apTemplate    = testUtil.createNewActionPlanTemplate( 2 );
        
        apTemplate.XC_LegalEntity__c = 'EndesaX';
        update apTemplate;
        
        APTTaskTemplate__c newAPTTask   = new APTTaskTemplate__c();
        APTTaskTemplate__c newAPTTask2  = new APTTaskTemplate__c();
        
        newAPTTask.Subject__c           = testUtil.createRandomWord();
        newAPTTask.DaysFromStart__c     = 2;
        newAPTTask.Dependent__c         = 'None';
        newAPTTask.Type__c              = 'Email';
        newAPTTask.Priority__c          = 'High'; 
        
        newAPTTask2.Subject__c          = testUtil.createRandomWord();
        newAPTTask2.DaysFromStart__c    = 2;
        newAPTTask2.Dependent__c        = 'None';
        newAPTTask2.Type__c             = 'Email';
        newAPTTask2.Priority__c         = 'High';
        
        
        System.currentPageReference().getParameters().put( 'id', apTemplate.Id );
        ActionPlanTemplateCreationController apTemplateController = new ActionPlanTemplateCreationController( new ApexPages.StandardController( new ActionPlanTemplate__c() ) );
        
        apTemplateController.actionPlanTemplates.aptTasks = new List<APTTaskTemplate__c>();
        apTemplateController.actionPlanTemplates.aptTasks.add( newAPTTask );

        apTemplateController.checkCycleDependent();
        
        System.assert( apTemplateController.getErrorMsg() == '', 'dependency check failed' );
        
        Test.StopTest();
    }
    
    @isTest
    public static void testCyclicDependencySuccess(){
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c apTemplate    = testUtil.createNewActionPlanTemplate( 2 );
        
        APTTaskTemplate__c newAPTTask   = new APTTaskTemplate__c();
        APTTaskTemplate__c newAPTTask2  = new APTTaskTemplate__c();
        APTTaskTemplate__c newAPTTask3  = new APTTaskTemplate__c();
        
        newAPTTask.Subject__c           = testUtil.createRandomWord();
        newAPTTask.DaysFromStart__c     = 2;
        newAPTTask.Dependent__c         = '2';
        newAPTTask.Type__c              = 'Email';
        newAPTTask.Priority__c          = 'Hight';
        
        newAPTTask2.Subject__c          = testUtil.createRandomWord();
        newAPTTask2.DaysFromStart__c    = 2;
        newAPTTask2.Dependent__c        = '0';
        newAPTTask2.Type__c             = 'Email';
        newAPTTask2.Priority__c         = 'Hight';
        
        newAPTTask3.Subject__c          = testUtil.createRandomWord();
        newAPTTask3.DaysFromStart__c    = 2;
        newAPTTask3.Dependent__c        = '1';
        newAPTTask3.Type__c             = 'Email';
        newAPTTask3.Priority__c         = 'Hight';
        
        
        System.currentPageReference().getParameters().put( 'id', apTemplate.Id );
        ActionPlanTemplateCreationController apTemplateController = new ActionPlanTemplateCreationController( new ApexPages.StandardController( new ActionPlanTemplate__c() ) );
        
        apTemplateController.actionPlanTemplates.aptTasks = new List<APTTaskTemplate__c>();
        apTemplateController.actionPlanTemplates.aptTasks.add( newAPTTask );
        apTemplateController.actionPlanTemplates.aptTasks.add( newAPTTask2 );
        apTemplateController.actionPlanTemplates.aptTasks.add( newAPTTask3 );

        apTemplateController.checkCycleDependent();
        System.assert( apTemplateController.getErrorMsg() != null, 'dependency check failed' );
        Test.StopTest();
    }
}