/**
 * The Class XC_REST_MobilityOrder_C.
 *
 * @author            : Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 12/03/2020
 * @date Modification : 
 * @description       : UTIL for XC_REST_MobilityOrder
 **/ 


public without sharing class XC_REST_MobilityOrder_C {


    /**
     * validateRequestCommodity.
     *
     * @param wr the wrapper request
     * @param mapHeader the map header
     * @return the wrapper result
     * @description method to verify if required parameters are correctly filled for Commodity
     */   
    public static XC_UTIL_Integration.WrapperResult validateRequestCommodity(XC_REST_MobilityOrder_W.WrapperRequest wr, Map<String,String> mapHeader){
        
        XC_UTIL_Integration.WrapperResult validateResult = XC_UTIL_RESTInbound.checkObjectPermission('NE__Order__c', 'create');
    
        if(validateResult.errorFlag){
            return validateResult; 
        }   
        
        validateResult = XC_UTIL_Integration.validateHeader(mapHeader);
        if(validateResult.errorFlag) {
            return validateResult; 
        }

        /*if(mapHeader.get('Functionality') != 'OrderManagement'){
            validateResult.errorMessage = 'Wrong Functionality value';
            validateResult.errorFlag = true;
            return validateResult;
        }*/

        validateResult = validateOrderCommodity(wr);
        if(validateResult.errorFlag) {
            return validateResult; 
        }

        validateResult = XC_REST_MobilityOrder_V.validateOrderItem(wr, 'POST');
        if(validateResult.errorFlag) {
            return validateResult;
        }

        return validateResult;
    }


    /**
     * ValidateOrderCommodity.
     *
     * @param wr the wrapper request
     * @return the wrapper result
     * @description method to verify if Order required parameters are correctly filled fro Commodity
     */   
    public static XC_UTIL_Integration.WrapperResult validateOrderCommodity(XC_REST_MobilityOrder_W.WrapperRequest wr){
        
        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

        if (wr.Order == null) {
            validateResult.errorMessage = 'Missing mandatory field: Order';
            validateResult.errorFlag = true;
            return validateResult; 
        }

        Map<String, String> requiredParameters = new Map<String, String>{'Channel' => wr.Order.Channel,
                                                                            'CommodityBillingCycleFrequency' => wr.Order.CommodityBillingCycleFrequency,
                                                                            'OrderType' => wr.Order.OrderType,
                                                                            //'DeactivationBasedOnRegulatory' => wr.Order.DeactivationBasedOnRegulatory,
                                                                            'AccountFiscalCode' => wr.Order.AccountFiscalCode,
                                                                            //'BillingProfileData' => wr.Order.BillingProfileData,
                                                                            'BillingAddressData' => wr.Order.BillingAddressData,
                                                                            'InstallationAddressData' => wr.Order.InstallationAddressData,
                                                                            'LegalEntity' => wr.Order.LegalEntity
                                                                        };
        for(String key : requiredParameters.keySet()) {
            if (String.isBlank(requiredParameters.get(key))) {
                validateResult.errorMessage = 'Missing mandatory field: Order.' + key;
                validateResult.errorFlag = true;
                return validateResult; 
            }
        }

        // check mandatory field for document section
        if(wr.Order.Document != null && !wr.Order.Document.isEmpty()){
            Integer i = 1;
            for(XC_REST_MobilityOrder_W.OrderDocumentWrapper externalDoc : wr.Order.Document){
                if(String.isBlank(externalDoc.ContractUrl)){
                    validateResult.errorMessage = 'Missing mandatory field: Order.Document.ContractUrl in ' + i + '-th Order.Document';
                    validateResult.errorFlag = true;
                    return validateResult; 
                }
                i++;
            }
        }


        //check order item discount size and mandatory fields
        if(wr.Order.OrderItemList[0].OrderItemDiscount != null && !wr.Order.OrderItemList[0].OrderItemDiscount.isEmpty()){
            if(wr.Order.OrderItemList[0].OrderItemDiscount.size() > 1){
                validateResult.errorMessage = 'Only one discount can be applied. Review Order.OrderItem.OrderItemDiscount.';
                validateResult.errorFlag = true;
                return validateResult; 
            }

            Map<String, String> requiredParametersDiscount = new Map<String, String>{'Code' => wr.Order.OrderItemList[0].OrderItemDiscount[0].Code,
                                                                                    'OneTimePrice' => String.valueOf(wr.Order.OrderItemList[0].OrderItemDiscount[0].OneTimePrice),
                                                                                    'OneTimeValue' => String.valueOf(wr.Order.OrderItemList[0].OrderItemDiscount[0].OneTimeValue),
                                                                                    'RecurringPrice' => String.valueOf(wr.Order.OrderItemList[0].OrderItemDiscount[0].RecurringPrice),
                                                                                    'RecurringValue' => String.valueOf(wr.Order.OrderItemList[0].OrderItemDiscount[0].RecurringValue),
                                                                                    'Status' => wr.Order.OrderItemList[0].OrderItemDiscount[0].Status,
                                                                                    'Type' => wr.Order.OrderItemList[0].OrderItemDiscount[0].Type
                                                                                };
            for(String key : requiredParametersDiscount.keySet()) {
                if(String.isBlank(requiredParametersDiscount.get(key))) {
                    validateResult.errorMessage = 'Missing mandatory field: Order.OrderItem.OrderItemDiscount.' + key;
                    validateResult.errorFlag = true;
                    return validateResult; 
                }
            }
        }


        return validateResult;
    }


    /**
     * ManageInsertCommodity.
     *
     * @param wrReq the wrapper request
     * @param wrResp the wrapper response
     * @param TransactionID the transactionID
     * @description method to manage insert for Commodity
     */
    public static void manageInsertCommodity(XC_REST_MobilityOrder_W.WrapperRequest wrReq, XC_REST_MobilityOrder_W.WrapperResponse wrResp, String transactionID) {
        
        Map<String, Object> objectMap = new Map<String, Object>();
        objectMap.put('TransactionID', transactionID);
        getAllCommodityRecords(wrReq, wrResp, objectMap);
        if(wrResp.Result.ErrorCode != '0') {
            return;
        }

        Account acc = (Account) objectMap.get('account');
        wrReq.Order.AccountID = acc.Id;
        wrReq.Order.BillingAddressID = (String) objectMap.get('billingAddressId');
        wrReq.Order.ShippingAddressID = (String) objectMap.get('installationAddressId');
        
        String productName = (String) objectMap.get('productName');

        Map<String, String> infos = XC_REST_MobilityOrder_U.createConfigurationInfoMap(wrReq.Order);
        
        infos.put('XC_LegalEntity__c', wrReq.Order.LegalEntity);
        infos.put('account', JSON.Serialize(objectMap.get('account')));
        infos.put('contactId', (String) objectMap.get('contactId'));
        infos.put('preferredlanguageofcontact', (String) objectMap.get('preferredlanguageofcontact'));
        infos.put('xcProvince', (String) objectMap.get('province'));
        infos.put('billingProfLineItemId', (String) objectMap.get('billingProfLineItemId'));
        infos.put('billingProfId', (String) objectMap.get('billingProfId'));
        infos.put('paymentMethod', (String) objectMap.get('paymentMethod'));
        infos.put('categoryId', (String) objectMap.get('categoryId'));
        infos.put('catalogId', (String) objectMap.get('catalogId'));
        infos.put('catalogItemId', (String) objectMap.get('catalogItemId'));
        infos.put('qty', String.valueOf(wrReq.Order.OrderItemList[0].Quantity));
        infos.put('familyPropertyIds', (String) objectMap.get('familyPropertyIds'));
        infos.put('ChannelCommodity', wrReq.Order.Channel);
        infos.put('PricingRegionCommodity', (String)objectMap.get('pricingRegion'));
        infos.put('OrderDocument',  (wrReq.Order.Document != null && !wrReq.Order.Document.isEmpty()) ? JSON.Serialize(wrReq.Order.Document, true) : '');
        infos.put('Discounts',  (wrReq.Order.OrderItemList[0].OrderItemDiscount != null && !wrReq.Order.OrderItemList[0].OrderItemDiscount.isEmpty()) ? JSON.Serialize(wrReq.Order.OrderItemList[0].OrderItemDiscount, true) : '');
        infos.put('AssetList', (!acc.Assets.isEmpty() ? JSON.Serialize(acc.Assets) : JSON.Serialize(new List<Asset>())));
        infos.put('commodityTransactionID', transactionID);
        infos.put('productCode', wrReq.Order.OrderItemList[0].EngineCode);
        infos.put('accountDNI',wrReq.Order.AccountFiscalCode.split('\\|')[1] );
        infos.put('clientSystem',  wrReq.Order.ClientSystem);
        infos.put('currencyISOCode', (String) objectMap.get('currencyISOCode'));
        wrReq.Order.ClientSystem = null;

       
        String productCategory = '';
        if(productName.containsIgnoreCase('LUZ')) {
            productCategory = Label.XC_CL_ServiciosDeLuz;
        } else if(productName.containsIgnoreCase('GAS')) {
            productCategory = Label.XC_CL_ServiciosDeGas;
        } else if(productName.containsIgnoreCase('Certificado')){
            productCategory = Label.XC_CL_CertificadoInstalacionElectrica;
        }else {
            productCategory = Label.XC_CL_OtherProducts; 
        }
        infos.put('productCategory', productCategory);
        infos.put('ChannelForOpp', 'Commodity Partner');
        infos.put('stream', acc.XC_Segment__c);

        XC_REST_MobilityOrder_W.createOpportunityForOrder(infos, wrReq.Order.LegalEntity);
        XC_REST_MobilityOrder_U.createOrderB2W(infos);

        wrResp.Result.Message = 'Operation completed successfully';
        wrResp.Result.ErrorCode = '0';
    }

    
    /**
     * GetAllCommodityRecords.
     *
     * @param wr the wrapper request
     * @param wrResp the wrapper response
     * @param objectMap the util map
     * @description method to get all records from Commodity request
     */   
    public static void getAllCommodityRecords(XC_REST_MobilityOrder_W.WrapperRequest wr, XC_REST_MobilityOrder_W.WrapperResponse wrResp, Map<String,Object> objectMap){

        List<String> docInfos = wr.Order.AccountFiscalCode.split('\\|');
        List<String> bpInfos = (String.isNotBlank(wr.Order.BillingProfileData)) ? wr.Order.BillingProfileData.split('\\|') : new List<String>{Label.XC_CL_Commodity_Bill};
        List<String> billingAddressInfos = wr.Order.BillingAddressData.split('\\|');
        List<String> installationAddressInfos = wr.Order.InstallationAddressData.split('\\|');

        if(/*(bpInfos[0] != Label.XC_CL_Commodity_Bill && bpInfos.size()<2) ||*/ docInfos.size()<2 || billingAddressInfos.size()<6 || installationAddressInfos.size()<6){
            wrResp.Result.Message = 'ERROR. Missing Mandatory fields. Review this fields: Order.AccountFiscalCode, Order.BillingProfileData, Order.BillingAddressData, Order.InstallationAddressData';
            wrResp.Result.logError = 'ERROR. Missing Mandatory fields. Review this fields: Order.AccountFiscalCode, Order.BillingProfileData, Order.BillingAddressData, Order.InstallationAddressData';
            wrResp.Result.ErrorCode = '400';
            return;
        }

        if(String.isBlank(billingAddressInfos[0])){
            billingAddressInfos[0]='Spain';
            String billingAddressReplace = wr.Order.BillingAddressData.replacefirst('|', 'Spain'); 
            wr.Order.BillingAddressData = billingAddressReplace;
        }
        if(String.isBlank(installationAddressInfos[0])){
            installationAddressInfos[0]='Spain';
            String installationAddressReplace = wr.Order.InstallationAddressData.replacefirst('|', 'Spain'); 
            wr.Order.InstallationAddressData = installationAddressReplace;
        }
        for(Integer j=1; j<6; j++){
            if(String.isBlank(billingAddressInfos[j])){
                wrResp.Result.Message = 'ERROR. Missing Mandatory fields. Review Order.BillingAddressData fields';
                wrResp.Result.logError = 'ERROR. Missing Mandatory fields. Review Order.BillingAddressData fields';
                wrResp.Result.ErrorCode = '464';
                return;
            }
            if(String.isBlank(installationAddressInfos[j])){
                wrResp.Result.Message = 'ERROR. Missing Mandatory fields. Review Order.InstallationAddressData fields';
                wrResp.Result.logError = 'ERROR. Missing Mandatory fields. Review Order.InstallationAddressData fields';
                wrResp.Result.ErrorCode = '464';
                return;
            }
        }

        Map<String,String> typeApiName = new Map<String,String>{Label.XC_CL_Credit_Card => 'NE__Card_Number__c',
                                                                Label.XC_CL_DirectDebt => 'NE__Iban__c',
                                                                Label.XC_CL_Commodity_Bill => 'XC_CommodityContractID__c'
                                                                };

        String docNumber = docInfos[1];
        String bpType = (String.isNotBlank(wr.Order.ContractCode)) ? Label.XC_CL_Commodity_Bill : bpInfos[0];
        if(!typeApiName.keySet().contains(bpType)) {
            bpType = (String.isNotBlank(wr.Order.ContractCode)) ? Label.XC_CL_Commodity_Bill : Label.XC_CL_DirectDebt;
        }
        String bpApiName = typeApiName.get(bpType);
        String bpNumber = (bpInfos.size() == 2 && String.isBlank(wr.Order.ContractCode)) ? bpInfos[1] : wr.Order.ContractCode;
        String iban = (bpInfos.size() == 2 && bpType == Label.XC_CL_Commodity_Bill) ? bpInfos[1] : '';

        
        if(String.isBlank(bpNumber)){
            wrResp.Result.Message = 'ERROR. Missing Mandatory fields: Order.ContractCode';
            wrResp.Result.logError = 'ERROR. Missing Mandatory fields: Order.ContractCode';
            wrResp.Result.ErrorCode = '400';
            return;
        }

        Pattern ibanPattern = Pattern.compile('[A-Z]{2,2}[0-9]{2,2}[a-zA-Z0-9]{1,30}');
        if(bpType == Label.XC_CL_DirectDebt){
            bpNumber = bpNumber.toUpperCase();
            Matcher bpNumberMatcher = ibanPattern.matcher(bpNumber);
            if(!bpNumberMatcher.matches()){
                wrResp.Result.Message = 'ERROR. Incorrect iban format';
                wrResp.Result.logError = 'ERROR. Incorrect iban format';
                wrResp.Result.ErrorCode = '465';
                return;
            }
        }

        Map<String,Object> utilAddressMap = new Map<String,Object>{'billingAddressInfos' => billingAddressInfos, 
                                                                    'installationAddressInfos' => installationAddressInfos
                                                                  };
        manageAddressDynamicString(utilAddressMap);
        String billingAddress = (String) utilAddressMap.get('billingAddress');
        String installationAddress = (String) utilAddressMap.get('installationAddress');
        System.debug('@@AFTER BillingAddress: ' + billingAddress);
        System.debug('@@AFTER InstallationAddress: ' + installationAddress);
        String status = Label.XC_CL_Asset_StatusActive;

        String query =  'SELECT Id, XC_Segment__c, XC_VatGroupType__c, XC_CompanyFiscalCode__c, XC_Country__c, XC_isGuestUser__c, XC_IsEmployee__c, PrimaryEmail__c, XC_AccountType__c , XC_DocumentCountry__c, XC_NIE_expedition_date__c, XC_NIE_expiration_date__c, ' + 
                        'IdentityNumber__c, IdentityType__c, Country__c,  XC_RecordTypePick__c, XC_FirstName__c, XC_LastName__c, Name, XC_SplitPayment__c, XC_RecordTypeDeveloperName__c, ' + 
                        '(SELECT Id, Email, XC_Preferredlanguageofcontact__c FROM Contacts WHERE XC_PrimaryContact__c = true), ' +
                        '(SELECT Id, XC_ExpirationDate__c, XC_DocumentType__c, XC_DocumentNumber__c, XC_ReleaseDate__c, XC_Country__c  FROM Personal_Documents__r  ORDER BY CreatedDate desc), '+ 
                        '(SELECT Id, Name, NE__Payment__c, XC_InvoicePreferredLanguage__c, XC_InvoiceDeliveryPref__c FROM NE__Billing_Profiles__r WHERE NE__Payment__c  =: bpType),'  +
                        '(SELECT Id, XC_AddressCountry__c, XC_City__c, XC_PostalCode__c, XC_StreetTypeText__c, XC_Address__c, XC_StreetNumber__c, XC_Floor__c, XC_Door__c, XC_AddressProvince__c, XC_PricinRegion__c FROM Addresses__r WHERE ( ' + billingAddress + ') OR (' + installationAddress + ' )), ' + 
                        '(SELECT XC_Address__c, XC_Product_Catalog_Category__c, NE__Bundle__c, NE__CatalogItem__r.NE__Catalog_Category_Name__c, NE__Catalog__c, NE__CatalogItem__c, XC_Coverage_Asset_Type__c, id, Name, NE__Description__c, NE__Parent_Order_Item__c, NE__ProdId__c, XC_Product_Type__c, XC_Product_Subtype__c, NE__Status__c, NE__UsageCode__c, NE__CatalogItem__r.NE__UsageCode__c  FROM Assets WHERE NE__Status__c =: status)' +
                        ' FROM Account';
        String filter1 = ' WHERE Id IN (SELECT XC_Account__c FROM XC_PersonalDocument__c WHERE XC_DocumentNumber__c =: docNumber AND XC_Account__c!= null) LIMIT 1';
        String filter2 = ' WHERE IdentityNumber__c =: docNumber LIMIT 1';

        String query1 = query + filter1;
        System.debug(LoggingLevel.FINEST, 'QUERY1: ' + query1);
        List<Account> listAcc = (List<Account>) Database.query(query1);

        if(listAcc.isEmpty()) {
            String query2 = query + filter2;
            System.debug(LoggingLevel.FINEST, 'QUERY2: ' + query2);
            listAcc = (List<Account>) Database.query(query2);
        }

        Map<Id, XC_CM_ClientSystemSetting__mdt> infosByClientSystem = new Map<Id, XC_CM_ClientSystemSetting__mdt> ([SELECT XC_CatalogLicName__c FROM XC_CM_ClientSystemSetting__mdt WHERE XC_ClientSystem__c  =: wr.Order.ClientSystem LIMIT 1]);
        if(infosByClientSystem == null || infosByClientSystem.isEmpty()){
            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.logError = 'INTERNAL ERROR: Client system not found';
            wrResp.Result.ErrorCode = '500';
            return;
        }


        Map<Id, NE__Catalog_Item__c> mapCatalogItem = new Map<Id, NE__Catalog_Item__c> ([SELECT Id, NE__Engine_Code__c, NE__Catalog_Id__c, NE__Catalog_Category_Name__c, XC_LIC_Catalog_Item_Name__c, NE__ProductId__c, CurrencyIsoCode
                                                                                         FROM NE__Catalog_Item__c 
                                                                                         WHERE NE__UsageCode__c =: wr.Order.OrderItemList[0].EngineCode AND NE__Visible__c = true AND NE__Type__c =: 'Product' AND NE__Catalog_Id__r.XC_LIC_Name__c =: infosByClientSystem.values()[0].XC_CatalogLicName__c ]);
        
        checkQueriedObjects(listAcc, mapCatalogItem, wrResp);
        if(wrResp.Result.ErrorCode == '400'){
            return;
        }
		
        utilAddressMap.put('addressList', listAcc[0].Addresses__r);
        utilAddressMap.put('accountId', listAcc[0].Id);
        utilAddressMap.put('recordTypeName', listAcc[0].XC_RecordTypeDeveloperName__c);
        utilAddressMap.put('foundBillingAddress', false);
        utilAddressMap.put('foundInstallationAddress', false);
        utilAddressMap.put('wrResp', wrResp);
        utilAddressMap.put('wrReq', wr);
        
        checkAddressInfo (utilAddressMap);
        if(!String.isBlank(wrResp.Result.ErrorCode) && wrResp.Result.ErrorCode != '0'){
            return;
        }
        


        Set<Id> bpIds = new Set<Id>();
        String bpId = '';
        String bpName = '';
        for(NE__Billing_Profile__c bp : listAcc[0].NE__Billing_Profiles__r) {
            bpIds.add(bp.Id);
            if(bp.Name.contains(bpNumber)) {
                bpId = bp.Id;
                bpName = bp.Name;
            }
        }
    
        Map<Id, XC_BillingProfileLineItem__c> mapBpli = new Map<Id, XC_BillingProfileLineItem__c>([SELECT Id, XC_LegalEntity__c, XC_SoldToAddress__c, XC_BillToAddress__c, XC_BillToContactId__c,
                                                                                                    XC_SoldToContactId__c, XC_BillingProfile__c, XC_BillingProfile__r.NE__Payment__c, XC_BillingProfile__r.XC_MandateType__c,
                                                                                                    XC_BillingProfile__r.XC_InvoicePreferredLanguage__c, XC_Status__c, XC_BillingProfile__r.NE__Card_Number__c,
                                                                                                    XC_BillingProfile__r.NE__Iban__c, XC_BillingProfile__r.XC_InvoiceDeliveryPref__c, XC_BillingProfile__r.XC_CommodityContractID__c
                                                                                                   FROM XC_BillingProfileLineItem__c 
                                                                                                   WHERE XC_BillToAddress__c =: (String)utilAddressMap.get('billingAddressId')
                                                                                                   AND XC_SoldToAddress__c =: (String)utilAddressMap.get('installationAddressId')
                                                                                                   AND XC_BillingProfile__c IN: bpIds
                                                                                                   AND XC_LegalEntity__c =: wr.Order.LegalEntity
                                                                                                   ORDER BY CreatedDate desc]);
                                                                                                  

        Map<String, Object> utilCheckMap = new  Map<String, Object>{'bpType' => bpType,
                                                                    'bpNumber' => bpNumber,
                                                                    'bpApiName' => bpApiName,
                                                                    'bpAccount' => listAcc[0],
                                                                    'contact' => listAcc[0].Contacts[0],
                                                                    'billingAddressId' => utilAddressMap.get('billingAddressId'),
                                                                    'installationAddressId' => utilAddressMap.get('installationAddressId'),
                                                                    'legalEntity' => wr.Order.LegalEntity,
                                                                    'bpId' => bpId,
                                                                    'bpName' => bpName,
                                                                    'bpliList' => mapBpli.values(),
                                                                    'iban' => iban,
                                                                    'commodityBillingCycleFrequency' => wr.Order.CommodityBillingCycleFrequency,
                                                                    'TransactionID' => objectMap.get('TransactionID')};
        checkAndUpdateBillingProfile(utilCheckMap, wrResp);
        if(wrResp.Result.ErrorCode != '0'){
            return;
        }

        //check discount code
        if(wr.Order.OrderItemList[0].OrderItemDiscount != null && !wr.Order.OrderItemList[0].OrderItemDiscount.isEmpty()){
            checkDiscountValue(wr, wrResp);
            if(wrResp.Result.ErrorCode == '400'){
                return;
            }
        }

        XC_BillingProfileLineItem__c bpliToManage = (XC_BillingProfileLineItem__c)utilCheckMap.get('bpliToManage');

        objectMap.put('account', listAcc[0]);
        objectMap.put('contactId', listAcc[0].Contacts[0].Id);
        objectMap.put('billingProfLineItemId', bpliToManage.Id);
        objectMap.put('billingProfId', bpliToManage.XC_BillingProfile__c);
        objectMap.put('paymentMethod', bpliToManage.XC_BillingProfile__r.NE__Payment__c);
        objectMap.put('catalogItemId', mapCatalogItem.values()[0].Id);
        objectMap.put('productId', mapCatalogItem.values()[0].NE__ProductId__c);
        objectMap.put('catalogId', mapCatalogItem.values()[0].NE__Catalog_Id__c); 
        objectMap.put('engineCode', mapCatalogItem.values()[0].NE__Engine_Code__c);
        objectMap.put('categoryId', mapCatalogItem.values()[0].NE__Catalog_Category_Name__c);
        objectMap.put('productName', mapCatalogItem.values()[0].XC_LIC_Catalog_Item_Name__c);
        objectMap.put('province', (String) utilAddressMap.get('province'));
        objectMap.put('pricingRegion', (String) utilAddressMap.get('pricingRegion'));
        objectMap.put('billingAddressId', (String) utilAddressMap.get('billingAddressId'));
        objectMap.put('installationAddressId', (String) utilAddressMap.get('installationAddressId'));
        objectMap.put('preferredlanguageofcontact', listAcc[0].Contacts[0].XC_Preferredlanguageofcontact__c);
        objectMap.put('currencyISOCode',  mapCatalogItem.values()[0].CurrencyIsoCode);
        getProductFamilyPropertyInfos(wr, objectMap);
        System.debug(LoggingLevel.FINEST, '@@@objectMap -> ' + objectMap);

        wrResp.Result.Message = 'Operation completed successfully';
        wrResp.Result.ErrorCode = '0';

    }

    
    /**
     * checkDiscountValue.
     *
     * @param wr the wrapper request
     * @param wrResp the wrapper response
     * @description method to check if the discount code exists in XC_CM_DiscountMapping__mdt
     */ 
    public static void checkDiscountValue(XC_REST_MobilityOrder_W.WrapperRequest wr, XC_REST_MobilityOrder_W.WrapperResponse wrResp){
        
       Map<Id, XC_CM_DiscountMapping__mdt> mapDiscount = new Map<Id, XC_CM_DiscountMapping__mdt>([SELECT Id, XC_DiscountPeriod__c FROM XC_CM_DiscountMapping__mdt WHERE XC_DiscountCode__c =: wr.Order.OrderItemList[0].OrderItemDiscount[0].Code]);
        if(mapDiscount.isEmpty()){
            wrResp.Result.Message = 'ERROR. Wrong value. Review Order.OrderItem.OrderItemDiscount.Code';
            wrResp.Result.logError = 'ERROR. Wrong value. Review Order.OrderItem.OrderItemDiscount.Code';
            wrResp.Result.ErrorCode = '400';
            return;
        }else{
            wr.Order.OrderItemList[0].OrderItemDiscount[0].Code = mapDiscount.values()[0].XC_DiscountPeriod__c;
        }
    }


    /**
     * checkAddressInfo.
     *
     * @param utilAddressMap the util address map
     * @description method to check if the address exists or it is necessary to create a new 
     */ 
    public static void checkAddressInfo(Map<String,Object> utilAddressMap){
        
        List<XC_Address__c> addressList = (List<XC_Address__c>) utilAddressMap.get('addressList');
        List<String> billingAddressInfos = (List<String>) utilAddressMap.get('billingAddressInfos');
        List<String> installationAddressInfos = (List<String>) utilAddressMap.get('installationAddressInfos');
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) utilAddressMap.get('wrResp');
        
        if(addressList.isEmpty()){
            if(String.isBlank(billingAddressInfos[1]) || String.isBlank(installationAddressInfos[1])){
                wrResp.Result.Message = 'ERROR. Missing Mandatory field: Province';
                wrResp.Result.logError = 'ERROR. Missing Mandatory field: Province';
                wrResp.Result.ErrorCode = '400';
                return;
            }
            createNewAddress(utilAddressMap);
        }else{
            getAddressIds(utilAddressMap);  
        }
    }


    /**
     * ManageAddressDynamicString.
     *
     * @param utilAddressMap the util address map
     * @description method to create dynamic string with address informations
     */   
    public static void manageAddressDynamicString(Map<String,Object> utilAddressMap){

        List<String> billingAddressInfos = (List<String>) utilAddressMap.get('billingAddressInfos');
        List<String> installationAddressInfos = (List<String>) utilAddressMap.get('installationAddressInfos');

        List<String> apiAddress = new List<String> {'XC_AddressCountry__c', 'XC_AddressProvince__c', 'XC_City__c', 'XC_PostalCode__c', 'XC_StreetTypeText__c', 'XC_Address__c', 'XC_StreetNumber__c', 'XC_Floor__c', 'XC_Door__c'};
		//List<String> apiAddress = new List<String> {'XC_City__c', 'XC_PostalCode__c', 'XC_Address__c', 'XC_StreetNumber__c', 'XC_Floor__c', 'XC_Door__c'};
        
        String billingAddress = 'XC_AddressCountry__c = ' + '\'' + String.escapeSingleQuotes(billingAddressInfos[0]) + '\'';
        for (Integer i = 1; i<billingAddressInfos.size(); i++){
            if(!String.isBlank(billingAddressInfos[i])){
                billingAddress = billingAddress + ' AND ' + apiAddress[i] + '=' + '\'' + String.escapeSingleQuotes(billingAddressInfos[i]) + '\'';
            }
        }
        utilAddressMap.put('billingAddress', billingAddress);
        System.debug('BillingAddress: ' + billingAddress);

        String installationAddress = 'XC_AddressCountry__c = ' + '\'' + String.escapeSingleQuotes(installationAddressInfos[0]) + '\'';
        for(Integer i = 1; i<installationAddressInfos.size(); i++){
            if(!String.isBlank(installationAddressInfos[i])){
                installationAddress = installationAddress + ' AND ' + apiAddress[i] + '=' + '\'' + String.escapeSingleQuotes(installationAddressInfos[i]) + '\'';
            }
        }
        utilAddressMap.put('installationAddress', installationAddress);
        System.debug('InstallationAddress: ' + installationAddress);
    }


    /**
     * GetAddressIds.
     *
     * @param utilAddressMap the util address map
     * @description method to get address ids
     */   
    public static void getAddressIds(Map<String,Object> utilAddressMap){

        List<XC_Address__c> addressList = (List<XC_Address__c>) utilAddressMap.get('addressList');
        List<String> billingAddressInfos = (List<String>) utilAddressMap.get('billingAddressInfos');
        List<String> installationAddressInfos = (List<String>) utilAddressMap.get('installationAddressInfos');
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) utilAddressMap.get('wrResp');
        
        List<String> apiAddress = new List<String> {'XC_AddressCountry__c', 'XC_AddressProvince__c', 'XC_City__c', 'XC_PostalCode__c', 'XC_StreetTypeText__c', 'XC_Address__c', 'XC_StreetNumber__c', 'XC_Floor__c', 'XC_Door__c'};
        utilAddressMap.put('apiAddress', apiAddress);
   

        for(XC_Address__c addr: addressList){

            findAddress(utilAddressMap, addr);

            if((Boolean)utilAddressMap.get('foundBillingAddress') && utilAddressMap.get('billingAddressId') == null){
                utilAddressMap.put('billingAddressId', addr.id);
            }
            if((Boolean)utilAddressMap.get('foundInstallationAddress') && utilAddressMap.get('installationAddressId') == null){
                utilAddressMap.put('installationAddressId', addr.id);
                utilAddressMap.put('province', addr.XC_AddressProvince__c);
                utilAddressMap.put('pricingRegion', addr.XC_PricinRegion__c);
            }

            if((Boolean)utilAddressMap.get('foundBillingAddress') && (Boolean)utilAddressMap.get('foundInstallationAddress')){
                break;
            }
            
        }

        //check if necessary to create a new address
        if(!(Boolean)utilAddressMap.get('foundBillingAddress') || !(Boolean)utilAddressMap.get('foundInstallationAddress')){
            if((!(Boolean)utilAddressMap.get('foundBillingAddress') && String.isBlank(billingAddressInfos[1])) || (!(Boolean)utilAddressMap.get('foundInstallationAddress') && String.isBlank(installationAddressInfos[1]))){
                wrResp.Result.Message = 'ERROR. Missing Mandatory fields: Province';
                wrResp.Result.logError = 'ERROR. Missing Mandatory fields: Province';
                wrResp.Result.ErrorCode = '400';
                return;
            }
            createNewAddress(utilAddressMap);
        }
    }


    /**
     * findAddress.
     *
     * @param utilAddressMap the util address map
     * @param addr the address
     * @description method to find address
     */  
    public static void findAddress(Map<String,Object> utilAddressMap, XC_Address__c addr){

        List<String> billingAddressInfos = (List<String>) utilAddressMap.get('billingAddressInfos');
        List<String> installationAddressInfos = (List<String>) utilAddressMap.get('installationAddressInfos');
        List<String> apiAddress = (List<String>) utilAddressMap.get('apiAddress');
        Boolean foundBillingAddress = (Boolean) utilAddressMap.get('foundBillingAddress');
        Boolean foundInstallationAddress = (Boolean) utilAddressMap.get('foundInstallationAddress');


        if(!foundBillingAddress){
            for(Integer i = 0; i<billingAddressInfos.size(); i++){
                if(!String.isBlank(billingAddressInfos[i])){
                    if(addr.get(apiAddress[i]) == billingAddressInfos[i]){
                        foundBillingAddress = true; 
                    }else{
                        foundBillingAddress = false;
                        break;
                    }
                }
            }
        }
        
        if(!foundInstallationAddress){
            for(Integer j = 0; j<installationAddressInfos.size(); j++){
                if(!String.isBlank(installationAddressInfos[j])){
                    if(addr.get(apiAddress[j]) == installationAddressInfos[j]){
                        foundInstallationAddress = true;
                    }else{
                        foundInstallationAddress = false;
                        break;
                    }
                }
            }
        }

        utilAddressMap.put('foundBillingAddress', foundBillingAddress);
        utilAddressMap.put('foundInstallationAddress', foundInstallationAddress);

    }


    /**
    * checkQueriedObjects.
    *
    * @param listAcc the account list 
    * @param mapCatalogItem the map with catalog item id as key and catalog item as value
    * @param wrResp the wrapper response
    * @description method to check if queried object are founded 
    */   
    public static void checkQueriedObjects(List<Account> listAcc, Map<Id, NE__Catalog_Item__c> mapCatalogItem, XC_REST_MobilityOrder_W.WrapperResponse wrResp){

        if(listAcc.isEmpty()){
            wrResp.Result.Message = 'ERROR. Account ' + Label.XC_CL_NotFount;
            wrResp.Result.logError = 'ERROR. Account ' + Label.XC_CL_NotFount;
            wrResp.Result.ErrorCode = '400';
            return;
        }

        if(mapCatalogItem.isEmpty()){
            wrResp.Result.Message = 'ERROR. CatalogItemID ' + Label.XC_CL_NotFount;
            wrResp.Result.logError = 'ERROR. CatalogItemID ' + Label.XC_CL_NotFount;
            wrResp.Result.ErrorCode = '400';
            return;
        }
      
    }


    /**
     * getProductFamilyPropertyInfos.
     *
     * @param wrReq the wrapper request
     * @param objectMap the util map 
     * @description get product family property infos
     */
    public static void getProductFamilyPropertyInfos(XC_REST_MobilityOrder_W.WrapperRequest wrReq, Map<String,Object> objectMap){     

        Map<String,String> mapPfpIaValue = new Map<String,String>();
        String productId = (String)objectMap.get('productId');
        String productName = (String)objectMap.get('productName');

        if(wrReq.Order.OrderItemList[0].Attribute == null) {
            wrReq.Order.OrderItemList[0].Attribute = new List<XC_REST_MobilityOrder_W.WrapperAttribute>();
        }

        Boolean checkRegion = false;
        Boolean checkPayment = false;
        Set<String> attrNameList = new Set<String>();
        for(XC_REST_MobilityOrder_W.WrapperAttribute  wrAttr : wrReq.Order.OrderItemList[0].Attribute) {
            String attrName = (wrAttr.name == 'Billing Frecuency' || wrAttr.name == 'Billing Frequency') ? '%Payment%' : '%' + wrAttr.name + '%';
            attrNameList.add(attrName);

            checkRegion = (attrName.containsIgnoreCase('Region') || checkRegion) ? true : false;
            checkPayment = (attrName.containsIgnoreCase('Payment') || checkPayment) ? true : false;
        }

        if(!checkRegion) {
            XC_REST_MobilityOrder_W.WrapperAttribute attrRegion = new XC_REST_MobilityOrder_W.WrapperAttribute();
            attrRegion.Name = 'Region';
            attrRegion.Value = (String)objectMap.get('pricingRegion');
            wrReq.Order.OrderItemList[0].Attribute.add(attrRegion);
            attrNameList.add('%Region%');
        }
        if(!checkPayment) {
            
           /*Map<String,String> valueName = new Map<String,String>{	'Mensual' => Label.XC_CL_PaymentModel_Monthly, // check if mashery sends correctly values
                                                                    'Bimestral' => Label.XC_CL_PaymentModel_Monthly,
                                                                    'Anual' => Label.XC_CL_PaymentModel_Annual
                                                                    };*/
                                                                    
            XC_REST_MobilityOrder_W.WrapperAttribute attrPayment = new XC_REST_MobilityOrder_W.WrapperAttribute();
            attrPayment.Name = 'Billing Frequency';
            //attrPayment.Value = (valueName.get(wrReq.Order.CommodityBillingCycleFrequency) != null) ? valueName.get(wrReq.Order.CommodityBillingCycleFrequency) : wrReq.Order.CommodityBillingCycleFrequency;
            //attrPayment.Value = (attrPayment.Value == 'Bimonthly') ? Label.XC_CL_PaymentModel_Monthly : attrPayment.Value; // value from commodity
            attrPayment.Value = (wrReq.Order.CommodityBillingCycleFrequency == 'Bimonthly') ? Label.XC_CL_PaymentModel_Monthly : wrReq.Order.CommodityBillingCycleFrequency; // value from commodity
            attrPayment.Value = (productName.containsIgnoreCase('Certificado')) ? 'One shot' : attrPayment.Value;
            wrReq.Order.OrderItemList[0].Attribute.add(attrPayment);
            attrNameList.add('%Payment%');
        }   


        System.debug(LoggingLevel.FINEST, '@@@NM attribute: ' + wrReq.Order.OrderItemList[0].Attribute);
        System.debug(LoggingLevel.FINEST, '@@@NM attrNameList: ' + attrNameList);
        Map<Id,NE__Family__c> mapProdfam = new Map<Id,NE__Family__c>([SELECT Id, (SELECT id, NE__ProdId__c  FROM NE__ProductFamily__r WHERE NE__ProdId__c =: productId),
                                                                        (SELECT Id, NE__PropId__r.XC_LIC_DynamicPropertyDefinition__c, NE__FamilyPropertyCode__c FROM NE__ProductFamilyProperties__r WHERE NE__PropId__r.XC_LIC_DynamicPropertyDefinition__c LIKE: attrNameList)
                                                                    FROM NE__Family__c
                                                                    WHERE Id IN (SELECT NE__FamilyId__c FROM NE__ProductFamilyProperty__c WHERE NE__PropId__r.XC_LIC_DynamicPropertyDefinition__c LIKE : attrNameList) 
                                                                        AND Id IN (SELECT NE__FamilyId__c FROM NE__ProductFamily__c WHERE NE__ProdId__c =: productId)]);

        if(!mapProdfam.isEmpty()){
            for(XC_REST_MobilityOrder_W.WrapperAttribute  wrAttr : wrReq.Order.OrderItemList[0].Attribute){
                getPfpInfos(mapProdfam.values()[0].NE__ProductFamilyProperties__r, wrAttr, mapPfpIaValue);
            }

            if(!mapPfpIaValue.isEmpty()) {
                objectMap.put('familyPropertyIds', JSON.serialize(mapPfpIaValue));
            }
        }


        /*if(wrReq.Order.OrderItem.Attribute != null && !wrReq.Order.OrderItem.Attribute.isEmpty()){
            Set<String> attrNameList = new Set<String>();
            for(XC_REST_MobilityOrder_W.WrapperAttribute  wrAttr : wrReq.Order.OrderItem.Attribute){
                String attrName = (wrAttr.name == 'Billing Frecuency' || wrAttr.name == 'Billing Frequency') ? '%Payment%' : '%' + wrAttr.name + '%';
                attrNameList.add(attrName);
            }
                                                                                                            
            Map<Id,NE__Family__c> mapProdfam = new Map<Id,NE__Family__c>([SELECT Id,
                                                                        (SELECT Id, NE__PropId__r.XC_LIC_DynamicPropertyDefinition__c, NE__FamilyPropertyCode__c FROM NE__ProductFamilyProperties__r WHERE NE__PropId__r.XC_LIC_DynamicPropertyDefinition__c LIKE: attrNameList), 
                                                                        (SELECT id, NE__ProdId__c  FROM NE__ProductFamily__r WHERE NE__ProdId__c =: productId) 
                                                                        FROM NE__Family__c WHERE 
                                                                        Id IN (SELECT NE__FamilyId__c FROM NE__ProductFamilyProperty__c WHERE NE__PropId__r.XC_LIC_DynamicPropertyDefinition__c LIKE : attrNameList) 
                                                                        AND Id IN (SELECT NE__FamilyId__c FROM NE__ProductFamily__c WHERE NE__ProdId__c =: productId)]);

            if(!mapProdfam.isEmpty()){
                for(XC_REST_MobilityOrder_W.WrapperAttribute  wrAttr : wrReq.Order.OrderItem.Attribute){
                    getPfpInfos(mapProdfam.values()[0].NE__ProductFamilyProperties__r, wrAttr, mapPfpIaValue);
                }

                if(!mapPfpIaValue.isEmpty()) {
                    objectMap.put('familyPropertyIds', JSON.serialize(mapPfpIaValue));
                }
            }
        }*/ 
    }
    

    /**
     * getPfpInfos.
     *
     * @param pfpList the product family property id
     * @param wrAttr the wrapper item attribute
     * @param mapPfpIaValue the map with pfp as id and itemAttribute.value as value
     * @description get product family property infos
    */
    public static void getPfpInfos(List<NE__ProductFamilyProperty__c> pfpList, XC_REST_MobilityOrder_W.WrapperAttribute  wrAttr, Map<String,String> mapPfpIaValue){
        for(NE__ProductFamilyProperty__c pfp: pfpList){
            if(((wrAttr.Name == 'Billing Frecuency' || wrAttr.Name == 'Billing Frequency') &&  pfp.NE__FamilyPropertyCode__c.containsIgnoreCase('Payment Method')) || pfp.NE__FamilyPropertyCode__c.contains(wrAttr.Name)){
                String value = (wrAttr.value.containsIgnoreCase('Yearly')) ? Label.XC_CL_PaymentModel_Annual : wrAttr.value;
                mapPfpIaValue.put(pfp.Id, value);
                break;
            }
        }
    }


    /**
     * checkAndUpdateBillingProfile.
     *
     * @param utilCheckMap the util check map
     * @description method to check billing profile and activate it, if it is necessary and it is a commodity bill 
     */   
    public static void checkAndUpdateBillingProfile(Map<String,Object> utilCheckMap, XC_REST_MobilityOrder_W.WrapperResponse wrResp){

        String bpType = (String)utilCheckMap.get('bpType');
        String bpNumber = (String)utilCheckMap.get('bpNumber');
        String bpApiName = (String)utilCheckMap.get('bpApiName');
        Account bpAccount = (Account)utilCheckMap.get('bpAccount');
        String legalEntity = (String)utilCheckMap.get('legalEntity');
        List<XC_BillingProfileLineItem__c> bpliList = (List<XC_BillingProfileLineItem__c>)utilCheckMap.get('bpliList');

        XC_BillingProfileLineItem__c bpliToManage;
        NE__Billing_Profile__c bpToUpdate;
        Boolean callZuora = false;
        Boolean isBpToUpdate = false; 

        // frequency values mapping
        Map<String,String> frequencyValue = new Map<String,String>{	Label.XC_CL_PaymentModel_Monthly => '01', 
                                                                    'Bimonthly' => '02',
                                                                    Label.XC_CL_PaymentModel_Annual => 'A'
                                                                };  
        
        utilCheckMap.put('frequencyValue', frequencyValue);


        for(XC_BillingProfileLineItem__c bpli : bpliList){
                                                                                                  
            Map<String, String> apiNameMap = new  Map<String, String>{  'NE__Card_Number__c' => bpli.XC_BillingProfile__r.NE__Card_Number__c, 
                                                                        'NE__Iban__c' => bpli.XC_BillingProfile__r.NE__Iban__c,
                                                                        'XC_CommodityContractID__c' => bpli.XC_BillingProfile__r.XC_CommodityContractID__c };

            if(apiNameMap.get(bpApiName) == bpNumber){
                callZuora = (bpli.XC_Status__c != 'Active' && bpli.XC_Status__c != 'Sent To Zuora'/* && bpType == 'Commodity Bill'*/) ? true : false;
                bpliToManage = bpli;
                isBpToUpdate = false; 
                break;

            }else if(/*bpType == 'Commodity Bill' &&*/ !isBpToUpdate && String.isBlank(apiNameMap.get(bpApiName))){

                callZuora = true;
                isBpToUpdate = true;
                bpliToManage = bpli; 
                String totalName = ZuoraBillingProfileCreationController.billingName(bpType, bpNumber);
                bpToUpdate = new NE__Billing_Profile__c(Id = bpli.XC_BillingProfile__c, XC_CommodityContractID__c = bpNumber, Name = totalName);
            
            }
        }        

        if(bpliToManage == null){
            bpliToManage = createBillingProfile(utilCheckMap, wrResp);
            if(wrResp.Result.ErrorCode != '0') {
                return;
            }
            callZuora = true;
        }  

        utilCheckMap.put('bpliToManage', bpliToManage);  

        if(isBpToUpdate){
            XC_UTIL_SObject.updateRecord(bpToUpdate);
        }              

        if(callZuora){                 
            prepareInfosAndCallZuora(utilCheckMap);
        }  

        wrResp.Result.ErrorCode = '0';
    }


    /**
     * createBillingProfile.
     *
     * @param utilCheckMap the util check map
     * @description method to check billing profile and activate it, if it is necessary and it is a commodity bill 
    */   
    public static XC_BillingProfileLineItem__c createBillingProfile(Map<String,Object> utilCheckMap, XC_REST_MobilityOrder_W.WrapperResponse wrResp){

        String bpType = (String) utilCheckMap.get('bpType');
        String bpNumber = (String) utilCheckMap.get('bpNumber');
        String bpApiName = (String) utilCheckMap.get('bpApiName');
        Account bpAccount = (Account) utilCheckMap.get('bpAccount');
        Contact con = (Contact) utilCheckMap.get('contact');
        String billingAddressId = (String) utilCheckMap.get('billingAddressId');
        String installationAddressId = (String) utilCheckMap.get('installationAddressId');
        String legalEntity = (String) utilCheckMap.get('legalEntity');
        String bpId = (String) utilCheckMap.get('bpId');
        String bpName = (String) utilCheckMap.get('bpName');
        String iban = (String) utilCheckMap.get('iban');
        Map<String,String> frequencyValue =  (Map<String,String>)utilCheckMap.get('frequencyValue');
        String commodityBillingCycleFrequency =  (String) utilCheckMap.get('commodityBillingCycleFrequency');
        List<XC_BillingProfileLineItem__c> bpliList = (List<XC_BillingProfileLineItem__c>)utilCheckMap.get('bpliList');

        String invoiceDeliveryPreference = '';
        String invoicePreferredLanguage = '';
        if(String.isBlank(bpId)) {
            NE__Billing_Profile__c bpToInsert = new NE__Billing_Profile__c( Name = ZuoraBillingProfileCreationController.billingName(bpType, bpNumber),
                                                                            NE__Payment__c = bpType,
                                                                            NE__Account__c = bpAccount.Id,
                                                                            XC_MandateType__c = 'RECURRENT',
                                                                            XC_Status__c = 'Draft',
                                                                            NE__Iban__c = iban, 
                                                                            XC_LegalEntity__c = (bpType == Label.XC_CL_DirectDebt || bpType == Label.XC_CL_Commodity_Bill) ? legalEntity : '',
                                                                            XC_CommodityBillingCycleFrequency__c = (bpType == Label.XC_CL_Commodity_Bill && frequencyValue.get(commodityBillingCycleFrequency)!= null) ? frequencyValue.get(commodityBillingCycleFrequency) : '',
                                                                            XC_InvoiceDeliveryPref__c = (String.isNotBlank(con.Email)) ? 'Email' : 'Print',
                                                                            XC_InvoicePreferredLanguage__c = (String.isNotBlank(con.XC_Preferredlanguageofcontact__c)) ? con.XC_Preferredlanguageofcontact__c : 'Spanish');
            bpToInsert.put(bpApiName, bpNumber);

            System.debug(LoggingLevel.FINEST, '@@@NM bpToInsert: ' + bpToInsert);
            XC_UTIL_SObject.WrapperResult resultInsertBP = XC_UTIL_SObject.insertRecord(bpToInsert);
            if(!resultInsertBP.success) {
                wrResp.Result.Message = 'INTERNAL ERROR';
                wrResp.Result.logError = 'Error in CreateBP: ' + resultInsertBP.errorMessage;
                wrResp.Result.ErrorCode = '500';
                return null;
            }
            bpId = bpToInsert.Id;
            bpName = bpToInsert.Name;

            invoiceDeliveryPreference = bpToInsert.XC_InvoiceDeliveryPref__c;
            invoicePreferredLanguage = bpToInsert.XC_InvoicePreferredLanguage__c;
        }
        
        // manage delivery and language
        if(String.isBlank(invoiceDeliveryPreference)){
            for(NE__Billing_Profile__c bp : bpAccount.NE__Billing_Profiles__r){
                if(bp.id == bpId){
                    invoiceDeliveryPreference = bp.XC_InvoiceDeliveryPref__c;
                    invoicePreferredLanguage = bp.XC_InvoicePreferredLanguage__c;
                    break;
                }
            }
        }
        

        XC_BillingProfileLineItem__c bpliToInsert = new XC_BillingProfileLineItem__c(   XC_BillingProfile__c = bpId, 
                                                                                        XC_BillToAddress__c = billingAddressId,
                                                                                        XC_BillingAddressCopy__c = billingAddressId,
                                                                                        XC_SoldToAddress__c = installationAddressId, 
                                                                                        XC_SoldToAddressCopy__c = installationAddressId,
                                                                                        XC_BillToContactId__c = con.Id,
                                                                                        XC_SoldToContactId__c = con.Id,
                                                                                        XC_BillingProfileName__c = bpName,
                                                                                        XC_LegalEntity__c = legalEntity,
                                                                                        XC_InvoiceDeliveryPreference__c = (!String.isblank(invoiceDeliveryPreference) && invoiceDeliveryPreference.containsIgnoreCase('Smart')) ? Label.XC_CL_BpliInvoiceDeliveryPref : invoiceDeliveryPreference, 
                                                                                        XC_InvoicePreferredLanguage__c = invoicePreferredLanguage,
                                                                                        XC_Status__c = 'Draft');

        // set invoiceDeliveryPrefsPrint to true if the contact missing the email
        if(!String.isBlank(bpliToInsert.XC_InvoiceDeliveryPreference__c) && (bpliToInsert.XC_InvoiceDeliveryPreference__c.equalsIgnoreCase(Label.XC_CL_BpliInvoiceDeliveryPref)
            || bpliToInsert.XC_InvoiceDeliveryPreference__c.equalsIgnoreCase('Email')) &&  String.isBlank(con.Email)){
                bpliToInsert.XC_InvoiceDeliveryPreference__c = 'Print';
        }


        System.debug(LoggingLevel.FINEST, '@@@NM bpliToInsert: ' + bpliToInsert);
        XC_UTIL_SObject.WrapperResult resultInsertBPLI = XC_UTIL_SObject.insertRecord(bpliToInsert);
        if(!resultInsertBPLI.success) {
            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.logError = 'Error in CreateBPLI: ' + resultInsertBPLI.errorMessage;
            wrResp.Result.ErrorCode = '500';
            return null;
        }

        wrResp.Result.ErrorCode = '0';
        return [SELECT Id, XC_LegalEntity__c, XC_SoldToAddress__c, XC_BillToAddress__c, XC_BillToContactId__c, XC_SoldToContactId__c, XC_BillingProfile__c,
                    XC_BillingProfile__r.NE__Payment__c, XC_BillingProfile__r.XC_InvoicePreferredLanguage__c, XC_Status__c, XC_BillingProfile__r.NE__Card_Number__c,
                    XC_BillingProfile__r.NE__Iban__c, XC_BillingProfile__r.XC_InvoiceDeliveryPref__c, XC_BillingProfile__r.XC_CommodityContractID__c, XC_BillingProfile__r.XC_MandateType__c,
                    XC_InvoiceDeliveryPreference__c
                FROM XC_BillingProfileLineItem__c 
                WHERE Id =: bpliToInsert.Id];
    }


    /**
     * prepareInfosAndCallZuora.
     *
     * @param utilCheckMap the util map
     * @description prepare infos to create a Billing Account and call Zuora
    */
    public static void prepareInfosAndCallZuora(Map<String,Object> utilCheckMap){

        String bpNumber = (String) utilCheckMap.get('bpNumber');
        Account bpAccount = (Account) utilCheckMap.get('bpAccount');
        String legalEntity = (String) utilCheckMap.get('legalEntity');
        String transactionID = (String) utilCheckMap.get('TransactionID');
        String commodityBillingCycleFrequency =  (String) utilCheckMap.get('commodityBillingCycleFrequency');
        XC_BillingProfileLineItem__c billingProfileLineItem = (XC_BillingProfileLineItem__c) utilCheckMap.get('bpliToManage');
        Map<String,String> frequencyValue = (Map<String,String>)utilCheckMap.get('frequencyValue');
        
        Map<String, Object> mapAccountDocument = new Map<String,Object>{'legalEntity' => legalEntity,'bpAccount' => bpAccount};
        XC_REST_MobilityOrder_B.manageDocument(mapAccountDocument);

        String docNif = (String) mapAccountDocument.get('docNif');
        String docNumber = (String) mapAccountDocument.get('docNumber');
        String expedition = (String) mapAccountDocument.get('expedition');
        String expiration = (String) mapAccountDocument.get('expiration');
        String docCountry = (String) mapAccountDocument.get('docCountry');
        String countryCode  = (String) mapAccountDocument.get('countryCode');


        NE__Billing_Profile__c billingProfile = new NE__Billing_Profile__c ();
        billingProfile.Id = billingProfileLineItem.XC_BillingProfile__c;
        billingProfile.NE__Payment__c = billingProfileLineItem.XC_BillingProfile__r.NE__Payment__c;
        billingProfile.XC_InvoiceDeliveryPref__c =  billingProfileLineItem.XC_BillingProfile__r.XC_InvoiceDeliveryPref__c;
        billingProfile.XC_InvoicePreferredLanguage__c =  billingProfileLineItem.XC_BillingProfile__r.XC_InvoicePreferredLanguage__c;
        billingProfile.NE__Iban__c = billingProfileLineItem.XC_BillingProfile__r.NE__Iban__c;
        billingProfile.XC_CommodityContractID__c = billingProfileLineItem.XC_BillingProfile__r.XC_CommodityContractID__c;
        billingProfile.XC_MandateType__c = billingProfileLineItem.XC_BillingProfile__r.XC_MandateType__c;
        billingProfile.NE__Card_Number__c = billingProfileLineItem.XC_BillingProfile__r.NE__Card_Number__c;


        Map<String,Object> paymentMethod = XC_REST_MobilityOrder_B.manageBpForZuora(billingProfile);
        
        mapAccountDocument.put('billingProfile', billingProfile);

        XC_REST_Account_B.wrapperOption wrOptions = XC_REST_MobilityOrder_B.manageWrapperOption(mapAccountDocument);

        // Set Billing Frequency on Zuora Customer Account
        if(billingProfile.NE__Payment__c == Label.XC_CL_DirectDebt || billingProfile.NE__Payment__c == Label.XC_CL_Commodity_Bill){
            
            /*Map<String,String> valueName = new Map<String,String>{	'Mensual' => Label.XC_CL_PaymentModel_Monthly, // check if mashery sends correctly values
                                                                    'Bimestral' => 'Bimonthly',
                                                                    'Anual' => Label.XC_CL_PaymentModel_Annual
                                                                    };*/

              

            //String billingFrequency =  (valueName.get(commodityBillingCycleFrequency) != null) ? valueName.get(commodityBillingCycleFrequency) : commodityBillingCycleFrequency;
            //String batchInputValue = (billingFrequency == Label.XC_CL_PaymentModel_Monthly) ? '01' : '02';
            String batchInputValue = (commodityBillingCycleFrequency == Label.XC_CL_PaymentModel_Monthly) ? '01' : '02';

            wrOptions.Batch = XC_ZuoraBPCreationC_U.manageCommodityContractBillingFrequency(new Map<String,Object>{'CommodityBillingCycleFrequency' => batchInputValue});
            wrOptions.XC_CommodityFrequencyReplace = (frequencyValue.get(commodityBillingCycleFrequency)!= null) ? frequencyValue.get(commodityBillingCycleFrequency) : '';
            //wrOptions.XC_CommodityFrequencyReplace = (frequencyValue.get(billingFrequency)!= null) ? frequencyValue.get(billingFrequency) : '';

        }

        Map<String,Object>  zuoraPayment = new Map<String,Object>{  'bpId' => billingProfileLineItem.Id,
                                                                    'fromBillingProfile' => false,
                                                                    'docNif' => (String.isBlank(docNif)) ? '': docNif,
                                                                    'docNumber' => (String.isBlank(docNumber)) ?  '': docNumber,
                                                                    'countryCode' => (String.isBlank(countryCode)) ?  '': countryCode,
                                                                    'expedition' => (String.isBlank(expedition)) ? '': expedition,
                                                                    'expiration' => (String.isBlank(expiration)) ? '': expiration,
                                                                    'personTypeCode' => (!String.isBlank(bpAccount.XC_RecordTypeDeveloperName__c) && bpAccount.XC_RecordTypeDeveloperName__c.containsIgnoreCase('Residential')) ? 'F' : 'J',
                                                                    'sequenceSetId' => wrOptions.SimplifiedInvoiceReplace,
                                                                    'invoicePreferredLanguage' => billingProfile.XC_InvoicePreferredLanguage__c,
                                                                    'contractId'=> (billingProfile.NE__Payment__c == Label.XC_CL_Commodity_Bill) ? bpNumber : ''
                                                                    };   


        Map<String,String>  zuoraMap = new Map<String,String>{  'account' =>  JSON.Serialize(bpAccount, true),
                                                                'legalEntity' => legalEntity,
                                                                'options' => (JSON.Serialize(wrOptions, true)).replace('Replace', '__c'),
                                                                'billingProfLineItemId' => billingProfileLineItem.Id,
                                                                'zuoraPayment' => JSON.serialize(zuoraPayment, true),
                                                                'mapPayment' => JSON.serialize(paymentMethod, true),
                                                                'billingProfId' => billingProfile.Id,
                                                                'bpli' => JSON.serialize(billingProfileLineItem, true),
                                                                'country' => bpAccount.Country__c,
                                                                'TransactionID' => transactionID
                                                                };  
        
        if(billingProfile.NE__Payment__c == Label.XC_CL_DirectDebt){
            ZuoraBillingProfileCreationController.callSIAForSEPAAsynchronous(bpAccount.Id, billingProfile, zuoraMap); 
        }else{
            XC_REST_Account_B.callZuora(zuoraMap);
        }                                       
        
    }


    /**
     * createNewAddress.
     *
     * @param utilAddressMap the util map
     * @description create new address to insert
    */
    public static void createNewAddress(Map<String,Object> utilAddressMap){

        String accountId = (String)utilAddressMap.get('accountId');
        String recordTypeName = (String) utilAddressMap.get('recordTypeName');
        Boolean foundBillingAddress = (Boolean) utilAddressMap.get('foundBillingAddress');
        Boolean foundInstallationAddress = (Boolean) utilAddressMap.get('foundInstallationAddress');
        List<String> billingAddressInfos = (List<String>) utilAddressMap.get('billingAddressInfos');
        List<String> installationAddressInfos = (List<String>) utilAddressMap.get('installationAddressInfos');        
        XC_REST_MobilityOrder_W.WrapperRequest wrReq = (XC_REST_MobilityOrder_W.WrapperRequest) utilAddressMap.get('wrReq');
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) utilAddressMap.get('wrResp');
        List<XC_Address__c> addrListToInsert = new List<XC_Address__c>();

        if(!foundBillingAddress && !foundInstallationAddress){
            if(wrReq.Order.BillingAddressData == wrReq.Order.InstallationAddressData){
                XC_Address__c addr = populateAddressFields(billingAddressInfos, accountId, recordTypeName);
                addrListToInsert.add(addr);
            }else{
                XC_Address__c billingAddr = populateAddressFields(billingAddressInfos, accountId, recordTypeName);
                XC_Address__c installationAddr = populateAddressFields(installationAddressInfos, accountId, recordTypeName);
                addrListToInsert.add(billingAddr);
                addrListToInsert.add(installationAddr);
            }
        }else if(!foundBillingAddress && foundInstallationAddress){
            XC_Address__c billingAddr = populateAddressFields(billingAddressInfos, accountId, recordTypeName);
            addrListToInsert.add(billingAddr);
        }else if(foundBillingAddress && !foundInstallationAddress){
            XC_Address__c installationAddr = populateAddressFields(installationAddressInfos, accountId, recordTypeName);
            addrListToInsert.add(installationAddr);
        }

        insertAddress(addrListToInsert, utilAddressMap);

    }


    /**
    * populateAddressFields.
    *
    * @param addressInfos the list of address info
    * @param accountId the accountId
    * @param recordTypeName the recordTypeName
    * @description method to populate the address fields
    */
    public static XC_Address__c populateAddressFields(List<String> addressInfos, String accountId, String recordTypeName){

        XC_Address__c addr = new XC_Address__c();
        addr.XC_AddressCountry__c = addressInfos[0];
        addr.XC_AddressProvince__c = addressInfos[1];
        addr.XC_City__c = addressInfos[2];
        addr.XC_PostalCode__c = addressInfos[3];
        addr.XC_StreetTypeText__c = addressInfos[4];
        addr.XC_Address__c = addressInfos[5];
        addr.XC_StreetNumber__c = (addressInfos.size() >= 7) ? addressInfos[6] : '';
        addr.XC_Floor__c = (addressInfos.size() >= 8) ? addressInfos[7] : '';
        addr.XC_Door__c = (addressInfos.size() == 9) ? addressInfos[8] : ''; 
        addr.XC_Account__c = accountId;
        addr.XC_AddressValidated__c = true; 
        Boolean isPartner = (recordTypeName.containsIgnoreCase('Partner')) ? true : false;
        addr.RecordTypeId = XC_UTIL_Address.getAddressRecordTypeByCountry(addressInfos[0].toUpperCase(), isPartner);

        
        return addr;
    }


    /**
    * insertAddress.
    *
    * @param addrListToInsert the list of address to insert
    * @param utilAddressMap the util map
    * @description method to insert the new address
    */
    public static void insertAddress(List<XC_Address__c> addrListToInsert, Map<String,Object> utilAddressMap){

        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) utilAddressMap.get('wrResp');

        if(!addrListToInsert.isEmpty()){
            List<XC_UTIL_SObject.WrapperResult> addressInsertRes = XC_UTIL_SObject.insertListRecords(addrListToInsert);
            for(XC_UTIL_SObject.WrapperResult addrRes : addressInsertRes){
                if(!addrRes.success) {
                    wrResp.Result.Message = 'INTERNAL ERROR';
                    wrResp.Result.logError = 'Error in createAddress: ' + addrRes.errorMessage;
                    wrResp.Result.ErrorCode = '500';
                    return;
                }
            }

            Map<Id, XC_Address__c> mapAddr; 
            if(utilAddressMap.get('installationAddressId') == null){
                List<id> ids = XC_UTIL_SObject.getIds(addrListToInsert);
                mapAddr = new Map<Id, XC_Address__c>([SELECT XC_PricinRegion__c FROM XC_Address__c WHERE Id IN: ids]);
            }

            if(addrListToInsert.size() == 2){
                utilAddressMap.put('billingAddressId', addrListToInsert[0].id);
                utilAddressMap.put('installationAddressId', addrListToInsert[1].id);
                utilAddressMap.put('province', addrListToInsert[1].XC_AddressProvince__c);
                utilAddressMap.put('pricingRegion', mapAddr.get(addrListToInsert[1].id).XC_PricinRegion__c);
            }else{
                if(utilAddressMap.get('billingAddressId') == null){
                    utilAddressMap.put('billingAddressId', addrListToInsert[0].id);
                }
                if(utilAddressMap.get('installationAddressId') == null){
                    utilAddressMap.put('installationAddressId', addrListToInsert[0].id);
                    utilAddressMap.put('province', addrListToInsert[0].XC_AddressProvince__c);
                    utilAddressMap.put('pricingRegion',  mapAddr.get(addrListToInsert[0].id).XC_PricinRegion__c);
                }
            }

        }
    }
    
}