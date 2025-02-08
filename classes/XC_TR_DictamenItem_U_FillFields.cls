/**
 * @File Name          : XC_TR_DictamenItem_U_FillFields.cls
 * @description        : Util to handle the filling of Dictamen Fields
 * @Author             : Roberta Cossiga - rcossiga@deloitte.it && Marco Rosa - marco.rosa@nttdata.com && Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @Group              : 
 * @Last Modified By   : Roberta Cossiga - rcossiga@deloitte.it && Marco Rosa - marco.rosa@nttdata.com && Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @Last Modified On   : 06/11/2019, 11:37:20
**/

public without sharing class XC_TR_DictamenItem_U_FillFields {

    /**
    * @description populateDictamenFields
    * @author Roberta Cossiga - rcossiga@deloitte.it && Marco Rosa - marco.rosa@nttdata.com && Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @param listNew 
    **/
    public static void populateDictamenFields(List<XC_DictamenItem__c> listNew){
        for(XC_DictamenItem__c dic : listNew){
            if(checkInstallationSealed(dic)){
                dic.XC_Precintar__c = 'Sealed';
            }else{
                dic.XC_Precintar__c = 'Not Sealed';
               dic.XC_AnomalyResolvedIn__c = setTimeOfResolution(dic);
            }
        }
    }

    /**
    * @description checkInstallationSealed
    * @author Roberta Cossiga - rcossiga@deloitte.it && Marco Rosa - marco.rosa@nttdata.com && Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @param dic
    * @return Boolean 
    **/
    private static Boolean checkInstallationSealed(XC_DictamenItem__c dic){
        if((!String.isEmpty(dic.XC_MainEquipmentAnomaly__c) && dic.XC_MainEquipmentAnomaly__c.contains(Label.XC_CL_Precintar)) ||
           (!String.isEmpty(dic.XC_MainInstallationAnomaly__c) && dic.XC_MainInstallationAnomaly__c.contains(Label.XC_CL_Precintar)) || 
           (!String.isEmpty(dic.XC_SecondaryEquipmentAnomaly__c) && dic.XC_SecondaryEquipmentAnomaly__c.contains(Label.XC_CL_Precintar)) ||
           (!String.isEmpty(dic.XC_SecondaryInstallationAnomaly__c) && dic.XC_SecondaryInstallationAnomaly__c.contains(Label.XC_CL_Precintar))){
            return true;
        }
        return false;
    }

    /**
    * @description setTimeOfResolution
    * @author Roberta Cossiga - rcossiga@deloitte.it && Marco Rosa - marco.rosa@nttdata.com && Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @param dic
    * @return Boolean 
    **/
    private static String setTimeOfResolution(XC_DictamenItem__c dic){
        String anomalyResolvedIn = '';
        if((!String.isEmpty(dic.XC_MainEquipmentAnomaly__c) && dic.XC_MainEquipmentAnomaly__c.contains(Label.XC_CL_DaysToResolveAnomaly)) || 
            (!String.isEmpty(dic.XC_MainInstallationAnomaly__c) &&dic.XC_MainInstallationAnomaly__c.contains(Label.XC_CL_DaysToResolveAnomaly)) ||
            (!String.isEmpty(dic.XC_SecondaryEquipmentAnomaly__c) && dic.XC_SecondaryEquipmentAnomaly__c.contains(Label.XC_CL_DaysToResolveAnomaly)) || 
            (!String.isEmpty(dic.XC_SecondaryInstallationAnomaly__c) && dic.XC_SecondaryInstallationAnomaly__c.contains(Label.XC_CL_DaysToResolveAnomaly))){
            anomalyResolvedIn = '15 days';
        }else{
            anomalyResolvedIn = '6 months';
        }
        return anomalyResolvedIn;
    }

}