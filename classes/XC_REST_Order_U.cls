/**
 * @author            : Riccardo Cossu - riccardo.cossu@nttdata.com
 * @date  Creation   : 10/12/2018
 * @date Modification : 09/04/2019 by Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : REST Interface for Create / Update a Order / Order Item / Order Item Attribute
 **/

public without sharing class XC_REST_Order_U {

    /** @description the wrapper request */
    public abstract class WrapperRequest {
        
    }

    /** @description the wrapper PUT request */
    public class WrapperPUTRequest extends WrapperRequest {
        
 
        public XC_UTIL_Order.OrderIFWrapper Order;   
        
        /**
        * @description  
        */
        public WrapperPUTRequest(){
            XC_UTIL_Debug.debug(true, 'WrapperPUTRequest');
        }
    }

    /** @description the wrapper POST request */
    public class WrapperPOSTRequest extends WrapperRequest{
        
        public XC_UTIL_Order.OrderIFWrapper Order; 
        
        /**
        *@description 
        */
        public WrapperPOSTRequest(){
            XC_UTIL_Debug.debug(true, 'WrapperPOSTRequest');
        }

    }

    /** @description the wrapper GET request */
    public class WrapperGETRequest extends WrapperRequest{
        
        public String[] OrderID;
        
        /**
        *@description 
        */
        public WrapperGETRequest(){
            XC_UTIL_Debug.debug(true, 'WrapperGETRequest');
        }
    }

    /** @description the wrapper response */
    public abstract class WrapperResponse {

        public XC_UTIL_Integration.Result Result;

    }   

    /** @description the wrapper res */
    public class WrapperRes extends WrapperResponse{
        
        public XC_UTIL_Order.OrderIFWrapper Order;

        /**
        *@description 
        */
        public WrapperRes(){
            Result = new XC_UTIL_Integration.Result();
        }
    }

    /** @description the wrapper GET response */
    public class WrapperGETResponse extends WrapperResponse{
    
        public XC_UTIL_Order.OrderIFWrapper[] Order;   
        
        /**
        * @description Instantiates a new wrapper GET response.
        */
        public WrapperGETResponse(){
            Result = new XC_UTIL_Integration.Result();
            Order = new List<XC_UTIL_Order.OrderIFWrapper>();
        }
    }

    /** @description the wrapper integration log */
    public class WrapperIntegrationLog{
        public String logError;
        public String msgRequest;
        public String msgResponse;
    }
        

    /**
    * @param postRequest the post request
    * @param wr the wr
    * @description insert a list of orders from a wrapper
    */
    public static void insertOrders(WrapperPOSTRequest postRequest, XC_REST_Order_U.WrapperRes wr, Map<String, Object> mapUtil){
        List<Account> accList = ((Map<Id,Account>)mapUtil.get('Account')).values(); 

        //check billing profile and get paymentMethod
        Map<Id,NE__Billing_Profile__c> bpMap = XC_REST_Order_ZZZ.checkBillingProfile(postRequest.order.orderItem, wr, accList, postRequest.order.LegalEntity);
        if(wr.Result.ErrorCode == '400'){
            return;
        }
        
        //check credit card BP
        Set<Id> ccbillingProfileIds = new Set<Id>();
        for(XC_UTIL_Order.OrderItemWrapper orderItem : postRequest.order.orderItem){
            if(!String.isBlank(orderItem.BillingProfileID)){
                if((!String.isBlank(orderItem.PaymentType) && orderItem.PaymentType == Label.XC_CL_Credit_Card)|| bpMap.get(orderItem.BillingProfileID).NE__Payment__c == Label.XC_CL_Credit_Card){
                    ccbillingProfileIds.add(orderItem.BillingProfileID); 
                }
            }
        }

        //check duplicate order 
        if(!ccbillingProfileIds.isEmpty()){
            Map<Id, NE__OrderItem__c> sameOiMap = XC_REST_Order_U_D.getOIwithSameBPDraft(ccbillingProfileIds, postRequest.order.LegalEntity);
            if(!sameOiMap.isEmpty()){
                    wr.Result.ErrorCode = '463';
                    wr.Result.Message = 'INTERNAL ERROR: ' + Label.XC_CL_DuplicateOrder;
                    wr.Result.LogError = 'INTERNAL ERROR: ' + Label.XC_CL_DuplicateOrder;
                    return;
            }
        }

        //retrieve currency
        String currencyValue = '';
        if(!String.isBlank(postRequest.order.LegalEntity)){
            String orgId = UserInfo.getOrganizationId();
            Map<Id, XC_CM_LegalEntity_Configuration__mdt> mapCurrency = new Map<Id, XC_CM_LegalEntity_Configuration__mdt>([SELECT XC_Currency__c FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_Stream__c =: accList[0].XC_Segment__c AND XC_LegalEntity__c =: postRequest.order.LegalEntity AND XC_OrgId__c =: orgId]);
            currencyValue = (mapCurrency != null && !mapCurrency.isEmpty()) ? mapCurrency.values()[0].XC_Currency__c : '';
        }
        

        List<NE__Order__c> toInsert = new List<NE__Order__c>();
        toInsert.add(XC_UTIL_Order.createOrder(postRequest.Order));
        toInsert[0].NE__Type__c = 'InOrder';
        if(!String.isBlank(currencyValue)){
            toInsert[0].CurrencyIsoCode = currencyValue; 
        }
        

        if(((Map<String,String>)mapUtil.get('header')).get('ClientSystem') == 'E-Commerce'){ // fix 25/06/2020
            toInsert[0].XC_SignedByExternal__c = 'Web';
        }

        system.debug('**********'+mapUtil.get('header'));
        if(((Map<String,String>)mapUtil.get('header')).get('ClientSystem')=='CommoditySpainB2C'){
            toInsert[0].XC_Channel__c = 'Market';
            toInsert[0].NE__AccountId__c = ((Map<Id, Account>)mapUtil.get('Account')).values()[0].id;
            for(XC_Address__c a : ((Map<Id, Account>)mapUtil.get('Account')).values()[0].Addresses__r){
                if(a.XC_InstallationAddress__c){
                    toInsert[0].XC_InstallationAddress__c = a.id;
                } else{
                    toInsert[0].XC_OrderBillingAddress__c = a.id;
                }
            }

            system.debug('**********'); 
        }


        // create a new opportunity if necessary
        if(String.isBlank(postRequest.Order.OpportunityID)){
            Opportunity opp = XC_REST_Order_ZZZ.createOpportunity(postRequest, wr, accList);
            if(opp == null){
                return;
            }else{
                toInsert[0].NE__OptyId__c = opp.Id;
            }
        }else{
            XC_REST_Order_ZZZ.updateOpportunity(postRequest, wr, accList);
            if(wr.Result.ErrorCode == '500'){
                wr.Order = null;
                return;
            }
        }
    

        XC_REST_Order_V.insertOrderAndPopulateResponse(toInsert, wr);
        if(wr.Result.ErrorCode == '500'){
            wr.Order = null;
            return;
        }
        
        List<NE__OrderItem__c> parentOrderItemtoInsert = new List<NE__OrderItem__c>();
        Map<XC_UTIL_Order.OrderItemWrapper, NE__OrderItem__c> mapOIWrOI = new Map<XC_UTIL_Order.OrderItemWrapper, NE__OrderItem__c>();
        Map<List<XC_UTIL_Order.WrapperAttribute>, NE__OrderItem__c> mapOIAOrdItem = new Map<List<XC_UTIL_Order.WrapperAttribute>, NE__OrderItem__c>();
        Map<NE__OrderItem__c, Id> oiBpMap = new Map<NE__OrderItem__c, Id>();
        Map<String, Object> mapUtilOI = new Map<String, Object>{'mapOIWrOI'=> mapOIWrOI,
                                                                'mapOIAOrdItem' => mapOIAOrdItem,
                                                                'parentOrderItemtoInsert'=> parentOrderItemtoInsert,
                                                                'orderReq'=> postRequest.Order,
                                                                'orderId' => toInsert[0].id, 
                                                                'oiBpMap' => oiBpMap,
                                                                'bpMap' => bpMap,
                                                                'currencyValue' => currencyValue
                                                                };                                                     
        XC_REST_Order_V.manageOrderItem(mapUtilOI); 
        system.debug('oiBpMap' +oiBpMap);
                                 

        Map<String, NE__OrderItem__c> mapIdordItem = new Map<String, NE__OrderItem__c>();
        Map<String, Object> mapUtilParentOI = new Map<String, Object>{  'mapIdordItem'=> mapIdordItem,
                                                                        'parentOrderItemtoInsert'=> parentOrderItemtoInsert,
                                                                        'order'=> toInsert[0], 
                                                                        'wr' => wr,
                                                                        'mapOIWrOIChild' => (Map<XC_UTIL_Order.OrderItemWrapper, NE__OrderItem__c>)mapUtilOI.get('mapOIWrOIChild')
                                                                        };
        XC_REST_Order_V.manageParentOrderItem(mapUtilParentOI);
        if(wr.Result.ErrorCode == '500'){
            wr.Order = null;
            return;
        }

        Map<XC_UTIL_Order.OrderItemWrapper, NE__OrderItem__c> mapOIWrOIChild = (Map<XC_UTIL_Order.OrderItemWrapper, NE__OrderItem__c>)mapUtilOI.get('mapOIWrOIChild');

        if(mapOIWrOIChild != null && !mapOIWrOIChild.isEmpty()/*!String.isBlank(parentOrderItem)*/){
            List<NE__OrderItem__c>  ordItemToInsert = new List<NE__OrderItem__c>(); 

            Map<String, Object> mapUtilOIchild = new Map<String, Object>{'mapOIWrOI'=> MapOIWrOI,
                                                                        'mapOIWrOIChild' => mapOIWrOIChild,
                                                                        'parentOrderItemtoInsert'=> parentOrderItemtoInsert,
                                                                        'order' => toInsert[0], 
                                                                        'ordItemToInsert' => ordItemToInsert
                                                                        };
         
            XC_REST_Order_V.getOrderItemChild(mapUtilOIchild);
            XC_REST_Order_V.updateOrderItem(ordItemToInsert, mapIdordItem, wr);
            if(wr.Result.ErrorCode == '500'){
                wr.Order = null;
                return;
            }
        }
        

        List<NE__Order_Item_Attribute__c> itemAttrToInsert = new List<NE__Order_Item_Attribute__c >();
        
        Map<String, Object> mapUtilOIA = new Map<String, Object>{'orderItemList'=> postRequest.Order.OrderItem,
                                                                'itemAttrToInsert' => itemAttrToInsert,
                                                                'mapOIAOrdItem' => mapOIAOrdItem
                                                                };
        XC_REST_Order_VV.populateOIAList(mapUtilOIA);

        Map<String, NE__Order_Item_Attribute__c> mapIdordItemAttr = new Map<String, NE__Order_Item_Attribute__c>();
        Map<String, Object> mapUtilOIAttr = new Map<String, Object>{
                                                                    'itemAttrToInsert' => itemAttrToInsert,
                                                                    'mapIdordItemAttr'=> mapIdordItemAttr,
                                                                    'wr' => wr
                                                                    };
        XC_REST_Order_VV.manageItemAttribute(mapUtilOIAttr);
        if(wr.Result.ErrorCode == '500'){
            wr.Order = null;
            return;
        }

        //insertOrderItemDiscount(MapOIWrOI, wr); 
        insertOrderItemDiscountOverload(MapOIWrOI, wr, currencyValue);
        if(wr.Result.ErrorCode == '500'){
            wr.Order = null;
            return;
        }


        Map<String,Object> utilMap = new Map<String,Object> { 'optyId' => toInsert[0].Id,
                                                              'postRequest' => postRequest
                                                            };

        XC_REST_Order_ZZZ.orderToOrder(utilMap, wr, 'Order'); 
        if(wr.Result.ErrorCode =='500'){
            return;
        }

        // populate response
        Map<String, Object> mapUtilResponse = new Map<String, Object>{
                                                                    'wr'=> wr,
                                                                    'orderId' => wr.Order.OrderID,
                                                                    'postRequest' => postRequest
                                                                    };

        XC_REST_Order_ZZZ.populateResponse(mapUtilResponse);       

        wr.Result.ErrorCode = '0';
        wr.Result.Message = 'Operation completed successfully'; 
    }


    /**
    * @param Map<String, Object> mapOrder
    * @param wr the wr
    * @description update orders
    */
    public static void updateOrders(Map<String, Object> mapOrder, XC_REST_Order_U.WrapperRes wr) {

        XC_REST_Order_U.WrapperPUTRequest putRequest = (XC_REST_Order_U.WrapperPUTRequest) mapOrder.get('wrReq');
        String recordTypeOrder= (String) mapOrder.get('recordTypeOrder');

        XC_REST_Order_ZZZ.checkExternalFinancing(mapOrder, wr);
        if(wr.Result.ErrorCode == '500'){
            wr.Order = null;
            return;
        }

        if(recordTypeOrder !='Quote' && !String.isBlank(putRequest.Order.OrderStatus) && putRequest.Order.OrderStatus.equalsIgnoreCase('Accepted')){
            wr.Result.Message = 'Operation in progress';
            wr.Result.ErrorCode = '464';
            wr.Order = null;
            wr.Result.logError = 'INTERNAL ERROR: Operation not allowed for a Quote in this status';
            return;
        }

        XC_REST_Order_ZZZ.manageUpdateOrder(mapOrder, wr);
        if(wr.Result.ErrorCode == '400' || wr.Result.ErrorCode == '500'){
            wr.Order = null;
            return;
        }


        // manage quote to order
        if( recordTypeOrder =='Quote' && !String.isBlank(putRequest.Order.OrderStatus) && putRequest.Order.OrderStatus.equalsIgnoreCase('Accepted')){

            if((String) mapOrder.get('orderStatus') != Label.XC_CL_Configuration_QuoteDraft && (String) mapOrder.get('orderStatus') != Label.XC_CL_Configuratione_QuoteNotifiedToClient){
                wr.Result.Message = 'INTERNAL ERROR: ' + Label.XC_CL_Quote_OperationNotAllowedWithThisStatus;
                wr.Result.ErrorCode = '500';
                wr.Order = null;
                wr.Result.logError = 'INTERNAL ERROR: Operation not allowed for a Quote in this status';
                return;
            }

            XC_REST_Order_ZZZ.orderToOrder(mapOrder, wr, 'Order'); 
            if(wr.Result.ErrorCode =='500'){
                return;
            }

        }else if (putRequest.Order.StartProvisioning == true){  // after accepted a quote the record type of the output record id is still a Quote
            if(recordTypeOrder == 'Order'){
                system.debug('IN ORDER');
                XC_REST_Order_ZZZ.manageCompliance(mapOrder, putRequest, null);  
            
            }else{
                wr.Result.Message = 'Operation in progress';
                wr.Result.ErrorCode = '464';
                wr.Order = null;
                wr.Result.logError = 'INTERNAL ERROR: Start provisioning not available on pending order or quote/opty';
                return;
            }
              
        }
        
       
    
        /*Boolean skipCompliance = (putRequest.Order.skipCompliance != null) ? putRequest.Order.skipCompliance : true;
        Boolean startProvisioning = (putRequest.Order.startProvisioning != null) ? putRequest.Order.startProvisioning : false;
        if(startProvisioning && !skipCompliance && mapOrder.get('complianceStatus')!='OK'){
            wr.Result.ErrorCode = '500';
            wr.Result.Message = 'INTERNAL ERROR: Document compliance is required to proceed'; 
            return;
        }*/

        wr.Result.ErrorCode = '0';
        wr.Result.Message = 'Operation completed successfully';

        if(wr.Order.OrderItem.isEmpty()) {
            wr.Order.OrderItem = null;
        }

    }




    /**
    * @param mapOrder - Map<String,Object> 
    * @param wr - XC_REST_Order_U.WrapperRes
    * @param recordTypeName - String
    * @description  method to manage conversion from order of recordType Opty to Quote  
    */
    public static void manageOptyToQuote(Map<String, Object> mapOrder, XC_REST_Order_U.WrapperRes wr, String recordTypeName){

        wr.Order = new XC_UTIL_Order.OrderIFWrapper();
        wr.Order.OrderItem = null;
        
        String recordTypeOrder = (String) mapOrder.get('recordTypeOrder');
        XC_REST_Order_U.WrapperPUTRequest putRequest=(XC_REST_Order_U.WrapperPUTRequest) mapOrder.get('wrReq');

        if(recordTypeOrder != 'Opty'){
            wr.Result.Message = 'INTERNAL ERROR: Invalid Record Type';
            wr.Result.ErrorCode = '500';
            wr.Order = null;
            wr.Result.logError = 'INTERNAL ERROR: Invalid Record Type';
            return;
        }


        XC_REST_Order_ZZZ.orderToOrder(mapOrder, wr, recordTypeName);

        if(wr.Result.ErrorCode =='500'){
            return; 
        }
        
        wr.Result.ErrorCode = '0';
        wr.Result.Message = 'Operation completed successfully';
        

    }


    /**
    * @param wrResp - XC_REST_Order_U.WrapperGetResponse
    * @param header - Map<String,String> 
    * @param orders - List<NE__Order__c> 
    * @description  read orders
    */
    public static void readOrders(XC_REST_Order_U.WrapperGetResponse wrResp, Map<String,String> header, List<NE__Order__c> orders){

        wrResp.Result.Message = 'Operation completed successfully';
        wrResp.Result.ErrorCode = '0';

        List<Id> confIdList = XC_UTIL_Sobject.getIds(Orders);
        List<NE__OrderItem__c> orderItems = XC_REST_Order_U_D.getOrderItemByOrderIdList(confIdList);
        
        
        //mario.a.giordano@accenture.com 29112021 _START
        Map<Id,XC_UTIL_Order.AccountWrapper> accountChildAccountMap = new Map<Id,XC_UTIL_Order.AccountWrapper> ();
        List<Id> accountIdList = new List<Id>();
        for(NE__Order__c order : orders){
            accountIdList.add(order.NE__AccountId__c);
        }
        List<Account> accounts =  [SELECT ParentId,XC_LastName__c,XC_FirstName__c,XC_BirthDate__c,XC_Energy_Community__c, XC_Community_Typology__c,XC_Community_Code__c, XC_GSE_Code__c, XC_Community_Members_Number__c,XC_Community_GSE_Approval_Date__c,
        XC_Energy_Community_Foundation_date__c, //minal.mahavir.patil@accenture.com, 06/01/2022, Enel X - NR2260 - Energy Communities, ENEL X - r12 
        (SELECT id,ParentId,XC_Member_Typology__c,XC_FirstName__c, XC_LastName__c, XC_CustomerNumber_EnelEnergia__c, XC_BirthDate__c,
        XC_Una_tantum_member_fee__c, XC_Annual_member_fee__c, XC_Annual_membership_fee_due_date__c, XC_Fix_part_sharing_monthly__c, XC_MISE_incentive__c, XC_Arera_incentive__c, XC_Local_price_incentive__c //minal.mahavir.patil@accenture.com, 06/01/2022, Enel X - NR2260 - Energy Communities, ENEL X - r12 
        FROM ChildAccounts) FROM Account 
        WHERE Id in: accountIdList];

        for(Account a : accounts ){  
            XC_UTIL_Order.AccountWrapper   accountwrp = new  XC_UTIL_Order.AccountWrapper () ;
            XC_REST_Order_VVV.populateAccountFields(a,accountwrp);
            List<XC_UTIL_Order.AccountChildWrapper> accountchildwrpList = new List<XC_UTIL_Order.AccountChildWrapper>();
            for(Account ac : a.ChildAccounts){
                XC_UTIL_Order.AccountChildWrapper accountchildwrp = new XC_UTIL_Order.AccountChildWrapper();
                XC_REST_Order_VVV.populateAccountChildFields (ac,accountchildwrp);               
                accountchildwrpList.add(accountchildwrp);
            }
            accountwrp.AccountChild = accountchildwrpList;
            accountChildAccountMap.put(a.Id,accountwrp);
        }
        //mario.a.giordano@accenture.com 29112021 _END 
            
        List<Id> confItemIdList = XC_UTIL_Sobject.getIds(orderItems);
        Map<Id, List<String>> itemDoc = XC_UTIL_DocumentComplianceMaster.getDocumentComplianceMaster('C1', confItemIdList);

        Map<String, String> pickListValuesMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = XC_DocumentComplianceMaster__c.XC_DocumentType__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple){
            pickListValuesMap.put(pickListVal.getLabel(), pickListVal.getValue());
        }

        List<XC_DocumentType__c> documentTypes = XC_REST_Order_U_D.getDocumentType(confIdList);

        Map<Id,Map<String,Decimal>> ordItDocType = new Map<Id,Map<String,Decimal>>();
        for(Id d : itemDoc.keySet()){
            Map<String,Decimal> tmp = new Map<String,Decimal>();
            for(String s : itemDoc.get(d)){
                tmp.put(pickListValuesMap.get(s),0);
            }
            ordItDocType.put(d, tmp);
        }

        Map<Id,Integer> ordNumContract = new Map<Id,Integer>();

        Set<Id> orderIdToExclude = new Set<Id>();
        Map<Id,Map<String,Decimal>> ordDocType = new Map<Id,Map<String,Decimal>>();   
        for(NE__OrderItem__c oi:orderItems){
            if(!oi.XC_BPLIStatus__c && !String.isBlank(oi.XC_BillingProfileLineItem__c) && oi.XC_BillingProfileLineItem__r.XC_PaymentMethod__c == Label.XC_CL_Credit_Card){
                orderIdToExclude.add(oi.NE__OrderId__c);
                continue;
            }
            if(ordItDocType.get(oi.id)==null){
                continue;
            }

            if(ordDocType.get(oi.NE__OrderId__c)!=null){
                Map<String,Decimal> tmp = ordDocType.get(oi.NE__OrderId__c);
                Map<String,Decimal> ntmp = ordItDocType.get(oi.id);
                for(String s : tmp.keySet()){
                    ntmp.put(s,0);
                }
                ordDocType.put(oi.NE__OrderId__c,ntmp);

            } else {
                ordDocType.put(oi.NE__OrderId__c,ordItDocType.get(oi.id));
            }

            //Counting countract - ST 02/09/2020
            Integer n = ordNumContract.get(oi.NE__OrderId__c);
            if(n!=null&&oi.XC_ContractGenerated__c){
                ordNumContract.put(oi.NE__OrderId__c, n+1);
            } else if(oi.XC_ContractGenerated__c){
                ordNumContract.put(oi.NE__OrderId__c, 1);
            }
        }

      
        if(!orderIdToExclude.isEmpty()){ 
            // method to exclude the order that have at least one order item with CC draft
            Map<String,Object> utilMapFilterOrder = new Map<String,Object>{
                                                                        'orders' => orders,
                                                                        'orderItems' => orderItems,
                                                                        'orderIdToExclude' => orderIdToExclude,
                                                                        'wrResp' => wrResp
                                                                    };
            excludeOrderWithCCDraft(utilMapFilterOrder);
            orders = (List<NE__Order__c>)utilMapFilterOrder.get('orders');
            orderItems = (List<NE__OrderItem__c>)utilMapFilterOrder.get('orderItems');
            wrResp = (XC_REST_Order_U.WrapperGetResponse) utilMapFilterOrder.get('wrResp');
            if(wrResp.Result.ErrorCode == '400'){
                return;
            }
        }
       

        Map<String,Decimal> tmp = new Map<String,Decimal>();
        for(XC_DocumentType__c dt : documentTypes){
            Decimal t = dt.numberOfFiles__c;

            if(ordDocType.get(dt.XC_Configuration__c)!=null){
                tmp = ordDocType.get(dt.XC_Configuration__c);
                if(ordDocType.get(dt.XC_Configuration__c).get(dt.Category__c)!=null){          
                    t = dt.numberOfFiles__c;
                }
            } 

            tmp.put(dt.Category__c, t);
            ordDocType.put(dt.XC_Configuration__c, tmp);
        }
        
        List<String> prodIds = new List<String>();
        for (NE__OrderItem__c o : orderItems){
            prodIds.add(o.NE__ProdId__c);
        }
        
        List<NE__DocumentationCharacterist__c> docuChar = XC_REST_Order_U_D.getDocCharact(prodIds);
        Map<Id, NE__DocumentationCharacterist__c> docuMap = new Map<Id, NE__DocumentationCharacterist__c>();
        for (NE__DocumentationCharacterist__c dc : docuChar){
            docuMap.put(dc.id, dc);
        }

        // Check compliance1 to be modified
        Map<Id, List<String>> mapOrderitemDocument = new Map<Id, List<String>>();
        XC_REST_Order_VV.manageComplianceVerification(orders, mapOrderitemDocument, header);
        
        Map<Id, Map<String, String>> mapWithZuoraParameters = XC_REST_Order_U.getZuoraInfosFromOrderItem(OrderItems);
        Map<Id, Asset> idAssetMap = XC_REST_Order_VVV.createAssetMap(orderItems);

        if(header.get('Operation')=='WorkOrderStatus'){
            List<Id> orderIds = XC_UTIL_Sobject.getIds(orders);
            List<WorkOrder> wos = XC_REST_Order_U_D.getWorkOrder(orderIds);
           
            if(!wos.isEmpty()){
                for(WorkOrder wo:wos){ 
                    XC_UTIL_Order.OrderIFWrapper wrOrd = new XC_UTIL_Order.OrderIFWrapper();
                    wrOrd.OrderId = wo.xc_configuration__c;
                    wrOrd.WorkOrderExpected = Integer.valueOf(wo.XC_NumberWorkOrdersDI__c);
                    wrOrd.WorkOrderCreated = (wo.XC_NumberWorkOrdersDI__c == 1) ? 1 : wo.ChildWorkOrders.size(); 
                    wrOrd.WorkOrderStatus = (wrOrd.WorkOrderCreated==wrOrd.WorkOrderExpected) ? 'OK' : 'Pending';             
                    wrOrd.AppointmentToBeScheduled = (wo.Status == 'New' && (wo.XC_WorkTypeCategory__c == 'Installation' || wo.XC_WorkTypeCategory__c == 'Delivery & Installation'));
                    wrOrd.OrderItem = null;
                    wrResp.order.add(wrOrd);
                }
                return;  
            }

            List<XC_Provisioning_Step__c> listSteps = new List<XC_Provisioning_Step__c>([
                SELECT Id, XC_Flow_API_Name__c, XC_Configuration_Item__r.NE__OrderId__c 
                FROM XC_Provisioning_Step__c 
                WHERE XC_Configuration_Item__r.NE__OrderId__c IN :orderIds AND XC_Flow_API_Name__c = :Label.XC_CL_ProvisioningCreateDeliveryInstallationWO_Flow
            ]);
            if(!listSteps.isEmpty()) {
                Map<String, Integer> mapSteps = new Map<String, Integer>();
                for(XC_Provisioning_Step__c step : listSteps) {
                    if(!mapSteps.containsKey(step.XC_Configuration_Item__r.NE__OrderId__c)) {
                        mapSteps.put(step.XC_Configuration_Item__r.NE__OrderId__c, 0);
                    }
                    mapSteps.put(step.XC_Configuration_Item__r.NE__OrderId__c, mapSteps.get(step.XC_Configuration_Item__r.NE__OrderId__c) + 1);
                }

                for(String key : mapSteps.keySet()) {
                    XC_UTIL_Order.OrderIFWrapper wrOrd = new XC_UTIL_Order.OrderIFWrapper();
                    wrOrd.OrderID = key;
                    wrOrd.WorkOrderExpected = mapSteps.get(key);
                    wrOrd.WorkOrderCreated = 0;
                    wrOrd.WorkOrderStatus = (wrOrd.WorkOrderExpected != wrOrd.WorkOrderCreated) ? 'Pending' : 'OK';
                    wrOrd.AppointmentToBeScheduled = false;
                    wrResp.order.add(wrOrd);
                }
            } else {
                for(Id ordId : orderIds){
                    XC_UTIL_Order.OrderIFWrapper wrOrd = new XC_UTIL_Order.OrderIFWrapper();
                    wrOrd.OrderID = ordId;
                    wrOrd.WorkOrderExpected = 0;
                    wrOrd.WorkOrderCreated = 0;
                    wrOrd.WorkOrderStatus = 'OK';
                    wrOrd.AppointmentToBeScheduled = false;
                    wrResp.order.add(wrOrd);
                }
            }


            return; 
        }

        Map<Id,XC_UTIL_Order.OrderIFWrapper> wrOrdMap = new Map<Id,XC_UTIL_Order.OrderIFWrapper>();

        List<XC_DocumentByPaymentMethod__mdt> mdtValues = XC_REST_Order_U_D.getPaymentTypesList();

        // get all legal entities and streams
        Set<String> legalEntities = new Set<String>();
        Set<String> streams = new Set<String>();
        for(NE__Order__c o : orders){
            legalEntities.add(o.XC_LegalEntity__c);
            streams.add(o.XC_Segment__c);
        }
        //Map<String,String> excludedMopsbyLe = getExcludedMopsConfs(legalEntities);

        //Map<String,String> excludedMopsbyLe = getExcludedMopsConfs(legalEntities, streams);
        //Map<String,String> excludedMopsbyLeStr = new Map<String,String>(); 
        
        List<XC_CM_CountryLegalEntityAssociation__mdt> cleaMap = ([
            SELECT DeveloperName, RemoteQuoteFlow__c, XC_LegalEntity__c, XC_Stream__c 
            FROM XC_CM_CountryLegalEntityAssociation__mdt 
            WHERE XC_LegalEntity__c IN: legalEntities AND XC_Stream__c IN: streams]);

        for(NE__Order__c o : orders){
            XC_UTIL_Order.OrderIFWrapper wrOrd = new XC_UTIL_Order.OrderIFWrapper();

            wrOrd.OrderId = o.id;
            wrOrd.OpportunityID = o.NE__OptyId__c;
            wrOrd.StartDate = String.valueOf(o.CreatedDate);
            wrOrd.OrderStatus =  o.XC_Status__c;
            //missing uniqueID
            wrOrd.AccountID = o.NE__AccountId__c;
            wrOrd.ContractAccount = o.NE__Contract_Account__c;
            wrOrd.OrderTracking = o.XC_Order_Tracking__c;
            wrOrd.DeliveryID = o.XC_Delivery_ID__c;            
            wrOrd.ServiceAccountAsset = o.NE__Service_Account_Asset__c;
            wrOrd.BillingAccountAsset = o.NE__Billing_Account_Asset__c;
            wrOrd.AdministrativeTasks = o.XC_AdministrativeTasks__c;
            wrOrd.ModeOfcancellation = o.XC_Mode_of_cancellation__c;
            wrOrd.TypeOfcancellation = o.XC_Type_of_cancellation__c;
            wrOrd.DeliveryType = o.XC_DeliveryType__c;
            wrOrd.InstallationAddress = o.XC_InstallationAddress__c;
            wrOrd.BillingAddress = o.XC_OrderBillingAddress__c;
            wrOrd.FinancialPracticeNumber = o.XC_PracticeNumber__c;
            wrOrd.FinancialApproval = o.XC_FinancialApproval__c;
            wrOrd.PracticeStatus = o.XC_PracticeStatus__c;
            wrOrd.FinancialRejectReason = o.XC_FinancialRejectReason__c;
            wrOrd.Compliance1Status = o.XC_Compliance_Approval__c;
            wrOrd.ComplianceRejectReason = o.XC_ComplianceRejectReason__c;
            wrOrd.OrderDescription = o.name;
            wrOrd.CompanyCode = o.XC_Company_Code__c;
            wrOrd.CostCenter = o.XC_Cost_Center__c;
            wrOrd.CurrencyX = o.CurrencyIsoCode;
            wrOrd.CustomerZipCode = o.XC_InstallationAddress__r.XC_PostalCode__c;
            wrOrd.RecordType  = o.RecordType.Name;
            wrOrd.PaymentTransactionDetails = o.XC_PaymentTransactionDetails__c;
            wrOrd.PaymentTransactionDate = o.XC_PaymentTransactionDate__c;
            wrOrd.PaymentTransactionID = o.XC_PaymentTransactionID__c;
            wrOrd.ContactEmail = (!String.isBlank(o.NE__OptyId__c) && !String.isBlank(o.NE__OptyId__r.XC_Contact__c)) ? o.NE__OptyId__r.XC_Contact__r.Email : null;
            
            for(XC_CM_CountryLegalEntityAssociation__mdt clea : cleaMap){
                if(clea.XC_LegalEntity__c == o.XC_LegalEntity__c && clea.XC_Stream__c == o.XC_Segment__c){
                    wrOrd.RemoteQuoteFlow = clea.RemoteQuoteFlow__c;
                }
            }
            
            XC_REST_Order_VVV.populateOrderFields(o, wrOrd);

            wrOrd.Document = new List<XC_UTIL_Order.DocumentWrapper>();

            if(ordDocType.get(wrOrd.OrderId)!=null){
                for(String dt:ordDocType.get(wrOrd.OrderId).keySet()){
                    XC_UTIL_Order.DocumentWrapper dw = new XC_UTIL_Order.DocumentWrapper();
                    dw.DocumentType = dt;  
                    dw.Quantity = ordDocType.get(wrOrd.OrderId).get(dt);
                    wrOrd.Document.add(dw);
                }   
            } 

            //porcata che poi toglieremo 
            if( ( ordDocType.get(wrOrd.OrderId)==null || ordDocType.get(wrOrd.OrderId).get('SF_DNI')==null )
                    && header.get('ClientSystem') == 'XInstaller' && o.XC_LegalEntity__c==Label.XC_CL_EndesaX ){
                XC_UTIL_Order.DocumentWrapper dw = new XC_UTIL_Order.DocumentWrapper();
                dw.DocumentType = 'SF_DNI';  
                dw.Quantity = 0;
                wrOrd.Document.add(dw);
            }

            if(wrOrd.OrderItem.isEmpty()) { 
                wrOrd.OrderItem = null;
            }
            if(wrOrd.Document.isEmpty()){
                wrOrd.Document = null;
            }

            if(ordNumContract.get(o.id)!=null&&header.get('ClientSystem') == 'XInstaller'){
                wrOrd.NumGeneratedContract = ordNumContract.get(o.id);
            } else if(header.get('ClientSystem') == 'XInstaller'){
                wrOrd.NumGeneratedContract = 0;
            }
           
            //mario.a.giordano@accenture.com 29112021 _START
            if(accountChildAccountMap.containsKey(o.NE__AccountId__c)){
                wrOrd.Account = accountChildAccountMap.get(o.NE__AccountId__c);
            }    
            //mario.a.giordano@accenture.com 29112021 _END
            wrOrdMap.put(wrOrd.OrderId, wrOrd);
            //wrResp.order.add(wrOrd);
            //
            
            /*Map<String,List<XC_UTIL_PaymentMethodFilter.MopWrapper>> excludedMopsbyLe = XC_UTIL_PaymentMethodFilter.getAvailabeMopsForOrderItems(o.XC_LegalEntity__c, o.XC_Segment__c, orderItems);
            
            for(String s : excludedMopsbyLe.keySet()){
                List<String> l = new List<String>();
                for(XC_UTIL_PaymentMethodFilter.MopWrapper m : excludedMopsbyLe.get(s)){
                    l.add(m.mopValue);
                }
                String res = String.valueOf(l);
                res = res.substring(1,res.length()-1);
                excludedMopsbyLeStr.put(s, res);
            }*/
        }

        if (OrderItems.isEmpty()) {
            return;
        }

        XC_UTIL_DependentPicklist.PicklistWrapper wrPayments = XC_UTIL_DependentPicklist.getDependentPicklist('NE__OrderItem__c','XC_BillingModel__c','XC_PaymentMethod__c');
        Map<Id,List<XC_UTIL_Order.OrderItemWrapper>> wrItemMap = new Map<Id,List<XC_UTIL_Order.OrderItemWrapper>>();
        for (NE__OrderItem__c oi : OrderItems) {
            Map<String,Object> utilMap = new Map<String,Object>{
                'oi' => oi,
                'wrOrd' => wrOrdMap.get(oi.NE__OrderId__c),
                'mapOrderitemDocument' => mapOrderitemDocument
            };
            XC_REST_Order_VVV.populateDocumentFields(utilMap);

            XC_UTIL_Order.OrderItemWrapper wrOi = new XC_UTIL_Order.OrderItemWrapper();
            wrOi.OrderItemID = oi.id;  
            wrOi.ProdID = oi.NE__ProdId__c;
            wrOi.ProdName = oi.XC_TranslatedProductName__c;
            wrOi.CatalogItemID = oi.NE__CatalogItem__c;
            wrOi.BillingProfileID = oi.XC_BillingProfileLineItem__r.XC_BillingProfile__c;
            wrOi.Quantity = (Integer) oi.NE__Qty__c;
            wrOi.BaseRecurringCharge = oi.NE__BaseRecurringCharge__c;
            wrOi.BaseOneTimeFee = oi.NE__BaseOneTimeFee__c;
            wrOi.EngineCode =  oi.NE__CatalogItem__r.NE__Engine_Code__c; // oi.XC_Engine_Code__c;
            wrOi.PaymentMethod = oi.XC_BillingModel__c; //oi.XC_PaymentMethod__c;
            wrOi.PaymentType = oi.XC_PaymentMethod__c;
            wrOi.ParentOrderItemID = oi.NE__Parent_Order_Item__c;
            wrOi.BundleConfiguration = oi.NE__Bundle_Configuration__c;
            wrOi.Brand = oi.NE__CatalogItem__r.XC_Brand__c;
            wrOi.BundleTotalOTAmount = (header.get('ClientSystem') == 'E-Commerce') ? oi.XC_BundleTotalOTAmount__c : null;
            wrOi.CreditAssignmentAmount = (header.get('ClientSystem') == 'E-Commerce') ? oi.XC_CreditAssignmentAmount__c : null;
            wrOi.CreditAssignmentCustomerAmount = (header.get('ClientSystem') == 'E-Commerce') ? oi.XC_CreditAssignmentCustomerAmount__c : null;
            wrOi.CatalogItemCategory = (header.get('ClientSystem') == 'E-Commerce') ? oi.XC_CatalogItemCategory__c : null;
            //wrOi.AllowablePaymentTypes = filterMopWithLegalEntity(excludedMopsbyLe.get(oi.NE__OrderId__r.XC_LegalEntity__c+oi.NE__OrderId__r.XC_Segment__c), wrPayments.pickListMap.get(oi.XC_BillingModel__c), oi); //getAllowablePaymentTypes(mdtValues, wrPayments, oi);
            //wrOi.AllowablePaymentTypes = excludedMopsbyLeStr.get(oi.Id);
            wrOi.AllowablePaymentTypes = oi.XC_AllowablePaymentTypes__c;

            if(oi.NE__OrderId__r.XC_LegalEntity__c == Label.XC_CL_EndesaX ){ // exclude commodity bill
                if((oi.XC_Product_Type__c == 'Bundle' || oi.XC_Product_Type__c == 'Equipment' || oi.XC_Product_Type__c == 'Service') &&(oi.XC_Product_Subtype__c != 'Parameter') && String.isBlank(oi.NE__CatalogItem__r.XC_ConvergentBillType__c)){
                    wrOi.AllowablePaymentTypes = wrOi.AllowablePaymentTypes.replace('Commodity Bill, ', '');
                    system.debug('IN Padre'+  wrOi.AllowablePaymentTypes);
                }else if(!String.isBlank(oi.NE__Bundle_Configuration__c) && (oi.NE__Bundle_Configuration__r.XC_Product_Type__c == 'Bundle' || oi.NE__Bundle_Configuration__r.XC_Product_Type__c == 'Equipment' || oi.NE__Bundle_Configuration__r.XC_Product_Type__c == 'Service') &&(oi.NE__Bundle_Configuration__r.XC_Product_Subtype__c != 'Parameter') && String.isBlank(oi.NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ConvergentBillType__c)){
                    wrOi.AllowablePaymentTypes = oi.NE__Bundle_Configuration__r.XC_AllowablePaymentTypes__c.replace('Commodity Bill, ', '');
                }else if(!String.isBlank(oi.NE__Parent_Order_Item__c) && (oi.NE__Parent_Order_Item__r.XC_Product_Type__c == 'Bundle' || oi.NE__Parent_Order_Item__r.XC_Product_Type__c == 'Equipment' || oi.NE__Parent_Order_Item__r.XC_Product_Type__c == 'Service') &&(oi.NE__Parent_Order_Item__r.XC_Product_Subtype__c != 'Parameter') && String.isBlank(oi.NE__Parent_Order_Item__r.NE__CatalogItem__r.XC_ConvergentBillType__c)){
                    wrOi.AllowablePaymentTypes = oi.NE__Parent_Order_Item__r.XC_AllowablePaymentTypes__c.replace('Commodity Bill, ', '');
                }
            }


            if(oi.NE__Catalog__r.XC_LIC_Name__c=='eHome - ES'&&oi.XC_BillingModel__c=='Recurring'){
                wrOi.AllowablePaymentTypes = wrOi.AllowablePaymentTypes.replace('Credit Card, ', '');
            } 
    
            
            wrOi.ConvergentBillType = oi.NE__CatalogItem__r.XC_ConvergentBillType__c; //************** to do - split 
            //type e subtype
            wrOi.ItemCode = oi.NE__Item_Code__c;
            wrOi.RelatedProduct = oi.XC_RelatedProduct__c;
            wrOi.OrderItemType = oi.XC_Product_Type__c;
            wrOi.OrderItemSubType = oi.XC_Product_Subtype__c;
            wrOi.OneTimeFeeOv = oi.NE__OneTimeFeeOv__c;
            wrOi.RecurringChargeOv = oi.NE__RecurringChargeOv__c;
            wrOi.CreditAssignmentSurvey = oi.XC_CreditAssignmentSurvey__c;
            wrOi.CreditAssignmentAvailable = (header.get('ClientSystem') == 'XInstaller') ? oi.XC_CreditAssignmentAvailable__c : null;
            
            wrOi.DeliveryStatus = oi.XC_DeliveryStatus__c;
            wrOi.DeliveryStatusList = oi.XC_DeliveryStatusList__c;
            
            if (oi.NE__StartDate__c!=null){
                wrOi.StartDate = date.newinstance(oi.NE__StartDate__c.year(), oi.NE__StartDate__c.month(), oi.NE__StartDate__c.day()); 
            }
                
            if(mapWithZuoraParameters.containsKey(oi.id)) {
                wrOi.ZSubscriptionId = mapWithZuoraParameters.get(oi.id).get('ZSubscriptionId');
                wrOi.ZAccountId = mapWithZuoraParameters.get(oi.id).get('ZAccountId');
                wrOi.StartDateSubscription = mapWithZuoraParameters.get(oi.id).get('StartDateSubscription');
                wrOi.ZChargeNumber = mapWithZuoraParameters.get(oi.id).get('ZChargeNumber');
            }
            
            wrOi.TechnicalCharacteristic = new List<XC_UTIL_Order.WrapperDocuCharact>();
            for (NE__DocumentationCharacterist__c doc : docuMap.values()){
                if (doc.NE__Product__c == wrOi.ProdID){
                    XC_UTIL_Order.WrapperDocuCharact wr = new XC_UTIL_Order.WrapperDocuCharact();
                    wr.Name = doc.name;
                    wr.Value = doc.NE__Value__c;
                    wrOi.TechnicalCharacteristic.add(wr);
                }
            }
            if (wrOi.TechnicalCharacteristic.isEmpty()){
                wrOi.TechnicalCharacteristic = null;
            }
            
            XC_REST_Order_VVV.populateAssetFields(oi, wrOi, idAssetMap);
            XC_REST_Order_VVV.populateOrdItemAttrFields(oi, wrOi);
            XC_REST_Order_VVV.populateProvisioningSteps(oi, wrOi);
            XC_REST_Order_VVV.populateOiDiscountFields(oi, wrOi);
            //wrOrd.OrderItem.add(wrOi);

            if(wrItemMap.get(oi.NE__OrderId__c)==null){
                List<XC_UTIL_Order.OrderItemWrapper> l = new List<XC_UTIL_Order.OrderItemWrapper>();
                l.add(wrOi);
                wrItemMap.put(oi.NE__OrderId__c, l);

            } else {
                List<XC_UTIL_Order.OrderItemWrapper> l = wrItemMap.get(oi.NE__OrderId__c);
                l.add(wrOi);
                wrItemMap.put(oi.NE__OrderId__c, l);

            }
            
        }

        for(XC_UTIL_Order.OrderIFWrapper wr:wrOrdMap.values()){
            wr.OrderItem = new List<XC_UTIL_Order.OrderItemWrapper>();
            if(wrItemMap.get(wr.OrderID)!=null){
                wr.OrderItem.addAll(wrItemMap.get(wr.OrderID));
                wrResp.order.add(wr);
            }
        }
        
    
    }


    /**
    *@description  exclue the order with at least one CC draft
    *
    * @param orders the order list
    * @param orderItems the orderitem list
    * @param wrResp the wrapper response
    */
    public static void excludeOrderWithCCDraft(Map<String,Object> utilMapFilterOrder){
        
        List<NE__Order__c> orders = (List<NE__Order__c>)utilMapFilterOrder.get('orders');
        List<NE__OrderItem__c> orderItems = (List<NE__OrderItem__c>)utilMapFilterOrder.get('orderItems');
        Set<Id> orderIdToExclude = (Set<Id>) utilMapFilterOrder.get('orderIdToExclude');
        XC_REST_Order_U.WrapperGetResponse wrResp = (XC_REST_Order_U.WrapperGetResponse) utilMapFilterOrder.get('wrResp');

        Map<Id, NE__Order__c> mapOrder = new Map<Id, NE__Order__c>();
        for(NE__Order__c order: orders){
            mapOrder.put(order.Id, order);
        }

        Map<Id, NE__OrderItem__c> mapOiNotExcluded = new Map<Id, NE__OrderItem__c>();
        Map<Id, NE__Order__c> mapOrdersNotExluded = new Map<Id, NE__Order__c>();
        for(NE__OrderItem__c oi:orderItems){
            if(!orderIdToExclude.contains(oi.NE__OrderId__c)){
                mapOiNotExcluded.put(oi.Id, oi); 
                mapOrdersNotExluded.put(oi.NE__OrderId__c, mapOrder.get(oi.NE__OrderId__c));
            }
        }

        if(mapOrdersNotExluded.isEmpty()){
            wrResp.Result.Message = Label.XC_CL_OrderNotFound;
            wrResp.Result.ErrorCode = '400';
            wrResp.Order = new List<XC_UTIL_Order.OrderIFWrapper>();
        }else{
            utilMapFilterOrder.put('orders', mapOrdersNotExluded.values());
            utilMapFilterOrder.put('orderItems', mapOiNotExcluded.values()); // an order must have always at least one order item
        }
    }

    
    /**
    *@description  Gets the zuora infos from order item.
    *
    * @param orderItemList the order item list
    * @return the zuora infos from order item
    */
    public static Map<Id, Map<String, String>> getZuoraInfosFromOrderItem(List<NE__OrderItem__c> orderItemList) {

        List<String> zuoraIdList = XC_UTIL_Sobject.getListFieldValues(orderItemList, 'XC_ZQuoteId__c');

        if(zuoraIdList.isEmpty()){
            return new Map<Id, Map<String, String>>();
        }
    
        Map<Id, zqu__Quote__c> quotesMap = new Map<Id, zqu__Quote__c>([SELECT Id, zqu__ZuoraSubscriptionID__c, zqu__ZuoraAccountID__c, XC_ConfigurationItem__c
                                                                        FROM zqu__Quote__c
                                                                        WHERE Id IN: zuoraIdList]);
        List<zqu__Quote__c> quotes = quotesMap.values();

        Map<Id, Map<String, String>> mapOrderItemIdZParameters = new Map<Id, Map<String, String>>();
        for(zqu__Quote__c q : quotes) {
            Map<String, String> mapZpar = new Map<String, String>();
            mapZpar.put('ZSubscriptionId', q.zqu__ZuoraSubscriptionID__c);
            mapZpar.put('ZAccountId', q.zqu__ZuoraAccountID__c);
            mapOrderItemIdZParameters.put(q.XC_ConfigurationItem__c, mapZpar);
        }

        List<String> zuoraSubscriptionId = XC_UTIL_Sobject.getListFieldValues(quotes,'zqu__ZuoraSubscriptionID__c');

        Map<Id, Zuora__Subscription__c> zSubMap = new Map<Id, Zuora__Subscription__c>([SELECT Id, Zuora__SubscriptionStartDate__c, Zuora__OriginalId__c,
                                                                                        (SELECT Zuora__ChargeNumber__c FROM Zuora__Subscription_Product_Charges__r ORDER BY createdDate desc)
                                                                                        FROM Zuora__Subscription__c
                                                                                        WHERE Zuora__OriginalId__c IN: zuoraSubscriptionId]);
        List<Zuora__Subscription__c> zuoraSubscriptionList = zSubMap.values();
        
        for(Map<String, String> mapZuoraPar : mapOrderItemIdZParameters.values()) {
            for(Zuora__Subscription__c zsub : zuoraSubscriptionList) {
                if(zsub.Zuora__OriginalId__c == mapZuoraPar.get('ZSubscriptionId')) {
                    String zSubsc = mapZuoraPar.get('ZSubscriptionId');
                    mapZuoraPar.put('StartDateSubscription', String.valueOf(zsub.Zuora__SubscriptionStartDate__c));
                    if(!zsub.Zuora__Subscription_Product_Charges__r.isEmpty()){
                        mapZuoraPar.put('ZChargeNumber', zsub.Zuora__Subscription_Product_Charges__r.get(0).Zuora__ChargeNumber__c);
                    }
                }
            }
        }

        return mapOrderItemIdZParameters;
    }


    /*private static String getAllowablePaymentTypes(List<XC_DocumentByPaymentMethod__mdt> mdtValues, XC_UTIL_DependentPicklist.PicklistWrapper wrPayments, NE__OrderItem__c oi){
        List<String> payments = new List<String>();
        List<String> legit = new List<String>{'Direct Debt', 'Bank Transfer', 'Credit Card', 'Barcode', 'External Financing', 'Commodity Bill'};
   
        if(oi.XC_NumPrepayment__c == 0){
            List<String> temp = wrPayments.pickListMap.get(oi.XC_BillingModel__c);
            for(String p:temp){
                if(!legit.contains(p)){ 
                    continue;
                }

                if(p=='Commodity Bill'&&(
                    (oi.NE__CatalogItem__r.XC_ConvergentBillType__c=='GAS'&&!String.isBlank(oi.NE__OrderId__r.NE__OptyId__r.XC_GasContract__c))||
                    (oi.NE__CatalogItem__r.XC_ConvergentBillType__c=='Electric'&&!String.isBlank(oi.NE__OrderId__r.NE__OptyId__r.XC_ElectricContract__c)))){
                    payments.add('Commodity Bill');
                } else if(!(oi.NE__Catalog__r.XC_LIC_Name__c=='eHome - ES'&&oi.XC_BillingModel__c=='Recurring'&&p=='Credit Card')){
                    payments.add(p); 
                }
            } 

        } else {
            for(XC_DocumentByPaymentMethod__mdt m : mdtValues){
                if(m.XC_Legal_Entity__c == oi.NE__OrderId__r.XC_LegalEntity__c){
                    payments.add(m.XC_PaymenMethod__c); 
                }
            }
        } 
 
        String res = '';

        if(payments!=null&&!payments.isEmpty()){
            res = String.valueOf(payments);
            res = res.substring(1,res.length()-1);
        } else {
            res = null;
        }
        
        return res;
    }*/



    private static XC_REST_Order_U.WrapperRes insertOrderItemDiscount(Map<XC_UTIL_Order.OrderItemWrapper, NE__OrderItem__c> mapOIWrOI, XC_REST_Order_U.WrapperRes wr){
        insertOrderItemDiscountOverload(mapOIWrOI, wr, '');
        return wr;
    }

    private static XC_REST_Order_U.WrapperRes insertOrderItemDiscountOverload(Map<XC_UTIL_Order.OrderItemWrapper, NE__OrderItem__c> mapOIWrOI, XC_REST_Order_U.WrapperRes wr, String currencyValue){

        List<NE__Order_Item_Discount__c> oidlist = new List<NE__Order_Item_Discount__c>();
        for(XC_UTIL_Order.OrderItemWrapper i:mapOIWrOI.keySet()){
            if(i.OrderItemDiscount==null){
                continue;
            }
            for(XC_UTIL_Order.WrapperDiscount d:i.OrderItemDiscount){
                NE__Order_Item_Discount__c oid = new NE__Order_Item_Discount__c();
                if(!String.isBlank(currencyValue)){
                    oid.CurrencyIsoCode = currencyValue;
                }
                oid.NE__Asset_update_key__c = d.AssetUpdateKey;
                oid.NE__Code__c = d.Code;
                oid.NE__Discount_Item__c = d.DiscountItem;
                oid.NE__End_Date__c = d.EndDate;
                oid.NE__One_Time_Percentage__c = d.OneTimePercentage;
                oid.NE__One_Time_Price__c = d.OneTimePrice;
                oid.NE__One_Time_Value__c = d.OneTimeValue;
                oid.NE__Reason__c = d.Reason;
                oid.NE__Recurring_Percentage__c = d.RecurringPercentage;
                oid.NE__Recurring_Price__c = d.RecurringPrice;
                oid.NE__Recurring_Value__c = d.RecurringValue;
                oid.NE__Sequence__c = d.Sequence;
                oid.NE__Start_Date__c = d.StartDate;
                oid.NE__Status__c = d.Status;
                oid.NE__Type__c = d.Type;
                oid.NE__Order_Item__c = mapOIWrOI.get(i).id;
                oidlist.add(oid);
            }
        } 

        List<XC_UTIL_Sobject.WrapperResult> insertedOrderItemDis = XC_UTIL_SObject.insertListRecords(oidlist);
        for(XC_UTIL_Sobject.WrapperResult insertResult : insertedOrderItemDis){
            if(!insertResult.success){
                wr.Result.ErrorCode = '500';
                wr.Result.Message = 'INTERNAL ERROR';
                wr.Result.logError = 'INTERNAL ERROR ' + insertResult.errorMessage;
                return wr;
            }
        }

        return wr;
    } 


    /**
    * getExcludedMopsConfs
    *
    * @params: legalEntities - set of legal entities
    * @return: Map<String,String> - the map with legal entity as key and string with excluded payment methods as value
    * @description : method to get all excluded payment methods based on legal entity
    **/
    /*public static Map<String,String> getExcludedMopsConfs(Set<String> legalEntities){

        Map<String,String> leExcludedMop = new Map<String,String>();

        Map<Id, XC_CM_Excluded_MOP_LE__mdt> excludedMopsConfs = new Map<Id, XC_CM_Excluded_MOP_LE__mdt> ([SELECT DeveloperName, XC_Excluded_Payment_Methods__c 
                                                                                                          FROM XC_CM_Excluded_MOP_LE__mdt 
                                                                                                          WHERE DeveloperName IN :legalEntities]);

        for(XC_CM_Excluded_MOP_LE__mdt excludedMops : excludedMopsConfs.values()){
            leExcludedMop.put(excludedMops.DeveloperName, excludedMops.XC_Excluded_Payment_Methods__c);
        }

        return leExcludedMop; 
    }*/


    /**
    * getExcludedMopsConfs
    *
    * @params: legalEntities - set of legal entities
    * @params: streams - set of streams
    * @return: Map<String,String> - the map with legal entity as key and string with excluded payment methods as value
    * @description : method to get all excluded payment methods based on legal entity
    **/
    /*public static Map<String,String> getExcludedMopsConfs(Set<String> legalEntities, Set<String> streams){

        Map<String,String> leExcludedMop = new Map<String,String>();

        Map<Id, XC_CM_Excluded_MOP_LE__mdt> excludedMopsConfs = new Map<Id, XC_CM_Excluded_MOP_LE__mdt> ([SELECT DeveloperName, XC_LegalEntity__c, XC_Stream__c, XC_Excluded_Payment_Methods__c 
                                                                                                          FROM XC_CM_Excluded_MOP_LE__mdt 
                                                                                                          WHERE XC_LegalEntity__c IN :legalEntities AND XC_Stream__c IN :streams]);

        for(XC_CM_Excluded_MOP_LE__mdt excludedMops : excludedMopsConfs.values()){
            leExcludedMop.put(excludedMops.XC_LegalEntity__c+excludedMops.XC_Stream__c, excludedMops.XC_Excluded_Payment_Methods__c);
        }

        return leExcludedMop; 
    }


    /**
    * filterMopWithLegalEntity
    *
    * @params: excludedMopsConfs - string with exclueded mops 
    * @params: mops - the list of payment methods avaiable for a billing model
    * @return: String - the list of payment methods avaiable for a billing model and legal entity
    * @description : method to get all allowable payment methods based on billing model and legal entity
    **/
    /*private static String filterMopWithLegalEntity(String excludedMopsConfs, List<String> mops, NE__OrderItem__c oi){

        List<String> newMopList = new List<String>();
        List<String> mopsToString = new List<String>();
        mopsToString.addAll(mops);

        if(String.isBlank(excludedMopsConfs)){
            return String.join(mopsToString,',');
        }

        // extracting the list of unavailable payment methods from the custom metadata
        String[] excludedMops = excludedMopsConfs.split(';');
        if(excludedMops.isEmpty()){
            return String.join(mopsToString,',');
        }


        if(oi.NE__OrderId__r.XC_LegalEntity__c == Label.XC_CL_EndesaX){
            if(oi.NE__CatalogItem__r.NE__ProductId__r.XC_LIC_Product_Name__c.containsIgnoreCase('OKLuz')  || (!String.isBlank(oi.NE__Parent_Order_Item__c) && oi.NE__Parent_Order_Item__r.NE__CatalogItem__r.NE__ProductId__r.XC_LIC_Product_Name__c.containsIgnoreCase('OKLuz'))){
                newMopList.add(Label.XC_CL_Payment_CommodityBill);
                newMopList.add(Label.XC_CL_DirectDebt);
                return String.join(newMopList,','); 
            }
        }

        if(oi.NE__OrderId__r.XC_LegalEntity__c == Label.XC_CL_LegalEntity_Italy) {
            if(String.isNotBlank(oi.XC_IncentiveName__c)  || (String.isNotBlank(oi.NE__Bundle_Configuration__c) && String.isNotBlank(oi.NE__Bundle_Configuration__r.XC_IncentiveName__c))) {
                newMopList.add(Label.XC_CL_BankTransfer);
                newMopList.add(Label.XC_CL_Payment_ExternalFinancing);
                return String.join(newMopList,','); 
            }
        }
        

        Set<String> excludedMopsSet = new Set<String>();
        excludedMopsSet.addAll(excludedMops);
        

        for(String inputMop : mopsToString){
            //check if the mop is in the excluded mop set
            if(!excludedMopsSet.contains(inputMop)){
                newMopList.add(inputMop);
            }
        }

        newMopList = (!filterForeHome(newMopList, oi).isEmpty()) ?  filterForeHome(newMopList, oi) : newMopList;

        return !newMopList.isEmpty() ? String.join(newMopList,',')  : String.join(mopsToString,',');

    }


    /**
    * filterForeHome
    *
    * @params: newMopList - string with allowable mops 
    * @params: oi - the order item
    * @return: List<String> - list of payment method filtered for eHome catalog
    * @description : method to filter allowable payment methods for eHome catalogs
    **/
    /*public static List<String> filterForeHome(List<String> newMopList, NE__OrderItem__c oi){
        
        List<String> newMopListFiltered = new List<String>();
        if((oi.NE__Catalog__r.XC_LIC_Name__c.containsIgnoreCase('eHome') && oi.XC_BillingModel__c == Label.XC_CL_BillingModel_Recurring)){
            for(String mop : newMopList){
                if(mop != Label.XC_CL_Credit_Card){
                    newMopListFiltered.add(mop);
                }
            }
        }
        return newMopListFiltered; 
    }*/
    

}