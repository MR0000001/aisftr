/**
* @author FirstName : Roberta Porrega
* @date Creation 23/03/2020
* @date Modification dd/mm/yyyy
* @description - Clear Error Log
*/

public without sharing class Giic_LCC019_ClearErrorLog {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_LCC019_ClearErrorLog');
    
    /**
*@author Roberta Porrega 
*@description 
*@param recordId the record id
*@return XC_UTIL_ResultWrapper the XC UTI L result wrapper
*/
    @AuraEnabled
    public static XC_UTIL_ResultWrapper retrieveErrorLog(String recordId){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = false;
        rw.resultMessage = Label.giic_ErrorClearErrorLogs; // 'No Error Logs to delete';
        List<giic_ErrorLog__c> errorLogList = new List<giic_ErrorLog__c> ();
        Id recId = Id.valueOf(recordId);
        String sobjectType = recId.getSObjectType().getDescribe().getName();
        if(sobjectType=='gii__PurchaseOrder__c'){
            errorLogList = [   SELECT Id,giic_Process__c
                            FROM giic_ErrorLog__c
                            WHERE giic_PurchaseOrder__c =:recordId ];
        }
        else if(sobjectType=='gii__PurchaseOrderReceipt__c'){
            errorLogList =[ SELECT Id,giic_Process__c
                           FROM giic_ErrorLog__c
                           WHERE giic_PurchaseOrderReceipt__c =:recordId ];
        }
        System.debug('errorLogList1 = '+errorLogList);
        Set<String> errorName3PL = new Set<String>();
        Set<String> errorNameSAP = new Set<String>();
        Boolean foundSAP = false;
        Boolean found3PL = false;
        if(!errorLogList.isEmpty() ){
            rw.success = true;
            for(giic_ErrorLog__c errorLog  : errorLogList){
                if(errorLog.giic_Process__c == 'Integration 3PL'){
                    found3PL = true;
                    rw.fieldName = 'found3PL';
                    continue;
                }
                if(errorLog.giic_Process__c == 'Integration SAP'){
                    foundSAP = true;
                    rw.fieldName2 = 'foundSAP';
                    continue;
                }
                if(errorLog.giic_Process__c == 'Purchase Order Receipt'){
                    foundSAP = true;
                    rw.fieldName2 = 'foundSAP';
                    continue;
                }
            }
            
        }
        return rw;
    }
    
    
    /**
*@author Roberta Porrega 
*@description 
*@param recordId the record id
*@return XC_UTIL_ResultWrapper the XC UTI L result wrapper
*/
    @AuraEnabled
    public static XC_UTIL_ResultWrapper deleteErrorLog(String recordId, Boolean clear3PLError, Boolean clearSAPError){
        System.debug('clear3PLError = '+clear3PLError);
        System.debug('clearSAPError = '+clearSAPError);
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        rw.resultMessage = Label.Giic_SuccessClearErrorLog ; //'Records successfully deleted';
        List<giic_ErrorLog__c> errorLogList = new List<giic_ErrorLog__c> (); 
        Id recId = Id.valueOf(recordId);
        String sobjectType = recId.getSObjectType().getDescribe().getName();
        if(sobjectType=='gii__PurchaseOrder__c'){
            List<String> processToDelete = new List<String>();
            String process3PL = clear3PLError ? 'Integration 3PL' : ''; 
            String processSAP = clearSAPError ? 'Integration SAP' : '';  
            processToDelete.add(process3PL);
            processToDelete.add(processSAP);
            System.debug('processToDelete = '+processToDelete);
            errorLogList = [SELECT Id,giic_Process__c
                            FROM giic_ErrorLog__c
                            WHERE giic_PurchaseOrder__c =:recordId
                            AND giic_Process__c IN: processToDelete];
        }
        else if(sobjectType=='gii__PurchaseOrderReceipt__c'){
            errorLogList =[ SELECT Id,giic_Process__c
                           FROM giic_ErrorLog__c
                           WHERE giic_PurchaseOrderReceipt__c =:recordId ];
        }
        System.debug('errorLogList2 = '+errorLogList);
        if(!errorLogList.isEmpty() ){
            List<XC_UTIL_Sobject.WrapperResult> weList = XC_UTIL_Sobject.deleteListRecords(errorLogList);
            for(XC_UTIL_Sobject.WrapperResult error : weList){
                if(!error.success){
                    rw.success = false;
                    rw.resultMessage = error.errorMessage;
                    return rw;
                }
            }
        }
        return rw;
    }
    
}