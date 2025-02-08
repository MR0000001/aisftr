/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
public with sharing class XC_TR_PPM_ProjectTaskAddError {
    public static void whenDeleteProjectTask(Map<Id,project_cloud__Project_Task__c> mapTasks){
        addErrorIfTaskisWIP(mapTasks);



        List<project_cloud__Project_Task__c> listTasksStatusClosed = new List<project_cloud__Project_Task__c>();
        listTasksStatusClosed= getProjectTasks(mapTasks);
        if(listTasksStatusClosed.isEmpty()){
            return ;
        }
        for(project_cloud__Project_Task__c pt : listTasksStatusClosed){
            if(pt.id == mapTasks.get(pt.id).id){
                mapTasks.get(pt.id).addError('Il task non può essere cancellato');
            }
        }



    }


    private static List<project_cloud__Project_Task__c> getProjectTasks(Map<Id,project_cloud__Project_Task__c> mapTasks){
        List<project_cloud__Project_Task__c> listTasks = new List<project_cloud__Project_Task__c>();
        List<project_cloud__Project_Task__c> listTasksStatusClosed = new List<project_cloud__Project_Task__c>();
        listTasks = [select id, XC_TaskStatus__c,  project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Status__c,project_cloud__Project_Phase__r.project_cloud__Project__r.id  from project_cloud__Project_Task__c where id IN :mapTasks.keySet()];
        for(project_cloud__Project_Task__c p : listTasks){
            if(p.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Status__c == 'Closed'){
                listTasksStatusClosed.add(p);
            }
        }

        return listTasksStatusClosed;
    }

    private static void addErrorIfTaskisWIP(Map<Id,project_cloud__Project_Task__c> mapTasks){
        for(project_cloud__Project_Task__c pt: mapTasks.values()){
            if(pt.XC_TaskStatus__c == 'Closed' || pt.XC_TaskStatus__c == 'Work in Progress'){
                pt.addError('Il task non può essere cancellato');
            }
        }

    }





}