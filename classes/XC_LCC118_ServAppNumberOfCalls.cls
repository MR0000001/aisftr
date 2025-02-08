/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 11/06/2019
* @date Modification dd/mm/yyyy
* @description  – XC_LCC118_ServAppNumberOfCalls  - controller class of XC_LCP118_ServiceAppointmentNumberOfCalls to increase Number Of Calls
*/ 
public without sharing class XC_LCC118_ServAppNumberOfCalls {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC118_ServAppNumberOfCalls');

    /**
    * @param recordId the record id
    * @description increase Number Of Calls
    * @return XXC_UTIL_Sobject.WrapperResult - the result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper increaseNumberOfCalls(String recordId){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        Map<Id,ServiceAppointment> saToUpdateMap = new Map<Id, ServiceAppointment>([SELECT Id, XC_NumberOfCalls__c
                                         FROM ServiceAppointment
                                         WHERE Id =: recordId]);  
        if(saToUpdateMap.get(recordId).XC_NumberOfCalls__c != null){                                                        
            saToUpdateMap.get(recordId).XC_NumberOfCalls__c = saToUpdateMap.get(recordId).XC_NumberOfCalls__c + 1;
            XC_UTIL_Sobject.WrapperResult result = XC_UTIL_Sobject.updateRecord(saToUpdateMap.get(recordId));
            if(result.success){
                rw.success = true;
            }
            else{
                rw.success = false;
                rw.resultMessage = result.errorMessage;            
            }
        }
        else{
            rw.success = false;
            rw.resultMessage = Label.XC_CL_NumberOfCallsNull;
        }
        return rw;
    }

}