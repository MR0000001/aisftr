/**
* @author Raffaele Pacchiano
* @date Creation  07/10/2020 
* @description XC_TR_PPM_ProjectAddError_TEST test class 
*/
@IsTest
public class XC_TR_PPM_ProjectAddError_TEST {
    static testmethod void checkAllTaskSuspended()
    {
        Test.startTest();
       
       project_cloud__Project__c project = new project_cloud__Project__c();
            project.project_cloud__IsTemplate__c =true;
            project.project_cloud__Type__c='provisioning';
            project.XC_LegalEntity__c ='EnelX';
            project.XC_Country__c ='Chile';
        	project.XC_Status__c = 'Assigned';
            insert project;
        	/**project_cloud__Project_Phase__c phFace= new project_cloud__Project_Phase__c();
            phFace.project_cloud__Project__c =project.id;
            phFace.XC_billing_phase__c = true;
            insert phFace;
        	
            project_cloud__Project_Task__c task = new project_cloud__Project_Task__c();
            task.project_cloud__Project_Phase__c = phFace.id;
            task.project_cloud__Estimated_Hours__c = 1;
            task.project_cloud__Units__c='Duration';
        	task.XC_TaskStatus__c ='NEW';
            insert task;**/
       		project.XC_Status__c = 'Planned';
        	update project;
        	project.XC_Status__c = 'Work in Progress';
        	update project;
        	project.XC_Status__c = 'Closed';
        	update project;
        	
       	 	

        	project_cloud__Project__c project1 = new project_cloud__Project__c();
            project1.project_cloud__IsTemplate__c =true;
            project1.project_cloud__Type__c='provisioning';
            project1.XC_LegalEntity__c ='EnelX';
            project1.XC_Country__c ='Chile';
        	project1.XC_Status__c = 'Assigned';
            insert project1;
       	
       
        Map<id,project_cloud__Project__c> mapOld= new Map <id,project_cloud__Project__c>();
   		Map<id,project_cloud__Project__c> mapNew= new Map <id,project_cloud__Project__c>();
        mapNew.put(project.id,project);
    	mapOld.put(project.id,project1); 
       
        XC_TR_PPM_ProjectAddError.checkAllTaskSuspended(mapNew,mapOld);
    	}
}