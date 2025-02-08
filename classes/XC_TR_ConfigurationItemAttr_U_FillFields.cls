/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 21/03/2019
* @description XC_TR_ConfigurationItemAttr_U_FillFields – Util class for XC_TR_ConfigurationItemAttribute
*/
public without sharing class XC_TR_ConfigurationItemAttr_U_FillFields {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ConfigurationItemAttr_U_FillFields');
    
    /**
     * @description Populate months renting
     * @param listNew the list new
     */
    public static void populateMonthsRenting(List<NE__Order_Item_Attribute__c> listNew){
        List<Id> configurationItemListId = XC_UTIL_Sobject.getListFieldValues(listNew, 'NE__Order_Item__c');
        
        Map<Id, NE__OrderItem__c> orderItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, NE__ProdName__c 
                                                    FROM NE__OrderItem__c 
                                                    WHERE Id IN:configurationItemListId AND NE__ProdName__c LIKE 'OK%']);
        Map<Id, Boolean> orderItemAttrMap = new Map<Id, Boolean>();
        for(NE__Order_Item_Attribute__c oia : listNew){
            orderItemAttrMap.put(oia.Id, false);
            if(!orderItemMap.isEmpty()){
                orderItemAttrMap.put(oia.Id, true);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@# Map' + orderItemAttrMap);                                            
        for(NE__Order_Item_Attribute__c oia : listNew){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '### Value --->' + oia.NE__Value__c + '### Developer Name --> ' + oia.XC_DeveloperName__c);
            if(orderItemAttrMap.containsKey(oia.Id)){
                if(!orderItemAttrMap.get(oia.Id)){ 
                    calculateMonths(oia);
                } else {
                    oia.XC_MonthsRenting__c = 12; // If the product is OK* type, the field is set to 12
                }
            } else{
                oia.XC_MonthsRenting__c = 1; 
            }
        }
    }

    /**
     * @description Calculate Months
     * @param oia - NE__Order_Item_Attribute__c
     */
    private static void calculateMonths(NE__Order_Item_Attribute__c oia) {
        if(oia.XC_DeveloperName__c == Label.XC_CL_ConfigurationItemAttribute_DevPaymentModel && !String.isBlank(oia.NE__Value__c)){
            if(oia.NE__Value__c.contains('3')){
                oia.XC_MonthsRenting__c = 36; // 3*12 : years*months
            } else if(oia.NE__Value__c.contains('5')){
                oia.XC_MonthsRenting__c = 60; // 5*12 : years*months
            } else if(oia.NE__Value__c.contains('7')){
                oia.XC_MonthsRenting__c = 84; // 7*12 : years*months 
            } 
        }
    }
}