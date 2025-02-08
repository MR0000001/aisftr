/**
 * @author            : Salvatore Scarpato salvatore.scarpato@nttdata.com
 * @date Creation     : 27/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : XC_TR_ConfItem_U_CompleteStep – Class to Complete the Provisioning Step when a complete billing profile line item 
 *                      is added to the conf item
 **/
public without sharing class XC_TR_ConfItem_U_CompleteStep {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ConfItem_U_CompleteStep');
    /**
    * @description on After Update.
    * @param mapOld the map old
    * @param mapNew the map new
    */
    public static void onAfterUpdate(Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew) {
        List<String> fieldList = new List<String>{'XC_BillingProfileLineItem__c', 'XC_PaymentMethod__c'};
        List<NE__OrderItem__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        checkBillingProfile(listChanged, mapOld, mapNew);
    }

    private static void checkBillingProfile(List<NE__OrderItem__c> listChanged, Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew){
        List<String> orderItemsIdWithStepsToComplete = new List<String>();
        Map<String, List<String>> bpliOrderItemMap = new Map<String, List<String>>();
        if(!listChanged.isEmpty()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@285b Billing profile added to: '+ listChanged);
            for(NE__OrderItem__c orderItem : listChanged){
                if(!bpliOrderItemMap.containsKey(orderItem.XC_BillingProfileLineItem__c)){
                    bpliOrderItemMap.put(orderitem.XC_BillingProfileLineItem__c, new List<String>());
                }
                bpliOrderItemMap.get(orderItem.XC_BillingProfileLineItem__c).add(orderitem.Id);
            }
            Map<Id,XC_BillingProfileLineItem__c> mapBpli = new Map<Id,XC_BillingProfileLineItem__c>([SELECT Id, XC_CustomerAccount__c 
                                                                                                    FROM XC_BillingProfileLineItem__c 
                                                                                                    WHERE Id IN: bpliOrderItemMap.keyset() AND XC_Status__c = 'Active']);
            for(XC_BillingProfileLineItem__c bpli : mapBpli.values()){
                if(!String.isBlank(bpli.XC_CustomerAccount__c)){
                    orderItemsIdWithStepsToComplete.addAll(bpliOrderItemMap.get(bpli.Id));
                }
            }
            if(!orderItemsIdWithStepsToComplete.isEmpty()){
                completeProvisioningStep(orderItemsIdWithStepsToComplete, mapOld, mapNew);
            }
        }
    }

    private static void completeProvisioningStep(List<String> orderItemsIdWithStepsToComplete, Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew){
        List<XC_Provisioning_Step__c> stepListToUpdate = new List<XC_Provisioning_Step__c>();
        Map<Id, XC_Provisioning_Step__c> stepMap = new Map<Id, XC_Provisioning_Step__c>([SELECT Id, XC_Status__c, XC_Configuration_Item__c, XC_Flow_API_Name__c 
                                                                                FROM XC_Provisioning_Step__c
                                                                                WHERE XC_Configuration_Item__c  IN: orderItemsIdWithStepsToComplete
                                                                                AND  XC_Status__c =: Label.XC_CL_Provisioning_Step_InProgress
                                                                                AND (XC_Flow_API_Name__c =: Label.XC_CL_ProvisioningCheckPaymentMethod_Flow
                                                                                OR XC_Flow_API_Name__c =: Label.XC_CL_Provisioning_CommodityKo)]);

       /* List<Case> caseList = new List<Case>([SELECT Id, Status, XC_ProvisioningStep__c FROM Case WHERE Status = :Label.XC_CL_Case_InProgress AND XC_ProvisioningStep__c IN :stepMap.keySet()]);
        List<Case> caseToUpdate = new List<Case>();

        for (Case c : caseList) {
            XC_Provisioning_Step__c step = stepMap.get(c.XC_ProvisioningStep__c);
            if(step != NULL && step.XC_Flow_API_Name__c == Label.XC_CL_ProvisioningCheckPaymentMethod_Flow && mapNew.get(step.XC_Configuration_Item__c).XC_PaymentMethod__c != NULL){
                c.Status = Label.XC_CL_Case_Closed;
                caseToUpdate.add(c);

                step.XC_Status__c = Label.XC_CL_Completed_Ok;
                stepListToUpdate.add(step);
            }
        }*/

        for(XC_Provisioning_Step__c step : stepMap.values()){
            if ((step.XC_Flow_API_Name__c == Label.XC_CL_Provisioning_CommodityKo || step.XC_Flow_API_Name__c == Label.XC_CL_ProvisioningCheckPaymentMethod_Flow)
                    && mapNew.get(step.XC_Configuration_Item__c).XC_BillingProfileLineItem__c != mapOld.get(step.XC_Configuration_Item__c).XC_BillingProfileLineItem__c){
            step.XC_Status__c = Label.XC_CL_Completed_Ok;
            stepListToUpdate.add(step);
        }
        }

        XC_UTIL_Sobject.updateListRecords(stepListToUpdate);
        //XC_UTIL_Sobject.updateListRecords(caseToUpdate);
    }

}