/**
 * Created by SNEKKANTI00 on 13/05/2021.
 */

public with sharing class ServiceRequestService {
    public static void closeAndUpdateServiceRequests(List<Service_Request__c> serviceRequests) {
        for(Service_Request__c sr : serviceRequests) {
            sr.CheckStatus__c = 'Chiusa';
        }

        if(serviceRequests != null && !serviceRequests.isEmpty()) {
            ServiceRequestSelector.updateServiceRequests(serviceRequests, false);
        }
    }
}