public with sharing class XC_TR_ProductRequired_U_WOLIPName {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ProductRequired_U_WOLIPName');
    public static void updateProdIdOnWoli(Map<Id,SObject> mapNew, String objType){
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'updateProdIdOnWoli' );
        Map<Id,ProductRequired> mapNewProductRequired;  
        Map<Id,XC_RequiredPosition__c> mapNewRequiredPosition;      
        Map<Id,String> woliMap = new Map<Id,String>(); 
        if(objType == 'ProductRequired'){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'ProductRequired1' );
            mapNewProductRequired = (Map<Id,ProductRequired>) mapNew;
            for (ProductRequired pr : mapNewProductRequired.values()) {
                if(pr.ParentRecordId!=null && XC_UTIL_Sobject.getObjectType(pr.ParentRecordId)=='WorkOrderLineItem'){
                    woliMap.put(pr.ParentRecordId, pr.XC_WBSElement__c);
                }
            }
        }else{
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'RequiredPosition1' );
            mapNewRequiredPosition = (Map<Id,XC_RequiredPosition__c>) mapNew;   
            for (XC_RequiredPosition__c rp : mapNewRequiredPosition.values()) {
                woliMap.put(rp.XC_WorkOrderLineItem__c, rp.XC_WBE__c);       
            }
        }

        
        List<WorkOrderLineItem> woliList = new List<WorkOrderLineItem>([SELECT ID, WorkOrderId, WorkOrder.XC_Configuration__c, XC_ProductName__c, status, XC_UpdatedByApp__c, XC_WoliType__c FROM WorkOrderLineItem where id in : woliMap.keyset()]);
        Set<id> confIds = new Set<id>();
        for (WorkOrderLineItem woli : woliList){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'woli.WorkOrder.XC_Configuration__c' );
            confIds.add(woli.WorkOrder.XC_Configuration__c);
        }

        Map<id, NE__OrderItem__c > orderItemMap = new Map<id, NE__OrderItem__c >([select id, NE__OrderId__c, XC_WBE__c, NE__ProdId__r.Name, NE__Root_Order_Item__c from NE__OrderItem__c where NE__Root_Order_Item__c =null and NE__OrderId__c IN :confIds]);
        Map<String, NE__OrderItem__c> wbeMap = new Map<String, NE__OrderItem__c>();
        for (NE__OrderItem__c orderItem : orderItemMap.values()){
             //check if wbe is populated
            if(orderItem.XC_WBE__c!=null)             
                wbeMap.put(orderItem.XC_WBE__c, orderItem);
        }

        List<WorkOrderLineItem> woliToUpdateList = new List<WorkOrderLineItem>();
        if(objType == 'ProductRequired'){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'ProductRequired2');
            for (ProductRequired pr : mapNewProductRequired.values()) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'ProductRequired3');
                if(pr.ParentRecordId!=null && XC_UTIL_Sobject.getObjectType(pr.ParentRecordId)=='WorkOrderLineItem' &&  wbeMap.containsKey(pr.XC_WBSElement__c)){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'ProductRequired4' + woliList);
                    for(WorkOrderLineItem woli : woliList){
                        if (woli.id == pr.ParentRecordId){
                            woli.XC_ProductName__c = wbeMap.get(pr.XC_WBSElement__c).NE__ProdId__r.Name;
                            woliToUpdateList.add(woli);
                        }
                    }
                }
            }
        }else{
            for (XC_RequiredPosition__c rp : mapNewRequiredPosition.values()) {
                if(wbeMap.containsKey(rp.XC_WBE__c)){
                    for(WorkOrderLineItem woli : woliList){
                        if (woli.id == rp.XC_WorkOrderLineItem__c){
                            woli.XC_ProductName__c = wbeMap.get(rp.XC_WBE__c).NE__ProdId__r.Name;
                            woliToUpdateList.add(woli);
                        }
                    }
                }
            }
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'woli.WorkOrder.XC_Configuration__c' + woliToUpdateList);
        if(!woliToUpdateList.isEmpty()){
            XC_UTIL_Sobject.updateListRecords( woliToUpdateList);
        }        
    }
}