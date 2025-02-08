/**
 * The Class XC_REST_MobilityOrder_V.
 *
 * @author            : Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 30/04/2019
 * @date Modification : dd/mm/yyyy
 * @description       : UTIL for XC_REST_MobilityOrder
 **/ 


public without sharing class XC_REST_MobilityOrder_V {

        
    /**
     * ValidateRequest.
     *
     * @param wr the wrapper request
     * @param mapHeader the map header
     * @param method the method
     * @return the wrapper result
     * @description method to verify if required parameters are correctly filled
     */   
    public static XC_UTIL_Integration.WrapperResult validateRequest(XC_REST_MobilityOrder_W.WrapperRequest wr, Map<String,String> mapHeader, String method){
        
        XC_UTIL_Integration.WrapperResult validateResult;

        if(method == 'PUT'){
            validateResult = XC_UTIL_RESTInbound.checkObjectPermission('NE__Order__c', 'update');
        } else {
            validateResult = XC_UTIL_RESTInbound.checkObjectPermission('NE__Order__c', 'create');
        }
    
        if(validateResult.errorFlag){
            return validateResult; 
        }   
        
        validateResult = XC_UTIL_Integration.validateHeader(mapHeader);
        if(validateResult.errorFlag) {
            return validateResult; 
        }

        if(mapHeader.get('Functionality') != 'OrderManagement'){
            validateResult.errorMessage = 'Wrong Functionality value';
            validateResult.errorFlag = true;
            return validateResult;
        }

        validateResult = validateOrder(wr, method);
        if(validateResult.errorFlag) {
            return validateResult; 
        }

        validateResult = validateOrderItem(wr, method);
        if(validateResult.errorFlag) {
            return validateResult;
        }

        if(method == 'PUT') {
            validateResult = validateBillingProfile(wr, method, null);
            if(validateResult.errorFlag) {
                return validateResult; 
            }
        }

        return validateResult;
    }


    /**
     * ValidateOrder.
     *
     * @param wr the wrapper request
     * @param method the method
     * @return the wrapper result
     * @description method to verify if Order required parameters are correctly filled
     */   
    public static XC_UTIL_Integration.WrapperResult validateOrder(XC_REST_MobilityOrder_W.WrapperRequest wr, String method){
        
        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

        if (method == 'POST' && wr.Order==null) {
            validateResult.errorMessage = 'Missing mandatory field: Order';
            validateResult.errorFlag = true;
            return validateResult; 
        }

        Map<String, String> requiredParameters = new Map<String, String>{'AccountID' => wr.Order.AccountID,
                                                                            'LegalEntity' => wr.Order.LegalEntity,
                                                                            'PaymentMode' => wr.Order.PaymentMode,
                                                                            'Channel' => wr.Order.Channel,
                                                                            'SubChannel' => wr.Order.SubChannel,
                                                                            'CreatedDate' => wr.Order.CreatedDate
                                                                        };
        for(String key : requiredParameters.keySet()) {
            if (method == 'POST' && String.isBlank(requiredParameters.get(key))) {
                validateResult.errorMessage = 'Missing mandatory field: Order.' + key;
                validateResult.errorFlag = true;
                return validateResult; 
            }
        }

        validateOtherOrderParameters(wr, method, validateResult);

        return validateResult;
    }


    /**
     * ValidateOtherOrderParameters.
     *
     * @param wr the wrapper request
     * @param method the method
     * @param validateResult the wrapper result
     * @description method to verify if Order required parameters are correctly filled
     */   
    public static void validateOtherOrderParameters(XC_REST_MobilityOrder_W.WrapperRequest wr, String method, XC_UTIL_Integration.WrapperResult validateResult) {

        if (method == 'PUT' && wr.Order != null && String.isBlank(wr.Order.OrderID)) {
            validateResult.errorMessage = 'Missing mandatory field: Order.OrderID';
            validateResult.errorFlag = true;
            return;
        }

        if (method == 'POST' && wr.Order.RegisteredOnRechargeApp==null) {
            validateResult.errorMessage = 'Missing mandatory field: Order.RegisteredOnRechargeApp';
            validateResult.errorFlag = true;
            return; 
        }
    }


    /**
     * ValidateOrderItem.
     *
     * @param wr the wrapper request
     * @param method the method
     * @return the wrapper result
     * @description method to verify if Order Item required parameters are correctly filled
     */   
    public static XC_UTIL_Integration.WrapperResult validateOrderItem(XC_REST_MobilityOrder_W.WrapperRequest wr, String method){
        
        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

        if(method == 'POST') {      // POST
            validateOrderItemPOST(wr, validateResult);

        } else {                    // PUT
            validateOrderItemPUT(wr, validateResult);
        }        

        return validateResult; 
    }


    /**
     * ValidateOrderItemPOST.
     *
     * @param wr the wrapper request
     * @param validateResult the result wrapper
     * @description method to verify if Order Item required parameters are correctly filled for POST method
     */   
    public static void validateOrderItemPOST(XC_REST_MobilityOrder_W.WrapperRequest wr, XC_UTIL_Integration.WrapperResult validateResult){
        
        if (wr.Order.OrderItemList == null || wr.Order.OrderItemList.isEmpty()) {
            validateResult.errorMessage = 'Missing mandatory field: Order.OrderItem';
            validateResult.errorFlag = true;
            return; 
        }

        Integer i = 1;
        for(XC_REST_MobilityOrder_W.OrderItemWrapper oiWr : wr.Order.OrderItemList) {

            if (String.isBlank(oiWr.EngineCode)) {
                validateResult.errorMessage = 'Missing mandatory field: Order.OrderItem.EngineCode in ' + i + '-th OrderItem';
                validateResult.errorFlag = true;
                return; 
            }

            if (oiWr.Quantity == null) {
                validateResult.errorMessage = 'Missing mandatory field: Order.OrderItem.Quantity in ' + i + '-th OrderItem';
                validateResult.errorFlag = true;
                return; 
            }

            i++;
        }
    }


    /**
     * ValidateOrderItemPUT.
     *
     * @param wr the wrapper request
     * @param validateResult the result wrapper
     * @description method to verify if Order Item required parameters are correctly filled for PUT method
     */   
    public static void validateOrderItemPUT(XC_REST_MobilityOrder_W.WrapperRequest wr, XC_UTIL_Integration.WrapperResult validateResult) {

        if (wr.Order.OrderItem == null) {
            validateResult.errorMessage = 'Missing mandatory field: Order.OrderItem';
            validateResult.errorFlag = true;
            return; 
        }

        Map<String, String> requiredParameters = new Map<String, String>{'OldAssetID' => wr.Order.OrderItem.OldAssetID,
                                                                            'OldSubscriptionID' => wr.Order.OrderItem.OldSubscriptionID,
                                                                            'NewEngineCode' => wr.Order.OrderItem.NewEngineCode
                                                                        };
        for(String key : requiredParameters.keySet()) {
            if (String.isBlank(requiredParameters.get(key))) {
                validateResult.errorMessage = 'Missing mandatory field: Order.OrderItem.' + key;
                validateResult.errorFlag = true;
                return;
            }
        }
        
        if (wr.Order.OrderItem.NewQuantity == null) {
            validateResult.errorMessage = 'Missing mandatory field: Order.OrderItem.NewQuantity';
            validateResult.errorFlag = true;
            return; 
        }
    }


    /**
     * ValidateBillingProfile.
     *
     * @param wr the wrapper request
     * @param method the method
     * @param prod the catalog item
     * @return the wrapper result
     * @description method to verify if Billing Profile required parameters are correctly filled
     */   
    public static XC_UTIL_Integration.WrapperResult validateBillingProfile(XC_REST_MobilityOrder_W.WrapperRequest wr, String method, NE__Catalog_Item__c prod){
            
        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();
    
        if (method == 'POST' && wr.BillingProfile==null && String.isBlank(wr.Order.CouponCode) && (String.isBlank(wr.Order.CostCenter) || String.isBlank(wr.Order.CompanyCode)) && !prod.XC_LIC_Catalog_Item_Name__c.containsIgnoreCase(Label.XC_CL_CatItem_DomesticOffer) && !prod.XC_Skip_Payment_Method__c) {
            validateResult.errorMessage = 'Missing mandatory field: BillingProfile';
            validateResult.errorFlag = true;
            return validateResult; 
        }

        if (wr.BillingProfile != null && String.isBlank(wr.BillingProfile.CreditCardExternalKey)) {
            validateResult.errorMessage = 'Missing mandatory field: BillingProfile.CreditCardExternalKey';
            validateResult.errorFlag = true;
            return validateResult;
        }
            
        return validateResult;
    }

}