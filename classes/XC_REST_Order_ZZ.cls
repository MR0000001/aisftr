/**
 * @author :              Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation :       30/04/2019
 * @date Modification :   dd/mm/yyyy
 * @description :         XC_REST_Order_ZZ – Util for Validate to Create/Update/Read an Order
 * 
 */

public without sharing class XC_REST_Order_ZZ {
     
    /**  
    * @param mapUtil - Map<String,Object> 
    * @description validate orderItem POST
    */
    public static void validateOrdItemPOST(Map<String,Object> mapUtil){

        XC_UTIL_Order.OrderItemWrapper orderItem = (XC_UTIL_Order.OrderItemWrapper) mapUtil.get('orderItem');
        Integer j = (Integer) mapUtil.get('j');
        XC_UTIL_Integration.WrapperResult wr = (XC_UTIL_Integration.WrapperResult) mapUtil.get('wr');
        String clientSystem = (String) mapUtil.get('clientSystem');
        String direction = (String) mapUtil.get('direction');

        if(String.IsBlank(orderItem.ProdID)){
            wr.errorMessage = 'Missing field: OrderItem.ProdID in '+ j + '-th OrderItem';
            wr.errorFlag = true;
            return;
        }

        /*
        if(String.IsBlank(orderItem.BillingProfileID)){
            wr.errorMessage = 'Missing field: OrderItem.BillingProfileID in '+ j + '-th OrderItem';
            wr.errorFlag = true;
            return;
        }*/

        if(orderItem.Quantity==null){
            wr.errorMessage = 'Missing field: OrderItem.Quantity in '+ j + '-th OrderItem';
            wr.errorFlag = true;
            return;
        }

        if(orderItem.BaseOneTimeFee == null && orderItem.BaseRecurringCharge == null){
            wr.errorMessage = 'Missing field: OrderItem.BaseOneTimeFee or OrderItem.BaseRecurringCharge in '+ j + '-th OrderItem';
            wr.errorFlag = true;
            return;
        }
        

        Map<String,Object> utilMap = new Map<String,Object>{
                                                            'direction' => direction,
                                                            'clientSystem' => clientSystem, 
                                                            'orderItem' => orderItem,
                                                            'wr' => wr,
                                                            'j' => j
                                                            };

        XC_REST_Order_ZZ.validateOrdItemPOSTUtil(utilMap);
        if(wr.errorFlag){
            return;
        }

        XC_REST_Order_ZZ.validateOrdItemAttr(orderItem, wr, j);
        if(wr.errorFlag){
            return;
        }

    }


    /**
    * @param mapUtil - Map<String,Object>
    * @description  validate orderItem util POST
    */
    public static void validateOrdItemPOSTUtil(Map<String,Object> mapUtil){

        String direction = (String) mapUtil.get('direction');
        String clientSystem = (String) mapUtil.get('clientSystem');
        XC_UTIL_Order.OrderItemWrapper orderItem = (XC_UTIL_Order.OrderItemWrapper) mapUtil.get('orderItem');
        XC_UTIL_Integration.WrapperResult wr = (XC_UTIL_Integration.WrapperResult) mapUtil.get('wr');
        Integer j = (Integer) mapUtil.get('j');

        if(direction != 'Inbound'){
            return;
        }
        
        if(clientSystem != 'CommoditySpainB2C' && String.IsBlank(orderItem.CatalogItemID)){
            wr.errorMessage = 'Missing field: OrderItem.CatalogItemID in '+ j + '-th OrderItem';
            wr.errorFlag = true;
            return ;
        } 

        if(clientSystem == 'CommoditySpainB2C'){
            Map<String, String> fields = new Map<String, String>{ 
                'OrderItemType' => orderItem.OrderItemType, 
                'OrderItemSubType' => orderItem.OrderItemSubType//, 
                //'BillingProfileData' => orderItem.BillingProfileData
            };

            for(String field : fields.KeySet()) {
                if(string.isBlank(fields.get(field))) {
                    wr.errorMessage = 'ERROR. Missing mandatory field: OrderItem.'+field+' in '+ j + '-th OrderItem';
                    wr.errorFlag = true;
                    return;
                } 
            }
        }


        /*// check manadatory fields - they can be also blank fields.
        List<String> clientSystemColumnC = new List<String>{'XRecharge','XInstaller', 'E-Commerce', 'Partner'};
        Map<String, Object> mandatoryFields = new Map<String, Object>{ 
                                                                        'OneTimeFeeDiscounted' => orderItem.OneTimeFeeDiscounted, 
                                                                        'PriceListVersionItem' => orderItem.PriceListVersionItem, 
                                                                        'PenaltyType' => orderItem.PenaltyType, 
                                                                        'Bundle' => orderItem.Bundle, 
                                                                        'GoodCost' => orderItem.GoodCost, 
                                                                        'BundleElement' => orderItem.BundleElement, 
                                                                        'Penalty' => orderItem.Penalty, 
                                                                        'Bit2WINTranslatedProductName' => orderItem.Bit2WINTranslatedProductName, 
                                                                        'PenaltyFee' => orderItem.PenaltyFee, 
                                                                        'RecurringChargeFrequency' => orderItem.RecurringChargeFrequency, 
                                                                        'UsageCode' => orderItem.UsageCode, 
                                                                        'RecurringChargeDiscounted' => orderItem.RecurringChargeDiscounted
                                                                    };
        for(String key : mandatoryFields.keySet()){
            if(clientSystemColumnC.contains(clientSystem) && mandatoryFields.get(key) == null){
                wr.errorMessage = 'ERROR. Missing mandatory field: OrderItem.'+key+' in '+ j + '-th OrderItem';
                wr.errorFlag = true;
                return;
            }
        } */
        
    }


    /**
    * @param orderItem - XC_UTIL_Order.OrderItemWrapper
    * @param wr - XC_UTIL_Integration.WrapperResult
    * @param j
    * @description  validate orderItemAttr POST
    */
    public static void validateOrdItemAttr(XC_UTIL_Order.OrderItemWrapper orderItem, XC_UTIL_Integration.WrapperResult wr, Integer j){

        if(orderItem.Attribute != null){
            Integer i=1;
            for(XC_UTIL_Order.WrapperAttribute wrAttr: orderItem.Attribute){
                system.debug('----> I' + i);
                if(String.isBlank(wrAttr.Name)){
                    wr.errorMessage = 'Missing field: OrderItem.Attribute.Name in '+ i + '-th OrderItem.Attribute of ' + j + '-th OrderItem' ;
                    wr.errorFlag = true;
                    return;
                }
                /*if(String.isBlank(wrAttr.Value)){
                    wr.errorMessage = 'Missing field: OrderItem.Attribute.Value in '+ i + '-th OrderItem.Attribute of ' + j + '-th OrderItem' ;
                    wr.errorFlag = true;
                    return;
                }*/ //GDB 23/12/19
                if(String.isBlank(wrAttr.ProductFamilyPropertyID)){
                    wr.errorMessage = 'Missing field: OrderItem.Attribute.ProductFamilyPropertyID in '+ i + '-th OrderItem.Attribute of' + j + '-th OrderItem';
                    wr.errorFlag = true;
                    return;
                }
                i++;
            }
        }
    }       
        

    /**
    *  Validate request PUT.
    *  @param order the order
    *  @return the x C UTI L integration. wrapper result
    *  @author       : Riccardo Cossu - riccardo.cossu@nttdata.com
    *  @date     : 11 / 12 / 2018 - LastModified : 04/04/19 Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
    *  @description  : validate multiple order reqest
    */
    public static  XC_UTIL_Integration.WrapperResult validateRequestPUT(XC_UTIL_Order.OrderIFWrapper order){
        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();
        
        if(order == null) {
            validateResult.errorFlag = true;
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' Order';
            return validateResult;
        }

        if(String.isBlank(order.OrderID)) {
            validateResult.errorFlag = true;
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' Order.OrderID';
            return validateResult;
        }
        
        return validateResult;
    }


    /**
    * @param req - WrapperRequest
    * @param wr - XC_UTIL_Integration.WrapperResult
    * @description check PUT Request
    */
    public static void checkPUTReq(XC_REST_Order_U.WrapperRequest req, XC_UTIL_Integration.WrapperResult wr){

        XC_REST_Order_U.WrapperPUTRequest putRequest = (XC_REST_Order_U.WrapperPUTRequest)req;
        if(putRequest.order.OrderItem != null) {
            for(XC_UTIL_Order.OrderItemWrapper orderItem : putRequest.order.OrderItem){
                if(String.IsBlank(orderItem.OrderItemID)){
                    wr.errorMessage = Label.XC_CL_MandatoryField + ' OrderItem.OrderItemID';
                    wr.errorFlag = true;
                    return;
                }
                if(orderItem.Attribute != null) {
                    for(XC_UTIL_Order.WrapperAttribute orderItemAttr : orderItem.Attribute){
                        if(String.isBlank(orderItemAttr.AttributeID)){
                            wr.errorMessage = Label.XC_CL_MandatoryField +  ' OrderItem.AttributeID';
                            wr.errorFlag = true;
                            return;
                        }
                    }
                }
                if (orderItem.OrderItemDiscount!=null&&!orderItem.OrderItemDiscount.isEmpty()) {
                    for(XC_UTIL_Order.WrapperDiscount discount : orderItem.OrderItemDiscount){
                        if (String.isBlank(discount.OrderItemID)) {
                            wr.errorMessage = 'Missing mandatory field: OrderItem.OrderItemDiscount.OrderItemID';
                            wr.errorFlag = true;
                            return;
                        }
                        if (String.isBlank(discount.Code)) {
                            wr.errorMessage = 'Missing mandatory field: OrderItem.OrderItemDiscount.Code';
                            wr.errorFlag = true;
                            return;
                        }
                        if (discount.OneTimePrice==null) {
                            wr.errorMessage = 'Missing mandatory field: OrderItem.OrderItemDiscount.OneTimePrice';
                            wr.errorFlag = true;
                            return;
                        }
                        if (discount.OneTimeValue==null) {
                            wr.errorMessage = 'Missing mandatory field: OrderItem.OrderItemDiscount.OneTimeValue';
                            wr.errorFlag = true;
                            return;
                        }
                        if (discount.RecurringPrice==null) {
                            wr.errorMessage = 'Missing mandatory field: OrderItem.OrderItemDiscount.RecurringPrice';
                            wr.errorFlag = true;
                            return;
                        }
                        if (discount.RecurringValue==null) {
                            wr.errorMessage = 'Missing mandatory field: OrderItem.OrderItemDiscount.RecurringValue';
                            wr.errorFlag = true;
                            return;
                        }
                        if (String.isBlank(discount.Status)) {
                            wr.errorMessage = 'Missing mandatory field: OrderItem.OrderItemDiscount.Status';
                            wr.errorFlag = true;
                            return;
                        }
                        if (discount.Type==null) {
                            wr.errorMessage = 'Missing mandatory field: OrderItem.OrderItemDiscount.Type';
                            wr.errorFlag = true;
                            return;
                        }
                    }
                }
            }
        }
    }
 

    /**
    * 
    * @param mapOrder - Map<String, Object>
    * @param wrResp - XC_REST_Order_U.WrapperRes 
    * @description  check Configuration object Ids 
    */
    public static void checkConfigurationObjectsId(Map<String, Object> mapOrder, XC_REST_Order_U.WrapperRes wrResp){
     
        Map<String, List<NE__Order_Item_Attribute__c>> mapOrdItemIdOIA=(Map<String, List<NE__Order_Item_Attribute__c>>) mapOrder.get('mapOrdItemIdOIA');
        XC_REST_Order_U.WrapperPUTRequest wrReq = (XC_REST_Order_U.WrapperPUTRequest) mapOrder.get('wrReq');

        //List<NE__Order__c> ordList = XC_REST_Order_U_D.getOrderById(wrReq.Order.OrderID);
        Map<Id,NE__Order__c> ordMap= new Map<Id,NE__Order__c>([SELECT ID, RecordType.Name, XC_Status__c, XC_PracticeStatus__c, XC_Compliance_Approval__c, XC_FinancialPracticeStatus__c, XC_FinancialPracticeNumber__c, XC_FinancialInstitution__c,  (SELECT Id, XC_PaymentMethod__c FROM NE__Order_Items__r) from NE__Order__c where id=:wrReq.Order.OrderID]); 
        if(ordMap.values().isEmpty()){
            wrResp.Result.Message = Label.XC_CL_OrderIdNotFound;
            wrResp.Result.ErrorCode = '400';
            wrResp.Order = null;
            return;
        }
        
        mapOrder.put('ordMap',ordMap); 
        mapOrder.put('recordTypeOrder',ordMap.values()[0].RecordType.Name);
        mapOrder.put('practiceStatus',ordMap.values()[0].XC_PracticeStatus__c);
        mapOrder.put('complianceStatus',ordMap.values()[0].XC_Compliance_Approval__c); 
        mapOrder.put('orderID',ordMap.values()[0].Id); 
        mapOrder.put('orderStatus',ordMap.values()[0].XC_Status__c) ;


        Map<id, NE__OrderItem__c> orderItemMap;
        if(wrReq.Order.OrderItem != null){
            Set<id> ordItemIds = new Set<id>();
            Set<id> ordItemAttrIds = new Set<id>();
            XC_REST_Order_VVV.getIDs(wrReq.Order.OrderItem, ordItemIds, ordItemAttrIds);
            orderItemMap = XC_REST_Order_U_D.getOrderItemByOrder(wrReq.Order.OrderID, ordItemIds, ordItemAttrIds);
            for(XC_UTIL_Order.OrderItemWrapper ordItemWr :wrReq.Order.OrderItem){
                if(!orderItemMap.containskey(ordItemWr.OrderItemID)){
                    wrResp.Result.Message = 'ERROR. Order.OrderItem.OrderItemID '+ ordItemWr.OrderItemID + ' ' + Label.XC_CL_NotFount;
                    wrResp.Result.ErrorCode = '400';
                    wrResp.Order = null;
                    return;
                }
            }
            for(NE__OrderItem__c ordItem : orderItemMap.values()){
                if(!ordItem.NE__Order_Item_Attributes__r.isEmpty()){
                    mapOrdItemIdOIA.put(ordItem.id, ordItem.NE__Order_Item_Attributes__r);
                }
            }
        }
    }

    
}