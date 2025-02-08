@isTest
public class ActionPlansDisplayController_TEST {
    
    @isTest static void testController(){
        new ActionPlansDisplayController();
        new ActionPlansDisplayController().getAxplIsClassic();
    } 
    
    @isTest static void testController2(){
        new ActionPlansDisplayController(new Apexpages.StandardController( new ActionPlan__c() ) );
        new ActionPlansDisplayController(new Apexpages.StandardSetController( new List<ActionPlan__c>() ) );
        new ActionPlansDisplayController(new ImportTemplateController());
    }
}