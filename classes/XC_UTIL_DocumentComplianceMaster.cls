/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com & Marco Rosa - marco.rosa@nttdata.com 
* @date Creation 11/01/2019
* @date Modification 01/04/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_UTIL_DocumentComplianceMaster – Util class for XC_DocumentComplianceMaster__c methods
*/

public without sharing class XC_UTIL_DocumentComplianceMaster {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_DocumentComplianceMaster');
    /**
    * @description DocumentComplianceWrapper
    */
    public class DocumentComplianceWrapper {
        public String country;
        public String type;
        public String productCategory;
        public String paymentMethod;
        public String receivingChannel;
        public String creditAssignment = '';
    }

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description method to getDocumentComplianceMaster
    * @param type
    * @param listConfItem
    * @return getDocumentComplianceMaster
    **/    
    public static Map<Id, List<String>> getDocumentComplianceMaster(String type, List<NE__OrderItem__c> listConfItem){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-----> entered in  getDocumentComplianceMaster----->');
        List<Id> listConfItemId = XC_UTIL_SObject.getIds(listConfItem);
        return getDocumentComplianceMaster(type, listConfItemId);
    }

    private static Boolean checkExactFields (DocumentComplianceWrapper wrapper, XC_DocumentComplianceMaster__c documentComplianceMaster){
        return (wrapper.type == documentComplianceMaster.XC_ComplianceType__c   
            && wrapper.productCategory == documentComplianceMaster.XC_ProductCategory__c
            && wrapper.country == documentComplianceMaster.XC_Country__c
            && wrapper.paymentMethod == documentComplianceMaster.XC_PaymentMethod__c
            && wrapper.receivingChannel == documentComplianceMaster.XC_ReceivingChannel__c
            && (wrapper.creditAssignment == documentComplianceMaster.XC_HasCreditAssignment__c || documentComplianceMaster.XC_HasCreditAssignment__c == null));
    }
	@TestVisible
    private static Boolean checkWildCardFields(DocumentComplianceWrapper wrapper, XC_DocumentComplianceMaster__c documentComplianceMaster){
        return (wrapper.type == documentComplianceMaster.XC_ComplianceType__c   
            && wrapper.productCategory == documentComplianceMaster.XC_ProductCategory__c
            && wrapper.country == documentComplianceMaster.XC_Country__c
            && documentComplianceMaster.XC_PaymentMethod__c == '*'
            && documentComplianceMaster.XC_ReceivingChannel__c == '*'
            && (wrapper.creditAssignment == documentComplianceMaster.XC_HasCreditAssignment__c || documentComplianceMaster.XC_HasCreditAssignment__c == null) );
    }

    private static Boolean checkExactPaymentMethod(DocumentComplianceWrapper wrapper, XC_DocumentComplianceMaster__c documentComplianceMaster){
        return (wrapper.type == documentComplianceMaster.XC_ComplianceType__c   
            && wrapper.productCategory == documentComplianceMaster.XC_ProductCategory__c
            && wrapper.country == documentComplianceMaster.XC_Country__c
            && wrapper.paymentMethod == documentComplianceMaster.XC_PaymentMethod__c
            && documentComplianceMaster.XC_ReceivingChannel__c == '*'
            && (wrapper.creditAssignment == documentComplianceMaster.XC_HasCreditAssignment__c || documentComplianceMaster.XC_HasCreditAssignment__c == null));
    }
	@TestVisible
    private static Boolean checkExactReceivingChannel(DocumentComplianceWrapper wrapper, XC_DocumentComplianceMaster__c documentComplianceMaster){
        return (wrapper.type == documentComplianceMaster.XC_ComplianceType__c   
            && wrapper.productCategory == documentComplianceMaster.XC_ProductCategory__c
            && wrapper.country == documentComplianceMaster.XC_Country__c
            && wrapper.receivingChannel == documentComplianceMaster.XC_ReceivingChannel__c
            && documentComplianceMaster.XC_PaymentMethod__c == '*'
            && (wrapper.creditAssignment == documentComplianceMaster.XC_HasCreditAssignment__c || documentComplianceMaster.XC_HasCreditAssignment__c == null));
    }

    private static void populateDocList(List<String> documents, List<String> finalDoc, Map<String, String> pickListValuesMap){
        for(String doc : documents){
            if(pickListValuesMap.containsKey(doc)){
                String docu = pickListValuesMap.get(doc);
                finalDoc.add(docu);
            }
        }
    }

    private static Boolean checkOnDocumentType(XC_DocumentComplianceMaster__c documentComplianceMaster){
        return (!String.isBlank(documentComplianceMaster.XC_DocumentType__c) && documentComplianceMaster.XC_DocumentType__c.contains(';'));
    }

    private static void checkAndPopulateDocumentList(List<String> documentList, XC_DocumentComplianceMaster__c documentComplianceMaster,Map<String, String> pickListValuesMap){
        if(checkOnDocumentType(documentComplianceMaster)){
            List<String> documents = documentComplianceMaster.XC_DocumentType__c.split(';'); 
            List<String> finalDoc = new List<String>();
            populateDocList(documents, finalDoc, pickListValuesMap);
            
            documentList.addAll(finalDoc);                        
        } else{
            String doc = pickListValuesMap.get(documentComplianceMaster.XC_DocumentType__c);
            documentList.add(doc); 
        } 
    }
    /**
    * @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description method to getDocumentComplianceMaster
    * @param type
    * @param listConfItemId
    * @return mapConfItemComplianceMaster  
    **/ 
    public static Map<Id, List<String>> getDocumentComplianceMaster(String type, List<Id> listConfItemId){
        Map<Id, List<String>> mapConfItemComplianceMaster = new Map<Id, List<String>>();
        List<NE__OrderItem__c> orderItemList = getConfigurationItemFields(listConfItemId); 
        
        Map<Id, DocumentComplianceWrapper> mapConfItemIdWrapper = createMapConfItemIdWrapper(type, orderItemList); 
        List<XC_DocumentComplianceMaster__c> listCompliances = getDocumentComplianceMaster(mapConfItemIdWrapper);
        
        Map<String, String> pickListValuesMap= new  Map<String, String>();
        //Schema.DescribeFieldResult fieldResult = XC_DocumentComplianceMaster__c.XC_DocumentType__c.getDescribe();
        List<Schema.PicklistEntry> ple = XC_DocumentComplianceMaster__c.XC_DocumentType__c.getDescribe().getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesMap.put(pickListVal.getValue(), pickListVal.getLabel());
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-----> listCompliances ----->' + listCompliances);
        
        for(NE__OrderItem__c confItem : orderItemList){
            Boolean found = false;
            DocumentComplianceWrapper wrapper = mapConfItemIdWrapper.get(confItem.Id);
            List<String> documentList = new List<String>();
            
            for(XC_DocumentComplianceMaster__c documentComplianceMaster : listCompliances){
                if(checkExactFields(wrapper,documentComplianceMaster)){   
                    checkAndPopulateDocumentList(documentList,documentComplianceMaster,pickListValuesMap);
                    found = true;
                    break;
                }
            } 
            if(!found){
                for(XC_DocumentComplianceMaster__c documentComplianceMaster : listCompliances){
                    if(checkExactPaymentMethod(wrapper,documentComplianceMaster)){   
                        checkAndPopulateDocumentList(documentList,documentComplianceMaster,pickListValuesMap);
                        found = true;
                        break;
                    }
                } 
            }
            if(!found){
                for(XC_DocumentComplianceMaster__c documentComplianceMaster : listCompliances){
                    if(checkExactReceivingChannel(wrapper,documentComplianceMaster)){   
                        checkAndPopulateDocumentList(documentList,documentComplianceMaster,pickListValuesMap);
                        found = true;
                        break;
                    }
                } 
            }
            if(!found){
                for(XC_DocumentComplianceMaster__c documentComplianceMaster : listCompliances){
                    if(checkWildCardFields(wrapper,documentComplianceMaster)){   
                        checkAndPopulateDocumentList(documentList,documentComplianceMaster,pickListValuesMap);
                        found = true;
                        break;
                    }
                } 
            }
            List<String> tmpList = mapConfItemComplianceMaster.get(confItem.Id);
            if(tmpList == NULL){
                mapConfItemComplianceMaster.put(confItem.Id, documentList); 
            }else {
                tmpList.addAll(documentList);
                mapConfItemComplianceMaster.put(confItem.Id, tmpList); 
            }
        }   
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-----> mapConfItemComplianceMaster----->' + mapConfItemComplianceMaster);
        return mapConfItemComplianceMaster;
    }


    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
    * @description Given a Map Id -> DocumentComplianceWrapper retireves a List of corresponding XC_DocumentComplianceMaster__c
    * @param mapConfItemIdWrapper
    * @return listComplianceMaster
    **/ 
    public static List<XC_DocumentComplianceMaster__c> getDocumentComplianceMaster( Map<Id, DocumentComplianceWrapper> mapConfItemIdWrapper) {
        
        List<String> typeList = new List<String>();
        List<String> productCategoryList = new List<String>(); 
        List<String> countryValueList = new List<String>();
        List<String> paymentMethodList = new List<String>();
        List<String> receivingChannelList = new List<String>();

        for(DocumentComplianceWrapper wrapper : mapConfItemIdWrapper.values()){
            countryValueList.add(wrapper.country);
            typeList.add(wrapper.type);
            productCategoryList.add(wrapper.productCategory); 
            paymentMethodList.add(wrapper.paymentMethod);
            receivingChannelList.add(wrapper.receivingChannel);
        }
        paymentMethodList.add('*');
        receivingChannelList.add('*');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#@ countryValueList----->' + countryValueList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#@ typeList----->' + typeList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#@ productCategoryList----->' + productCategoryList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#@ paymentMethodList----->' + paymentMethodList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#@ receivingChannelList----->' + receivingChannelList);

        List<XC_DocumentComplianceMaster__c> listComplianceMaster  = new List<XC_DocumentComplianceMaster__c>([
        SELECT Id,Name,XC_ComplianceType__c, XC_ProductCategory__c, XC_DocumentType__c, XC_Country__c, XC_PaymentMethod__c, XC_ReceivingChannel__c, XC_HasCreditAssignment__c 
            FROM XC_DocumentComplianceMaster__c
            WHERE XC_ComplianceType__c IN: typeList
            AND XC_ProductCategory__c IN: productCategoryList
            AND XC_Country__c IN: countryValueList
            AND XC_PaymentMethod__c IN: paymentMethodList 
            AND XC_ReceivingChannel__c IN: receivingChannelList
            ORDER BY XC_HasCreditAssignment__c DESC
        ]);     
        return listComplianceMaster;  
    } 


    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description 
    * @param type
    * @param orderItemList
    * @return mapConfItemIdWrapper
    **/    
    public static Map<Id, DocumentComplianceWrapper> createMapConfItemIdWrapper(String type, List<NE__OrderItem__c> orderItemList){
        Map<Id, DocumentComplianceWrapper> mapConfItemIdWrapper = new  Map<Id, DocumentComplianceWrapper>();

        for(NE__OrderItem__c orderItem : orderItemList){ 
            DocumentComplianceWrapper wrapper = new DocumentComplianceWrapper();
            wrapper.type =type;
            wrapper.country = orderItem.XC_CountryFormula__c;     
            wrapper.productCategory = orderItem.NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c;
            wrapper.paymentMethod =  orderItem.XC_PaymentMethod__c;
            wrapper.receivingChannel = orderItem.NE__OrderId__r.NE__OptyId__r.XC_ReceivingChannel__c;
            if(!String.isEmpty(orderItem.NE__Bundle_Configuration__c)){
                if(orderItem.NE__Bundle_Configuration__r.XC_CreditAssignmentAvailable__c  ){
                    if(!String.isEmpty(orderItem.NE__OrderId__r.NE__OptyId__c)  && (orderItem.NE__OrderId__r.NE__OptyId__r.XC_HouseOwner__c == 'Owner' || String.isEmpty(orderItem.NE__OrderId__r.NE__OptyId__r.XC_HouseOwner__c)) ){
                        wrapper.creditAssignment = Label.XC_CL_Yes;
                    } else if(!String.isEmpty(orderItem.NE__OrderId__r.NE__OptyId__c)  && !String.isEmpty(orderItem.NE__OrderId__r.NE__OptyId__r.XC_HouseOwner__c) && orderItem.NE__OrderId__r.NE__OptyId__r.XC_HouseOwner__c != 'Owner'){
                        wrapper.creditAssignment = 'Yes - Not House Owner';
                    }
                    
                }
            } else if(orderItem.XC_CreditAssignmentAvailable__c){
                if(!String.isEmpty(orderItem.NE__OrderId__r.NE__OptyId__c)  && (orderItem.NE__OrderId__r.NE__OptyId__r.XC_HouseOwner__c == 'Owner' || String.isEmpty(orderItem.NE__OrderId__r.NE__OptyId__r.XC_HouseOwner__c)) ){
                    wrapper.creditAssignment = Label.XC_CL_Yes;
                } else if(!String.isEmpty(orderItem.NE__OrderId__r.NE__OptyId__c)  && !String.isEmpty(orderItem.NE__OrderId__r.NE__OptyId__r.XC_HouseOwner__c) && orderItem.NE__OrderId__r.NE__OptyId__r.XC_HouseOwner__c !='Owner'){
                    wrapper.creditAssignment = 'Yes - Not House Owner';
                }
            }
            mapConfItemIdWrapper.put(orderItem.Id, wrapper);
        }
        return mapConfItemIdWrapper; 
    } 
    

    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description Retrieve all values from the Configuration Items in input
    * @param listConfItemId
    * @return orderItemList
    **/
    public static List<NE__OrderItem__c> getConfigurationItemFields(List<Id> listConfItemId){
        String query = XC_UTIL_SObject.selectAllFieldsGetSelect('NE__OrderItem__c'); 
        query += ', NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c, NE__OrderId__r.NE__OptyId__r.XC_ReceivingChannel__c,NE__Bundle_Configuration__r.XC_CreditAssignmentAvailable__c,  NE__OrderId__r.NE__OptyId__c, NE__OrderId__r.NE__OptyId__r.XC_HouseOwner__c ';
        query += ' FROM NE__OrderItem__c WHERE id IN : listConfItemId';
        List<NE__OrderItem__c> orderItemList = Database.query(query);
        return orderItemList;
    }


    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 01/04/2019
    * @description getMapDocumentListIdConfItem - Get Map<Document, Set<IdConfItem>> from Map<IdConfItem, List<Document>>
    * @param mapConfItemDocuments
    * @return mapResult
    **/
    public static Map<String, Set<String>> getMapDocumentListIdConfItem(Map<Id, List<String>> mapConfItemDocuments){
        Map<String, Set<String>> mapResult = new Map<String, Set<String>>();

        for(Id id : mapConfItemDocuments.keySet()) {
            for(String document : mapConfItemDocuments.get(id)) {
                Set<String> setIdConfItem = new Set<String>();
                if(!mapResult.containsKey(document)) {
                    setIdConfItem.add(id);
                    mapResult.put(document, setIdConfItem);
                } else {
                    mapResult.get(document).add(id);
                }
            }
        }

        return mapResult;
    }
}