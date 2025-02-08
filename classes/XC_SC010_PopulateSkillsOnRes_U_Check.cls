/**
* @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 05/03/2019
* @description XC_SC010_PopulateSkillsOnRes_U_Check – Util methods for XC_SC010_PopulateSkillsOnResources batch
*/

public class XC_SC010_PopulateSkillsOnRes_U_Check { 

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC010_PopulateSkillsOnResources');

    /** @description CheckDocumentCertificationWrapper */
    public class CheckDocumentCertificationWrapper {
        public XC_SC010_PopulateSkillsOnResources_U.DocumentSkillCheckWrapper wr = new XC_SC010_PopulateSkillsOnResources_U.DocumentSkillCheckWrapper();
        public List<XC_ServiceResourceDocument__c> listDocumentForCertification = new List<XC_ServiceResourceDocument__c>();
        public List<String> requiredDocuments = new List<String>();
        public Map<String,XC_ServiceResourceDocument__c> mapDocumentForCertification = new Map<String,XC_ServiceResourceDocument__c>();
        public Boolean finish = false;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Populate DocumentSkillCheckWrapper
    * @param checkDocCertWRapper - CheckDocumentCertificationWrapper
    */
    public static void populateDocumentSkillCheckWrapper(CheckDocumentCertificationWrapper checkDocCertWRapper) {
        for(String document : checkDocCertWRapper.requiredDocuments) {
            if(document != null) { 
                if(!checkDocCertWRapper.mapDocumentForCertification.containsKey(document)) {
                    break; 
                } else if(checkDocCertWRapper.mapDocumentForCertification.get(document).XC_ResultOfValidation__c.equals('KO')) {
                    checkDocCertWRapper.wr.deactive = true;
                    checkDocCertWRapper.wr.result = false;
                    checkDocCertWRapper.finish = true;
                    break;
                } else {
                    checkDocCertWRapper.listDocumentForCertification.add(checkDocCertWRapper.mapDocumentForCertification.get(document));
                }
            }
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Populate DocumentSkillCheckWrapper for KO
    * @param checkDocCertWRapper - CheckDocumentCertificationWrapper
    */
    public static void populateDocumentSkillCheckWrapperKO(CheckDocumentCertificationWrapper checkDocCertWRapper) {
        Integer documentsKO = 0;
        for(String document : checkDocCertWRapper.requiredDocuments) {
            if(document != null) {
                if(checkDocCertWRapper.mapDocumentForCertification.containsKey(document)) {
                    checkDocCertWRapper.listDocumentForCertification.add(checkDocCertWRapper.mapDocumentForCertification.get(document));
                    documentsKO = countDocumentKO(checkDocCertWRapper, document, documentsKO);
                }
            }
        }

        if(documentsKO == checkDocCertWRapper.requiredDocuments.size()) {
            checkDocCertWRapper.wr.deactive = true;
            checkDocCertWRapper.wr.result = false;
            checkDocCertWRapper.finish = true;
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Count number of Document KO
    * @param checkDocCertWRapper - CheckDocumentCertificationWrapper
    * @param document - String
    * @param documentsKO - Integer
    * @return documentsKO
    */
    private static Integer countDocumentKO(CheckDocumentCertificationWrapper checkDocCertWRapper, String document, Integer documentsKO) {
        if(checkDocCertWRapper.mapDocumentForCertification.get(document).XC_ResultOfValidation__c.equals('KO')) {
            documentsKO++;
        }
        return documentsKO; 
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Populate DocumentSkillCheckWrapper for Intersect
    * @param typeOfList - String
    * @param checkDocCertWRapper - CheckDocumentCertificationWrapper
    */
    public static void populateDocumentSkillCheckWrapperForIntersect(String typeOfList, CheckDocumentCertificationWrapper checkDocCertWRapper) {        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listDocumentForCertification..size ' + checkDocCertWRapper.listDocumentForCertification.size()); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ requiredDocuments.size ' + checkDocCertWRapper.requiredDocuments.size()); 
        if('AND'.equals(typeOfList) && (checkDocCertWRapper.listDocumentForCertification.size() == checkDocCertWRapper.requiredDocuments.size())) {
            List<XC_SC010_PopulateSkillsOnRes_U_Interval.Interval> listInverval = XC_SC010_PopulateSkillsOnRes_U_Interval.getListInterval(checkDocCertWRapper.listDocumentForCertification);
            XC_SC010_PopulateSkillsOnRes_U_Interval.IntersectionResult intersectionDates = XC_SC010_PopulateSkillsOnRes_U_Interval.intervalIntersection(listInverval);
            if(!intersectionDates.isEmpty) {
                checkDocCertWRapper.wr.result = true;
                checkDocCertWRapper.wr.listInterval = intersectionDates.listInterval;
            }
        } /*else {
            checkDocCertWRapper.finish = true;
        }*/
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Populate DocumentSkillCheckWrapper for Union
    * @param typeOfList - String
    * @param checkDocCertWRapper - CheckDocumentCertificationWrapper
    */
    public static void populateDocumentSkillCheckWrapperForUnion(String typeOfList, CheckDocumentCertificationWrapper checkDocCertWRapper) {
        if('OR'.equals(typeOfList) && !checkDocCertWRapper.listDocumentForCertification.isEmpty()) {
            List<XC_SC010_PopulateSkillsOnRes_U_Interval.Interval> listInverval = XC_SC010_PopulateSkillsOnRes_U_Interval.getListInterval(checkDocCertWRapper.listDocumentForCertification);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ populateDocumentSkillCheckWrapperForUnion.listInverval ' + listInverval); 
            XC_SC010_PopulateSkillsOnRes_U_Interval.UnionResult unionDates = XC_SC010_PopulateSkillsOnRes_U_Interval.intervalUnion(listInverval);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ populateDocumentSkillCheckWrapperForUnion.unionDates ' + unionDates); 
            if(!unionDates.isEmpty) {
                checkDocCertWRapper.wr.result = true;
                checkDocCertWRapper.wr.listInterval = unionDates.listInterval;
            }
            //checkDocCertWRapper.finish = true;
        }
    }

    /**
    * @date Creation 18/03/2019
    * @description Check for End Date
    * @param wrapper - CheckIntervalDateWrapper
    */
    public static void checkIntervalDate(XC_SC010_PopulateSkillsOnRes_U_Interval.CheckIntervalDateWrapper wrapper) {
        if(wrapper.listIntervals[wrapper.j].startDate < wrapper.intervals[wrapper.i].startDate && wrapper.listIntervals[wrapper.j].endDate > wrapper.intervals[wrapper.i].endDate) {
            return;
        }
        if(wrapper.listIntervals[wrapper.j].endDate <= wrapper.intervals[wrapper.i].endDate ||
            wrapper.intervals[wrapper.i].startDate < wrapper.listIntervals[wrapper.j].endDate || 
            wrapper.listIntervals[wrapper.j].endDate == wrapper.intervals[wrapper.i].startDate) {
                wrapper.listIntervals[wrapper.j].endDate = wrapper.intervals[wrapper.i].endDate;
                wrapper.union.isEmpty = false;
        }
    }
}