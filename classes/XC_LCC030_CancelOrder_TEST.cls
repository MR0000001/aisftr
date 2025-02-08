/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  14/05/2019 
* @description XC_LCC030_CancelOrder_TEST – Test class for XC_LCC030_CancelOrder
*/
@isTest
public class XC_LCC030_CancelOrder_TEST {
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)'; 
        org.XC_Spain_Triggers__c=true;
        org.XC_Spain_ValidationRules__c =  true;
        insert org;
    } 
    //Test Method checkStatus
    static testMethod void checkStatus(){
        
        Test.startTest(); 
        NE__Order__c orderInserted = XC_DF_Order.createOrder('InOrder');
        /*
        List<ProcessInstance> processInstances = [select Id, Status from ProcessInstance where TargetObjectId = :neord.id];  
        system.debug(processInstances);
        //ProcessInstance pi = processInstances[0];
        //insert  pi;
        
        ProcessInstance pi = new ProcessInstance();
        pi.ProcessDefinitionId =
            pi.TargetObjectId =
            pi.CurrentNodeId =   
            pi.Status= Label.XC_CL_Approval_Pending;
        insert  pi;*/
        
        
        XC_LCC030_CancelOrder.resultWrapper rw = XC_LCC030_CancelOrder.checkStatus(orderInserted.Id); 
        orderInserted.XC_Status__c = Label.XC_CL_Configuration_OrderInProgress;
        update orderInserted;
        
         rw = XC_LCC030_CancelOrder.checkStatus(orderInserted.Id); 
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
        
    }

    //Test Method orderInCancelled
    static testMethod void orderInCancelled(){
        
       

        NE__Order__c orderInserted2 = XC_DF_Order.createOrder('InOrder');
        List<Opportunity> oppToInsert = XC_DF_Opportunity.createOpportunity(1,false);
        insert oppToInsert;
        
        orderInserted2.NE__OptyId__c = oppToInsert[0].Id;
         Test.startTest(); 
        update orderInserted2;

        XC_LCC030_CancelOrder.resultWrapper rw = XC_LCC030_CancelOrder.orderInCancelled(orderInserted2.Id,'Total','Compliance KO');
        System.assertEquals(true, rw!=null);
        Test.stopTest();

    }

}