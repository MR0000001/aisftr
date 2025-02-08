/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com - Salvatore Scarpato - salvatore.scarpato@nttdata.com
*         Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 10/10/2018
* @date Modification dd/mm/yyyy
* @description XC_UTIL_Configuration_U – Class for XC_UTIL_Configuration
*/ 

public without sharing class XC_UTIL_Configuration_U { 
    
    /** @description Wrapper for loop Retrieve Field */
   
    private class RetrieveFieldWrapper {
        List<XC_UTIL_Sobject.WrapperResult> wrapperList = new List<XC_UTIL_Sobject.WrapperResult>();
        List<NE__Order__c> orderConfList = new List<NE__Order__c>();
        List <String> statusactionList = new List<String>();
        List<String> acceptedStatusList = new List<String>();
        String statusaction;
        Boolean checkOk;
    }

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Configuration_U');

    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description  Method to get the id from the Cart Configuration from the External Id in input.
    *               The External Id is the Practice Number for ApproveFinancial process and 
    *               is the Order Id for ApproveCompliance process.
    * @param processName - String
    * @param targetExternalId - String
    * @return Id 
    **/
    @TestVisible
    private static Id getConfigurationIdFromExternalId(String processName, String targetExternalId) {
        List<NE__Order__c> orderList;
        if(processName == 'XC_ESP_Config_APP001_ApproveFinancial'){
            if(!Schema.sObjectType.NE__Order__c.isAccessible()){
                return null;
            }
            orderList = [SELECT Id from NE__Order__c where XC_PracticeNumber__c =: targetExternalId];
        }
        else if(processName == 'XC_ESP_Config_APP002_ApproveCompliance'){
            if(!Schema.sObjectType.NE__Order__c.isAccessible()){
                return null;
            }
            orderList = [SELECT Id from NE__Order__c where Id =: targetExternalId];
        }
        
        if (!orderList.isEmpty()) {
            NE__Order__c order = orderList[0];
            return order.Id;
        }
        return null;
    }

    /**
    * @author Riccardo Cossu - riccardo.cossu@nttdata.com - Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description check if exist record in object NE__Order__c
    * @param idsfdc
    * @param statusaction
    * @return List<XC_UTIL_Sobject.WrapperResult>
    */
    public static List<XC_UTIL_Sobject.WrapperResult> getConfigurationNextStep(String idsfdc, String statusaction) {
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.DEBUG, '--- ID Salesforce --- :' + idsfdc);
        XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.DEBUG, '--- Status Action --- :' + statusaction);
        
        Boolean checkOk;
        List < String > statusactionList = new List < String > ();
        List<XC_UTIL_Sobject.WrapperResult> wrapperList = new List<XC_UTIL_Sobject.WrapperResult>(); 
        Id recTypeIdOrder = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.DEBUG, ' --- RecordType Id Order --- : ' + recTypeIdOrder);
        if(!Schema.sObjectType.NE__Order__c.isAccessible()){
            return wrapperList;
        }
        List < NE__Order__c > orderConfList = [SELECT Id, RecordType.DeveloperName, 
                                               XC_Status__c,
                                               NE__OptyId__c,
                                               NE__OrderStatus__c from NE__Order__c where RecordType.Id =: recTypeIdOrder and Id =: idsfdc];
        List<String> acceptedStatusList = new List<String>{Label.XC_CL_Configuration_OrderCancelled,Label.XC_CL_Configuration_OrderInProvisioning};
                    if (!orderConfList.isEmpty() && acceptedStatusList.contains(statusaction)) { 
                        //Loop for retrive the field 
                        RetrieveFieldWrapper wrapperRetrieve = new RetrieveFieldWrapper();
                        wrapperRetrieve.wrapperList = wrapperList;
                        wrapperRetrieve.orderConfList = orderConfList;
                        wrapperRetrieve.statusactionList = statusactionList;
                        wrapperRetrieve.statusaction = statusaction;
                        wrapperRetrieve.checkOk = checkOk;
                        wrapperRetrieve.acceptedStatusList = acceptedStatusList;
                        loopRetrieveField(wrapperRetrieve);
                        wrapperList = wrapperRetrieve.wrapperList;
                        orderConfList = wrapperRetrieve.orderConfList;
                        statusactionList = wrapperRetrieve.statusactionList;
                        statusaction = wrapperRetrieve.statusaction;
                        checkOk = wrapperRetrieve.checkOk;
                        acceptedStatusList = wrapperRetrieve.acceptedStatusList;
                    }else if(orderConfList.isEmpty()){
            XC_UTIL_Sobject.WrapperResult swr = new XC_UTIL_Sobject.WrapperResult();
            swr.recordId = idsfdc;
            swr.success = false;
            swr.errorMessage = Label.XC_CL_IdNoOrder;
            swr.errorfieldName = 'Id';
            wrapperList.add(swr); 
        }else{
            XC_UTIL_Sobject.WrapperResult swr = new XC_UTIL_Sobject.WrapperResult();
            swr.recordId = idsfdc;
            swr.success = false;
            swr.errorMessage = Label.XC_CL_StateForbbiden;
            swr.errorfieldName = 'XC_Status__c';
            wrapperList.add(swr);    
        }if(checkOk ==  true){
            wrapperList = XC_UTIL_Sobject.updateListRecords(orderConfList);
        }      
        return wrapperList;
    }


    /**
    * @description Loop for retrive the field 
    * @param wrapperRetrieve - RetrieveFieldWrapper
    */
    private static void loopRetrieveField(RetrieveFieldWrapper wrapperRetrieve) {
        for(NE__Order__c ne: wrapperRetrieve.orderConfList) {
            wrapperRetrieve.statusactionList.add(ne.Id);
            wrapperRetrieve.statusactionList.add(ne.XC_Status__c);
            XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.DEBUG, '--- status action  list ---> :' + wrapperRetrieve.statusactionList);
            XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.DEBUG, '---acceptedStatusList --->  :'+ wrapperRetrieve.acceptedStatusList);
            
            if (wrapperRetrieve.statusactionList.Contains('To be validated') || wrapperRetrieve.statusactionList.Contains('In Progress')) {        
                ne.XC_Status__c = wrapperRetrieve.statusaction;
                wrapperRetrieve.checkOk = true;
                //Call b2w method
                XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.DEBUG, '--- Value checkOk boolean --- ' + wrapperRetrieve.checkOk);
                XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.DEBUG, '--- Value XC Status ---' + ne.XC_Status__c);
            }else {
                XC_UTIL_Sobject.WrapperResult swr = new XC_UTIL_Sobject.WrapperResult();
                swr.recordId = ne.Id;
                swr.success = false;
                swr.errorMessage = Label.XC_CL_StateForbbiden;
                swr.errorfieldName = 'XC_Status__c';
                wrapperRetrieve.wrapperList.add(swr);
            }
        }
    }
}