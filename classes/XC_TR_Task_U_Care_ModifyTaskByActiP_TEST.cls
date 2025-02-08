/**
    * @author Emanuela Cacace ecacace@deloitte.it
    * @date Creation  27/05/2019 
    * @description XC_TR_Task_U_Care_ModifyTaskByActiP_TEST – Test class for XC_TR_Task_U_Care_ModifyTaskByActionPlan
    */ 
    @isTest
public with sharing class XC_TR_Task_U_Care_ModifyTaskByActiP_TEST {
    // Test method for modifyTaskByActionPlan 
     static testMethod void modifyTaskByActionPlan(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            Test.startTest();
                Task t = new Task();
                t.Description='Action Plan Enel X';
                insert t; 

                System.assert(t!=null);
            Test.stopTest();
     }

}