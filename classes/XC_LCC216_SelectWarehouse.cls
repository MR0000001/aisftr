public class XC_LCC216_SelectWarehouse {

   @AuraEnabled
   public static String getWarehouseList(String recordId, String filterMap){
       Map<String,Object> filterMapObj = (Map<String,Object>) JSON.deserializeUntyped(filterMap);
       Map<String,String> filterMapStr = new Map<String,String>();
       for(String key : filterMapObj.keySet()){
           filterMapStr.put(key,filterMapObj.get(key)!= null ? String.valueOf(filterMapObj.get(key)) : null);
       }
       filterMapStr.putAll(computeCapexOpexFilter(recordId));
       return JSON.serialize(XC_TR_WorkOrderLineItem_GetFromGlovia.getWarehouseList(new List<String>{recordId},filterMapStr));
    }
    
    
   @AuraEnabled
   public static void setWarehouse(String recordId, String warehouse){
       XC_UTIL_FSLLogistic.WarehouseWrapper warehouseObj = (XC_UTIL_FSLLogistic.WarehouseWrapper) JSON.deserialize(warehouse, XC_UTIL_FSLLogistic.WarehouseWrapper.class);
       WorkOrderLineItem woli = new WorkOrderLineItem();
       woli.Id = recordId;
       woli.XC_WarehouseId__c = warehouseObj.recordId;
       woli.XC_WarehouseCode__c = warehouseObj.warehouseCode;
       
       woli.XC_ShipToCity__c	= warehouseObj.wareHouseCity;
       woli.XC_ShipToCountry__c = warehouseObj.wareHouseCountry;
       woli.XC_ShipToStateProvince__c = warehouseObj.wareHouseStateProvince;
       woli.XC_ShipToStreet__c = warehouseObj.wareHouseStreet;
       woli.XC_ShipToZipPostalCode__c = warehouseObj.wareHouseZipPostalCode;
       
       update woli;
       
       //[Begin - NR2357 - 28/02/2022 - DK - ET - Update related form cases under the woli 
       List<XC_FormCase__c> formCases = [SELECT Id FROM XC_FormCase__c WHERE XC_Return_Material__c =: recordId];

       for(XC_FormCase__c form : formCases){
           form.XC_Return_to_City__c = warehouseObj.wareHouseCity;
           form.XC_Return_to_Country__c = warehouseObj.wareHouseCountry;
           form.XC_Return_to_State_Province__c = warehouseObj.wareHouseStateProvince;
           form.XC_Return_to_Street__c = warehouseObj.wareHouseStreet;
           form.XC_Return_to_Zip_Code__c = warehouseObj.wareHouseZipPostalCode;
       }
       update formCases;
       //[End - NR2357 - 28/02/2022 - DK - ET - Update related form cases under the woli
   
   }

   private static Map<String,String> computeCapexOpexFilter(String recordId) {
        Map<String, String> filters = new Map<String, String>();
        String capexOpex = 'capexOpex';
        WorkOrderLineItem woli = [SELECT Id, WorkOrder.XC_Country__c, WorkOrder.XC_Configuration__c FROM WorkOrderLineItem WHERE Id = :recordId];
        String configId = woli.WorkOrder.XC_Configuration__c;
        List<NE__OrderItem__c> orderItems = [SELECT XC_Wbe__c, NE__OrderId__c FROM NE__OrderItem__c WHERE NE__OrderId__c = :configId AND NE__Root_Order_Item__c = NULL];
        if(!orderItems.isEmpty()) {
            NE__OrderItem__c oi = orderItems.get(0);
            if(woli.WorkOrder.XC_Country__c == 'Colombia' && String.isNotBlank(oi.XC_Wbe__c)) {
                String digit11 = oi.XC_Wbe__c.substring(10,11);
                if(digit11.equalsIgnoreCase('Y')) {
                    filters.put(capexOpex, 'Opex');
                } else if(digit11.equalsIgnoreCase('W')) {
                    filters.put(capexOpex, 'Capex');
                }
            }
        }
        return filters;
   }
}