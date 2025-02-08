/**
 * The Class XC_TR_BillingProfile_U_DisconnectAsset.
 *
 * @author            : Nicola Mariniello nmariniello@delotte.it
 * @date Creation     : 16/04/2021
 * @date Modification : dd/mm/yyyy
 * @description       : Class to manage disconnect asset linked to bpli
 **/


public without sharing class XC_TR_BillingProfile_U_DisconnectAsset {


    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_BillingProfile_U_DisconnectAsset');


    /** 
     * @param the mapmapOld old
     * @param mapNew the map new
     * @description on Status Update
     */
    public static void onStatusUpdate(Map<Id, NE__Billing_Profile__c> mapOld, Map<Id, NE__Billing_Profile__c> mapNew) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_BillingProfile_U_DisconnectAsset.onStatusUpdate');

        List<String> fieldList = new List<String>{'XC_Status__c', 'XC_StatusReason__c'};
        List<NE__Billing_Profile__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
		XC_UTIL_Debug.debug(DEBUGACTIVE, '#listChanged -> ' + listChanged);

        Map<Id, NE__Billing_Profile__c> bpToProcess = new Map<Id, NE__Billing_Profile__c>();
        for(NE__Billing_Profile__c bp : listChanged) {
            if(bp.XC_Status__c == label.XC_CL_BillingProfileStatus_Refused && bp.XC_StatusReason__c == Label.XC_CL_BillingProfile_StatusReason_Termination){
                bpToProcess.put(bp.Id, bp);
            }
		}
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#bpToProcess -> ' + bpToProcess);

        if(bpToProcess.isEmpty()) {
            return;
        }

        // Get BPLI and Assets
        Map<Id, XC_BillingProfileLineItem__c> bpliMap = new Map<Id, XC_BillingProfileLineItem__c>([SELECT Id, 
                                                                                                        (SELECT Id, XC_LegalEntity__c, XC_Segment__c, XC_BillingProfileLineItem__c, XC_BillingProfileLineItem__r.XC_BillingProfile__c,
                                                                                                            XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Payment__c, NE__Order_Config__r.NE__OptyId__r.XC_Province__c, 
                                                                                                            XC_Address__c, ContactId, Status, NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c, NE__Catalog__c, AccountId
                                                                                                        FROM Assets__r
                                                                                                        WHERE Status =: Label.XC_CL_Asset_StatusActive AND NE__Bundle_Configuration__c = ''
                                                                                                            AND NE__Parent_Order_Item__c = '' AND NE__Root_Order_Item__c = '')
                                                                                                    FROM XC_BillingProfileLineItem__c
                                                                                                    WHERE XC_BillingProfile__c IN: bpToProcess.keySet()]);
        
        for(XC_BillingProfileLineItem__c bpli : bpliMap.values()) {
            for(Asset a : bpli.Assets__r) {
                if(a.XC_Segment__c == 'B2C') {
                    changeOffer(JSON.serialize(a));
                } else {
                    disconnectAsset(JSON.serialize(a));
                }
            }
        }

    }


    /** 
     * @param assetString
     * @description change offer
     */
    @future(callout=true)
    public static void changeOffer(String assetString) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_BillingProfile_U_DisconnectAsset.changeOffer');

        Asset a = (Asset) JSON.deserialize(assetString, Asset.class);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Asset: ' + a);
        System.debug('AssetID: ' + a.Id);

        // Get the Engine Code of the product to activate
        Map<Id, XC_CM_LegalEntity_Configuration__mdt> legalEnConfigMap = new Map<Id, XC_CM_LegalEntity_Configuration__mdt>([SELECT Id, XC_OfferToActivate__c
                                                                                                                            FROM XC_CM_LegalEntity_Configuration__mdt
                                                                                                                            WHERE XC_OrgId__c =: UserInfo.getOrganizationId() AND 
                                                                                                                                XC_LegalEntity__c =: a.XC_LegalEntity__c AND
                                                                                                                                XC_Stream__c =: a.XC_Segment__c AND
                                                                                                                                XC_OfferToActivate__c != null]);
        if(legalEnConfigMap.isEmpty()) {
            return;
        }

        // Search Catalog Item PPU
        Map<Id, NE__Catalog_Item__c> catItemMap = new Map<Id, NE__Catalog_Item__c>([SELECT Id, XC_LIC_Catalog_Item_Name__c, NE__ProductId__c, NE__Catalog_Category_Name__c, NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c, NE__Catalog_Id__c, NE__Engine_Code__c, XC_Skip_Payment_Method__c, CurrencyIsoCode
                                                                                    FROM NE__Catalog_Item__c
                                                                                    WHERE NE__Engine_Code__c =: legalEnConfigMap.values()[0].XC_OfferToActivate__c]);
        NE__Catalog_Item__c prod = catItemMap.values()[0];

        // Call Mobility Order method to change offer
        Map<String, String> infosOffer = new Map<String, String>{'assetId' => a.Id,
                                                                    'categoryId' => prod.NE__Catalog_Category_Name__c,
                                                                    'catalogId' => prod.NE__Catalog_Id__c,
                                                                    'catalogItemId' => prod.Id,
                                                                    'XC_eMobTransactionId__c' => '',
                                                                    'orderSubtype' => Label.XC_CL_ConfigurationSubtype_ServiceUpgradeDowngrade,
                                                                    'qty' => '1',
                                                                    'billingProfLineItemId' => a.XC_BillingProfileLineItem__c,
                                                                    'billingProfId' => a.XC_BillingProfileLineItem__r.XC_BillingProfile__c,
                                                                    'paymentMethod' => a.XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Payment__c,
                                                                    'xcProvince' => a.NE__Order_Config__r.NE__OptyId__r.XC_Province__c,
                                                                    'XC_LegalEntity__c' => a.XC_LegalEntity__c,
                                                                    'clientSystem' => 'XRecharge',
                                                                    'XC_DeliveryAddress__c' => a.XC_Address__c,
                                                                    'XC_InstallationAddress__c' => a.XC_Address__c,
                                                                    'NE__AccountId__c' => a.AccountId,
                                                                    'ContactId' => a.ContactId};
        XC_REST_MobilityOrder_U.changeOffer(infosOffer);
    }


    /** 
     * @param assetString
     * @description disconnect asset
     */
    @future(callout=true)
    public static void disconnectAsset(String assetString) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_BillingProfile_U_DisconnectAsset.disconnectAsset');

        Asset a = (Asset) JSON.deserialize(assetString, Asset.class);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Asset: ' + a);
        System.debug('AssetID: ' + a.Id);

        String idorder = NE.JS_RemoteMethods.stdasset2order(a.Id , 'Disconnect');
        if(XC_UTIL_DisconnectAsset.isAnOrder(idorder) && Schema.SObjectType.NE__Order__c.isAccessible() && Schema.sObjectType.NE__Order__c.fields.Id.isAccessible() && Schema.sObjectType.NE__Order__c.fields.XC_Subtype__c.isAccessible()) {
            
            NE__Order__c conf = new NE__Order__c(Id = idorder, XC_Subtype__c = Label.XC_CL_ConfigurationSubtype_ContractCancellationForComplexProducts);
            XC_UTIL_Sobject.updateRecord(conf);
            
            XC_LCC048_OrderInProvisioning.insertProvisioningSteps(idorder, 'XC_TR_BillingProfile_U_DisconnectAsset');
            System.enqueueJob(new XC_UTIL_NextStepOrderToProvisioning.ThirdNextStepQueue(idorder));
        }
    }

}