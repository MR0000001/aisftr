/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 26/02/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_ExceptionLog – UTIL Class to manage exceptions
*/

public without sharing class XC_UTIL_ExceptionLog {
    /**
    *@description method insertExceptionLog
    *@param e Exception
    **/
    public static void insertExceptionLog(Exception e) {
        XC_ExceptionLog__c exceptionLog = new XC_ExceptionLog__c();

        exceptionLog.XC_MessageException__c	= 'Error in Line Number [' + e.getLineNumber() + '] ' +
                                                'caused by "' + e.getMessage() +
                                                '\n(Stacktrace: ' + e.getStackTraceString() + ')';
        exceptionLog.XC_ExceptionType__c	= e.getTypeName();
        exceptionLog.XC_RunningUser__c = UserInfo.getUserName();
        if(e.getTypeName().equals('System.DmlException')) {
            exceptionLog.XC_RecordId__c = e.getDmlId(0);
            exceptionLog.XC_MessageDML__c	= 'Error for Field "' + e.getDmlFieldNames(0) + '". ' +
                                                'Message: "' + e.getDmlMessage(0);
            exceptionLog.XC_DMLType__c = String.valueOf(e.getDmlType(0));
        }

        try {
            if(Limits.getLimitDMLStatements() - Limits.getDMLStatements() > 0 && Schema.sObjectType.XC_ExceptionLog__c.isCreateable()) {
                insert exceptionLog;
            }
            else {
                System.debug('@@@ Exception in XC_UTIL_ExceptionLog ---> Too many DML.');
            }
        }
        catch(Exception exp) {
            System.debug('@@@ Exception in XC_UTIL_ExceptionLog ---> ' + exp.getMessage());
        }
    }

    /**
    * @author Eleni Tsiolaki - etsiolaki@deloitte.gr
    * @date Creation 26/01/2022
    * @date Modification dd/mm/yyyy
    * @description method insertExceptionLog
    * @param e Exception
    * @param recordId - String
    **/
    public static void insertExceptionLog(Exception e, String recordId) {

        XC_ExceptionLog__c exceptionLog = new XC_ExceptionLog__c();

        exceptionLog.XC_MessageException__c = 'Error in Line Number [' + e.getLineNumber() + '] ' +
                                                'caused by "' + e.getMessage() +
                                                '\n(Stacktrace: ' + e.getStackTraceString() + ')';
        exceptionLog.XC_ExceptionType__c    = e.getTypeName();
        exceptionLog.XC_RunningUser__c = UserInfo.getUserName();
        if(e.getTypeName().equals('System.DmlException')) {
            exceptionLog.XC_RecordId__c = e.getDmlId(0);
            exceptionLog.XC_MessageDML__c   = 'Error for Field "' + e.getDmlFieldNames(0) + '". ' +
                                                'Message: "' + e.getDmlMessage(0);
            exceptionLog.XC_DMLType__c = String.valueOf(e.getDmlType(0));
        }

        if(string.isBlank(exceptionLog.XC_RecordId__c)) {
            exceptionLog.XC_RecordId__c = recordId;
        }

        try {
            if(Limits.getLimitDMLStatements() - Limits.getDMLStatements() > 0 && Schema.sObjectType.XC_ExceptionLog__c.isCreateable()) {
                insert exceptionLog;
            }
            else {
                System.debug('@@@ Exception in XC_UTIL_ExceptionLog ---> Too many DML.');
            }
        }
        catch(Exception exp) {
            System.debug('@@@ Exception in XC_UTIL_ExceptionLog ---> ' + exp.getMessage());
        }
    }
}