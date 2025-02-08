/**
 * The Class XC_REST_CartAPI_U_clone.
 *
 * @author            :  Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  10/06/2019
 * @date Modification :  16/06/2020
 * @description       :  Util class for XC_REST_CartAPI
 */


public without sharing class XC_REST_CartAPI_U_clone {


    /**
     * ManageUpsertItemsResponse.
     *
     * @param result the result of upsert items
     * @param infos the infos map
     * @description manage response of UpsertItems
     */
    public static void manageUpsertItemsResponse(Map<String,Object> result, Map<String, String> infos) {

        Map<String,Object> conf = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(result.get('configuration')));
        if(String.isBlank(infos.get('assetId'))) {
            populateConfigurationMap(conf, infos);
        }
        conf.remove('id');

        result.remove('sessionInfo');
        result.remove('listOfItems');
        result.remove('listOfCategories');
        result.remove('listOfBundle');
        result.remove('itemsCounter');
        result.put('configuration', (Object) conf);

        String dataInterceptorString = JSON.serialize(result);
        dataInterceptorString = dataInterceptorString.escapeJava();
        infos.put('dataInterceptorString', dataInterceptorString);
    }


    /**
     * PopulateConfigurationMap.
     *
     * @param confMap the configuration Map
     * @param infos the infos map
     * @description populate Configuration Map with some infos
     */
    public static void populateConfigurationMap(Map<String, Object> confMap, Map<String, String> infos) {
        
        Set<String> valuesNoConf = new Set<String>{'sessionId', 'token', 'productCategory', 'categoryId', 'catalogId', 'catalogItemId', 'itemcode', 'qty', 'OrganizationId',
                                                    'ClientId', 'ServerURL', 'ConfId', 'assetId', 'billingProfLineItemId', 'billingProfId', 'paymentMethod', 'ServerURL_Change',
                                                    'Password', 'PasswordToken', 'UserToken', 'token_Change', 'LICname', 'oiAttribute', 'contactId', 'productId', 'familyPropertyIds',
                                                    'ChannelCommodity', 'ChannelForOpp', 'OrderDocument', 'PricingRegionCommodity', 'AssetList', 'commodityTransactionID', 'account', 'clientSystem',
                                                    'productCode', 'accountDNI', 'Discounts', 'stream', 'optyIdRM', 'orderItemList', 'catalogItemIds', 'catalogItemAttributesMap', 'currentStep', 
                                                    'insertOpportunityResult','preferredlanguageofcontact'
                                                   };
        
        for(String key : infos.keySet()) {
            if(!valuesNoConf.contains(key) && String.isNotBlank(infos.get(key))) {
                confMap.put(key, (Object) infos.get(key));
            }
        }

        confMap.put('NE__order_date__c', DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS'));
    }


    /**
     * InsertIntegrationLogs.
     *
     * @param integrationLogsToInsert the integration log list
     * @param transactionID the transactionId
     * @description method insert integration Logs
     */
    @future
    public static void insertIntegrationLogs(String integrationLogsString, String infosString) {

        List<XC_Integration_Log__c> integrationLogsToInsert = (List<XC_Integration_Log__c>) JSON.deserialize(integrationLogsString, List<XC_Integration_Log__c>.class);
        Map<String, String> infos = (Map<String, String>) JSON.deserialize(infosString, Map<String, String>.class);
        String transactionId = (!String.isBlank(infos.get('XC_eMobTransactionId__c'))) ? infos.get('XC_eMobTransactionId__c') : infos.get('commodityTransactionID');
        String accountDNI = infos.get('accountDNI');
        String accountId = infos.get('NE__AccountId__c');
        String productCode = infos.get('productCode');

        for(XC_Integration_Log__c intLog : integrationLogsToInsert) {
            intLog.XC_Log_TransactionId__c = transactionID;
            intLog.XC_Log_ClientSystem__c = 'XCustomerB2C'; 
		    intLog.XC_Log_ServerSystem__c = 'Bit2Win'; 
            intLog.XC_Log_AccountDNI__c	= accountDNI;
            intLog.XC_Log_AccountID__c = accountId;
            intLog.XC_Log_ProductCode__c = productCode;
        }

        XC_UTIL_Sobject.insertListRecords(integrationLogsToInsert);
    }


    /**
     * ManageCheckout.
     *
     * @param confId the configuration id
     * @param counter the counter
     * @param infos the infos map
     * @description method to manage the configuration
     */
    public static void manageCheckout(String confId, Integer counter, Map<String, String> infos) {

        if(counter == 0) {

            if(String.isBlank(infos.get('assetId')) && !Test.isRunningTest()) { // Create Configuration - Type inOrder
                XC_REST_CartAPI_clone.cartCheckout(infos, 1);

            } else {    // Update Configuration - Type ChangeOrder
                
                Boolean complianceNeeded = getClientSystemSettings(infos.get('clientSystem'), infos);
                NE__Order__c ord = new NE__Order__c(Id = confId,
                                                    RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId(),
                                                    XC_Status__c = 'In Progress',
                                                    NE__ConfigurationStatus__c = 'Valid',
                                                    XC_Compliance_Approval__c = 'Not Needed',
                                                    NE__Type__c = 'ChangeOrder',
                                                    XC_Subtype__c = 'eMobility Change Offer',
                                                    XC_eMobTransactionId__c = infos.get('XC_eMobTransactionId__c'),
                                                    NE__AccountId__c = infos.get('NE__AccountId__c'),
                                                    NE__BillAccId__c = infos.get('NE__AccountId__c'),
                                                    NE__ServAccId__c = infos.get('NE__AccountId__c'));
                XC_UTIL_Sobject.WrapperResult updateConfResult = XC_UTIL_Sobject.updateRecord(ord);
                System.debug('updateConfResult -> ' + updateConfResult);
                
                infos.put('complianceNeeded', JSON.serialize(complianceNeeded));
                startProvisioning(confId, infos);
            }
            
        } else if(counter == 1) {   // Update Configuration - Type inOrder

            Boolean complianceNeeded = getClientSystemSettings(infos.get('clientSystem'), infos);

            NE__Order__c ord = new NE__Order__c(Id = confId,
                                                RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId(),
                                                XC_Status__c = 'In Progress',
                                                NE__ConfigurationStatus__c = 'Valid',
                                                //XC_Compliance_Approval__c = 'Not Needed',
                                                XC_Compliance_Approval__c =  (!complianceNeeded) ? 'Not Needed' :  '', // compliance for Commodity
                                                XC_Channel__c = (String.isNotBlank(infos.get('ChannelCommodity'))) ? infos.get('ChannelCommodity') : '',
                                                XC_SignedByExternal__c = infos.get('clientSystem').equalsIgnoreCase('CommodityItalyB2C') ? 'VocalOrder' : '');
            XC_UTIL_Sobject.WrapperResult updateConfResult = XC_UTIL_Sobject.updateRecord(ord);
            System.debug('updateConfResult -> ' + updateConfResult);
            infos.put('complianceNeeded', JSON.serialize(complianceNeeded));

            startProvisioning(confId, infos);
        }
    }

    
    /**
     * Start Provisioning.
     *
     * @param confId the configuration id
     * @param infos the infos map
     * @description method to set the Billing Profile for Configuration Items and to start the Provisioning
     */
    public static void startProvisioning(String confId, Map<String, String> infos) {

        // Configuration Item
        Map<Id, NE__OrderItem__c> ordItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, NE__BillingProfId__c, XC_BillingProfileLineItem__c, XC_PaymentMethod__c, NE__CatalogItem__c, NE__Root_Order_Item__c FROM NE__OrderItem__c WHERE NE__OrderId__c =: confId]);
        List<NE__OrderItem__c> ordItemList = ordItemMap.values();
        
        /*if(String.isNotBlank(infos.get('XC_Coupon_Code__c'))) {
            
            // Burn Coupon
            System.debug('BURN COUPON - CouponCode ' + infos.get('XC_Coupon_Code__c'));
            System.debug('BURN COUPON - Account ' + infos.get('NE__AccountId__c'));

            XC_REST_CheckCoupon_W.WrapperCheckCouponRequest requestBurnCoupon = new XC_REST_CheckCoupon_W.WrapperCheckCouponRequest();
            requestBurnCoupon.requestElement = new List<XC_REST_CheckCoupon_W.WrapperRequestElement>();
            XC_REST_CheckCoupon_W.WrapperRequestElement wrElement = new XC_REST_CheckCoupon_W.WrapperRequestElement();
            wrElement.CouponCode = infos.get('XC_Coupon_Code__c');
            wrElement.AccountID = infos.get('NE__AccountId__c');
            requestBurnCoupon.requestElement.add(wrElement);

            XC_REST_CheckCoupon_W.WrapperResponse resultBurnCoupon = new XC_REST_CheckCoupon_W.WrapperResponse();
            XC_REST_CheckCoupon_U.checkCouponPostPut(requestBurnCoupon, resultBurnCoupon, 'PUT');
        }*/
        
        for(NE__OrderItem__c ordItem : ordItemList) {
            if(String.isBlank(infos.get('paymentMethod'))) {
                ordItem.XC_PaymentMethod__c = 'Direct Debt';
            } else if((infos.get('paymentMethod') == Label.XC_CL_Commodity_Bill && String.isBlank(ordItem.NE__Root_Order_Item__c)) ||
                        infos.get('paymentMethod') != Label.XC_CL_Commodity_Bill) {
                    ordItem.NE__BillingProfId__c = infos.get('billingProfId');
                    ordItem.XC_BillingProfileLineItem__c = infos.get('billingProfLineItemId');
                    ordItem.XC_PaymentMethod__c = infos.get('paymentMethod');
            }

            if(String.isNotBlank(infos.get('assetId'))) {
                ordItem.NE__Action__c = (ordItem.NE__CatalogItem__c == infos.get('catalogItemId')) ? 'Add' : 'Remove';
            }
        }
        
        List<XC_UTIL_Sobject.WrapperResult> updateConfItemResult = XC_UTIL_Sobject.updateListRecords(ordItemList);
 
        if(String.isNotBlank(infos.get('ChannelCommodity')) && !String.isBlank(infos.get('OrderDocument'))) {   // FOR COMMODITY
            manageExternalDocument(confId, infos);
        }

        Boolean complianceNeeded = (Boolean)JSON.deserialize(infos.get('complianceNeeded'), Boolean.class);
        if(!Test.isRunningTest()) { // Start Provisioning 
            
            if(infos.get('stream') != 'B2C') {  // Set WBE for B2B/B2G
                XC_LCC_056_CalculateWBS.submit(confId);
            }

            if(complianceNeeded){

                XC_UTIL_NextStepOrderToProvisioning.firstNextStep(confId);

            } else {
        
                XC_LCC048_OrderInProvisioning.insertProvisioningSteps(confId, 'XC_REST_CartAPI_U_clone');
                System.enqueueJob(new XC_UTIL_NextStepOrderToProvisioning.ThirdNextStepQueue(confId));
            }
        }
    }

    
    /**
     * Start manageExternalDocument.
     *
     * @param confId the configuration id
     * @param infos the infos map
     * @description method to manage the external document from commodity.
     */
    public static void manageExternalDocument(String confId, Map<String, String> infos){

        List<XC_REST_MobilityOrder_W.OrderDocumentWrapper> externalDocuments = (List<XC_REST_MobilityOrder_W.OrderDocumentWrapper>)JSON.deserialize(infos.get('OrderDocument'), List<XC_REST_MobilityOrder_W.OrderDocumentWrapper>.class); 
        List<XC_ExternalDocument__c> externalDocumentToInsert = new List<XC_ExternalDocument__c>();

        for(XC_REST_MobilityOrder_W.OrderDocumentWrapper extDocs : externalDocuments){
            if(!String.isBlank(extDocs.ContractUrl)){
                XC_ExternalDocument__c externalDoc = new XC_ExternalDocument__c(XC_Configuration__c = confId, XC_ContractURL__c = extDocs.ContractUrl);
                externalDocumentToInsert.add(externalDoc);
            }
        }
		
        if(!externalDocumentToInsert.isEmpty()){
            XC_UTIL_SObject.insertListRecords(externalDocumentToInsert);
        }
    }

    /**
    * @description method to get Client System setting
    * @return Boolean
    * @param clientSystem - String
    * @param infos - Map<String, String>
    */
    public static Boolean getClientSystemSettings(String clientSystem, Map<String, String> infos){

        if(String.isBlank(clientSystem)) {
            return true;
        }

        Map<Id, XC_CM_ClientSystemSetting__mdt> complianceMap = new Map<Id,XC_CM_ClientSystemSetting__mdt> ([SELECT XC_ComplianceNeeded__c
                                                                                                            FROM XC_CM_ClientSystemSetting__mdt   
                                                                                                            WHERE XC_ClientSystem__c  =: clientSystem]);
        
        if(!(complianceMap.values()).isEmpty()){
            return (!complianceMap.values()[0].XC_ComplianceNeeded__c) ? false : (clientSystem == Label.XC_CL_CommoditySpainB2C && String.isBlank(infos.get('OrderDocument'))) ? false : true; 
        }
        
        return true;
    }

}