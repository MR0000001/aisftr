/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 14/03/2020
* @date Modification dd/mm/yyyy
* @description  – XC_UTIL_Conga_U  - Util class that for XC_UTIL_Conga
*/ 

public without sharing class XC_UTIL_Conga_U {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Conga'); 
    
    /**
    * @description menage the different scenarios for the conga documents creation logic
    * @author salvatore.scarpato@nttdata.com | 14/3/2020 
    * @param wrapperList List<XC_UTIL_Conga.UtilWrapper>
    * @param customMetadataList List<XC_CM_CongaTemplateAssociation__mdt>
    * @param categoryType String
    **/
    public static void manageScenarios(List<XC_UTIL_Conga.UtilWrapper> wrapperList, List<XC_CM_CongaTemplateAssociation__mdt> customMetadataList, String categoryType){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ wrapperList--> ' + wrapperList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ customMetadataList--> ' + customMetadataList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ categoryType--> ' + categoryType);
        if(categoryType == 'PRECONTRACTUAL_CONDITIONS' || categoryType == 'CONTRACT_TO_SIGN' || categoryType == 'CREDIT_ASSIGNMENT_TO_SIGN'){
            for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){
                orderItemScenario(wrapper, customMetadataList);
                //add delega to template if needed
                if(wrapper.customerRepresentative){
                    wrapper.templateList.add('Modulo Delega');
                }
            }
        } /*else if(categoryType == 'Reduced - SERVICE_REPORT') {
            for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){
                workOrderReducedReportScenario(wrapper, customMetadataList);
            
        } }*/ 
         else if (categoryType == 'SERVICE_REPORT'){
            for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){
                workOrderScenario(wrapper, customMetadataList);
            }
        } else if(categoryType == 'SEPA_SIGNATURE'){
            for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){
                sepaSignatureScenario(wrapper, customMetadataList);
            }
        }/*else if (categoryType == 'Info WOLI - SERVICE_REPORT'){
            for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){
                woliScenario(wrapper, customMetadataList);
            }
        }*/
    }

    /**
    * @description check the Spain Scenario, in which to check XC_BillingModel__c, XC_ProductServiceCategory__c, XC_Country__c, XC_LegalEntity__c
    * @author salvatore.scarpato@nttdata.com | 13/3/2020 
    * @param wrapper XC_UTIL_Conga.UtilWrapper 
    * @param customMetadataList List<XC_CM_CongaTemplateAssociation__mdt> 
    **/
    /*private static void spainScenario(XC_UTIL_Conga.UtilWrapper wrapper, List<XC_CM_CongaTemplateAssociation__mdt> customMetadataList){
        for(XC_CM_CongaTemplateAssociation__mdt cmd : customMetadataList){
            if(cmd.XC_BillingModel__c == wrapper.billingModel && cmd.XC_ProductServiceCategory__c == wrapper.categoryName
            && cmd.XC_Country__c ==  wrapper.country 
            && wrapper.legalEntity != null && cmd.XC_LegalEntity__c.contains(wrapper.legalEntity)){
                List<String> cmdtList = new List<String>();
                if(cmd.XC_TemplateList__c.contains('/')){
                    cmdtList = cmd.XC_TemplateList__c.split('/'); 
                } else {
                    cmdtList.add(cmd.XC_TemplateList__c);
                }
                wrapper.templateList = cmdtList;
            }
        }
    }*/

    /**
    * @description check the Italy Scenario, in which to check XC_ProductServiceCategory__c, XC_Country__c, XC_LegalEntity__c, XC_ProductServiceName__c
    * @author salvatore.scarpato@nttdata.com | 13/3/2020 
    * @param wrapper XC_UTIL_Conga.UtilWrapper
    * @param customMetadataList List<XC_CM_CongaTemplateAssociation__mdt>
    **/
    private static void orderItemScenario(XC_UTIL_Conga.UtilWrapper wrapper, List<XC_CM_CongaTemplateAssociation__mdt> customMetadataList){   
       	XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ wrapper--> ' + wrapper);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ customMetadataList--> ' + customMetadataList);
        for(XC_CM_CongaTemplateAssociation__mdt cmd : customMetadataList){
            System.debug('@@@@070521 cmd -->' + cmd);
            List<String> listOfProductServiceCategory = new List<String>();
            List<String> listOfProductServiceName = new List<String>();
            if(!String.isBlank(cmd.XC_ProductServiceCategory__c) && cmd.XC_ProductServiceCategory__c.contains('/')){
                listOfProductServiceCategory = cmd.XC_ProductServiceCategory__c.split('/');
            }else{
                listOfProductServiceCategory.add(cmd.XC_ProductServiceCategory__c);
            }
            if(!String.isBlank(cmd.XC_ProductServiceName__c) && cmd.XC_ProductServiceName__c.contains('/')){
                listOfProductServiceName = cmd.XC_ProductServiceName__c.split('/');
            } else if(!String.isBlank(cmd.XC_ProductServiceName__c)) {
                listOfProductServiceName.add(cmd.XC_ProductServiceName__c);
            }
            if(!listOfProductServiceName.isEmpty()){
                for(String productService : listOfProductServiceCategory){
                    for(String productName : listOfProductServiceName){
                        System.debug('@@@@070521 productService -->' + productService);
                        System.debug('@@@@070521 productName -->' + productName);
                        if(productService == wrapper.categoryName 
                        && cmd.XC_Country__c ==  wrapper.country && productName == wrapper.productServiceName 
                        && wrapper.legalEntity != null && cmd.XC_LegalEntity__c.contains(wrapper.legalEntity)){
                            List<String> cmdtList = new List<String>();
                            if(cmd.XC_TemplateList__c.contains('/')){
                                cmdtList = cmd.XC_TemplateList__c.split('/'); 
                            } else {
                                cmdtList.add(cmd.XC_TemplateList__c);
                            }
                            System.debug('@@@@070521 templateList -->' + cmdtList);
                            wrapper.templateList = cmdtList;
                        }
                    }
                }
            } else {
                for(String productService : listOfProductServiceCategory){
                	XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ productService--> ' + productService);
                    if(productService == wrapper.categoryName 
                    && cmd.XC_Country__c ==  wrapper.country 
                    && wrapper.legalEntity != null && cmd.XC_LegalEntity__c.contains(wrapper.legalEntity)){
                        List<String> cmdtList = new List<String>();
                        if(cmd.XC_TemplateList__c.contains('/')){
                            cmdtList = cmd.XC_TemplateList__c.split('/'); 
                        } else {
                            cmdtList.add(cmd.XC_TemplateList__c);
                        }
                        System.debug('@@@@070521 templateList NO PROD -->' + cmdtList);
                        wrapper.templateList = cmdtList;
                    }
                }
            }
        }
    }

    /**
    * @description check the workOrder Reduced Report Scenario
    * @author salvatore.scarpato@nttdata.com | 23/3/2020 
    * @param wrapper XC_UTIL_Conga.UtilWrapper 
    * @param customMetadataList List<XC_CM_CongaTemplateAssociation__mdt> 
    **/
    /*private static void workOrderReducedReportScenario(XC_UTIL_Conga.UtilWrapper wrapper, List<XC_CM_CongaTemplateAssociation__mdt> customMetadataList){
        for(XC_CM_CongaTemplateAssociation__mdt cmd : customMetadataList){
            List<String> listOfProductServiceCategory = new List<String>();
            if(!String.isBlank(cmd.XC_ProductServiceCategory__c) && cmd.XC_ProductServiceCategory__c.contains('/')){
                listOfProductServiceCategory = cmd.XC_ProductServiceCategory__c.split('/');
            }else{
                listOfProductServiceCategory.add(cmd.XC_ProductServiceCategory__c);
            }
            for(String productService : listOfProductServiceCategory){
                Boolean checkProductSubType = wrapper.workType == Label.XC_CL_WorkType_DeliveryInstallation && productService == wrapper.categoryName;
                if((checkProductSubType||  cmd.XC_WorkType__c.contains(wrapper.workType))
                    && cmd.XC_Country__c ==  wrapper.country 
                    && wrapper.legalEntity != null && cmd.XC_LegalEntity__c.contains(wrapper.legalEntity)){
                    List<String> cmdtList = new List<String>();
                    if(cmd.XC_TemplateList__c.contains('/')){
                        cmdtList = cmd.XC_TemplateList__c.split('/'); 
                    } else {
                        cmdtList.add(cmd.XC_TemplateList__c);
                    }
                    wrapper.templateList = cmdtList;
                }
            }
        }
    }*/

    /**
    * @description check the workOrder Reduced Report Scenario
    * @author salvatore.scarpato@nttdata.com | 23/3/2020 
    * @param wrapper XC_UTIL_Conga.UtilWrapper 
    * @param customMetadataList List<XC_CM_CongaTemplateAssociation__mdt> 
    **/
    @TestVisible
    private static void workOrderScenario(XC_UTIL_Conga.UtilWrapper wrapper, List<XC_CM_CongaTemplateAssociation__mdt> customMetadataList){
   		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ wrapper--> ' + wrapper);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ customMetadataList--> ' + customMetadataList);
        for(XC_CM_CongaTemplateAssociation__mdt cmd : customMetadataList){
            List<String> listOfProductServiceCategory = new List<String>();
            if(!String.isBlank(cmd.XC_ProductServiceCategory__c) && cmd.XC_ProductServiceCategory__c.contains('/')){
                listOfProductServiceCategory = cmd.XC_ProductServiceCategory__c.split('/');
            }else{
                listOfProductServiceCategory.add(cmd.XC_ProductServiceCategory__c);
            }
            for(String productService : listOfProductServiceCategory){            
                if( wrapper.forAragona == cmd.XC_ForAragona__c
                    && productService == wrapper.categoryName
                    && cmd.XC_WorkType__c.contains(wrapper.workType)
                    && cmd.XC_Country__c ==  wrapper.country 
                    && wrapper.legalEntity != null && cmd.XC_LegalEntity__c.contains(wrapper.legalEntity)){
                    List<String> cmdtList = new List<String>();
                    if(cmd.XC_TemplateList__c.contains('/')){
                        cmdtList = cmd.XC_TemplateList__c.split('/'); 
                    } else {
                        cmdtList.add(cmd.XC_TemplateList__c);
                    }
                    wrapper.templateList = cmdtList;
                }
            }
        }
    }

    /**
    * @description check the workOrder Reduced Report Scenario
    * @author salvatore.scarpato@nttdata.com | 23/3/2020 
    * @param wrapper XC_UTIL_Conga.UtilWrapper 
    * @param customMetadataList List<XC_CM_CongaTemplateAssociation__mdt> 
    **/
    private static void sepaSignatureScenario(XC_UTIL_Conga.UtilWrapper wrapper, List<XC_CM_CongaTemplateAssociation__mdt> customMetadataList){
       	XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ wrapper--> ' + wrapper);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ customMetadataList--> ' + customMetadataList);
        for(XC_CM_CongaTemplateAssociation__mdt cmd : customMetadataList){
            
            if( String.isEmpty(wrapper.legalEntity)  || cmd.XC_LegalEntity__c.contains(wrapper.legalEntity) ){
                List<String> cmdtList = new List<String>();
                if(cmd.XC_TemplateList__c.contains('/')){
                    cmdtList = cmd.XC_TemplateList__c.split('/'); 
                } else {
                    cmdtList.add(cmd.XC_TemplateList__c);
                }
                wrapper.templateList = cmdtList;
            }
        }
    }

    /**
    * @description check the creation of woli document
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 23/3/2020 
    * @param wrapper XC_UTIL_Conga.UtilWrapper
    * @param customMetadataList List<XC_CM_CongaTemplateAssociation__mdt>
    **/
    /*private static void woliScenario(XC_UTIL_Conga.UtilWrapper wrapper, List<XC_CM_CongaTemplateAssociation__mdt> customMetadataList){
        for(XC_CM_CongaTemplateAssociation__mdt cmd : customMetadataList){
            if(cmd.XC_Country__c ==  wrapper.country 
            && wrapper.legalEntity != null && cmd.XC_LegalEntity__c.contains(wrapper.legalEntity)){
                List<String> cmdtList = new List<String>();
                if(cmd.XC_TemplateList__c.contains('/')){
                    cmdtList = cmd.XC_TemplateList__c.split('/'); 
                } else {
                    cmdtList.add(cmd.XC_TemplateList__c);
                }
                wrapper.templateList = cmdtList;
            }
        }
    }*/
}