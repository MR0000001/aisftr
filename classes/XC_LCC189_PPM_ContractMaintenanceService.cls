/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date Creation 19/05/2020
* @description class to generate Project Maintenance Service
*/
public with sharing class XC_LCC189_PPM_ContractMaintenanceService {
 /**
   * @author Nicola Arrigo - narrigo@deloitte.it
   * @date Creation 19/05/2020
   * @description class to generate Project Template List
   * @param recordId string
   * @return List project_cloud__Project__c
   */    
    @AuraEnabled
    public static list<project_cloud__Project__c> projectTemplateList(string recordId ){
     project_cloud__Project_Task__c projTask = new project_cloud__Project_Task__c();
     projTask = retrieveProjectTask( recordId); 
      string projCountry= projTask.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Country__c;
      string legalEntity=projTask.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_LegalEntity__c;
      system.debug('country proj'+' '+projTask.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Country__c);
      list<project_cloud__Project__c>projectTemplates=new list<project_cloud__Project__c>();
      if (Schema.sObjectType.project_cloud__Project__c.fields.name.isAccessible() && 
          Schema.sObjectType.project_cloud__Project__c.fields.XC_Country__c.isAccessible()){
         projectTemplates=[select id, name,XC_Country__c
                         from project_cloud__Project__c
                         where 
                         project_cloud__IsTemplate__c=true and
                         project_cloud__Type__c=:'Maintenance Plan' and 
                         XC_LegalEntity__c=:legalEntity
                        ];
      }
      system.debug('projectTemplateName'+' '+projectTemplates[0].name);
      return projectTemplates;                                                 
    }
  /**
   * @author Nicola Arrigo
   * @date Creation 19/05/2020
   * @description class to creat Project
   * @param recordId string
   * @param projTempldateId id
   * @return string
   */  

  @AuraEnabled
  public static  string createProject(string recordId, id projTempldateId){
    project_cloud__Project_Task__c projTask=[select id,project_cloud__Project__c,XC_TaskType__c,XC_MaintenanceServiceProject__c,
                                             project_cloud__Project_Phase__r.project_cloud__Project__r.id,XC_TaskReason__c,project_cloud__End__c
                                            from project_cloud__Project_Task__c
                                            where id=:recordId ]; 
   project_cloud__Project__c projOld=new project_cloud__Project__c(); 
    if (Schema.sObjectType.project_cloud__Project__c.fields.ccpe_ocp__Account__c.isAccessible()){
    projOld=[select id,name,XC_Country__c,ccpe_ocp__Account__c from project_cloud__Project__c
              where id=:projTask.project_cloud__Project_Phase__r.project_cloud__Project__r.id];
    }
    List<Contract> contractsList=new List<Contract>(); 
    Contract c=new Contract(); 
	 boolean checkExpiration;
      system.debug('Id project Reminder '+projOld);
    if (Schema.sObjectType.Contract.isAccessible() && projOld!=null){
     contractsList=[select id,Account.XC_Country__c,XC_Project__c,ContractNumber,XC_LegalEntity__c,	XC_Segment__c ,XC_Configurations__c,XC_CheckExpirDate__c, EndDate
          from Contract
         where XC_Project__c=:projOld.id
         order by createddate desc];
		   checkExpiration=contractsList[0].XC_CheckExpirDate__c;
    }                  
    string countryProj;
	  system.debug('Contract exipiration '+checkExpiration);
   /*     if(projTask.XC_MaintenanceServiceProject__c!=null){
       return 'A project is just related to this Project Task';
   }*/
   if(projTask.XC_TaskReason__c!='Create Maintenance Plan'){
     return Label.XC_CL_MaintenanceReminderTask;
   } 
   else if(contractsList.isEmpty()){
     return Label.XC_CL_MaintenanceLackofProject;
   }else if(projTask.project_cloud__End__c<system.today()){
        //return 'Please replan the Project Task before to create the Maintenance Project';
        return Label.XC_CL_ReplanTask;
   }
   else {
    if(projold.xc_country__c!=null){
      countryProj=projold.xc_country__c;
     }
     if(contractsList.size()>0){
      c=contractsList[0];
	   if(!c.XC_CheckExpirDate__c){
             system.debug('enter if contract expired');
             return Label.XC_CL_ContractExpired;
         }
     }
   }
List<project_cloud__Project__c> projectList2 = [SELECT Id,OwnerId,Name,XC_Country__c,
                                                                         ccpe_ocp__Opportunity__c, project_cloud__Location__c,project_cloud__Units__c,
                                                                         XC_LegalEntity__c, XC_Segment__c,
                                                                         project_cloud__Start__c, project_cloud__Type__c,
                                                                         ccpe_ocp__Account__c,
                                                                         project_cloud__Monthly_Expenses__c,
                                                                         project_cloud__IsWorking_Friday__c, project_cloud__IsWorking_Monday__c, project_cloud__IsWorking_Saturday__c,
                                                                         project_cloud__IsWorking_Sunday__c, project_cloud__IsWorking_Thursday__c, project_cloud__IsWorking_Tuesday__c,
                                                                         project_cloud__IsWorking_Wednesday__c,project_cloud__Methodology__c,
                                                                         XC_MasterProject__c
                                                                         FROM project_cloud__Project__c
                                                                         where id=:projTempldateId];
     projectList2[0].Name='Maintenance Project Contract:'+' '+c.ContractNumber;
     projectList2[0].XC_Contract__c=c.id;
     projectList2[0].XC_Configuration__c=c.XC_Configurations__c;
     projectList2[0].xc_MasterProject__c=projOld.id;
   //  projectList2[0].project_cloud__Units__c='Duration';
     projectList2[0].ccpe_ocp__Account__c=projOld.ccpe_ocp__Account__c;
     projectList2[0].XC_Country__c=countryProj;
     projectList2[0].XC_LegalEntity__c=c.XC_LegalEntity__c;
     projectList2[0].XC_Segment__c=c.XC_Segment__c; 
     project_cloud__Project__c proj=project_cloud.CloneHelper.cloneProject(projectList2[0],Date.today() );
     projTask.XC_MaintenanceServiceProject__c =proj.id;
     projTask.XC_TaskStatus__c='Work in Progress';  
    // List<project_cloud__Project_Task__c> projTaskToUpdate=assignContractToTask(proj.id,c.id);
        if (Schema.sObjectType.project_cloud__Project_Task__c.isUpdateable()){
         update projTask;    
     //    update projTaskToUpdate;
        }
         return proj.id;
   }
/**
   * @author Nicola Arrigo
   * @date Creation 09/08/2020
   * @description class to retrieve Project Task
   * @param recordId string 
   * @param contractId string
   * @return List<project_cloud__project_task__c>
   */
  /*
     private static List<project_cloud__Project_Task__c> assignContractToTask(String recordId,string contractId){
       List<project_cloud__Project_Task__c> projTaskToUpdate=new List<project_cloud__Project_Task__c>();
       if(Schema.sObjectType.project_cloud__Project_Task__c.isAccessible()){
        projTaskToUpdate=[SELECT id,XC_Contract__c,XC_TaskType__c,XC_MaintenanceServiceProject__c,
                     project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Country__c,
                     project_cloud__Project_Phase__r.project_cloud__Project__r.XC_LegalEntity__c
                                                  FROM project_cloud__Project_Task__c
                                                  WHERE id=:recordId ];
          for(project_cloud__Project_Task__c task: projTaskToUpdate){
            task.XC_Contract__c=contractId;
          }                                        
         }
      return projTaskToUpdate;
     }*/

 /**
   * @author Nicola Arrigo
   * @date Creation 19/05/2020
   * @description class to retrieve Project Task
   * @param recordId string 
   * @return project_cloud__project_task__c
   */
  private static project_cloud__Project_Task__c retrieveProjectTask(String recordId){
    project_cloud__Project_Task__c projTask = new project_cloud__Project_Task__c();
    if(Schema.sObjectType.project_cloud__Project_Task__c.isAccessible()){
   projTask=[SELECT id,XC_TaskType__c,XC_MaintenanceServiceProject__c,
                project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Country__c,
                project_cloud__Project_Phase__r.project_cloud__Project__r.XC_LegalEntity__c
                                             FROM project_cloud__Project_Task__c
                                             WHERE id=:recordId ];
    }
    return projTask;
  }
}