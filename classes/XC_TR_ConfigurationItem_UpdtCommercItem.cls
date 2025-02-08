public with sharing class XC_TR_ConfigurationItem_UpdtCommercItem{

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ConfigurationItem_Handler');
    /**
     * @description update commercial Item cost
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void calculateCommercialItemCost(Map<Id, NE__OrderItem__c> mapOld) {

        List<NE__OrderItem__c> configItems = new List<NE__OrderItem__c>();
        Map<Id, NE__Order_Item_Attribute__c> parentConfigItem = new Map<Id, NE__Order_Item_Attribute__c>();
        Map<Id, NE__OrderItem__c> parentCommItem = new Map<Id, NE__OrderItem__c>();

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'calculateCommercialItemCost() - mapOld: ' + mapOld);
        if (Schema.sObjectType.NE__OrderItem__c.fields.XC_ParentCommercialItem__c.isAccessible() &&
                Schema.sObjectType.NE__OrderItem__c.fields.NE__One_Time_Cost__c.isAccessible() &&
                Schema.sObjectType.NE__OrderItem__c.fields.NE__Qty__c.isAccessible() ) {
            configItems = [SELECT id, recordtype.developername, NE__One_Time_Cost__c, XC_ParentCommercialItem__c, NE__Qty__c
                            FROM NE__OrderItem__c
                            WHERE XC_ParentCommercialItem__c != Null AND id IN: mapOld.keySet() AND Recordtype.Developername = 'Technical_Item'
                            AND NE__One_Time_Cost__c > 0 AND NE__Qty__c > 0];
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'calculateCommercialItemCost() - configItems: ' + configItems);

        if(configItems.isEmpty()) { return;}

        for (NE__OrderItem__c configItem: configItems){
            parentCommItem.put(configItem.XC_ParentCommercialItem__c, configItem);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'calculateCommercialItemCost() - parentCommItem: ' + parentCommItem);

        Map<Id,NE__Order_Item_Attribute__c> itemAttributes = new Map<Id,NE__Order_Item_Attribute__c>([SELECT Id, XC_DeveloperName__c, NE__Order_Item__c,NE__Old_Value__c, NE__Value__c
                                                        FROM NE__Order_Item_Attribute__c
                                                        WHERE NE__Order_Item__c =: parentCommItem.keySet() AND XC_DeveloperName__c = 'Cost']);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'calculateCommercialItemCost() - itemAttribute: ' + itemAttributes);
        for (NE__Order_Item_Attribute__c configItemAttr: itemAttributes.values()){
            parentConfigItem.put(configItemAttr.NE__Order_Item__c, configItemAttr);
        }

        List<NE__Order_Item_Attribute__c> updateAttributes = new List<NE__Order_Item_Attribute__c>();
        for (NE__OrderItem__c deletedConfigItem : configItems){
            NE__Order_Item_Attribute__c tempAttribute = parentConfigItem.get(deletedConfigItem.XC_ParentCommercialItem__c);
            if (tempAttribute != null && Decimal.valueOf(tempAttribute.NE__Value__c) > 0) {
                String tempValue = tempAttribute.NE__Value__c;
                //NE__OrderItem__c tempConfig = parentCommItem.get(tempAttribute.NE__Order_Item__c);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'calculateCommercialItemCost() - attribute.NE__Value__c before change: ' + tempAttribute);
                tempAttribute.NE__Value__c = String.valueOf(Decimal.valueOf(tempAttribute.NE__Value__c) - deletedConfigItem.NE__Qty__c * deletedConfigItem.NE__One_Time_Cost__c);
                tempAttribute.NE__Old_Value__c = tempValue;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'calculateCommercialItemCost() - attribute.NE__Value__c after change: ' + tempAttribute);
                updateAttributes.add(tempAttribute);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'calculateCommercialItemCost() - itemAttribute: ' + itemAttributes);
        XC_UTIL_Sobject.updateListRecords(updateAttributes);
    }
    
}