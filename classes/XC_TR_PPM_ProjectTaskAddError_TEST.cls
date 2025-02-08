@Istest
public class XC_TR_PPM_ProjectTaskAddError_TEST {
    static testmethod void whenDeleteProjectTask()
    {
      Test.startTest();
      project_cloud__Project__c project = new project_cloud__Project__c();
      project.project_cloud__IsTemplate__c =true;
      project.project_cloud__Type__c='provisioning';
      project.XC_LegalEntity__c ='EnelX';
      project.XC_Country__c ='Chile';
      project.XC_Status__c = 'Assigned';
      insert project;
      
      
      project_cloud__Project_Phase__c ph = new project_cloud__Project_Phase__c();
      ph.project_cloud__Project__c=project.id;
      insert ph;
	  project_cloud__Project_Task__c task = new project_cloud__Project_Task__c();
      task.project_cloud__Project_Phase__c= ph.id;
      task.project_cloud__Estimated_Hours__c = 1;
      task.project_cloud__Units__c='Duration';
      task.XC_TaskStatus__c='Closed';
      insert task;
      project.XC_Status__c = 'Planned';
      update project;
      project.XC_Status__c = 'Work in Progress';
      update project;  
      project.XC_Status__c = 'Closed';
      task.addError('Il task non può essere cancellato');
      update project;        
      Map<id,project_cloud__Project_Task__c> mapTasks= new Map <id,project_cloud__Project_Task__c>();
      mapTasks.put(task.id,task);       
            
     XC_TR_PPM_ProjectTaskAddError.whenDeleteProjectTask(mapTasks);
        Test.stopTest();
    }   
}