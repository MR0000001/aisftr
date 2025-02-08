/**
* @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
* @date Creation  25/06/2019 
* @description XC_TR_Task_Handler_TEST – Test class for XC_TR_Task_Handler
*/ 
@isTest
public class XC_TR_Task_Handler_TEST {
    
    @TestSetup
    static void setup() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Task t = new Task();
        insert t;

        List<Task> taskList = [SELECT ID FROM Task];
        System.assert(taskList.size() == 1);
    }

    @IsTest
    static void test1(){
        
        Test.startTest();
        List<Task> taskList = [SELECT ID FROM Task];
        update taskList;
        delete taskList;
        System.assert(taskList.size() == 1);
        Test.stopTest();
        
    }
}