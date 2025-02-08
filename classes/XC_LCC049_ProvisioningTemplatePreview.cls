/**
 * The Class XC_LCC049_ProvisioningTemplatePreview.
 *
 * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com - Fabrizio Antonioli Fabrizio.antonioli@nttdata.com - Giovanni Schioppa giovanni.schioppa@nttdata.com
 * @description Controller for XC_LCP049_ProvisioningTemplatePreview Component
 */

public without sharing class XC_LCC049_ProvisioningTemplatePreview {

       
    /**
     * @description The Class ResultWrapper.
     */
    public class ResultWrapper{
        /** @description pickListValuesList */
        @AuraEnabled
        public List<String> pickListValuesList {get; set;} 
        /** @description baseURL */
        @AuraEnabled
        public String baseURL {get; set;} 
    }
    
    /**
     * @description Gets the pick list values.
     * @return the pick list values
     */
    @AuraEnabled        
    public static ResultWrapper getPickListValues(){  
        Set<String> pickListValues = new Set<String>();     
        List<XC_CM_Provisioning_Template_Config__mdt> listTemplate = [
            SELECT Id, XC_CM_Step_Name__c, XC_CM_Template_Name__c 
            FROM XC_CM_Provisioning_Template_Config__mdt
            ORDER BY XC_CM_Template_Name__c];
        for(XC_CM_Provisioning_Template_Config__mdt tmp : listTemplate){ 
            pickListValues.add(tmp.XC_CM_Template_Name__c);
        }
        ResultWrapper result = new ResultWrapper();
        result.pickListValuesList = new List<String>(pickListValues);
		result.baseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
        return result;
    }
 
    

}