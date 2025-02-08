@isTest
public without sharing class ActionPlanSelectController_TEST {
@isTest
    public static void checkActionPlanTemplateListEmpty(){
    
        Test.StartTest();
        
        //Delete any previous templates you might have
        List<ActionPlanTemplate__c> templateList = [ select Id from ActionPlanTemplate__c ]; 
        delete templateList;
        
        ActionPlanSelectController apSelectController = new ActionPlanSelectController( new ApexPages.StandardController( new ActionPlan__c() ) );      
        List<ActionPlanTemplate__c> APTemplates = apSelectController.getActionPlanTemplates();
        
        // verifies list is empty
        System.assert( APTemplates.isEmpty(), 'Action Plan Template List not Empty' );
        
        Test.StopTest();
    }
    
    @isTest
    public static void checkActionPlanTemplateListNotEmpty(){
    
        Test.StartTest();
        
        ActionPlansTestUtil_Test testUtil = new ActionPlansTestUtil_Test();
        
        ActionPlanTemplate__c auxTemplate;
        auxTemplate = testUtil.createNewActionPlanTemplate( 1 );
        auxTemplate = testUtil.createNewActionPlanTemplate( 1 );
        
        ActionPlanSelectController apSelectController = new ActionPlanSelectController( new ApexPages.StandardController( new ActionPlan__c() ) );      
        List<ActionPlanTemplate__c> APTemplates = apSelectController.getActionPlanTemplates();
        
        // verifies list is not empty
        System.assert( !APTemplates.isEmpty(), 'Action Plan template is empty' );
        
        Test.StopTest();
    }
}