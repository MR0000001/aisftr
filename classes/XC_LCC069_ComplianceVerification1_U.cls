/**
* @author Salvatore Scarpato -- salvatore.scarpato@nttdata.com
* @description UTIL Class for XC_LCC069_ComplianceVerification1
**/
public without sharing class XC_LCC069_ComplianceVerification1_U {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC069_ComplianceVerification1_U');
    /**
     * @description MapWrapper 
    */
    public class UtilWrapper{
        public Map<Id, XC_ComplianceVerificationStatus__c> mapIdDocument = new Map<Id, XC_ComplianceVerificationStatus__c>();
        public Map<String, Set<String>> mapDocumentOrderItem = new Map<String, Set<String>>();
        public Map<String, XC_OrderItemCompliance__c> mapDocumentNameOrderItemCompliance = new Map<String, XC_OrderItemCompliance__c>();
        public Map<String, String> mapConfItemCase = new Map<String, String>();
        public String complianceType;
        public List<Case> listOfCase;
    }

    private class CheckComplianceWrapper {
        String orderItem;
        Map<Id, XC_ComplianceVerificationStatus__c> mapIdDocument = new Map<Id, XC_ComplianceVerificationStatus__c>(); 
        Id idDocument;
        Map<String, XC_OrderItemCompliance__c> mapDocumentNameOrderItemCompliance = new Map<String, XC_OrderItemCompliance__c>();
        String complianceType;
    }

    /**
     * @description UtilComplianceWrapper
    */
    public class UtilComplianceWrapper {
        public String complianceType;
        public Map<Id, List<String>> mapOrderitemDocument = new Map<Id, List<String>>();
        public String orderId;
        public Map<String, XC_OrderItemCompliance__c> mapDocumentNameOrderItemCompliance = new Map<String, XC_OrderItemCompliance__c>();
    }

    private class C1C5Wrapper {
        String complianceType;
        Map<String, XC_OrderItemCompliance__c> mapDocumentNameOrderItemCompliance = new Map<String, XC_OrderItemCompliance__c>();
        Map<Id, XC_ComplianceVerificationStatus__c> mapIdDocument = new Map<Id, XC_ComplianceVerificationStatus__c>();
        Id idDocument;
        String orderItem;
    }
    /**
    * @description
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 22/8/2019
    * @param c1c5wrapper C1C5Wrapper
    * @return Boolean
    */
    private static Boolean checkConditionC1C5(C1C5Wrapper c1c5wrapper){
        List<String> compliance1or5 = new List<String>{Label.XC_CL_Compliance_C1, Label.XC_CL_Compliance_C5};
        String complianceType = c1c5wrapper.complianceType;
        Map<String, XC_OrderItemCompliance__c> mapDocumentNameOrderItemCompliance = c1c5wrapper.mapDocumentNameOrderItemCompliance;
        Map<Id, XC_ComplianceVerificationStatus__c> mapIdDocument = c1c5wrapper.mapIdDocument;
        Id idDocument = c1c5wrapper.idDocument;
        String orderItem = c1c5wrapper.orderItem;
        return (compliance1or5.contains(complianceType) ||
            ( !compliance1or5.contains(complianceType) && mapDocumentNameOrderItemCompliance.get(mapIdDocument.get(idDocument).Name)==null) ||
            ( !compliance1or5.contains(complianceType)  &&
            (mapDocumentNameOrderItemCompliance.get(mapIdDocument.get(idDocument).Name).XC_ComplianceVerificationStatus__c != idDocument &&
            mapDocumentNameOrderItemCompliance.get(mapIdDocument.get(idDocument).Name).XC_OrderItem__c != orderItem)));
    }

    private static Boolean checkOnCompliance(CheckComplianceWrapper checkWr){
        String orderItem = checkWr.orderItem;
        Map<Id, XC_ComplianceVerificationStatus__c> mapIdDocument = checkWr.mapIdDocument;
        Id idDocument = checkWr.idDocument;
        Map<String, XC_OrderItemCompliance__c> mapDocumentNameOrderItemCompliance = checkWr.mapDocumentNameOrderItemCompliance;
        String complianceType = checkWr.complianceType;
        
        Boolean check = false;
        C1C5Wrapper c1c5wrapper = new C1C5Wrapper();
        c1c5wrapper.orderItem = orderItem;
        c1c5wrapper.mapIdDocument = mapIdDocument;
        c1c5wrapper.mapDocumentNameOrderItemCompliance = mapDocumentNameOrderItemCompliance;        
        c1c5wrapper.idDocument = idDocument;
        c1c5wrapper.complianceType = complianceType;
        if(checkConditionC1C5(c1c5wrapper)) {
            check = true;
        }
        return check;
    }
    /**
     * @description complianceUtil
     * @param utilWr
    */
    public static void complianceUtil(UtilWrapper utilWr){
        
        Map<Id, XC_ComplianceVerificationStatus__c> mapIdDocument = utilWr.mapIdDocument;
        Map<String, Set<String>> mapDocumentOrderItem = utilWr.mapDocumentOrderItem;
        Map<String, XC_OrderItemCompliance__c> mapDocumentNameOrderItemCompliance = utilWr.mapDocumentNameOrderItemCompliance;
        Map<String, String> mapConfItemCase = utilWr.mapConfItemCase;
        List<String> listDocumentsToNotDuplicate = new List<String>();
        String complianceType = utilWr.complianceType;
        List<XC_OrderItemCompliance__c> listJunctionDocumentOrderItemToInsert = new List<XC_OrderItemCompliance__c>();

        Integer counterSerialNumber = 0;
        for(Id idDocument : mapIdDocument.keySet()){
            String nameDocument = mapIdDocument.get(idDocument).Name;
            if(nameDocument == 'Serial Number'){
                counterSerialNumber ++;
            }
        }
        Integer counter = 0;
        for(Id idDocument : mapIdDocument.keySet()) {
            String nameDocument = mapIdDocument.get(idDocument).Name;
            if(!listDocumentsToNotDuplicate.contains(nameDocument) && nameDocument != 'Serial Number'){
                listDocumentsToNotDuplicate.add(nameDocument);
            } else if(nameDocument == 'Serial Number') {
                counter ++;
                if(counterSerialNumber != counter){
                    continue;
                }
            } else {
                continue;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ nameDocument ---> ' + nameDocument);
            if(mapDocumentOrderItem.containsKey(nameDocument)) {
                for(String orderItem : mapDocumentOrderItem.get(nameDocument)) {

                    CheckComplianceWrapper checkWr = new CheckComplianceWrapper();
                    checkWr.orderItem = orderItem;
                    checkWr.mapIdDocument = mapIdDocument;
                    checkWr.idDocument = idDocument;
                    checkWr.mapDocumentNameOrderItemCompliance = mapDocumentNameOrderItemCompliance;
                    checkWr.complianceType = complianceType;
                    if(checkOnCompliance(checkWr)) {
                        XC_OrderItemCompliance__c junctionDocumentOrderItem = new XC_OrderItemCompliance__c(
                            XC_ComplianceVerificationStatus__c = idDocument,
                            XC_OrderItem__c = orderItem,
                            XC_Case__c = complianceType == Label.XC_CL_Compliance_C1 || complianceType == Label.XC_CL_Compliance_C5 ? utilWr.listOfCase[0].id : mapConfItemCase.get(orderItem),
                            XC_ComplianceType__c = complianceType
                        );
                        listJunctionDocumentOrderItemToInsert.add(junctionDocumentOrderItem);
                    }
                }
            }
        
        }
        XC_UTIL_Sobject.insertListRecords(listJunctionDocumentOrderItemToInsert);
    }


        /**
     * Populate junction document order item.
     *
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param uWrapper
     * @date Creation 01/04/2019
     * @description populateJunctionDocumentConfItem - Insert records in Junction Object Document-OrderItem
     */
    public static void populateJunctionDocumentOrderItem(UtilComplianceWrapper uWrapper) {
        
        String complianceType = uWrapper.complianceType;
        Map<Id, List<String>> mapOrderitemDocument = uWrapper.mapOrderitemDocument;
        String idOrder = uWrapper.orderId;
        Map<String, XC_OrderItemCompliance__c> mapDocumentNameOrderItemCompliance = uWrapper.mapDocumentNameOrderItemCompliance;

        Map<String, Set<String>> mapDocumentOrderItem = XC_UTIL_DocumentComplianceMaster.getMapDocumentListIdConfItem(mapOrderitemDocument);

        // Create map for CVS
        Map<Id, XC_ComplianceVerificationStatus__c> mapIdDocument = new Map<Id, XC_ComplianceVerificationStatus__c>([SELECT Id, Name
                                                                                                                     FROM XC_ComplianceVerificationStatus__c 
                                                                                                                     WHERE XC_Order__c = :idOrder ORDER BY CreatedDate asc]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapIdDocument ---> ' + mapIdDocument);

        // Create map
        List<String> listOrderItemId = new List<String>(); 
        for(String idDocument : mapDocumentOrderItem.keyset()) {
            for(String idOrderItem : mapDocumentOrderItem.get(idDocument)) {
                listOrderItemId.add(idOrderItem);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listOrderItemId ---> ' + listOrderItemId);

        List<Case> listOfCase = new List<Case>([SELECT Id
                                                FROM Case
                                                WHERE XC_Order__c =: idOrder AND Type =: 'Compliance Verification']);

        if(!listOrderItemId.isEmpty()) {
            Map<Id, Case> mapIdCase = new Map<Id, Case>([SELECT Id, XC_OrderItem__c FROM Case WHERE XC_OrderItem__c IN :listOrderItemId]);
            Map<String, String> mapConfItemCase = new Map<String, String>();
            for(Id cs : mapIdCase.keySet()) {
                mapConfItemCase.put(mapIdCase.get(cs).XC_OrderItem__c, mapIdCase.get(cs).Id);
            }

 
            // For populate junction object:
            UtilWrapper utilWr = new UtilWrapper();
            utilWr.mapIdDocument = mapIdDocument;
            utilWr.mapDocumentOrderItem = mapDocumentOrderItem;
            utilWr.mapDocumentNameOrderItemCompliance = mapDocumentNameOrderItemCompliance;
            utilWr.mapConfItemCase = mapConfItemCase;
            utilWr.complianceType = complianceType;
            utilWr.listOfCase = listOfCase;
            complianceUtil(utilWr);
        }
    }

    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 14/06/2019
     * @description Method to create e missing documents in a String
     * @param mapOrderitemDocument - Map<Id, List<String>>
     * @param configurationId - String
     * @return String
     */
    public static String retrieveMissingDocumentAsString(Map<Id, List<String>> mapOrderitemDocument, String configurationId) {
        List<String> documentL = new List<String>();
        String missingDocument = '';
        Set<String> setDoc = new Set<String>();
        mapOrderitemDocument.remove(null);
        List<List<String>> documents = mapOrderitemDocument.values();
        for(List<String> documentList : documents){
            setDoc.addAll(documentList);
            for(String document : documentList) {
                if(documentL.isEmpty()){
                    documentL.addAll(documentList);
                }
                if(String.isBlank(missingDocument)) {
                    missingDocument = document;
                }
                else if(!missingDocument.contains(document)) {
                    missingDocument = missingDocument + ', ' + document;
                }
            }  
        }
        missingDocument = recalculateMissingDocument(configurationId, missingDocument, setDoc);
        return missingDocument;
    }


    /**
    * @description 
    * @author Del Prete Domenico | 18/10/2019 
    * @param docs 
    * @param categories 
    * @return Boolean 
    **/
    public static Boolean checkDocumentOnOrder(List<XC_DocumentType__c> docs, Set<String> categories){
        Map<String, String> pickListValuesMap = retrievePicklistValue();
        Boolean docFound = false;
         for(String category : categories){
            docFound = false;
            for(XC_DocumentType__c doc : docs){
                if(pickListValuesMap.containsKey(doc.Category__c) && pickListValuesMap.get(doc.Category__c).equals(category)){
                    docFound = true;
                }
            }
            if(!docFound){
                break;   
            }
        }
        return docFound;
    }


    /**
    * @description 
    * @author Del Prete Domenico | 18/10/2019 
    * @return Map<String, String> 
    **/
    public static Map<String, String> retrievePicklistValue (){
        Map<String, String> pickListValuesMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = XC_DocumentComplianceMaster__c.XC_DocumentType__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple){
            pickListValuesMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }
        return pickListValuesMap;
    }

    /**
    * @description 
    * @author Del Prete Domenico | 18/10/2019 
    * @param cvs 
    * @return Boolean 
    **/
    public static Boolean checkComplianceType(XC_LCC069_ComplianceVerification1.CvsWrapper cvs){
        return cvs.complianceType != Label.XC_CL_Compliance_C1 && cvs.complianceType != Label.XC_CL_Compliance_C5;
    }



    /**
    * @description 
    * @author Del Prete Domenico | 18/12/2019 
    * @param configurationId 
    * @param missingDocument 
    * @param allDoc 
    * @return String 
    **/
    public static String recalculateMissingDocument(String configurationId, String missingDocument, Set<String> allDoc){
        Map<String, String> pickListValuesMap = retrievePicklistValue();
        String newMissingDoc ='';
        List<String> allDocList = new List<String>();
        allDocList.addAll(allDoc);
        List <XC_DocumentType__c> listOfDocumentTyp = new List <XC_DocumentType__c>([SELECT Id, XC_Configuration__c, Category__c
                                                                                        FROM XC_DocumentType__c
                                                                                        WHERE XC_Configuration__c =: configurationId]);
        if(listOfDocumentTyp.isEmpty()){
            return missingDocument;
        }
        List<String> docSplit = new List<String>();
        for(XC_DocumentType__c doc :listOfDocumentTyp){
           docSplit.addAll(doc.Category__c.split(';'));
        }
        for(String doc : docSplit){
            String tempDoc = pickListValuesMap.get(doc);
            if(!String.isBlank(tempDoc) && missingDocument.contains(tempDoc)){
                if(allDocList.contains(tempDoc)){
                    Integer index = allDocList.indexOf(tempDoc);
                    allDocList.remove(index);
                }
            }
        }
        for(String doc : allDocList){
            if(String.isBlank(newMissingDoc)) {
                newMissingDoc = doc;
            }
            else if(!newMissingDoc.contains(doc)) {
                newMissingDoc = newMissingDoc + ', ' + doc;
            }
        }
        return newMissingDoc;
    }
}