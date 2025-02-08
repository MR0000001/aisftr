/**
 * The Class XC_REST_MobilityOrder_Z.
 *
 * @author            : Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 13/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : UTIL for XC_REST_MobilityOrder
 **/


public without sharing class XC_REST_MobilityOrder_Z {


    /**
     * DoChecks.
     *
     * @param wrReq the wrapper request
     * @param wrResp the wrapper response
     * @param infos the infos map
     * @description method to check before insert
     */
    public static void doChecks(XC_REST_MobilityOrder_W.WrapperRequest wrReq, XC_REST_MobilityOrder_W.WrapperResponse wrResp, Map<String, String> infos) {
        
        if(String.isNotBlank(wrReq.order.AccountID)) {
            Account acc = XC_REST_MobilityOrder_D.searchAccount(wrReq.order.AccountID);
            if(acc == null){
                wrResp.Result.Message = Label.XC_CL_AccountNotFound;
                wrResp.Result.logError = 'ERROR. Account not found';
                wrResp.Result.ErrorCode = '400';
                return;
            }
            infos.put('stream', acc.XC_Segment__c);

            if(!acc.Addresses__r.isEmpty()) {
                String deliveryAddress = acc.Addresses__r[0].Id;
                String province = acc.Addresses__r[0].XC_AddressProvince__c;
                for(XC_Address__c addr : acc.Addresses__r) {
                    if(addr.Id == wrReq.Order.ShippingAddressID) {
                        deliveryAddress = addr.Id;
                        province = addr.XC_AddressProvince__c;
                        break;
                    }
                    if(addr.XC_DeliveryAddress__c == true) {
                        deliveryAddress = addr.Id;
                        province = addr.XC_AddressProvince__c;
                        if(String.isBlank(wrReq.Order.ShippingAddressID)) {
                            break;
                        }
                    }
                }
                infos.put('XC_DeliveryAddress__c', deliveryAddress);
                infos.put('XC_InstallationAddress__c', deliveryAddress);
                infos.put('xcProvince', province);
            }
        }

        doChecksPlus(wrReq, wrResp, infos);
        if(wrResp.Result.ErrorCode != '0') {
            return;
        }
        
        //infos.put('qty', String.valueOf(wrReq.Order.OrderItem.Quantity));
        wrResp.Result.ErrorCode = '0';
    }


    /**
     * DoChecksPlus.
     *
     * @param wrReq the wrapper request
     * @param wrResp the wrapper response
     * @param infos the infos map
     * @description method to check before insert
     */
    public static void doChecksPlus(XC_REST_MobilityOrder_W.WrapperRequest wrReq, XC_REST_MobilityOrder_W.WrapperResponse wrResp, Map<String, String> infos) {
        
        Set<String> engineCodes = new Set<String>();
        for(XC_REST_MobilityOrder_W.OrderItemWrapper oiWr : wrReq.Order.OrderItemList) {
            engineCodes.add(oiWr.EngineCode);
        }

        List<NE__Catalog_Item__c> prodList = XC_REST_MobilityOrder_D.searchCatalogItems(engineCodes);
        if(prodList == null || prodList.isEmpty() || prodList.size() != engineCodes.size()){
            wrResp.Result.Message = 'ERROR. EngineCodes not valid';
            wrResp.Result.logError = 'ERROR. EngineCodes not valid';
            wrResp.Result.ErrorCode = '400';
            return;

        } else {
            addOrderItemsToInfosMap(wrReq, prodList, infos);
        }

        XC_UTIL_Integration.WrapperResult validateResult = XC_REST_MobilityOrder_V.validateBillingProfile(wrReq, 'POST', prodList[0]);
        if(validateResult.errorFlag) {
            wrResp.Result.Message = 'ERROR. ' + validateResult.errorMessage;
            wrResp.Result.logError = 'ERROR. ' + validateResult.errorMessage;
            wrResp.Result.ErrorCode = '400';
            return;
        }

        if(wrReq.BillingProfile != null && String.isNotBlank(wrReq.BillingProfile.CreditCardExternalKey)) {

            Map<String,Object> mapUtil = new Map<String,Object>();
            mapUtil.put('externalKey', wrReq.BillingProfile.CreditCardExternalKey);
            mapUtil.put('legalEntity', wrReq.order.LegalEntity);
            mapUtil.put('deliveryAddressId', infos.get('XC_DeliveryAddress__c'));
            mapUtil.put('TransactionID', infos.get('XC_eMobTransactionId__c'));

            XC_BillingProfileLineItem__c billingProfileLineItem = XC_REST_MobilityOrder_D.searchBillingProfileLineItem(mapUtil, wrResp);
            if(billingProfileLineItem == null){
                wrResp.Result.Message = Label.XC_CL_ProBilling_CreditCard + ' ' + wrReq.BillingProfile.CreditCardExternalKey + ' ' + Label.XC_CL_NotFount;
                wrResp.Result.logError = 'ERROR: BillingProfile with CreditCardExternalKey '+ wrReq.BillingProfile.CreditCardExternalKey + ' not found';
                wrResp.Result.ErrorCode = '400';
                return;
            }else if (wrResp.Result.ErrorCode == '500'){
                return;
            }
                
            infos.put('billingProfLineItemId', billingProfileLineItem.Id);
            infos.put('billingProfId', billingProfileLineItem.XC_BillingProfile__c);
            infos.put('paymentMethod', (String)mapUtil.get('billingProfilePaymentMethod')); //billingProfileLineItem.XC_BillingProfile__r.NE__Payment__c
            
            if(String.isBlank(infos.get('XC_OrderBillingAddress__c'))) {
                infos.put('XC_OrderBillingAddress__c', billingProfileLineItem.XC_BillToAddress__c);
            }
        }

        String productCategory = (prodList[0].NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c.equalsIgnoreCase('App Mobile')) ? 'eMobility Private' : 'eMobility Recharge Manager';
        infos.put('productCategory', productCategory);
        infos.put('categoryId', prodList[0].NE__Catalog_Category_Name__c);
        infos.put('catalogId', prodList[0].NE__Catalog_Id__c);
        //infos.put('catalogItemId', prod.id);
        infos.put('LICname', prodList[0].XC_LIC_Catalog_Item_Name__c);
        infos.put('currencyISOCode', prodList[0].CurrencyIsoCode);
        wrResp.Result.ErrorCode = '0';
    }


    /**
     * AddOrderItemsToInfosMap.
     *
     * @param wrReq the wrapper request
     * @param prodList the prodList
     * @param infos the infos map
     * @description method to check before insert
     */
    public static void addOrderItemsToInfosMap(XC_REST_MobilityOrder_W.WrapperRequest wrReq, List<NE__Catalog_Item__c> prodList, Map<String, String> infos) {

        Map<String, NE__Catalog_Item__c> engineCodeProductMap = new Map<String, NE__Catalog_Item__c>();
        for(NE__Catalog_Item__c prod : prodList) {
            engineCodeProductMap.put(prod.NE__Engine_Code__c, prod);
        }

        List<String> catalogItemIds = new List<String>();
        for(XC_REST_MobilityOrder_W.OrderItemWrapper oiWr : wrReq.Order.OrderItemList) {
            oiWr.CatalogItemID = engineCodeProductMap.get(oiWr.EngineCode).Id;
            catalogItemIds.add(oiWr.CatalogItemID);
        }

        infos.put('catalogItemIds', JSON.serialize(catalogItemIds));
        infos.put('orderItemList', JSON.serialize(wrReq.Order.OrderItemList));
    }


    /**
     * CreateBillingProfileForSmart.
     *
     * @param infos the infos map
     * @param the wrapper response
     * @description method to create Billing Profile for product 'X-Energía Smart'
     **/   
    public static void createBillingProfileForSmart(Map<String, String> infos, XC_REST_MobilityOrder_W.WrapperResponse wrResp, String legalEntity){

        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, Name, Country__c, CurrencyIsoCode, RecordType.Name, IdentityType__c, IdentityNumber__c, XC_NIE_expedition_date__c, XC_NIE_expiration_date__c,
                                                            XC_DocumentCountry__c, XC_Segment__c, XC_VatGroupType__c, XC_CompanyFiscalCode__c, XC_GIRO__c, XC_Country__c,
                                                        (SELECT Id, XC_DocumentType__c, XC_DocumentNumber__c, XC_ReleaseDate__c, XC_ExpirationDate__c, XC_Country__c FROM Personal_Documents__r),
                                                        (SELECT Id, XC_MainLegalEntity__c, XC_Preferredlanguageofcontact__c FROM Contacts WHERE XC_PrimaryContact__c = true),
                                                        (SELECT Id FROM Addresses__r WHERE XC_BillingAddress__c = true)
                                                        FROM Account WHERE Id =: infos.get('NE__AccountId__c')]);
        Account account = accMap.values();

        if(account.Addresses__r.isEmpty()) {
            wrResp.Result.Message = Label.XC_CL_AccBillingAddress;
            wrResp.Result.logError = 'ERROR. The Account has not a BillingAddress';
            wrResp.Result.ErrorCode = '400';
            return;
        }   

        NE__Billing_Profile__c billingProfile = new NE__Billing_Profile__c(Name = 'Cash',
                                                                            NE__Payment__c = 'Cash',
                                                                            NE__Account__c = infos.get('NE__AccountId__c'),
                                                                            XC_Status__c = 'Draft');
        XC_UTIL_Sobject.WrapperResult w = XC_UTIL_Sobject.insertRecord(billingProfile);
        if(!w.success){
            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.logError = 'INTERNAL ERROR: ' + w.errorMessage;
            wrResp.Result.ErrorCode = '500';
            return;
        }

        System.debug('@@@Billing Prof Id ' + billingProfile.Id);

        XC_BillingProfileLineItem__c billingProfileLineItem = new XC_BillingProfileLineItem__c(XC_BillingProfile__c = billingProfile.Id, 
                                                                                                XC_BillToAddress__c = account.Addresses__r[0].Id,
                                                                                                XC_SoldToAddress__c = account.Addresses__r[0].Id, 
                                                                                                XC_BillToContactId__c = account.Contacts[0].Id,
                                                                                                XC_SoldToContactId__c = account.Contacts[0].Id,
                                                                                                XC_LegalEntity__c = legalEntity,
                                                                                                XC_BillingProfileName__c = 'Cash');
        XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.insertRecord(billingProfileLineItem); 
        if(!wr.success){
            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.logError = 'INTERNAL ERROR: ' + wr.errorMessage;
            wrResp.Result.ErrorCode = '500';
            return;
        }

        infos.put('billingProfLineItemId', billingProfileLineItem.Id);
        infos.put('billingProfId', billingProfile.Id);
        infos.put('paymentMethod', billingProfile.NE__Payment__c);
        infos.put('XC_OrderBillingAddress__c', billingProfileLineItem.XC_BillToAddress__c);


        // Prepare infos for Zuora callouts
        ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper conAddrWr = ZuoraBillingProfileCreationController.prepareContactForZuora(account.Contacts[0].Id, account.Addresses__r[0].Id, billingProfileLineItem.XC_LegalEntity__c);
        String contactSoldSerialized = JSON.Serialize(conAddrWr);
        String contactBillSerialized = JSON.Serialize(conAddrWr);

        XC_REST_Account_B.wrapperOption wrOptions = new XC_REST_Account_B.wrapperOption();
        wrOptions.SimplifiedInvoiceReplace = 'No';
        wrOptions.invoiceDeliveryPrefsEmail = true;
        wrOptions.invoiceDeliveryPrefsPrint = false;
        wrOptions.paymentTerm = 'Due Upon Receipt';
        wrOptions.billCycleDay = 0;
        //wrOptions.billCycleDay = 1;

        Map<String,Object> zuoraPayment = createZuoraPayment(BillingProfile.Id, account);

        String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, account.XC_Segment__c);
        if(String.isBlank(entityName)) {
            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.logError = 'INTERNAL ERROR: ' + Label.XC_CL_EntityNameNotFound;
            wrResp.Result.ErrorCode = '500';
            return;
        }

        Map<String, String> zuoraInfo = new Map<String, String>();
        zuoraInfo.put('account', JSON.Serialize(account, true));
        zuoraInfo.put('billingContact', contactBillSerialized);
        zuoraInfo.put('soldContact', contactSoldSerialized);
        zuoraInfo.put('entityName', entityName);
        zuoraInfo.put('options', (JSON.Serialize(wrOptions, true)).replace('Replace', '__c'));
        zuoraInfo.put('billingProfId', billingProfile.Id);
        zuoraInfo.put('billingProfLineItemId', billingProfileLineItem.Id);
        zuoraInfo.put('zuoraPayment', JSON.serialize(zuoraPayment, true));

        callZuora(zuoraInfo);

        wrResp.Result.ErrorCode = '0';
    }


    /**
     * CreateZuoraPayment.
     *
     * @param billingProfId the billing profile id
     * @param account the account
     * @return the Map<String, Object>
     * @description method to create zuora payment map
     **/
    public static Map<String, Object> createZuoraPayment(String billingProfId, Account account){

        String docNif = '';
        String docNumber = '';
        String expedition = '';
        String expiration = '';
        String countryCode = '';


        if(account.RecordType.Name == 'Residential' &&  !account.Personal_Documents__r.isEmpty()) {
            docNif = account.Personal_Documents__r[0].XC_DocumentType__c;
            docNumber = account.Personal_Documents__r[0].XC_DocumentNumber__c;
            expedition = (account.Personal_Documents__r[0].XC_ReleaseDate__c != null) ? String.valueOf(account.Personal_Documents__r[0].XC_ReleaseDate__c) : '';
            expiration = (account.Personal_Documents__r[0].XC_ExpirationDate__c != null) ? String.valueOf(account.Personal_Documents__r[0].XC_ExpirationDate__c) : '';
            countryCode = [SELECT XC_ISOCode__c FROM XC_CM_CountryISOCodeAssociation__mdt WHERE XC_Country__c =: account.Personal_Documents__r[0].XC_Country__c][0].XC_ISOCode__c;
        } else if(account.RecordType.Name != 'Residential') {
            docNif = account.IdentityType__c;
            docNumber = account.IdentityNumber__c;
            expedition = (account.XC_NIE_expedition_date__c != null) ? String.valueOf(account.XC_NIE_expedition_date__c) : '';
            expiration = (account.XC_NIE_expiration_date__c != null) ? String.valueOf(account.XC_NIE_expiration_date__c) : '';
            countryCode = [SELECT XC_ISOCode__c FROM XC_CM_CountryISOCodeAssociation__mdt WHERE XC_Country__c =: account.XC_DocumentCountry__c][0].XC_ISOCode__c;
        }

        Map<String, Object> zuoraPayment = new Map<String,Object>{'bpId' => billingProfId,
                                                                 'fromBillingProfile' => false,
                                                                 'docNif' => docNif,
                                                                 'docNumber' => docNumber,
                                                                 'expedition' => expedition,
                                                                 'expiration' => expiration,
                                                                 'countryCode' => countryCode,
            													 'personTypeCode' => (account.RecordType.Name == 'Residential') ? 'F' : 'J'
                                                                };
        return zuoraPayment;
    }


    /**
     * CallZuora.
     *
     * @param zuoraInfo the zuora info map
     * @description method to call Zuora
     **/
    @future(callout=true)
    public static void callZuora(Map<String, String> zuoraInfo){

        String account = zuoraInfo.get('account');
        String billingContact = zuoraInfo.get('billingContact');
        String soldContact = zuoraInfo.get('soldContact');
        String entityName = zuoraInfo.get('entityName');
        String options = zuoraInfo.get('options');
        String billingProfId = zuoraInfo.get('billingProfId');
        String billingProfLineItemId = zuoraInfo.get('billingProfLineItemId');
        String zuoraPayment = zuoraInfo.get('zuoraPayment');
        
        system.debug('Info to Zuora: option '+ options);
        system.debug('Info to Zuora: Account '+ account);

        if(!Test.isRunningTest()) {
            //createUnlinkedZuoraAccount
            Map<String,Object> mapResult =  (Map<String,Object>)JSON.deserializeUntyped(ZuoraBillingProfileCreationController.createUnlinkedZuoraAccount(account, billingContact, soldContact, entityName, options, billingProfLineItemId, zuoraPayment));
            system.debug('mapResult'+mapResult);
            if(mapResult.get('success') == 'true'){
                String accZuoraId = (String) mapResult.get('accountId');
                
                //linkAccountToExternalPaymentMethod
                system.debug('In linkAccountToExternalPaymentMethod');
                ZuoraBillingProfileCreationController.linkAccountToExternalPaymentMethod(accZuoraId, 'Cash', entityName);
            } else {
                return;
            }
        }

        NE__Billing_Profile__c billingProf = new NE__Billing_Profile__c(Id = billingProfId, XC_Status__c = 'Sent To Zuora');
        XC_BillingProfileLineItem__c billingProfLineItem = new XC_BillingProfileLineItem__c(Id = billingProfLineItemId, XC_Status__c = 'Sent To Zuora');
        List<Sobject> listObject = new List<Sobject>();
        listObject.add(billingProf);
        listObject.add(billingProfLineItem);
        XC_UTIL_Sobject.updateListRecords(listObject);
    }


    /**
     * RetrieveSohoBillingProfile.
     *
     * @param wrReq the wrapper request
     * @param wrResp the wrapper response
     * @param infos the infos map
     * @description method to retrieve the billing profile for Recharge Manager
     **/   
    public static void retrieveSohoBillingProfile(XC_REST_MobilityOrder_W.WrapperRequest wrReq, XC_REST_MobilityOrder_W.WrapperResponse wrResp, Map<String, String> infos) {

        /*Map<Id, Asset> assetMap = new Map<Id, Asset>([SELECT Id, XC_BillingProfileLineItem__c, XC_BillingProfileLineItem__r.XC_SoldToAddress__c, XC_BillingProfileLineItem__r.XC_BillToAddress__c,
                                                        XC_BillingProfileLineItem__r.XC_BillingProfile__c, XC_BillingProfileLineItem__r.XC_SoldToAddress__r.XC_AddressProvince__c, XC_Configuration_Item__r.XC_PaymentMethod__c
                                                        FROM Asset
                                                        WHERE XC_CompanyCode__c =: wrReq.Order.CompanyCode AND
                                                            XC_CostCenter__c =: wrReq.Order.CostCenter AND XC_BillingProfileLineItem__c != null]);
        if(assetMap.isEmpty()) {
            wrResp.Result.Message = 'ERROR. No Orders found with this CompanyCode e CostCenter';
            wrResp.Result.logError = 'ERROR. No Orders found with this CompanyCode e CostCenter';
            wrResp.Result.ErrorCode = '500';
            return;
        }*/

        List<NE__Product__c> prodList = new List<NE__Product__c>([SELECT Id, (SELECT ID, NE__FamilyId__r.XC_LIC_Family_Name__c FROM NE__ProductFamily__r WHERE NE__FamilyId__r.XC_LIC_Family_Name__c = :Label.XC_CL_Family_JNManager), 
                                                                    (SELECT Id, NE__ProdId__c, XC_BillingProfileLineItem__c, XC_BillingProfileLineItem__r.XC_SoldToAddress__c, XC_BillingProfileLineItem__r.XC_BillToAddress__c,
                                                                        XC_BillingProfileLineItem__r.XC_BillingProfile__c, XC_BillingProfileLineItem__r.XC_SoldToAddress__r.XC_AddressProvince__c,
                                                                        XC_Configuration_Item__r.XC_PaymentMethod__c, XC_Segment__c, NE__Order_Config__r.NE__OptyId__c, NE__Order_Config__r.NE__OptyId__r.XC_ActivationCountry__c
                                                                        FROM NE__Asset_Prod__r
                                                                        WHERE XC_CompanyCode__c =: wrReq.Order.CompanyCode AND XC_CostCenter__c =: wrReq.Order.CostCenter AND XC_BillingProfileLineItem__c != null
                                                                            AND NE__Order_Config__r.XC_EmobilityWebAppType__c != '' AND XC_LegalEntity__c =: wrReq.Order.LegalEntity AND NE__ProdId__r.XC_Product_Subtype__c =: Label.XC_CL_ProductSubtype_B2BTariff)
                                                                FROM NE__Product__c
                                                                WHERE Id IN (SELECT NE__ProdId__c
                                                                            FROM Asset
                                                                            WHERE XC_CompanyCode__c =: wrReq.Order.CompanyCode AND XC_CostCenter__c =: wrReq.Order.CostCenter AND XC_BillingProfileLineItem__c != null
                                                                                AND NE__Order_Config__r.XC_EmobilityWebAppType__c != '' AND XC_LegalEntity__c =: wrReq.Order.LegalEntity AND NE__ProdId__r.XC_Product_Subtype__c =: Label.XC_CL_ProductSubtype_B2BTariff)]);
        Asset a;
        Asset aPortal;
        for(NE__Product__c pr : prodList) {
            if(pr.NE__ProductFamily__r.isEmpty()) {
                a = pr.NE__Asset_Prod__r[0];
            } else {
                aPortal = pr.NE__Asset_Prod__r[0];
            }
        }
        a = (a == null) ? aPortal : a;

        if(a == null){
            wrResp.Result.Message = 'ERROR. No Orders found with this CompanyCode e CostCenter';
            wrResp.Result.logError = 'ERROR. No Orders found with this CompanyCode e CostCenter';
            wrResp.Result.ErrorCode = '500';
            return;
        }

        infos.put('XC_DeliveryAddress__c', a.XC_BillingProfileLineItem__r.XC_SoldToAddress__c);
        infos.put('XC_InstallationAddress__c', a.XC_BillingProfileLineItem__r.XC_SoldToAddress__c);
        infos.put('XC_OrderBillingAddress__c', a.XC_BillingProfileLineItem__r.XC_BillToAddress__c);
        infos.put('xcProvince', a.XC_BillingProfileLineItem__r.XC_SoldToAddress__r.XC_AddressProvince__c);
        infos.put('paymentMethod', a.XC_Configuration_Item__r.XC_PaymentMethod__c);
        infos.put('billingProfId', a.XC_BillingProfileLineItem__r.XC_BillingProfile__c);
        infos.put('billingProfLineItemId', a.XC_BillingProfileLineItem__c);
        infos.put('stream', a.XC_Segment__c);
        infos.put('activationCountry', a.NE__Order_Config__r.NE__OptyId__r.XC_ActivationCountry__c);
        infos.put('optyIdRM', a.NE__Order_Config__r.NE__OptyId__c);
    }
}