/**
 * @File Name          : XC_SC025_UpdateRejectedWo.cls
 * @description        : update WorkOrders older then 6 months to cannot complete 
 * @Author             : Andrea Bravaccino - andrea.bravaccino@nttdata.com
 * @Group              : 
 * @Last Modified By   : Andrea Bravaccino - andrea.bravaccino@nttdata.com
 * @Last Modified On   : 14/10/2019, 09:47:26
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    14/10/2019    Andrea Bravaccino         Initial Version
**/
public with sharing class XC_SC025_UpdateRejectedWo implements Schedulable, Database.Batchable<sObject>{
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC025_UpdateRejectedWo');
    
    /**
    * @description execute method
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 14/10/2019 
    * @param sc 
    **/
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC025_UpdateRejectedWo());
    }

    /**
    * @description start method
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 14/10/2019 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Start batch XC_SC025_UpdateRejectedWo'); 

        String query = 'SELECT Id, XC_StatusReason__c, Status ' +
                    'FROM WorkOrder ' +
                    'WHERE XC_WorkTypeCategory__c = \'' + Label.XC_CL_CommercialVisit + '\' AND Status  = \'' + Label.XC_CL_WorkOrder_New + '\' AND XC_StatusReason__c = \'' + Label.XC_CL_WorkOrder_AssignmentError + 
                    '\'';

        query = Test.isRunningTest() ? query : query + ' AND  XC_ReadyForCanceled__c = true';

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Final Query ---> \'' + query); 
        System.debug('@@@ Final Query ---> \'' + query); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'End start method for batch XC_SC025_UpdateRejectedWo'); 
        return Database.getQueryLocator(query);
    }

    /**
    * @description execute method
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 14/10/2019 
    * @param bc 
    * @param scope 
    **/
    public void execute(Database.BatchableContext bc, List<WorkOrder> scope) { 
        List<WorkOrder> woToUpdateList = new List<WorkOrder>();
        List<ServiceAppointment> saToUpdateList = new List<ServiceAppointment>();

        for (WorkOrder wo : scope) {
            wo.Status = Label.XC_CL_WorkOrder_Canceled;
            woToUpdateList.add(wo);            
        }
        
        Savepoint sp = Database.setSavepoint();
        List<XC_UTIL_Sobject.WrapperResult> resultList = XC_UTIL_Sobject.updateListRecords(woToUpdateList);
        if(!XC_UTIL_Sobject.checkDMLResults(resultList)){
            createBatchErrorLog(resultList, sp);
        }
        
    }  

    @TestVisible
    private static void createBatchErrorLog(List<XC_UTIL_Sobject.WrapperResult> resultList, Savepoint sp){
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();
        for(XC_UTIL_Sobject.WrapperResult wr : resultList){
            if(!wr.success){
                XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                bel.Name = 'XC_SC025_UpdateRejectedWo';
                bel.XC_ErrorMessage__c = wr.errorMessage;
                bel.XC_TypeOfOperation__c = 'update WorkOrders older then 6 months to cannot complete';
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
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 14/10/2019 
    * @param bc 
    **/
    public void finish(Database.batchablecontext bc) {        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Finish XC_SC025_UpdateRejectedWo');
    }
}