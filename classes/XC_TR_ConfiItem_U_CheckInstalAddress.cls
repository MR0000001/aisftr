public with sharing class XC_TR_ConfiItem_U_CheckInstalAddress {


    public static void onUpdate(Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew){
        List<String> fieldList = new List<String>{'XC_Installation_Address__c'};  
        List<NE__OrderItem__c> confItemListChanged = (List<NE__OrderItem__c>)XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        Map<Id,NE__OrderItem__c> configurationItemToCheck = new Map<Id,NE__OrderItem__c>();
        for(NE__OrderItem__c oi : confItemListChanged){
            if(oi.XC_Segment__c != 'B2C'){
                configurationItemToCheck.put(oi.id, oi);
            }
        }
        if(!configurationItemToCheck.isEmpty()){
            checkBillingProfileAd(new Map<Id,NE__OrderItem__c>(confItemListChanged));
        }

    }
	
	

	 public static void checkBillingProfileAd(Map<Id, NE__OrderItem__c> listConfigurationItem){
        		
		map<Id,NE__OrderItem__c> oiMap= new map<Id,NE__OrderItem__c> ([select id, XC_BillingProfileLineItem__c,  XC_BillingProfileLineItem__r.XC_SoldToAddress__r.XC_AddressCountry__c ,XC_Installation_Address__r.XC_AddressCountry__c, XC_Segment__c, NE__OrderId__r.NE__Type__c from NE__OrderItem__c where ID IN :listConfigurationItem.keySet()]);
		
		for (NE__OrderItem__c oi : OiMap.values()){
            if(oi.XC_BillingProfileLineItem__c == null){
                listConfigurationItem.get(oi.id).addError(Label.XC_CL_ConfigurationItem_InstallationAddressCheck);
            }else if(oi.XC_BillingProfileLineItem__r.XC_SoldToAddress__r.XC_AddressCountry__c != oi.XC_Installation_Address__r.XC_AddressCountry__c ){
				listConfigurationItem.get(oi.id).addError(Label.XC_CL_ConfigurationItem_InstallationAddressCheckBilling);
			}				
		}																							
																									
	 }

}