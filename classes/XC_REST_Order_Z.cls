/**
 * @author :              Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation :       30/04/2019
 * @date Modification :   dd/mm/yyyy
 * @description :         XC_REST_Order_Z – Util for Validate to Create/Update/Read an Order
 * 
 */

public without sharing class XC_REST_Order_Z {
    /** 
    * @param header - Map<String,String>
    * @param wrReq - XC_REST_Order_U.WrapperPUTRequest
    * @param direction - String 
    * @return the x C UTI L integration. wrapper result
    * @description  validate an order reqest
    */
    public static XC_UTIL_Integration.WrapperResult validateReq(Map<String,Object> mapUtil){
        
        Map<String,String> header = (Map<String,String>) mapUtil.get('header');
        XC_REST_Order_U.WrapperRequest wrReq = (XC_REST_Order_U.WrapperRequest) mapUtil.get('wrReq');
        String direction = (String)  mapUtil.get('direction');

        XC_UTIL_Integration.WrapperResult validateResult;

        validateResult = XC_UTIL_Integration.validateHeader(header);
        if(validateResult.errorFlag){
            return validateResult;
        }

        validateResult = XC_REST_Order_Z.validateRequest(wrReq, header);
        if (validateResult.errorFlag) {
            return validateResult;
        }

        validateResult = XC_REST_Order_Z.validateOrderRequest(mapUtil);
        
        return validateResult;
    }

    
    /**
    * Validate request.
    *
    * @param wrReq the wr req
    * @param header
    * @return the x C UTI L integration. wrapper result
    * @description  validate the inbound request  
    */
    public static XC_UTIL_Integration.WrapperResult validateRequest(XC_REST_Order_U.WrapperRequest wrReq, Map<String,String> header) {  

        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult() ;
        
        if(wrReq instanceof XC_REST_Order_U.WrapperPUTRequest) {
            XC_REST_Order_U.WrapperPUTRequest putRequest = (XC_REST_Order_U.WrapperPUTRequest) wrReq;
            return XC_REST_Order_ZZ.validateRequestPUT(putRequest.Order);
        }
        
        if(wrReq instanceof XC_REST_Order_U.WrapperPOSTRequest) {
            XC_REST_Order_U.WrapperPOSTRequest postRequest = (XC_REST_Order_U.WrapperPOSTRequest) wrReq;
            return validateRequestPOST(postRequest.Order, header);
        }
        
        if(wrReq instanceof XC_REST_Order_U.WrapperGETRequest) {
            XC_REST_Order_U.WrapperGETRequest getRequest = (XC_REST_Order_U.WrapperGETRequest)wrReq;
            
            if(getRequest.OrderID == null || getRequest.OrderID.size() == 0){
                validateResult.errorMessage = 'Missing Order IDs to retrieve!';
                validateResult.errorFlag = true;
            }
        }
                        
        return validateResult;
    }


     /**
    * Validate request POST.
    *
    * @param ord the ord
    * @param header
    * @return the x C UTI L integration. wrapper result
    * @description validate an order reqest
    */
    public static XC_UTIL_Integration.WrapperResult validateRequestPOST(XC_UTIL_Order.OrderIFWrapper ord, Map<String,String> header) {    
        
        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();
        
        //Check mandatory fields
        if(ord==null){
            validateResult.errorMessage = 'Missing mandatory field: Order';
            validateResult.errorFlag = true;
            return validateResult;
        }
        validateOrderPOSTUtil(ord, header, validateResult);
        if(validateResult.errorFlag){
            return validateResult;
        }
        if (String.isBlank(ord.AccountID)&&header.get('ClientSystem')!='CommoditySpainB2C'){
            validateResult.errorMessage = 'Missing mandatory field: Order.AccountID';
            validateResult.errorFlag = true;
            return validateResult;
        }       
        if (String.isBlank(ord.OrderStatus)){
            validateResult.errorMessage = 'Missing mandatory field: Order.OrderStatus';
            validateResult.errorFlag = true;
            return validateResult;
        }
        if (ord.OrderStatus != Label.XC_CL_InProgress){
            validateResult.errorMessage = 'Order.OrderStatus must be equal to In progress';
            validateResult.errorFlag = true;
            return validateResult;
        }
        if (ord.OrderItem == null || ord.OrderItem.size() == 0) {
            validateResult.errorMessage = 'Missing mandatory field: Order.OrderItem';
            validateResult.errorFlag = true;
            return validateResult;
        }
        


        validateResult = validateDiscountRequest(ord, 'POST');
        
        return validateResult;
    }


    /**
    * @param ord
    * @param header
    * @param validateResult
    * @description  validate orderItem util POST
    */
    public static void validateOrderPOSTUtil(XC_UTIL_Order.OrderIFWrapper ord, Map<String,String> header, XC_UTIL_Integration.WrapperResult validateResult){
        
        List<String> clientSystem = new List<String>{'XRecharge','XInstaller', 'E-Commerce', 'Partner', 'CommoditySpainB2C'};

        if(clientSystem.contains(header.get('ClientSystem')) && String.isBlank(ord.LegalEntity)){ 
            validateResult.errorFlag= true;
            validateResult.errorMessage = 'Missing mandatory field: Order.LegalEntity';
            return;
        }

        Map<String, String> fields = new Map<String, String>{ 
            'Channel' => ord.Channel, 
            'ContractId' => ord.ContractId, 
            'OrderType' => ord.OrderType, 
            'DeactivationBasedOnRegulatory' => ord.DeactivationBasedOnRegulatory,
            'BillingAddressData' => ord.BillingAddressData,
            'InstallationAddressData' => ord.InstallationAddressData
        };

        if(header.get('ClientSystem') == 'CommoditySpainB2C'){

            if(String.isBlank(ord.AccountID)&&String.isBlank(ord.AccountFiscalCode)){
                validateResult.errorFlag= true;
                validateResult.errorMessage = 'Missing one of this field: Order.AccountID, Order.AccountFiscalCode';
                return;
            }

            for(String field : fields.KeySet()) {
                if(string.isBlank(fields.get(field))) {
                    validateResult.errorMessage = 'ERROR. Missing mandatory field: Order.'+field;
                    validateResult.errorFlag = true;
                    return;
                } 
            }

        }
       

        /*// check manadatory fields - they can be also blank fields.
        clientSystem.remove(4);
        Map<String, Object> mandatoryFields = new Map<String, Object>{ 
                                                                        'CatalogID' => ord.CatalogID, 
                                                                        'CommercialModelID' => ord.CommercialModelID, 
                                                                        'TotalOneTimeFee' => ord.TotalOneTimeFee, 
                                                                        'TotalRecurringCharge' => ord.TotalRecurringCharge,
                                                                        'TotalRecurringFrequency' => ord.TotalRecurringFrequency,
                                                                        'EngineType' => ord.EngineType,
                                                                        'PriceListVersion' => ord.PriceListVersion,
                                                                        'PriceListName' => ord.PriceListName
                                                                    };
        for(String key : mandatoryFields.keySet()){
            if(clientSystem.contains(header.get('ClientSystem')) && mandatoryFields.get(key) == null){
                validateResult.errorFlag= true;
                validateResult.errorMessage = 'Missing mandatory field: Order.'+ key;
                return;
            }
        } */
       
    }

    /**
    * Validate order request.
    *
    * @param mapUtil the req
    * @return the x C UTI L integration. wrapper result
    * @description  validate the order item/order items inside the request 
    */
    public static XC_UTIL_Integration.WrapperResult validateOrderRequest(Map<String,Object> mapUtil){
        
        String clientSystem = ((Map<String,String>) mapUtil.get('header')).get('ClientSystem');
        XC_REST_Order_U.WrapperRequest req = (XC_REST_Order_U.WrapperRequest) mapUtil.get('wrReq');
        String direction = (String)  mapUtil.get('direction');

        XC_UTIL_Integration.WrapperResult validateResult;


        XC_UTIL_Integration.WrapperResult wr = new XC_UTIL_Integration.WrapperResult();

        Set<Id> accountToQuery = new Set<Id>();
        Set<Id> opportunityToQuery = new Set<Id>();
        Set<Id> productToQuery = new Set<Id>();

        // for POST
        if(req instanceof XC_REST_Order_U.WrapperPOSTRequest){
            // SINGLE ORDER
            XC_REST_Order_U.WrapperPOSTRequest postRequest = (XC_REST_Order_U.WrapperPOSTRequest)req;

            accountToQuery.add(postRequest.order.AccountID);
            if(!String.isBlank(postRequest.order.OpportunityID)) {
                opportunityToQuery.add(postRequest.order.OpportunityID);
            }

            Integer j = 1;
            for(XC_UTIL_Order.OrderItemWrapper orderItem : postRequest.order.OrderItem){

                Map<String,Object> utilMap = new Map<String,Object>{
                                                            'orderItem' => orderItem,
                                                            'j' => j, 
                                                            'wr' => wr,
                                                            'clientSystem' => clientSystem,
                                                            'direction'=> direction
                                                            };
                XC_REST_Order_ZZ.validateOrdItemPOST(utilMap);
                if(wr.errorFlag){
                    return wr;
                }
                j++;
                productToQuery.add(orderItem.ProdID);
                
            }

            Map<String,Object> utilMapPOST = new Map<String,Object>{
                                                            'req' => req,
                                                            'wr' => wr,
                                                            'productToQuery' => productToQuery,
                                                            'opportunityToQuery'=> opportunityToQuery,
                                                            'accountToQuery' => accountToQuery,
                                                            'clientSystem' => clientSystem
                                                            };

            XC_REST_Order_Z.checkPOSTReq(utilMapPOST, ((Map<String,String>) mapUtil.get('header')));
            if(wr.errorFlag){
                return wr;
            }

            /*
                    //UniqueID Check
                    //tbd
            if(clientSystem == 'E-Commerce'){
                wr = XC_UTIL_RESTInbound.wso2AuthCheck(((XC_REST_Order_U.WrapperPOSTRequest)req).Order.AccountID, ((Map<String,String>) mapUtil.get('header')));
                if(wr.errorFlag) {
                    return wr;
                }
            }
            */

            mapUtil.put('Account', utilMapPOST.get('Account'));
        }

        // for PUT
        if(req instanceof XC_REST_Order_U.WrapperPUTRequest){
            Map<String,Object> utilMapPUT = new Map<String,Object>{
                                                            'req' => req,
                                                            'wr' => wr,
                                                            'productToQuery' => productToQuery,
                                                            'opportunityToQuery'=> opportunityToQuery,
                                                            'accountToQuery' => accountToQuery
                                                            };

            XC_REST_Order_ZZ.checkPUTReq(req, wr);
            if(wr.errorFlag){
                return wr;
            }

            //UniqueID Check
            if(String.isNotBlank(((Map<String,String>)mapUtil.get('header')).get('X-UniqueID'))){
                wr = XC_UTIL_RESTInbound.wso2AuthCheck(((XC_REST_Order_U.WrapperPUTRequest)req).Order.OrderID, ((Map<String,String>) mapUtil.get('header')));
                if(wr.errorFlag) {
                    return wr;
                }
            }

            wr = validateDiscountRequest(((XC_REST_Order_U.WrapperPUTRequest)req).Order, 'PUT');

        }
        
        return wr;
    }

    
    /** 
    * @param utilMapPOST - Map<String,Object>
    * @description check POST Req ID
    */
    public static void checkPOSTReq(Map<String,Object> utilMapPOST, Map<String,String> header){

        String clientSystem = (String)utilMapPOST.get('clientSystem');
        XC_REST_Order_U.WrapperPOSTRequest req = (XC_REST_Order_U.WrapperPOSTRequest) utilMapPOST.get('req');
        XC_UTIL_Integration.WrapperResult wr = (XC_UTIL_Integration.WrapperResult) utilMapPOST.get('wr');
        Set<Id> productToQuery = (Set<Id>) utilMapPOST.get('productToQuery');
        Set<Id> opportunityToQuery = (Set<Id>) utilMapPOST.get('opportunityToQuery');
        Set<Id> accountToQuery = (Set<Id>) utilMapPOST.get('accountToQuery');
        Map<Id, Account> accounts = new Map<Id, Account>();

        if(clientSystem=='CommoditySpainB2C'){ 
            accounts = getAccount(req, opportunityToQuery);
            if(accounts.values().isEmpty()){
                wr.errorMessage = 'AccountID not found';
                wr.errorFlag = true;
                return;
            } if(accounts.values()[0].Addresses__r.isEmpty()){
                wr.errorMessage = 'Address not found';
                wr.errorFlag = true;
                return;
            } 

        } else {
            accounts = new Map<Id,Account>([SELECT Id, XC_Segment__c,
                                            (SELECT Id, XC_CampaignPlatform__c, XC_CampaignProduct__c, XC_CampaignCode__c, XC_ConventionCode__c, XC_Ecid__c FROM Opportunities WHERE Id =: opportunityToQuery), 
                                            (SELECT Id, XC_InstallationAddress__c FROM Addresses__r LIMIT 1), 
                                            (SELECT Id FROM Contacts WHERE XC_PrimaryContact__c = true) FROM Account WHERE Id =: accountToQuery]);
            if(!accounts.containsKey(req.Order.AccountID)){
                wr.errorMessage = 'AccountID not found';
                wr.errorFlag = true;
                return;
            }
        }
        
        Map<Id, NE__Product__c> products = new Map<ID,NE__Product__c>([SELECT Id, (SELECT Id, Name FROM NE__ProductFamily__r) FROM NE__Product__c WHERE Id =: productToQuery]);

        if(String.isNotBlank(req.Order.OpportunityID) && accounts.get(req.Order.AccountID).opportunities.isEmpty()){
            wr.errorMessage  = 'OpportunityID not found';
            wr.errorFlag = true;
            return;
        }

        /*
        for(XC_UTIL_Order.OrderItemWrapper orderItem : postRequest.Order.OrderItem){
            if(!products.containsKey(orderItem.ProdID)){
                wr.errorMessage = 'ProdID ' + orderItem.ProdID +' not found';
                wr.errorFlag = true;
                return;
            }
        }
        */

        utilMapPOST.put('Account', accounts);
        utilMapPOST.put('Products', products);
    }



    private static XC_UTIL_Integration.WrapperResult validateDiscountRequest(XC_UTIL_Order.OrderIFWrapper ord, String method){ 
        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

        if(ord.OrderItem==null){
            return validateResult;
        }

        for(XC_UTIL_Order.OrderItemWrapper orderItem : ord.OrderItem){
            if (orderItem.OrderItemDiscount==null||orderItem.OrderItemDiscount.isEmpty()) {
                continue;
            }

            for(XC_UTIL_Order.WrapperDiscount discount : orderItem.OrderItemDiscount){
                if(method == 'PUT' && !String.isBlank(discount.OrderItemDiscountID)){
                    continue;
                }
                if (String.isBlank(discount.Code)) {
                    validateResult.errorMessage = 'Missing mandatory field: OrderItem.OrderItemDiscount.Code';
                    validateResult.errorFlag = true;
                    return validateResult;
                }
                if (discount.OneTimePrice==null) {
                    validateResult.errorMessage = 'Missing mandatory field: OrderItem.OrderItemDiscount.OneTimePrice';
                    validateResult.errorFlag = true;
                    return validateResult;
                }
                if (discount.OneTimeValue==null) {
                    validateResult.errorMessage = 'Missing mandatory field: OrderItem.OrderItemDiscount.OneTimeValue';
                    validateResult.errorFlag = true;
                    return validateResult;
                }
            }
            
        }
        return validateResult;
    }

    public static Map<Id, Account> getAccount(XC_REST_Order_U.WrapperPOSTRequest req, Set<Id> opportunityToQuery){

        String condition = '';
        if(!String.isBlank(req.Order.AccountID)){
            String var = req.Order.AccountID;
            condition = 'WHERE id =: var';

        } else{

            String type = req.Order.AccountFiscalCode.replace('|', ',').split(',')[0];
            String num = req.Order.AccountFiscalCode.replace('|', ',').split(',')[1];
            condition = 'WHERE IdentityType__c =: type AND IdentityNumber__c =: num';
            System.debug('type ' + type);
            System.debug('num ' + num);
        }

        List<String> split_a = req.Order.BillingAddressData.replace('|', ',*').split(',');
        List<String> split_b = req.Order.InstallationAddressData.replace('|', ',*').split(',');

        String country_a = split_a[0].remove('*');
        String country_b = split_b[0].remove('*');
        String city_a = split_a[1].remove('*');
        String city_b = split_b[1].remove('*');
        String zipcode_a = split_a[2].remove('*');
        String zipcode_b = split_b[2].remove('*');
        String streetype_a = split_a[3].remove('*');
        String streetype_b = split_b[3].remove('*');
        String address_a = split_a[4].remove('*');
        String address_b = split_b[4].remove('*');
        String streetnumber_a = split_a[5].remove('*');
        String streetnumber_b = split_b[5].remove('*');
        String floor_a = (split_a[6]=='*') ? split_a[6].remove('*') : '';
        String floor_b = (split_b[6]=='*') ? split_b[6].remove('*') : '';
        String door_a = (split_a[7]=='*') ? split_a[7].remove('*') : '';
        String door_b = (split_b[7]=='*') ? split_b[7].remove('*') : '';

        String addressCondition1 = '(XC_AddressCountry__c =: country_a AND XC_City__c =: city_a AND XC_PostalCode__c =: zipcode_a AND XC_StreetTypeText__c =: streetype_a AND XC_StreetNumber__c =: streetnumber_a AND XC_Floor__c =: floor_a AND XC_Door__c =: door_a)';
        String addressCondition2 = ' OR (XC_AddressCountry__c =: country_b AND XC_City__c =: city_b AND XC_PostalCode__c =: zipcode_b AND XC_StreetTypeText__c =: streetype_b AND XC_StreetNumber__c =: streetnumber_b AND XC_Floor__c =: floor_b AND XC_Door__c =: door_b)';
       
        String queryString = 'SELECT Id, XC_Segment__c, (SELECT Id, XC_CampaignPlatform__c, XC_CampaignProduct__c, XC_CampaignCode__c, XC_ConventionCode__c, XC_Ecid__c FROM Opportunities WHERE Id =: opportunityToQuery), (SELECT Id, XC_InstallationAddress__c FROM Addresses__r WHERE (' + addressCondition1 + addressCondition2 + ')), (SELECT Id FROM Contacts WHERE XC_PrimaryContact__c = true) FROM Account ' + condition;
        System.debug('**query: ' + querystring);
        List<Account> accs = Database.query(String.escapeSingleQuotes(queryString));
        Map<Id, Account> accMap = new Map<Id, Account>();
        for(Account a : accs){
            accMap.put(a.id, a);
        }
        return accMap;
    }
}