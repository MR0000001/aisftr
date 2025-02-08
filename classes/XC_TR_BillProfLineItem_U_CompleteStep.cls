/**
 * The Class XC_TR_BillProfLineItem_U_CompleteStep.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it & Salvatore Scarpato salvatpre.scarpato@nttdata.com
 * @date Creation     : 27/05/2019
 * @date Modification : 22/03/2021 by Nicola Mariniello nmariniello@deloitte.it
 * @description       : XC_TR_BillProfLineItem_U_CompleteStep – Class to Complete the Provisioning Step
 **/


public without sharing class XC_TR_BillProfLineItem_U_CompleteStep {


    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_BillProfLineItem_U_CompleteStep');


    /**
     * @description AfterBpliUpdate.
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void afterBpliUpdate(Map<Id, XC_BillingProfileLineItem__c> mapOld, Map<Id, XC_BillingProfileLineItem__c> mapNew) {
        List<String> fieldList = new List<String>{'XC_CustomerAccount__c', 'XC_Status__c'};
        List<XC_BillingProfileLineItem__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        Map<Id, XC_BillingProfileLineItem__c> bpliToProcess = new Map<Id, XC_BillingProfileLineItem__c>();

        for(XC_BillingProfileLineItem__c bpli : listChanged) {
            if(bpli.XC_Status__c == Label.XC_CL_Billing_Active || bpli.XC_Status__c == Label.XC_CL_BillingProfileStatus_Refused) {
                bpliToProcess.put(bpli.Id, bpli);
            }
        }

        if(!bpliToProcess.isEmpty()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@285 Customer account added to: '+ bpliToProcess);
            completeProvisioningStep(bpliToProcess);
        }
    }


    /**
     * @description CompleteProvisioningStep.
     * @param bpliMap
     */
    public static void completeProvisioningStep(Map<Id, XC_BillingProfileLineItem__c> bpliMap) {

        List<XC_Provisioning_Step__c> stepList = new List<XC_Provisioning_Step__c>();

        Map<Id, NE__OrderItem__c> orderItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_BillingProfileLineItem__c, XC_BillingProfileLineItem__r.XC_Status__c, NE__OrderId__r.NE__OptyId__r.XC_CommodityBillBPLI__c, NE__OrderId__r.NE__OptyId__r.XC_CommodityBillBPLI__r.XC_Status__c,
                                                                                    (SELECT id, XC_Status__c, XC_Flow_API_Name__c
                                                                                    FROM Provisioning_Steps__r
                                                                                    WHERE XC_Status__c =: Label.XC_CL_Provisioning_Step_InProgress)
                                                                                FROM NE__OrderItem__c
                                                                                WHERE XC_BillingProfileLineItem__c IN: bpliMap.keySet() OR NE__OrderId__r.NE__OptyId__r.XC_CommodityBillBPLI__c IN: bpliMap.keySet()]);
        
        for(NE__OrderItem__c orItem : orderItemMap.values()) {

            for(XC_Provisioning_Step__c step : orItem.Provisioning_Steps__r) {

                if(step.XC_Flow_API_Name__c == Label.XC_CL_ProvisioningFlow_WaitForCommodity && String.isNotBlank(orItem.NE__OrderId__r.NE__OptyId__r.XC_CommodityBillBPLI__c) && bpliMap.containsKey(orItem.NE__OrderId__r.NE__OptyId__r.XC_CommodityBillBPLI__c)) {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@285 Step to complete: ' +step.id);
                    step.XC_Status__c = (orItem.NE__OrderId__r.NE__OptyId__r.XC_CommodityBillBPLI__r.XC_Status__c == Label.XC_CL_Billing_Active) ? Label.XC_CL_Completed_Ok : Label.XC_CL_Step_CompletedWarning;
                    stepList.add(step);

                } else if((step.XC_Flow_API_Name__c == Label.XC_CL_ProvisioningCheckPaymentMethod_Flow || step.XC_Flow_API_Name__c == Label.XC_CL_Provisioning_CommodityKo || step.XC_Flow_API_Name__c == Label.XC_CL_ProvisioningCheckPaymentMethodNoZeroPrice_Flow) && bpliMap.containsKey(orItem.XC_BillingProfileLineItem__c)) {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@285 Step to complete: ' +step.id);
                    step.XC_Status__c = (orItem.XC_BillingProfileLineItem__r.XC_Status__c == Label.XC_CL_Billing_Active) ? Label.XC_CL_Completed_Ok : Label.XC_CL_Step_CompletedWarning;
                    stepList.add(step);
                }
            } 
        }

        XC_UTIL_Sobject.updateListRecords(stepList);
    }
}