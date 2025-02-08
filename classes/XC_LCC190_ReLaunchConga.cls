/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 25/05/2020
* @date Modification dd/mm/yyyy
* @description XC_LCC190_ReLaunchConga – Controller for XC_LCP190_ReLaunchConga Component 
*/
public class XC_LCC190_ReLaunchConga {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC190_ReLaunchConga');

        /**
    * @description The Class resultWrapper.
    */
    public class ResultWrapper {
        
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String  errorMessage = '';
    }

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 25/5/2020 
    * @param recordId 
    * @return Set<String> 
    **/
    @AuraEnabled        
    public static List<String> getPickListValues(String recordId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_LCC190_ReLaunchConga');
        Map<String,String> documentsAcceptedMap = new Map<String,String>{'PRECONTRACTUAL_CONDITIONS' => 'Precontractual Condition', 
                                                                    'CONTRACT_TO_SIGN' => 'Contract To Sign', 
                                                                    'CREDIT_ASSIGNMENT_TO_SIGN' => 'Credit Assignment to Sign'};
        Map<String,Boolean> checkContractSignedBy = checkContractSignedBy(recordId);
        for(String orderId : checkContractSignedBy.keySet()){
            if(checkContractSignedBy.get(orderId)){
                documentsAcceptedMap.put('CONTRACT_SIGNED','Contract Signed');
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### DocumentsAcceptedMap --->' + documentsAcceptedMap);
        List<String> documentsList = getDocuments(recordId, documentsAcceptedMap);
        return documentsList;
    }
    
    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 25/5/2020 
    * @param recordId 
    * @return Map<String, Boolean> 
    **/
    private static Map<String,Boolean> checkContractSignedBy(String recordId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### recordId --->' + recordId);
        Map<String,Boolean> checkContractSignedBy = new Map<String,Boolean>();
        List<NE__Order__c> orderQueried = new List<NE__Order__c>([SELECT Id,XC_SignedByExternal__c 
                                                                    FROM NE__Order__c 
                                                                    WHERE Id =: recordId]);

        for(NE__Order__c order : orderQueried){
            if(!String.isEmpty(order.XC_SignedByExternal__c)){
                checkContractSignedBy.put(order.Id, true);
            } else {
                checkContractSignedBy.put(order.Id, false);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### checkContractSignedBy --->' + checkContractSignedBy);
        return checkContractSignedBy;
    }

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 25/5/2020 
    * @param recordId 
    * @param documentsAcceptedMap 
    * @return List<String> 
    **/
    private static List<String> getDocuments(String recordId, Map<String,String> documentsAcceptedMap){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### documentsAcceptedMap --->' + documentsAcceptedMap);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### recordId --->' + recordId);
        List<String> documentList = new List<String>();
        List<ContentDocumentLink> documentsCreatedList = new List<ContentDocumentLink>( [SELECT id, ContentDocument.Title 
                                                                                        FROM ContentDocumentLink 
                                                                                        WHERE LinkedEntityId =: recordId 
                                                                                        ORDER BY ContentDocument.CREATEDDATE DESC]);
        
        for(ContentDocumentLink contentDocument : documentsCreatedList){
            for(String docAccepted : documentsAcceptedMap.keySet()){
                if(!String.isEmpty(contentDocument.ContentDocument.Title) && contentDocument.ContentDocument.Title.contains(docAccepted) && !documentList.contains(contentDocument.ContentDocument.Title)){
                    documentList.add(contentDocument.ContentDocument.Title);
                }
            }
        }
        
        return documentList;
    }

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 25/5/2020 
    * @param templateName 
    * @param recordId 
    **/
    @AuraEnabled        
    public static ResultWrapper startCongaFromButton(String templateName, String recordId){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### templateName --->' + templateName);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### recordId --->' + recordId);
        ResultWrapper resWrapper = new ResultWrapper();
        resWrapper.success = false;
        
        Map<Id,NE__OrderItem__c> orderItemForConga = new Map<Id,NE__OrderItem__c>();
        List<NE__OrderItem__c> orderItemToUpdateList = new List<NE__OrderItem__c>();
        String orderItemName = '';
        Boolean precontractualCondition = false;
        Boolean contract = false;
        Boolean creditAssignment = false;
        if(templateName != null && templateName.contains('0')){
            Integer startIndex = templateName.indexOf('0');
            Integer endIndex = startIndex + 10;
            orderItemName = 'OI-'+ templateName.substring(startIndex,endIndex);
        } else {
            resWrapper.errorMessage = Label.XC_CL_RecreateDocument_NoDoc;
            return resWrapper;
        }
        if(templateName.contains('PRECONTRACTUAL_CONDITIONS')){
            precontractualCondition = true;
        } else if(templateName.contains('CONTRACT_')){
            contract = true;
        } else if(templateName.contains('CREDIT_ASSIGNMENT_')){
            creditAssignment = true;
        } else {
            resWrapper.errorMessage = Label.XC_CL_RecreateDocument_NoDoc;
            return resWrapper;
        }
        if(!String.isBlank(orderItemName) && !String.isBlank(recordId)){
            orderItemForConga = new Map<Id,NE__OrderItem__c>([SELECT Id, Name, NE__ProdName__c, NE__OrderId__c, NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c, XC_BillingProfileLineItem__c,NE__ProdId__c,XC_PaymentMethod__c, NE__OrderId__r.XC_DelegatedSignature__c,
                                                                    XC_CongaStaticAPI__c,XC_CongaDynamicAPI__c, XC_BillingModel__c,NE__OrderId__r.Name, NE__OrderId__r.NE__OptyId__c,
                                                                    NE__OrderId__r.NE__AccountId__r.XC_SohoType__c, XC_Product_Subtype__c,NE__OrderId__r.XC_Country__c, NE__Bundle_Configuration__c,
                                                                    NE__OrderId__r.XC_LegalEntity__c, XC_IsAProduct__c, NE__Root_Order_Item__c, NE__Catalog__r.XC_LIC_Name__c, NE__OrderId__r.RecordTypeId, NE__OrderId__r.XC_SignedByExternal__c, NE__OrderId__r.NE__OptyId__r.XC_PrincingRegion__c,
                                                                    NE__OrderId__r.NE__OptyId__r.XC_Contact__r.IndividualId,NE__OrderId__r.NE__Type__c,NE__OrderId__r.XC_SkipContractGeneration__c,
                                                                    NE__OrderId__r.NE__OptyId__r.XC_Contact__c, NE__Bundle__r.LIC_Name__c, NE__OrderId__r.XC_InstallationAddress__r.XC_PricinRegion__c    
                                                                FROM NE__OrderItem__c
                                                                WHERE Name =: orderItemName AND NE__OrderId__c =: recordId]);
        } else {
            resWrapper.errorMessage = Label.XC_CL_RecreateDocument_NoOrderItem;
            return resWrapper;
        }
        if(!orderItemForConga.isEmpty()){
            NE__OrderItem__c orderItemToBlank = orderItemForConga.values()[0];
            orderItemToBlank.XC_CongaDynamicAPI__c = '';
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_UTIL_SObject.updateRecord(orderItemToBlank);
        } else {
            resWrapper.errorMessage = Label.XC_CL_RecreateDocument_NoOrderItem;
            return resWrapper;
        }
        if(contract){
            List<XC_UTIL_Conga.UtilWrapper> wrapperList = XC_TR_ConfigurationItem_U_StartCongaWF.getOrderInfo(orderItemForConga,orderItemForConga.values(), false);
            for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){
                if(XC_TR_ConfigurationItem_U_StartCongaWF.checkEmobilityScenarioAndRecordType(wrapper)) {
                    resWrapper.errorMessage = Label.XC_CL_RecreateDocument_NoDoc;
                    return resWrapper;
                }
            }
            XC_UTIL_Conga.queryOnCongaTemplates(wrapperList, 'CONTRACT_TO_SIGN');
            if(!wrapperList.isEmpty()){
                orderItemToUpdateList = XC_TR_ConfigurationItem_U_StartCongaWF.startingCongaWorkflowOnBundle(wrapperList, 'isInsert');
            }  
        } else if(creditAssignment){
            List<XC_UTIL_Conga.UtilWrapper> wrapperList = XC_TR_ConfigurationItem_U_StartCongaWF.getOrderInfoByCreditAssignment(orderItemForConga.values());
            for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){
                if(XC_TR_ConfigurationItem_U_StartCongaWF.checkEmobilityScenarioAndRecordType(wrapper)) {
                    resWrapper.errorMessage = Label.XC_CL_RecreateDocument_NoDoc;
                    return resWrapper;
                }
            }
            XC_UTIL_Conga.queryOnCongaTemplates(wrapperList, 'CREDIT_ASSIGNMENT_TO_SIGN');
            if(!wrapperList.isEmpty()){
                orderItemToUpdateList = XC_TR_ConfigurationItem_U_StartCongaWF.startingCongaWorkflowOnBundle(wrapperList, 'isInsert');
            }           
        } else if(precontractualCondition){
            List<XC_UTIL_Conga.UtilWrapper> wrapperList = XC_TR_Configuration_U_StartCongaWorkflow.populateWrapper(orderItemForConga);
            if(!wrapperList.isEmpty()){
                XC_UTIL_Conga.queryOnCongaTemplates(wrapperList, 'PRECONTRACTUAL_CONDITIONS');
                orderItemToUpdateList = XC_TR_Configuration_U_StartCongaWorkflow.updateToStartConga(wrapperList);
            } else {
                resWrapper.errorMessage = Label.XC_CL_RecreateDocument_NoDoc;
                return resWrapper;
            }
        } else {
            resWrapper.errorMessage = Label.XC_CL_RecreateDocument_NoDoc;
            return resWrapper;
        }
        
        if(!orderItemToUpdateList.isEmpty()){
            List<XC_UTIL_Sobject.WrapperResult> dMLResultList = XC_UTIL_SObject.updateListRecords(orderItemToUpdateList);
            if(!dMLResultList.isEmpty()){
                resWrapper.success = dMLResultList[0].success;
                resWrapper.errorMessage = dMLResultList[0].errorMessage;
            }
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        }
        return resWrapper;
    }
}