/**
* @author Marco Rosa - marco.rosa@nttdata.com 
* @date Creation 20/11/2018
* @date Modification dd/mm/yyyy
* @description XC_UTIL_ProvisioningTemplateConfig – Util class for Provisioning Template Config methods
*/ 

public without sharing class XC_UTIL_ProvisioningTemplateConfig {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_ProvisioningTemplateConfig');

    /**
     *@author : Marco Rosa - marco.rosa@nttdata.com , Salvatore Scarpato - salvatore.scarpato@nttdata.com, Fabrizio Antonioli - fabrizio.antonioli@nttdata.com
     *@param mapConfItemTemplateName the map of conf item and template name 
     *@description   This method takes in input a Map<Configuration Item Id, String Template Name> and returns 
                     a Map<Configuration Item Id, List of Custom Metadata records>. The Custom Metadata records are 
                     retrieved with the logic that its name is equal to the String Template Name took in input.
     *@return mapConfItemIdListSteps 
    **/
    public static Map<Id, List<XC_CM_Provisioning_Template_Config__mdt>> getTemplateSteps(Map<Id, String> mapConfItemTemplateName){
        Map<Id,List<XC_CM_Provisioning_Template_Config__mdt>> mapConfItemIdListSteps =  new Map<Id,List<XC_CM_Provisioning_Template_Config__mdt>>();
        Map<String,List<XC_CM_Provisioning_Template_Config__mdt>> mapTemplateNameListSteps =  new Map<String,List<XC_CM_Provisioning_Template_Config__mdt>>();
        List<XC_CM_Provisioning_Template_Config__mdt> provisioningTemplateConfList = getProvisioningTemplateConfList(mapConfItemTemplateName.values()); 

        if(!provisioningTemplateConfList.isEmpty()){
            for(XC_CM_Provisioning_Template_Config__mdt ptc : provisioningTemplateConfList){
                if(!mapTemplateNameListSteps.containsKey(ptc.XC_CM_Template_Name__c)){
                    mapTemplateNameListSteps.put(ptc.XC_CM_Template_Name__c, new List<XC_CM_Provisioning_Template_Config__mdt>());
                } 
                List<XC_CM_Provisioning_Template_Config__mdt> listSteps = mapTemplateNameListSteps.get(ptc.XC_CM_Template_Name__c);
                listSteps.add(ptc);
            }
            System.debug('@@@ mapTemplateNameListSteps -> ' + mapTemplateNameListSteps);
            if(!mapConfItemTemplateName.isEmpty()){
                for(Id confItemId : mapConfItemTemplateName.keySet()){
                    String templateName = mapConfItemTemplateName.get(confItemId);
                    System.debug('@@@ templateName-> ' + templateName);
                    System.debug('@@@ mapTemplateNameListSteps -> ' + mapTemplateNameListSteps);
                    List<XC_CM_Provisioning_Template_Config__mdt> listSteps = mapTemplateNameListSteps.get(templateName);
                    mapConfItemIdListSteps.put(confItemId, listSteps);
                } 
            }
        }
        return mapConfItemIdListSteps;
    }

    /**
     *@author : Salvatore Scarpato - salvatore.scarpato@nttdata.com
     *@description : This method retrieves the provisioning Template Config custom metadata records based on the name ot the template
                     in Input.
     *@param mapConfItemTemplateValues
     *@return provisioningTemplateConfList
    **/

    public static List<XC_CM_Provisioning_Template_Config__mdt> getProvisioningTemplateConfList (List<String> mapConfItemTemplateValues) {
        
        Map<Id,XC_CM_Provisioning_Template_Config__mdt> provisioningTemplateConfMap = new Map<Id,XC_CM_Provisioning_Template_Config__mdt>([SELECT Id,XC_CM_Template_Name__c,XC_CM_Mandatory_Steps__c,XC_CM_Step_Code__c,XC_CM_Step_Name__c,XC_CM_Step_Order__c,
                                                                                XC_CM_Synchronous__c, XC_CM_Flow_to_execute__r.XC_CM_Flow_Developer_Name__c, XC_CM_PlatformEventName__c, XC_CM_OptionalForProvisioningCompletion__c
                                                                                FROM XC_CM_Provisioning_Template_Config__mdt
                                                                                WHERE XC_CM_Template_Name__c IN: mapConfItemTemplateValues]);
        List<XC_CM_Provisioning_Template_Config__mdt> provisioningTemplateConfList = provisioningTemplateConfMap.values();
        return provisioningTemplateConfList;                                                                       
    }
}