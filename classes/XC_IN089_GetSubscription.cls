/**
 * @author            :  Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  29/04/2022
 * @date Modification :  dd/mm/yyyy
 * @description       :  XC_IN089_GetSubscription - This class is called from the flow XC_FL_ChangeProvisioning_GetSubscription
*/
 
public without sharing class XC_IN089_GetSubscription {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN089_GetSubscription');

    /**     
    * The Class InputWrapper.
    * @description InputWrapper
    */
    public class InputWrapper{
        @Invocablevariable     
        public String stepId;       
    }

    /**
    * @param inputWrapperList the list coming from flow
    * @description method to get subscription and save last invoice date on provisioning steps
    */
    @InvocableMethod 
    public static void getSubscription(List<InputWrapper> inputWrapperList) { 
    
        if(!inputWrapperList.isEmpty() && Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){

            List<String> listStepIds = new List<String>{inputWrapperList[0].stepId};
            Map<Id, XC_Provisioning_Step__c> mapSteps = getMapSteps(listStepIds);
            if(mapSteps.isEmpty()){
                return;
            }

            XC_Provisioning_Step__c step = mapSteps.get(inputWrapperList[0].stepId);
            String orderId = step.XC_Configuration_Item__r.NE__OrderId__c; 
            String confItemId = step.XC_Configuration_Item__c;
            String stream = step.XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c;
            Map<Id,NE__OrderItem__c> itemMap = getOrderItemInfo(confItemId);

            if(itemMap.get(confItemId).Assets__r.isEmpty()){
                updateStepsStatus(step.Id, Label.XC_CL_Step_CompletedKO, Label.XC_CL_MissingAsset);
                return;
            }

            if(String.isBlank(itemMap.get(confItemId).Assets__r[0].XC_SubscriptionName__c)){ 
                updateStepsStatus(step.Id, Label.XC_CL_Step_CompletedKO, Label.XC_CL_NoSubscription);
            }else {
                // call zuora and update provisioning step
                manageCallZuoraAndUpdateObjects(itemMap.get(confItemId).Assets__r[0].XC_SubscriptionName__c, itemMap.get(confItemId).Provisioning_Steps__r, step);
            }
        }
    }


    /**
    * @description method to manage call zuora and update objects 
    * @param subscriptionName the subscription name
    * @param stepList the step list
    * @param step the step 

    */
    private static void manageCallZuoraAndUpdateObjects(String subscriptionName, List<XC_Provisioning_Step__c> stepList, XC_Provisioning_Step__c step){

        XC_REST_GetSubscription.WrapperRequest wrReq = new XC_REST_GetSubscription.WrapperRequest();
        wrReq.legalEntity = step.XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c;
        wrReq.stream = step.XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c;
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        XC_REST_GetSubscription.WrapperResponse result = XC_REST_GetSubscription.retrieveSubscriptionByName(subscriptionName, wrReq);

        manageZuoraResponse(result, stepList, step);
    }


    /**
    * @description method to set provisioning step status   
    * @param stepId the step id
    * @param status the status to set on the step 
    * @param errorMessage the error message to set on the step
    */
    public static void updateStepsStatus(String stepId, String status, String errorMessage){
        
        XC_Provisioning_Step__c step = new XC_Provisioning_Step__c (Id = stepId, XC_Status__c = status);
        if(!String.isBlank(errorMessage)){
            step.XC_ErrorMessage__c = errorMessage;
        }        
        
        XC_UTIL_Sobject.updateRecord(step);
    }


    /**
    * @description method to manage the get subscription zuora response and update the provisioming step with last invoice date
    * @param result the get subscription result 
    * @param stepList the step list 
    * @param step the provisioning step
    */
    public static void manageZuoraResponse(XC_REST_GetSubscription.WrapperResponse result, List<XC_Provisioning_Step__c> stepList, XC_Provisioning_Step__c step){

        List<XC_Integration_Log__c> integrationLogs = new List<XC_Integration_Log__c>();

        if(result!=null){
            
            if(result.integrationLog!=null){
                integrationLogs.add(result.integrationLog);
            }

            if(result.success == null || !result.success){
                String errorMsg = Label.XC_CL_ErrorIntegrationZuora + ': ';
                if(result.reasons != null){
                    for(XC_REST_GetSubscription.WrapperReason errorRes : result.reasons){
                        errorMsg += errorRes.message + ' ';
                    }
                }
            
                updateStepsStatus(step.id, Label.XC_CL_Step_CompletedKO, errorMsg); 
                if(!integrationLogs.isEmpty()){
                    XC_UTIL_Sobject.insertListRecords(integrationLogs);
                }else{
                    XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
                    XC_UTIL_IntegrationLog.LogWrapper  logWr = new XC_UTIL_IntegrationLog.LogWrapper();
                    logWr.httpMethod = 'GET'; 
                    logWr.logIsSuccess = false;
                    logWr.logIntegrationName = 'GetSubscription';
                    logWr.logMessage = 'GetSubscription';
                    logWr.orderID = step.XC_Configuration_Item__r.NE__OrderId__c;
                    intLog.insertIntegReqOutboundLog(logWr);
                    intLog.insertIntegRespOutboundLog(false, Label.XC_CL_ErrorIntegrationZuora, '500', errorMsg);
                }
                return;
            }

            
            if(!integrationLogs.isEmpty()){
                XC_UTIL_Sobject.insertListRecords(integrationLogs);
            }

            Date lastInvoiceDate = getLastInvoiceDate(result, step);
            if(lastInvoiceDate == null){
                return; 
            }
            
            // Update ProvStep - the last invoice date is saved on all provisioning steps. This date will be used from the cancellation step of the old subscription and from the creation step of the new one. 
            for(XC_Provisioning_Step__c provStep : stepList){
                provStep.XC_LastInvoiceDate__c = lastInvoiceDate;
            }

            List<XC_UTIL_Sobject.WrapperResult> resulProvStepUpdateList = XC_UTIL_Sobject.updateListRecords(stepList);
            for(XC_UTIL_Sobject.WrapperResult resultProvStepUpdate : resulProvStepUpdateList){
                if(!resultProvStepUpdate.success){
                    updateStepsStatus(step.id, Label.XC_CL_Step_CompletedKO, resultProvStepUpdate.errorMessage); 
                    return;
                }
            }
        
            updateStepsStatus(step.id, Label.XC_CL_Completed_Ok, ''); 
        }else{
            XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
            XC_UTIL_IntegrationLog.LogWrapper  logWr = new XC_UTIL_IntegrationLog.LogWrapper();
            logWr.httpMethod = 'GET'; 
            logWr.logIsSuccess = false;
            logWr.logIntegrationName = 'GetSubscription';
            logWr.logMessage = 'GetSubscription';
            logWr.orderID = step.XC_Configuration_Item__r.NE__OrderId__c;
            intLog.insertIntegReqOutboundLog(logWr);
            intLog.insertIntegRespOutboundLog(false,'ERROR. Calling Zuora', '500', 'Response NULL of the ZuoraGetSubscription API');
            updateStepsStatus(step.id, Label.XC_CL_Step_CompletedKO, 'Response NULL of the ZuoraGetSubscription API'); 
        }
    }

    /**
	* @description method to retrieve the last invoice date 
    * @param response - XC_REST_GetSubscription.WrapperResponse
    * @param step - XC_Provisioning_Step__c
    * @return Date
	**/
    private static Date getLastInvoiceDate(XC_REST_GetSubscription.WrapperResponse response, XC_Provisioning_Step__c step){
        
       
        String legalEntity = step.XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c;
        String segment = step.XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c;
        
        XC_ZuoraZQuoteUtil_U.EntityWrapper entityWr = XC_ZuoraZQuoteUtil_U.getZuoraEntityWrapper(legalEntity, segment, step.Id);
        if(entityWr == null){
            return null;
        }

        Date lastInvoiceDate = (Test.isRunningTest()) ? Date.valueOf(DateTime.now()) : Date.valueOf(DateTime.now().format('yyyy-MM-dd', entityWr.timeZone));
    
        //assumption: if there are several roots the date is the same 
        List<Object> ratePlan = ((List<Object>) response.subscription.get('ratePlans'));
        Boolean foundDate = false;
        for (Object obj : ratePlan) {
            Map<String, Object> rp = (Map<String, Object>) obj;
            List<Object> tt = (List<Object>) rp.get('ratePlanCharges');
            for (Object rpc : tt) {
                Map<String, Object> rpcMap = (Map<String, Object>) rpc;
                if (!String.isBlank(String.valueOf(rpcMap.get('XC_Hierarchy__c'))) && String.valueOf(rpcMap.get('XC_Hierarchy__c')).equalsIgnoreCase('Root')){
                    lastInvoiceDate =  !String.isBlank(String.valueOf(rpcMap.get('chargedThroughDate'))) ? Date.valueOf(String.valueOf(rpcMap.get('chargedThroughDate'))) : (!String.isBlank(String.valueOf(rpcMap.get('effectiveStartDate')))) ? Date.valueOf(String.valueOf(rpcMap.get('effectiveStartDate'))): Date.today();
                    foundDate = true;
                    break;
                }
            }
            if(foundDate){
                break;
            }
        }

        //the last invoice date is used in the change order service up/downgrade for the B2BG stream
        return lastInvoiceDate;      
    }


    
/* @description get Steps
    *  @param listStepIds the list of step id
    *  @return the steps
    */
    public static Map<Id, XC_Provisioning_Step__c> getMapSteps(List<Id> listStepIds) {
        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>(
                [SELECT XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c, XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c, 
                XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c
                FROM XC_Provisioning_Step__c 
                WHERE Id IN: listStepIds]);
        return mapSteps;
    }


    /**
    * @description get Order Item information
    * @param confItemId the configuration item id
    * @return the order item mat
    */
    public static Map<Id, NE__OrderItem__c> getOrderItemInfo(String confItemId) {

        Map<Id, NE__OrderItem__c> itemMap = new Map<Id, NE__OrderItem__c>();
        if(!String.isBlank(confItemId)){
            itemMap = new Map<Id, NE__OrderItem__c>([SELECT id,
                                                    (SELECT Id, XC_SubscriptionName__c FROM Assets__r),
                                                    (SELECT Id FROM Provisioning_Steps__r)
                                                    FROM NE__OrderItem__c 
                                                    WHERE Id =: confItemId]);
        }
        return itemMap;
    }

}