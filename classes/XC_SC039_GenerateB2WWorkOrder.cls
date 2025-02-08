/**
 * @author            :  Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  12/01/20201
 * @date Modification :  dd/mm/yyyy
 * @description       :  XC_SC039_GenerateB2WWorkOrder – Schedulable classe used to automatically relaunch generate work order method 
*/

public with sharing class XC_SC039_GenerateB2WWorkOrder implements Schedulable {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC039_GenerateB2WWorkOrder');

    /**
     * @description execute method
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        enqueueCallFuture(); 
    } 

    /** 
     * @description execute method
    */
    public void enqueueCallFuture() {

        String rtOrder = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        String query = 'SELECT Id FROM NE__Order__c WHERE XC_ToBeReprocessed__c = true AND XC_AlreadyReprocessed__c = false AND (NE__Type__c =\'InOrder\' OR (NE__Type__c = \'ChangeOrder\' AND XC_Subtype__c != \'Early Cancellation (Customer Acquisition)\'))  AND RecordTypeId =: rtOrder order by CreatedDate LIMIT 50';
        List<NE__Order__c> orderList = Database.query(query);

     
        if(!orderList.isEmpty()){
            for(NE__Order__c order : orderList){
                order.XC_AlreadyReprocessed__c = true;
                callGenerateWorkOrderFuture(order.id);
            }
            XC_UTIL_Sobject.updateListRecords(orderList); 
        }
        
    }   


    /** 
     * @description call b2w generate work order method
     * @orderID -  the orderID
    */
    @future(callout = true)
    public static void callGenerateWorkOrderFuture(Id orderID){
        String generateResult = B2WExtCat.WS_WorkOrders.generateWorkOrders(orderID);
        XC_UTIL_IntegrationLog.insertGenerateWorkOrderLog(generateResult, orderID, 'GenerateWorkOrder-XC_SC039_GenerateB2WWorkOrder');
    }
}