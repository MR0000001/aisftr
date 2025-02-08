/**
 * The Class XC_REST_MobilityOrder_D.
 *
 * @author            : Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 15/06/2020
 * @date Modification : dd/mm/yyyy
 * @description       : UTIL for XC_REST_MobilityOrder
 **/


public without sharing class XC_REST_MobilityOrder_D {


    /**
     * SearchAccount.
     *
     * @param accountId the account id
     * @return the account
     * @description method to get Account
     */
    public static Account searchAccount(String accountId) {

        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, XC_Segment__c, (SELECT Id, XC_DeliveryAddress__c, XC_AddressProvince__c FROM Addresses__r ORDER BY LastModifiedDate desc) FROM Account WHERE Id =: accountId]);
        List<Account> accountList = accountMap.values();

        if(accountList.isEmpty()) {
            return null;
        }

        return accountList[0];
    }


    /**
     * SearchAsset.
     *
     * @param assetId the asset id
     * @return the asset
     * @description method to get Asset
     */
    public static Asset searchAsset(String assetId) {

        Map<Id, Asset> assetMap = new Map<Id, Asset>([SELECT Id, Status, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__CatalogItem__c, ContactId, Contact.AccountId,
                                                        XC_Configuration_Item__r.NE__CatalogItem__r.NE__Engine_Code__c, XC_Configuration_Item__r.NE__BillingProfId__c,
                                                        XC_Configuration_Item__r.XC_BillingProfileLineItem__c, XC_Configuration_Item__r.NE__BillingProfId__r.NE__Payment__c,
                                                        NE__Order_Config__r.NE__OptyId__r.XC_Province__c, NE__Order_Config__r.NE__OptyId__r.XC_LegalEntity__c,
                                                        NE__Order_Config__r.NE__OptyId__r.XC_Country__c, XC_Address__c, NE__CatalogItem__r.NE__Engine_Code__c, XC_BillingProfileLineItem__c,
                                                        XC_BillingProfileLineItem__r.XC_BillingProfile__c, XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Payment__c
                                                        FROM Asset
                                                        WHERE Id =: assetId]);
        List<Asset> assetList = assetMap.values();
        
        if(assetList.isEmpty()) {
            return null;
        }

        return assetList[0];
    }


    /**
     * SearchCatalogItem.
     *
     * @param engineCode the engine code
     * @return the catalog item
     * @description method to get ProductID from CatalogItemID
     */
    public static NE__Catalog_Item__c searchCatalogItem(String engineCode){

        Map<Id, NE__Catalog_Item__c> catItemMap = new Map<Id, NE__Catalog_Item__c>([SELECT Id, XC_LIC_Catalog_Item_Name__c, NE__ProductId__c, NE__Catalog_Category_Name__c, NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c, NE__Catalog_Id__c, NE__Engine_Code__c, XC_Skip_Payment_Method__c, CurrencyIsoCode
                                                                                    FROM NE__Catalog_Item__c
                                                                                    WHERE NE__Engine_Code__c =: engineCode]);
        List<NE__Catalog_Item__c> catItemList = catItemMap.values();
        
        if(catItemList.isEmpty()) {
            return null;
        }

        return catItemList[0]; 
    }


    /**
     * SearchCatalogItems.
     *
     * @param engineCodes the engine code list
     * @return the catalog item
     * @description method to get ProductID from CatalogItemID
     */
    public static List<NE__Catalog_Item__c> searchCatalogItems(Set<String> engineCodes){

        Map<Id, NE__Catalog_Item__c> catItemMap = new Map<Id, NE__Catalog_Item__c>([SELECT Id, XC_LIC_Catalog_Item_Name__c, NE__ProductId__c, NE__Catalog_Category_Name__c, NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c, NE__Catalog_Id__c, NE__Engine_Code__c, XC_Skip_Payment_Method__c, CurrencyIsoCode
                                                                                    FROM NE__Catalog_Item__c
                                                                                    WHERE NE__Engine_Code__c IN: engineCodes]);

        return catItemMap.values();
    }


     /**
     * SearchBillingProfileLineItem.
     *
     * @param mapUtil the map with util value
     * @param wrResp the wrapper response
     * @return the billing profile line item
     * @description method to get the billing profile line item
     **/   
    public static XC_BillingProfileLineItem__c searchBillingProfileLineItem(Map<String,Object> mapUtil, XC_REST_MobilityOrder_W.WrapperResponse wrResp) {

        String creditCardExternalKey = (String) mapUtil.get('externalKey');
        String legalEntity = (String) mapUtil.get('legalEntity');
        String deliveryAddressId = (String) mapUtil.get('deliveryAddressId');
            
        Map<Id, XC_BillingProfileLineItem__c> bpliMap = new Map<Id, XC_BillingProfileLineItem__c>([SELECT Id, XC_BillingProfile__c, XC_BillingProfile__r.NE__Payment__c, XC_BillToAddress__c,
                                                                                                    XC_SoldToAddress__c, XC_BillToContactId__c, XC_SoldToContactId__c, XC_BillingProfileName__c, XC_BillingProfile__r.XC_PayPalUsername__c,
                                                                                                    XC_ExternalKey__c, XC_BillingProfile__r.NE__Account__c, XC_LegalEntity__c, XC_PEC__c, XC_RecipientCode__c, XC_BillToContactId__r.Email,XC_TPBCode__c, // EA TPB 12/10/2021 add XC_TPBCode__c
                                                                                                    (SELECT Id FROM Configuration_Items__r)
                                                                                                    FROM XC_BillingProfileLineItem__c
                                                                                                    WHERE XC_ExternalKey__c =: creditCardExternalKey AND XC_TPBCode__c=null]); // EA TPB 12/10/2021 add XC_TPBCode__c = null

        List<XC_BillingProfileLineItem__c> bpliList = bpliMap.values();
        if(bpliList.isEmpty()){
            return null;
        }

        mapUtil.put('billingProfilePaymentMethod', bpliList[0].XC_BillingProfile__r.NE__Payment__c);

        XC_BillingProfileLineItem__c bpliToUpdate;
        for(XC_BillingProfileLineItem__c bpli : bpliList){
            if(bpli.XC_LegalEntity__c == legalEntity && bpli.XC_SoldToAddress__c == deliveryAddressId){
                return bpli; 
            } else if(bpli.XC_LegalEntity__c == legalEntity && bpli.Configuration_Items__r.isEmpty()) {
                bpliToUpdate = bpli;
            }
        }

        if(bpliToUpdate != null) {
            bpliToUpdate.XC_SoldToAddress__c = deliveryAddressId;
            XC_UTIL_Sobject.updateRecord(bpliToUpdate);
            return bpliToUpdate;
        }

        mapUtil.put('billingProfLi', bpliList[0]);
        XC_BillingProfileLineItem__c bpli = XC_REST_MobilityOrder_B.createBillingProfile(mapUtil, wrResp);
        if(wrResp.Result.ErrorCode == '500'){
            return null; 
        }
        
        return bpli;
    }

}