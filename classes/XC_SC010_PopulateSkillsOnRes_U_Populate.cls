/**
* @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 05/03/2019
* @date Modification 06/12/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_SC010_PopulateSkillsOnRes_U_Populate – Execute method for XC_SC010_PopulateSkillsOnResources batch
*/

public class XC_SC010_PopulateSkillsOnRes_U_Populate { 

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC010_PopulateSkillsOnResources');

     /** @description PopulateForUnionWrapper */
    public class PopulateForUnionWrapper {
        public List<ServiceResourceSkill> listSkillToInsert = new List<ServiceResourceSkill>();
        public List<ServiceResourceSkill> listSkillToUpdate = new List<ServiceResourceSkill>();
        public List<ServiceResourceSkill> listSkillToDelete = new List<ServiceResourceSkill>();
        public Id srId;
        public XC_SkillDocumentAssociation__c skillDocAss;
        public XC_SC010_PopulateSkillsOnRes_U_Interval.UnionResult unionDates;
        public List<ServiceResourceSkill> existingServiceResourceSkill = new List<ServiceResourceSkill>();
    }

    /** @description PopulateWrapper */
    public class PopulateWrapper {
        public List<ServiceResourceSkill> existingServiceResourceSkill = new List<ServiceResourceSkill>();
        public List<ServiceResourceSkill> listSkillToInsert = new List<ServiceResourceSkill>();
        public List<ServiceResourceSkill> listSkillToUpdate = new List<ServiceResourceSkill>();
        public List<ServiceResourceSkill> listSkillToDelete = new List<ServiceResourceSkill>();
        public Id srId;
        public List<XC_SC010_PopulateSkillsOnRes_U_Interval.Interval> intervalsDates = new List<XC_SC010_PopulateSkillsOnRes_U_Interval.Interval>();
        public Boolean exists;
        public XC_SkillDocumentAssociation__c skillDocAss;
        public Map<String,Id> skillMap = new Map<String,Id>();
    }

    /** @description PopulateDMLWrapper */
    private class PopulateDMLWrapper {
        XC_SkillDocumentAssociation__c skillDocAss;
        ID srId;
        List<ServiceResourceSkill> listSkillToInsert = new List<ServiceResourceSkill>();
        List<ServiceResourceSkill> listSkillToUpdate = new List<ServiceResourceSkill>();
        List<ServiceResourceSkill> listSkillToDelete = new List<ServiceResourceSkill>();
        List<ServiceResourceSkill> existingServiceResourceSkill = new List<ServiceResourceSkill>();
        Boolean exists = false;
        XC_SC010_PopulateSkillsOnResources_U.DocumentSkillCheckWrapper checkAND;
        XC_SC010_PopulateSkillsOnResources_U.DocumentSkillCheckWrapper checkOR;
        Map<String,Id> skillMap = new Map<String,Id>();
    }

    /** @description CheckExistingWrapper */
    private class CheckExistingWrapper {
        List<ServiceResourceSkill> existingServiceResourceSkill = new List<ServiceResourceSkill>();
        List<ServiceResourceSkill> resourceSkills = new List<ServiceResourceSkill>();
        XC_SkillDocumentAssociation__c skillDocAss;
        Boolean exists = false;
    }

    /** 
     * @description Execute method for XC_SC010_PopulateSkillsOnResources batch
     * @param mapRecordTypeListSkillDocAss - Map<String, List<XC_SkillDocumentAssociation__c>> 
     * @param mapServiceResource - Map<Id, ServiceResource>
    */
    public static void executePopulateSkillOnResource(Map<String, List<XC_SkillDocumentAssociation__c>> mapRecordTypeListSkillDocAss, Map<Id, ServiceResource> mapServiceResource) {
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>(); 
        if(!mapRecordTypeListSkillDocAss.isEmpty()) {
            // Create Lists of objects to insert/update/delete:
            List<ServiceResourceSkill> listSkillToInsert = new List<ServiceResourceSkill>();
            List<ServiceResourceSkill> listSkillToUpdate = new List<ServiceResourceSkill>();
            List<ServiceResourceSkill> listSkillToDelete = new List<ServiceResourceSkill>();

            Map<String,Id> skillMap = XC_UTIL_Skill.getMapSkills(); 

            // For each Service Resource:
            for(Id srId : mapServiceResource.keySet()) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Service Resource ' + srId);
                // Get objects (resourceSkills and resourceDocuments) from ServiceResource (parent)
                List<ServiceResourceSkill> resourceSkills = mapServiceResource.get(srId).ServiceResourceSkills;
                List<XC_ServiceResourceDocument__c> resourceDocuments = mapServiceResource.get(srId).Service_Resource_Documents__r;
                // Get XC_SkillDocumentAssociation__c from map by Type
                List<XC_SkillDocumentAssociation__c> listSkillDocAssToCheck = XC_SC010_PopulateSkillsOnResources_U.getListSkillDocAssToCheck(mapRecordTypeListSkillDocAss, mapServiceResource.get(srId));

                if(!listSkillDocAssToCheck.isEmpty()) {
                    // For each skill:
                    for(XC_SkillDocumentAssociation__c skillDocAss : listSkillDocAssToCheck) {
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Skill ' + skillDocAss.XC_SkillName__c);
                        // Create Lists of Documents (only Name) in AND and in OR:
                        XC_SC010_PopulateSkillsOnResources_U.DocumentsAndOrWrapper documentsAndOrWrapper = XC_SC010_PopulateSkillsOnResources_U.getDocumentsAndOr(skillDocAss);
                        // Check if documents in AND and in OR exist in current resource:
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ documentAND ---> ' + documentsAndOrWrapper.documentsAnd);
                        XC_SC010_PopulateSkillsOnResources_U.DocumentSkillCheckWrapper checkAND = XC_SC010_PopulateSkillsOnResources_U.checkSkill(resourceDocuments, documentsAndOrWrapper.documentsAnd, 'AND');
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ checkAND ---> ' + checkAND);

                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ documentOR ---> ' + documentsAndOrWrapper.documentsOr);
                        XC_SC010_PopulateSkillsOnResources_U.DocumentSkillCheckWrapper checkOR = XC_SC010_PopulateSkillsOnResources_U.checkSkill(resourceDocuments, documentsAndOrWrapper.documentsOr, 'OR');
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ checkOR ---> ' + checkOR);

                        // Check if current Service Resource has current skill:
                        CheckExistingWrapper checkWrapper = new CheckExistingWrapper();
                        checkWrapper.resourceSkills = resourceSkills;
                        checkWrapper.skillDocAss = skillDocAss;
                        checkExistingSkill(checkWrapper);

                        PopulateDMLWrapper populateDMLWrapper = new PopulateDMLWrapper();
                        populateDMLWrapper.skillDocAss = skillDocAss;
                        populateDMLWrapper.srId = srId;
                        populateDMLWrapper.listSkillToInsert = listSkillToInsert;
                        populateDMLWrapper.listSkillToUpdate = listSkillToUpdate;
                        populateDMLWrapper.listSkillToDelete = listSkillToDelete;
                        populateDMLWrapper.existingServiceResourceSkill = checkWrapper.existingServiceResourceSkill;
                        populateDMLWrapper.exists = checkWrapper.exists;
                        populateDMLWrapper.checkAND = checkAND;
                        populateDMLWrapper.checkOR = checkOR;
                        populateDMLWrapper.skillMap = skillMap;
                        checkForPopulateListDML(populateDMLWrapper);
                        listSkillToInsert = populateDMLWrapper.listSkillToInsert;
                        listSkillToUpdate = populateDMLWrapper.listSkillToUpdate;
                        listSkillToDelete = populateDMLWrapper.listSkillToDelete;
                    }
                }
            }

            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listSkillToInsert ---> ' + listSkillToInsert);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listSkillToUpdate ---> ' + listSkillToUpdate);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listSkillToDelete ---> ' + listSkillToDelete);
            
            List<XC_UTIL_Sobject.WrapperResult> listWrToDelete = XC_UTIL_Sobject.deleteListRecords(listSkillToDelete, false);
            for(XC_UTIL_Sobject.WrapperResult wr : listWrToDelete){
                if(!wr.success){
                    XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                    bel.Name = 'XC_SC010_PopulateSkillsOnRes_U_Populate';
                    bel.XC_ErrorMessage__c = wr.errorMessage;
                    bel.XC_TypeOfOperation__c = 'Delete Skill';
                    bel.XC_RecordId__c = wr.errorObjectId;
                    errorLog.add(bel);
                 }
            }
            List<XC_UTIL_Sobject.WrapperResult> listWrForUpdate = XC_UTIL_Sobject.updateListRecords(listSkillToUpdate, false);
            for(XC_UTIL_Sobject.WrapperResult wr : listWrForUpdate){
                if(!wr.success){
                    XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                    bel.Name = 'XC_SC010_PopulateSkillsOnRes_U_Populate';
                    bel.XC_ErrorMessage__c = wr.errorMessage;
                    bel.XC_TypeOfOperation__c = 'Update Skill';
                    bel.XC_RecordId__c = wr.errorObjectId;
                    errorLog.add(bel);
                }
        	}
            List<XC_UTIL_Sobject.WrapperResult> listWrToInsert = XC_UTIL_Sobject.insertListRecords(listSkillToInsert, false);
            for(XC_UTIL_Sobject.WrapperResult wr : listWrToInsert){
                 if(!wr.success){
                    XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                    bel.Name = 'XC_SC010_PopulateSkillsOnRes_U_Populate';
                    bel.XC_ErrorMessage__c = wr.errorMessage;
                    bel.XC_TypeOfOperation__c = 'Insert Skill';
                    errorLog.add(bel);
                }
            }

        	XC_UTIL_Sobject.insertListRecords(errorLog);
        }
    }

    /**
     * @description Populate List for DML operation for Union Interval
     * @param populateWrapper - PopulateForUnionWrapper 
    */
    @TestVisible
    private static void populateListDMLForUnion(PopulateForUnionWrapper populateWrapper) {
        XC_SC010_PopulateSkillsOnRes_U_Interval.ManageIntervalExistingSkillWrapper manageWrapperIntervalExistingSkillWrapper = new XC_SC010_PopulateSkillsOnRes_U_Interval.ManageIntervalExistingSkillWrapper();
        manageWrapperIntervalExistingSkillWrapper.existingServiceResourceSkill = populateWrapper.existingServiceResourceSkill;
        manageWrapperIntervalExistingSkillWrapper.unionDates = populateWrapper.unionDates;
        manageWrapperIntervalExistingSkillWrapper.skillDocAss = populateWrapper.skillDocAss;
        manageWrapperIntervalExistingSkillWrapper.srId = populateWrapper.srId;
        XC_SC010_PopulateSkillsOnResources_U.ManageExistingSkillWrapper manageWrapper = XC_SC010_PopulateSkillsOnRes_U_Interval.manageIntervalExistingSkill(manageWrapperIntervalExistingSkillWrapper);
        if(!manageWrapper.listSkillToDelete.isEmpty()) {
            populateWrapper.listSkillToDelete.addAll(manageWrapper.listSkillToDelete);
        }
        if(!manageWrapper.listSkillToInsert.isEmpty()) {
            populateWrapper.listSkillToInsert.addAll(manageWrapper.listSkillToInsert);
        }
        if(!manageWrapper.listSkillToUpdate.isEmpty()) {
            populateWrapper.listSkillToUpdate.addAll(manageWrapper.listSkillToUpdate);
        }
    }

    /** 
     * @description Populate List for DML operation (FOR CYCLOMATIC COMPLEXITY)
     * @param populateWrapper - PopulateWrapper 
    */
    @TestVisible
    private static void populateListDML(PopulateWrapper populateWrapper) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ populateWrapper.exists ' + populateWrapper.exists); 
        
        Map<String,Id> skillMap = populateWrapper.skillMap;
        for(XC_SC010_PopulateSkillsOnRes_U_Interval.Interval interval : populateWrapper.intervalsDates) {
            if(populateWrapper.exists) {
                populateWrapper.listSkillToDelete.addAll(populateWrapper.existingServiceResourceSkill);
            }
            //if(!populateWrapper.exists) {
                ServiceResourceSkill skillToAdd = new ServiceResourceSkill();
                skillToAdd.SkillId = skillMap.get(populateWrapper.skillDocAss.XC_SkillName__c);
                skillToAdd.ServiceResourceId = populateWrapper.srId;
                skillToAdd.SkillLevel = 1;
                skillToAdd.XC_CertificationStartDate__c = interval.startDate;
                skillToAdd.XC_CertificationEndDate__c = interval.endDate;
                skillToAdd.EffectiveStartDate = interval.startDate;
                skillToAdd.EffectiveEndDate = interval.endDate;
                populateWrapper.listSkillToInsert.add(skillToAdd);
            /*} else {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ populateListDML.interval' + interval);
                XC_SC010_PopulateSkillsOnRes_U_Interval.UnionResult unionDates = XC_SC010_PopulateSkillsOnRes_U_Interval.populateListIntervalForExistingSkill(populateWrapper.existingServiceResourceSkill, interval);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ populateListDML.unionDates' + unionDates);
                if(unionDates.isEmpty) {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Creation of a new interval for existing skill...');
                    ServiceResourceSkill skillToAdd = new ServiceResourceSkill();
                    skillToAdd.SkillId = XC_UTIL_Skill.getMapSkills().get(populateWrapper.skillDocAss.XC_SkillName__c);
                    skillToAdd.ServiceResourceId = populateWrapper.srId;
                    skillToAdd.SkillLevel = 1;
                    skillToAdd.XC_CertificationStartDate__c = interval.startDate;
                    skillToAdd.XC_CertificationEndDate__c = interval.endDate;
                    skillToAdd.EffectiveStartDate = interval.startDate;
                    skillToAdd.EffectiveEndDate = interval.endDate;
                    populateWrapper.listSkillToInsert.add(skillToAdd);
                } else {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Edit of intervals for existing skill...');
                    PopulateForUnionWrapper populateUnionWrapper = new PopulateForUnionWrapper();
                    populateUnionWrapper.listSkillToInsert = populateWrapper.listSkillToInsert;
                    populateUnionWrapper.listSkillToUpdate = populateWrapper.listSkillToUpdate;
                    populateUnionWrapper.listSkillToDelete = populateWrapper.listSkillToDelete;
                    populateUnionWrapper.srId = populateWrapper.srId;
                    populateUnionWrapper.skillDocAss = populateWrapper.skillDocAss;
                    populateUnionWrapper.unionDates = unionDates;
                    populateUnionWrapper.existingServiceResourceSkill = populateWrapper.existingServiceResourceSkill;
                    populateListDMLForUnion(populateUnionWrapper);
                    populateWrapper.listSkillToInsert = populateUnionWrapper.listSkillToInsert;
                    populateWrapper.listSkillToUpdate = populateUnionWrapper.listSkillToUpdate;
                    populateWrapper.listSkillToDelete = populateUnionWrapper.listSkillToDelete;
                }
            }*/
        }
    }

    /** 
     * @description Populate CheckExistingWrapper for Existing Skills
     * @param checkWrapper - CheckExistingWrapper 
    */
    private static void checkExistingSkill(CheckExistingWrapper checkWrapper) {
        for(ServiceResourceSkill existingSkill : checkWrapper.resourceSkills) {
            if(checkWrapper.skillDocAss.XC_SkillName__c.equals(existingSkill.Skill.MasterLabel)) {
                checkWrapper.exists = true;
                checkWrapper.existingServiceResourceSkill.add(existingSkill);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Skill exists');
            }
        }
    }

    /** 
     * @description Populate list for DML operation
     * @param populateDMLWrapper - PpopulateDMLWrapper 
    */
    private static void checkForPopulateListDML(PopulateDMLWrapper populateDMLWrapper) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ populateDMLWrapper.exists ' + populateDMLWrapper.exists); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ populateDMLWrapper.checkAND.result ' + populateDMLWrapper.checkAND.result); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ populateDMLWrapper.checkOR.result ' + populateDMLWrapper.checkOR.result); 
        // To deactive existing skill:
        if((populateDMLWrapper.checkAND.deactive || populateDMLWrapper.checkOR.deactive) && populateDMLWrapper.exists) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Skill disabled.');
            for(ServiceResourceSkill exstSkill : populateDMLWrapper.existingServiceResourceSkill) {
                ServiceResourceSkill srs = new ServiceResourceSkill();
                srs.Id = exstSkill.Id;
                Datetime endDateTemp = exstSkill.EffectiveStartDate;
                srs.EffectiveEndDate = endDateTemp;
                srs.XC_CertificationEndDate__c = date.newinstance(endDateTemp.year(), endDateTemp.month(), endDateTemp.day());
                populateDMLWrapper.listSkillToUpdate.add(srs);
            }
        }
        // ...else:
        else {
            if(populateDMLWrapper.checkAND.result && populateDMLWrapper.checkOR.result) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ populateDMLWrapper.checkAND.listInterval' + populateDMLWrapper.checkAND.listInterval);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ populateDMLWrapper.checkOR.listInterval' + populateDMLWrapper.checkOR.listInterval);
                List<XC_SC010_PopulateSkillsOnRes_U_Interval.Interval> intervalsDates = XC_SC010_PopulateSkillsOnRes_U_Interval.getInsersectionIntervals(populateDMLWrapper.checkAND.listInterval, populateDMLWrapper.checkOR.listInterval);                         
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ checkForPopulateListDML.intervalsDates' + intervalsDates);
 
                PopulateWrapper populateWrapper = new PopulateWrapper();
                populateWrapper.existingServiceResourceSkill = populateDMLWrapper.existingServiceResourceSkill;
                populateWrapper.listSkillToInsert = populateDMLWrapper.listSkillToInsert;
                populateWrapper.listSkillToUpdate = populateDMLWrapper.listSkillToUpdate;
                populateWrapper.listSkillToDelete = populateDMLWrapper.listSkillToDelete;
                populateWrapper.srId = populateDMLWrapper.srId; 
                populateWrapper.intervalsDates = intervalsDates;
                populateWrapper.exists = populateDMLWrapper.exists;
                populateWrapper.skillDocAss = populateDMLWrapper.skillDocAss;
                populateWrapper.skillMap = populateDMLWrapper.skillMap;
                populateListDML(populateWrapper);
                populateDMLWrapper.listSkillToInsert = populateWrapper.listSkillToInsert;
                populateDMLWrapper.listSkillToUpdate = populateWrapper.listSkillToUpdate;
                populateDMLWrapper.listSkillToDelete = populateWrapper.listSkillToDelete;
            }
        }
    }
}