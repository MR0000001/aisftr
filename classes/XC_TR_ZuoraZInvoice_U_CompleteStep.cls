/**
* @author Valeria Martino - valeria.martino@nttdata.com
* @date Creation 11/10/2019
* @date Modification 23/07/2021 by Nicola Mariniello - nmariniello@deloitte.it
* @description XC_TR_ZuoraZInvoice_U_CompleteStep 
*/


public without sharing class XC_TR_ZuoraZInvoice_U_CompleteStep {


    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ZuoraZInvoice_U_CompleteStep');


    /**
     * @description updateStatus - When change Status of Zuora__ZInvoice__c from >0 to =0 
     * @author Valeria Martino - valeria.martino@nttdata.com  
     * @param listNew - List<Zuora__ZInvoice__c
     * @param mapOld - Map<Id,Zuora__ZInvoice__c>
     * @param mapNew - Map<Id,Zuora__ZInvoice__c> 
     */
    public static void afterUpdateStatus(List<Zuora__ZInvoice__c> listNew, Map<Id, Zuora__ZInvoice__c> mapOld, Map<Id, Zuora__ZInvoice__c> mapNew) {

        List<String> fieldList = new List<String>{'Zuora__Balance2__c'};
        List<Zuora__ZInvoice__c> invoiceChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(!Schema.SObjectType.Zuora__ZInvoice__c.isAccessible()) { 
            return;
        }

        Map<String,Boolean> checkCACoveredInvoicesMap = checkCreditAssignmentInvoiceCoverage(invoiceChanged, mapOld);
        Set<String> listZuoraZInvoiceToUpdate = new Set<String>();
        for(Zuora__ZInvoice__c zInvoice : invoiceChanged) {
            if( (mapOld.get(zInvoice.Id).Zuora__Balance2__c > 0 || mapOld.get(zInvoice.Id).Zuora__Balance2__c == null)  && 
                ((mapNew.get(zInvoice.Id).Zuora__Balance2__c == 0 && mapNew.get(zInvoice.Id).Zuora__PaymentAmount__c > 0 ) || 
                (checkCACoveredInvoicesMap.containsKey(zInvoice.Id) && checkCACoveredInvoicesMap.get(zInvoice.Id)))) {
                    listZuoraZInvoiceToUpdate.add(zInvoice.Id);
            }
        }

        if(!listZuoraZInvoiceToUpdate.isEmpty()) {
            updateProvisioningStep(listZuoraZInvoiceToUpdate);
        }             
    }


    /**
     * @description updateProvisioningStep
     * @author Valeria Martino - valeria.martino@nttdata.com
     * @param listZuoraZInvoiceToUpdate - List<String>
     **/
    public static void updateProvisioningStep(Set<String> listZuoraZInvoiceToUpdate) {

        Map<Id, Zuora__InvoiceItem__c> iiMap = new Map<Id, Zuora__InvoiceItem__c>([SELECT Id, XC_SubscriptionNumber__c, Zuora__Subscription__r.Zuora__SubscriptionNumber__c
                                                                                    FROM Zuora__InvoiceItem__c
                                                                                    WHERE Zuora__Invoice__c IN :listZuoraZInvoiceToUpdate]);
        if(iiMap.isEmpty()) {
            return;
        }

        Set<String> subscriptionNameSet = new Set<String>();
        for(Zuora__InvoiceItem__c invoiceItem : iiMap.values()) {
            if(String.isNotBlank(invoiceItem.Zuora__Subscription__c) && String.isNotBlank(invoiceItem.Zuora__Subscription__r.Zuora__SubscriptionNumber__c)){
                subscriptionNameSet.add(invoiceItem.Zuora__Subscription__r.Zuora__SubscriptionNumber__c);
            } else if(String.isNotBlank(invoiceItem.XC_SubscriptionNumber__c)) {
                subscriptionNameSet.add(invoiceItem.XC_SubscriptionNumber__c);
            }
        }

        if(!subscriptionNameSet.isEmpty()){
            updateRelatedRecordsForPaymentDone(subscriptionNameSet);
        }
    }


    /**
     * @description updateRelatedRecords
     * @author Valeria Martino - valeria.martino@nttdata.com
     * @param subscriptionNameSet - Set<String>
     **/
    public static void updateRelatedRecordsForPaymentDone(Set<String> subscriptionNameSet) {
        
        Map<Id, Asset> assetMap = new  Map<Id, Asset>([SELECT XC_Configuration_Item__c, XC_Configuration_Item__r.NE__Bundle_Configuration__c, XC_PaymentDate__c
                                                        FROM Asset
                                                        WHERE XC_SubscriptionName__c IN: subscriptionNameSet
                                                            AND XC_Configuration_Item__c <> NULL]);
        if(assetMap.isEmpty()) {
            return;
        }

        Map<Id, Asset> confItemAssetMap = new Map<Id, Asset>();
        for(Asset asset : assetMap.values()) {
            confItemAssetMap.put(asset.XC_Configuration_Item__c, asset);
        }
        
        Set<String> confItemSet = new Set<String>();
        Map<Id, NE__OrderItem__c> mapConfigItem = new Map<Id, NE__OrderItem__c>();
        List<Asset> assetList = new List<Asset>();
    
        for(Id confItem : confItemAssetMap.keySet()) {
            Asset a = confItemAssetMap.get(confItem);
            
            mapConfigItem.put(confItem, new NE__OrderItem__c(Id = confItem, XC_PaymentDate__c = a.XC_PaymentDate__c, XC_PaymentDone__c = true));
            confItemSet.add(confItemAssetMap.get(confItem).XC_Configuration_Item__c);
            
            if(String.isNotBlank(confItemAssetMap.get(confItem).XC_Configuration_Item__r.NE__Bundle_Configuration__c)) {
                mapConfigItem.put(confItemAssetMap.get(confItem).XC_Configuration_Item__r.NE__Bundle_Configuration__c, new NE__OrderItem__c(Id = confItemAssetMap.get(confItem).XC_Configuration_Item__r.NE__Bundle_Configuration__c, XC_PaymentDate__c = a.XC_PaymentDate__c, XC_PaymentDone__c = true));
            }
            
            if(a != null && a.XC_PaymentDate__c == null) {
                a.XC_PaymentDate__c = Date.Today();
                assetList.add(a);
            }
        }

        for(NE__OrderItem__c conf : mapConfigItem.values()) {
            conf.XC_PaymentDone__c = true; 
            conf.XC_PaymentDate__c = (conf.XC_PaymentDate__c == null) ? Date.Today() : conf.XC_PaymentDate__c;
        }
        
        Map<Id, XC_Provisioning_Step__c> provisioningStepMap = new Map<Id, XC_Provisioning_Step__c>([SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__Bundle_Configuration__c  
                                                                                                        FROM XC_Provisioning_Step__c 
                                                                                                        WHERE XC_Configuration_Item__c IN: confItemAssetMap.keySet()
                                                                                                            AND XC_Flow_API_Name__c  =: Label.XC_CL_ProvisioningPaymentCheck_Flow 
                                                                                                            AND XC_Status__c =: Label.XC_CL_Provisioning_Step_InProgress]); 
        if(!provisioningStepMap.isEmpty()) {
            for(XC_Provisioning_Step__c provStep : provisioningStepMap.values()) {
                provStep.XC_Status__c = Label.XC_CL_Completed_Ok; 
            }
            
            List<Case> caseList = new List<Case>([SELECT Id, Status 
                                                    FROM Case 
                                                    WHERE Status = :Label.XC_CL_Case_InProgress AND XC_ProvisioningStep__c IN :provisioningStepMap.keySet()]);
            for (Case c : caseList) {
                c.Status = Label.XC_CL_Case_Closed;
            }

            List<WorkOrder> listWo = new List<WorkOrder>();
            List<ServiceAppointment> listSA = new List<ServiceAppointment>([SELECT Id, ParentRecordId
                                                                            FROM ServiceAppointment 
                                                                            WHERE XC_Configuration_Item__c IN: confItemSet
                                                                                AND Status =:Label.XC_CL_ServiceAppointment_OnHold  
                                                                                AND XC_WorkTypeCategory__c = :Label.XC_CL_WorkType_DeliveryInstallation]);
            System.debug('listSA stamp: ' +  listSA);
            for(ServiceAppointment sa : listSA){
                sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
                WorkOrder wo = new WorkOrder();
                wo.Id = sa.ParentRecordId;
                wo.status = Label.XC_CL_WorkOrder_Assigned;
                listWo.add(wo);
            }
            
            XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            
            XC_UTIL_Sobject.updateListRecords(listSA);
            XC_UTIL_Sobject.updateListRecords(listWO);
            XC_UTIL_Sobject.updateListRecords(provisioningStepMap.values());
            XC_UTIL_Sobject.updateListRecords(caseList);
        }
        
        XC_UTIL_Sobject.updateListRecords(mapConfigItem.values());
        XC_UTIL_Sobject.updateListRecords(assetList);
    }


    /**
     * @description checks if in case of credit assignment the customer has covered his part of the invoice balance.
     * @author Francesco Imperioli - fimperioli@deloitte.it | 07-06-2020 
     * @param invoicesToCheck 
     * @return Map<String, Boolean> 
     **/
    public static Map<String,Boolean> checkCreditAssignmentInvoiceCoverage(List<Zuora__ZInvoice__c> listNew, Map<Id,Zuora__ZInvoice__c> mapOld) {

        Map<String,Boolean> result = new Map<String,Boolean>();
        Map<Id,Zuora__ZInvoice__c> invoicesMap = new Map<Id, Zuora__ZInvoice__c>(listNew);
        Set<String> subscriptionNumbers = new Set<String>();

        //getting invoiceItems
        Map<Id, Zuora__InvoiceItem__c> invoiceItems = new Map<Id, Zuora__InvoiceItem__c>([SELECT Id,Zuora__Invoice__c,Zuora__Subscription__c,XC_SubscriptionNumber__c 
                                                                                                FROM Zuora__InvoiceItem__c 
                                                                                                WHERE Zuora__Invoice__c IN :invoicesMap.keySet()]);
        for(Zuora__InvoiceItem__c ii : invoiceItems.values()){
            if(String.isNotBlank(ii.XC_SubscriptionNumber__c)){
                subscriptionNumbers.add(ii.XC_SubscriptionNumber__c);
            }
        }
        
        //getting the configuration items related
        Map<Id, Asset> relatedAssets = new Map<Id, Asset>([SELECT Id, XC_SubscriptionName__c,
                                                                XC_Configuration_Item__r.XC_CreditAssignmentAvailable__c,
                                                                XC_Configuration_Item__r.XC_CreditAssignmentAmount__c,
                                                                XC_Configuration_Item__r.XC_CreditAssignmentCustomerAmount__c,
                                                                XC_Configuration_Item__r.NE__Bundle_Configuration__r.XC_CreditAssignmentCustomerAmount__c,
                                                                XC_Configuration_Item__r.NE__Bundle_Configuration__r.XC_CreditAssignmentAvailable__c,
                                                                XC_Configuration_Item__r.NE__Bundle_Configuration__r.XC_CreditAssignmentAmount__c
                                                            FROM Asset 
                                                            WHERE XC_SubscriptionName__c IN :subscriptionNumbers 
                                                                AND XC_Configuration_Item__c != null 
                                                                AND XC_SubscriptionName__c != null ]);

        Map<String,Decimal> mapOfAmountsToBeCovered = new  Map<String,Decimal>();
        Map<String,Decimal> mapOfCreditAssignmentAmounts = new Map<String,Decimal>();

        //mapping the amount that the customer payed in order to check if the invoice has been covered.
        for(Asset ra : relatedAssets.values()){
            if(String.isBlank(ra.XC_Configuration_Item__r.NE__Bundle_Configuration__c) 
            && ra.XC_Configuration_Item__r.XC_CreditAssignmentAvailable__c 
            && ra.XC_Configuration_Item__r.XC_CreditAssignmentCustomerAmount__c!=null){

                mapOfAmountsToBeCovered.put(ra.XC_SubscriptionName__c,ra.XC_Configuration_Item__r.XC_CreditAssignmentCustomerAmount__c);
                mapOfCreditAssignmentAmounts.put(ra.XC_SubscriptionName__c,ra.XC_Configuration_Item__r.XC_CreditAssignmentAmount__c);

            }else if(String.isNotBlank(ra.XC_Configuration_Item__r.NE__Bundle_Configuration__c) 
            && ra.XC_Configuration_Item__r.NE__Bundle_Configuration__r.XC_CreditAssignmentAvailable__c 
            && ra.XC_Configuration_Item__r.NE__Bundle_Configuration__r.XC_CreditAssignmentCustomerAmount__c != null){

                mapOfAmountsToBeCovered.put(ra.XC_SubscriptionName__c,ra.XC_Configuration_Item__r.NE__Bundle_Configuration__r.XC_CreditAssignmentCustomerAmount__c);
                mapOfCreditAssignmentAmounts.put(ra.XC_SubscriptionName__c,ra.XC_Configuration_Item__r.NE__Bundle_Configuration__r.XC_CreditAssignmentAmount__c);

            }
        }

        System.Debug('AMOUNTS CUSTOMER MAP::: ' + mapOfAmountsToBeCovered);
        System.Debug('AMOUNTS COVERED BY ENEL::: ' + mapOfCreditAssignmentAmounts);

        if(!mapOfAmountsToBeCovered.isEmpty()){
            for(Zuora__InvoiceItem__c ii : invoiceItems.values()){
                Zuora__ZInvoice__c currentItemInvoice = invoicesMap.get(ii.Zuora__Invoice__c);
                Zuora__ZInvoice__c oldInvoiceRec = (mapOld != null) ? mapOld.get(ii.Zuora__Invoice__c) : null;
                if(mapOfAmountsToBeCovered.containsKey(ii.XC_SubscriptionNumber__c) && !result.containsKey(currentItemInvoice.Id)){
                    Decimal amountThatCustomerHasToPay = mapOfAmountsToBeCovered.get(ii.XC_SubscriptionNumber__c);
                    //balance has to be changed, payment amount has to be changed, amount in charge of the customer must be  >0
                    if((oldInvoiceRec != null && checkWithOldValues(oldInvoiceRec, currentItemInvoice, amountThatCustomerHasToPay))
                        || (oldInvoiceRec == null && checkOnlyOnCurrent(currentItemInvoice, amountThatCustomerHasToPay))) {
                            result.put(currentItemInvoice.Id, true);
                    }else{
                        result.put(currentItemInvoice.Id, false);
                    }
                }
            }
        }

        System.Debug('FINAL RESULT::: ' + result);
        return result;
    }


    /**
     * @description checkWithOldValues
     * @author Francesco Imperioli - fimperioli@deloitte.it | 07-06-2020 
     * @param oldInvoiceRec 
     * @param currentItemInvoice 
     * @param amountThatCustomerHasToPay 
     * @return Boolean
     **/
    public static Boolean checkWithOldValues(Zuora__ZInvoice__c oldInvoiceRec, Zuora__ZInvoice__c currentItemInvoice, Decimal amountThatCustomerHasToPay) {
        return oldInvoiceRec.Zuora__Balance2__c != currentItemInvoice.Zuora__Balance2__c
                && oldInvoiceRec.Zuora__PaymentAmount__c != currentItemInvoice.Zuora__PaymentAmount__c 
                && amountThatCustomerHasToPay > 0
                && currentItemInvoice.Zuora__PaymentAmount__c >= (amountThatCustomerHasToPay - 1);
    }


    /**
     * @description checkOnlyOnCurrent
     * @author Francesco Imperioli - fimperioli@deloitte.it | 07-06-2020 
     * @param oldInvoiceRec 
     * @param currentItemInvoice 
     * @param amountThatCustomerHasToPay 
     * @return Boolean
     **/
    public static Boolean checkOnlyOnCurrent(Zuora__ZInvoice__c currentItemInvoice, Decimal amountThatCustomerHasToPay) {
        return amountThatCustomerHasToPay > 0 && currentItemInvoice.Zuora__PaymentAmount__c >= (amountThatCustomerHasToPay - 1);
    }

}