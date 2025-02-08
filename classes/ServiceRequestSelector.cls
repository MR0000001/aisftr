/**
 * Created by SNEKKANTI00 on 13/05/2021.
 */

public with sharing class ServiceRequestSelector {
    public static void updateServiceRequests(List<Service_Request__c> serviceRequests, Boolean allOrNone) {
        try {
            Database.SaveResult[] results = Database.update(serviceRequests, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            System.debug('Exception at ServiceRequestSelector.updateServiceRequests: ' + e.getMessage());

            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }
}