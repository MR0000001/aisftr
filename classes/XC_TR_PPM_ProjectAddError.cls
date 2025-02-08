/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
public with sharing class XC_TR_PPM_ProjectAddError {
    public static void checkAllTaskSuspended(Map<Id,project_cloud__Project__c> mapNew,Map<Id,project_cloud__Project__c>mapOld){
    Map<Id,project_cloud__Project__c> mapProjectToSuspended = new Map<Id,project_cloud__Project__c>();
    Map<Id,project_cloud__Project__c> mapProjectToCancelled = new Map<Id,project_cloud__Project__c>();
        mapProjectToSuspended = checkStatusIsChangedToSuspended(mapNew,mapOld);
        mapProjectToCancelled = checkStatusIsChangedToClosed(mapNew,mapOld);
        if(mapProjectToSuspended.isEmpty() && mapProjectToCancelled.isEmpty()){
            system.debug('maps null');
            return;
        }
        if(mapProjectToSuspended!=null || !mapProjectToSuspended.isEmpty()){
            getAllTaskSuspended(mapProjectToSuspended,mapNew);    
        }
        if(mapProjectToCancelled!=null || !mapProjectToCancelled.isEmpty()){   
            getAllTaskClosed(mapProjectToCancelled,mapNew);
        }

    }
    private static Map<Id,project_cloud__Project__c> checkStatusIsChangedToSuspended(Map<Id,project_cloud__Project__c> mapNew,Map<Id,project_cloud__Project__c>mapOld){
       Map<Id,project_cloud__Project__c> mapProjectToSuspended = new Map<Id,project_cloud__Project__c>();
        for(Id i : mapOld.keySet()){
                if((mapNew.get(i).XC_Status__c == 'Suspended' && mapOld.get(i).XC_Status__c != 'Suspended') ){
                    System.debug('Status'+mapNew.get(i).XC_Status__c);
                    mapProjectToSuspended.put(i,mapNew.get(i));
                }  
            }
            return mapProjectToSuspended;
        }
     
        private static void getAllTaskSuspended(Map<Id,project_cloud__Project__c> mapProjectToSuspended,Map<Id,project_cloud__Project__c> mapNew){
            List<project_cloud__Project_Task__c> listAllTask = new List<project_cloud__Project_Task__c>();
            listAllTask = [select id, XC_TaskStatus__c, project_cloud__Project_Phase__r.project_cloud__Project__c,XC_TotalParentIncompleteNew__c   from project_cloud__Project_Task__c where project_cloud__Project_Phase__r.project_cloud__Project__c IN :mapProjectToSuspended.keySet()];
            for(project_cloud__Project_Task__c p : listAllTask){
               /* if(p.XC_TaskStatus__c != 'Suspended' && p.XC_TaskStatus__c != 'Closed' && p.XC_TaskStatus__c != 'Cancelled'){
                    mapNew.get(p.project_cloud__Project_Phase__r.project_cloud__Project__c).addError('It is  not possible to change the status of  the Project');
                }*/
                if(p.XC_TaskStatus__c =='NEW' ||
                   (p.XC_TaskStatus__c=='Planned' && p.XC_TotalParentIncompleteNew__c==0) ||
                    p.XC_TaskStatus__c=='Work in Progress' ||
                    p.XC_TaskStatus__c=='Re-Planning'
                   ){
                   // mapNew.get(p.project_cloud__Project_Phase__r.project_cloud__Project__c).addError('It is  not possible to change the status of  the Project'); 
                   mapNew.get(p.project_cloud__Project_Phase__r.project_cloud__Project__c).addError(Label.XC_CL_PPM_NoChangeProjectStatus);  
                 }
            }
        }    

    private static void getAllTaskClosed(Map<Id,project_cloud__Project__c> mapProjectToSuspended,Map<Id,project_cloud__Project__c> mapNew){
        system.debug('enter getAllTaskClosed');
        List<project_cloud__Project_Task__c> listAllTask = new List<project_cloud__Project_Task__c>();
        listAllTask = [select id, XC_TaskStatus__c, project_cloud__Project_Phase__r.project_cloud__Project__c,XC_TotalParentIncompleteNew__c   from project_cloud__Project_Task__c where project_cloud__Project_Phase__r.project_cloud__Project__c IN :mapProjectToSuspended.keySet()];
        for(project_cloud__Project_Task__c p : listAllTask){
            if( p.XC_TaskStatus__c != 'Closed' && p.XC_TaskStatus__c != 'Cancelled'){
              //  mapNew.get(p.project_cloud__Project_Phase__r.project_cloud__Project__c).addError('It is  not possible to change the status of  the Project');
              system.debug('task status'+' '+p.XC_TaskStatus__c);
              mapNew.get(p.project_cloud__Project_Phase__r.project_cloud__Project__c).addError(Label.XC_CL_PPM_NoChangeProjectStatus); 
            }
        }



    }

    private static Map<Id,project_cloud__Project__c> checkStatusIsChangedToClosed(Map<Id,project_cloud__Project__c> mapNew,Map<Id,project_cloud__Project__c>mapOld){
        Map<Id,project_cloud__Project__c> mapProjectToCancelled = new Map<Id,project_cloud__Project__c>();
        for(Id i : mapOld.keySet()){
            if(mapNew.get(i).XC_Status__c == 'Closed' && mapOld.get(i).XC_Status__c != 'Closed'){
                System.debug('Status'+mapNew.get(i).XC_Status__c);
                mapProjectToCancelled.put(i,mapNew.get(i));
            }
        }
        return mapProjectToCancelled;


    }
}