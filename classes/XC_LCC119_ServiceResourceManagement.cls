/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 12/06/2019
* @description XC_LCC119_ServiceResourceManagement – Custom Controller for XC_LCP119_ServiceResourceManagement
*/

public without sharing class XC_LCC119_ServiceResourceManagement {

    private final static Boolean DEBUGACTIVE = true;//XC_UTIL_Debug.isActive('XC_LCC119_ServiceResourceManagement');

    /** @description InputTableWrapper */
    public class InputTableWrapper { 
        @AuraEnabled
        public List<Map<String, Map<String, List<Map<String, String>>>>> listServiceResourceDocument = new List<Map<String, Map<String, List<Map<String, String>>>>>(); 
        @AuraEnabled
        public List<Map<String, String>> listServiceResourceStatus = new List<Map<String, String>>();
        @AuraEnabled
        public List<Map<String, String>> listServiceResourceSkill = new List<Map<String, String>>();
    }

    /** @description DocumentWrapper */
    public class DocumentWrapper { 
        public String nameDocument = '';
        public String typeDocument = '';
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 12/06/2019
    * @description Method to retrieve Service Resource By Account Id
    * @param accountId - String
    * @return InputTableWrapper
    */ 
    @AuraEnabled
    public static InputTableWrapper getServiceResourceByPartner(String accountId) {
        InputTableWrapper inputWrapper = new InputTableWrapper();
        // Populate List of Service Resource and Service Resource Skills:
        Map<Id, ServiceResource> mapServiceResource = new Map<Id, ServiceResource>([
            SELECT Id, Name,
                (SELECT Id, XC_CertificationEndDate__c, XC_CertificationStartDate__c, Skill.MasterLabel, XC_IsSkillActive__c, ServiceResourceId, EffectiveStartDate, EffectiveEndDate, SkillLevel  
                FROM ServiceResourceSkills),
                (SELECT Id, Name, XC_DocumentName__c, XC_StartDateOfValidity__c, XC_ExpirationDateOfValidity__c, XC_ServiceResource__c 
                FROM Service_Resource_Documents__r)
            FROM ServiceResource 
            WHERE XC_Account__c = :accountId]);
        List<ServiceResource> listServiceResource = mapServiceResource.values();

        //Populate List for Status:
        for(ServiceResource sr : listServiceResource) { 
            Map<String, String> tempMapOutput = checkStatusSkill(sr);
            inputWrapper.listServiceResourceStatus.add(tempMapOutput);
        }
        // Populate List of Skills:
        List<String> listNameSkill = new List<String>();
        for(ServiceResource sr : listServiceResource) { 
            populateStatusSkill(sr, inputWrapper, listNameSkill);
        }

        // Populate List of Documents:
        Map<String, List<DocumentWrapper>> mapSkillDocuments = createMapSkillDocument(listNameSkill);
        for(ServiceResource sr : listServiceResource) { 
            Map<String, Map<String, List<Map<String, String>>>> tempMapOutput = new Map<String, Map<String, List<Map<String, String>>>>(); 
            tempMapOutput.put(sr.Id, new Map<String, List<Map<String, String>>>()); 
            List<ServiceResourceSkill> listServiceResourceSkill = checkActiveSrs(sr.ServiceResourceSkills);
            for(ServiceResourceSkill srs : listServiceResourceSkill) {
                tempMapOutput.get(sr.Id).put(srs.Skill.MasterLabel, new List<Map<String, String>>());
                for(XC_ServiceResourceDocument__c document : sr.Service_Resource_Documents__r) {
                    List<DocumentWrapper> listTempDoc = mapSkillDocuments.get(srs.Skill.MasterLabel);
                    if(checkSizeListDocumentWrapper(listTempDoc)) {
                        Map<String, String> mapNameDocumentWrapper = new Map<String, String>();
                        for(DocumentWrapper wr : listTempDoc) {
                            mapNameDocumentWrapper.put(wr.nameDocument, wr.typeDocument);
                        }
                        if(mapNameDocumentWrapper.keySet().contains(document.XC_DocumentName__c)) {
                            Map<String, String> mapNameFieldDocument = new Map<String, String>();
                            mapNameFieldDocument.put('nameSkill', srs.Skill.MasterLabel);
                            mapNameFieldDocument.put('nameDocument', document.XC_DocumentName__c);
                            mapNameFieldDocument.put('startDate', String.valueOf(document.XC_StartDateOfValidity__c));
                            mapNameFieldDocument.put('endDate', String.valueOf(document.XC_ExpirationDateOfValidity__c));
                            mapNameFieldDocument.put('type', mapNameDocumentWrapper.get(document.XC_DocumentName__c));
                            tempMapOutput.get(sr.Id).get(srs.Skill.MasterLabel).add(mapNameFieldDocument);
                        }
                    } 
                } 
            }
            inputWrapper.listServiceResourceDocument.add(tempMapOutput); 
        }
        return inputWrapper;
    }

    /**
    * @date 14/06/2019
    * @description Method to check if a list of DocumentWrapper is Empty (for cyclomatic complexity)
    * @param listDocumentWrapper - List<DocumentWrapper>
    * @return Boolean
    */
    private static Boolean checkSizeListDocumentWrapper(List<DocumentWrapper> listDocumentWrapper) { 
        Boolean check = false;
        if(listDocumentWrapper != null && !listDocumentWrapper.isEmpty()) {
            check = true;
        }
        return check;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 14/06/2019
    * @description Method to check Skill's status
    * @param sr - ServiceResource
    * @return Map<String, String>
    */
    private static Map<String, String> checkStatusSkill(ServiceResource sr) {
        List<ServiceResourceSkill> listServiceResourceSkill = checkActiveSrs(sr.ServiceResourceSkills);
        Map<String, String> tempMapOutput = new Map<String, String>();
        tempMapOutput.put('Id', sr.Id);
        tempMapOutput.put('nameServiceResource', sr.Name);
        if(listServiceResourceSkill.isEmpty()) {
            tempMapOutput.put('color', 'action:close');
            tempMapOutput.put('label', Label.XC_CL_SerResMangement_SkillDeactive);
        }
        else {
            Integer numberDeactived = 0;
            String color = 'action:approval';
            String message = Label.XC_CL_SerResMangement_SkillActive;   
            for(ServiceResourceSkill srs : listServiceResourceSkill) {
                if(!srs.XC_IsSkillActive__c) {
                    numberDeactived++;
                }
            }
            Integer numberSkill = listServiceResourceSkill.size();
            if(numberSkill == numberDeactived) {
                color = 'action:close';
                message = Label.XC_CL_SerResMangement_SkillDeactive;
            } else if(numberDeactived > 0) {
                color = 'action:new_case';
                message = Label.XC_CL_SerResMangement_SkillSomeDeactive;
            } 
            tempMapOutput.put('color', color);
            tempMapOutput.put('label', message);
        }
        return tempMapOutput;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 08/07/2019
    * @description Method to check only Skill Active or near today
    * @param listServiceResourceSkill - List<ServiceResourceSkill>
    * @return List<ServiceResourceSkill> 
    */
    private static List<ServiceResourceSkill> checkActiveSrs(List<ServiceResourceSkill> listServiceResourceSkill) {
        Map<String, ServiceResourceSkill> mapSrs = new Map<String, ServiceResourceSkill>();
        Map<String, List<ServiceResourceSkill>> mapLabelServiceResourceSkill = new Map<String, List<ServiceResourceSkill>>();
        for(ServiceResourceSkill srs : listServiceResourceSkill) {
            if(!mapLabelServiceResourceSkill.containsKey(srs.Skill.MasterLabel)) {
                mapLabelServiceResourceSkill.put(srs.Skill.MasterLabel, new List<ServiceResourceSkill>());
            }
            mapLabelServiceResourceSkill.get(srs.Skill.MasterLabel).add(srs);

            mapSrs.put(srs.Id, srs);
        }

        List<ServiceResourceSkill> listResult = new List<ServiceResourceSkill>();
        for(String skill : mapLabelServiceResourceSkill.keySet()) {
            XC_UTIL_ServiceResourceSkill.SkillCheckWrapper wrapper = XC_UTIL_ServiceResourceSkill.checkServiceResourceSkill(mapLabelServiceResourceSkill.get(skill));
            listResult.add(mapSrs.get(wrapper.srsId));
        }

        return listResult;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 14/06/2019
    * @description Method to populate Skills
    * @param sr - ServiceResource
    * @param inputWrapper - InputTableWrapper
    * @param listNameSkill - List<String>
    */
    private static void populateStatusSkill(ServiceResource sr, InputTableWrapper inputWrapper, List<String> listNameSkill) {
        List<ServiceResourceSkill> listServiceResourceSkill = checkActiveSrs(sr.ServiceResourceSkills);
        for(ServiceResourceSkill srs : listServiceResourceSkill) {
            Map<String, String> tempMapOutput = new Map<String, String>();
            tempMapOutput.put('Id', sr.Id);
            tempMapOutput.put('nameSkill', srs.Skill.MasterLabel);
            if(srs.XC_IsSkillActive__c) {
                tempMapOutput.put('active', 'action:approval');
            } else {
                tempMapOutput.put('active', 'action:close');
            }
            listNameSkill.add(srs.Skill.MasterLabel);
            inputWrapper.listServiceResourceSkill.add(tempMapOutput);
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 14/06/2019
    * @description Method to create a map with Key->Skill.MasterLabel and Value->Document
    * @param listNameSkill - List<String>
    * @return Map<String, List<DocumentWrapper>>
    */
    private static Map<String, List<DocumentWrapper>> createMapSkillDocument(List<String> listNameSkill) {
        
        Map<Id,XC_SkillDocumentAssociation__c> mapDocuments = new Map<Id,XC_SkillDocumentAssociation__c>([
            SELECT Id, XC_ListOfDocumentAND__c, XC_ListOfDocumentOR__c, XC_SkillName__c
            FROM XC_SkillDocumentAssociation__c
            WHERE XC_SkillName__c IN :listNameSkill
        ]);
        List<XC_SkillDocumentAssociation__c> listDocuments = mapDocuments.values();
        Map<String, List<DocumentWrapper>> mapSkillDocuments = new Map<String, List<DocumentWrapper>>();
        for(XC_SkillDocumentAssociation__c document : listDocuments) {
            List<DocumentWrapper> listAllDocument = new List<DocumentWrapper>();
            List<String> listDocumentAnd = String.isBlank(document.XC_ListOfDocumentAND__c) ? new List<String>() : document.XC_ListOfDocumentAND__c.split(';');
            List<String> listDocumentOr = String.isBlank(document.XC_ListOfDocumentOR__c) ? new List<String>() : document.XC_ListOfDocumentOR__c.split(';');
            for(String andDocument : listDocumentAnd) {
                DocumentWrapper documentWrapper = new DocumentWrapper();
                documentWrapper.nameDocument = andDocument;
                documentWrapper.typeDocument = 'A';
                listAllDocument.add(documentWrapper);
            }
            for(String orDocument : listDocumentOr) {
                DocumentWrapper documentWrapper = new DocumentWrapper();
                documentWrapper.nameDocument = orDocument;
                documentWrapper.typeDocument = 'O';
                listAllDocument.add(documentWrapper);
            }
            mapSkillDocuments.put(document.XC_SkillName__c, listAllDocument);
        }
        return mapSkillDocuments;
    }

}