/**
 * @author            :  Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  02/03/2022
 * @date Modification :  dd/mm/yyyy
 * @description       :  XC_IN087_CancelSubscription - This class is called from the flow XC_FL_ChangeProvisioning_CancelSubscription
*/
 
public without sharing class XC_IN087_CancelSubscription {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN087_CancelSubscription');

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
    * @description method to perform the cancel subscription and historicize the old subscription name
    */
    @InvocableMethod 
    public static void cancelSubscription(List<InputWrapper> inputWrapperList) { 

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN087_CancelSubscription');

        if(!inputWrapperList.isEmpty() && Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){

            List<String> listStepIds = new List<String>{inputWrapperList[0].stepId};
            Map<Id, XC_Provisioning_Step__c> mapSteps = XC_IN087_CancelSubscription_D.getMapSteps(listStepIds);
            if(mapSteps.isEmpty()){
                return;
            }

            XC_Provisioning_Step__c step = mapSteps.get(inputWrapperList[0].stepId);
            String orderId = step.XC_Configuration_Item__r.NE__OrderId__c; 
            String confItemId = step.XC_Configuration_Item__c;
            String stream = step.XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c;
            String parentOiId = step.XC_Configuration_Item__r.NE__Parent_Order_Item__c;
            Map<Id,NE__OrderItem__c> itemMap = XC_IN087_CancelSubscription_D.getOrderItemInfo(confItemId, parentOiId);

            if(itemMap.get(confItemId).Assets__r.isEmpty()){
                updateStepsStatus(step.Id, Label.XC_CL_Step_CompletedKO, Label.XC_CL_MissingAsset);
                return;
            }

            //getAsset linked to the order item
            Set<Asset> assSet = getAssetSet(itemMap);

            if(String.isBlank(itemMap.get(confItemId).Assets__r[0].XC_SubscriptionName__c)){ 
                updateStepsStatus(step.Id, Label.XC_CL_Step_CompletedKO, Label.XC_CL_NoSubscription);
            }else {
                // call zuora and update asset
                manageCallZuoraAndUpdateObjects(itemMap.get(confItemId).Assets__r[0].XC_SubscriptionName__c, assSet, step);
            }
        }
    }

    /**
    * @description method to get all assets related to the order item
    * @param itemMap the item map
    * @return assetSet
    */
    private static Set<Asset> getAssetSet(Map<Id,NE__OrderItem__c> itemMap){
        Set<Asset> assetSet = new Set<Asset>();
        for(NE__OrderItem__c item : itemMap.values()){
            if(!item.Assets__r.isEmpty()){
                assetSet.addAll(item.Assets__r);
            }
        }

        return assetSet;
    }

    /**
    * @description method to manage call zuora and update objects 
    * @param subscriptionName the subscription name
    * @param assetSet the asset set
    * @param step the step 

    */
    private static void manageCallZuoraAndUpdateObjects(String subscriptionName, Set<Asset> assetSet, XC_Provisioning_Step__c step){

        XC_REST_GetSubscription.WrapperRequest wrReq = new XC_REST_GetSubscription.WrapperRequest();
        wrReq.legalEntity = step.XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c;
        wrReq.stream = step.XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c;
        //[Begin - NR1640 Fix - 20220502 - LR]
        wrReq.cancellationEffectiveDate = step.XC_LastInvoiceDate__c; // if the last invoice date field is populated, it allows the subscription to be cancelled on a that specific date
        //[End - NR1640 Fix - 20220502 - LR]

        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        XC_REST_CancelSubscription.WrapperResponse result = XC_REST_CancelSubscription.cancelSubscriptionByName(subscriptionName, wrReq);
        manageZuoraResponse(result, assetSet, step);
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
    * @description method to manage the update zuora account response  and update the previous subscription name on the asset
    * @param result the cancel subscription result 
    * @param assetList the asset set
    * @param step the provisioning step
    */
    public static void manageZuoraResponse(XC_REST_CancelSubscription.WrapperResponse result, Set<Asset> assetSet, XC_Provisioning_Step__c step){

        List<XC_Integration_Log__c> integrationLogs = new List<XC_Integration_Log__c>();

        if(result!=null){
            
            if(result.integrationLog!=null){
                integrationLogs.add(result.integrationLog);
            }

            if(result.success == null || !result.success){
                String errorMsg = Label.XC_CL_ErrorIntegrationZuora + ': ';
                if(result.reasons != null){
                    for(XC_REST_CancelSubscription.WrapperReason errorRes : result.reasons){
                        errorMsg += errorRes.message + ' ';
                    }
                }
               
                updateStepsStatus(step.id, Label.XC_CL_Step_CompletedKO, errorMsg); 
                if(!integrationLogs.isEmpty()){
                    XC_UTIL_Sobject.insertListRecords(integrationLogs);
                }else{
                    XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
                    XC_UTIL_IntegrationLog.LogWrapper  logWr = new XC_UTIL_IntegrationLog.LogWrapper();
                    logWr.httpMethod = 'PUT'; 
                    logWr.logIsSuccess = false;
                    logWr.logIntegrationName = 'CancelSubscription';
                    logWr.logMessage = 'CancelSubscription';
                    logWr.orderID = step.XC_Configuration_Item__r.NE__OrderId__c;
                    intLog.insertIntegReqOutboundLog(logWr);
                    intLog.insertIntegRespOutboundLog(false, Label.XC_CL_ErrorIntegrationZuora, '500', errorMsg);
                }
                return;
            }

            
            if(!integrationLogs.isEmpty()){
                XC_UTIL_Sobject.insertListRecords(integrationLogs);
            }

            
            // Update Asset
            for(Asset ass : assetSet){
                ass.XC_PreviousSubscriptionName__c = ass.XC_SubscriptionName__c;
                //[Begin - NR1640 Fix - 20220502 - LR]
                //The last invoice date on the asset will be checked when creating a change order from a case.
                if(ass.id == ass.RootAssetId && step.XC_LastInvoiceDate__c != null){
                    ass.XC_LastInvoiceDate__c = step.XC_LastInvoiceDate__c;
                }
                //[Begin - NR1640 Fix - 20220502 - LR]
            }

            List<Asset> assetList = new List<Asset>();
            assetList.addAll(assetSet);
            List<XC_UTIL_Sobject.WrapperResult> resultAssetUpdateList = XC_UTIL_Sobject.updateListRecords(assetList);
            for(XC_UTIL_Sobject.WrapperResult resultAssetUpdate : resultAssetUpdateList){
                if(!resultAssetUpdate.success){
                    updateStepsStatus(step.id, Label.XC_CL_Step_CompletedKO, Label.XC_CL_ErrorUpdateAsset + ': '+ resultAssetUpdate.errorMessage); 
                    return;
                }
            }
        
            updateStepsStatus(step.id, Label.XC_CL_Completed_Ok, ''); 

        }else{
            XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
            XC_UTIL_IntegrationLog.LogWrapper  logWr = new XC_UTIL_IntegrationLog.LogWrapper();
            logWr.httpMethod = 'PUT'; 
            logWr.logIsSuccess = false;
            logWr.logIntegrationName = 'CancelSubscription';
            logWr.logMessage = 'CancelSubscription';
            logWr.orderID = step.XC_Configuration_Item__r.NE__OrderId__c;
            intLog.insertIntegReqOutboundLog(logWr);
            intLog.insertIntegRespOutboundLog(false,'ERROR. Calling Zuora', '500', 'Response NULL of the ZuoraCancelSubscription API');
            updateStepsStatus(step.id, Label.XC_CL_Step_CompletedKO, 'Response NULL of the ZuoraCancelSubscription API'); 
        }
    }
}