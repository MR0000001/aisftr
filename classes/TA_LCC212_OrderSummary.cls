public without sharing class TA_LCC212_OrderSummary {

    public class InfoBag {
        @AuraEnabled
        public List<FieldWrapper> order {get; set;}

        @AuraEnabled
        public List<OrderItemWrapper> orderItemsBundle {get; set;}

        @AuraEnabled
        public List<OrderItemWrapper> orderItemsEquipment {get; set;}
    }

    public class OrderItemWrapper {
        @AuraEnabled
        public List<FieldWrapper> orderItemFields {get; set;}

        @AuraEnabled
        public List<List<FieldWrapper>> childOrderItems {get; set;}

        public OrderItemWrapper (){
            this.orderItemFields = new List<FieldWrapper>();
            this.childOrderItems = new List<List<FieldWrapper>>();
        }

    }

    public class FieldWrapper {
        @AuraEnabled
        public String apiName {get; set;}

        @AuraEnabled
        public String label {get; set;}

        @AuraEnabled
        public String value {get; set;}
    }

    @AuraEnabled
    public static String initialize(WorkOrder workOrder, String customSet) {
        InfoBag infoBag = new InfoBag();
        infoBag.order = new List<FieldWrapper>();
        infoBag.orderItemsBundle = new List<OrderItemWrapper> ();
        infoBag.orderItemsEquipment = new List<OrderItemWrapper> ();

        try {
            Map<String, Object> deserializedJson = (Map<String, Object>) JSON.deserializeUntyped(customSet);

            if(deserializedJson != null) {
                List<Object> orderFields = (List<Object>) deserializedJson.get('NE__Order__c');
                List<String> listOrderFieldApiName = new List<String>();

                for(Object orderField : orderFields) {
                    Map<String, Object> ordFieldMap = (Map<String, Object>) orderField;
                    listOrderFieldApiName.add(String.valueOf(ordFieldMap.get('apiName')));
                }

                //START FIX - [#20210325AL]
                String queryOrder = 'SELECT Id, ' + String.join(listOrderFieldApiName, ',') + ' FROM NE__Order__c';
                Boolean toQuery = false;
                if(String.isNotBlank(workOrder.XC_Configuration__c)) {
                    queryOrder += ' WHERE Id = \'' + workOrder.XC_Configuration__c + '\'';
                    toQuery = true;
                }
                //START FIX - [ADC06/07/2021] ENXCRM-165
                else if(String.isNotBlank(workOrder.AssetId)) {
                    List<WorkOrder> workOrders = [SELECT Id, AssetId, Asset.NE__Order_Config__c FROM WorkOrder WHERE Id =:workOrder.Id];
                    if(!workOrders.isEmpty()){
                        queryOrder += ' WHERE Id = \'' + workOrders[0].Asset.NE__Order_Config__c + '\'';
                        toQuery = true;
                    }
                }
                //END FIX - [ADC06/07/2021] ENXCRM-165
                else {
                    List<WorkOrder> workOrders = [SELECT Id, ParentWorkOrderId, ParentWorkOrder.XC_Configuration__c FROM WorkOrder WHERE Id =:workOrder.Id];
                    if(!workOrders.isEmpty() && 
                        String.isNotBlank(workOrders[0].ParentWorkOrderId) && 
                        String.isNotBlank(workOrders[0].ParentWorkOrder.XC_Configuration__c)) {
                        queryOrder += ' WHERE Id = \'' + workOrders[0].ParentWorkOrder.XC_Configuration__c + '\'';
                        toQuery = true;
                    }
                }               

                //String queryOrder = 'SELECT Id, ' + String.join(listOrderFieldApiName, ',') + ' FROM NE__Order__c WHERE Id = \'' + workOrder.XC_Configuration__c + '\'';
                //END FIX - [#20210325AL]

                
                if(toQuery) {
                    List<NE__Order__c> listOrder = Database.query(queryOrder);

                    if(listOrder.size() > 0) {
                        // SObjectType sObjectType;
                        // Map<String, Schema.SObjectField> fieldsMap;
                        // Schema.SObjectField sObjectField;

                        //ENXCRM-87
                        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                        Schema.SObjectType orderSchema = schemaMap.get('NE__Order__c');
                        Map<String, Schema.SObjectField> orderFieldLabelsMap = orderSchema.getDescribe().fields.getMap();
                        Schema.SObjectType orderItemSchema = schemaMap.get('NE__OrderItem__c');
                        Map<String, Schema.SObjectField> orderItemFieldLabelsMap = orderItemSchema.getDescribe().fields.getMap();

                        List<FieldWrapper> orderFieldWrapper = createFieldWrapperList(listOrder.get(0), orderFields, orderFieldLabelsMap);
                        infoBag.order = orderFieldWrapper;
    
                        List<Object> orderItemFields = (List<Object>) deserializedJson.get('NE__OrderItem__c');
                        List<String> listOrderItemFieldApiName = new List<String>();
    
                        for(Object orderItemField : orderItemFields) {
                            Map<String, Object> ordItemFieldMap = (Map<String, Object>) orderItemField;
                            listOrderItemFieldApiName.add(String.valueOf(ordItemFieldMap.get('apiName')));
                        }
    
                        String queryOrderItem = 'SELECT Id, ' + String.join(listOrderItemFieldApiName, ',') + ',(SELECT Id, ' + String.join(listOrderItemFieldApiName, ',') + ' FROM NE__OrderItem__c.NE__Bundle_Configuration__r )' + ' FROM NE__OrderItem__c WHERE NE__Bundle_Configuration__c = null AND NE__OrderId__c = \'' + listOrder[0].Id + '\'';

                        system.debug('>_> query : ' + queryOrderItem);
                        List<NE__OrderItem__c> listOrderItem = Database.query(queryOrderItem);
                        
                        for(NE__OrderItem__c orderItem : listOrderItem) {

                            OrderItemWrapper oiWrapper = new OrderItemWrapper();
                            
                            List<FieldWrapper> listFieldWrapper = createFieldWrapperList(orderItem, orderItemFields, orderItemFieldLabelsMap);
                            oiWrapper.orderItemFields = listFieldWrapper;

                            for (NE__OrderItem__c orderItemChild : orderItem.NE__Bundle_Configuration__r){
                                List<FieldWrapper> listFieldWrapperChild = createFieldWrapperList(orderItemChild, orderItemFields, orderItemFieldLabelsMap);
                                oiWrapper.childOrderItems.add(listFieldWrapperChild);
                            }

                            if(orderItem.XC_Product_Type__c == 'Bundle'){
                                infoBag.orderItemsBundle.add(oiWrapper);
                            } else {
                                infoBag.orderItemsEquipment.add(oiWrapper);
                            }
                        }
                        system.debug('>_> infobag : ' + JSON.serialize(infobag));
                    }
                }
            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC212_OrderSummary] initialize - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC212_OrderSummary', 'initialize', errorMessage, 0, errorMessage, null);
        }
        return JSON.serialize(infoBag);
    }

    private static List<FieldWrapper> createFieldWrapperList(SObject sObj, List<Object> objFields, Map<String, Schema.SObjectField> objFieldLabelsMap){
        List<FieldWrapper> listFieldWrapper = new List<FieldWrapper>();

        for(Object objField : objFields) {
            Map<String, Object> objFieldMap = (Map<String, Object>) objField;
            FieldWrapper fieldWrapper = new FieldWrapper();
            fieldWrapper.apiName = String.valueOf(objFieldMap.get('apiName'));
            // fieldWrapper.label = String.valueOf(objFieldMap.get('label'));
            fieldWrapper.label = String.valueOf(objFieldLabelsMap.get(fieldWrapper.apiName).getDescribe().getLabel());

            if(String.valueOf(objFieldMap.get('apiName')).contains('.')) {
                fieldWrapper.value = String.valueOf(sObj.getSObject(String.valueOf(objFieldMap.get('apiName')).split('\\.').get(0)).get(String.valueOf(objFieldMap.get('apiName')).split('\\.').get(1)));
            } else {
                fieldWrapper.value = String.valueOf(sObj.get(String.valueOf(objFieldMap.get('apiName'))));
            }
            listFieldWrapper.add(fieldWrapper);
        }

        return listFieldWrapper;

    }
}