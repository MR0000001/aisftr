/**
* @author Nicola Arrigo -
* @date Creation 19/05/2020
* @description XC_SC030_ProjectTask_EmailNotification – Batch class to send an email when project task manual must be In Progress
*/
public with sharing class XC_SC030_ProjectTaskEmailNotification implements Schedulable, Database.Batchable<sObject>{
  
   /**
     * @description execute method
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
      Id batchId = Database.executeBatch(new XC_SC030_ProjectTaskEmailNotification(), 50);
      system.debug('Id Batch '+batchId); 
  } 
    /**
     * @description Start method for batch
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {     
        string planned='planned';
        string projectTaskReminder='Reminder';
        string myQuery='SELECT id,XC_TaskType__c,project_cloud__Start__c,XC_MailInviata__c,XC_TaskStatus__c,project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Country__c,XC_TotalParentIncompleteNew__c,XC_TaskReason__c FROM project_cloud__Project_Task__c where XC_MailInviata__c=false and XC_TaskStatus__c=:planned  and XC_TaskType__c=:projectTaskReminder and XC_MaintenanceServiceProject__c =null ';
         system.debug('query'+' '+myQuery);
         return Database.getQueryLocator(myQuery);
        }
       /**
    * @description Execute method for batch
    * @param bc - Database.BatchableContext
    * @param projectTaks - List<sObject>
    */
        public void execute(Database.BatchableContext bc, List<sObject> projectTaks) {
            List<project_cloud__Project_Task__c> newtasksReminder=new List<project_cloud__Project_Task__c>(); 
         for(project_cloud__Project_Task__c t:(list<project_cloud__Project_Task__c>)projectTaks){         
              system.debug('t'+' '+t); 
              if(isReminder(t)){
                system.debug('phase Type'+' '+t.XC_TaskType__c);
                newtasksReminder.add(t);
              }        
           } 
    
          if(newtasksReminder.size()>0){
            updateProjectTaskReminder(newtasksReminder);
          }
        }
        /**
     * @description Finish method for batch
     * @param bc - BatchableContext 
    */
        public void finish(Database.BatchableContext bc) {
            System.debug('PROJECT TASK EMAIL NOTIFICATION ENDED');
        }
        
          private static Boolean isReminder(project_cloud__Project_Task__c t){
            return  t.XC_TaskType__c=='Reminder' &&
                   // t.XC_TaskReason__c=='Create Maintenance Plan' &&
                    t.project_cloud__Start__c<=system.today()&&
                    t.XC_TotalParentIncompleteNew__c==0 &&  
                    t.XC_MailInviata__c==false ;
        }   
         
          private static void updateProjectTaskReminder(List<project_cloud__Project_Task__c> newtasksReminder){
            for(project_cloud__Project_Task__c tReminder:newtasksReminder){
                system.debug('tReminderId'+' '+tReminder.id);
                Map<String, Object> projectMap = new Map<String, Object>();
               string projectCountry=tReminder.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Country__c;
               string taskReason=tReminder.XC_TaskReason__c;
               projectMap.put('varGetReason',taskReason);
               projectMap.put('varGetTask',tReminder);
               projectMap.put('varGetUserLanguage',projectCountry);
               system.debug('varGetUserLanguage'+' '+projectCountry);
               system.debug('varGetTask'+' '+tReminder);
               flow.Interview flow=new flow.Interview.XC_FL_PPM_ProjectTaskReminderNotification(projectMap);
               flow.start();
               tReminder.XC_MailInviata__c=true;
               system.debug('Mail Inviata'+' '+tReminder.XC_MailInviata__c);
              }
              try{
              update newtasksReminder;
              }catch (System.NullPointerException e) {
                system.debug('System.NullPointerException'+e);  
            }
          }   
}