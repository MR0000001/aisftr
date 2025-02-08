/**
 * Created by dolombardi on 05/07/2021.
 */

public with sharing class XC_TR_ConfigurationItem_U_ChangeOrder {
    public static void updateChildByParent(Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew) {
        Map<Id, NE__OrderItem__c> mapOrderItemB2B = new Map<Id, NE__OrderItem__c>();
        for (NE__OrderItem__c ne : mapNew.values()) {
            if (ne.XC_Segment__c != 'B2C' && ne.NE__Action__c == 'Add' && !String.isEmpty(ne.NE__Parent_Order_Item__c)) {
                mapOrderItemB2B.put(ne.id, ne);
            }
        }
        if (mapOrderItemB2B.isEmpty()) {
            return;
        }
        Map<Id, NE__OrderItem__c> mapOrderItemNullValue = new Map<Id, NE__OrderItem__c>();
        mapOrderItemNullValue = iterateOrderItem(mapOrderItemB2B);
        if (mapOrderItemNullValue.isEmpty()) {
            return;
        }
        Map<Id, NE__OrderItem__c> mapItemParent = new Map<Id, NE__OrderItem__c>();
        mapItemParent = retrieveParentInformation(mapOrderItemNullValue);
        if (mapItemParent.isEmpty()) {
            return;
        }
        for (NE__OrderItem__c ne : mapNew.values()) {
            if (mapItemParent.get(ne.NE__Parent_Order_Item__c) != null){
                ne.XC_Wbe__c = mapItemParent.get(ne.NE__Parent_Order_Item__c).XC_Wbe__c;
                ne.XC_WBE_Status__c = mapItemParent.get(ne.NE__Parent_Order_Item__c).XC_WBE_Status__c;
            	ne.XC_BlockWBE_User__c = true;
                ne.XC_CMCostCenter__c = mapItemParent.get(ne.NE__Parent_Order_Item__c).XC_CMCostCenter__c;
                ne.XC_CMProfitCenter__c = mapItemParent.get(ne.NE__Parent_Order_Item__c).XC_CMProfitCenter__c;
                ne.XC_CMProfitCenter__c = mapItemParent.get(ne.NE__Parent_Order_Item__c).XC_CMProfitCenter__c;
                ne.XC_BillingProfileLineItem__c = mapItemParent.get(ne.NE__Parent_Order_Item__c).XC_BillingProfileLineItem__c;
                ne.XC_BillingModel__c = mapItemParent.get(ne.NE__Parent_Order_Item__c).XC_BillingModel__c;
                ne.XC_PaymentMethod__c = mapItemParent.get(ne.NE__Parent_Order_Item__c).XC_PaymentMethod__c;
			}
		}
    }




    private static Boolean checkValue(String value){
       Boolean check = false;
        if(String.isBlank(value)){
            return true;
        }
        return false;
    }

    private static Map<Id,NE__OrderItem__c> iterateOrderItem(Map<Id,NE__OrderItem__c> mapOrderItemB2B){
        Map<Id,NE__OrderItem__c> mapOrderItemNullValue = new Map<Id,NE__OrderItem__c>();
        for(NE__OrderItem__c ne : mapOrderItemB2B.values()){
            if(checkValue(ne.XC_Wbe__c) || checkValue(ne.XC_WBE_Status__c) || checkValue(ne.XC_CMCostCenter__c) || checkValue(ne.XC_CMProfitCenter__c) || checkValue(ne.XC_BillingProfileLineItem__c) || checkValue(ne.XC_BillingModel__c) || checkValue(ne.XC_PaymentMethod__c)){
                mapOrderItemNullValue.put(ne.id,ne);
            }
        }
        return mapOrderItemNullValue;
    }
    private static Map<Id,NE__OrderItem__c> retrieveParentInformation(Map<Id,NE__OrderItem__c> mapOrderItemNullValue){
        Set<Id> setParentId = new Set<Id>();
        for(NE__OrderItem__c ne : mapOrderItemNullValue.values()){
            if(ne.NE__Parent_Order_Item__c != null){
                setParentId.add(ne.NE__Parent_Order_Item__c);
            }
        }
        Map<Id,NE__OrderItem__c> mapItemParent = new Map<Id, NE__OrderItem__c>([select id, NE__Action__c, XC_Wbe__c, XC_WBE_Status__c, XC_CMCostCenter__c, XC_CMProfitCenter__c,  XC_BillingProfileLineItem__c, XC_PaymentMethod__c, XC_BillingModel__c, NE__Parent_Order_Item__c  From NE__OrderItem__c where id in :setParentId AND NE__OrderId__r.NE__Type__c = 'ChangeOrder']);
        return mapItemParent;
    }

}