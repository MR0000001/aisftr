/**
 * @description       : 
 * @author            : benjamin.geronimo
 * @group             : WebResults
 * @last modified on  : 28-05-2021
 * @last modified by  : benjamin.geronimo
 * Modifications Log 
 * Ver   Date         Author              Modification
 * 1.0   17-05-2021   benjamin.geronimo   Initial Version
**/

public with sharing class TA_LCC254_DynamicHomepage {
    /**
    * @description 
    * @author benjamin.geronimo | 17-05-2021 
    * @param language 
    * @param customLabels 
    * @return List<TA_CustomLabel__mdt> 
    **/
    @AuraEnabled
    public static List<TA_CustomLabel__mdt> getCustomLabels(List<String> customLabels) {
        List<TA_CustomLabel__mdt> listCustomLabel = new List<TA_CustomLabel__mdt>();
        System.debug('>_> customLabels : ' + customLabels);
        try {
            String language = UserInfo.getLanguage() != null ? UserInfo.getLanguage().substring(0, 2) : 'it';
            System.debug('>_> language : ' + language);
            List<TA_CustomLabel__mdt> listAllCustomLabel = [SELECT Id,
                                                                TA_Label__c,
                                                                MasterLabel,
                                                                TA_Language__c
                                                            FROM TA_CustomLabel__mdt
                                                            WHERE (TA_Language__c = :language OR TA_Language__c = 'en_US')
                                                                AND MasterLabel IN :customLabels];

            Map<String, TA_CustomLabel__mdt> mapCustomLabelFiltered = new Map<String, TA_CustomLabel__mdt>();
            for(TA_CustomLabel__mdt customLabel : listAllCustomLabel) {
                if(customLabel.TA_Language__c == language ||
                (customLabel.TA_Language__c == 'en_US' && !mapCustomLabelFiltered.containsKey(customLabel.MasterLabel))) {
                    mapCustomLabelFiltered.put(customLabel.MasterLabel, customLabel);
                }
            }
            listCustomLabel.addAll(mapCustomLabelFiltered.values());
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC254_DynamicHomepage] getCustomLabels - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC254_DynamicHomepage', 'getCustomLabels', errorMessage, 0, errorMessage, null);
        }
        return listCustomLabel;
    }

    /**
    * @description 
    * @author benjamin.geronimo | 28-05-2021 
    * @param objName 
    * @param listViewName 
    * @return String 
    **/
    // @AuraEnabled
    // public static String getListView(String objName, String listViewName){
    //     System.debug('>_> Inside TA_LCC205_Homepage.getListView');
    //     String listViewId = '';
 
    //     List<ListView> listViews = [
    //             SELECT Id, Name, DeveloperName 
    //             FROM ListView 
    //             WHERE SobjectType = :objName
    //             AND Name = :listViewName];

    //     system.debug('>_> query result : ' + listViews);

    //     if( !listViews.isEmpty() ) listViewId = listViews[0].Id;

    //     return listViewId;
    // }
}