public without sharing class Giic_TR_SalesOrder_UTIL {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_TR_SalesOrder_UTIL');   
    
    public class SalesOrderWrapper{
        public Id salesOrderId;
        public Integer totalTransferOrder = 0;
        public Integer totalPurchaseOrder = 0;
        public gii__SalesOrder__c salesOrder = new gii__SalesOrder__c();
        public Id workOrderId;
    } 
    
     public static void setLEOnSO(List<gii__SalesOrder__c> listNew){
         XC_UTIL_Debug.debug(DEBUGACTIVE,'In setLEOnSO----->>' );
        List<String> whTransferIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'gii__Warehouse__c');
        map<Id,gii__Warehouse__c> p2Maps = new  map<Id,gii__Warehouse__c> ([SELECT Id, giic_LegalEntity__c FROM gii__Warehouse__c WHERE Id IN: whTransferIds ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'p2Maps = '+p2Maps.values());
        for(gii__SalesOrder__c s : listNew){   
             for(gii__Warehouse__c w : p2Maps.values()){
                 if(s.gii__Warehouse__c == w.Id && w.giic_LegalEntity__c != null){
                    	s.giic_LegalEntity__c = w.giic_LegalEntity__c;
                 }
             }
            
        }
        
    }
    
    
    public static void checkIfNeedCustomerInteraction(List<gii__SalesOrder__c> listNew, Map<Id, gii__SalesOrder__c> mapOld){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In checkIfNeedCustomerInteraction----->>' );
        map<Id,Id> salesOrderIdToWorkOrderId = new map<Id,Id>();
        for(gii__SalesOrder__c so : listNew ){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'giic_OrderStatus__c----->>' +so.giic_OrderStatus__c);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'gii__Dropship__c----->>' +so.gii__Dropship__c);
            if(mapOld.get(so.Id).giic_OrderStatus__c!= 'Completed' && so.giic_OrderStatus__c == 'Completed' && !so.gii__Dropship__c ){ 
                salesOrderIdToWorkOrderId.put(so.Id, so.giic_WorkOrder__c); 

            }
        }
        
        List<SalesOrderWrapper> soWrList = populateSalesOrderWrapper(salesOrderIdToWorkOrderId);
        List<Id> workOrderForPickupCI = new List<Id>();
        List<Id> workOrderForOthersCI = new List<Id>();
        List<Id> workOrderForInstallCI = new List<Id>();
        map<Id,String> workOrderRejectReason = new  map<Id,String>();
        for(SalesOrderWrapper soWr : soWrList){
            if(soWr.totalTransferOrder>0 && soWr.totalPurchaseOrder == 0 && soWr.salesOrder.giic_IsDelivery__c){
                workOrderForPickupCI.add(soWr.workOrderId);
            }else if(soWr.totalPurchaseOrder == 0 && soWr.totalTransferOrder == 0  && !soWr.salesOrder.giic_IsDelivery__c){
                workOrderForInstallCI.add(soWr.workOrderId); 
            }/*else if(soWr.totalPurchaseOrder > 0 && soWr.totalTransferOrder>0 && soWr.salesOrder.giic_IsDelivery__c){ 
                workOrderForOthersCI.add(soWr.workOrderId); 
            }*/
        }
        map<Id,WorkOrder> workOrderMapPickup  = new map<Id,WorkOrder>();
        map<Id,WorkOrder> workOrderMapOther  = new map<Id,WorkOrder>();
        map<Id,WorkOrder> workOrderMapInstall  = new map<Id,WorkOrder>();
        if(!workOrderForPickupCI.isEmpty()){ 
            workOrderMapPickup = giic_TR_PurchaseOrder_ManageUpdate.getWoMap(workOrderForPickupCI);
        }
        /*if(!workOrderForOthersCI.isEmpty()){ 
            workOrderMapOther = giic_TR_PurchaseOrder_ManageUpdate.getWoMap(workOrderForOthersCI);  
        } */
        if(!workOrderForInstallCI.isEmpty()){ 
            workOrderMapInstall = giic_TR_PurchaseOrder_ManageUpdate.getWoMap(workOrderForInstallCI);  
        }
        List<XC_Customer_Interaction__c> orderPickCustomInterList = new  List<XC_Customer_Interaction__c>(); 
        orderPickCustomInterList = giic_TR_PurchaseOrder_ManageUpdate.populateCustomInterListFromPO(workOrderMapPickup.values(),  'Orders_Pickup',workOrderRejectReason);
        /*if(!workOrderMapOther.isEmpty()){ 
            orderPickCustomInterList.addAll(giic_TR_PurchaseOrder_ManageUpdate.populateCustomInterListFromPO(workOrderMapOther.values(),  'Orders_Pickup_NoStock') );
        }*/
        if(!workOrderMapInstall.isEmpty()){ 
            orderPickCustomInterList.addAll(giic_TR_PurchaseOrder_ManageUpdate.populateCustomInterListFromPO(workOrderMapInstall.values(),  'Orders_Pickup_InStock',workOrderRejectReason) );
        }
        XC_UTIL_Glovia.insertAndLogError(orderPickCustomInterList);
    }
    
    public static void customInteractionDeliveryTracking(List<gii__SalesOrder__c> listNew, Map<Id,gii__SalesOrder__c> mapOld, Map<Id,gii__SalesOrder__c> mapNew){
        List<String> fieldList = new List<String>{'giic_DeliveryTracking__c'};
        List<gii__SalesOrder__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        System.debug('@@@@@ List Changed Delivery Tracking');
        System.debug(listChanged);
        if(listChanged.isEmpty()){
            return;
        }
        List<Id> woList = new List<Id>();
        map<Id,String> mapSOId = new  map<Id,String>();
        Map<Id,gii__SalesOrder__c> mapWoB2C  = new Map<Id,gii__SalesOrder__c>([SELECT Id, giic_WorkOrder__c, giic_WorkOrder__r.XC_Segment__c FROM gii__SalesOrder__c WHERE Id IN :listNew AND giic_WorkOrder__c!=null AND giic_WorkOrder__r.XC_Segment__c='B2C']);
        for(gii__SalesOrder__c so : mapWoB2C.values()){
            woList.add(so.giic_WorkOrder__c);
            mapSOId.put(so.giic_WorkOrder__c,so.Id);
        }
        map<Id,WorkOrder> workOrderMap = new  map<Id,WorkOrder>();
        map<Id,String> workOrderRejectReason = new  map<Id,String>();
        if(!woList.isEmpty()){
        	workOrderMap = giic_TR_PurchaseOrder_ManageUpdate.getWoMap(woList);
        }
        List<XC_Customer_Interaction__c> customInterList = giic_TR_PurchaseOrder_ManageUpdate.populateCustomInterListFromPO(workOrderMap.values(), 'Delivery Tracking Number',workOrderRejectReason);
        List<XC_Customer_Interaction__c> customInterToInsert = new List<XC_Customer_Interaction__c>();
        for (XC_Customer_Interaction__c ci : customInterList){
            ci.XC_AdditionalInfo2__c=(!String.isBlank(mapSOId.get(ci.XC_WorkOrderId__c))) ? mapSOId.get(ci.XC_WorkOrderId__c) : null;
            customInterToInsert.add(ci);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ New CI Delivery Tracking Number to create = ' + customInterToInsert);
         List<XC_UTIL_SObject.WrapperResult> insCIResults = XC_UTIL_DML.insertRecords(customInterToInsert);
 		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ CI Delivery Tracking Number results = ' + insCIResults);
    }
    
    
    public static List<SalesOrderWrapper> populateSalesOrderWrapper(map<Id,Id> salesOrderIdToWorkOrderId){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In populateSalesOrderWrapper con----->>' +salesOrderIdToWorkOrderId);
        
        List<SalesOrderWrapper> wrapperListToReturn = new  List<SalesOrderWrapper>();
        List<gii__SalesOrder__c> soList = [SELECT Id, giic_IsDelivery__c ,(SELECT id FROM Transfer_Orders__r), (SELECT Id FROM gii__Purchase_Orders__r) FROM gii__SalesOrder__c WHERE Id IN: salesOrderIdToWorkOrderId.keySet()];
        for(gii__SalesOrder__c so : soList){
            SalesOrderWrapper soWr = new SalesOrderWrapper();
            soWr.salesOrderId = so.Id;
            soWr.totalTransferOrder = (so.Transfer_Orders__r).size();
            soWr.totalPurchaseOrder = (so.gii__Purchase_Orders__r).size();
            soWr.salesOrder = so;
            soWr.workOrderId = salesOrderIdToWorkOrderId.get(so.Id);
            wrapperListToReturn.add(soWr);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'End populateSalesOrderWrapper con----->>' +wrapperListToReturn);
        return wrapperListToReturn;
    }
    

}