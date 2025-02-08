/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 10/02/2020
* @date Modification dd/mm/yyyy
* @description  – XC_UTIL_Conga  - Util class for logic related to the Conga service. 
*/ 
public  without sharing class XC_UTIL_Conga {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Conga');

    /**
    * @author Salvatore Scarpato salvatore.scarpato@nttdata.com
    * @date Creation 10/02/2020
    * @description  – UtilWrapper
    */ 
    public class UtilWrapper {
        public NE__OrderItem__c orderItemToBeUpdated;
        public NE__OrderItem__c orderItemWithNoPaymentRequired;
        public WorkOrder workOrderToBeUpdated;
        public Asset trackedAsset;
        public NE__Billing_Profile__c billingProfileToUpdate;
        public Boolean checkOnRecordType = false;
        public Boolean checkSohoType = true;
        public Boolean forAragona = false;
        public Boolean customerRepresentative = false;
        public List<String> templateList = new List<String>();
        public String billingModel;
        public String categoryName;   
        public String catalogName;
        public String recordTypeFather = '';
        public String templateId;
        public String congaQuery;
        public String optyId;
        public String country;
        public String productServiceName;
        public String legalEntity;
        public String workType;
        public String state;
        public String fileName;
        public String individualId;
        public String contactId;
        public String equipmentName;
        public String bundleName;
        public String region;
        public String penaltyValue;
        public String photovoltaicId;
        public Boolean noPaymentMethodRequired;
        public Boolean isExternallySigned = true;
        public String productId;
    }

    private class MapAndListWrapper{
        List<String> allTemplates = new List<String>();
        List<String> allQueries = new List<String>();
    }

    private class WrapperCongaLists{
        List<String> congaQueriesRequiringOrderItemId = new List<String>(); 
        List<String> congaQueriesRequiringOppId = new List<String>();
        List<String> congaQueriesRequiringIndividualId = new List<String>();
        List<String> congaQueriesRequiringContactId = new List<String>();
        List<String> congaQueriesRequiringPhotovoltaicId = new List<String>();
        List<String> congaQueriesRequiringProductId = new List<String>();
    }

    /**
    * @author Salvatore Scarpato salvatore.scarpato@nttdata.com
    * @date Creation 10/02/2020
    * @date Modification dd/mm/yyyy
    * @param wrapperList List<UtilWrapper>
    * @param categoryType String
    * @description  – queryOnCongaTemplates  - method useful to retrieve the correct templates related
                                                to an order. Useful for CONTRACT_TO_SIGN and PRECONTRACTUAL_CONDITIONS
                                                documents. 
    */ 
    public static void queryOnCongaTemplates(List<UtilWrapper> wrapperList, String categoryType){
        System.debug('@@PEN wrapperList--->' + wrapperList);
        Map<String,String> templateNameId = new Map<String,String>();
        MapAndListWrapper wr = createUtilMap(wrapperList, categoryType);
        if(wr == null){
            return;
        }
        List<String> cmdtList = wr.allTemplates;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ All templates--> ' + cmdtList);
        List<APXTConga4__Conga_Template__c> templatesList = new List<APXTConga4__Conga_Template__c>([SELECT Id, Name, APXTConga4__Name__c, APXTConga4__Template_Group__c 
                                                                                                FROM APXTConga4__Conga_Template__c 
                                                                                                WHERE APXTConga4__Name__c IN: cmdtList]);
        if(templatesList.isEmpty()){
            return;
        }
        for(APXTConga4__Conga_Template__c template : templatesList){
            templateNameId.put(template.APXTConga4__Name__c, template.Id);
        }
        List<String> templatesStringList = new List<String>();
        for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){
            /*if(!mapCmd.isEmpty() && mapCmd.containsKey(wrapper.billingModel + wrapper.categoryName)){
                templatesStringList = mapCmd.get(wrapper.billingModel + wrapper.categoryName); 
            } else {
                continue;
            }*/
            if(wrapper.templateList != null){
                populateTemplateId(wrapper.templateList, wrapper,templateNameId);
            }
        }
        getCongaQuery(wr.allQueries, wrapperList);
        
    }

    /**
    * @description method to populate the templateId value.
    * @author salvatore.scarpato@nttdata.com | 10/2/2020 
    * @param templatesStringList List<String>
    * @param wrapper XC_UTIL_Conga.UtilWrapper
    * @param templateNameId Map<String,String> 
    **/
    private static void populateTemplateId(List<String> templatesStringList, XC_UTIL_Conga.UtilWrapper wrapper, Map<String,String> templateNameId){
        for(String template : templatesStringList){
            if(!String.isBlank(wrapper.templateId) && templateNameId.containsKey(template)){
                wrapper.templateId = wrapper.templateId + ',' + templateNameId.get(template);
            } else if(templateNameId.containsKey(template)){
                wrapper.templateId = templateNameId.get(template);
            }
        }
    }

    /**
    * @description get Conga Query - retrieve the conga query info related to the order-
                                    NOTE: It's necessary that the name of the conga query is equal to
                                    the name of conga template
    * @author salvatore.scarpato@nttdata.com | 10/2/2020 
    * @param  congaQueriesNames List<String>
    * @param  wrapperList List<XC_UTIL_Conga.UtilWrapper>
    **/
    private static void getCongaQuery(List<String> congaQueriesNames, List<XC_UTIL_Conga.UtilWrapper> wrapperList){
        Map<String,String> congaQueryToCleanId = new Map<String,String>();
        List<String> congaQueriesExactNameList = cleanCongaQueryName(congaQueriesNames);
        Map<Id, APXTConga4__Conga_Merge_Query__c> congaQueryMap = new Map<Id, APXTConga4__Conga_Merge_Query__c>([SELECT Id, APXTConga4__Name__c 
                                                                    FROM APXTConga4__Conga_Merge_Query__c 
                                                                    WHERE APXTConga4__Name__c IN: congaQueriesExactNameList]); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@congaQueryList ---> '+ congaQueryMap.values());
        if(congaQueryMap.isEmpty()){
            return;
        }
        for(APXTConga4__Conga_Merge_Query__c congaQuery : congaQueryMap.values()){
            for(String congaQueryNameWithUnderscore : congaQueriesNames){
                if(congaQueryNameWithUnderscore.contains(congaQuery.APXTConga4__Name__c)){
                    congaQueryToCleanId.put(congaQuery.Id, congaQueryNameWithUnderscore);
                }
            }
        }
        // If implementing the logic with query related to a record, add this string %3Fpv0%3D + recId   
        // where recId is the record considered as pv0 for the congaQuery.
        createAllCongaQuery(congaQueryToCleanId,congaQueryMap, wrapperList);
    }
    
    /**
    * @description 
    * @author salvatore.scarpato@nttdata.com | 14/3/2020 
    * @param congaQueriesNames List<String> 
    * @return congaQueriesExactNameList 
    **/
    private static List<String> cleanCongaQueryName(List<String> congaQueriesNames){
        List<String> congaQueriesExactNameList = new List<String>();
        for(String congaQuery : congaQueriesNames){
            if(congaQuery.contains('_')){
                congaQueriesExactNameList.add(congaQuery.substringBefore('_'));
            } else {
                congaQueriesExactNameList.add(congaQuery);
            }
        }
        return congaQueriesExactNameList;
    }

    /**
    * @description create a map that has as key the billing model+product service categoty of order item
                   and as value the list of templates required for this couple.
    * @author salvatore.scarpato@nttdata.com | 10/2/2020 
    * @param wrapperList List<XC_UTIL_Conga.UtilWrapper>
    * @param categoryType String
    * @return MapAndListWrapper
    **/
    private static MapAndListWrapper createUtilMap(List<XC_UTIL_Conga.UtilWrapper> wrapperList, String categoryType) {
        List<String> countryList = new List<String>();    
        List<String> allQueries = new List<String>();   
        for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){
            //productList.add(wrapper.categoryName);
            countryList.add(wrapper.country);
        }    
        MapAndListWrapper wr = new MapAndListWrapper();
        Map<String,List<String>> mapCmd = new Map<String,List<String>>();
        Map<String, String> mappa = new Map<String, String>();
        List<XC_CM_CongaTemplateAssociation__mdt> customMetadataList = new List<XC_CM_CongaTemplateAssociation__mdt>([SELECT Id, XC_TemplateList__c, XC_QueryList__c, 
                                                                            XC_ProductServiceCategory__c, XC_ProductServiceName__c, XC_BillingModel__c, 
                                                                            XC_LegalEntity__c, XC_Country__c, XC_Region__c, XC_WorkType__c, XC_ForAragona__c
                                                                            FROM XC_CM_CongaTemplateAssociation__mdt
                                                                            WHERE XC_Country__c IN : countryList
                                                                            AND XC_Category__c =: categoryType
                                                                            ORDER BY XC_ProductServiceName__c ASC]);
        if(customMetadataList.isEmpty()){
            return null;
        }
        
        for(XC_CM_CongaTemplateAssociation__mdt cta : customMetadataList){
            List<String> tempList = new List<String>();
            if(!String.isEmpty(cta.XC_QueryList__c)){
                if(cta.XC_QueryList__c.contains('/')){
                    tempList = cta.XC_QueryList__c.split('/'); 
                } else {
                    tempList.add(cta.XC_QueryList__c);
                }
                allQueries.addAll(tempList);
            }
        }
        XC_UTIL_Conga_U.manageScenarios(wrapperList, customMetadataList, categoryType);

        List<String> allTemplates = new List<String>();
        for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){
            if(wrapper.templateList != null){
                allTemplates.addAll(wrapper.templateList);
            }
        }
        wr.allTemplates = allTemplates;
        wr.allQueries = allQueries;
        return wr;
    }

    /**
    * @description method to create the conga query field that has to be passed to Conga in order to create the data sets.
    * @author salvatore.scarpato@nttdata.com | 13/3/2020 
    * @param congaQueryToCleanId Map<String,String> 
    * @param congaQueryMap Map<Id,APXTConga4__Conga_Merge_Query__c> 
    * @param wrapperList List<XC_UTIL_Conga.UtilWrapper> 
    **/
    public static void createAllCongaQuery(Map<String,String> congaQueryToCleanId,Map<Id, APXTConga4__Conga_Merge_Query__c> congaQueryMap,List<XC_UTIL_Conga.UtilWrapper> wrapperList){
        wrapperCongaLists congaLists = createCongaQueryLists(congaQueryToCleanId);
        List<String> congaQueriesRequiringOrderItemId = congaLists.congaQueriesRequiringOrderItemId;//new List<String>{'OrderItemInfo','OrderItemEqipInfo','OrderItemInfoGas', 'OrderItemInfoLuz','OrItemInfoWithId','OrderItemServInfo'};
        List<String> congaQueriesRequiringOppId = congaLists.congaQueriesRequiringOppId;//new List<String>{'OptyInfo'};
        List<String> congaQueriesRequiringIndividualId = congaLists.congaQueriesRequiringIndividualId;
        List<String> congaQueriesRequiringContactId = congaLists.congaQueriesRequiringContactId;
        List<String> congaQueriesRequiringPhotovoltaicId = congaLists.congaQueriesRequiringPhotovoltaicId;
        List<String> congaQueriesRequiringProductId = congaLists.congaQueriesRequiringProductId;
        for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){
            String congaQuery = '';
            for(String queryId : congaQueryMap.keySet()){
                String congaQueryName = congaQueryMap.get(queryId).APXTConga4__Name__c;
                if(congaQueriesRequiringOppId.contains(congaQueryName)){
                    congaQuery = congaQuery + '[' + congaQueryName+ ']'+queryId + '%3Fpv0%3D' +wrapper.optyId + ','  ;
                } else if(congaQueriesRequiringOrderItemId.contains(congaQueryName)) {
                    congaQuery = congaQuery + '[' + congaQueryName+ ']'+queryId + '%3Fpv0%3D' +wrapper.orderItemToBeUpdated.Id + ',' ;
                } else if(congaQueriesRequiringIndividualId.contains(congaQueryName)) {
                    congaQuery = congaQuery + '[' + congaQueryName+ ']'+queryId + '%3Fpv0%3D' +wrapper.individualId + ',' ;
                } else if(congaQueriesRequiringContactId.contains(congaQueryName)) {
                    congaQuery = congaQuery + '[' + congaQueryName+ ']'+queryId + '%3Fpv0%3D' +wrapper.contactId + ',' ;
                } else if(congaQueriesRequiringPhotovoltaicId.contains(congaQueryName)){
                    congaQuery = congaQuery + '[' + congaQueryName+ ']'+queryId + '%3Fpv0%3D' +wrapper.photovoltaicId + ',' ;
                } else if(congaQueriesRequiringProductId.contains(congaQueryName)){
                    congaQuery = congaQuery + '[' + congaQueryName+ ']'+queryId + '%3Fpv0%3D' +wrapper.productId + ',' ;
                }else {
                    congaQuery = congaQuery + '[' + congaQueryName+ ']'+queryId + ',' ;
                }
            }
            wrapper.congaQuery = congaQuery;
        }
    }

    /**
    * @description 
    * @author salvatore.scarpato@nttdata.com | 14/3/2020 
    * @param congaQueryToCleanId Map<String,String>
    * @return wrapperLists 
    **/
    private static wrapperCongaLists createCongaQueryLists(Map<String,String> congaQueryToCleanId){
        WrapperCongaLists wrapperLists = new WrapperCongaLists();
        List<String> congaQueriesRequiringOrderItemId = new List<String>();
        List<String> congaQueriesRequiringOppId = new List<String>();
        List<String> congaQueriesRequiringIndividualId = new List<String>();
        List<String> congaQueriesRequiringContactId = new List<String>();
        List<String> congaQueriesRequiringPhotovoltaicId = new List<String>();
        List<String> congaQueriesRequiringProductId = new List<String>();
        for(String congaQueryId : congaQueryToCleanId.keySet()){
            String congaQueryWithUnderscore = congaQueryToCleanId.get(congaQueryId);
            if(congaQueryWithUnderscore.contains('_itemId')){
                congaQueriesRequiringOrderItemId.add(congaQueryWithUnderscore.substringBefore('_'));
            } else if(congaQueryWithUnderscore.contains('_optyId')){
                congaQueriesRequiringOppId.add(congaQueryWithUnderscore.substringBefore('_'));
            } else if(congaQueryWithUnderscore.contains('_individualId')){
                congaQueriesRequiringIndividualId.add(congaQueryWithUnderscore.substringBefore('_'));
            } else if(congaQueryWithUnderscore.contains('_contactId')){
                congaQueriesRequiringContactId.add(congaQueryWithUnderscore.substringBefore('_'));
            } else if(congaQueryWithUnderscore.contains('_photovoltaicId')){
                congaQueriesRequiringPhotovoltaicId.add(congaQueryWithUnderscore.substringBefore('_'));
            } else if(congaQueryWithUnderscore.contains('_productId')){
                congaQueriesRequiringProductId.add(congaQueryWithUnderscore.substringBefore('_'));
            } 
        }
        wrapperLists.congaQueriesRequiringOrderItemId = congaQueriesRequiringOrderItemId;
        wrapperLists.congaQueriesRequiringOppId = congaQueriesRequiringOppId;
        wrapperLists.congaQueriesRequiringIndividualId = congaQueriesRequiringIndividualId;
        wrapperLists.congaQueriesRequiringContactId = congaQueriesRequiringContactId;
        wrapperLists.congaQueriesRequiringPhotovoltaicId = congaQueriesRequiringPhotovoltaicId;
        wrapperLists.congaQueriesRequiringProductId = congaQueriesRequiringProductId;
        return wrapperLists;
    }
}