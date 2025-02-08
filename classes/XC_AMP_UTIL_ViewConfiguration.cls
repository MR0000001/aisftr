/**
* @author Monica Cutillo - mcutillo@deloitte.it
* @date Creation 02/12/2020
* @date Modification dd/mm/yyyy
* @description XC_AMP_UTIL_ViewConfiguration – Util class with method for view configuration
*/ 
public without sharing class XC_AMP_UTIL_ViewConfiguration {

    /** @description ViewDefinition Input Data Wrapper */
    public class ViewDefinitionInputData{
        public XC_CM_OrderPortalSales_ViewDefinition__mdt viewDefMtd;
        public String recordTypeName;
    }

    /**
     * @description retrieveNetworkViewDefinition
     * @return the XC_CM_OrderPortalSales_ViewDefinition__mdt list
     */
    public static List<XC_CM_OrderPortalSales_ViewDefinition__mdt> retrieveNetworkViewDefinition(ViewDefinitionInputData inputData){
        String netName = getNetworkName();
        if(String.isBlank(netName) || inputData == null){
            return new List<XC_CM_OrderPortalSales_ViewDefinition__mdt>();
        }
        String userLE = XC_UTIL_User.getLegalEntityFromUser();
        List<String> filterLE = new List<String>{userLE, null};
        Map<Id,XC_CM_OrderPortalSales_ViewDefinition__mdt> dataView = new Map<Id,XC_CM_OrderPortalSales_ViewDefinition__mdt>([
            SELECT Id, XC_AvailableSections__c, XC_InsertDocument__c, XC_CategoriesMandatoryDocumentation__c, XC_ExtraSections__c, XC_CategoriesExtraSections__c, XC_EditableSectionsBeforeOrderCreation__c, XC_LegalEntity__c, XC_Stream__c, XC_DefaultCategoryOfInterest__c, XC_IsFullFlow__c, XC_AMP_AvailableCatalogCategories__c 
              FROM XC_CM_OrderPortalSales_ViewDefinition__mdt 
             WHERE XC_NetworkName__c =: netName 
               AND XC_LegalEntity__c IN: filterLE
               AND XC_ClientType__c =: inputData.recordTypeName
            LIMIT 1
        ]);
        return dataView.values();
    }
    
    /**
     * @description retrieveComponentDefinition
     * @param inputData the XC_CM_OrderPortalSales_ViewDefinition__mdt
     * @return XC_CM_OrderPortalSales_ViewDefinition__mdt list
     */
    public static List<XC_CM_OrderPortalSales_ComponentDef__mdt> retrieveComponentDefinition(ViewDefinitionInputData inputData){
        List<String> sections = (inputData != null && inputData.viewDefMtd != null) ? inputData.viewDefMtd.XC_AvailableSections__c.split(',')
                                                                                  : new List<String>();
        return getComponentDefinitionForSectionNames(inputData, sections);
    }
    
    /**
     * @description retrieveComponentDefinition
     * @param inputData the XC_CM_OrderPortalSales_ViewDefinition__mdt
     * @param sectionNames List<String>
     * @return XC_CM_OrderPortalSales_ViewDefinition__mdt list
     */
    public static List<XC_CM_OrderPortalSales_ComponentDef__mdt> getComponentDefinitionForSectionNames(ViewDefinitionInputData inputData, List<String> sectionNames){
        if(sectionNames.isEmpty()){
            return new List<XC_CM_OrderPortalSales_ComponentDef__mdt>();
        }
        String netLE = inputData.viewDefMtd.XC_LegalEntity__c;
        String netSgm = inputData.viewDefMtd.XC_Stream__c;
        
        Map<Id,XC_CM_OrderPortalSales_ComponentDef__mdt> dataComponents = new Map<Id,XC_CM_OrderPortalSales_ComponentDef__mdt>([
            SELECT Id, XC_SectionName__c, XC_ComponentName__c, XC_FieldSetName__c, XC_FieldSetRequiredName__c, XC_ReferenceSObject__c , XC_RTDevName__c
              FROM XC_CM_OrderPortalSales_ComponentDef__mdt 
             WHERE XC_SectionName__c IN: sectionNames
               AND XC_LegalEntity__c =: netLE 
               AND XC_Stream__c =: netSgm
        ]);
        return dataComponents.values();
    }

    /**
    * @description Retrieve the current Network name
    * @return the Network Name
    */
    public static String getNetworkName(){
        String idNet = Network.getNetworkId();
        if(String.isBlank(idNet)){
            if(!Test.isRunningTest() ){
                /*idNet = [SELECT network.name, networkId, memberID, Member.Name FROM NetworkMember WHERE memberID = :UserInfo.getUserId() LIMIT 1].networkId;
            }else{*/
                return '';
            }
        }
        Map<Id,Network> dataNet;
        if(Test.isRunningTest()){
            dataNet = new Map<Id,Network>([
                SELECT Id, Name FROM Network WHERE Name = 'Portale Automotive'
            ]);
        }else{
            dataNet = new Map<Id,Network>([
                SELECT Id, Name FROM Network WHERE Id =: idNet
            ]);
        }

        if(dataNet.isEmpty()){
            return '';
        }
        return dataNet.values()[0].Name;
    }

    /**
    * @description Retrieve info from XC_CM_CountryLegalEntityAssociation__mdt by LE and Segment
    * @param legalEntity
    * @param segment
    * @return data map with info
    */
    public static Map<String,XC_CM_CountryLegalEntityAssociation__mdt> getCountryLegalEntityInfo(String legalEntity, String segment) {
        Map<String,XC_CM_CountryLegalEntityAssociation__mdt> result = new Map<String,XC_CM_CountryLegalEntityAssociation__mdt>();
        Map<Id,XC_CM_CountryLegalEntityAssociation__mdt> allMetadata = new Map<Id,XC_CM_CountryLegalEntityAssociation__mdt>([
            SELECT Id, XC_LegalEntity__c, XC_Stream__c, XC_Country__c, XC_Preferredlanguageofcontact__c
            FROM XC_CM_CountryLegalEntityAssociation__mdt
            WHERE XC_LegalEntity__c =: legalEntity
              AND XC_Stream__c =: segment
        ]);

        for(XC_CM_CountryLegalEntityAssociation__mdt cle : allMetadata.values()){
            result.put(cle.XC_LegalEntity__c+cle.XC_Stream__c, cle);
        }
        return result;
    }

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-11-2020 
    * @return Map<String, Object> 
    **/
    public static Map<String,Object> getPartnerUserInfo(){

        Map<String,Object> result = new Map<String,Object>();
        String currentUserId = UserInfo.getUserId();
        String networkId = Network.getNetworkId();

        User currentPartnerUserInfo = [
            SELECT Id, ContactId, Contact.Account.XC_AMP_Catalog__c, Contact.Account.XC_AMP_DefaultCategoryOfInterest__c, Contact.Account.XC_AMP_DefaultBPLI__c,
                   Contact.Account.XC_AMP_AvailableCatalogCategories__c, Contact.Account.XC_AMP_LogoURL__c, XC_Receiving_Channel__c, AccountId, Account.XC_AMP_Partner__c, 
                   Contact.XC_Preferredlanguageofcontact__c, XC_ExternalCallCenterUser__c
              FROM User 
             WHERE Id =: currentUserId];

        result.put('isPartner',String.isNotBlank(currentPartnerUserInfo.ContactId));
        result.put('catalogId',currentPartnerUserInfo.Contact.Account.XC_AMP_Catalog__c);
        result.put('categoryOfInterest',currentPartnerUserInfo.Contact.Account.XC_AMP_DefaultCategoryOfInterest__c);
        result.put('defaultBpli',currentPartnerUserInfo.Contact.Account.XC_AMP_DefaultBPLI__c);
        result.put('receivingChannel',currentPartnerUserInfo.XC_Receiving_Channel__c);
        result.put('logoImageUrl',currentPartnerUserInfo.Contact.Account.XC_AMP_LogoURL__c);
        result.put('ampPartner',currentPartnerUserInfo.Account.XC_AMP_Partner__c);
        result.put('userAccountId',currentPartnerUserInfo.AccountId);
        result.put('preferredlanguageofcontact',currentPartnerUserInfo.Contact.XC_Preferredlanguageofcontact__c);
        result.put('isExternalCallCenterUser',currentPartnerUserInfo.XC_ExternalCallCenterUser__c);

        //getting available catalogCategories
        if(String.isNotBlank(currentPartnerUserInfo.Contact.Account.XC_AMP_AvailableCatalogCategories__c)){
            getPartnerCatalogCategoriesInfos(result,currentPartnerUserInfo.Contact.Account.XC_AMP_AvailableCatalogCategories__c);
        }

        return result;

    }


    /**
    * @description fill available catalog category infos for current partner user
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-14-2020 
    * @param result 
    * @param categoryList 
    **/
    @TestVisible
    public static void getPartnerCatalogCategoriesInfos(Map<String,Object> result,String categoryList){

        String[] listOfCategories = categoryList.split(';');

        List<Map<String,Object>> categoryEntryList = new List<Map<String,Object>>();
        List<NE__Catalog_Category__c> categories = [SELECT Id,Name,XC_LIC_Category_Name__c,NE__CatalogId__c FROM NE__Catalog_Category__c WHERE NE__CatalogId__c = :String.valueOf(result.get('catalogId')) AND XC_LIC_Category_Name__c  IN :listOfCategories];
        for(NE__Catalog_Category__c cat : categories){
            Map<String,Object> categoryEntry = new Map<String,Object>();
            categoryEntry.put('categoryName',cat.Name);
            categoryEntry.put('categoryId',cat.Id);
            categoryEntry.put('categoryLICName',cat.XC_LIC_Category_Name__c);
            categoryEntryList.add(categoryEntry);
        }
        result.put('availableCategories',categoryEntryList);
    }



}