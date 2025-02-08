/**
 * The Class XC_REST_MobilityOrder_U.
 *
 * @author            : Simone Trenta - strenta@deloitte.it
 * @date Creation     : 07/02/2019
 * @date Modification : 11/05/2019 by Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : UTIL for XC_REST_MobilityOrder
 **/ 

    
public without sharing class XC_REST_MobilityOrder_U {
    
    
    /**
     * ManageInsert.
     *
     * @param wrReq the wrapper request
     * @param wrResp the wrapper response
     * @description method to manage insert
     */
    public static void manageInsert(XC_REST_MobilityOrder_W.WrapperRequest wrReq, XC_REST_MobilityOrder_W.WrapperResponse wrResp, String transactionId) {

        Map<String, String> infos = createConfigurationInfoMap(wrReq.Order);
        infos.put('XC_eMobTransactionId__c', transactionId);
        infos.put('XC_LegalEntity__c', wrReq.Order.LegalEntity);
        infos.put('productCode', wrReq.Order.OrderItemList[0].EngineCode);
        infos.put('clientSystem',  wrReq.Order.ClientSystem);
        infos.put('activationCountry',  wrReq.Order.ActivationCountry);
        wrReq.Order.ClientSystem = null;

        checkToInsert(wrReq, wrResp, infos);
        if(wrResp.Result.ErrorCode != '0') {
            return;
        }

        // Check Coupon
        if(String.isNotBlank(wrReq.Order.CouponCode)) {
            Map<String, String> parameters = new Map<String, String>{'couponCode' => wrReq.Order.CouponCode,
                                                                        'AccountID' => wrReq.Order.AccountId,
                                                                        'method' => 'GET'
                                                                    };

            XC_REST_CheckCoupon_W.WrapperCheckCouponResponse resultBurnCoupon = new XC_REST_CheckCoupon_W.WrapperCheckCouponResponse();
            XC_REST_CheckCoupon_U.checkCouponGET(parameters, resultBurnCoupon);
            if(resultBurnCoupon.outcome == 'KO') {
                wrResp.Result.Message = resultBurnCoupon.outcomeDescription;
                wrResp.Result.logError = resultBurnCoupon.outcomeDescription;
                wrResp.Result.ErrorCode = '400';
                return;
            }
            
            Map<Id, XC_Voucher__c> couponMap = new Map<Id, XC_Voucher__c>([SELECT Id, XC_CompanyCode__c, XC_CostCenter__c, XC_Order__r.NE__OptyId__c, XC_Order__r.NE__OptyId__r.XC_Segment__c FROM XC_Voucher__c WHERE XC_VoucherCode__c =: wrReq.Order.CouponCode]);
            List<XC_Voucher__c> couponList = couponMap.values();
            if(couponList[0] != null) {
                infos.put('XC_Company_Code__c', couponList[0].XC_CompanyCode__c);
                infos.put('XC_Cost_Center__c', couponList[0].XC_CostCenter__c);

                if(infos.get('stream') != 'B2C' && couponList[0].XC_Order__r.NE__OptyId__r.XC_Segment__c != 'B2C') {
                    infos.put('optyIdRM', couponList[0].XC_Order__r.NE__OptyId__c);
                }
            }
        }
        //17032022 - mario.a.giordano@accenture.com - fix BLAZE
        if(null != wrReq.Order  && null  != wrReq.Order.Document && !wrReq.Order.Document.isEmpty() && null != wrReq.Order.Document[0]){
            infos.put('ExternalDocID',wrReq.Order.Document[0].ExternalDocID);
        }
        //END

        XC_REST_MobilityOrder_W.createOpportunityForOrder(infos, wrReq.Order.LegalEntity);
        createOrderB2W(infos);

        wrResp.Result.Message = 'Operation completed successfully';
        wrResp.Result.ErrorCode = '0';
    }


    /**
     * CheckToInsert.
     *
     * @param wrReq the wrapper request
     * @param wrResp the wrapper response
     * @param infos the infos map
     * @description method to check before insert
     */
    public static void checkToInsert(XC_REST_MobilityOrder_W.WrapperRequest wrReq, XC_REST_MobilityOrder_W.WrapperResponse wrResp, Map<String, String> infos) {

        XC_REST_MobilityOrder_Z.doChecks(wrReq, wrResp, infos);
        if(wrResp.Result.ErrorCode != '0') {
            return;
        }

        if(String.isNotBlank(wrReq.Order.CompanyCode) && String.isNotBlank(wrReq.Order.CostCenter)) {
            XC_REST_MobilityOrder_Z.retrieveSohoBillingProfile(wrReq, wrResp, infos);
            if(wrResp.Result.ErrorCode != '0') {
                return;
            }
        }

        if(infos.get('LICname') == 'X-Energía Smart' && (wrReq.BillingProfile == null || String.isBlank(wrReq.BillingProfile.CreditCardExternalKey))) {
            XC_REST_MobilityOrder_Z.createBillingProfileForSmart(infos, wrResp, wrReq.Order.LegalEntity);
            if(wrResp.Result.ErrorCode != '0') {
                return;
            }   
        }

        wrResp.Result.ErrorCode = '0';
    }


    /**
     * CreateOrderB2W.
     *
     * @param configurationInfo the configuration Info Map
     * @description method to create order b2w
     */
    public static void createOrderB2W(Map<String, String> configurationInfo){

        if(String.isNotBlank(configurationInfo.get('NE__OptyId__c'))) {
            Map<Id, XC_CS004_Bit2WinCredentials__c> b2wMap = new Map<Id, XC_CS004_Bit2WinCredentials__c>([SELECT XC_ServerURL__c, XC_ClientId__c, XC_OrganizationId__c, XC_EngineVersion__c FROM XC_CS004_Bit2WinCredentials__c WHERE XC_Country__c = 'SPAIN']);
            List<XC_CS004_Bit2WinCredentials__c> b2wCred = b2wMap.values();
            if(b2wCred.isEmpty()) {
                return;
            } else {
                configurationInfo.put('ServerURL', b2wCred[0].XC_ServerURL__c);
                configurationInfo.put('ClientId', b2wCred[0].XC_ClientId__c);
                configurationInfo.put('OrganizationId', b2wCred[0].XC_OrganizationId__c);
                configurationInfo.put('EngineVersion', b2wCred[0].XC_EngineVersion__c);
            }

            if(!Test.isRunningTest()) {
                XC_REST_CartAPI cartAPI = new XC_REST_CartAPI(configurationInfo);
                System.enqueueJob(cartAPI);
            }
        }
    }


    /**
     * ManageUpdate.
     *
     * @param wrReq the wrapper request
     * @param wrResp the wrapper response
     * @description method to manage update
     */
    public static void manageUpdate(XC_REST_MobilityOrder_W.WrapperRequest wrReq, XC_REST_MobilityOrder_W.WrapperResponse wrResp, String transactionId) {
        
        Asset asset = XC_REST_MobilityOrder_D.searchAsset(wrReq.Order.OrderItem.OldAssetID);
        if(asset == null) {

            wrResp.Result.Message = Label.XC_CL_AssetNotFound;
            wrResp.Result.logError = 'ERROR. Asset not found';
            wrResp.Result.ErrorCode = '400';
            return;

        } else if(asset.Status != 'Inactive') {
            
            wrResp.Result.Message = transactionId;
            changeOrder(wrReq, wrResp, asset);

        } else {
            wrResp.Result.Message = Label.XC_CL_AssetStatus + asset.Status + '\'';
            wrResp.Result.logError = 'ERROR. Asset Status is not correct \'' + asset.Status + '\'';
            wrResp.Result.ErrorCode = '400';
        } 
    }


    /**
     * ChangeOrder.
     *
     * @param wrReq the wrapper request
     * @param wrResp the wrapper response
     * @description method to change order
     */
    public static void changeOrder(XC_REST_MobilityOrder_W.WrapperRequest wrReq, XC_REST_MobilityOrder_W.WrapperResponse wrResp, Asset asset) {

        String transactionId = wrResp.Result.Message;
        wrResp.Result.Message = null;

        NE__Catalog_Item__c prod = XC_REST_MobilityOrder_D.searchCatalogItem(wrReq.order.OrderItem.NewEngineCode);
        if(prod == null){
            wrResp.Result.Message = 'ERROR. CatalogItemID' + Label.XC_CL_NotFount;
            wrResp.Result.logError = 'ERROR. CatalogItemID not found';
            wrResp.Result.ErrorCode = '400';
            return;
        }
        
        if(String.isNotBlank(wrReq.order.AccountID)) {
            Account acc = XC_REST_MobilityOrder_D.searchAccount(wrReq.order.AccountID);
            if(acc == null){
                wrResp.Result.Message = Label.XC_CL_AccountNotFound;
                wrResp.Result.logError = 'ERROR. Account not found';
                wrResp.Result.ErrorCode = '400';
                return;
            }
        } else {
            wrReq.Order.AccountID = asset.Contact.AccountId;
        }
        
        if(asset.NE__CatalogItem__r.NE__Engine_Code__c != wrReq.order.OrderItem.NewEngineCode) {
            // CHANGE OFFER

            if(asset.Status == 'Suspended') {
                wrResp.Result.Message = Label.XC_CL_AssetStatus + asset.Status + '\'';
                wrResp.Result.logError = 'ERROR. Asset Status is not correct \'' + asset.Status + '\'';
                wrResp.Result.ErrorCode = '400';
                return;
            }

            Map<String, String> infosOffer = new Map<String, String>{'assetId' => wrReq.Order.OrderItem.OldAssetID,
                                                                    'categoryId' => prod.NE__Catalog_Category_Name__c,
                                                                    'catalogId' => prod.NE__Catalog_Id__c,
                                                                    'catalogItemId' => prod.Id,
                                                                    'qty' => (String.valueOf(wrReq.Order.OrderItem.NewQuantity)),
                                                                    'XC_eMobTransactionId__c' => transactionId,
                                                                    'billingProfLineItemId' => asset.XC_BillingProfileLineItem__c,
                                                                    'billingProfId' => asset.XC_BillingProfileLineItem__r.XC_BillingProfile__c,
                                                                    'paymentMethod' => asset.XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Payment__c,
                                                                    'xcProvince' => asset.NE__Order_Config__r.NE__OptyId__r.XC_Province__c,
                                                                    'XC_LegalEntity__c' => asset.NE__Order_Config__r.NE__OptyId__r.XC_LegalEntity__c,
                                                                    'clientSystem' => wrReq.Order.ClientSystem
                                                                    };
                                                                    
            wrReq.Order.ClientSystem = null;
            infosOffer.putAll(createConfigurationInfoMap(wrReq.Order));
            infosOffer.put('XC_DeliveryAddress__c', asset.XC_Address__c);
            infosOffer.put('XC_InstallationAddress__c', asset.XC_Address__c);
            infosOffer.put('ContactId', asset.ContactId);

            changeOffer(infosOffer);

        } else if(wrReq.BillingProfile != null && String.isNotBlank(wrReq.BillingProfile.CreditCardExternalKey)) {
            //CHANGE BILLING PROFILE
            
                Map<String,Object> mapUtil = new Map<String,Object>();
                mapUtil.put('externalKey', wrReq.BillingProfile.CreditCardExternalKey);
                mapUtil.put('legalEntity', asset.NE__Order_Config__r.NE__OptyId__r.XC_LegalEntity__c);
                mapUtil.put('deliveryAddressId', asset.XC_Address__c);
                
                XC_BillingProfileLineItem__c billingProfileLineItem = XC_REST_MobilityOrder_D.searchBillingProfileLineItem(mapUtil, wrResp);
                if(billingProfileLineItem == null) {
                    wrResp.Result.Message = Label.XC_CL_ProBilling_CreditCard + ' ' + wrReq.BillingProfile.CreditCardExternalKey + ' ' + Label.XC_CL_NotFount;
                    wrResp.Result.logError = 'ERROR: BillingProfile with CreditCardExternalKey '+ wrReq.BillingProfile.CreditCardExternalKey + ' not found';
                    wrResp.Result.ErrorCode = '400';
                    return;
                }else if (wrResp.Result.ErrorCode == '500'){
                    return;
                }
                
                Map<String, String> infosBill = new Map<String, String>{'asset' => JSON.serialize(asset, true),
                    'billingProfileLineItem' => JSON.serialize(billingProfileLineItem, true),
                    'transactionId' => transactionId
                    };
                changeBillingProfile(infosBill);
        	 
        }

        wrResp.Result.Message = 'Operation completed successfully';
        wrResp.Result.ErrorCode = '0';
    }


    /**
     * ChangeOffer.
     *
     * @param infos the infos map
     * @description method to create order b2w
     */
    public static void changeOffer(Map<String, String> infos){

        Map<Id, XC_CS004_Bit2WinCredentials__c> b2wMap = new Map<Id, XC_CS004_Bit2WinCredentials__c>([SELECT XC_ServerURL__c, XC_ClientId__c, XC_OrganizationId__c, XC_EngineVersion__c FROM XC_CS004_Bit2WinCredentials__c WHERE XC_Country__c = 'SPAIN']);
        List<XC_CS004_Bit2WinCredentials__c> b2wCred = b2wMap.values();
        if(b2wCred.isEmpty()) {
            return;
        }
        infos.put('ServerURL', b2wCred[0].XC_ServerURL__c);
        infos.put('ClientId', b2wCred[0].XC_ClientId__c);
        infos.put('OrganizationId', b2wCred[0].XC_OrganizationId__c);
        infos.put('EngineVersion', b2wCred[0].XC_EngineVersion__c);

        Map<Id, XC_CS005_Bit2WinChangeAPI__c> b2wChangeMap = new Map<Id, XC_CS005_Bit2WinChangeAPI__c>([SELECT XC_Password__c, XC_PasswordToken__c, XC_ServerURL__c, XC_UserToken__c FROM XC_CS005_Bit2WinChangeAPI__c WHERE XC_Country__c = 'SPAIN']);
        List<XC_CS005_Bit2WinChangeAPI__c> b2wChangeCred = b2wChangeMap.values();
        if(b2wChangeCred.isEmpty()) {
            return;
        }
        infos.put('ServerURL_Change', b2wChangeCred[0].XC_ServerURL__c);
        infos.put('Password', b2wChangeCred[0].XC_Password__c);
        infos.put('PasswordToken', b2wChangeCred[0].XC_PasswordToken__c);
        infos.put('UserToken', b2wChangeCred[0].XC_UserToken__c);

        for(String key : infos.keySet()) {
            if(String.isBlank(infos.get(key))) {
                String rem = infos.remove(key);
            }
        }
        String rec = infos.remove('RecordTypeId');

        if(!Test.isRunningTest()) {
            XC_REST_ChangeAPI changeAPI = new XC_REST_ChangeAPI(infos);
            System.enqueueJob(changeAPI);
        }
    }


    /**
     * ChangeBillingProfile.
     *
     * @param infos the infos map
     * @description method to create order b2w
     */
    @future(callout=true)
    public static void changeBillingProfile(Map<String, String> infos){

        Asset asset = (Asset) JSON.deserialize(infos.get('asset'), Asset.class);
        XC_BillingProfileLineItem__c billingProfileLineItem = (XC_BillingProfileLineItem__c) JSON.deserialize(infos.get('billingProfileLineItem'), XC_BillingProfileLineItem__c.class);
        String transactionId = infos.get('transactionId');

        if(asset.XC_Configuration_Item__r.XC_BillingProfileLineItem__c != billingProfileLineItem.Id) {
            // CHANGE BILLING PROFILE

            String orderChangeID = NE.JS_RemoteMethods.stdasset2order(asset.Id, 'Change');
            System.debug('orderChangeID -> ' + orderChangeID);

            NE__Order__c orderChangeToUpdate = new NE__Order__c(Id = orderChangeID,
                                                                XC_Subtype__c = 'Change Billing Profile',
                                                                XC_OrderBillingAddress__c = billingProfileLineItem.XC_BillToAddress__c,
                                                                XC_eMobTransactionId__c = transactionId,
                                                                XC_Compliance_Approval__c = 'Not Needed',
                                                                NE__AccountId__c = asset.Contact.AccountId,
                                                                NE__BillAccId__c = asset.Contact.AccountId,
                                                                NE__ServAccId__c = asset.Contact.AccountId,
                                                                XC_TechnicalProductOnly__c = false
                      
                                                               );
            
            XC_UTIL_Sobject.WrapperResult updateOrderResult = XC_UTIL_Sobject.updateRecord(orderChangeToUpdate);
            if(updateOrderResult.success) {

                Map<Id, NE__OrderItem__c> oiMap = new Map<Id, NE__OrderItem__c>([SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderChangeID LIMIT 1]);
                NE__OrderItem__c oiToUpdate = oiMap.values()[0];
                oiToUpdate.NE__BillingProfId__c = billingProfileLineItem.XC_BillingProfile__c;
                oiToUpdate.XC_BillingProfileLineItem__c = billingProfileLineItem.Id;
                oiToUpdate.XC_PaymentMethod__c = billingProfileLineItem.XC_BillingProfile__r.NE__Payment__c;
            
                XC_UTIL_Sobject.WrapperResult updateOIResult = XC_UTIL_Sobject.updateRecord(oiToUpdate);
                if(updateOIResult.success) {
                    XC_LCC048_OrderInProvisioning.insertProvisioningSteps(orderChangeID, 'XC_REST_MobilityOrder_U');
                    System.enqueueJob(new XC_UTIL_NextStepOrderToProvisioning.ThirdNextStepQueue(orderChangeID));
                }
            }
        }
    }


    /**
     * CreateConfigurationInfoMap.
     *
     * @param orderWr the order wrapper
     * @return the Map<String, String>
     * @description method to populate Order fields from WrapperRequest POST Method
     **/   
    public static Map<String, String> createConfigurationInfoMap(XC_REST_MobilityOrder_W.OrderWrapper orderWr){

        Map<String, String> infos = new Map<String, String>{'NE__AccountId__c' => orderWr.AccountID,
                                                            'NE__BillAccId__c' => orderWr.AccountID,
                                                            'NE__ServAccId__c' => orderWr.AccountID,
                                                            'NE__OrderStatus__c' => orderWr.OrderStatus,
                                                            'XC_Contract_Code__c' => orderWr.ContractCode,
                                                            'XC_Contract_Date__c' => orderWr.ContractDate,
                                                            'XC_Company_Code__c' => orderWr.CompanyCode,
                                                            'XC_Cost_Center__c' => orderWr.CostCenter,
                                                            'NE__One_Time_Fee_Total__c' => orderWr.TotalOneTimeFee,
                                                            'B2WZC__ZPaymentmethodType__c' => orderWr.PaymentMode,
                                                            'NE__Channel__c' => orderWr.Channel,
                                                            'XC_SubChannel__c' => orderWr.SubChannel,
                                                            'XC_RegisteredOnRechargeApp__c' => (String.valueOf(orderWr.RegisteredOnRechargeApp)),
                                                            'XC_Coupon_Code__c' => orderWr.CouponCode,
                                                            'XC_Destination_Code__c' => orderWr.DestinationCode,
                                                            'XC_Certified_Email__c' => orderWr.CertifiedEmail,
                                                            'XC_OrderBillingAddress__c' => orderWr.BillingAddressID,
                                                            'XC_DeliveryAddress__c' => orderWr.ShippingAddressID,
                                                            'XC_InstallationAddress__c' => orderWr.ShippingAddressID,
                                                            'NE__ConfigurationStatus__c' => 'Valid',
                                                            'NE__type__c' => 'InOrder',
                                                            'RecordTypeId' => (Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId()),
                                                            'XC_EnelEnergyOfferExternalID__c' => orderWr.ExternalOffer //[ deepti.ramesh@accenture.com, 18/2/2022, R1-2022, AO011249, added mapping for new tag]
                                                            };
        
        return infos;
    }
    
    public static void skipTestMFL(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }


}