/**
 * The Class XC_TR_Configuration_U_FillAddress.
 *
 * @author  Daniele Lico
 * @date    30/06/2020
 * @description The class populates the address lookup on the configuration item when is created blank
 */

public with sharing class XC_TR_ConfiItem_U_FillAddress {

    /**
     * @description Populate address from opportunity.
     * @param listNew the list new
     */

    public static void populateAddressFromConf(List<NE__OrderItem__c> listNew){

        List<NE__OrderItem__c> oiList = new List<NE__OrderItem__c>();
        List<String> listConfId = XC_UTIL_Sobject.getListFieldValues(listNew, 'NE__OrderId__c');
    
        Map<Id,NE__Order__c> orderMap = new Map<Id, NE__Order__c> ([
                SELECT Id, XC_InstallationAddress__c, XC_LegalEntity__c, XC_Segment__c
                FROM NE__Order__c 
                WHERE Id IN: listConfId
            ]);
    
    
        for(NE__OrderItem__c configurationItem : listNew) {
            if(orderMap.containsKey(configurationItem.NE__OrderId__c)){
                NE__Order__c conf = orderMap.get(configurationItem.NE__OrderId__c);
                if(String.isBlank(configurationItem.XC_Installation_Address__c)){
                    configurationItem.XC_Installation_Address__c = conf.XC_InstallationAddress__c;
                }
            }
        }
    
    }

}