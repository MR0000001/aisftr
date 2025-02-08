/** 
 * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com / Riccardo Cossu - riccardo.cossu@nttdata.com / Sala Miozza - sara.miozza@nttadata.com
 * @date 12/03/2019
 * @Modification Date 07/02/2020 Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description XC_IN013_DeprovisioningCheckRefund public class with invocable method. - Call the check refound
 */
public without sharing class XC_IN013_DeprovisioningCheckRefund {

    /** The Constant DEBUGACTIVE. */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN013_DeprovisioningCheckRefund');
    
    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
     * @description InputWrapper
     */
    public class InputWrapper{ 
        @Invocablevariable 
        public String stepId;
    }


    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
     * @description checkRefund method to check the amount of refund 
     * @param inputWrapperList the list coming from flow
     */
    @InvocableMethod
    public static void checkRefund(List<InputWrapper> inputWrapperList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In XC_IN013_DeprovisioningCheckRefund');

        if(!inputWrapperList.isEmpty() && Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){
            List<String> listStepIds = new List<String>();
            for(InputWrapper inputWr : inputWrapperList){
                listStepIds.add(inputWr.stepId);
            }
            
            XC_IN008_DeprovisioningBillingProcess_U.ListsWrapper listWr = XC_IN008_DeprovisioningBillingProcess.populateLists(listStepIds); 
            XC_IN008_DeprovisioningBillingProcess_U.WrapperConfItemsMaps wrappConfItem = XC_IN008_DeprovisioningBillingProcess.getConfigurationItemsMap(listWr.confListId);
            String refundAmount = showRefund(wrappConfItem.configurationItemBundleMap, listWr.mapSteps);

            doActions(wrappConfItem, refundAmount, listWr);
        } 
    }

    
    /**
    * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
    * @description method to do logic of check refund    
    * @param wrappConfItem the XC_IN008_DeprovisioningBillingProcess_U.WrapperConfItemsMaps
    * @param refundAmount the amount of the refund
    * @param listWr the XC_IN008_DeprovisioningBillingProcess_U.ListsWrapper
    */
    public static void doActions(XC_IN008_DeprovisioningBillingProcess_U.WrapperConfItemsMaps wrappConfItem, String refundAmount, XC_IN008_DeprovisioningBillingProcess_U.ListsWrapper listWr){

        Map<Id,NE__OrderItem__c> configurationItemWithBundleMap = wrappConfItem.configurationItemBundleMap;
        Map<Id,NE__OrderItem__c> configurationItemMap = wrappConfItem.configurationItemMap; 

        for(NE__OrderItem__c ordItem : configurationItemWithBundleMap.values()){
            if(!configurationItemMap.containsKey(ordItem.id) && listWr.confItemListId.contains(ordItem.id)){
                configurationItemMap.put(ordItem.id, ordItem);
            }
        }


        if(configurationItemMap.containsKey(listWr.mapSteps.values()[0].XC_Configuration_Item__c) && refundAmount != 'KO' && refundAmount != '0'){
            
            NE__OrderItem__c item = configurationItemMap.get(listWr.mapSteps.values()[0].XC_Configuration_Item__c);
            
            XC_REST_Indemnification.WrapperRequest wrapReq= new XC_REST_Indemnification.WrapperRequest();
            wrapReq.Amount = Decimal.valueof(refundAmount);
            wrapReq.AccountId = item.XC_BillingProfileLineItem__r.XC_ZuoraId__c;
            wrapReq.AutomaticRefund = 'Yes';
            wrapReq.CaseId = item.NE__OrderId__r.XC_CaseId__c;
            wrapReq.legalEntity = item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c;
            wrapReq.stream = item.NE__OrderId__r.XC_Segment__c;
            wrapReq.CommentsForApproval = '';
            wrapReq.ReasonCode= 'IND024';
            XC_REST_Indemnification.WrapperResponse resultRest = XC_REST_Indemnification.createIndemnification(wrapReq);
            
            completeStep(listWr.mapSteps.values()[0], resultRest, refundAmount);
     
        }else{
            completeStep(listWr.mapSteps.values()[0], null, refundAmount);
        }
    }



    /**
    * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
    * @description method to complete step  
    * @param step the step to complete
    * @param result the result
    * @param refundAmount the amount of the refund
    */
    private static void completeStep(XC_Provisioning_Step__c step, XC_REST_Indemnification.WrapperResponse result, String refundAmount){
        
        if(refundAmount != '0' && refundAmount != 'KO'){
            if(result.errors != null && !result.errors.isEmpty()){
                step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                step.XC_ErrorMessage__c = result.errors[0].title;
            } else {
                step.XC_Status__c = Label.XC_CL_Completed_Ok; 
            }
        }else if(refundAmount == 'KO'){
            step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            step.XC_ErrorMessage__c = refundAmount;
        }else if(refundAmount == '0'){
            step.XC_Status__c = Label.XC_CL_Step_Skipped;
            step.XC_ErrorMessage__c = refundAmount;
        }

        XC_UTIL_Sobject.updateRecord(step);
        
    }


    /**
     * @description show refund.
     * @param configurationItemWithBundleMap the map with configuration item id as key and configuration item as value
     * @param mapSteps the map with stepId as key and provisioningStep as value
     * @return the amount of the refund
    **/
    public static String showRefund(Map<Id,NE__OrderItem__c> configurationItemWithBundleMap, Map<Id, XC_Provisioning_Step__c> mapSteps){

   
        Map<Id,String> mapConfItemAssetOfBundleId = new Map<Id,String>();
        String assetId = '';
        if(!configurationItemWithBundleMap.isEmpty()){
            for(NE__OrderItem__c confItem : configurationItemWithBundleMap.values()){                 
                assetId = confItem.NE__AssetItemEnterpriseId__c;                      
            }
        }           

        if(!String.isBlank(assetId)){
            String orderSubtype = XC_IN008_DeprovisioningBillingProcess.getOrderSubtypeFromSteps(mapSteps.values());
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'orderSubtype---> ' + orderSubtype);
            Date dateToCalculate = (configurationItemWithBundleMap.values()[0].NE__OrderId__r.XC_CaseId__c != null && configurationItemWithBundleMap.values()[0].NE__OrderId__r.XC_CaseId__r.XC_Communication_Date__c != null) ? configurationItemWithBundleMap.values()[0].NE__OrderId__r.XC_CaseId__r.XC_Communication_Date__c : Date.today();
            XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper calcWr = XC_UTIL_PenaltyRefundCalculation.getCalculationInput(assetId, orderSubtype, dateToCalculate);
            XC_UTIL_ResultWrapper rw = XC_UTIL_DisconnectAssetManager.checkRefundBeforeDisconnectCase(calcWr);
            Map<String,String> rfData = (Map<String,String>)JSON.deserialize(rw.objectInfo, Map<String,String>.class);
            return rfData.get('refundValue');
        }

        return 'KO';
    }


    /*private static void doActions(ActionWrapper actionWr){
        List<InputWrapper> inputWrapperList = actionWr.inputWrapperList;
        Map<Id, XC_Provisioning_Step__c> mapSteps = actionWr.mapSteps;
        Map<Id, NE__OrderItem__c> configurationItemMap = actionWr.configurationItemMap;
        Map<Id,String> mapConfItemZuoraExternalId = actionWr.mapConfItemZuoraExternalId;
        List<XC_Provisioning_Step__c> stepsToComplete = new List<XC_Provisioning_Step__c> ();
        for(InputWrapper inputWr : inputWrapperList){
            String paymentMethodId;
            XC_Provisioning_Step__c step = mapSteps.get(inputWr.stepId);
            NE__OrderItem__c confItem = configurationItemMap.get(step.XC_Configuration_Item__c);
            XC_REST_CreateRefund.RequestWrapper rw = new XC_REST_CreateRefund.RequestWrapper();
            XC_REST_CreateRefund.ResponseWrapper response = new XC_REST_CreateRefund.ResponseWrapper();
            rw.comment = Label.XC_CL_CheckRefund_StandardComment;
            rw.totalAmount = confItem.NE__OneTimeFeeOv__c;
            rw.reasonCode = Label.XC_CL_CheckRefund_StandardRefund;
            if(mapConfItemZuoraExternalId!= null && mapConfItemZuoraExternalId.containsKey(confItem.Id)){
                paymentMethodId = mapConfItemZuoraExternalId.get(confItem.Id);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'PaymentMethodId -->' + paymentMethodId);
            Set<String> paymentTypeList = new Set<String>{Label.XC_CL_Credit_Card, Label.XC_CL_DirectDebt, 'CreditCard', 'DirectDebt'};
            if(paymentTypeList.contains(confItem.XC_PaymentMethod__c)){              
                rw.Type = Label.XC_CL_PaymentType_Electronic; 
                if(!String.isBlank(paymentMethodId)){
                    response = XC_REST_Createrefund.createRefund(paymentMethodId, rw);
                } 
            } else {  
                rw.Type = 'External';
                String methodType = '';
                String methodTypeLong = confItem.XC_PaymentMethod__c;
                if(!String.isBlank(methodTypeLong)){
                    if(methodTypeLong.contains(' ')){
                        methodType = methodTypeLong.remove(' ');
                    } else {
                        methodType = methodTypeLong;
                    }
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Method Type -->' + methodType);
                rw.methodType = confItem.XC_PaymentMethod__c;
                rw.refundDate = Datetime.Now().format('yyyy-MM-dd');
                if(!String.isBlank(paymentMethodId)){
                    response = XC_REST_Createrefund.createRefund(paymentMethodId, rw); 
                }
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Request wrapper of XC_IN013_DeprovisioningCheckRefund -->' + rw); 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Response from XC_REST_Createrefund.createRefund ---> '+ response);
            // Complete Step
            stepsToComplete.add(step);
        }
        completeStep(stepsToComplete);
    }*/


    /*private static void completeStep (List<XC_Provisioning_Step__c> stepsToComplete){
        List<XC_Provisioning_Step__c> stepsToUpdate = new List<XC_Provisioning_Step__c>();
        if(!stepsToComplete.isEmpty()){
            for(XC_Provisioning_Step__c step : stepsToComplete){
                step.XC_status__c = Label.XC_CL_Completed_OK;
                stepsToUpdate.add(step);
            }
            XC_UTIL_Sobject.updateListRecords(stepsToUpdate);
        }
    }


    private static ZuoraWrapper populateMaps(List<String> confItemListId){
        ZuoraWrapper zuoraWr = new ZuoraWrapper();
        Map<Id, NE__OrderItem__c> configurationItemMap = new Map<Id, NE__OrderItem__c>();
        Map<Id,String> mapConfItemZuoraExternalId = new Map<Id,String>();
        if(!confItemListId.isEmpty() && Schema.sObjectType.Zuora__Payment__c.isAccessible()){
            configurationItemMap = new Map<Id, NE__OrderItem__c>([
                SELECT Id, XC_ZQuoteId__c, XC_PaymentMethod__c, NE__OrderItem__c.CurrencyIsoCode, NE__OneTimeFeeOv__c, 
                NE__BillingProfId__r.B2WZC__Zuora_MethodPaymentId__c,NE__RecurringChargeOv__c
                FROM NE__OrderItem__c
                WHERE Id IN: confItemListId]);
            
            
            List<Zuora__Payment__c> zuoraPaymentList = [SELECT id, Zuora__External_Id__c, Zuora__Type__c,XC_CRM_ConfigurationItem__c 
                                            FROM Zuora__Payment__c 
                                            WHERE XC_CRM_ConfigurationItem__c IN: confItemListId];

            for(Zuora__Payment__c zp : zuoraPaymentList){
                mapConfItemZuoraExternalId.put(zp.XC_CRM_ConfigurationItem__c,zp.Zuora__External_Id__c);
            }                                   
        }
        zuoraWr.configurationItemMap = configurationItemMap;
        zuoraWr.mapConfItemZuoraExternalId = mapConfItemZuoraExternalId;

        return zuoraWr;
    }*/
}