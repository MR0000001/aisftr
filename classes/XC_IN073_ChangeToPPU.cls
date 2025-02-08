/**
 * @author Nicola Mariniello nmarriniello@deloitte.it
 * @date Creation 25/03/2021
 * @date Modification 
 * @description - 
 */


public without sharing class XC_IN073_ChangeToPPU {


    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN073_ChangeToPPU');


    /** 
     * @description InputWrapper the input wrapper.
     */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;       
    }


    /** 
     * @description Invocable method 
     * @param inputWrapperList
     */
    @InvocableMethod 
    public static void changeToPPU(List<InputWrapper> inputWrapperList) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering In XC_IN073_ChangeToPPU');

        Set<Id> stepIds = new Set<Id>(); 
        for(InputWrapper inputWr : inputWrapperList) {                
            stepIds.add(inputWr.stepId);
        } 
   
        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>([SELECT XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c
                                                                                            FROM XC_Provisioning_Step__c 
                                                                                            WHERE Id IN: stepIds]);

        String stepId = '';
        String configurationItemId = '';
        String orderId = '';

        for(XC_Provisioning_Step__c step : mapSteps.values()) {
            stepId = step.Id;
            configurationItemId = step.XC_Configuration_Item__c;
            orderId = step.XC_Configuration_Item__r.NE__OrderId__c;
        }

        Map<Id, Asset> assetMap = new Map<Id, Asset>([SELECT Id, XC_LegalEntity__c, XC_Segment__c, XC_BillingProfileLineItem__c, XC_BillingProfileLineItem__r.XC_BillingProfile__c,
                                                            XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Payment__c, NE__Order_Config__r.NE__OptyId__r.XC_Province__c, 
                                                            XC_Address__c, ContactId, Status, NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c, NE__Catalog__c, AccountId
                                                        FROM Asset
                                                        WHERE NE__Order_Config__c =: orderId]);
        Asset temporaryOfferAsset;
        Asset openChargeAsset;
        for(Asset a : assetMap.values()) {
            if(a.NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c.containsIgnoreCase('Temporary Offer')) {
                temporaryOfferAsset = a;
            } else if(a.NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c.containsIgnoreCase('OpenCharge')) {
                openChargeAsset = a;
            }
        }

        if(temporaryOfferAsset == null || openChargeAsset == null) {
            XC_Provisioning_Step__c stepToUpdate = new XC_Provisioning_Step__c();
            stepToUpdate.id = stepId;
            stepToUpdate.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            stepToUpdate.XC_ErrorMessage__c = 'Missing Asset';
            return;
        }

        // Inactive Open Charge Asset
        openChargeAsset.Status = Label.XC_CL_Asset_StatusInactive;
        XC_UTIL_SObject.updateRecord(openChargeAsset);

        // Get the Engine Code of the product to activate
        Map<Id, XC_CM_LegalEntity_Configuration__mdt> legalEnConfigMap = new Map<Id, XC_CM_LegalEntity_Configuration__mdt>([SELECT Id, XC_OfferToActivate__c
                                                                                                                            FROM XC_CM_LegalEntity_Configuration__mdt
                                                                                                                            WHERE XC_OrgId__c =: UserInfo.getOrganizationId() AND 
                                                                                                                                XC_LegalEntity__c =: temporaryOfferAsset.XC_LegalEntity__c AND
                                                                                                                                XC_Stream__c =: temporaryOfferAsset.XC_Segment__c AND
                                                                                                                                XC_OfferToActivate__c != null]);
        if(legalEnConfigMap.isEmpty()) {
            XC_Provisioning_Step__c stepToUpdate = new XC_Provisioning_Step__c();
            stepToUpdate.id = stepId;
            stepToUpdate.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            stepToUpdate.XC_ErrorMessage__c = 'New Offer to activate not found';
            return;
        }

        // Search Catalog Item PPU
        Map<Id, NE__Catalog_Item__c> catItemMap = new Map<Id, NE__Catalog_Item__c>([SELECT Id, XC_LIC_Catalog_Item_Name__c, NE__ProductId__c, NE__Catalog_Category_Name__c, NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c, NE__Catalog_Id__c, NE__Engine_Code__c, XC_Skip_Payment_Method__c, CurrencyIsoCode
                                                                                    FROM NE__Catalog_Item__c
                                                                                    WHERE NE__Engine_Code__c =: legalEnConfigMap.values()[0].XC_OfferToActivate__c]);
        NE__Catalog_Item__c prod = catItemMap.values()[0];

        // Call Mobility Order method to change offer on temporary offer asset
        Map<String, String> infosOffer = new Map<String, String>{'assetId' => temporaryOfferAsset.Id,
                                                                    'categoryId' => prod.NE__Catalog_Category_Name__c,
                                                                    'catalogId' => prod.NE__Catalog_Id__c,
                                                                    'catalogItemId' => prod.Id,
                                                                    'XC_eMobTransactionId__c' => Label.XC_CL_OpenCharge,
                                                                    'qty' => '1',
                                                                    'billingProfLineItemId' => temporaryOfferAsset.XC_BillingProfileLineItem__c,
                                                                    'billingProfId' => temporaryOfferAsset.XC_BillingProfileLineItem__r.XC_BillingProfile__c,
                                                                    'paymentMethod' => temporaryOfferAsset.XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Payment__c,
                                                                    'xcProvince' => temporaryOfferAsset.NE__Order_Config__r.NE__OptyId__r.XC_Province__c,
                                                                    'XC_LegalEntity__c' => temporaryOfferAsset.XC_LegalEntity__c,
                                                                    'clientSystem' => 'XRecharge',
                                                                    'XC_DeliveryAddress__c' => temporaryOfferAsset.XC_Address__c,
                                                                    'XC_InstallationAddress__c' => temporaryOfferAsset.XC_Address__c,
                                                                    'NE__AccountId__c' => temporaryOfferAsset.AccountId,
                                                                    'ContactId' => temporaryOfferAsset.ContactId,
                                                                    'PStoComplete' => stepId};
        XC_REST_MobilityOrder_U.changeOffer(infosOffer);
        
    }

}