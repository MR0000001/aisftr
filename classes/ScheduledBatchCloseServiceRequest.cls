/**
 * Created by SNEKKANTI00 on 03/12/2020.
 */
global class ScheduledBatchCloseServiceRequest implements Database.Batchable<sObject>, Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new ScheduledBatchCloseServiceRequest());
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('START ScheduledBatchCloseServiceRequest');
        try {
            DateTime dt = System.now().addHours(-1);
            String query = 'SELECT CheckStatus__c FROM Service_Request__c WHERE CheckStatus__c = \'Aperta\' AND CreatedDate = TODAY AND CreatedDate <: dt AND (SR_Origin__c = \'URP\' OR (SR_Origin__c = \'Call Center\' AND CheckBackOffice__c = true))';
            return Database.getQueryLocator(query);
        } catch(Exception e) {
            System.debug('Exception at ScheduledBatchCloseServiceRequest START: ' + e.getMessage());

            ErrorLogEventHandler.publishEventDMLSafe(ErrorLogEventHandler.createEvent(e));
            return Database.getQueryLocator('SELECT id FROM Service_Request__c LIMIT 0');
        }
    }
    global void execute(Database.BatchableContext BC, List<Service_Request__c> toCloseServiceRequests) {
        System.debug('EXECUTE ScheduledBatchCloseServiceRequest.size: ' + toCloseServiceRequests.size());
        System.debug('EXECUTE ScheduledBatchCloseServiceRequest: ' + toCloseServiceRequests);

        try {
            ServiceRequestService.closeAndUpdateServiceRequests(toCloseServiceRequests);
        } catch(Exception e) {
            System.debug('Exception at ScheduledBatchCloseServiceRequest EXECUTE: ' + e.getMessage());
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);

            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }
    global void finish(Database.BatchableContext BC) {
        System.debug('FINISH ScheduledBatchCloseServiceRequest');
    }
}