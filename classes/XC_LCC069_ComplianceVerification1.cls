/************************************************************************************************************
* @author :             Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
* @date Creation :      11/01/2019
* @date Modification :  15/01/2019
* @date Modification :  01/04/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description :        XC_LCC069_ComplianceVerification1 –- Controller of XC_LCP069_ComplianceVerification1
************************************************************************************************************/

public without sharing class XC_LCC069_ComplianceVerification1 {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC069_ComplianceVerification1');

    /**
     * @description MapWrapper
     */
    private class MapWrapper{
        Map<String, Set<String>> mapDocumentOrdItem = new Map<String, Set<String>>();
        Map<String, NE__OrderItem__c> mapOrderOrderItem = new Map<String, NE__OrderItem__c>();
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 01/04/2019
     * @description CvsWrapper - Wrapper for create Compliance Verification Status
     */
    public class CvsWrapper {
        public String complianceType;
        public Map<Id, List<String>> mapOrderitemDocument;
        public Map<Id, XC_UTIL_ComplianceMaster.ComplianceWrapperResult> mapOrderitemCompliance;
        public String orderId;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 04/04/2019
     * @description OrderItemCVSwrapper -Wrapper for Junction Object (Order Item - Compliance Verification Status)
     */
    public class OrderItemCVSwrapper {
        public Map<Id, Set<String>> mapOrderItemIdDocuments = new Map<Id, Set<String>>();
        public Map<String, XC_OrderItemCompliance__c> mapDocumentNameOrderItemCompliance = new Map<String, XC_OrderItemCompliance__c>();
    }

    /**
     * @param configurationId the configuration id
     * @return the boolean
     * @description : Method to check if the Compliance 1 Verification is necessary
     */
    @AuraEnabled
    public static Boolean checkCompliance1Needed(String configurationId) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In Compliance Verification 1');
        XC_UTIL_ResultWrapper rw = checkCompliance1NeededOrToSkeep(configurationId);
        return rw.outcome;
    }

    
    /**
     * @description Check compliance 1 needed or to skeep.
     * @param configurationId the configuration id
     * @return the x C UTI L result wrapper
     */
    public static XC_UTIL_ResultWrapper checkCompliance1NeededOrToSkeep(String configurationId) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@@ checkCompliance1NeededOrToSkeep');
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();

        Map<Id,NE__Order__c> ordersMap = new Map<Id,NE__Order__c>([SELECT id, XC_Compliance_Approval__c, NE__Type__c, XC_Subtype__c 
        FROM NE__Order__c WHERE id =: configurationId LIMIT 1]);
        List<NE__Order__c> orders = ordersMap.values();

        if(orders.isEmpty()){
            rw.success = false;
            rw.resultMessage = Label.XC_CL_ErrorsOccurred;//order not found
            return rw;
        }

        NE__Order__c order = orders[0];
        if(!(Label.XC_CL_Configuration_TypeInOrder).equals(order.NE__Type__c) && !(Label.XC_CL_ConfigurationSubtype_ChangeOfOwnership).equals(order.XC_Subtype__c)){
            //Compliance non prevista > non devono essere visualizzati messaggi
            rw.success = true;
            rw.outcome = false;
        } else if(String.isBlank(order.XC_Compliance_Approval__c)) {
            //Compliance needed
            rw.success = true;
            rw.outcome = true;
            rw.resultMessage = Label.XC_CL_ComplianceNeeded;
            rw.typeMessage = 'warning';
        } 
        else {
            //Compliance not needed
            rw.success = true;
            rw.outcome = false;
            rw.resultMessage = Label.XC_CL_Compliance1NotNeeded;
            rw.typeMessage = 'success';
            if(order.XC_Compliance_Approval__c == Label.XC_CL_InProgress) {
                rw.resultMessage = Label.XC_CL_CompleteComplianceVerification;
            } else if(order.XC_Compliance_Approval__c == Label.XC_CL_ComplianceVerificationStatus_StatusOK) {
                rw.resultMessage = Label.XC_CL_ComplianceDone;
            }
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@@ checkCompliance1 result='+rw);
        return rw;
    }
    
    /**
     * @param configurationId the configuration id
     * @return XC_UTIL_ResultWrapper
     * @description : Method to check if there are Documents required by Compliance 1 Verification
     *                It returns false if no Configuration Items need Documents, otherwise it returns true
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkDocumentsComplianceVerification1(String configurationId) {
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        List<NE__Order__c> order = new List<NE__Order__c>([SELECT NE__Type__c, XC_Subtype__c, XC_LegalEntity__c
                                                            FROM NE__Order__c 
                                                            WHERE id =: configurationId]);
        String typeSelected;
        if(order[0].NE__Type__c.equals(Label.XC_CL_Configuration_TypeInOrder)){
            typeSelected = Label.XC_CL_Compliance_C1;
        } else if(order[0].XC_Subtype__c.equals(Label.XC_CL_ConfigurationSubtype_ChangeOfOwnership)){
            typeSelected = Label.XC_CL_Compliance_C5;
        } 
        Map<Id, XC_UTIL_ComplianceMaster.ComplianceWrapperResult> mapOrderitemCompliance1 = XC_UTIL_ComplianceMaster.getDocumentComplianceMaster(typeSelected, configurationId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'MAP from XC_UTIL_ComplianceMaster.getDocumentComplianceMaster' + mapOrderitemCompliance1);
        List<Id> confItemIdList = new List<Id>();
        List<Id> confItemIdListRequiringCases = new List<Id>();
        List<NE__OrderItem__c> confItemListToUpdate = new List<NE__OrderItem__c>();
        
        for(Id orderItemId : mapOrderitemCompliance1.keySet()) {
            if(mapOrderitemCompliance1.get(orderItemId).check) {
                confItemIdList.add(orderItemId);
                if(!mapOrderitemCompliance1.get(orderItemId).complianceMaster.XC_SkipCaseCreation__c || mapOrderitemCompliance1.get(orderItemId).complianceMaster.XC_ComplianceType__c != Label.XC_CL_Compliance_C1){
                    confItemIdListRequiringCases.add(orderItemId);
                }
            } else {
                NE__OrderItem__c configurationItemToUpdate = new NE__OrderItem__c();
                configurationItemToUpdate.id = orderItemId;
                configurationItemToUpdate.XC_Compliance1_Status__c = Label.XC_CL_Configuration_NotNeeded;
                confItemListToUpdate.add(configurationItemToUpdate);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@1306 confItemIdList ---> ' + confItemIdList);
        /* modifica MCutillo 02/04/2019 */
        Map<Id, List<String>> mapOrderitemDocument = new Map<Id, List<String>>();
        if(!confItemIdList.isEmpty()){
            mapOrderitemDocument = XC_UTIL_DocumentComplianceMaster.getDocumentComplianceMaster(typeSelected, confItemIdList);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapOrderitemDocument ---> ' + mapOrderitemDocument);
            if(!checkDoxeeDocumentations(configurationId, mapOrderitemDocument)){
                rw.success = false;
                String missingDocument = XC_LCC069_ComplianceVerification1_U.retrieveMissingDocumentAsString(mapOrderitemDocument, configurationId);
                rw.resultMessage = Label.XC_CL_Compliance1DocIncomplete + Label.XC_CL_ComplianceMissingDocument + missingDocument;
                rw.typeMessage = 'error'; 
                rw.executeNextStep = false;
                return rw;
            }
        }

        XC_UTIL_Sobject.updateListRecords(confItemListToUpdate);
        // SS 27/05/2020 Live Italy - NR0559 - Compliance 1 Skip Enhancement
        Map<Id, List<String>> mapOrderitemDocumentFiltered = new Map<Id, List<String>>();
        Map<Id, XC_UTIL_ComplianceMaster.ComplianceWrapperResult> mapOrderitemCompliance1Filtered = new Map<Id, XC_UTIL_ComplianceMaster.ComplianceWrapperResult>();
        if(!confItemIdListRequiringCases.isEmpty()){
            confItemIdList = confItemIdListRequiringCases;
            for(Id confItemId : mapOrderitemDocument.keySet()){
                if(confItemIdList.contains(confItemId)){
                    mapOrderitemDocumentFiltered.put(confItemId, mapOrderitemDocument.get(confItemId));
                }
            }
            for(Id confItemId : mapOrderitemCompliance1.keySet()){
                if(confItemIdList.contains(confItemId)){
                    mapOrderitemCompliance1Filtered.put(confItemId, mapOrderitemCompliance1.get(confItemId));
                } 
            }
            mapOrderitemDocument = mapOrderitemDocumentFiltered;
            mapOrderitemCompliance1 = mapOrderitemCompliance1Filtered;
        } else { // old logic: if(!String.isBlank(order[0].XC_LegalEntity__c) && order[0].XC_LegalEntity__c == 'EnelXItalia')
            NE__Order__c configurationToUpdate = new NE__Order__c();
            configurationToUpdate.Id = configurationId;
            configurationToUpdate.XC_Compliance_Approval__c = 'OK';
            configurationToUpdate.XC_Status__c = Label.XC_CL_Configuration_OrderToBeValidated;
            XC_UTIL_Sobject.updateRecord(configurationToUpdate);
            rw.success=true;
            rw.resultMessage = Label.XC_CL_OrderUpdated;
            rw.typeMessage = 'success';
            rw.executeNextStep = true; //not needed >> si prosegue
            return rw;
        }

        if(!confItemIdList.isEmpty()) {
            CvsWrapper cvs = new CvsWrapper();
            cvs.mapOrderitemDocument = mapOrderitemDocument;
            cvs.complianceType = typeSelected;
            cvs.orderId = configurationId;
            cvs.mapOrderitemCompliance = mapOrderitemCompliance1;
            createComplianceVerificationStatus(cvs);
            NE__Order__c configurationToUpdate = new NE__Order__c();
            configurationToUpdate.Id = configurationId;
            configurationToUpdate.XC_Compliance_Approval__c = Label.XC_CL_InProgress;
            configurationToUpdate.XC_Status__c = Label.XC_CL_Configuration_OrderToBeValidated;
            XC_UTIL_Sobject.updateRecord(configurationToUpdate);

            rw.success = true;
            rw.typeMessage = 'warning';
            rw.executeNextStep = false; 
            rw.resultMessage = Label.XC_CL_Compliance1Needed;
        } else {
            NE__Order__c configurationToUpdate = new NE__Order__c();
            configurationToUpdate.Id = configurationId;
            configurationToUpdate.XC_Compliance_Approval__c = Label.XC_CL_Configuration_NotNeeded;
            XC_UTIL_Sobject.updateRecord(configurationToUpdate);
            //Compliance not Needed
            rw.success=true;
            rw.resultMessage = Label.XC_CL_Compliance1NotNeeded;
            rw.typeMessage = 'success';
            rw.executeNextStep = true; //not needed >> si prosegue
        }
        
        return rw;
    }

    /**
     * Check doxee documentations.
     *
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @param configurationId the configuration id
     * @param mapOrderitemDocument the map orderitem document
     * @return the boolean
     * @date Creation 02/04/2019
     * @description For all categories that the Configuration in input needs, the method cheks if there is
     * almost a XC_DocumentType__c associated, with a similar Category__c. For empty categories the check is Ok.
     */
    public static Boolean checkDoxeeDocumentations(String configurationId, Map<Id, List<String>> mapOrderitemDocument){
       if(mapOrderitemDocument.isEmpty()){
            return true;
        }
        Set<String> categories = new Set<String>();
        for(List<String> itemCategories : mapOrderitemDocument.values()){
            categories.addAll(itemCategories);
        }
        if(categories.isEmpty()){
            return true;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ categories (in checkDoxeeDocumentations) ---> ' + categories);

        Map<Id,XC_DocumentType__c> docsMap = new Map<Id,XC_DocumentType__c>([SELECT Id, Category__c, numberOfFiles__c 
        FROM XC_DocumentType__c WHERE XC_Configuration__c =: configurationId]);
        List<XC_DocumentType__c> docs = docsMap.values();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ docs ---> ' + docs);
        Boolean docFound = XC_LCC069_ComplianceVerification1_U.checkDocumentOnOrder(docs, categories);
        return docFound;
    }

    /**
     * Gets the wrapper juction object.
     *
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param listOrderItem the list order item
     * @return the wrapper juction object
     * @date Creation 04/04/2019
     * @description getMapConfItemIdExistingDocuments() - Method to create a Map with Configuration Item Id as key and a Set of Existing Documents Name as Value
     */
    public static OrderItemCVSwrapper getWrapperJuctionObject(Set<Id> listOrderItem) {
        OrderItemCVSwrapper wrapper = new OrderItemCVSwrapper();
        Set<String> setDocumentsName;

        Map<Id,XC_OrderItemCompliance__c> listJunctionObjectMap = new Map<Id,XC_OrderItemCompliance__c>([SELECT XC_OrderItem__c, XC_ComplianceVerificationStatus__c,
         XC_ComplianceVerificationStatus__r.Name FROM XC_OrderItemCompliance__c WHERE XC_OrderItem__c IN :listOrderItem]);
        //Add for PMD
        List<XC_OrderItemCompliance__c> listJunctionObject = listJunctionObjectMap.values();

        if(!listJunctionObject.isEmpty()) {
            Map<String, List<String>> maporderItemjunctionObject = new Map<String, List<String>>();
            for(XC_OrderItemCompliance__c junctionObject : listJunctionObject) {
                if(maporderItemjunctionObject.containsKey(junctionObject.XC_OrderItem__c)) {
                    maporderItemjunctionObject.get(junctionObject.XC_OrderItem__c).add(junctionObject.XC_ComplianceVerificationStatus__r.Name);
                } else {
                    maporderItemjunctionObject.put(junctionObject.XC_OrderItem__c, new List<String>{junctionObject.XC_ComplianceVerificationStatus__r.Name});
                }

                // Populate map of wrapper:
                wrapper.mapDocumentNameOrderItemCompliance.put(junctionObject.XC_ComplianceVerificationStatus__r.Name, junctionObject);
            }
            for(Id orderItem : listOrderItem) {
                setDocumentsName = new Set<String>();
                for(String cvsName : maporderItemjunctionObject.get(orderItem)) {
                    setDocumentsName.add(cvsName);
                }
                wrapper.mapOrderItemIdDocuments.put(orderItem, setDocumentsName);
            }
        } 

        return wrapper;
    }

    /**
     * Creates the compliance verification status.
     *
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param cvs the cvs
     * @date Creation 01/04/2019
     * @description createComplianceVerificationStatus() - Method to create Compliance Verification Status records in according to the Compliance Type
     */
    public static void createComplianceVerificationStatus(CvsWrapper cvs) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapConfigurationItemDocument ---> ' + cvs.mapOrderitemDocument);
        List<NE__OrderItem__c> confItemListToUpdate = new List<NE__OrderItem__c>();
        XC_UTIL_Case.createComplianceCases(cvs.mapOrderitemDocument, cvs.mapOrderitemCompliance);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Case created');
        Map<String, Set<String>> mapDocumentOrdItem = XC_UTIL_DocumentComplianceMaster.getMapDocumentListIdConfItem(cvs.mapOrderitemDocument);
        Map<String, NE__OrderItem__c> mapOrderOrderItem = new Map<String, NE__OrderItem__c>([SELECT Id, NE__OrderId__c FROM NE__OrderItem__c WHERE Id IN :cvs.mapOrderitemDocument.keySet()]);   
        Map<Id, Set<String>> mapOrderitemDocumentExist;
        OrderItemCVSwrapper wrapperJunction = new OrderItemCVSwrapper();
        if(XC_LCC069_ComplianceVerification1_U.checkComplianceType(cvs)) {
            wrapperJunction = getWrapperJuctionObject(cvs.mapOrderitemDocument.keyset());
        }
        MapWrapper mapWr = new MapWrapper();
        mapWr.mapDocumentOrdItem = mapDocumentOrdItem;
        mapWr.mapOrderOrderItem = mapOrderOrderItem; 
        cycleOnDocument(mapWr, cvs, wrapperJunction);

        XC_LCC069_ComplianceVerification1_U.UtilComplianceWrapper uWrapper = new XC_LCC069_ComplianceVerification1_U.UtilComplianceWrapper();
        uWrapper.complianceType = cvs.complianceType;
        uWrapper.mapOrderitemDocument = cvs.mapOrderitemDocument;
        uWrapper.orderId = cvs.orderId;
        uWrapper.mapDocumentNameOrderItemCompliance = wrapperJunction.mapDocumentNameOrderItemCompliance;
 
        XC_LCC069_ComplianceVerification1_U.populateJunctionDocumentOrderItem(uWrapper);
    }


    private static void cycleOnDocument(MapWrapper mapWr, CvsWrapper cvs, OrderItemCVSwrapper wrapperJunction){
        List<String> compliance1or5 = new List<String>{Label.XC_CL_Compliance_C1, Label.XC_CL_Compliance_C5};
        Map<String, Set<String>> mapDocumentOrdItem = mapWr.mapDocumentOrdItem;
        Map<String, NE__OrderItem__c> mapOrderOrderItem = mapWr.mapOrderOrderItem;
        List<XC_ComplianceVerificationStatus__c> complStatusList = new List<XC_ComplianceVerificationStatus__c>();
        List<NE__OrderItem__c> listOrderItemToUpdate = new List<NE__OrderItem__c>();
        for(String document : mapDocumentOrdItem.keySet()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For document ---> ' + document);
            Boolean checkNewDocumentsToInsert = false;
            for(String orderItemId: mapDocumentOrdItem.get(document)) {
                if(compliance1or5.contains(cvs.complianceType)||
                    (!compliance1or5.contains(cvs.complianceType) && (wrapperJunction.mapOrderItemIdDocuments.isEmpty() ||
                    (!wrapperJunction.mapOrderItemIdDocuments.isEmpty() && !wrapperJunction.mapOrderItemIdDocuments.get(orderItemId).contains(document))))) {
                    checkNewDocumentsToInsert = true;
                    XC_ComplianceVerificationStatus__c complStatusToInsert = new XC_ComplianceVerificationStatus__c();
                    complStatusToInsert.Name = document;
                    complStatusToInsert.XC_ComplianceType__c = cvs.complianceType;
                    complStatusToInsert.XC_Order__c = mapOrderOrderItem.get(new List<String>(mapDocumentOrdItem.get(document))[0]).NE__OrderId__c;
                    if(!complStatusList.contains(complStatusToInsert)) {
                        complStatusList.add(complStatusToInsert);
                    }
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Add CVS ---> ' + complStatusToInsert);
                }
            }

            populateListToUpdate(mapDocumentOrdItem, document, listOrderItemToUpdate);
        } 
        List<XC_UTIL_Sobject.WrapperResult> wrInsert = XC_UTIL_Sobject.insertListRecords(complStatusList);
        List<XC_UTIL_Sobject.WrapperResult> wrUpdate = XC_UTIL_Sobject.updateListRecords(listOrderItemToUpdate);       
    }

    private static void populateListToUpdate(Map<String, Set<String>> mapDocumentOrdItem, String document, List<NE__OrderItem__c> listOrderItemToUpdate ) {
        for(String orderItem : mapDocumentOrdItem.get(document)) {
            NE__OrderItem__c orderItemToUpdate = new NE__OrderItem__c();
            orderItemToUpdate.Id = orderItem;
            listOrderItemToUpdate.add(orderItemToUpdate);
        }
    } 
}