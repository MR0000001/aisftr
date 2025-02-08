/**
* @author Federico Amici - federico.amici@nttdata.com
* @date Creation  19/06/2019 
* @description XC_TR_Opportunity_U_Delete_TEST – Test to cover delete opportunity handler
*/ 
@isTest
public without sharing class XC_TR_Task_U_Delete_TEST {
    
    @TestSetup
    private static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;

        Task t = new Task();
        insert t;
    }

    @isTest
    private static void deleteTask() {
        Task t = [SELECT Id FROM Task LIMIT 1];

        Test.startTest();
            delete t;
        Test.stopTest();    
        
        System.assert([SELECT Count() FROM Task] == 0);
    }
    
    

}