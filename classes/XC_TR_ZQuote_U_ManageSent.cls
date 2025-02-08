/**
 * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
 * @date Creation 11/05/2019
 * @date Modification 28/10/2021 by Nicola Mariniello - nmariniello@deloitte.it
 * @description XC_TR_ZQuote_U_ManageSent 
 */


public without sharing class XC_TR_ZQuote_U_ManageSent {
    

    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description Method to populate WBE fields
    * @param mapOld
    * @param mapNew
    */ 
    public static void manageSentStatus(Map<Id, Sobject> mapOld, Map<Id, Sobject> mapNew) {
        List<String> listFieldToCheck = new List<String>{'zqu__Status__c'};
        List<zqu__Quote__c> listChanged = XC_UTIL_Sobject.getListChanged(listFieldToCheck,mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }

        Map<Id, List<XC_Provisioning_Step__c>> zquoteIdStepsMap = getStepsByZquote(listChanged);
        Map<Id, List<XC_ContractAmendment__c>> zquoteIdContractAmendsMap = getContractAmendsByZquote(listChanged);
        Map<Id, XC_Provisioning_Step__c> mapStepToUpdate = new Map<Id, XC_Provisioning_Step__c>();
        Map<Id, XC_ContractAmendment__c> mapContractAmendToUpdate = new Map<Id, XC_ContractAmendment__c>();
        for(zqu__Quote__c zquote : listChanged){
            if(zquote.zqu__Status__c == 'Sent to Z-Billing' && zquoteIdStepsMap.get(zquote.Id) != null){
                manageStepsForSentZquote(zquoteIdStepsMap.get(zquote.Id), mapStepToUpdate, zquote.zqu__ZuoraSubscriptionID__c);
            }
            if (zquote.zqu__Status__c == 'Sent to Z-Billing' && zquoteIdContractAmendsMap.get(zquote.Id) != null) {
                manageContractAmendForSentZquote(zquoteIdContractAmendsMap.get(zquote.Id), mapContractAmendToUpdate);
            }
        }

        XC_UTIL_Sobject.updateListRecords(mapStepToUpdate.values());
        XC_UTIL_Sobject.updateListRecords(mapContractAmendToUpdate.values());
    }


    /**
    * @author Nicola Mariniello - nmariniello@deloitte.it
    * @description Method to manage Steps For Sent Zquote
    * @param zquoteList 
    * @return Map<Id, List<XC_Provisioning_Step__c>>
    */
    public static Map<Id, List<XC_Provisioning_Step__c>> getStepsByZquote(List<zqu__Quote__c> zquoteList) {
 
        Map<Id, List<XC_Provisioning_Step__c>> zquoteIdStepsMap = new Map<Id, List<XC_Provisioning_Step__c>>();
        List<Id> zquoteIds = XC_UTIL_Sobject.getIds(zquoteList);
        Set<String> flowsAPINames = new Set<String>{Label.XC_CL_ProvisioningCreateSubscription_Flow,
                                                    Label.XC_CL_ProvisioningTriggerInvoiceBarcode_Flow,
                                                    Label.XC_CL_ChangeProvisioningUpDownBillingProcess_Flow,
                                                    Label.XC_CL_ProvisioningBillingProcess_Flow,
                                                    Label.XC_CL_ProvisioningPaymentCheck_Flow,
                                                    Label.XC_CL_DeprovisioningCheckPenalty,
                                                    Label.XC_CL_ChangeProvisioningSubstitutionBillingProcess_Flow,
                                                    Label.XC_CL_ProvisioningTriggerInvoice_Flow,
                                                    Label.XC_CL_ChangeProvisioningApplyCoupon_Flow,
                                                    Label.XC_CL_ChangeProvisioning_AddRemoveCoverage_BillingProcess_Flow,
                                                    Label.XC_CL_ProvisioningCreateSubscriptionTriggerInvoice_Flow,
                                                    Label.XC_CL_DeprovisioningResidualAmount_Flow,
            										'XC_FL_PPM_ChangeOrder_AddRemove',													 
            										'XC_FL_PPM_ChangeOrder_ActionChange',
            										Label.XC_CL_Provisioning_CreateSubscriptionNoZeroPrice_Flow
                                                    };

        Map<Id, NE__OrderItem__c> orderItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_ZQuoteId__c, NE__Parent_Order_Item__c, NE__OrderId__c,
                                                                                    (SELECT Id, XC_Status__c, XC_Flow_API_Name__c
                                                                                    FROM Provisioning_Steps__r
                                                                                    WHERE XC_Flow_API_Name__c IN :flowsAPINames)
                                                                                FROM NE__OrderItem__c WHERE XC_ZQuoteId__c IN :zquoteIds]);
        if(orderItemMap.isEmpty()){
            return new Map<Id, List<XC_Provisioning_Step__c>>();
        }

        Set<Id> parentOis = new Set<Id>();
        for(NE__OrderItem__c oi : orderItemMap.values()) {
            if(String.isNotBlank(oi.NE__Parent_Order_Item__c) && oi.Provisioning_Steps__r.isEmpty()) {
                parentOis.add(oi.NE__Parent_Order_Item__c);
            }
        }

        // Get steps on Parent Order Items
        Map<Id, NE__OrderItem__c> parentOrderItemMap = new Map<Id, NE__OrderItem__c>();
        if(!parentOis.isEmpty()) {
            parentOrderItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_ZQuoteId__c, NE__Parent_Order_Item__c, NE__OrderId__c,
                                                                    (SELECT Id, XC_Status__c, XC_Flow_API_Name__c
                                                                    FROM Provisioning_Steps__r
                                                                    WHERE XC_Flow_API_Name__c IN :flowsAPINames)
                                                                FROM NE__OrderItem__c
                                                                WHERE Id IN: parentOis]);
        }

        for(NE__OrderItem__c oi : orderItemMap.Values()) {

            List<XC_Provisioning_Step__c> stepsToUpdate = oi.Provisioning_Steps__r.isEmpty() ? 
            String.isNotBlank(oi.NE__Parent_Order_Item__c) ? parentOrderItemMap.get(oi.NE__Parent_Order_Item__c).Provisioning_Steps__r : 
            oi.Provisioning_Steps__r : oi.Provisioning_Steps__r;
            
            if(stepsToUpdate != null) {
                if(zquoteIdStepsMap.containsKey(oi.XC_ZQuoteId__c)) { 
                    zquoteIdStepsMap.get(oi.XC_ZQuoteId__c).addAll(stepsToUpdate);
                } else {
                    zquoteIdStepsMap.put(oi.XC_ZQuoteId__c, stepsToUpdate);
                }
            }
        }

        System.debug('@@@ zquoteIdStepsMap -> ' + zquoteIdStepsMap);
        return zquoteIdStepsMap;
    }


    /**
    * @author Nicola Mariniello - nmariniello@deloitte.it
    * @description Method to manage Contract Amendments For Sent Zquote
    * @param zquoteList 
    * @return Map<Id, List<XC_ContractAmendment__c>>
    */
    public static Map<Id, List<XC_ContractAmendment__c>> getContractAmendsByZquote(List<zqu__Quote__c> zquoteList) {

        Map<Id, List<XC_ContractAmendment__c>> zquoteIdContractAmendsMap = new Map<Id, List<XC_ContractAmendment__c>>();

        Set<Id> zquoteIds = XC_UTIL_Sobject.getSetIds(zquoteList);
        Map<Id, XC_ContractAmendment__c> contractAmendMap = new Map<Id, XC_ContractAmendment__c>([SELECT Id, XC_Status__c, XC_Asset__r.XC_ZQuoteId__c
                                                                                                    FROM XC_ContractAmendment__c
                                                                                                    WHERE XC_Status__c = 'In Progress' AND XC_Asset__c != null AND XC_Asset__r.XC_ZQuoteId__c IN: zquoteIds]);
        for(XC_ContractAmendment__c ca : contractAmendMap.values()) {
            if(!zquoteIdContractAmendsMap.containsKey(ca.XC_Asset__r.XC_ZQuoteId__c)) {
                zquoteIdContractAmendsMap.put(ca.XC_Asset__r.XC_ZQuoteId__c, new List<XC_ContractAmendment__c>{ca});
            } else {
                zquoteIdContractAmendsMap.get(ca.XC_Asset__r.XC_ZQuoteId__c).add(ca);
            }
        }

        return zquoteIdContractAmendsMap;
    }


    /**
    * @author Nicola Mariniello - nmariniello@deloitte.it
    * @description Method to manage Steps For Sent Zquote
    * @param stepList the step list
    * @param mapStepToUpdate the step map to update
    * @param zuoraSubscriptionId zuora subscription Id
    */
    public static void manageStepsForSentZquote(List<XC_Provisioning_Step__c> stepList,  Map<Id, XC_Provisioning_Step__c> mapStepToUpdate, String zuoraSubscriptionId) {

        for(XC_Provisioning_Step__c step : stepList) {

            XC_Provisioning_Step__c stepToUpdate = new XC_Provisioning_Step__c();
            stepToUpdate.Id = step.Id;

            if(step.XC_Flow_API_Name__c == Label.XC_CL_ProvisioningPaymentCheck_Flow){
                stepToUpdate.XC_ZuoraSubscriptionId__c = zuoraSubscriptionId;
                mapStepToUpdate.put(stepToUpdate.id, stepToUpdate);
                continue;
            }

            if(step.XC_Status__c == Label.XC_CL_Provisioning_Step_InProgress) {
                stepToUpdate.XC_Status__c = Label.XC_CL_Completed_OK;
            } else {
                stepToUpdate.XC_ToBeAutocompleted__c = true;
            }

            mapStepToUpdate.put(stepToUpdate.id, stepToUpdate);
        }
    }


    /**
    * @author Nicola Mariniello - nmariniello@deloitte.it
    * @description Method to manage Contract Amendment For Sent Zquote
    * @param contractAmendList the contract Amendment list
    * @param mapContractAmendToUpdate the contract Amendment map to update
    */
    public static void manageContractAmendForSentZquote(List<XC_ContractAmendment__c> contractAmendList,  Map<Id, XC_ContractAmendment__c> mapContractAmendToUpdate) {

        for(XC_ContractAmendment__c ca : contractAmendList) {

            XC_ContractAmendment__c caToUpdate = new XC_ContractAmendment__c();
            caToUpdate.Id = ca.Id;
            caToUpdate.XC_Status__c = 'Completed';

            mapContractAmendToUpdate.put(caToUpdate.id, caToUpdate);
        }
    }


    /**
     * @author dpalamides - dpalamides@deloitte.it
     * @description updates status of the billing project task
     * @param mapOld
     * @param mapNew
     */
    public static void manageSentStatusPPM(Map<Id, Sobject> mapOld, Map<Id, Sobject> mapNew) {
        List<String> listFieldToCheck = new List<String>{'zqu__Status__c'};
        List<zqu__Quote__c> listChanged = XC_UTIL_Sobject.getListChanged(listFieldToCheck,mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }

        Map<Id, project_cloud__Project_Task__c> zquoteIdTaskMap = getTasksByZquote(listChanged);
        List<project_cloud__Project_Task__c> taskToUpdate = new List<project_cloud__Project_Task__c>();
        List<zqu__Quote__c> toBePreviewed = new List<zqu__Quote__c>();

        for(zqu__Quote__c zquote : listChanged){
            if(!zquote.XC_IsPreviewQuote__c && zquote.zqu__Status__c == 'Sent to Z-Billing' && zquoteIdTaskMap!= null && zquoteIdTaskMap.get(zquote.XC_Project_Task__c) != null){
                project_cloud__Project_Task__c t = zquoteIdTaskMap.get(zquote.XC_Project_Task__c);
                t.XC_StepSubscription__c = true;
                if(t.XC_TaskReason__c != 'One shot' && t.XC_TaskReason__c != 'Milestone' && t.XC_TaskReason__c != 'Installment plan'  && t.XC_TaskReason__c != 'Billing Plan'){
                    t.XC_TaskStatus__c = 'Closed';
                    t.project_cloud__Completed_Date__c = Date.today();
                    //t.project_cloud__Health__c = 'Green';
                    t.XC_Message__c = Label.XC_CL_BillingTaskDone;
                }
                taskToUpdate.add(t);
            } else if(!zquote.XC_IsPreviewQuote__c && !String.isBlank(zquote.XC_Message__c) && zquote.XC_IsSuccess__c == false && zquoteIdTaskMap!= null  && zquoteIdTaskMap.get(zquote.XC_Project_Task__c) != null){
                project_cloud__Project_Task__c t = zquoteIdTaskMap.get(zquote.XC_Project_Task__c);
                t.XC_StepSubscription__c = false;
                t.XC_TaskStatus__c = 'Suspended';
                //t.project_cloud__Health__c = 'Yellow';
                t.XC_Message__c = zquote.XC_Message__c;
                taskToUpdate.add(t);
            } else if(zquote.XC_IsPreviewQuote__c && zquote.zqu__Status__c == 'Sent to Z-Billing' && zquote.BillingModel__c != 'Capex'){
                toBePreviewed.add(zquote);
            }
        }
        XC_UTIL_Sobject.updateListRecords(taskToUpdate);

        if(!toBePreviewed.isEmpty()){
            XC_TR_ZQuote_U_CallBillingPreviewWF.callZuoraBillingPreview(toBePreviewed);
        }
    }


    private static Map<Id, project_cloud__Project_Task__c> getTasksByZquote(List<zqu__Quote__c> listChanged){
        if (!Schema.sObjectType.project_cloud__Project_Task__c.isAccessible()) {
            return new Map<Id, project_cloud__Project_Task__c>();
        }
        List<String> idTasks = XC_UTIL_Sobject.getListFieldValues(listChanged,'XC_Project_Task__c');
        Map<Id, project_cloud__Project_Task__c> queryMap = new Map<Id, project_cloud__Project_Task__c>(
            [select id, XC_StepSubscription__c, XC_StepInvoice__c, XC_TaskReason__c from project_cloud__Project_Task__c where id in :idTasks]
        );

        return queryMap;
    }

}