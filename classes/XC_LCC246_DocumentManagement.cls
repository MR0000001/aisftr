/**
  * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
  * @date 24/03/2021
  * @description XC_LCC246_DocumentManagement - Apex Controller for component XC_LCP246_DocumentManagement
*/

public without sharing class XC_LCC246_DocumentManagement {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC246_DocumentManagement');

    /** @description Returnes wrapper for component */
    public class ReturnWrapper {
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String message = '';
        @AuraEnabled
        public Boolean documentsExist = false;
        @AuraEnabled
        public List<String> listDocumentsRequired = new List<String>();
        @AuraEnabled
        public List<String> listExistingDocuments = new List<String>();
        @AuraEnabled
        public String sessionId = '';
        @AuraEnabled
        public String orderId = '';
        @AuraEnabled
        public Map<String, String> mapDocumentCategoryName = new Map<String, String>();
        @AuraEnabled
        public String legalEntity = '';
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 24/03/2021
     * @description Method to retrieve required documents and existing documents
     * @param oppId - String
     * @return ReturnWrapper
     */
    @AuraEnabled
    public static ReturnWrapper getDocuments(String oppId) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In XC_LCC246_DocumentManagement');
        ReturnWrapper rw = new ReturnWrapper();
        try {
            rw.sessionId = UserInfo.getSessionId();
            List<NE__OrderItem__c> listOrderItems = new List<NE__OrderItem__c>([
                SELECT Id, NE__OrderId__c, XC_PaymentMethod__c, NE__OrderId__r.XC_ReceivingChannelFormula__c, NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c, XC_Country__c
                FROM NE__OrderItem__c
                WHERE NE__OrderId__r.NE__OptyId__c = :oppId AND NE__OrderId__r.RecordType.Name = :Label.XC_CL_Configuration_Order AND NE__OrderId__r.NE__Type__c = :Label.XC_CL_Configuration_TypeInOrder AND NE__OrderId__r.XC_Status__c = :Label.XC_CL_Configuration_OrderInProgress
            ]);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Order Item: ' + listOrderItems);
            rw.orderId = listOrderItems[0].NE__OrderId__c;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check documents for order ' + rw.orderId);
            List<String> listPaymentFiltered = new List<String>();
            List<String> listReceivingChannelFiltered = new List<String>();
            List<String> listCategoryFiltered = new List<String>();
            String country = listOrderItems[0].XC_Country__c;
            for(NE__OrderItem__c oi : listOrderItems) {
                if(String.isNotBlank(oi.XC_PaymentMethod__c) && !listPaymentFiltered.contains(oi.XC_PaymentMethod__c)) {
                    listPaymentFiltered.add(oi.XC_PaymentMethod__c);
                }
                if(String.isNotBlank(oi.NE__OrderId__r.XC_ReceivingChannelFormula__c) && !listPaymentFiltered.contains(oi.NE__OrderId__r.XC_ReceivingChannelFormula__c)) {
                    listReceivingChannelFiltered.add(oi.NE__OrderId__r.XC_ReceivingChannelFormula__c);
                }
                if(String.isNotBlank(oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c) && !listPaymentFiltered.contains(oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c)) {
                    listCategoryFiltered.add(oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c);
                }
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listPaymentFiltered: ' + listPaymentFiltered);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listReceivingChannelFiltered: ' + listReceivingChannelFiltered);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listCategoryFiltered: ' + listCategoryFiltered);
            listPaymentFiltered.add('*');
            listReceivingChannelFiltered.add('*');
            listCategoryFiltered.add('*');

            List<XC_DocumentComplianceMaster__c> listDocuments = new List<XC_DocumentComplianceMaster__c>([
                SELECT Id, tolabel(XC_DocumentType__c) NameDocuments, XC_DocumentType__c, XC_ProductCategory__c, XC_PaymentMethod__c, XC_ReceivingChannel__c
                FROM XC_DocumentComplianceMaster__c 
                WHERE XC_ComplianceType__c = 'C1' AND XC_Country__c = :country AND XC_ProductCategory__c IN :listCategoryFiltered AND XC_PaymentMethod__c IN :listPaymentFiltered AND XC_ReceivingChannel__c IN :listReceivingChannelFiltered
            ]);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Document type required: ' + listDocuments);
            if(listDocuments.isEmpty()) {
                rw.message = Label.XC_CL_NoRequiredDocument;
                rw.success = true;
                rw.documentsExist = false;
                return rw;
            }
        
            for(NE__OrderItem__c oi : listOrderItems) {
                Boolean found = false;
                for(XC_DocumentComplianceMaster__c dcm : listDocuments) {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For document master: ' + dcm);
                    if(dcm.XC_ProductCategory__c == oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c &&
                        dcm.XC_PaymentMethod__c == oi.XC_PaymentMethod__c &&
                            dcm.XC_ReceivingChannel__c == oi.NE__OrderId__r.XC_ReceivingChannelFormula__c) {
                                calculateRequiredDocuments(rw, dcm);
                                found = true;
                    }
                }
            
                if(!found) {
                    for(XC_DocumentComplianceMaster__c dcm : listDocuments) {
                        if((dcm.XC_ProductCategory__c == '*' || dcm.XC_ProductCategory__c == oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c) &&
                            dcm.XC_PaymentMethod__c == oi.XC_PaymentMethod__c &&
                                (dcm.XC_ReceivingChannel__c == '*' || dcm.XC_ReceivingChannel__c == oi.NE__OrderId__r.XC_ReceivingChannelFormula__c)) {
                                    calculateRequiredDocuments(rw, dcm);
                                    found = true;
                        }
                    }
                }

                if(!found) {
                    for(XC_DocumentComplianceMaster__c dcm : listDocuments) {
                        if((dcm.XC_ProductCategory__c == '*' || dcm.XC_ProductCategory__c == oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c) &&
                            (dcm.XC_PaymentMethod__c == '*' || dcm.XC_PaymentMethod__c == oi.XC_PaymentMethod__c) &&
                                dcm.XC_ReceivingChannel__c == oi.NE__OrderId__r.XC_ReceivingChannelFormula__c) {
                                    calculateRequiredDocuments(rw, dcm);
                                    found = true;
                        }
                    }
                }

                if(!found) {
                    for(XC_DocumentComplianceMaster__c dcm : listDocuments) {
                        if((dcm.XC_ProductCategory__c == '*' || dcm.XC_ProductCategory__c == oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c) &&
                            (dcm.XC_PaymentMethod__c == '*' || dcm.XC_PaymentMethod__c == oi.XC_PaymentMethod__c) &&
                                (dcm.XC_ReceivingChannel__c == '*' || dcm.XC_ReceivingChannel__c == oi.NE__OrderId__r.XC_ReceivingChannelFormula__c)) {
                                    calculateRequiredDocuments(rw, dcm);
                                    found = true;
                        }
                    }
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Match document master: ' + found);
            }
            List<XC_DocumentType__c> listDocumentsOrder = new List<XC_DocumentType__c>([
                SELECT Id, Category__c    
                FROM XC_DocumentType__c
                WHERE XC_Configuration__c = :rw.orderId
            ]);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Existing documents for order: ' + listDocumentsOrder);
            rw.listExistingDocuments = XC_UTIL_Sobject.getListFieldValues(listDocumentsOrder, 'Category__c');
            List<User> listUser = new List<User>([SELECT Id, XC_LegalEntity__c FROM User WHERE Id = :UserInfo.getUserId()]);
            rw.legalEntity = listUser[0].XC_LegalEntity__c;
            rw.success = true;
            rw.documentsExist = true;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Result Wrapper: ' + rw);
        } catch(Exception e) {
            rw.message = e.getMessage();
            rw.success = false;
            return rw;
        }
        return rw;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 20/04/2021
     * @description Method to check the match
     * @param rw - ReturnWrapper
     * @param dcm - XC_DocumentComplianceMaster__c
     */
    @AuraEnabled
    public static void calculateRequiredDocuments(ReturnWrapper rw, XC_DocumentComplianceMaster__c dcm) {
        List<String> listCategoryCode = dcm.XC_DocumentType__c.split(';');
        List<String> listNameDocument = ((String) dcm.get('NameDocuments')).split(';');
        for(Integer i=0; i<listCategoryCode.size(); i++) {
            if(!rw.listDocumentsRequired.contains(listCategoryCode[i])) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Document required inserted: ' + listCategoryCode[i]);
                rw.listDocumentsRequired.add(listCategoryCode[i]);
                rw.mapDocumentCategoryName.put(listCategoryCode[i], listNameDocument[i]);
            }
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 20/04/2021
     * @description Method to save url for Order
     * @param orderId - String
     * @param valueField - String
     * @return ReturnWrapper
     */
    @AuraEnabled
    public static ReturnWrapper updateOrder(String orderId, String valueField) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In XC_LCC246_DocumentManagement');
        ReturnWrapper rw = new ReturnWrapper();
        try {
            List<XC_CTICallRecording__c> listCTI = new List<XC_CTICallRecording__c>([SELECT Id FROM XC_CTICallRecording__c WHERE XC_Order__c = :orderId]);
            XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
            
            if(listCTI.isEmpty()) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ New record CTI Call Recording');
                XC_CTICallRecording__c ctiToInsert = new XC_CTICallRecording__c(
                    XC_RecordingUrl__c = valueField,
                    XC_Order__c = orderId
                );
                wr = XC_UTIL_Sobject.insertRecord(ctiToInsert);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Record inserted: ' + ctiToInsert);
                if(wr.success) {
                    NE__Order__c orderToUpdate = new NE__Order__c(
                        Id = orderId,
                        XC_CTICallRecording__c = ctiToInsert.Id
                    );
                    wr = XC_UTIL_Sobject.updateRecord(orderToUpdate);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Order to update: ' + orderToUpdate);
                    if(wr.success) {
                        rw.success = true;
                        rw.message = Label.XC_CL_OperationCompleted;
                    } else {
                        rw.success = false;
                        rw.message = wr.errorMessage;
                    }
                } else {
                    rw.success = false;
                    rw.message = wr.errorMessage;
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Result Wrapper: ' + rw);
                return rw;
            } else {
                listCTI[0].XC_RecordingUrl__c = valueField;
                wr = XC_UTIL_Sobject.updateRecord(listCTI[0]);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ CTI record to update: ' + listCTI[0]);
                if(wr.success) {
                    rw.success = true;
                    rw.message = Label.XC_CL_OperationCompleted;
                } else {
                    rw.success = false;
                    rw.message = wr.errorMessage;
                }
                return rw;
            }
        } catch(Exception e) {
            rw.success = false;
            rw.message = e.getMessage();
            return rw;
        }
    }

}