@isTest
public class XC_TR_WorkOrderLineItem_U_CT_TEST {
 static testMethod  void closeProjectTask (){
        test.startTest();
        List<WorkOrder> listOrd = XC_DF_WorkOrder.createWorkOrdersForLead (1);
        insert listOrd; 
        project_cloud__Project__c project = new project_cloud__Project__c();
        project.project_cloud__IsTemplate__c =true;
        project.project_cloud__Type__c='provisioning';
        project.XC_LegalEntity__c ='EnelX';
        project.XC_Country__c ='Chile';
        insert project;
        project_cloud__Project_Phase__c phFace= new project_cloud__Project_Phase__c();
        phFace.project_cloud__Project__c =project.id;
        phFace.XC_billing_phase__c = true;
        insert phFace;             
        project_cloud__Project_Task__c projectTask = new project_cloud__Project_Task__c();
        projectTask.project_cloud__Project_Phase__c = phFace.id;
        projectTask.project_cloud__Estimated_Hours__c = 1;
        projectTask.project_cloud__Units__c='Duration';
        insert projectTask;   	
        WorkOrderLineItem woli = new WorkOrderLineItem();  
     	Id rtId =Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_PE_WOLI').getRecordTypeId();
        woli.WorkOrderId= listOrd[0].Id;
     	woli.RecordTypeId=rtId;
    	insert woli;
  		woli.Status = 'Completed' ;
     	woli.XC_Project_Task__c=projectTask.id;
        woli.XC_OrderOfActivity__c=1;
        update woli;
     	WorkOrderLineItem olditem =  woli.clone(true,false,false,false);
    	olditem.Status = 'Completed' ;
     	update olditem;
     	system.debug('vecchia mappa' + olditem);
     	Map<id,WorkOrderLineItem> mapOld= new Map <id,WorkOrderLineItem>();
        mapOld.put(olditem.id,olditem);
        Map<id,WorkOrderLineItem> mapNew= new Map <id,WorkOrderLineItem>();
        mapNew.put(woli.id,woli);
        XC_TR_WorkOrderLineItem_U_CloseTask.closeProjectTask(mapOld,mapNew);
     	test.stopTest();
 }
        static testMethod  void retrievePT (){
        test.startTest();
        List<WorkOrder> listOrd = XC_DF_WorkOrder.createWorkOrdersForLead (1);
        insert listOrd; 
        project_cloud__Project__c project = new project_cloud__Project__c();
        project.project_cloud__IsTemplate__c =true;
        project.project_cloud__Type__c='provisioning';
        project.XC_LegalEntity__c ='EnelX';
        project.XC_Country__c ='Chile';
        insert project;
        project_cloud__Project_Phase__c phFace= new project_cloud__Project_Phase__c();
        phFace.project_cloud__Project__c =project.id;
        phFace.XC_billing_phase__c = true;
        insert phFace;               
        project_cloud__Project_Task__c projectTask = new project_cloud__Project_Task__c();
        projectTask.project_cloud__Project_Phase__c = phFace.id;
        projectTask.project_cloud__Estimated_Hours__c = 1;
        projectTask.project_cloud__Units__c='Duration';
        projectTask.XC_TaskStatus__c='New';
        projectTask.XC_TaskType__c='Partner Engagement';
        projectTask.project_cloud__Completed_Date__c=system.today();
        insert projectTask;
        list<id> ProjectTasksIds =new list<id>();
        ProjectTasksIds.add(projectTask.id);    	
        WorkOrderLineItem woli = new WorkOrderLineItem();  
     	Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_PE_WOLI').getRecordTypeId();
        woli.WorkOrderId= listOrd[0].Id; 
    	insert woli;
  		woli.Status = 'Completed' ;
     	woli.XC_Project_Task__c=projectTask.id;
        woli.XC_OrderOfActivity__c=1;
        update woli;
     	Map<id,WorkOrderLineItem> mapOld= new Map <id,WorkOrderLineItem>();
        mapOld.put(woli.id,woli);
        Map<id,WorkOrderLineItem> mapNew= new Map <id,WorkOrderLineItem>();
        mapNew.put(woli.id,woli);
        XC_TR_WorkOrderLineItem_U_CloseTask.retrievePT(ProjectTasksIds);
        XC_TR_WorkOrderLineItem_U_CloseTask.closeProjectTask(mapOld,mapNew);
     	test.stopTest();
 }
        static testMethod  void updatePT (){
        test.startTest();
        List<WorkOrder> listOrd = XC_DF_WorkOrder.createWorkOrdersForLead (1);
        insert listOrd; 
        project_cloud__Project__c project = new project_cloud__Project__c();
        project.project_cloud__IsTemplate__c =true;
        project.project_cloud__Type__c='provisioning';
        project.XC_LegalEntity__c ='EnelX';
        project.XC_Country__c ='Chile';
        insert project;
        project_cloud__Project_Phase__c phFace= new project_cloud__Project_Phase__c();
        phFace.project_cloud__Project__c =project.id;
        phFace.XC_billing_phase__c = true;
        insert phFace;               
        /*List<project_cloud__Project_Task__c> projectTask = new List<project_cloud__Project_Task__c>(); 
        projectTask[0].project_cloud__Project_Phase__c = phFace.id;
        projectTask[0].project_cloud__Estimated_Hours__c = 1;
        projectTask[0].project_cloud__Units__c='Duration';
        projectTask[0].XC_TaskStatus__c='New';
        projectTask[0].XC_TaskType__c='Partner Engagement';
        projectTask[0].project_cloud__Completed_Date__c=system.today();
        insert projectTask;*/
              List<project_cloud__project_task__c> projectTasksList=[select id,XC_TaskStatus__c, XC_TaskType__c,project_cloud__Completed_Date__c 
                                                              			from project_cloud__Project_Task__c
                                                                    where XC_TaskStatus__c ='Closed'];
        XC_TR_WorkOrderLineItem_U_CloseTask.updatePT(projectTasksList);
     	test.stopTest();
}
}