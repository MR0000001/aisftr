/**
 * @author Federico Amici - federico.amici@nttdata.com
 * @date 23/04/2019
 * @description XC_IN019_EMobilityOrder Handles the eMobility callback
 */
public with sharing class XC_IN019_EMobilityOrder {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN019_EMobilityOrder');

    /** 
     * @author Federico Amici - federico.amici@nttdata.comP
     * @date 18/03/2019
     * @description Wrapper used by flow
     */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId; 

        @Invocablevariable
        public Boolean callbackParent;

        @Invocablevariable
        public Boolean isChangeBP;
    }    

    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description createZquote manages the creation of the zquote
     * @param inputWrapperList the input wrapper list
     */
    @InvocableMethod
    public static void callbackOrder(List<InputWrapper> inputWrapperList) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN019_EMobilityOrder');

        System.debug('IN callbackOrder - inputWrapperList: ' + inputWrapperList);

        if(inputWrapperList.isEmpty()) {
            return;
        }
        List<String> listStepIds = new List<String>{inputWrapperList[0].stepId};
        Map<Id, XC_Provisioning_Step__c> mapSteps = XC_IN011_ChangeProvBillingProcess_D.getMapSteps(listStepIds);
        System.debug('IN callbackOrder - mapSteps: ' + mapSteps);
        String orderId = ''; 
        String confItemId = ''; 
        XC_Provisioning_Step__c step;
        XC_REST_MobilityOrderCallback_U.RequestWrapper requestWrapper;
        Boolean callbackParent = false;
        Boolean isChangeBP = false;

        for(InputWrapper inputWr : inputWrapperList){
            step = mapSteps.get(inputWr.stepId);
            orderId = step.XC_Configuration_Item__r.NE__OrderId__c; 
            confItemId = step.XC_Configuration_Item__c;
            callbackParent = inputWr.callbackParent;
            isChangeBP = inputWr.isChangeBP;
        }

        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@mapSteps-->' +mapSteps);

        Map<Id, NE__OrderItem__c> itemMap =
            new Map<Id, NE__OrderItem__c>([SELECT ID, NE__OrderId__c, NE__OrderId__r.XC_Company_Code__c, XC_ZquoteId__c, NE__OrderId__r.XC_LegalEntity__c,
                                            NE__OrderId__r.XC_Coupon_Code__c, XC_BillingProfileLineItem__c, XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Zuora_Id__c,
                                            NE__OrderId__r.XC_Cost_Center__c, NE__CatalogItem__r.Name, NE__ProdName__c, XC_LastSubscriptionId__c, NE__CatalogItem__r.XC_Skip_Payment_Method__c,
                                            NE__OrderId__r.NE__AccountId__c, NE__CatalogItem__r.NE__Engine_Code__c, NE__Action__c,
                                           (SELECT Id, XC_Original_Configuration_Item__r.XC_ZQuoteId__c, XC_SubscriptionName__c, XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Zuora_Id__c, XC_Subscription__c, XC_Subscription__r.Zuora__SubscriptionStartDate__c FROM Assets__r),
                                           (SELECT Id FROM Provisioning_Steps__r WHERE XC_Flow_API_Name__c = :Label.XC_CL_ProvisioningFlow_WaitForTemporaryOffer AND XC_Status__c =: Label.XC_CL_Provisioning_Step_InProgress)
                                            FROM NE__OrderItem__c 
                                            // WHERE Id = :confItemId
                                            WHERE NE__OrderId__c = :orderId]);
        NE__OrderItem__c item = itemMap.get(confItemId);
        

        if(item.NE__ProdName__c == Label.XC_CL_CatItem_DomesticOffer || item.NE__CatalogItem__r.XC_Skip_Payment_Method__c) {
            requestWrapper = populateRequestWrapperForDomesticOffer(item);
        } else if (callbackParent) {
            requestWrapper = populateRequestWrapperForCorporateOffer(item);
        } else if(!isChangeBP) {
            requestWrapper = populateRequestWrapperForPayPerUse(item, itemMap, step.XC_Template_Name__c);
        } else {
            requestWrapper = populateRequestWrapperForChangeBillingProfile(item);
        }
        
        // Call Mobility Order Callback
        System.debug('IN callbackOrder - requestWrapper: ' + requestWrapper);
        if(requestWrapper != null && inputWrapperList[0].stepId != null) {
            requestWrapper.StepID = inputWrapperList[0].stepId;
            XC_REST_MobilityOrderCallback_Outbound.callToMobility(requestWrapper, '');         
        }

        // Complete Step
        /*step.XC_Status__c = Label.XC_CL_Completed_OK;
        XC_UTIL_SObject.updateRecord(step);*/

        // Relaunch step Wait for Temporary Offer
        for(NE__OrderItem__c oi : itemMap.values()) {
            for(XC_Provisioning_Step__c ps : oi.Provisioning_Steps__r) {
                relaunchStep(ps.Id);
            }
        }

    }


    /**
    * @author Nicola Mariniello - nmariniello@deloitte.it
    * @description Method to manage Steps For Sent Zquote
    * @param stepList the step list
    * @param mapStepToUpdate the step map to update
    * @param zuoraSubscriptionId zuora subscription Id
    */
    @future(callout=true)
    public static void relaunchStep(Id stepId) {
        List<XC_Provisioning_Step__c> listSteps = XC_UTIL_Sobject.selectAllFields(stepId);
        XC_UTIL_ProvisioningStep.executeSteps(listSteps);
    }


    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description populateRequestWrapper manages the creation of the zquote
     * @param item the orderitem
     * @return the requestWrapper
     */
    private static XC_REST_MobilityOrderCallback_U.RequestWrapper populateRequestWrapperForCorporateOffer(NE__OrderItem__c item) {
        
        Map<Id, XC_Voucher__c> mapVoucher = new Map<Id, XC_Voucher__c>([SELECT Id, XC_CostCenter__c, XC_CompanyCode__c
                                                                        FROM XC_Voucher__c 
                                                                        WHERE XC_VoucherCode__c = :item.NE__OrderId__r.XC_Coupon_Code__c]);
        if(mapVoucher.isEmpty()) {
            System.debug('@@NM Voucher not found');
            return null;
        }
        XC_Voucher__c voucher = mapVoucher.values()[0];

        List<NE__Product__c> prodList = new List<NE__Product__c>([SELECT Id, (SELECT Id, NE__ProdId__c, XC_ZQuoteId__c, XC_SubscriptionName__c, XC_Subscription__c, XC_Subscription__r.Zuora__SubscriptionNumber__c, XC_Subscription__r.Zuora__External_Id__c, XC_Subscription__r.Zuora__SubscriptionStartDate__c, XC_Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c FROM NE__Asset_Prod__r WHERE XC_CompanyCode__c =: voucher.XC_CompanyCode__c AND XC_CostCenter__c =: voucher.XC_CostCenter__c AND XC_ZQuoteId__c != '' AND NE__Order_Config__r.XC_EmobilityWebAppType__c != '' AND XC_LegalEntity__c =: item.NE__OrderId__r.XC_LegalEntity__c AND NE__ProdId__r.XC_Product_Subtype__c =: Label.XC_CL_ProductSubtype_B2BTariff),
                                                                    (SELECT ID, NE__FamilyId__r.XC_LIC_Family_Name__c FROM NE__ProductFamily__r WHERE NE__FamilyId__r.XC_LIC_Family_Name__c = :Label.XC_CL_Family_JNManager)
                                                                FROM NE__Product__c
                                                                WHERE Id IN (SELECT NE__ProdId__c FROM Asset WHERE XC_CompanyCode__c =: voucher.XC_CompanyCode__c AND XC_CostCenter__c =: voucher.XC_CostCenter__c AND XC_ZQuoteId__c != '' AND NE__Order_Config__r.XC_EmobilityWebAppType__c != '' AND XC_LegalEntity__c =: item.NE__OrderId__r.XC_LegalEntity__c AND NE__ProdId__r.XC_Product_Subtype__c =: Label.XC_CL_ProductSubtype_B2BTariff)]);
        Asset a;
        for(NE__Product__c pr : prodList) {
            if(pr.NE__ProductFamily__r.isEmpty()) {
                a = pr.NE__Asset_Prod__r[0];
            }
        }
        if(a == null) {
            System.debug('@@NM Asset not found');
            return null;
        }

        zqu__Quote__c zQuote;
        Zuora__Subscription__c subscription;
        if(String.isBlank(a.XC_Subscription__c) && String.isNotBlank(a.XC_ZQuoteId__c) && a.XC_ZQuoteId__c instanceOf Id) {
            Map<Id, zqu__Quote__c> zQuoteMap = new Map<Id, zqu__Quote__c>([SELECT Id, zqu__StartDate__c, zqu__ZuoraAccountID__c, zqu__ZuoraSubscriptionID__c, XC_SubscriptionName__c, XC_LastSubscriptionId__c
                                                                            FROM zqu__Quote__c
                                                                            WHERE Id = :a.XC_ZQuoteId__c
                                                                            LIMIT 1]);
            zQuote = zQuoteMap.get(a.XC_ZQuoteId__c);

        } else if(String.isBlank(a.XC_Subscription__c) && String.isNotBlank(a.XC_SubscriptionName__c)) {
            Map<Id, Zuora__Subscription__c> subMap = new Map<Id, Zuora__Subscription__c>([SELECT Id, Zuora__SubscriptionNumber__c, Zuora__External_Id__c, Zuora__SubscriptionStartDate__c, Zuora__CustomerAccount__r.Zuora__External_Id__c
                                                                                            FROM Zuora__Subscription__c
                                                                                            WHERE Zuora__SubscriptionNumber__c = :a.XC_SubscriptionName__c
                                                                                            ORDER BY Zuora__Version__c desc
                                                                                            LIMIT 1]);
            subscription = (!subMap.isEmpty()) ? subMap.values()[0] : null;
        }
        
        XC_REST_MobilityOrderCallback_U.RequestWrapper requestWrapper = new XC_REST_MobilityOrderCallback_U.RequestWrapper();
        requestWrapper.companyCode = item.NE__OrderId__r.XC_Company_Code__c;
        requestWrapper.costCenter = item.NE__OrderId__r.XC_Cost_Center__c;
        requestWrapper.orderId = item.NE__OrderId__c;
        requestWrapper.startDateSubscription = (String.isNotBlank(a.XC_Subscription__c)) ? String.valueOf(a.XC_Subscription__r.Zuora__SubscriptionStartDate__c) : (zQuote != null) ? String.valueOf(zQuote.zqu__StartDate__c) : (subscription != null) ? String.valueOf(subscription.Zuora__SubscriptionStartDate__c) : null;
        requestWrapper.zAccountId = (String.isNotBlank(a.XC_Subscription__c)) ? a.XC_Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c : (zQuote != null) ? zQuote.zqu__ZuoraAccountID__c : (subscription != null) ? subscription.Zuora__CustomerAccount__r.Zuora__External_Id__c : null;
        requestWrapper.zSubscriptionNumber = (String.isNotBlank(a.XC_Subscription__c)) ? a.XC_Subscription__r.Zuora__SubscriptionNumber__c : (zQuote != null) ? zQuote.XC_SubscriptionName__c : (subscription != null) ? subscription.Zuora__SubscriptionNumber__c : null;
        requestWrapper.zSubscriptionId = (String.isNotBlank(a.XC_Subscription__c)) ? a.XC_Subscription__r.Zuora__External_Id__c : (zQuote != null && String.isNotBlank(zQuote.XC_LastSubscriptionId__c)) ? zQuote.XC_LastSubscriptionId__c : (zQuote != null && String.isNotBlank(zQuote.zqu__ZuoraSubscriptionID__c)) ? zQuote.zqu__ZuoraSubscriptionID__c : (subscription != null) ? subscription.Zuora__External_Id__c : null;
        requestWrapper.zChargeNumber = '';
        requestWrapper.assetID = a.Id;
        return requestWrapper;
    }


    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description populateRequestWrapper manages the creation of the zquote
     * @param item the orderitem
     * @return the requestWrapper
     */
    private static XC_REST_MobilityOrderCallback_U.RequestWrapper populateRequestWrapperForDomesticOffer(NE__OrderItem__c item) {
        Map<Id, Asset> assetMap = new Map<Id, Asset>([SELECT Id, XC_ZQuoteId__c
                                                        FROM Asset
                                                        WHERE XC_CostCenter__c = :item.NE__OrderId__r.XC_Cost_Center__c 
                                                            AND XC_CompanyCode__c = :item.NE__OrderId__r.XC_Company_Code__c
                                                        LIMIT 1]);
        Asset a = assetMap.values()[0];
       
        XC_REST_MobilityOrderCallback_U.RequestWrapper requestWrapper = new XC_REST_MobilityOrderCallback_U.RequestWrapper();
        requestWrapper.AssetID = (!item.Assets__r.isEmpty()) ? item.Assets__r[0].Id : null;
        requestWrapper.CompanyCode = item.NE__OrderId__r.XC_Company_Code__c;
        requestWrapper.costCenter = item.NE__OrderId__r.XC_Cost_Center__c;
        requestWrapper.orderId = item.NE__OrderId__c;
        requestWrapper.startDateSubscription = String.valueOf('1970-01-01');
        requestWrapper.zAccountId = 'Accountid';
        requestWrapper.zSubscriptionId = 'Subscription';
        requestWrapper.zChargeNumber = 'Charge';
        return requestWrapper;
    }


    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description populateRequestWrapperForPayPerUser manages the creation of the zquote
     * @param item the orderitem
     * @return the requestWrapper
     */
    private static XC_REST_MobilityOrderCallback_U.RequestWrapper populateRequestWrapperForPayPerUse(NE__OrderItem__c item, Map<Id, NE__OrderItem__c> itemMap, String stepTemplateName) {

        Asset a = (!item.Assets__r.isEmpty()) ? item.Assets__r[0] : null;

        Map<Id, zqu__Quote__c> zQuoteMap = new Map<Id, zqu__Quote__c>([SELECT Id, zqu__StartDate__c, zqu__ZuoraAccountID__c, zqu__ZuoraSubscriptionID__c, XC_LastSubscriptionId__c, XC_SubscriptionName__c, zqu__ExistSubscriptionID__c, CreatedDate
                                                                        FROM zqu__Quote__c
                                                                        WHERE Id = :item.XC_ZQuoteId__c
                                                                        LIMIT 1]);
        zqu__Quote__c zQuote = zQuoteMap.get(item.XC_ZQuoteId__c);

        String oldZAccountId = '';
        for(NE__OrderItem__c oi : itemMap.values()) {
            if(oi.NE__Action__c == 'Remove' && String.isBlank(oldZAccountId)) {
                oldZAccountId = (!oi.Assets__r.isEmpty()) ? oi.Assets__r[0].XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Zuora_Id__c : oi.XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Zuora_Id__c;
            }
        }
       
        XC_REST_MobilityOrderCallback_U.RequestWrapper requestWrapper = new XC_REST_MobilityOrderCallback_U.RequestWrapper();
        requestWrapper.AssetID = (a != null) ? a.Id : null;
        requestWrapper.CompanyCode = item.NE__OrderId__r.XC_Company_Code__c;
        requestWrapper.CostCenter = item.NE__OrderId__r.XC_Cost_Center__c;
        requestWrapper.OrderId = item.NE__OrderId__c;
        requestWrapper.StartDateSubscription = String.valueOf(zQuote.zqu__StartDate__c);
        requestWrapper.ZAccountId = item.XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Zuora_Id__c;
        requestWrapper.ZSubscriptionNumber = (a != null && String.isNotBlank(a.XC_SubscriptionName__c)) ? a.XC_SubscriptionName__c : (zQuote != null && String.isNotBlank(zQuote.XC_SubscriptionName__c)) ? zQuote.XC_SubscriptionName__c : null;
        requestWrapper.ZSubscriptionId = (String.isNotBlank(zQuote.XC_LastSubscriptionId__c)) ? zQuote.XC_LastSubscriptionId__c : zQuote.zqu__ZuoraSubscriptionID__c;
        requestWrapper.ZChargeNumber = '';
        requestWrapper.OldZAccountId = oldZAccountId;
        requestWrapper.OldZSubscriptionId = zQuote.zqu__ExistSubscriptionID__c;
        requestWrapper.EffectiveDate = Date.valueOf(zQuote.CreatedDate);
        requestWrapper.AccountID = item.NE__OrderId__r.NE__AccountId__c;
        requestWrapper.ProdID = item.NE__CatalogItem__r.NE__Engine_Code__c;
        requestWrapper.isChangeOpenCharge = (stepTemplateName == Label.XC_CL_ProvisioningTemplate_OpenChargeFinalOffer) ? true : false;

        return requestWrapper;
    }


    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description populateRequestWrapperForPayPerUser manages the creation of the zquote
     * @param item the orderitem
     * @return the requestWrapper 
     */
    private static XC_REST_MobilityOrderCallback_U.RequestWrapper populateRequestWrapperForChangeBillingProfile(NE__OrderItem__c item) {
        
        Asset a = (!item.Assets__r.isEmpty()) ? item.Assets__r[0] : null;
        zqu__Quote__c zQuote;
        Zuora__Subscription__c subscription;

        if(a != null && String.isBlank(a.XC_Subscription__c) && String.isNotBlank(a.XC_Original_Configuration_Item__r.XC_ZQuoteId__c)) {
            a = item.Assets__r[0];
            Map<Id, zqu__Quote__c> zQuoteMap = new Map<Id, zqu__Quote__c>([SELECT Id, zqu__StartDate__c, zqu__ZuoraAccountID__c, zqu__ZuoraSubscriptionID__c, XC_SubscriptionName__c
                                                                            FROM zqu__Quote__c
                                                                            WHERE Id = :a.XC_Original_Configuration_Item__r.XC_ZQuoteId__c]);
            zQuote = zQuoteMap.values()[0];

        } else if (a != null && String.isBlank(a.XC_Subscription__c) && String.isNotBlank(a.XC_SubscriptionName__c)) {
            Map<Id, Zuora__Subscription__c> subMap = new Map<Id, Zuora__Subscription__c>([SELECT Id, Zuora__SubscriptionNumber__c, Zuora__External_Id__c, Zuora__SubscriptionStartDate__c, Zuora__CustomerAccount__r.Zuora__External_Id__c
                                                                                            FROM Zuora__Subscription__c
                                                                                            WHERE Zuora__SubscriptionNumber__c = :a.XC_SubscriptionName__c
                                                                                            ORDER BY Zuora__Version__c desc
                                                                                            LIMIT 1]);
            subscription = (!subMap.isEmpty()) ? subMap.values()[0] : null;
        }
       
        XC_REST_MobilityOrderCallback_U.RequestWrapper requestWrapper = new XC_REST_MobilityOrderCallback_U.RequestWrapper();
        requestWrapper.AssetID = (a != null) ? a.Id : null;
        requestWrapper.CompanyCode = item.NE__OrderId__r.XC_Company_Code__c;
        requestWrapper.CostCenter = item.NE__OrderId__r.XC_Cost_Center__c;
        requestWrapper.OrderId = item.NE__OrderId__c;
        requestWrapper.StartDateSubscription = (String.isNotBlank(a.XC_Subscription__c)) ? String.valueOf(a.XC_Subscription__r.Zuora__SubscriptionStartDate__c) : (zQuote != null) ? String.valueOf(zQuote.zqu__StartDate__c) : (subscription != null) ? String.valueOf(subscription.Zuora__SubscriptionStartDate__c) : null;
        requestWrapper.ZAccountId = item.XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Zuora_Id__c;
        requestWrapper.ZSubscriptionNumber = (a != null && String.isNotBlank(a.XC_SubscriptionName__c)) ? a.XC_SubscriptionName__c : (zQuote != null && String.isNotBlank(zQuote.XC_SubscriptionName__c)) ? zQuote.XC_SubscriptionName__c : null;
        requestWrapper.ZSubscriptionId = item.XC_LastSubscriptionId__c;
        requestWrapper.ZChargeNumber = '';
        requestWrapper.AccountID = item.NE__OrderId__r.NE__AccountId__c;
        requestWrapper.ProdID = item.NE__CatalogItem__r.NE__Engine_Code__c;
        
        return requestWrapper;
    }

}