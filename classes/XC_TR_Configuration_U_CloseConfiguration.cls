/**
 * The Class XC_TR_Configuration_U_CloseConfiguration.
 *
 * @author Giovanni Schioppa - giovanni.schioppa@nttdata.com / Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date Creation 29/01/2011
 * @date Modification dd/mm/yyyy
 * @description class to check if all configuration item children of a configuration are closed. If so, close the associated configuration.
 */
public with sharing class XC_TR_Configuration_U_CloseConfiguration {

    /**
     * @author Dario Tramontin dtramontin@deloitte.it
     * @date Creation 08/09/2019
     * @date Modification dd/mm/yyyy
     * @description Closed related case of O Disconnect
     * @param listNew list of case
     */
    public static void caseDisconnectClosure(List<NE__Order__c> listNew, Map<Id, NE__Order__c> mapOld, Map<Id, NE__Order__c> mapNew){
        System.debug('## caseDisconnectClosure ##');
        List<String> listId = new List<String>();
        
        listNew = XC_UTIL_SObject.getListChanged(new List<String>{'XC_Status__c'}, mapOld, mapNew);
        if(listNew.isEmpty()) {
            return;
        }

        Set<Id> caseToUpdate = new Set<Id>();
        for( NE__Order__c order : listNew){
            if( order.XC_Status__c.equals(Label.XC_CL_Configuration_Closed) && (order.NE__Type__c.equals(Label.XC_CL_Configuration_TypeDisconnection) || order.NE__Type__c.equals(Label.XC_CL_Configuration_TypeChangeOrder) ) && order.XC_CaseId__c != null ){
                caseToUpdate.add(order.XC_CaseId__c);
            }
        }
        if( !caseToUpdate.isEmpty() ){
            XC_UTIL_Case_U_Check.isParentCasePending(caseToUpdate);
        }
    }
    
    /** 
     * 
     * @description Close configuration.
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void closeConfiguration(List<NE__Order__c> listNew, Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew){
        List<String> fieldList = new List<String>{'XC_NumberOfConfigurationItemCompleted__c'};
        List<NE__Order__c> configurationToCheckList = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);  
        
        Id orderRT = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        List<Id> listOrderIds = XC_UTIL_SObject.getIds(listNew);
        
        for(NE__Order__c order : configurationToCheckList){
            Boolean isOrder = orderRT == order.RecordTypeId;

            if((order.XC_NumberOfConfigurationItem__c == order.XC_NumberOfConfigurationItemCompleted__c) && 
                isOrder &&
                order.XC_NumberOfConfigurationItem__c != 0
                && order.XC_Status__c == Label.XC_CL_Configuration_OrderInProvisioning
                ){
                order.XC_Status__c = Label.XC_CL_Configuration_OrderClosed;
            } 
        }
    }
}