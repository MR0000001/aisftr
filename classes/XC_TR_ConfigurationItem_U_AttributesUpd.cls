/**
 * @author Monica Cutillo - mcutillo@deloitte.it
 * @date Creation 10/07/2020
 * @description ConfigurationItem TR Util to manage update on ConfigurationItemAttributes
 **/
public without sharing  class XC_TR_ConfigurationItem_U_AttributesUpd {

    /**
     * @description Manage case status on update
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void checkForCostValueUpdate(List<NE__OrderItem__c> confItemUpdate, Map<Id,NE__OrderItem__c> mapOld, Map<Id,NE__OrderItem__c> mapNew){
        List<String> fieldList = new List<String>{'NE__One_Time_Cost__c'};
        List<NE__OrderItem__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        Set<Id> idsCItem = XC_UTIL_Sobject.getSetIds(listChanged);
        Map<Id, NE__Order_Item_Attribute__c> attributes = new Map<Id, NE__Order_Item_Attribute__c>([
            SELECT Id, XC_DeveloperName__c, NE__Order_Item__c
            FROM NE__Order_Item_Attribute__c
            WHERE XC_DeveloperName__c = 'Cost'
              AND NE__Order_Item__c IN: idsCItem
        ]);

        for(NE__Order_Item_Attribute__c attr : attributes.values()){
            if(mapNew.get(attr.NE__Order_Item__c).NE__One_Time_Cost__c != null){
                attr.NE__Value__c = String.valueOf(mapNew.get(attr.NE__Order_Item__c).NE__One_Time_Cost__c);
            }
        }
        List<XC_UTIL_Sobject.WrapperResult> dmlRes = XC_UTIL_DML.updateRecords(attributes.values());
    }
    
     /**
     * @description updates commercial item NE__One_Time_Cost__c when the cost is updated on a child technical field
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void updateOneTimeCostOncommercialItem(Map<Id,NE__OrderItem__c> mapOld, Map<Id,NE__OrderItem__c> mapNew){
        List<String> fieldList = new List<String>{'NE__One_Time_Cost__c','NE__Qty__c'};
        List<NE__OrderItem__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        List<Id> idsCItem = (List<Id>) XC_UTIL_Sobject.getListFieldValues(listChanged,'XC_ParentCommercialItem__c'); //XC_UTIL_Sobject.getSetIds(listChanged);
        Map<Id, NE__OrderItem__c> commercialItem = new Map<Id, NE__OrderItem__c>([
                SELECT Id, NE__One_Time_Cost__c
                FROM NE__OrderItem__c
                WHERE id IN: idsCItem
        ]);
        String techItemRT = Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('Technical_Item').getRecordTypeId();
        for(NE__OrderItem__c oiTech : mapNew.values()){
            if(commercialItem.get(oiTech.XC_ParentCommercialItem__c)!= null && oiTech.NE__One_Time_Cost__c != null && oiTech.RecordTypeId == techItemRT){
                NE__OrderItem__c oldItem = mapOld.get(oiTech.Id);
                NE__OrderItem__c oiComm = commercialItem.get(oiTech.XC_ParentCommercialItem__c);
                Decimal basePrice = oiComm.NE__One_Time_Cost__c != null ? oiComm.NE__One_Time_Cost__c : 0;
                basePrice = oldItem.NE__One_Time_Cost__c != null ? basePrice - (oldItem.NE__Qty__c * oldItem.NE__One_Time_Cost__c) : basePrice;
                basePrice = basePrice < 0 ? 0 : basePrice;
                oiComm.NE__One_Time_Cost__c = basePrice + (oiTech.NE__Qty__c * oiTech.NE__One_Time_Cost__c);
            }
        }
        List<XC_UTIL_Sobject.WrapperResult> dmlRes = XC_UTIL_DML.updateRecords(commercialItem.values());
    }


    /**
    * @description updates commercial item NE__One_Time_Cost__c when the cost is updated on a child technical field
    * @param mapOld the map old
    * @param mapNew the map new
    */
    public static void updateOneTimePriceOnParent(Map<Id,NE__OrderItem__c> mapOld, Map<Id,NE__OrderItem__c> mapNew){
        List<String> fieldList = new List<String>{'NE__BaseRecurringCharge__c', 'NE__RecurringChargeOv__c', 'NE__BaseOneTimeFee__c', 'NE__OneTimeFeeOv__c','NE__Qty__c'};
        List<NE__OrderItem__c> listChanged = mapNew.values(); //XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        List<NE__OrderItem__c> toUpdate = new List<NE__OrderItem__c>();
        if(listChanged.isEmpty()){
            return;
        }
        List<Id> idsCItem = (List<Id>) XC_UTIL_Sobject.getListFieldValues(listChanged,'NE__Parent_Order_Item__c'); //XC_UTIL_Sobject.getSetIds(listChanged);
        Map<Id, NE__OrderItem__c> commercialItem = new Map<Id, NE__OrderItem__c>([
                SELECT Id, XC_BillingModel__c, NE__One_Time_Cost__c, NE__BaseRecurringCharge__c, NE__RecurringChargeOv__c, NE__BaseOneTimeFee__c, NE__OneTimeFeeOv__c,NE__Parent_Order_Item__c
                FROM NE__OrderItem__c
                WHERE id IN: idsCItem
        ]);

        for(NE__OrderItem__c oiTech : mapNew.values()){
            if(commercialItem.get(oiTech.NE__Parent_Order_Item__c)!= null){
                NE__OrderItem__c oldItem = mapOld.get(oiTech.Id);
                NE__OrderItem__c oiComm = mapNew.containsKey(oiTech.NE__Parent_Order_Item__c) ? mapNew.get(oiTech.NE__Parent_Order_Item__c) : commercialItem.get(oiTech.NE__Parent_Order_Item__c);

                Decimal baseRecurringCharge = oiComm.NE__BaseRecurringCharge__c != null ? oiComm.NE__BaseRecurringCharge__c : 0;
                Decimal recurringChargeOv   = oiComm.NE__RecurringChargeOv__c != null ? oiComm.NE__RecurringChargeOv__c : 0;
                Decimal baseOneTimeFee      = oiComm.NE__BaseOneTimeFee__c != null ? oiComm.NE__BaseOneTimeFee__c : 0;
                Decimal oneTimeFeeOv        = oiComm.NE__OneTimeFeeOv__c != null ? oiComm.NE__OneTimeFeeOv__c : 0;

                baseRecurringCharge = oldItem.NE__BaseRecurringCharge__c != null ? baseRecurringCharge - (oldItem.NE__Qty__c * oldItem.NE__BaseRecurringCharge__c) : baseRecurringCharge;
                baseRecurringCharge = baseRecurringCharge < 0 ? 0 : baseRecurringCharge;

                recurringChargeOv = oldItem.NE__RecurringChargeOv__c != null ? recurringChargeOv - (oldItem.NE__Qty__c * oldItem.NE__RecurringChargeOv__c) : recurringChargeOv;
                recurringChargeOv = recurringChargeOv < 0 ? 0 : recurringChargeOv;

                baseOneTimeFee = oldItem.NE__BaseOneTimeFee__c != null ? baseOneTimeFee - (oldItem.NE__Qty__c * oldItem.NE__BaseOneTimeFee__c) : baseOneTimeFee;
                baseOneTimeFee = baseOneTimeFee < 0 ? 0 : baseOneTimeFee;

                oneTimeFeeOv = oldItem.NE__OneTimeFeeOv__c != null ? oneTimeFeeOv - (oldItem.NE__Qty__c * oldItem.NE__OneTimeFeeOv__c) : oneTimeFeeOv;
                oneTimeFeeOv = oneTimeFeeOv < 0 ? 0 : oneTimeFeeOv;

                if(!mapNew.containsKey(oiComm.Id)) {
                    oiComm.NE__BaseRecurringCharge__c = baseRecurringCharge + (oiTech.NE__Qty__c * oiTech.NE__BaseRecurringCharge__c);
                    oiComm.NE__RecurringChargeOv__c = recurringChargeOv + (oiTech.NE__Qty__c * oiTech.NE__RecurringChargeOv__c);
                    oiComm.NE__BaseOneTimeFee__c = baseOneTimeFee + (oiTech.NE__Qty__c * oiTech.NE__BaseOneTimeFee__c);
                    oiComm.NE__OneTimeFeeOv__c = oneTimeFeeOv + (oiTech.NE__Qty__c * oiTech.NE__OneTimeFeeOv__c);
                    toUpdate.add(oiComm);
                }else {
                    mapNew.get(oiComm.Id).NE__BaseRecurringCharge__c = baseRecurringCharge + (oiTech.NE__Qty__c * oiTech.NE__BaseRecurringCharge__c);
                    mapNew.get(oiComm.Id).NE__RecurringChargeOv__c = recurringChargeOv + (oiTech.NE__Qty__c * oiTech.NE__RecurringChargeOv__c);
                    mapNew.get(oiComm.Id).NE__BaseOneTimeFee__c = baseOneTimeFee + (oiTech.NE__Qty__c * oiTech.NE__BaseOneTimeFee__c);
                    mapNew.get(oiComm.Id).NE__OneTimeFeeOv__c = oneTimeFeeOv + (oiTech.NE__Qty__c * oiTech.NE__OneTimeFeeOv__c);
                }
            }
        }
        List<XC_UTIL_Sobject.WrapperResult> dmlRes = XC_UTIL_DML.updateRecords(toUpdate);
    }

    /**
    * @description updates commercial item NE__One_Time_Cost__c when the cost is updated on a child technical field
    * @param mapOld the map old
    * @param mapNew the map new
    */
    public static void rollUpPriceOnParent(Map<Id,NE__OrderItem__c> mapOld, Map<Id,NE__OrderItem__c> mapNew){
        Map<Id,List<NE__OrderItem__c>> oibyRoot = new Map<Id,List<NE__OrderItem__c>>();
        for(NE__OrderItem__c oi : mapNew.values()){
            if(oi.NE__Root_Order_Item__c!=null){
                if(!oibyRoot.containsKey(oi.NE__Root_Order_Item__c)){
                    oibyRoot.put(oi.NE__Root_Order_Item__c,new List<NE__OrderItem__c>());
                }
                oibyRoot.get(oi.NE__Root_Order_Item__c).add(oi);
            }
        }

        for(Id rootId : oibyRoot.keySet()){
            NE__OrderItem__c root = mapNew.get(rootId);
            if(root==null){
                continue;
            }
            List<NE__OrderItem__c> children = oibyRoot.get(rootId);
            Boolean toRollUp =  root.NE__BaseRecurringCharge__c == 0 &&
                                root.NE__RecurringChargeOv__c == 0 &&
                                root.NE__BaseOneTimeFee__c == 0 &&
                                root.NE__OneTimeFeeOv__c == 0;
            if(toRollUp){
                for (NE__OrderItem__c child : children) {
                    root.NE__BaseRecurringCharge__c += child.NE__BaseRecurringCharge__c;
                    root.NE__RecurringChargeOv__c   += child.NE__RecurringChargeOv__c;
                    root.NE__BaseOneTimeFee__c      += child.NE__BaseOneTimeFee__c;
                    root.NE__OneTimeFeeOv__c        += child.NE__OneTimeFeeOv__c;
                }
            }
        }
    }

}