/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 23-07-2021
 * @last modified by  : Nicola Mariniello - nmariniello@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   24-08-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/


public without sharing class XC_TR_ZuoraInvItem_U_FillInvoiceNum {


    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ZuoraInvItem_U_FillInvoiceNum');


    /**
    * @description populate zuora invoice numbers on orderitems as the invoice is created
    * @author Francesco Imperioli - fimperioli@deloitte.it | 08-24-2020 
    * @param listNew 
    **/
    public static void fillInvoiceNumberDateOnOI(List<Zuora__InvoiceItem__c> listNew) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_ZuoraInvItem_U_FillInvoiceNum.fillInvoiceNumberDateOnOI');

        Map<String, String> itemInvoiceMap = new Map<String, String>();
        Map<String, String> subscriptionNumbersSetMap = new Map<String, String>();

        for(Zuora__InvoiceItem__c ii : listNew){
            if(String.isNotBlank(ii.XC_SubscriptionNumber__c) && String.isNotBlank(ii.Zuora__Invoice__c)){
                itemInvoiceMap.put(ii.Id, ii.Zuora__Invoice__c);
                subscriptionNumbersSetMap.put(ii.XC_SubscriptionNumber__c, ii.Zuora__Invoice__c);
            }
        }
        if(itemInvoiceMap.isEmpty() && subscriptionNumbersSetMap.isEmpty()) {
            return;
        }

        Map<Id, Zuora__ZInvoice__c> invoicesMap = new Map<Id, Zuora__ZInvoice__c>([SELECT Id, Name, Zuora__InvoiceDate__c 
                                                                                    FROM Zuora__ZInvoice__c 
                                                                                    WHERE Id IN: itemInvoiceMap.values() AND Zuora__Status__c = 'Posted']);
        if(invoicesMap.isEmpty()){
            return;
        }

        Map<Id, Asset> relatedAssets = new Map<Id, Asset>([SELECT Id, XC_SubscriptionName__c, XC_Configuration_Item__c, XC_PaymentMethod__c, XC_BillingModel__c, XC_Configuration_Item__r.NE__Bundle_Configuration__c
                                                            FROM Asset 
                                                            WHERE XC_SubscriptionName__c IN :subscriptionNumbersSetMap.keySet() 
                                                                AND XC_BillingModel__c = :Label.XC_CL_BillingModel_OneShot]);
        if(relatedAssets.isEmpty()){
            return;
        }

        updateRecordsForInvoice(relatedAssets.values(), invoicesMap, subscriptionNumbersSetMap);
    }


    /**
    * @description populate zuora invoice numbers on orderitems as the invoice is created
    * @author Francesco Imperioli - fimperioli@deloitte.it | 08-24-2020 
    * @param listNew 
    **/
    public static void updateRecordsForInvoice(List<Asset> assetList, Map<Id, Zuora__ZInvoice__c> invoicesMap, Map<String, String> subscriptionNumbersSetMap) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_ZuoraInvItem_U_FillInvoiceNum.updateRecordsForInvoice');

        Map<String,List<Asset>> subscriptionAssetMap = new Map<String,List<Asset>>();
        Set<String> confItemsForSteps = new Set<String>();
        Map<String, XC_Provisioning_Step__c> oiStepMap = new Map<String, XC_Provisioning_Step__c>();
        List<Asset> assetToUpdate = new List<Asset>();
        Set<NE__OrderItem__c> oisToUpdate = new Set<NE__OrderItem__c>();
        List<XC_Provisioning_Step__c> stepsToUpdate = new List<XC_Provisioning_Step__c>();

        for(Asset asset : assetList) {

            if(subscriptionAssetMap.containsKey(asset.XC_SubscriptionName__c)){
                subscriptionAssetMap.get(asset.XC_SubscriptionName__c).add(asset);
            }else if(!subscriptionAssetMap.containsKey(asset.XC_SubscriptionName__c)){
                subscriptionAssetMap.put(asset.XC_SubscriptionName__c, new List<Asset>{asset});
            }

            confItemsForSteps.add(asset.XC_Configuration_Item__c);
        }

        Map<Id, XC_Provisioning_Step__c> steps = new Map<Id, XC_Provisioning_Step__c>([SELECT Id,XC_Status__c,XC_Configuration_Item__c 
                                                                                        FROM XC_Provisioning_Step__c 
                                                                                        WHERE XC_Configuration_Item__c IN :confItemsForSteps
                                                                                            AND XC_Status__c =: Label.XC_CL_Provisioning_Step_InProgress
                                                                                            AND XC_StepLabel__c = 'Wait Invoice']);
        for(XC_Provisioning_Step__c step : steps.values()) {
            oiStepMap.put(step.XC_Configuration_Item__c, step);
        }

        for(String subscription : subscriptionAssetMap.keySet()) {

            List<Asset> relatedAssetsForSubscription = subscriptionAssetMap.get(subscription);

            for(Asset relatedAsset : relatedAssetsForSubscription){

                String confItemId = relatedAsset.XC_Configuration_Item__c;

                if(invoicesMap.containsKey(subscriptionNumbersSetMap.get(subscription))) {
    
                    Zuora__ZInvoice__c invoice = invoicesMap.get(subscriptionNumbersSetMap.get(subscription));
    
                    //check if there steps that has to be setted up to completed
                    if(oiStepMap.containsKey(confItemId)){
                        XC_Provisioning_Step__c stepToComplete = oiStepMap.get(confItemId);
                        stepToComplete.XC_Status__c = 'Completed OK';
                        stepsToUpdate.add(stepToComplete);
                    }
    
                    //update on ConfItem
                    if(String.isNotBlank(relatedAsset.XC_Configuration_Item__r.NE__Bundle_Configuration__c)) {
                        oisToUpdate.add(new NE__OrderItem__c (Id = relatedAsset.XC_Configuration_Item__r.NE__Bundle_Configuration__c,
                                                                XC_InvoiceDate__c = invoice.Zuora__InvoiceDate__c,
                                                                XC_InvoiceNumber__c = invoice.Name));
                    }
                    oisToUpdate.add(new NE__OrderItem__c (Id = confItemId,
                                                            XC_InvoiceDate__c = invoice.Zuora__InvoiceDate__c,
                                                            XC_InvoiceNumber__c = invoice.Name));

                    // update on Asset
                    relatedAsset.XC_InvoiceDate__c = invoice.Zuora__InvoiceDate__c;
                    relatedAsset.XC_InvoiceNumber__c = invoice.Name;
                    assetToUpdate.add(relatedAsset);
                }
            }
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'OIS TO UPDATE::: ' + oisToUpdate);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'ASSETS TO UPDATE::: ' + assetToUpdate);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'STEPS TO UPDATE::: ' + stepsToUpdate);
        XC_UTIL_Sobject.updateListRecords(new List<NE__OrderItem__c>(oisToUpdate));
        XC_UTIL_Sobject.updateListRecords(assetToUpdate);
        XC_UTIL_Sobject.updateListRecords(stepsToUpdate);
    }


    /**
    * @description populate zuora invoice numbers on orderitems as the invoice is updated
    * @author Nicola Mariniello - nmariniello@deloitte.it | 12/01/2021
    * @param mapOld - List<Zuora__InvoiceItem__c>
    * @param mapNew - List<Zuora__InvoiceItem__c>
    **/
    public static void fillInvoiceNumberDateOnOIOnUpdate(Map<Id, Zuora__InvoiceItem__c> mapOld, Map<Id, Zuora__InvoiceItem__c> mapNew){

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_ZuoraInvItem_U_FillInvoiceNum.fillInvoiceNumberDateOnOIOnUpdate');

        List<String> fieldToCheck = new List<String>{'Zuora__Subscription__c', 'Zuora__Invoice__c'};
        List<Zuora__InvoiceItem__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldTocheck, mapOld, mapNew);

        if(!listChanged.isEmpty()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'listChanged ' + listChanged);
            fillInvoiceNumberDateOnOI(listChanged);
        }
    }

}