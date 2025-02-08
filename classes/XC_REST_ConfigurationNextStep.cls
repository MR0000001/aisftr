/*****************************************************************************************************
* @author Riccardo Cossu - riccardo.cossu@nttdata.com - Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 10/10/2018
* @date Modification 15/10/2018
* @description  XC_REST_ConfigurationNextStep 
* Auth Insomnia : 
* URL : https://enelx-global-xcustomer--dev1.my.salesforce.com/services/apexrest/v1/NE__Order__c/
*****************************************************************************************************/

/** @description The Class XC_REST_ConfigurationNextStep */
@RestResource(urlMapping='/v1/NE__Order__c/*') 
global with sharing class XC_REST_ConfigurationNextStep {
    
    /** @description Do get */
    @HttpGet 
    global static void doGet() { 
        RestRequest request = RestContext.request; 
        String neorderid = request.requestURI.substring( request.requestURI.lastIndexOf('/')+1); 
        
    }   
  
    /***********************************************************************************************************
     *@author Riccardo Cossu - riccardo.cossu@nttdata.com - Salvatore Scarpato - salvatore.scarpato@nttdata.com
     *@description method for retriving data from external system and modify status of the Order Object
     *@modification 15_10_2018
     ************************************************************************************************************/

    /**
     * @description Do post
     * @param idsfdc the idsfdc
     * @param statusaction the statusaction
     * @return the string
     */
    @HttpPost 
    global static String doPost(String idsfdc, String statusaction ) {
        List<XC_UTIL_Sobject.WrapperResult> wrapperList = new List<XC_UTIL_Sobject.WrapperResult>(); 
		System.debug(LoggingLevel.DEBUG,'---> idsfdc --->'+idsfdc);
		System.debug(LoggingLevel.DEBUG,'---> statusaction --->'+statusaction);
        wrapperList = XC_UTIL_Configuration_U.getConfigurationNextStep(idsfdc,statusaction);
        return JSON.serialize(wrapperList);
        
    }
    
}