/**
 * The Class XC_IN034_UploadFreekWh.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 07/10/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Call Zuora to upload free kWh
 **/

public without sharing class XC_IN034_UploadFreekWh {

private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN034_UploadFreekWh');

    /** 
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @date 07/10/2019
     * @description Wrapper used by flow
     */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId; 
    }    

    
    /** 
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @date 07/10/2019
     * @param inputWrapperList the list of input wrapper
     * @description method to check if it is possible to apply frewkHw and then call Zuora 
     */
    @InvocableMethod
    public static void applyFreekWh(List<InputWrapper> inputWrapperList) {
    
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN034_UploadFreekWh_applyFreekWh');

        if(inputWrapperList.isEmpty()) {
            return;
        }

        List<String> listStepIds = new List<String>{inputWrapperList[0].stepId};
        Map<Id, XC_Provisioning_Step__c> mapSteps = XC_IN011_ChangeProvBillingProcess_D.getMapSteps(listStepIds);
        XC_Provisioning_Step__c step = mapSteps.get(inputWrapperList[0].stepId);
        String orderId = step.XC_Configuration_Item__r.NE__OrderId__c; 
        String confItemId = step.XC_Configuration_Item__c;

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@mapSteps-->' +mapSteps);

        NE__OrderItem__c item = XC_IN034_UploadFreekWh_D.getOrderItem(confItemId);
        List<NE__Order_Item_Attribute__c> itemAttrList =  item.NE__Order_Item_Attributes__r;

        Map<String, String> itemAttrMap = new Map<String, String>();
        for(NE__Order_Item_Attribute__c itemAttr : itemAttrList) {
            if(itemAttr.NE__FamPropId__r.NE__FamilyId__r.XC_LIC_Family_Name__c == 'KWH Free') {
                itemAttrMap.put(itemAttr.NE__FamPropId__r.NE__PropId__r.XC_LIC_DynamicPropertyDefinition__c, itemAttr.NE__Value__c);
            }
        }

        if(itemAttrMap.containsKey('Activation Free') && itemAttrMap.get('Activation Free') == 'true'){
           System.enqueueJob(new CallUploadFreekWh(itemAttrMap, item, step));
        }else{
            step.XC_Status__c = Label.XC_CL_Step_Skipped;
            XC_UTIL_Sobject.updateRecord(step);
        }
    }



    @TestVisible
    public class CallUploadFreekWh implements Queueable, Database.AllowsCallouts {

        Map<String, String> itemAttrMap;
        NE__OrderItem__c item;
        XC_Provisioning_Step__c step;
        
        /**
         * @description Costructor
         * @param itemAttrMap - Map<String, String>
         * @param item - NE__OrderItem__c
         * @param step - XC_Provisioning_Step__c
         */
        public CallUploadFreekWh(Map<String, String> itemAttrMap, NE__OrderItem__c item, XC_Provisioning_Step__c step) {
            this.itemAttrMap = itemAttrMap;
            this.item = item;
            this.step = step;
        }
        
        /**
         * @description Execute Queuable
         * @param context - QueueableContext
         */
        public void execute(QueueableContext context) {

            String legalEntity = item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c;
            String stream = item.NE__OrderId__r.XC_Segment__c;

            String startDateLocal;
            XC_ZuoraZQuoteUtil_U.EntityWrapper entityWr = XC_ZuoraZQuoteUtil_U.getZuoraEntityWrapper(legalEntity, stream, '');
            if(entityWr != null && String.isNotBlank(entityWr.timeZone)){
                startDateLocal = DateTime.now().format('yyyy-MM-dd', entityWr.timeZone);
                System.debug('StartDate (local time): ' + startDateLocal);
            } else {
                startDateLocal = String.valueOf(Date.Today());
                System.debug('StartDate (user local time): ' + startDateLocal);
            }

            Asset a = item.Assets__r[0];
            zqu__Quote__c quote = XC_IN034_UploadFreekWh_D.getZquote(a.XC_Original_Configuration_Item__r.XC_ZQuoteId__c);
            
            XC_REST_UploadFreekWh.WrapperRequest  wrRequest = new XC_REST_UploadFreekWh.WrapperRequest();
            wrRequest.Quantity = itemAttrMap.get('Quantity');
            wrRequest.StartDateTime = startDateLocal + 'T00:00:00';
            wrRequest.EndDateTime = String.valueOf(Date.valueOf(startDateLocal).addMonths(Integer.valueOf(itemAttrMap.get('Duration'))))+ 'T23:59:59';
            wrRequest.SubscriptionId = (String.isNotBlank(quote.XC_LastSubscriptionId__c)) ? quote.XC_LastSubscriptionId__c : quote.zqu__ZuoraSubscriptionID__c;
            wrRequest.AccountID = item.XC_BillingProfileLineItem__r.XC_ZuoraId__c;
            wrRequest.legalEntity = legalEntity;
            wrRequest.stream = stream;
            wrRequest.transactionID = item.NE__OrderId__r.XC_eMobTransactionId__c;

            XC_REST_UploadFreekWh.WrapperResponse wrResponse = XC_REST_UploadFreekWh.uploadFreekWh(wrRequest);
            System.debug('@@@ WRAPPER RESPONSE uploadFreekWh --> ' + wrResponse);

            if(wrResponse.errors != null && !(wrResponse.errors).isEmpty()){
                step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                step.XC_ErrorMessage__c = wrResponse.errors[0].title;
            }else {
                step.XC_Status__c = Label.XC_CL_Completed_Ok;
            }
            XC_UTIL_Sobject.updateRecord(step);
        }
    }
}