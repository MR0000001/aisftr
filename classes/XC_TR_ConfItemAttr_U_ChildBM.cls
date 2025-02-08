/**
* @author dpalamides
* @date 21/10/2020
* @description: classes.XC_TR_ConfItemAttr_U_ChildBM
*/


public without sharing class XC_TR_ConfItemAttr_U_ChildBM {
/**
     * @author dpalamides
     * @description Method starting in after insert
     * @param listNew the list of inserted Configuration Item Attribute
     */
    public static void onAfterInsert(List<NE__Order_Item_Attribute__c> listNew)
    {
        List<NE__OrderItem__c> childOrderItems = new List<NE__OrderItem__c>();
        childOrderItems.addAll([select id,NE__Root_Order_Item__c, XC_Segment__c, (select id, name,NE__FamPropExtId__c,NE__Value__c from NE__Order_Item_Attributes__r where name in ('Billing Model', 'Payment Method', 'Método de pago')  or NE__FamPropExtId__c = 'Billing Model:Payment Method') from NE__OrderItem__c where NE__Root_Order_Item__c in :XC_UTIL_Sobject.getListFieldValues(listNew,'NE__Order_Item__c')]);

        List<NE__Order_Item_Attribute__c> toInsert = new List<NE__Order_Item_Attribute__c>();
        for(NE__OrderItem__c oi : childOrderItems){
            for(NE__Order_Item_Attribute__c attr : listNew){
                if(oi.NE__Root_Order_Item__c == attr.NE__Order_Item__c && (attr.Name== 'Billing Model' || attr.Name== 'Payment Method' || attr.Name== 'Método de pago' || attr.NE__FamPropExtId__c == 'Billing Model:Payment Method') && (oi.XC_Segment__c == 'B2B' || oi.XC_Segment__c == 'B2G') && (oi.NE__Order_Item_Attributes__r == null || oi.NE__Order_Item_Attributes__r.isEmpty())){
                    NE__Order_Item_Attribute__c newAttr = attr.clone(false,false,false,false);
                    newAttr.NE__Order_Item__c = oi.Id;
                    toInsert.add(newAttr);
                }
            }
        }

        List<XC_UTIL_Sobject.WrapperResult> res = XC_UTIL_Sobject.insertListRecords(toInsert);
        System.debug(JSON.serialize(res));

    }
}