public without sharing class TA_LCC219_AuthorizedProvidersCnt {
    public TA_LCC219_AuthorizedProvidersCnt() {}
    
    // @AuraEnabled
    // public static String initialize(String workOrderId) {
    //     WorkOrder workOrderToBeReturned = new WorkOrder();
    //     try {
    //         List<WorkOrder> workOrderList = [SELECT Id,
    //                                             XC_AssignedPartner__c,
    //                                             XC_AssignedPartner__r.Name,
    //                                             XC_LegalEntity__c,
    //                                             XC_AssignedResource__c,
    //                                             XC_AssignedResource__r.Name
    //                                         FROM WorkOrder
    //                                         WHERE Id =: workOrderId];

    //         if(!workOrderList.isEmpty()) {
    //             workOrderToBeReturned = workOrderList[0];
    //         }
    //     } catch(Exception e) {
    //         String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();           
    //         System.debug('[TA_LCC219_AuthorizedProvidersCnt] initialize - EXCEPTION HANDLER: ' + errorMessage);
    //         XC_UTIL_LogManagement.createLog('TA_LCC219_AuthorizedProvidersCnt', 'initialize', errorMessage, 0, errorMessage, null);
    //     }
    //     return JSON.serialize(workOrderToBeReturned);
    // }
}