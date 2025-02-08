/**
* @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 05/03/2019
* @description XC_SC010_PopulateSkillsOnResources_U – Util methods for XC_SC010_PopulateSkillsOnResources batch
*/

public without sharing class XC_SC010_PopulateSkillsOnResources_U { 

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC010_PopulateSkillsOnResources');

    /** @description documentsAndOrWrapper – Wrapper for getDocumentsAndOr method */
    public class DocumentsAndOrWrapper{
        public List<String> documentsAnd = new List<String>();
        public List<String> documentsOr = new List<String>();
    } 

    /** @description DocumentSkillCheckWrapper – Wrapper for checkSkill method  */
    public class DocumentSkillCheckWrapper{
        public Boolean result = false;
        public Boolean deactive = false;
        public List<XC_SC010_PopulateSkillsOnRes_U_Interval.Interval> listInterval = new List<XC_SC010_PopulateSkillsOnRes_U_Interval.Interval>();
    }

    /** @description ManageExistingSkillWrapper – Wrapper for checkSkill method */
    public class ManageExistingSkillWrapper {
        public List<ServiceResourceSkill> listSkillToInsert = new List<ServiceResourceSkill>();
        public List<ServiceResourceSkill> listSkillToUpdate = new List<ServiceResourceSkill>();
        public List<ServiceResourceSkill> listSkillToDelete = new List<ServiceResourceSkill>();
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 05/03/2019
    * @description getMapServiceResource – Get Map of Service Resources from a list of Service Resource Documents
    * @param serviceResourceDocument - List<XC_ServiceResourceDocument__c>
    * @return mapServiceResource - Map<Id, ServiceResource>
    */
    public static Map<Id, ServiceResource> getMapServiceResource(List<XC_ServiceResourceDocument__c> serviceResourceDocument){
        // Get IDs from Service Resource (parent):
        List<String> serviceResourceIds = XC_UTIL_Sobject.getListFieldValues(serviceResourceDocument, 'XC_ServiceResource__c');

        // Create map <Id, ServiceResource>:
        if(!Schema.sObjectType.XC_ServiceResourceDocument__c .isAccessible() ||
            !Schema.sObjectType.ServiceResourceSkill.isAccessible() || 
            !Schema.sObjectType.ServiceResource.isAccessible()) {
                return new Map<Id, ServiceResource>();
        }
        Map<Id, ServiceResource> mapServiceResource = new Map<Id, ServiceResource>([
            SELECT Id, IsCapacityBased, XC_Freelance__c, XC_IsManager__c,
            (SELECT Id, XC_StartDateOfValidity__c, XC_ExpirationDateOfValidity__c, XC_DocumentName__c, XC_TypeOfDocument__c, XC_ResultOfValidation__c FROM Service_Resource_Documents__r),
            (SELECT Id, Skill.MasterLabel, EffectiveStartDate, EffectiveEndDate, XC_CertificationStartDate__c, XC_CertificationEndDate__c,XC_AssignmentEndDate__c  FROM ServiceResourceSkills)
            FROM ServiceResource WHERE Id IN :serviceResourceIds]);
        return mapServiceResource;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 05/03/2019
    * @description getMapRecordTypeListSkillDocAss() – Get Map of List of Skill Document Association for RecordType
    * @return mapRecordTypeListSkillDocAss - Map<String, List<XC_SkillDocumentAssociation__c>>
    */ 
    public static Map<String, List<XC_SkillDocumentAssociation__c>> getMapRecordTypeListSkillDocAss() {
        List<XC_SkillDocumentAssociation__c> listSkillDocumentAssociation = [
            SELECT Id, RecordType.DeveloperName, XC_SkillName__c, XC_ListOfDocumentAND__c, XC_ListOfDocumentOR__c 
            FROM XC_SkillDocumentAssociation__c LIMIT 50000];
        Map<String, List<XC_SkillDocumentAssociation__c>> mapRecordTypeListSkillDocAss = new Map<String, List<XC_SkillDocumentAssociation__c>>();
        for(XC_SkillDocumentAssociation__c skillDocAss : listSkillDocumentAssociation) {
            if(!mapRecordTypeListSkillDocAss.containskey(skillDocAss.RecordType.DeveloperName)) {
                mapRecordTypeListSkillDocAss.put(skillDocAss.RecordType.DeveloperName, new List<XC_SkillDocumentAssociation__c>());
            }
            mapRecordTypeListSkillDocAss.get(skillDocAss.RecordType.DeveloperName).add(skillDocAss);
        }
        return mapRecordTypeListSkillDocAss;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 05/03/2019
    * @description getListSkillDocAssToCheck – Get List of Skill Document Association for a Service Resource from a Map (see getMapRecordTypeListSkillDocAss())
    * @param mapRecordTypeListSkillDocAss - Map<String, List<XC_SkillDocumentAssociation__c>>
    * @param sr - ServiceResource
    * @return listSkillDocAssToCheck - List<XC_SkillDocumentAssociation__c>
    */
    public static List<XC_SkillDocumentAssociation__c> getListSkillDocAssToCheck(Map<String, List<XC_SkillDocumentAssociation__c>> mapRecordTypeListSkillDocAss, ServiceResource sr) {
        List<XC_SkillDocumentAssociation__c> listSkillDocAssToCheck = new List<XC_SkillDocumentAssociation__c>();
        if(sr.XC_IsManager__c) {
            listSkillDocAssToCheck = mapRecordTypeListSkillDocAss.get('XC_ESP_SkillDocumentAssociation_Partner');
        }
        else {
            if(sr.XC_Freelance__c) {
                listSkillDocAssToCheck = mapRecordTypeListSkillDocAss.get('XC_ESP_SkillDocumentAssociation_Freelance');
            }
            else {
                listSkillDocAssToCheck = mapRecordTypeListSkillDocAss.get('XC_ESP_SkillDocumentAssociation_Technician');
            }
        }
        return listSkillDocAssToCheck;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 06/03/2019
    * @description getDocumentsAndOr() – Get List of Document Name in AND and in OR from SkillDocumentAssociation
    * @param skillDocAssToCheck - XC_SkillDocumentAssociation__c
    * @return wr - DocumentsAndOrWrapper
    */
    public static DocumentsAndOrWrapper getDocumentsAndOr(XC_SkillDocumentAssociation__c skillDocAssToCheck) {
        DocumentsAndOrWrapper wr = new DocumentsAndOrWrapper();
        if(!String.isBlank(skillDocAssToCheck.XC_ListOfDocumentAND__c)) {
            wr.documentsAnd = skillDocAssToCheck.XC_ListOfDocumentAND__c.split(';');
        }
        if(!String.isBlank(skillDocAssToCheck.XC_ListOfDocumentOR__c)) {
            wr.documentsOr = skillDocAssToCheck.XC_ListOfDocumentOR__c.split(';');
        }

        return wr;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 06/03/2019
    * @description checkSkill() – Check if a list of Document of a Service Resource is contained in a list of Resource Documents
    * @param resourceDocuments - List<XC_ServiceResourceDocument__c>
    * @param requiredDocuments - List<String>
    * @param typeOfList - String
    * @return wr - DocumentSkillCheckWrapper
    */
    public static DocumentSkillCheckWrapper checkSkill(List<XC_ServiceResourceDocument__c> resourceDocuments, List<String> requiredDocuments, String typeOfList) {
        DocumentSkillCheckWrapper wr = new DocumentSkillCheckWrapper();
        if(requiredDocuments.isEmpty()){
            wr.result = true;
            return wr;
        }
        return manageCheckSkill(resourceDocuments, requiredDocuments, typeOfList);
    }
        
    private static DocumentSkillCheckWrapper manageCheckSkill(List<XC_ServiceResourceDocument__c> resourceDocuments, List<String> requiredDocuments, String typeOfList) {
        DocumentSkillCheckWrapper wr = new DocumentSkillCheckWrapper();        
        Map<String,XC_ServiceResourceDocument__c> mapDocumentForCertification = new Map<String,XC_ServiceResourceDocument__c>();

        for(XC_ServiceResourceDocument__c document : resourceDocuments) {
            mapDocumentForCertification.put(document.XC_DocumentName__c,document);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapDocumentForCertification ' + mapDocumentForCertification); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ requiredDocuments ' + requiredDocuments);  
        List<XC_ServiceResourceDocument__c> listDocumentForCertification = new List<XC_ServiceResourceDocument__c>();

        if('AND'.equals(typeOfList)) {
            XC_SC010_PopulateSkillsOnRes_U_Check.CheckDocumentCertificationWrapper checkDocCertWRapper = new XC_SC010_PopulateSkillsOnRes_U_Check.CheckDocumentCertificationWrapper();
            checkDocCertWRapper.requiredDocuments = requiredDocuments;
            checkDocCertWRapper.mapDocumentForCertification = mapDocumentForCertification; 
            XC_SC010_PopulateSkillsOnRes_U_Check.populateDocumentSkillCheckWrapper(checkDocCertWRapper);
            if(checkDocCertWRapper.finish) {
                return checkDocCertWRapper.wr;
            }
            requiredDocuments = checkDocCertWRapper.requiredDocuments; 
            mapDocumentForCertification = checkDocCertWRapper.mapDocumentForCertification;
            wr = checkDocCertWRapper.wr;
            listDocumentForCertification = checkDocCertWRapper.listDocumentForCertification;
        } else {
            XC_SC010_PopulateSkillsOnRes_U_Check.CheckDocumentCertificationWrapper checkDocCertWRapper = new XC_SC010_PopulateSkillsOnRes_U_Check.CheckDocumentCertificationWrapper();
            checkDocCertWRapper.requiredDocuments = requiredDocuments;
            checkDocCertWRapper.mapDocumentForCertification = mapDocumentForCertification;
            XC_SC010_PopulateSkillsOnRes_U_Check.populateDocumentSkillCheckWrapperKO(checkDocCertWRapper);
            if(checkDocCertWRapper.finish) {
                return checkDocCertWRapper.wr;
            }
            requiredDocuments = checkDocCertWRapper.requiredDocuments; 
            mapDocumentForCertification = checkDocCertWRapper.mapDocumentForCertification;
            wr = checkDocCertWRapper.wr;
            listDocumentForCertification = checkDocCertWRapper.listDocumentForCertification;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ requiredDocuments ' + requiredDocuments); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapDocumentForCertification ' + mapDocumentForCertification); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ wr ' + wr); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listDocumentForCertification ' + listDocumentForCertification); 
            

        //Correction for Cyclomatic Complexity:
        XC_SC010_PopulateSkillsOnRes_U_Check.CheckDocumentCertificationWrapper checkDocCertWRapperInter = new XC_SC010_PopulateSkillsOnRes_U_Check.CheckDocumentCertificationWrapper();
        checkDocCertWRapperInter.listDocumentForCertification = listDocumentForCertification;
        checkDocCertWRapperInter.requiredDocuments = requiredDocuments; 
        checkDocCertWRapperInter.wr = wr;    
        XC_SC010_PopulateSkillsOnRes_U_Check.populateDocumentSkillCheckWrapperForIntersect(typeOfList, checkDocCertWRapperInter);
        /*if(checkDocCertWRapperInter.finish) {
            return checkDocCertWRapperInter.wr;
        }*/
        wr = checkDocCertWRapperInter.wr;
        
        XC_SC010_PopulateSkillsOnRes_U_Check.CheckDocumentCertificationWrapper checkDocCertWRapperUnion = new XC_SC010_PopulateSkillsOnRes_U_Check.CheckDocumentCertificationWrapper();
        checkDocCertWRapperUnion.listDocumentForCertification = listDocumentForCertification;
        checkDocCertWRapperUnion.wr = wr;
        XC_SC010_PopulateSkillsOnRes_U_Check.populateDocumentSkillCheckWrapperForUnion(typeOfList, checkDocCertWRapperUnion);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ checkDocCertWRapperUnion ' + checkDocCertWRapperUnion);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ checkDocCertWRapperUnion ' + checkDocCertWRapperUnion.listDocumentForCertification);
        /*if(checkDocCertWRapperUnion.finish) { 
            return (checkDocCertWRapperUnion.wr == null) ? new DocumentSkillCheckWrapper() : checkDocCertWRapperUnion.wr;
        } */
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ checkDocCertWRapperUnion ' + checkDocCertWRapperUnion.wr);  
        wr = checkDocCertWRapperUnion.wr;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ checkDocCertWRapperUnion ' + wr);  
        wr.result = true;
        return wr;
    }

}