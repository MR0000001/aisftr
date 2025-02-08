@isTest
public without sharing class ActionPlanTemplateDetailCon_TEST {


    @isTest
    public static void testConstructor(){
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c apTemplate    = testUtil.createNewActionPlanTemplate( 2 );
        
        System.currentPageReference().getParameters().put( 'id', null );
        ActionPlanTemplateDetailController apTemplateDetailController = new ActionPlanTemplateDetailController( new ApexPages.StandardController( new ActionPlanTemplate__c() ) );
        
        System.currentPageReference().getParameters().put( 'id', apTemplate.Id );
        apTemplateDetailController = new ActionPlanTemplateDetailController( new ApexPages.StandardController( new ActionPlanTemplate__c() ) );
        
        Test.StopTest();
    }
    
    @isTest
    public static void testDeletActionPlanTemplate(){
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c apTemplate    = testUtil.createNewActionPlanTemplate( 2 );
        
        System.currentPageReference().getParameters().put( 'id', apTemplate.Id );
        ActionPlanTemplateDetailController apTemplateDetailController = new ActionPlanTemplateDetailController( new ApexPages.StandardController( new ActionPlanTemplate__c() ) );
        
        apTemplateDetailController.deleteTemplate();
        
        List<ActionPlanTemplate__c> auxTemplate = [ select Id from ActionPlanTemplate__c where Id =: apTemplate.Id ];
        
        //Checks to see if action plan template has been deleted
        System.assert( auxTemplate.isEmpty(), 'action plan Template was not deleted' );
        
        Test.StopTest();
    }
    
    @isTest
    public static void testRetrievingTemplateTasks(){
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c apTemplate    = testUtil.createNewActionPlanTemplate( 3 );
        
        System.currentPageReference().getParameters().put( 'id', apTemplate.Id );
        ActionPlanTemplateDetailController apTemplateDetailController = new ActionPlanTemplateDetailController( new ApexPages.StandardController( new ActionPlanTemplate__c() ) );
        
        List<APTTaskTemplate__c> taskList = apTemplateDetailController.getTemplateTasks();
        
        //Checks to see if template tasks is not empty
        System.assert( !taskList.isEmpty(), 'action plan Template tasks is empty' );
        
        //checks that list contains total number of created tasks
        System.assertEquals( 3, taskList.size() );
        
        
        Test.StopTest();
    }
    
    @isTest
    public static void testRetrievingActionPlanTemplate(){
        
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil   = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c apTemplate    = testUtil.createNewActionPlanTemplate( 3 );
        
        System.currentPageReference().getParameters().put( 'id', apTemplate.Id );
        ActionPlanTemplateDetailController apTemplateDetailController = new ActionPlanTemplateDetailController( new ApexPages.StandardController( new ActionPlanTemplate__c() ) );
        
        ActionPlanTemplate__c apTemplate2 = apTemplateDetailController.getActionPlanTemplate();
        
        //Checks to see if action plan template is retrieved
        System.assert( apTemplate2 != null, 'action plan Template tasks is empty' );
        
        //checks to see if both action plan templates are the same
        System.assertEquals( apTemplate2.Id, apTemplate.Id  );
        
        Test.StopTest();
    }
    
    @isTest
    public static void exportTest(){
    
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
        
        ActionPlanTemplateDetailController controller = new ActionPlanTemplateDetailController( new ApexPages.StandardController( new ActionPlanTemplate__c() ) );
        controller.actionPlanTemplateId = actionPlanTemplate.Id;
        
        controller.exportTemplateToXMLDoc();
        
        System.assert( controller.actionPlanExportXMLDoc != null ); 
        
        Test.StopTest();
    }
}