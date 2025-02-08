/*
@Created date    - 19/08/2020
@Author          - Andrea Liverani (andrea.liverani@webresults.it)
@Description     - Log management utility class
*/
public without sharing class TA_UTIL_LogManagement {
    public TA_UTIL_LogManagement() {}

    public static void createLog(String className, String classMethod, String description, Double logNumber, String logText, String source) {
        
        NE__Log__c log              = new NE__Log__c();
        log.NE__Class_name__c       = String.isNotBlank(className) ? className.left(255) : null;
        log.NE__Class_method__c     = String.isNotBlank(classMethod) ? classMethod.left(255) : null;
        log.NE__Description__c      = String.isNotBlank(description) ? description.left(131072) : null;
        log.NE__LogNumber__c        = logNumber;
        log.NE__LogText__c          = String.isNotBlank(logText) ? logText.left(32768) : null;
        log.NE__Source__c           = String.isNotBlank(source) ? source.left(255) : null;

        insert log;
    }

    public static void updateLog(String logId, NE__Log__c newLog) {

        NE__Log__c logToUpdate                              = new NE__Log__c(Id = logId);
        if(String.isNotBlank(newLog.NE__Class_name__c))     logToUpdate.NE__Class_name__c = newLog.NE__Class_name__c;
        if(String.isNotBlank(newLog.NE__Class_method__c))   logToUpdate.NE__Class_method__c = newLog.NE__Class_method__c;
        if(String.isNotBlank(newLog.NE__Description__c))    logToUpdate.NE__Description__c = newLog.NE__Description__c;
        if(newLog.NE__LogNumber__c != null)                 logToUpdate.NE__LogNumber__c = newLog.NE__LogNumber__c;
        if(String.isNotBlank(newLog.NE__LogText__c))        logToUpdate.NE__LogText__c = newLog.NE__LogText__c;
        if(String.isNotBlank(newLog.NE__Source__c))         logToUpdate.NE__Source__c = newLog.NE__Source__c;

        update logToUpdate;
    }
}