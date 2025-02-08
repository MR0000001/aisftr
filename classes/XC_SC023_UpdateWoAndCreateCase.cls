/**
 * @File Name          : XC_SC023_UpdateWoAndCreateCase.cls
 * @description        : update WorkOrder to on hold and PTE Contact when its service appointment is failed visit, 
                         then create a Case to manage the WO and to schedule a new SA
 * @Author             : Andrea Bravaccino - andrea.bravaccino@nttdata.com
 * @Group              : 
 * @Last Modified By   : Andrea Bravaccino - andrea.bravaccino@nttdata.com
 * @Last Modified On   : 11/10/2019, 11:56:52
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/10/2019    Andrea Bravaccino          Initial Version
**/
public class XC_SC023_UpdateWoAndCreateCase implements Schedulable, Database.Batchable<sObject>{
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC023_UpdateWoAndCreateCase');

    /**
    * @description execute method
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 11/10/2019 
    * @param sc 
    **/
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC023_UpdateWoAndCreateCase());
    }

    /**
    * @description start method
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 11/10/2019 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Start batch XC_SC023_UpdateWoAndCreateCase'); 

        String query = 'SELECT Id, XC_StatusReason__c, ownerId, ContactId, (SELECT Id, Status, XC_StatusReason__c, ParentRecordId FROM ServiceAppointments) ' +
                    'FROM WorkOrder ' +
                    'WHERE XC_WorkTypeCategory__c = \'' + Label.XC_CL_CommercialVisit + '\' AND Status  != \'' + Label.XC_CL_OnHold + '\' AND XC_StatusReason__c != \'' + Label.XC_CL_StatusReason_PteContact + 
                    '\' AND  Id IN (SELECT ParentRecordId FROM ServiceAppointment ' +
                                    'WHERE Status = \'' + Label.XC_CL_ServiceAppointment_Scheduled + '\'';

        query = Test.isRunningTest() ? query + ')' : query + 'AND XC_OutOfDate__c = true)';

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Final Query ---> \'' + query); 
        System.debug('@@@ Final Query ---> \'' + query); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'End start method for batch XC_SC023_UpdateWoAndCreateCase'); 
        return Database.getQueryLocator(query);
    }

    /**
    * @description execute method
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 11/10/2019 
    * @param bc 
    * @param scope 
    **/
    public void execute(Database.BatchableContext bc, List<WorkOrder> scope) { 
        List<WorkOrder> woToUpdateList = new List<WorkOrder>();
        List<ServiceAppointment> saToUpdateList = new List<ServiceAppointment>();

        for (WorkOrder wo : scope) {
            wo.Status = Label.XC_CL_OnHold;
            wo.XC_StatusReason__c = Label.XC_CL_StatusReason_PteContact;
            woToUpdateList.add(wo);
            for (ServiceAppointment sa : wo.ServiceAppointments) {
                sa.Status = Label.XC_CL_Cancelled;
                sa.XC_StatusReason__c = Label.XC_CL_StatusReason_Outoftime;
                saToUpdateList.add(sa);
            }
        }
        
        Savepoint sp = Database.setSavepoint();
        List<XC_UTIL_Sobject.WrapperResult> resultList = XC_UTIL_Sobject.updateListRecords(saToUpdateList);
        if(resultList[0].success){
            resultList = XC_UTIL_Sobject.updateListRecords(woToUpdateList);
            if(!resultList[0].success){
                createBatchErrorLog(resultList, sp);
            }
        }else {
            createBatchErrorLog(resultList, sp);
        }
    }

    private static void createBatchErrorLog(List<XC_UTIL_Sobject.WrapperResult> resultList, Savepoint sp){
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();
        for(XC_UTIL_Sobject.WrapperResult wr : resultList){
            if(!wr.success){
                XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                bel.Name = 'XC_SC023_UpdateWoAndCreateCase';
                bel.XC_ErrorMessage__c = wr.errorMessage;
                bel.XC_TypeOfOperation__c = 'update WorkOrder to on hold and PTE Contact when its service appointment is failed visit, then create a Case to manage the WO and to schedule a new SA';
                bel.XC_RecordId__c = wr.errorObjectId;
                System.debug('errorLog: ' + bel);
                errorLog.add(bel);
            }
        }
        if (!errorLog.isEmpty()){
            Database.rollback(sp);
            XC_UTIL_Sobject.insertListRecords(errorLog);
        }
    }

    /**
    * @description finish method
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 11/10/2019 
    * @param bc 
    **/
    public void finish(Database.batchablecontext bc) {        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Finish XC_SC023_UpdateWoAndCreateCase');
    }
}