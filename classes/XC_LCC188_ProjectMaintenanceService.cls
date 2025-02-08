/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
public with sharing class XC_LCC188_ProjectMaintenanceService {
    @AuraEnabled 
    public static Date inizio(string recordId){
        XC_ContractItem__c cli=[select id,XC_StartDate__c from XC_ContractItem__c 
                                where id=:recordId];
        // XC_ContractItem__c cli=new XC_ContractItem__c(); 
         cli=retrieveContractLineItem(recordId);
         system.debug('date'+' '+cli.XC_StartDate__c);
         date start=cli.XC_StartDate__c;
         return cli.XC_StartDate__c;
    }
    @AuraEnabled
    public static string createMainProject(string recordId,date projStartDate){
        XC_ContractItem__c cli=new XC_ContractItem__c();
        cli=retrieveContractLineItem(recordId);
        String error = checkRecord(cli, projStartDate);
        if(error != ''){
            return error;
        }else{
            Contract cont=retrieveContract( cli);
            system.debug('Contract Detail'+' '+cont);
            if(cont.XC_Project__r.id==null){
                return 'A Maintenance Project is not associated to the contract';
            }
		project_cloud__Project__c p=retrieveProject( cont);
            id currentUserId=UserInfo.getUserId();
            UserRecordAccess recordAccess=[SELECT RecordId, HasEditAccess FROM UserRecordAccess 
                                            where UserId=:currentUserId and RecordId=:p.id];
             if(recordAccess.HasEditAccess==false){
                 return Label.XC_CL_OwnerProject;
             }                               
         /*   if(p.OwnerId!=null &&
               currentUserId!=p.OwnerId){
                   return Label.XC_CL_OwnerProject;
               }*/
            system.debug('Project Detail'+' '+p);
            system.debug('Project Units'+' '+p.project_cloud__Units__c);


            project_cloud__Project_Phase__c ph=new project_cloud__Project_Phase__c(name=cli.Name+' '+'Phase Reminder',
                    project_cloud__Project__c=cont.XC_Project__c);

            ph = insertPhase( ph);
            System.debug('PHASE ' + ph );
            system.debug('PHASE ID'+' '+ph.id);
            //stabilire dove trovo la frequenza del servizio
            Integer serviceFrequency=Integer.valueOf(cli.XC_ServiceFrequency__c);
            //Durata del servizio
            integer serviceDuration=projStartDate.daysBetween(cli.XC_EndDate__c);
            list<project_cloud__Project_Task__c> newpt=new list<project_cloud__Project_Task__c>();
             if(serviceFrequency>serviceDuration){
                project_cloud__Project_Task__c pt=new project_cloud__Project_Task__c(name='Reminder Project Task'+' '+'1',
                        project_cloud__Units__c='Duration',
                        project_cloud__Duration__c=1,
                        project_cloud__Project_Phase__c=ph.id,
                        XC_TaskType__c='Reminder',//Constants.PROJECTTASK_REMINDER,
                        XC_TaskReason__c= 'Create Maintenance Plan', //Constants.PROJECTASK_MAINTENANCEPLAN,
                        XC_TaskStatus__c='Planned',//Constants.PROJECTTASK_PLANNED,
                        //XC_Execution__c='Manual',//Constants.PROJECTTASK_MANUALEXECUTION,
                        project_cloud__Autonomous_Start__c=projStartDate,
                        XC_ContractLineItem__c=cli.id,
                        project_cloud__Completed_Date__c=projStartDate.addDays(1)
                        //XC_TaskReason__c='Partner Engagement'
                        // project_cloud__Estimated_Hours__c=1,
                        // project_cloud__Autonomous_Start__c=(projStartDate+(i)*frequency)
                );
                newpt.add(pt);
            }else{
				for(integer i=0;i<Math.roundToLong(ServiceDuration/ServiceFrequency);i++){
					integer days=i*ServiceFrequency;
					integer ptduration=ServiceFrequency;
					integer z=i+1;

					project_cloud__Project_Task__c pt=new project_cloud__Project_Task__c(name='Reminder Project Task'+' '+z,
							project_cloud__Units__c='Duration',
							project_cloud__Duration__c=1,
							project_cloud__Project_Phase__c=ph.id,
							XC_TaskType__c='Reminder',//Constants.PROJECTTASK_REMINDER,
							XC_TaskReason__c= 'Create Maintenance Plan', //Constants.PROJECTASK_MAINTENANCEPLAN,
							XC_TaskStatus__c='Planned',//Constants.PROJECTTASK_PLANNED,
							//XC_Execution__c='Manual',//Constants.PROJECTTASK_MANUALEXECUTION,
							project_cloud__Autonomous_Start__c=projStartDate.addDays(days),
							XC_ContractLineItem__c=cli.id,
							project_cloud__Completed_Date__c=projStartDate.addDays(days).addDays(1)
							//XC_TaskReason__c='Partner Engagement'
							// project_cloud__Estimated_Hours__c=1,
							// project_cloud__Autonomous_Start__c=(projStartDate+(i)*frequency)
					);
					newpt.add(pt);

				}
		    }	

         //   system.debug('Stato del Project Task'+' '+newpt[0].XC_TaskStatus__c);
         //   system.debug('size Project Task List'+' '+newpt.size());

            //XC_UTIL_Sobject.insertListRecords(newpt);
            Insert newpt;
            // insert newpt;
            //update contractLineItem
            cli.XC_ServiceFirstExecution__c=projStartDate;
            cli.XC_Service_Status__c='Planned';
            //XC_Util_Sobject.updateRecord(cli);

            update cli;


            /* project_cloud__Project_Task__c pt=new project_cloud__Project_Task__c(name='Project Task Test',
                                                                               project_cloud__Duration__c=1,
                                                                               project_cloud__Project_Phase__c=ph.id,
                                                                               XC_Execution__c=Constants.PROJECTTASK_MANUALEXECUTION,
                                                                               XC_TaskType__c=Constants.PROJECTTASK_PARTNERENG,
                                                                               XC_TaskReason__c='Partner Engagement',
                                                                             //  project_cloud__Estimated_Hours__c=1,
                                                                               project_cloud__Autonomous_Start__c=projStartDate
                                                                               );
           insert pt;*/
        }
        return 'Project Task created';
    }
    /**
   * @author Nicola Arrigo
   * @Creation Date: 08/04/2019
   * @description Method to Creat Main Project
   * @param recordId string
   * @return XC_ContractItem__c
   */
    public static XC_ContractItem__c retrieveContractLineItem (string recordId){
        XC_ContractItem__c cli=new XC_ContractItem__c();

        Map<Id, XC_ContractItem__c> mapCli = new Map<Id, XC_ContractItem__c>([select id,XC_Contract__c,XC_ServiceFrequency__c,XC_EndDate__c,
                XC_ServiceFirstExecution__c,XC_Service_Status__c,XC_StartDate__c,
                XC_Active__c,Name,
        (select id from Project_Tasks__r)
        from XC_ContractItem__c
        where id=:recordId]);

        return mapCli.values()[0];
    }
    /**
     * @description retrieve a project
     * @param  cli cli description
     * @return     return description
     */
    private static Contract retrieveContract(XC_ContractItem__c cli){
        Contract cont = new Contract();
        if(Schema.sObjectType.Contract.isAccessible()){
            cont=[select id, XC_Project__c,XC_Project__r.id from Contract
            where id=:cli.XC_Contract__c];
        }
        return cont;
    }
    /**
       /**
     * @author Andrea Di Cicco
     * @description retrieve a project
     * @param  cont cont description
     * @return      return description
     */
    private static project_cloud__Project__c retrieveProject(Contract cont){
        project_cloud__Project__c p = new project_cloud__Project__c();
        if(Schema.sObjectType.project_cloud__Project__c.isAccessible()){
            p=[select id,project_cloud__Units__c,OwnerId from project_cloud__Project__c
            where id=:cont.XC_Project__r.id];
        }
        return p;
    }
    /**
     * @author Andrea Di Cicco
     * @description insert phase
     * @param  ph ph description
     * @return    return description
     */
    private static project_cloud__Project_Phase__c insertPhase(project_cloud__Project_Phase__c ph){
        if(Schema.sObjectType.project_cloud__Project_Phase__c.isCreateable()){
            insert ph;
        }
        return ph;
    }

    /**
     * @author Andrea Di Cicco
     * @description check if the record is valid
     * @param  cli
     * @param projStartDate
     * @return    return description
     */
    private static String checkRecord(XC_ContractItem__c cli,date projStartDate){
        if(cli.XC_EndDate__c==null){
            return ' The Contract Line Item End Date is not specified';
        }
        /* else if(projStartDate<system.today()){
           return 'The date selected is minus than today';
         }*/
        else if(projStartDate==null){
            return 'Insert a date for the first execution';
        }else if(projStartDate>cli.XC_EndDate__c){
            return 'The date inserted is greater than the End date of the Contract Line Item';
        }else if(cli.XC_Service_Status__c=='Unplanable'/*Constants.CONTRACTLINEITEM_SERVICESTATUS_UNPLANABLE*/){
            return 'You cannot create a project for a Service Unplanable';
        }else if(cli.XC_Service_Status__c==null){
            return 'Please insert a value for the service state';
        }else if(!cli.XC_Active__c){
            return 'The Contract Line Item is Inactive';
        }else if(cli.Project_Tasks__r.size()>0){

            return 'Project Tasks reminder just created';
        }else if(projStartDate==cli.XC_EndDate__c){
             return label.XC_CL_ContractServiceDate;
        }
        return '';
    }

    /* public static void insertListRecords(list<project_cloud__Project_Task__c> newpt){
       if(){

       }
     }*/

}