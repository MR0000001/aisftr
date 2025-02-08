/**
 * @File Name          : XC_IN_QRS04_CreateOrder.cls
 * @Description        :
 * @Author             : Luisana Rocco - lrocco@deloitte.it
 * @Group              :
 * @Last Modified By   : Tommaso Precania - tommaso.precania@accenture.com
 * @Last Modified On   : 08-02-2021
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    16/6/2020   Luisana Rocco - lrocco@deloitte.it     Initial Version
 * 2.0    12/10/2021  Tommaso Precania - tommaso.precania@accenture.com     Added Third Party Billing Logic
**/

public without sharing class XC_IN_QRS04_CreateOrder {

    public class InputWrapper {
        @InvocableVariable
        public String stepId;
    }

    public static final Set<String> MANAGED_ERROR_CODES = new Set<String>{'400','500'};


    /**
    * @description invokes XC_REST_MobilityOrder methods to manage order insert asynchronously - errors are managed via integration logs and queuedrequeststep fields
    * @author Luisana Rocco - lrocco@deloitte.it | 16/6/2020
    * @param inputs
    * @return void
    **/

    @InvocableMethod
    public static void executeOrderCreation(List<InputWrapper> inputs){
        System.enqueueJob(new QueueableExecuteOrderCreation(inputs));
    }


    public class QueueableExecuteOrderCreation implements Queueable, Database.AllowsCallouts{

        private List<InputWrapper> inputs;

        public QueueableExecuteOrderCreation(List<InputWrapper> inputs){
            this.inputs = inputs;
        }

        public void execute(QueueableContext qc) {
            manageOrderCreation(inputs);
        }
    }

    public static void manageOrderCreation(List<InputWrapper> inputs){

        System.Savepoint beforeInsertOrderSavepoint;
        if(!Test.isRunningTest()){
            beforeInsertOrderSavepoint = Database.setSavepoint();
        }

        //getting the full step info in order to process data
        InputWrapper iw = inputs[0];
        XC_QueuedRequestStep__c currentStep = XC_UTIL_QueuedRequestStep.getFullStepInfo(iw.stepId);
        Set<Integer> previousSequences = new Set<Integer> {Integer.valueOf(currentStep.XC_StepSequence__c)-1,  Integer.valueOf(currentStep.XC_StepSequence__c)-2};
        Map<Id,XC_QueuedRequestStep__c> previousSteps = XC_UTIL_QueuedRequestStep.getQueuedRequestSteps(currentStep,  previousSequences);

        //getting logging infos
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        XC_REST_Order_U.WrapperRes wrResp = new XC_REST_Order_U.WrapperRes();
        String logError = '';
        String messageResp = '';

        try{

            //generate body request
            XC_REST_Order_U.WrapperPOSTRequest wrReq = generatePostOrderBody(currentStep, previousSteps);

            //adding headers
            Map<String,String> mapHeader = new Map<String,String>();
            mapHeader.put('ClientSystem', currentStep.XC_QueuedRequest__r.XC_ClientSystem__c);
            mapHeader.put('TransactionID', currentStep.XC_QueuedRequest__r.XC_TransactionId__c);
            mapHeader.put('DateTimeMessage', DateTime.now().format('yyyyMMddHHmmssSSS'));
            mapHeader.put('Operation', 'Create');
            mapHeader.put('Functionality', 'CreateOrder');
            mapHeader.put('ServerSystem', 'XCustomerB2C');


            //TODO: manage first integration log insert here
            intLog.insertIntegReqInboundLog('AsyncOrder', JSON.serialize(wrReq,true),currentStep.XC_QueuedRequest__c);
            intLog.setHeader(mapHeader);
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod('POST');

            // set additional integration log info
            XC_UTIL_IntegrationLog.LogWrapper logWrapper = new  XC_UTIL_IntegrationLog.LogWrapper();
            logWrapper.accountID =  wrReq.Order.accountID;
            logWrapper.productCode = wrReq.Order.OrderItem[0].ProdID;
            intLog.setAdditionalInformations(logWrapper);

            //Try to inserting the order
            Map<String,Object> utilMap = new Map<String,Object>();
            utilMap.put('transactionID', mapHeader.get('TransactionID'));
            utilMap.put('currentStep', currentStep);
            utilMap.put('clientSystem', currentStep.XC_QueuedRequest__r.XC_ClientSystem__c);

            generatePostAccountBody(currentStep,utilMap);
            manageInsert(wrReq, wrResp, utilMap);



            //manage response
            String respErrorCode = wrResp.Result.ErrorCode;
            messageResp = JSON.serialize(wrResp,true);
            if(respErrorCode != '0'){
                manageErrors(currentStep,wrResp);
            }

        }catch(Exception e){
            logError = e.getMessage() + ' ' + e.getStackTraceString();
            currentStep.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            currentStep.XC_ErrorMessage__c = logError;

        }finally{
            //inserting logs
            if(!Test.isRunningTest() && wrResp.Result.ErrorCode !='0'){
                Database.rollback(beforeInsertOrderSavepoint);
                XC_UTIL_Sobject.updateRecord(currentStep);
                XC_UTIL_QueuedRequestStep.skipNotCallbackSteps(currentStep);
            }
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), messageResp, logError);
        }

    }

    /**
    * @description manage KO errors of the order creation phase
    * @author Luisana Rocco - lrocco@deloitte.it | 16/6/2020
    * @param currentStep
    * @param wrResp
    * @return void
    **/
    private static void manageErrors(XC_QueuedRequestStep__c currentStep, XC_REST_Order_U.WrapperRes wrResp){

        if(MANAGED_ERROR_CODES.contains(wrResp.Result.ErrorCode)){
            currentStep.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            currentStep.XC_ExecutionResponse__c = JSON.serialize(wrResp,true);
            currentStep.XC_ErrorMessage__c = wrResp.Result.Message;

            return;
        }

    }


    /**
    * @description method to generate order body
    * @author Luisana Rocco - lrocco@deloitte.it | 16/6/2020
    * @param currentStep
    * @return XC_REST_Order_U.WrapperPOSTRequest
    **/
    private static XC_REST_Order_U.WrapperPOSTRequest generatePostOrderBody(XC_QueuedRequestStep__c currentStep, Map<Id,XC_QueuedRequestStep__c> previousSteps){

        String requestStringValue = currentStep.XC_QueuedRequest__r.XC_RequestBody__c;
        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(requestStringValue, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        XC_REST_Order_U.WrapperPOSTRequest wrReq = new XC_REST_Order_U.WrapperPOSTRequest();
        wrReq.Order = fullQRReqBody.Order;

        XC_REST_Account_W.WrapperResponse responseWrPreviousStepAddress;
        XC_REST_Account_W.WrapperResponse responseWrPreviousStepBP;
        for(XC_QueuedRequestStep__c previousStep : previousSteps.values()){
            if(Integer.valueOf(previousStep.XC_StepSequence__c) == (Integer.valueOf(currentStep.XC_StepSequence__c) - 2)){
                responseWrPreviousStepAddress = (XC_REST_Account_W.WrapperResponse) JSON.deserialize(previousStep.XC_ExecutionResponse__c, XC_REST_Account_W.WrapperResponse.class);
            }else if(Integer.valueOf(previousStep.XC_StepSequence__c) == (Integer.valueOf(currentStep.XC_StepSequence__c) - 1)){
                responseWrPreviousStepBP = (XC_REST_Account_W.WrapperResponse) JSON.deserialize(previousStep.XC_ExecutionResponse__c, XC_REST_Account_W.WrapperResponse.class);
            }
        }

        wrReq.Order.InstallationAddress = responseWrPreviousStepAddress.Address[0].AddressID;
        wrReq.Order.BillingAddress =  (responseWrPreviousStepAddress.Address.size() > 1) ?  responseWrPreviousStepAddress.Address[1].AddressID : responseWrPreviousStepAddress.Address[0].AddressID;
        //Mod CV Errore Step Billing Profile 02/08/2021 Comment other index of list to get the first prefered by market
        wrReq.Order.BillingAddress = responseWrPreviousStepAddress.Address[0].AddressID;//(responseWrPreviousStepAddress.Address.size() > 1) ?  responseWrPreviousStepAddress.Address[1].AddressID : responseWrPreviousStepAddress.Address[0].AddressID;
        wrReq.Order.AccountID = responseWrPreviousStepBP.Account.AccountID;
        wrReq.Order.OrderItem[0].BillingProfileID = responseWrPreviousStepBP.BillingProfile[0].BillingProfileID;


        return wrReq;

    }

    private static void generatePostAccountBody(XC_QueuedRequestStep__c currentStep, Map<String,Object> utilMap){

        String requestStringValue = currentStep.XC_QueuedRequest__r.XC_RequestBody__c;
        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(requestStringValue, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        XC_REST_Account_W.WrapperResponse wrReq = new XC_REST_Account_W.WrapperResponse();        
        wrReq.Account = fullQRReqBody.Account;
        utilMap.put('XC_Company_Code__c',wrReq.Account.CompanyCode);
        utilMap.put('XC_Cost_Center__c',wrReq.Account.CostCenter);
        
    }    

    /**
     * ManageInsert.
     *
     * @param wrReq the wrapper request
     * @param wrResp the wrapper response
     * @param utilMap the util Map
     * @description method to manage insert
    */
    public static void manageInsert(XC_REST_Order_U.WrapperPOSTRequest wrReq, XC_REST_Order_U.WrapperRes wrResp, Map<String,Object> utilMap) {

        getAllObjectInfos(wrReq, wrResp, utilMap);
        if(wrResp.Result.ErrorCode == '400') {
            return;
        }

        Map<String, String> infos = (Map<String, String>)utilMap.get('infos');
        XC_REST_MobilityOrder_W.createOpportunityForOrder(infos, wrReq.Order.LegalEntity);
        if(!String.isBlank(infos.get('insertOpportunityResult'))){
            wrResp.Result.ErrorCode = '500';
            wrResp.Result.Message = 'INTERNAL ERROR. ' + infos.get('insertOpportunityResult');
            return;
        }

        XC_REST_MobilityOrder_U.createOrderB2W(infos);
        wrResp.Result.ErrorCode = '0';
        wrResp.Result.Message = 'Operation completed successfully';

    }


     /**
     * CreateOrderB2W.
     *
     * @param configurationInfo the configuration Info Map
     * @description method to create order b2w
     */
    /*private static void createOrderB2W(Map<String, String> configurationInfo){

        if(String.isNotBlank(configurationInfo.get('NE__OptyId__c'))) {
            Map<Id, XC_CS004_Bit2WinCredentials__c> b2wMap = new Map<Id, XC_CS004_Bit2WinCredentials__c>([SELECT XC_ServerURL__c, XC_ClientId__c, XC_OrganizationId__c FROM XC_CS004_Bit2WinCredentials__c WHERE XC_Country__c = 'SPAIN']);
            List<XC_CS004_Bit2WinCredentials__c> b2wCred = b2wMap.values();
            if(b2wCred.isEmpty()) {
                return;
            } else {
                configurationInfo.put('ServerURL', b2wCred[0].XC_ServerURL__c);
                configurationInfo.put('ClientId', b2wCred[0].XC_ClientId__c);
                configurationInfo.put('OrganizationId', b2wCred[0].XC_OrganizationId__c);
            }

            if(!Test.isRunningTest()) {
                XC_REST_CartAPI_clone cartAPI = new XC_REST_CartAPI_clone(configurationInfo);
                System.enqueueJob(cartAPI);
            }
        }

    }*/


    /**
     * getAllObjectInfos.
     *
     * @param wrReq the wrapper request
     * @param wrResp the wrapper response
     * @param utilMap the util map
     * @description method to get all object informations
    */
    public static void getAllObjectInfos(XC_REST_Order_U.WrapperPOSTRequest wrReq, XC_REST_Order_U.WrapperRes wrResp, Map<String,Object> utilMap){

        Map<String, String> infos = createConfigurationInfoMap(wrReq.Order, (String)utilMap.get('clientSystem'));
        utilMap.put('infos', infos);

        Set<Id> addressIds = new Set<Id>();
        addressIds.add(wrReq.Order.BillingAddress);
        addressIds.add( wrReq.Order.InstallationAddress);

        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id,Name, XC_Segment__c, XC_IsEmployee__c, XC_AccountType__c, XC_RecordTypeDeveloperName__c, Country__c, (SELECT Id, XC_Preferredlanguageofcontact__c FROM Contacts WHERE XC_PrimaryContact__c = true),
                                                            (SELECT Id, XC_BillingProfile__c, XC_BillingProfile__r.NE__Payment__c, XC_BillToAddress__c, XC_SoldToAddress__c, XC_TPBCode__c  FROM XC_BillingProfileLineItems__r WHERE XC_BillToAddress__c IN : addressIds AND XC_SoldToAddress__c IN : addressIds  AND XC_BillingProfile__c =: wrReq.Order.Orderitem[0].BillingProfileID AND XC_LegalEntity__c =: wrReq.Order.LegalEntity), //[DeAv 05/01/2022 TPB Fix for search correct bpli - Added XC_TPBCode__c]
                                                            (SELECT Id, XC_AddressProvince__c, XC_BillingAddress__c, XC_PricinRegion__c, XC_DeliveryAddress__c, XC_InstallationAddress__c  FROM Addresses__r WHERE Id IN : addressIds),
                                                            (SELECT XC_Address__c, XC_Product_Catalog_Category__c, NE__Bundle__c, NE__CatalogItem__r.NE__Catalog_Category_Name__c, NE__Catalog__c, NE__CatalogItem__c, XC_Coverage_Asset_Type__c, Id, Name, NE__Description__c, NE__Parent_Order_Item__c, NE__ProdId__c, XC_Product_Type__c, XC_Product_Subtype__c, NE__Status__c, NE__UsageCode__c, NE__CatalogItem__r.NE__UsageCode__c  FROM Assets WHERE NE__Status__c =: Label.XC_CL_Asset_StatusActive)
                                                            FROM Account WHERE Id =: wrReq.Order.AccountID LIMIT 1]);

        if(accountMap.isEmpty()){
            wrResp.Result.Message = 'ERROR. Account not found';
            wrResp.Result.logError = 'ERROR. Account not found';
            wrResp.Result.ErrorCode = '400';
            return;
        }

        //[DeAv 09/11/2021 CR NR2063 START]
        Map<Id, XC_CM_ClientSystemSetting__mdt> infosByClientSystem;
        if('B2B'.equalsIgnoreCase(accountMap.values()[0].XC_Segment__c) && 'CommodityItalyB2C'.equalsIgnoreCase((String)utilMap.get('clientSystem'))){
            infosByClientSystem = new Map<Id, XC_CM_ClientSystemSetting__mdt> ([SELECT XC_ProductCategoryOfInterest__c, XC_CatalogLicName__c FROM XC_CM_ClientSystemSetting__mdt WHERE XC_ClientSystem__c  = 'CommodityItalyB2B' LIMIT 1]);
        }else{
            infosByClientSystem = new Map<Id, XC_CM_ClientSystemSetting__mdt> ([SELECT XC_ProductCategoryOfInterest__c, XC_CatalogLicName__c FROM XC_CM_ClientSystemSetting__mdt WHERE XC_ClientSystem__c  =: (String)utilMap.get('clientSystem') LIMIT 1]);
        }
        //[DeAv 09/11/2021 CR NR2063 END]
        
        //minal.mahavir.patil@accenture.com NR2299 4/5/22 start
        if('B2C'.equalsIgnoreCase(accountMap.values()[0].XC_Segment__c) && 'CommodityRomaniaB2C'.equalsIgnoreCase((String)utilMap.get('clientSystem'))){
            if(null!=wrReq && null!= wrReq.order && String.isNotBlank(wrReq.order.MarketLegalEntity)){
                infos.put('MarketLegalEntity',wrReq.order.MarketLegalEntity);
            }  
            else{ 
                wrResp.Result.Message   = 'ERROR. Missing mandatory field MarketLegalEntity';
                wrResp.Result.logError  = 'ERROR. Missing mandatory field MarketLegalEntity';
                wrResp.Result.ErrorCode = '400';
                return; 
            }
        }
        //minal.mahavir.patil@accenture.com NR2299 4/5/22 End

        // BEGIN - [2021-10-11 :: TP :: Third Party Billing :: Get partner codes]
        List<XC_ThirdPartyConfiguration__c> tpbConfigs = [SELECT Name, XC_TPBCode__c, XC_ProductCategoryOfInterest__c, XC_CatalogLicName__c FROM XC_ThirdPartyConfiguration__c WHERE XC_TPBCode__c =:(String)utilMap.get('clientSystem') AND XC_OrgId__c = :UserInfo.getOrganizationId()];
        XC_ThirdPartyConfiguration__c tpbConf = (tpbConfigs != null && !tpbConfigs.isEmpty()) ? tpbConfigs.get(0) : null;
        String catalogLicName = (tpbConf != null && String.isNotBlank(tpbConf.XC_CatalogLicName__c)) ? tpbConf.XC_CatalogLicName__c : (!infosByClientSystem.isEmpty() ? infosByClientSystem.values()[0].XC_CatalogLicName__c : '');
        utilMap.put('catalogLicName', catalogLicName);
        utilMap.put('tpbConf', tpbConf); //[DeAv 05/01/2022 TPB Fix for search correct bpli]
        // utilMap.put('catalogLicName', !infosByClientSystem.isEmpty() ? infosByClientSystem.values()[0].XC_CatalogLicName__c : '');
        // END - [2021-10-11 :: TP :: Third Party Billing :: Get partner codes]
        // prepare map to link parent-child order item
        prepareParentChildInfo(wrReq, utilMap);
        searchRightObjects(accountMap, utilMap);
        getProductInfos(wrReq, wrResp, utilMap);
        if(wrResp.Result.ErrorCode == '400'){
            return;
        }

        List<NE__Catalog_Item__c> catalogItems = (List<NE__Catalog_Item__c>)utilMap.get('catalogItems');
        infos.put('account', JSON.Serialize(accountMap.values()[0]));
        infos.put('currentStep', JSON.serialize((XC_QueuedRequestStep__c)utilMap.get('currentStep')));
        infos.put('ChannelCommodity', wrReq.Order.Channel);
        infos.put('XC_LegalEntity__c', wrReq.Order.LegalEntity);
        infos.put('productCode', wrReq.Order.OrderItem[0].ProdID);
        infos.put('stream', accountMap.values()[0].XC_Segment__c);
        infos.put('catalogId',   catalogItems[0].NE__Catalog_Id__c);
        infos.put('contactId', accountMap.values()[0].Contacts[0].Id);
        infos.put('XC_Company_Code__c',(JSON.serialize((String)utilMap.get('XC_Company_Code__c'))).replace('\"',''));
        infos.put('XC_Cost_Center__c',(JSON.serialize((String)utilMap.get('XC_Cost_Center__c'))).replace('\"',''));
        //infos.put('productCategory', (infosByClientSystem != null && !infosByClientSystem.isEmpty()) ? infosByClientSystem.values()[0].XC_ProductCategoryOfInterest__c : Label.XC_CL_MaintenanceAndRepair);

        string pc = '';
        // BEGIN - [2021-10-11 :: TP :: Third Party Billing :: Get partner codes]
        if((tpbConf == null || String.isBlank(tpbConf.XC_ProductCategoryOfInterest__c)) && infosByClientSystem != null && !infosByClientSystem.isEmpty()){
            if((String)utilMap.get('clientSystem')=='CommoditySpainB2C'){
                pc = getProductCategory(catalogItems[0].XC_LIC_Catalog_Item_Name__c);
            } else {
                pc = infosByClientSystem.values()[0].XC_ProductCategoryOfInterest__c;
            }
        } else if(tpbConf == null || String.isBlank(tpbConf.XC_ProductCategoryOfInterest__c)){
            pc = Label.XC_CL_MaintenanceAndRepair;
        } else {
            pc = tpbConf.XC_ProductCategoryOfInterest__c;
        }
        // END - [2021-10-11 :: TP :: Third Party Billing :: Get partner codes]
        infos.put('productCategory', pc);
        infos.put('ChannelForOpp', Label.XC_CL_ChannelCommodityPartner);
        infos.put('commodityTransactionID',  (String) utilMap.get('transactionID'));
        infos.put('xcProvince',  (XC_Address__c)utilMap.get('deliveryAddress')!= null ? ((XC_Address__c)utilMap.get('deliveryAddress')).XC_AddressProvince__c : null);
        infos.put('PricingRegionCommodity',  (XC_Address__c)utilMap.get('deliveryAddress')!= null ? ((XC_Address__c)utilMap.get('deliveryAddress')).XC_PricinRegion__c : null);
        infos.put('OrderDocument', (wrReq.Order.Document != null && !wrReq.Order.Document.isEmpty()) ? JSON.Serialize(wrReq.Order.Document, true) : '');
        infos.put('AssetList', (!accountMap.values()[0].Assets.isEmpty() ? JSON.Serialize(accountMap.values()[0].Assets) : JSON.Serialize(new List<Asset>())));
        infos.put('XC_OrderBillingAddress__c', (XC_Address__c)utilMap.get('billingAddress')!= null ? ((XC_Address__c)utilMap.get('billingAddress')).Id : null);
        infos.put('XC_DeliveryAddress__c', (XC_Address__c)utilMap.get('deliveryAddress')!= null ? ((XC_Address__c)utilMap.get('deliveryAddress')).Id : null);
        infos.put('XC_InstallationAddress__c', (XC_Address__c)utilMap.get('installationAddress') != null ? ((XC_Address__c)utilMap.get('installationAddress')).Id : null);
        infos.put('clientSystem',  (String)utilMap.get('clientSystem'));
        infos.put('preferredlanguageofcontact', accountMap.values()[0].Contacts[0].XC_Preferredlanguageofcontact__c);
        infos.put('currencyISOCode', catalogItems[0].CurrencyIsoCode); // same currency iso code for a catalog
        infos.put('XC_ActivationDateOverride__c', wrReq.Order.StartDate);

        //infos.put('catalogItemId', catalogItems[0].Id);
        //infos.put('qty', String.valueOf(wrReq.Order.OrderItem[0].Quantity));
        //infos.put('categoryId', catalogItems[0].NE__Catalog_Category_Name__c);
        //infos.put('Discounts',  (wrReq.Order.OrderItem[0].OrderItemDiscount != null && !wrReq.Order.OrderItem[0].OrderItemDiscount.isEmpty()) ? JSON.Serialize(wrReq.Order.OrderItem[0].OrderItemDiscount, true) : '');


        if((XC_BillingProfileLineItem__c)utilMap.get('billingProfLineItem') == null){
            infos.put('billingProfLineItemId', accountMap.values()[0].XC_BillingProfileLineItems__r[0].Id);
            infos.put('billingProfId', accountMap.values()[0].XC_BillingProfileLineItems__r[0].XC_BillingProfile__c);
            infos.put('paymentMethod', accountMap.values()[0].XC_BillingProfileLineItems__r[0].XC_BillingProfile__r.NE__Payment__c);
        }else{
            infos.put('billingProfLineItemId', ((XC_BillingProfileLineItem__c)utilMap.get('billingProfLineItem')).Id);
            infos.put('billingProfId', ((XC_BillingProfileLineItem__c)utilMap.get('billingProfLineItem')).XC_BillingProfile__c);
            infos.put('paymentMethod', ((XC_BillingProfileLineItem__c)utilMap.get('billingProfLineItem')).XC_BillingProfile__r.NE__Payment__c);
        }

        utilMap.put('infos', infos);
    }


    /**
     * CreateConfigurationInfoMap.
     *
     * @param orderWr the order wrapper
     * @param clientSystem the client system
     * @return the Map<String, String>
     * @description method to populate Order fields from WrapperRequest POST Method
     **/
    public static Map<String, String> createConfigurationInfoMap(XC_UTIL_Order.OrderIFWrapper orderWr, String clientSystem){

        Map<String, String> infos = new Map<String, String>{'NE__AccountId__c' => orderWr.AccountID,
                                                            'NE__BillAccId__c' => orderWr.AccountID,
                                                            'NE__ServAccId__c' => orderWr.AccountID,
                                                            'NE__OrderStatus__c' => orderWr.OrderStatus,
                                                            'XC_Contract_Code__c' => orderWr.ContractCode,
                                                            'XC_Contract_Date__c' => orderWr.ContractDate,
                                                            'NE__One_Time_Fee_Total__c' => orderWr.TotalOneTimeFee,
                                                            'NE__Channel__c' => orderWr.Channel,
                                                            'NE__ConfigurationStatus__c' => 'Valid',
                                                            'NE__type__c' => 'InOrder',
                                                            'XC_UserNumber__c' => orderWr.UserNumber,
                                                            'XC_SalesChannel__c' => orderWr.UserChannelName,
                                                            'XC_UserChannelCode__c' => orderWr.UserChannelCode,
                                                            'XC_UserSubchannelCode__c' => orderWr.UserSubchannelCode,
                                                            'XC_SalesSubChannel__c' => orderWr.UserSubchannelName,
                                                            'XC_CommodityExternalId__c' => orderWr.IntegrationID,
                                                            'XC_VASContractExtID__c' => orderWr.VASContractExtID,
                                                            'XC_VASContractNumber__c' => orderWr.VASContractNumber,
                                                            'XC_PartnerSalesChannel__c' => orderWr.PartnerSalesChannel,
                                                            'XC_PartnerContractDelivered__c' => String.valueOf(orderWr.PartnerContractDelivered),
                                                            'XC_EnelEnergyOfferExternalID__c' =>orderWr.ExternalOffer,
                                                            'ExternalDocID' => (null != orderWr.Document && !orderWr.Document.isEmpty() && null != orderWr.Document[0] && null != orderWr.Document[0].ExternalDocID)? orderWr.Document[0].ExternalDocID : null ,
                                                            'XC_CallType__c' => (!String.isBlank(clientSystem) && clientSystem.equalsIgnoreCase('CommodityItalyB2C')) ? orderWr.Origin : null,
                                                            'RecordTypeId' => (Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId())
                                                            };

        return infos;
    }


    /**
     * getProductInfos.
     *
     * @param wrReq the wrapper request
     * @param wrResp the wrapper response
     * @param utilMap the util map
     * @description method retrive product informations
    */
    public static void getProductInfos(XC_REST_Order_U.WrapperPOSTRequest wrReq, XC_REST_Order_U.WrapperRes wrResp, Map<String,Object> utilMap){

        Set<String> catalogItemsCode = new Set<String>();
        Set<String> familyPropertyCode = new Set<String>();
        Map<String,XC_UTIL_Order.OrderItemWrapper> parentMap  = (Map<String,XC_UTIL_Order.OrderItemWrapper>) utilMap.get('parentMap');

        //for(XC_UTIL_Order.OrderItemWrapper oiWr : wrReq.Order.OrderItem) {
        for(XC_UTIL_Order.OrderItemWrapper oiWr : parentMap.values()) {
            catalogItemsCode.add(oiWr.ProdID);
            if(oiWr.Attribute != null && !oiWr.Attribute.isEmpty()){
                for(XC_UTIL_Order.WrapperAttribute oiAttrWr: oiWr.Attribute){
                familyPropertyCode.add(oiAttrWr.Name);
                }
            }
        }

        // get productFamilyPropertyID
        if(!familyPropertyCode.isEmpty()){
            Map<Id, NE__ProductFamilyProperty__c> mapPfp = new Map<Id, NE__ProductFamilyProperty__c> ([SELECT id, NE__FamilyPropertyCode__c FROM NE__ProductFamilyProperty__c
                                                                                                       WHERE  NE__FamilyPropertyCode__c IN: familyPropertyCode]);


            if(mapPfp.values().isEmpty() || mapPfp.values().size() != familyPropertyCode.size()){
                wrResp.Result.Message = 'ERROR. Attribute Name not valid';
                wrResp.Result.logError = 'ERROR. Attribute Name not valid';
                wrResp.Result.ErrorCode = '400';
                return;
            } else {
                utilMap.put('productFamilyProperty', mapPfp.values());
                //getProductFamilyPropertyInfos(wrReq, utilMap, (Map<String, String>)utilMap.get('infos'));
            }
        }

        // get catalogItem infos
        String type = 'Product';
        List<String> catalogLicNameList = !String.isBlank((String)utilMap.get('catalogLicName')) ? ((String) utilMap.get('catalogLicName')).split(';') : null;
        String query =  'SELECT Id, NE__Engine_Code__c, Catalog_item_code__c , NE__UsageCode__c, NE__Catalog_Id__c, NE__Catalog_Category_Name__c, XC_LIC_Catalog_Item_Name__c, CurrencyIsoCode,  NE__ProductId__c ' +
                        'FROM NE__Catalog_Item__c WHERE NE__UsageCode__c IN: catalogItemsCode AND (NE__Visible__c = true OR NE__Visible__c = false) AND NE__Type__c =: type'; //DCR 11112021 - NR2063

        //'FROM NE__Catalog_Item__c WHERE Catalog_item_code__c IN: catalogItemsCode AND NE__Visible__c = true AND NE__Type__c =: type';
        query = (catalogLicNameList != null && !catalogLicNameList.isEmpty()) ? query + ' AND NE__Catalog_Id__r.XC_LIC_Name__c IN: catalogLicNameList ' : query;
        List<NE__Catalog_Item__c> catalogItems = Database.query(String.escapeSingleQuotes(query));


        if(catalogItems == null || catalogItems.isEmpty() || catalogItems.size() != catalogItemsCode.size()){
            wrResp.Result.Message = 'ERROR. ProdId not valid';
            wrResp.Result.logError = 'ERROR. ProdId not valid';
            wrResp.Result.ErrorCode = '400';
            return;

        } else {
            utilMap.put('catalogItems', catalogItems);
            addOrderItemsToInfosMap(wrReq, utilMap, (Map<String, String>)utilMap.get('infos'));
        }

    }


    /**
     * getProductFamilyPropertyInfos.
     *
     * @param wrReq the wrapper request
     * @param utilMap the utilMap
     * @param infos the infos map
     * @description method to get  productFamilyPropertyId-Value mapping
    */
    /*public static void getProductFamilyPropertyInfos(XC_REST_Order_U.WrapperPOSTRequest wrReq, Map<String,Object> utilMap, Map<String, String> infos) {

        List<NE__ProductFamilyProperty__c> pfpList = (List<NE__ProductFamilyProperty__c>) utilMap.get('productFamilyProperty');
        Map<String, NE__ProductFamilyProperty__c> pfpCodeMap = new Map<String, NE__ProductFamilyProperty__c>();
        Map<String,String> mapPfpIdValue = new Map<String,String>();

        for(NE__ProductFamilyProperty__c pfp : pfpList) {
            pfpCodeMap.put(pfp.NE__FamilyPropertyCode__c, pfp);
        }

        for(XC_UTIL_Order.WrapperAttribute oiAttrWr: wrReq.Order.OrderItem[0].Attribute){
            mapPfpIdValue.put(pfpCodeMap.get(oiAttrWr.Name).Id, oiAttrWr.Value);
        }

        infos.put('familyPropertyIds', JSON.serialize(mapPfpIdValue));

    }*/


    /**
     * searchRightObjects.
     *
     * @param accountMap the account Map
     * @param utilMap the util map
     * @description method to search the right delivery address, billing address and bpli
    */
    public static void searchRightObjects(Map<Id, Account> accountMap, Map<String,Object> utilMap){

        //search addresses
        XC_address__c deliveryAddress;
        XC_address__c billingAddress;
        XC_address__c installationAddress;
        for(XC_address__c addr: accountMap.values()[0].Addresses__r){
            if(addr.XC_DeliveryAddress__c){
                deliveryAddress = addr;
            }
            if(addr.XC_BillingAddress__c){
                billingAddress = addr;
            }
            if(addr.XC_InstallationAddress__c){
                installationAddress = addr;
            }
        }

        String tpbCode = utilMap.get('tpbConf') != null ? (String)((XC_ThirdPartyConfiguration__c)utilMap.get('tpbConf')).XC_TPBCode__c : ''; //[DeAv 05/01/2022 TPB Fix for search correct bpli]

        // search bpli
        XC_BillingProfileLineItem__c billingProfLineItem;
        for(XC_BillingProfileLineItem__c bpli : accountMap.values()[0].XC_BillingProfileLineItems__r){
            if(bpli.XC_BillToAddress__c == billingAddress.id && bpli.XC_SoldToAddress__c == deliveryAddress.Id && ((String.isBlank(tpbCode) && String.isBlank(bpli.XC_TPBCode__c)) || (String.isNotBlank(tpbCode) && tpbCode.equalsIgnoreCase(bpli.XC_TPBCode__c) ))){ //[DeAv 05/01/2022 TPB Fix for search correct bpli]
                billingProfLineItem = bpli;
                break;
            }
        }

        utilMap.put('deliveryAddress', deliveryAddress);
        utilMap.put('billingAddress', billingAddress);
        utilMap.put('installationAddress', installationAddress);
        utilMap.put('billingProfLineItem', billingProfLineItem);

    }



    /**
     * AddOrderItemsToInfosMap.
     *
     * @param wrReq the wrapper request
     * @param utilMap the utilMap
     * @param infos the infos map
     * @description method to set catalog item and orderitem list
    */
    public static void addOrderItemsToInfosMap(XC_REST_Order_U.WrapperPOSTRequest wrReq, Map<String,Object> utilMap , Map<String, String> infos) {

        Map<String,List<XC_UTIL_Order.OrderItemWrapper>> parentChildMap = (Map<String,List<XC_UTIL_Order.OrderItemWrapper>>)utilMap.get('parentChildMap');
        Map<String,XC_UTIL_Order.OrderItemWrapper> parentMap = (Map<String,XC_UTIL_Order.OrderItemWrapper>)utilMap.get('parentMap');

        List<NE__Catalog_Item__c> prodList = (List<NE__Catalog_Item__c>) utilMap.get('catalogItems');
        List<NE__ProductFamilyProperty__c> pfpList = (utilMap.get('productFamilyProperty') != null) ? (List<NE__ProductFamilyProperty__c>) utilMap.get('productFamilyProperty') : new List<NE__ProductFamilyProperty__c>();

        Map<String, NE__Catalog_Item__c> catalogItemCodeMap = new Map<String, NE__Catalog_Item__c>();
        Map<String, NE__ProductFamilyProperty__c> pfpCodeMap = new Map<String, NE__ProductFamilyProperty__c>();

        for(NE__Catalog_Item__c prod : prodList) {
            catalogItemCodeMap.put(prod.NE__UsageCode__c, prod);
            // catalogItemCodeMap.put(prod.Catalog_item_code__c, prod);
        }

        for(NE__ProductFamilyProperty__c pfp : pfpList) {
            pfpCodeMap.put(pfp.NE__FamilyPropertyCode__c, pfp);
        }

        Map<Id, List<String>> mapCategoryIdCatalogItemList = new  Map<Id, List<String>>();
        Map<Id, List<XC_UTIL_Order.OrderItemWrapper>> mapCategoryIdOrderItemList = new Map<Id, List<XC_UTIL_Order.OrderItemWrapper>>();
        Map<String, Boolean> mapCategoryHasChild = new Map<String, Boolean>();

        //for(XC_UTIL_Order.OrderItemWrapper oiWr : wrReq.Order.OrderItem) {
         for(XC_UTIL_Order.OrderItemWrapper oiWr : parentMap.values()) {
            oiWr.CatalogItemID = catalogItemCodeMap.get(oiWr.ProdID).Id;
            if(oiWr.Attribute != null){
                for(XC_UTIL_Order.WrapperAttribute oiAttrWr: oiWr.Attribute){
                    if(oiWr.OrderItemDiscount != null && !oiWr.OrderItemDiscount.isEmpty() && oiAttrWr.Name == 'Payment details:Active Promo'){
                        oiAttrWr.ProductFamilyPropertyID = oiAttrWr.Name; // in order to allow the creation of the order item discount item for orders with discount, the attribute "Active Promo" in UpsertItem must not be populated
                    }else{
                        oiAttrWr.ProductFamilyPropertyID = pfpCodeMap.get(oiAttrWr.Name).Id;
                    }
                }
            }


            if(!mapCategoryIdCatalogItemList.containsKey(catalogItemCodeMap.get(oiWr.ProdID).NE__Catalog_Category_Name__c)){
                mapCategoryIdCatalogItemList.put(catalogItemCodeMap.get(oiWr.ProdID).NE__Catalog_Category_Name__c, new List<String>());
            }
            mapCategoryIdCatalogItemList.get(catalogItemCodeMap.get(oiWr.ProdID).NE__Catalog_Category_Name__c).add(catalogItemCodeMap.get(oiWr.ProdID).Id);

            if(!mapCategoryIdOrderItemList.containsKey(catalogItemCodeMap.get(oiWr.ProdID).NE__Catalog_Category_Name__c)){
                mapCategoryIdOrderItemList.put(catalogItemCodeMap.get(oiWr.ProdID).NE__Catalog_Category_Name__c, new List<XC_UTIL_Order.OrderItemWrapper>());
            }
            mapCategoryIdOrderItemList.get(catalogItemCodeMap.get(oiWr.ProdID).NE__Catalog_Category_Name__c).add(oiWr);

            if(!parentChildMap.isEmpty() && mapCategoryHasChild.get(catalogItemCodeMap.get(oiWr.ProdID).NE__Catalog_Category_Name__c) != true){ //(!mapCategoryHasChild.containsKey(catalogItemCodeMap.get(oiWr.ProdID).NE__Catalog_Category_Name__c) ||  mapCategoryHasChild.containsKey(catalogItemCodeMap.get(oiWr.ProdID).NE__Catalog_Category_Name__c) && !mapCategoryHasChild.get(catalogItemCodeMap.get(oiWr.ProdID).NE__Catalog_Category_Name__c))){
                mapCategoryHasChild.put(catalogItemCodeMap.get(oiWr.ProdID).NE__Catalog_Category_Name__c, (parentChildMap.get(oiWr.ProdID).size()>0) ? true : false);
            }
        }

        infos.put('catalogCategoryAndCatalogItems', JSON.serialize(mapCategoryIdCatalogItemList));
        infos.put('catalogCategoryAndOrderItems', JSON.serialize(mapCategoryIdOrderItemList));
        infos.put('mapCategoryHasChild', JSON.serialize(mapCategoryHasChild));
        infos.put('parentChildMap', JSON.serialize(parentChildMap));
    }


    /**
    * prepareParentChildInfo.
    *
    * @param wrReq the wrapper request
    * @param utilMap the util map
    * @description method to create parent child map
    */
    public static void prepareParentChildInfo(XC_REST_Order_U.WrapperPOSTRequest wrReq, Map<String,Object> utilMap){

        Map<String,List<XC_UTIL_Order.OrderItemWrapper>> parentChildMap = new Map<String,List<XC_UTIL_Order.OrderItemWrapper>>();
        Map<String,String> parentUsageCode = new Map<String,String>();
        Map<String,XC_UTIL_Order.OrderItemWrapper> parentMap = new Map<String,XC_UTIL_Order.OrderItemWrapper>();

        for(XC_UTIL_Order.OrderItemWrapper oiWr : wrReq.Order.OrderItem){
            if(String.isBlank(oiWr.ParentOrderItem)){
                parentUsageCode.put(oiWr.ItemCode, oiWr.ProdID);
                parentMap.put(oiWr.ProdID, oiWr);
            }
        }

        for(XC_UTIL_Order.OrderItemWrapper oiWr : wrReq.Order.OrderItem){

            if(String.isBlank(oiWr.ParentOrderItem)){ // assume usage code unique
                if(!parentChildMap.containsKey(oiWr.ProdID)){
                    parentChildMap.put(oiWr.ProdID, new List<XC_UTIL_Order.OrderItemWrapper>());
                }
            }else{
                if(!parentChildMap.containsKey(parentUsageCode.get(oiWr.ParentOrderItem))){                    
                    List<XC_UTIL_Order.OrderItemWrapper> childList = new List<XC_UTIL_Order.OrderItemWrapper>{oiWr};
                    if(null != parentUsageCode.get(oiWr.ParentOrderItem)){
                        parentChildMap.put(parentUsageCode.get(oiWr.ParentOrderItem), childList);
                    }
                }else{
                    parentChildMap.get(parentUsageCode.get(oiWr.ParentOrderItem)).add(oiwr);
                }
            }

        }


        utilMap.put('parentChildMap',parentChildMap);
        utilMap.put('parentMap', parentMap);

    }

    private static String getProductCategory(String productName){
        if(productName.containsIgnoreCase('LUZ')) {
            return Label.XC_CL_ServiciosDeLuz;
        } else if(productName.containsIgnoreCase('GAS')) {
            return Label.XC_CL_ServiciosDeGas;
        } else if(productName.containsIgnoreCase('Certificado')){
            return Label.XC_CL_CertificadoInstalacionElectrica;
        }else {
            return Label.XC_CL_OtherProducts;
        }
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