/**
* @author Domenico Del Prete - domenico.delprete@nttdata.com
* @date Creation 01/10/2019
* @date Modification dd/mm/yyyy
* @description  – XC_LCC158_WONumberOfCalls  - controller class of XC_LCP158_WONumberOfCalls to increase Number Of Calls
*/ 
public without sharing class XC_LCC158_WONumberOfCalls {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC158_WONumberOfCalls');    

    /**
    * @description The Class resultWrapper.
    */
    public class ResultWrapper {
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String  message = 'Error'; 
    }

    /**
    * @description 
    * @author Del Prete Domenico | 1/10/2019 
    * @param recordId 
    * @return ResultWrapper 
    **/
    @AuraEnabled
    public static ResultWrapper numberOfCalls(String recordId){
        ResultWrapper rw = new ResultWrapper();
        List<WorkOrder> listOfWo = new List<WorkOrder>([SELECT Id, XC_NumberOfAttemps__c
                                                        FROM WorkOrder
                                                        WHERE Id =: recordId]);
        WorkOrder woMaster = listOfWo[0];
        if(woMaster.XC_NumberOfAttemps__c == null){
            rw.message = Label.XC_CL_NumberOfCallsNull;
            return rw;
        }
        woMaster.XC_NumberOfAttemps__c = woMaster.XC_NumberOfAttemps__c + 1;
        if(woMaster.XC_NumberOfAttemps__c>= 3){
            woMaster.XC_StatusReason__c = Label.XC_CL_StatusReason_NotLocated;
        }
        XC_UTIL_Sobject.WrapperResult dmlResult = XC_UTIL_Sobject.updateRecord(woMaster);
        if(!dmlResult.success){
            rw.message = dmlResult.errorMessage;
            return rw;
        }
        rw.success = true;
        rw.message = Label.XC_CL_NumberOfCallsIncrese;
        return rw;
    }
}