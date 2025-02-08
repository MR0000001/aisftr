/*************************************************************************************************************************************************
* @author            : Simone Trenta - strenta@deloitte.it
* @date Creation     : 17/12/2020
* @date Modification : dd/mm/yyyy
* @description       : XC_TR_Config_U_SetVocalOrder
*************************************************************************************************************************************************/

public without sharing class XC_TR_Config_U_SetVocalOrder {

    
    /**
     * @description SetVocalOrder
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void setVocalOrder(List<NE__Order__c> listNew, Map<Id, NE__Order__c> mapOld, Map<Id, NE__Order__c> mapNew){ 
        List<String> fieldList = new List<String> {'XC_CTICallRecording__c', 'NE__OrderStatus__c'};
        List<NE__Order__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        
        if(listChanged.isEmpty()){  
            return;
        }

        for(NE__Order__c o:listChanged){
            if(o.XC_CTICallRecording__c!=null){
                o.XC_SignedByExternal__c = 'VocalOrder';
            }
        }

        return;
    }

}