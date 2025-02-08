/*
* @author Nicola Arrigo -
* @date Creation 29/06/2020
* @date Modification 
* @description XC_SC030_ProjectTaskEmailNot_Test 
*/
@isTest
public with sharing class XC_SC030_ProjectTaskEmailNot_Test {
    @TestSetup 
    static void setup(){
        //Create a new Project
       project_cloud__Project__c p=new project_cloud__Project__c(name='Batch_Project',
                                                                 project_cloud__Type__c='Provisioning',
                                                                  XC_Country__c='Colombia'
                                                                );
        insert p;
        //Create a new phase
        project_cloud__Project_Phase__c ph=new project_cloud__Project_Phase__c(name='Batch_Phase',
                                                                               project_cloud__Project__c=p.id);
        insert ph;
        project_cloud__Project_Task__c pt=new project_cloud__Project_Task__c(name='Batch_Task',
                                                                            project_cloud__Duration__c=1,
                                                                            project_cloud__Project_Phase__c=ph.id,
                                                                            XC_TaskType__c='Reminder',
                                                                            XC_TaskReason__c='Create Maintenance Plan',
                                                                            XC_TaskStatus__c=Constants.PROJECTTASK_PLANNED,
                                                                            project_cloud__Estimated_Hours__c=1,
                                                                            XC_MailInviata__c=false,
                                                                            project_cloud__Autonomous_Start__c=system.today()
                                                                            );
        insert pt;                                                                         
    }
    
    @isTest
    static void batchClassTest(){
        list<project_cloud__Project_Task__c> pt=[SELECT id,XC_TaskType__c,project_cloud__Start__c,XC_MailInviata__c,XC_TaskStatus__c,project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Country__c,XC_TotalParentIncompleteNew__c,XC_TaskReason__c FROM project_cloud__Project_Task__c];	
        Database.BatchableContext bc;
       test.startTest();
       XC_SC030_ProjectTaskEmailNotification obj=new XC_SC030_ProjectTaskEmailNotification();
       database.executeBatch(obj);
       obj.execute(bc,pt);
       test.stopTest();	
       system.assertEquals(pt[0].XC_MailInviata__c,true);
    }
}