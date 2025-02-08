/**
* @author Emanuela Cacace - ecacace@deloitte.it & Roberta Cossiga 
* @date Creation  06/06/2019 
* @description XC_UTIL_Task_TEST – Test class for XC_UTIL_Task
*/
@isTest
public with sharing class XC_UTIL_Task_TEST {
    //Test Method getNewSpainTask
    static testMethod void getNewTask(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest();
        XC_UTIL_Task.TaskWrapper taskW = new XC_UTIL_Task.TaskWrapper(); 
        Task  result =XC_UTIL_Task.getNewTask(taskW);
        System.assert(result!=null);
        Test.stopTest(); 
    }

}