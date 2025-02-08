@IsTest
public class XC_LCC189_PPM_ContMaintService_Test{
   @TestSetup
    static void setup(){
        //Project
		    project_cloud__Project__c p = new project_cloud__Project__c(name='ProgettoTestTemplate', 
	   	                         project_cloud__Type__c='Maintenance Plan',
	   	                         project_cloud__IsTemplate__c=true,
                                 XC_LegalEntity__c='EnelXItalia',
                                 project_cloud__Units__c='Duration',
                                 XC_Country__c ='Italy'
	   	                         );
			
	        insert p;
	//Create a new phase
	        project_cloud__Project_Phase__c ph = new project_cloud__Project_Phase__c(	Name='Phase Progetto di Test',
	        																			project_cloud__Project__c=p.id
	    	                                                                    );
	        insert ph;

	        system.debug('@@@ Nome Progetto Test'+ph.name);	                
		        // Created a Project Task
	        project_cloud__Project_Task__c pt=new project_cloud__Project_Task__c(name='Project Task Test',
                                                                                  project_cloud__Duration__c=1,
                                                                                  project_cloud__Project_Phase__c=ph.id,
                                                                                  XC_TaskType__c='Reminder',
                                                                                  XC_TaskReason__c='Create Maintenance Plan',
                                                                                  XC_TaskStatus__c='Planned',
                                                                                  project_cloud__Estimated_Hours__c=1,
                                                                                  project_cloud__Autonomous_Start__c=system.today()
	    	                                                                  );
	        insert pt;
    }
   @isTest 
    public static void projectTemplateList(){
         project_cloud__Project_Task__c pt=[select id from project_cloud__project_task__c 
                                            limit 1 ];
       string recordId=pt.id;
       list<project_cloud__Project__c>projectTemplates=XC_LCC189_PPM_ContractMaintenanceService.projectTemplateList(recordId);
      /* list<id> projectTemplateIdList=new List<id>();
        for(project_cloud__Project__c proj:projectTemplates){
             projectTemplateIdList.add(proj.id);
        }*/
       project_cloud__Project__c proj=[select id from project_cloud__project__c limit 1];
        List<Contract> createContracts=XC_DF_Contract.createContracts(1);
        Date today=system.today();
        createContracts[0].EndDate=today+1;
		createContracts[0].XC_Project__c=proj.id;
        insert createContracts;
       string projectId=XC_LCC189_PPM_ContractMaintenanceService.createProject(recordId,proj.id);
    }
}