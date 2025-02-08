public without sharing class TA_LCC233_QuoteSummary {

    public class QuoteWrapper {
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public Decimal oneTimeFeeTotal {get; set;}
        @AuraEnabled
        public String status {get; set;}
        @AuraEnabled
        public Boolean show {get; set;}
        @AuraEnabled
        public Boolean editEnabled {get; set;}
        @AuraEnabled
        public String workOrderId {get; set;}
        @AuraEnabled
        public String opptyId {get; set;}
        @AuraEnabled
        public List<ItemWrapper> items {get; set;}

        public QuoteWrapper(String id, String name, Decimal oneTimeFeeTotal, String status, String workOrderId, String opptyId) {
            this.id = id;
            this.name = name;
            this.oneTimeFeeTotal = oneTimeFeeTotal;
            this.status = status;
            this.show = false;
            this.editEnabled = false;
            this.workOrderId = workOrderId;
            this.opptyId = opptyId;
            this.items = new List<ItemWrapper>();  
        }
    }

    public class ItemWrapper {
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public String prodName {get; set;}
        @AuraEnabled
        public String quoteId {get; set;}
        @AuraEnabled
        public String billingModel {get; set;}
        @AuraEnabled
        public Decimal oneTimeFee {get; set;}
        @AuraEnabled
        public Decimal qty {get; set;}
        @AuraEnabled
        public String transletedProdName {get; set;}

        public ItemWrapper(String id, String prodName, String quoteId, String billingModel, Decimal oneTimeFee, Decimal qty, String transletedProdName) {
            this.id = id;
            this.prodName = prodName;
            this.quoteId = quoteId;
            this.billingModel = billingModel;
            this.oneTimeFee = oneTimeFee;
            this.qty = qty;
            this.transletedProdName = transletedProdName;
        }
    }

    @AuraEnabled
    public static List<QuoteWrapper> getQuotes(WorkOrder workOrder, String recordType, String quoteToAccept) {
        List<QuoteWrapper> quoteWrappers = new List<QuoteWrapper>();
        try 
        {
            List<Id> opptyIdList = new List<Id>();
            if(String.isNotBlank(workOrder.XC_Opportunity__c)) {
                opptyIdList.add(workOrder.XC_Opportunity__c);
            }

            List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE XC_WorkOrder__c = :workOrder.Id];
            for(Opportunity opp : oppList) {
                opptyIdList.add(opp.Id);
            }

            List<NE__Order__c> orderList = [SELECT Id,
                                                Name,
                                                NE__One_Time_Fee_Total__c,
                                                XC_Status__c,
                                                NE__OptyId__c
                                            FROM NE__Order__c
                                            WHERE NE__OptyId__c IN :opptyIdList
                                                AND RecordType.DeveloperName = :recordType
                                                AND XC_Status__c NOT IN ('Rejected')];

            Set<String> orderIdList = new Set<String>();
            for(NE__Order__c order : orderList) {
                if(recordType == 'opty' || (recordType == 'quote' && String.isNotBlank(quoteToAccept) && order.Id == quoteToAccept) || (recordType == 'quote' && order.XC_Status__c == 'Accepted')) {
                    orderIdList.add(order.Id);
                    quoteWrappers.add(new QuoteWrapper(order.Id, order.Name, order.NE__One_Time_Fee_Total__c, order.XC_Status__c, workOrder.Id, order.NE__OptyId__c));
                }
            }

            List<NE__OrderItem__c> orderItemList = [SELECT Id,
                                                        NE__OrderId__c,
                                                        NE__ProdName__c,
                                                        XC_BillingModel__c,
                                                        NE__OneTimeFeeOv__c,
                                                        XC_TranslatedProductName__c,
                                                        NE__Qty__c
                                                    FROM NE__OrderItem__c
                                                    WHERE NE__OrderId__c IN :orderIdList];

            for(QuoteWrapper quoteWrapper : quoteWrappers) {
                quoteWrapper.items = new List<ItemWrapper>();
                for(NE__OrderItem__c orderItem : orderItemList) {
                    if(orderItem.NE__OrderId__c == quoteWrapper.id) {
                        quoteWrapper.items.add(new ItemWrapper(orderItem.Id,
                                                        orderItem.NE__ProdName__c,
                                                        orderItem.NE__OrderId__c,
                                                        orderItem.XC_BillingModel__c,
                                                        orderItem.NE__OneTimeFeeOv__c,
                                                        orderItem.NE__Qty__c,
                                                        orderItem.XC_TranslatedProductName__c));
                    }
                }
            }
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC233_QuoteSummary] getQuotes - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC233_QuoteSummary', 'getQuotes', errorMessage, 0, errorMessage, null);
        }
        return quoteWrappers;
    }

    @AuraEnabled
    public static void updateToPhaseEvaluation(WorkOrder workOrder, String parameters) {
        try {
            workOrder.TA_Phase__c = 'Evaluation';
            Map<String, String> taParameters = new Map<String, String>();
            Map<String, Object> evtParam = (Map<String, Object>) JSON.deserializeUntyped(parameters);
            for(String evtParamKey : evtParam.keySet()) {
                taParameters.put(evtParamKey, String.valueOf(evtParam.get(evtParamKey)));
            }
            workOrder.TA_Parameters__c = JSON.serialize(taParameters);
            update workOrder;
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC233_QuoteSummary] updateToPhaseEvaluation - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC233_QuoteSummary', 'updateToPhaseEvaluation', errorMessage, 0, errorMessage, null);
        }
    }

    @AuraEnabled
    public static void moveOrdersToMainOppty(WorkOrder workOrder) {
        try {
            List<Opportunity> secondaryOpptyList = [SELECT Id FROM Opportunity WHERE XC_WorkOrder__c = :workOrder.Id];

            List<Id> secondaryOpptyIdList = new List<Id>();
            for(Opportunity secondaryOppty : secondaryOpptyList) {
                secondaryOpptyIdList.add(secondaryOppty.Id);
            }

            List<NE__Order__c> secondaryOrderList = [SELECT Id FROM NE__Order__c WHERE NE__OptyId__c IN :secondaryOpptyIdList];
            for(NE__Order__c secondaryOrder : secondaryOrderList) {
                secondaryOrder.NE__OptyId__c = workOrder.XC_Opportunity__c;
            }
            update secondaryOrderList;
            delete secondaryOpptyList;
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC233_QuoteSummary] moveOrdersToMainOppty - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC233_QuoteSummary', 'moveOrdersToMainOppty', errorMessage, 0, errorMessage, null);
        }
    }

    @AuraEnabled
    public static Map<String, String> changeOrderRecordType(WorkOrder workOrder, String selectedQuote) {
        Map<String, String> returnWrapper = new Map<String, String>();
        try {
            List<NE__Order__c> listOrder = [SELECT Id FROM NE__Order__c WHERE NE__OptyId__c = :workOrder.XC_Opportunity__c AND RecordType.DeveloperName = 'Opty'];

            for(NE__Order__c order : listOrder) {
                XC_UTIL_Order.OrderIFWrapper orderIfWrapper = new XC_UTIL_Order.OrderIFWrapper();
                orderIfWrapper.OrderID = order.Id;

                XC_REST_Order_U.WrapperPUTRequest wrReq = new XC_REST_Order_U.WrapperPUTRequest();
                wrReq.Order = orderIfWrapper;

                XC_REST_Order_U.WrapperRes wrResp = new XC_REST_Order_U.WrapperRes();

                Map<String,String> header = new Map<String,String> {
                    'ClientSystem' => 'XInstaller',
                    'DateTimeMessage' => DateTime.now().format('yyyyMMddHHmmssSSS'),
                    'TransactionID' => 'acceptQuote',
                    'Operation' => 'Create',
                    'Functionality' => 'CreateOrder',
                    'ServerSystem' => 'XCustomerB2C'
                };

                Map<String, Object> mapUtil = new Map<String, Object> {
                    'header' => header,
                    'wrReq' => wrReq,
                    'direction' => 'Inbound'
                };

                XC_UTIL_Integration.WrapperResult responseValidation = XC_UTIL_RESTInbound.checkObjectPermission('NE__Order__c', 'create');
                if(responseValidation.errorFlag) {
                    wrResp.Result.Message = responseValidation.errorMessage;
                    wrResp.Result.ErrorCode = '400';
                    returnWrapper.put('error', wrResp.Result.Message);
                    return returnWrapper;
                }

                String recordTypeDevName = [SELECT RecordType.DeveloperName FROM NE__Order__c WHERE Id =: order.Id].RecordType.DeveloperName;

                Map<String, List<NE__Order_Item_Attribute__c>> mapOrdItemIdOIA = new  Map<String, List<NE__Order_Item_Attribute__c>>();
                Map<String, Object> mapOrder = new Map<String, Object> {
                    'mapOrdItemIdOIA'=> mapOrdItemIdOIA,
                    'wrReq' => wrReq,
                    'clientSystem' => header.get('ClientSystem'),
                    'recordTypeOrder' => recordTypeDevName
                };

                responseValidation = XC_REST_Order_Z.validateReq(mapUtil);
                if(responseValidation.errorFlag) {
                    wrResp.Result.Message = 'ERROR. ' + responseValidation.errorMessage;
                    wrResp.Result.ErrorCode = (responseValidation.errorCode != '401' && responseValidation.errorCode != '402') ? '400' : responseValidation.errorCode;
                    wrResp.Order = null;
                    returnWrapper.put('error', wrResp.Result.Message);
                    return returnWrapper;
                }

                if(recordTypeDevName == 'Opty') {
                    //XC_REST_Order_U.manageOptyToQuote(mapOrder, wrResp, 'Quote');
                    manageOptyToQuote(mapOrder, wrResp, 'Quote');

                    if(wrResp.Result.ErrorCode != '0') {
                        returnWrapper.put('error', wrResp.Result.Message);
                        return returnWrapper;
                    } else if(order.Id == selectedQuote) {
                        returnWrapper.put('quoteToAccept', wrResp.Order.OrderID);
                    }
                }
            }
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC233_QuoteSummary] changeOrderRecordType - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC233_QuoteSummary', 'changeOrderRecordType', errorMessage, 0, errorMessage, null);
        }
        return returnWrapper;
    }

    /* [20201223AL] - START FIX */
    public static void manageOptyToQuote(Map<String, Object> mapOrder, XC_REST_Order_U.WrapperRes wr, String recordTypeName) {
        wr.Order = new XC_UTIL_Order.OrderIFWrapper();
        wr.Order.OrderItem = null;

        String recordTypeOrder = (String) mapOrder.get('recordTypeOrder');
        XC_REST_Order_U.WrapperPUTRequest putRequest=(XC_REST_Order_U.WrapperPUTRequest) mapOrder.get('wrReq');

        if(recordTypeOrder != 'Opty') {
            wr.Result.Message = 'INTERNAL ERROR: Invalid Record Type';
            wr.Result.ErrorCode = '500';
            wr.Order = null;
            wr.Result.logError = 'INTERNAL ERROR: Invalid Record Type';
            return;
        }

        orderToOrder(mapOrder, wr, recordTypeName);

        if(wr.Result.ErrorCode =='500') {
            return;
        }

        wr.Result.ErrorCode = '0';
        wr.Result.Message = 'Operation completed successfully';
    }

    public static void orderToOrder(Map<String,Object> utilMap, XC_REST_Order_U.WrapperRes wresp, String recordTypeName) {
        XC_REST_Order_U.WrapperPUTRequest putRequest = (XC_REST_Order_U.WrapperPUTRequest) utilMap.get('wrReq');
        XC_REST_Order_U.WrapperPOSTRequest postRequest = (XC_REST_Order_U.WrapperPOSTRequest) utilMap.get('postRequest');

        String objectId = '';
        if(putRequest == null) {
            objectId = (String) utilMap.get('optyId');
        } else {
            objectId = putRequest.Order.OrderID;
        }

        /*Integer beforeDataMapTime = Limits.getCpuTime();
        System.Debug('CHECK CPU USE BEFORE DATAMAP:::: ' + beforeDataMapTime);*/

        NE.DataMap.DataMapRequest dReq = new NE.DataMap.DataMapRequest();
        dReq.mapName = 'Order2Order';
        dReq.sourceId = objectId;
        NE.DataMap mp = new NE.DataMap();
        NE.DataMap.DataMapResponse dResp = mp.callDataMap(dReq);

        if(dresp.ErrorCode != '0') {
            wresp.Result.Message = dResp.errorMessage;
            wresp.Result.ErrorCode = '500';
            wresp.Order = null;
            wresp.Result.logError = 'INTERNAL ERROR: B2W Error ' + dResp.errorMessage;
            return;
        }

        wresp.Order.OrderID = dResp.ParentId;
        utilMap.put('orderID', dResp.ParentId);
        updateBit2winConfiguration(dResp.ParentId, recordTypeName, utilMap);

        /*Integer afterDataMapTime = Limits.getCpuTime();
        System.Debug('CHECK CPU USE AFTER DATAMAP:::: ' + afterDataMapTime  + ' EXECUTIONTIME ' + (afterDataMapTime-beforeDataMapTime));*/
    }

    public static void updateBit2winConfiguration(String parentId, String recordTypeName, Map<String,Object> utilMap) {
        NE__Order__c orderToUpdate;

        if(recordTypeName == 'Order') {
            orderToUpdate = new NE__Order__c(ID = parentId, NE__OrderStatus__c = 'Pending', RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId(), XC_Status__c = 'In Progress' );
        } else if(recordTypeName == 'Quote') {
            orderToUpdate = new NE__Order__c(ID = parentId, NE__OrderStatus__c = 'Active', RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId(), XC_Status__c = 'Draft' );
        }

        System.debug('order to update####' + orderToUpdate);
        XC_UTIL_Sobject.WrapperResult res = new XC_UTIL_Sobject.WrapperResult();
        res = XC_UTIL_SObject.updateRecord(orderToUpdate);
    }
    /* [20201223AL] - END FIX */

    @AuraEnabled
    public static Map<String, String> updateQuote(WorkOrder workOrder, String quoteStatus, String quoteToAccept) {
        Map<String, String> returnWrapper = new Map<String, String>();
        try {
            if(quoteStatus == 'Rejected' || quoteStatus == 'Notified to client') {
                List<NE__Order__c> listOrder = [SELECT Id, XC_InstallationAddress__c, XC_DeliveryAddress__c 
                                                FROM NE__Order__c 
                                                WHERE NE__OptyId__c = :workOrder.XC_Opportunity__c 
                                                AND RecordType.DeveloperName = 'Quote'];
                List<WorkOrder> myWorkOrderList = new List<WorkOrder>();
                List<NE__Order__c> listOrdersToUpdate = new List<NE__Order__c>();

                if(String.isBlank(workOrder.XC_Address__c)){
                    myWorkOrderList = [SELECT Id, XC_Address__c FROM WorkOrder WHERE Id = :workOrder.Id];
                }

                for(NE__Order__c order : listOrder) {
                    XC_UTIL_Order.OrderIFWrapper orderIfWrapper = new XC_UTIL_Order.OrderIFWrapper();
                    orderIfWrapper.OrderID = order.Id;

                    XC_REST_Order_U.WrapperPUTRequest wrReq = new XC_REST_Order_U.WrapperPUTRequest();
                    wrReq.Order = orderIfWrapper;
                    wrReq.Order.OrderStatus = quoteStatus;

                    XC_REST_Order_U.WrapperRes wrResp = new XC_REST_Order_U.WrapperRes();

                    Map<String,String> header = new Map<String,String> {
                        'ClientSystem' => 'XInstaller',
                        'DateTimeMessage' => DateTime.now().format('yyyyMMddHHmmssSSS'),
                        'TransactionID' => 'acceptQuote',
                        'Operation' => 'Create',
                        'Functionality' => 'CreateOrder',
                        'ServerSystem' => 'XCustomerB2C'
                    };

                    Map<String, Object> mapUtil = new Map<String, Object> {
                        'header' => header,
                        'wrReq' => wrReq,
                        'direction' => 'Inbound'
                    };

                    XC_UTIL_Integration.WrapperResult responseValidation = XC_UTIL_RESTInbound.checkObjectPermission('NE__Order__c', 'update');
                    if(responseValidation.errorFlag) {
                        wrResp.Result.Message = responseValidation.errorMessage;
                        wrResp.Result.ErrorCode = '400';
                        returnWrapper.put('error', wrResp.Result.Message);
                        return returnWrapper;
                    }

                    String recordTypeDevName = [SELECT RecordType.DeveloperName FROM NE__Order__c WHERE Id =: orderIfWrapper.OrderID].RecordType.DeveloperName;

                    Map<String, List<NE__Order_Item_Attribute__c>> mapOrdItemIdOIA = new  Map<String, List<NE__Order_Item_Attribute__c>>();
                    Map<String, Object> mapOrder = new Map<String, Object> {
                        'mapOrdItemIdOIA' => mapOrdItemIdOIA,
                        'wrReq' => wrReq,
                        'clientSystem' => header.get('ClientSystem'),
                        'recordTypeOrder' => recordTypeDevName
                    };

                    responseValidation = XC_REST_Order_Z.validateReq(mapUtil);
                    if(responseValidation.errorFlag) {
                        wrResp.Result.Message = 'ERROR. ' + responseValidation.errorMessage;
                        wrResp.Result.ErrorCode = (responseValidation.errorCode != '401' && responseValidation.errorCode != '402') ? '400' : responseValidation.errorCode;
                        wrResp.Order = null;
                        returnWrapper.put('error', wrResp.Result.Message);
                        return returnWrapper;
                    } else {
                        XC_REST_Order_U.updateOrders(mapOrder, wrResp);
                        if(wrResp.Result.ErrorCode != '0') {
                            returnWrapper.put('error', wrResp.Result.Message);
                            return returnWrapper;
                        } else {
                            workOrder.TA_Parameters__c = '';
                            update workOrder;
                        }
                    }

                    Boolean isChanged = false;

                    if(String.isBlank(order.XC_InstallationAddress__c)){
                        if(myWorkOrderList.isEmpty()){
                            order.XC_InstallationAddress__c = workOrder.XC_Address__c;
                        } else {
                            order.XC_InstallationAddress__c = myWorkOrderList[0].XC_Address__c;
                        }
                        isChanged = true;
                    }

                    if(String.isBlank(order.XC_DeliveryAddress__c)){
                        if(myWorkOrderList.isEmpty()){
                            order.XC_DeliveryAddress__c = workOrder.XC_Address__c;
                        } else {
                            order.XC_DeliveryAddress__c = myWorkOrderList[0].XC_Address__c;
                        }
                        isChanged = true;
                    }

                    if(isChanged){
                        listOrdersToUpdate.add(order);
                    }
                }

                if(!listOrdersToUpdate.isEmpty()){
                    update listOrdersToUpdate;
                }

            } else if(quoteStatus == 'Accepted') {
                workOrder.Latitude = null;
                workOrder.Longitude = null;
                workOrder.TA_Parameters__c = '{"quoteToAccept":"' + quoteToAccept + '"}';
                update workOrder;

                List<NE__Order__c> listOrder = [SELECT Id, XC_InstallationAddress__c, XC_DeliveryAddress__c FROM NE__Order__c WHERE NE__OptyId__c = :workOrder.XC_Opportunity__c AND RecordType.DeveloperName = 'Quote'];
                List<WorkOrder> myWorkOrderList = new List<WorkOrder>();
                List<NE__Order__c> listOrdersToUpdate = new List<NE__Order__c>();

                if(String.isBlank(workOrder.XC_Address__c)){
                    myWorkOrderList = [SELECT Id, XC_Address__c FROM WorkOrder WHERE Id = :workOrder.Id];
                }

                for(NE__Order__c order : listOrder) {
                    Boolean isChanged = false;

                    if(String.isBlank(order.XC_InstallationAddress__c)){
                        if(myWorkOrderList.isEmpty()){
                            order.XC_InstallationAddress__c = workOrder.XC_Address__c;
                        } else {
                            order.XC_InstallationAddress__c = myWorkOrderList[0].XC_Address__c;
                        }
                        isChanged = true;
                    }

                    if(String.isBlank(order.XC_DeliveryAddress__c)){
                        if(myWorkOrderList.isEmpty()){
                            order.XC_DeliveryAddress__c = workOrder.XC_Address__c;
                        } else {
                            order.XC_DeliveryAddress__c = myWorkOrderList[0].XC_Address__c;
                        }
                        isChanged = true;
                    }

                    if(isChanged){
                        listOrdersToUpdate.add(order);
                    }
                }

                if(!listOrdersToUpdate.isEmpty()){
                    update listOrdersToUpdate;
                }
                
            }
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC233_QuoteSummary] updateQuote - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC233_QuoteSummary', 'updateQuote', errorMessage, 0, errorMessage, null);
        }
        return returnWrapper;
    }
}