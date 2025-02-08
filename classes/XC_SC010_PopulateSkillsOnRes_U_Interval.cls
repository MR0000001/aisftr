/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 23/04/2019
* @date Modification 06/12/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_SC010_PopulateSkillsOnRes_U_Interval – Util methods to manage Interval (for) XC_SC010_PopulateSkillsOnResources batch)
*/

public class XC_SC010_PopulateSkillsOnRes_U_Interval {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC010_PopulateSkillsOnResources');

    /** @description CheckIntervalDateWrapper */
    public class CheckIntervalDateWrapper {
        public Integer j;
        public Integer i;
        public List<Interval> intervals = new List<Interval>();
        public List<Interval> listIntervals = new List<Interval>();
        public UnionResult union;
    }

    /** @description Class for Interval */
    public class Interval {
        public Date startDate = null;
        public Date endDate = null;
    }

    /** @description Class for Interval Intersection */
    public class IntersectionResult { 
        public Boolean isEmpty = true;
        public List<Interval> listInterval = new List<Interval>();
    }

    /** @description Class for Interval Union */
    public class UnionResult { 
        public Boolean isEmpty = true;
        public List<Interval> listInterval = new List<Interval>();
    }

    /** @description Manage Interval Existing Skill */
    public class ManageIntervalExistingSkillWrapper {
        public List<ServiceResourceSkill> existingServiceResourceSkill;
        public UnionResult unionDates;
        public XC_SkillDocumentAssociation__c skillDocAss;
        public Id srId;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 06/03/2019
    * @description calculateMaxOfDates() – Get MAX of dates in a list
    * @param listDate - List<Date>
    * @return maxDate - Date
    */
    public static Date calculateMaxOfDates(List<Date> listDate) {
        Date maxDate = listDate[0];
        Integer sizelistDate = listDate.size();
        Integer countlistDate = 1;
        while(countlistDate < sizelistDate) {
            if(listDate[countlistDate-1] < listDate[countlistDate]) {
                maxDate = listDate[countlistDate];
            }
            countlistDate = countListDate + 1;
        }
        return maxDate;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 06/03/2019
    * @description calculateMinOfDates() – Get MIN of dates in a list
    * @param listDate - List<Date>
    * @return minDate - Date
    */
    public static Date calculateMinOfDates(List<Date> listDate) {
        Date minDate = listDate[0];
        Integer sizelistDate = listDate.size();
        Integer countlistDate = 1;
        while(countlistDate < sizelistDate) {
            if(listDate[countlistDate-1] > listDate[countlistDate]) {
                minDate = listDate[countlistDate];
            }
            countlistDate = countListDate + 1;
        }
        return minDate;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 06/03/2019
    * @description intervalIntersection() – Interval Intersection
    * @param intervals - List<Interval>
    * @return intersection - IntersectionResult
    */
    public static IntersectionResult intervalIntersection(List<Interval> intervals) {
        IntersectionResult intersection = new IntersectionResult();

        List<Date> listStartDates = new List<Date>();
        List<Date> listEndDates = new List<Date>();
        for(Interval interval : intervals) {
            listStartDates.add(interval.startDate);
            listEndDates.add(interval.endDate);
        }

        Date maxStartDate = calculateMaxOfDates(listStartDates);
        Date minEndDate = calculateMinOfDates(listEndDates);

        if(maxStartDate != null && minEndDate != null && maxStartDate <= minEndDate) {
            Interval newInterval = new Interval();
            newInterval.startDate = maxStartDate;
            newInterval.endDate = minEndDate;
            intersection.listInterval.add(newInterval);
            intersection.isEmpty = false;
            return intersection;
        }
        
        return intersection;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 06/03/2019
    * @description intervalUnion() – Interval Union
    * @param intervals - List<Interval>
    * @return union - UnionResult
    */
    public static UnionResult intervalUnion(List<Interval> intervals) {
        UnionResult union = new UnionResult();
        if(intervals.isEmpty()) {
            return union;
        } 

        List<Interval> listIntervalOrdered = orderIntervals(intervals);

        List<Interval> listIntervals = new List<Interval>();
        Interval firstInterval = new Interval();
        firstInterval.startDate = listIntervalOrdered[0].startDate;
        firstInterval.endDate = listIntervalOrdered[0].endDate;
        listIntervals.add(firstInterval);

        if(listIntervalOrdered.size() != 1) {
            for(Integer i=1; i<listIntervalOrdered.size(); i++) {
                Integer sizeListIntervals = listIntervals.size();
                Boolean createNewInterval = false;
                for(Integer j=0; j<sizeListIntervals; j++) {
                    if((listIntervalOrdered[i].startDate > listIntervals[j].endDate) || (listIntervalOrdered[i].endDate < listIntervals[j].startDate)) {
                        createNewInterval = true;
                    }
                    else {
                        CheckIntervalDateWrapper checkIntervalDateWrapper = new CheckIntervalDateWrapper();
                        checkIntervalDateWrapper.j = j;
                        checkIntervalDateWrapper.i = i;
                        checkIntervalDateWrapper.intervals = listIntervalOrdered;
                        checkIntervalDateWrapper.listIntervals = listIntervals;
                        checkIntervalDateWrapper.union = union;
                        XC_SC010_PopulateSkillsOnRes_U_Check.checkIntervalDate(checkIntervalDateWrapper);
                        listIntervals = checkIntervalDateWrapper.listIntervals;
                        union = checkIntervalDateWrapper.union;
                        createNewInterval = false;
                    }
                }

                if(createNewInterval) {
                    Interval newInterval = new Interval();
                    newInterval.startDate = listIntervalOrdered[i].startDate;
                    newInterval.endDate = listIntervalOrdered[i].endDate;
                    listIntervals.add(newInterval);
                }
            }
        }
        
        union.listInterval = listIntervals;
        union.isEmpty = false;
        return union;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 18/03/2019
    * @description orderIntervals() – Order list of intervals
    * @param intervals - List<Interval>
    * @return List<Interval>
    */
    private static List<Interval> orderIntervals(List<Interval> intervals) {
        List<Interval> resultList = intervals;
        Interval temp = new Interval();
        Boolean swapped = false;
    
        do {
            swapped = false;
            for(Integer i=0; i<(resultList.size()-1); i++) {
                if(resultList[i].startDate > resultList[i+1].startDate) {
                    temp = resultList[i];
                    resultList[i] = resultList[i+1];
                    resultList[i+1] = temp;
                    swapped = true;
                }
            }
        } while(swapped==true);

        return resultList;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 18/03/2019
    * @description getListInterval() – Get list interval from List of ServiceResourceDocument
    * @param listDocuments - List<XC_ServiceResourceDocument__c>
    * @return List<Interval>
    */
    public static List<Interval> getListInterval(List<XC_ServiceResourceDocument__c> listDocuments) {
        List<Interval> listInterval = new List<Interval>();

        for(XC_ServiceResourceDocument__c document : listDocuments) {
            Interval newInterval = new Interval();
            newInterval.startDate = document.XC_StartDateOfValidity__c;
            newInterval.endDate = document.XC_ExpirationDateOfValidity__c;
            listInterval.add(newInterval);
        }

        return listInterval;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 18/03/2019
    * @description getInsersectionIntervals() – Get intersection of intervals
    * @param intervalsDocumentAnd - List<Interval>
    * @param intervalsDocumentOr - List<Interval>
    * @return resultIntervals - List<Interval> 
    */
    public static List<Interval> getInsersectionIntervals(List<Interval> intervalsDocumentAnd, List<Interval> intervalsDocumentOr) {
        List<Interval> resultIntervals = new List<Interval>();

        if(!intervalsDocumentOr.isEmpty()) {
            for(Interval intervalOR : intervalsDocumentOr) {
                List<Interval> intervalToCheck = new List<Interval>{intervalOR};
                intervalToCheck.addAll(intervalsDocumentAnd);
                IntersectionResult intersection = intervalIntersection(intervalToCheck);
                if(!intersection.isEmpty) {
                    resultIntervals.addAll(intersection.listInterval);
                }
            }
            return resultIntervals;
        }

        return intervalsDocumentAnd;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 19/03/2019
    * @description populateListIntervalForExistingSkill() – Populate a new list of Intervals for updating a existing skill
    * @param existingServiceResourceSkill - List<ServiceResourceSkill>
    * @param interval - Interval
    * @return UnionResult
    */
    public static UnionResult populateListIntervalForExistingSkill(List<ServiceResourceSkill> existingServiceResourceSkill, Interval interval) {
        List<Interval> listInverval = new List<Interval>();
        for(ServiceResourceSkill srs : existingServiceResourceSkill) {
            if(srs.XC_CertificationStartDate__c != null && srs.XC_CertificationEndDate__c != null){
                Interval newInterval = new Interval();
                newInterval.startDate = srs.XC_CertificationStartDate__c;
                newInterval.endDate = srs.XC_CertificationEndDate__c;
                listInverval.add(newInterval); 
            }
        }
        Interval newInterval = new Interval();
        newInterval.startDate = interval.startDate;
        newInterval.endDate = interval.endDate;
        listInverval.add(newInterval);

        List<Interval> listInvervalOrder = orderIntervals(listInverval);
        return intervalUnion(listInvervalOrder);
    }

    
    /** 
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 10/06/2019
     * @description Method to calculate End Date
     * @param skillToAdd - ServiceResourceSkill 
     * @param assignmentEndDate - Date
    */
    private static void calculateEndDate(ServiceResourceSkill skillToAdd, Date assignmentEndDate) { 
        if(assignmentEndDate == null || assignmentEndDate > skillToAdd.XC_CertificationEndDate__c) {
            Date dateAss = skillToAdd.XC_CertificationEndDate__c;
            skillToAdd.EffectiveEndDate = DateTime.newInstance(dateAss.year(), dateAss.month(), dateAss.day());
        } else {
            Date dateAss = assignmentEndDate;
            skillToAdd.EffectiveEndDate = DateTime.newInstance(dateAss.year(), dateAss.month(), dateAss.day());
        } 
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 19/03/2019
    * @description manageIntervalExistingSkill() – To insert a new interval for existing skill or to update an existing skill
    * @param manageWrapper - ManageIntervalExistingSkillWrapper
    * @return ManageExistingSkillWrapper
    */
    public static XC_SC010_PopulateSkillsOnResources_U.ManageExistingSkillWrapper manageIntervalExistingSkill(ManageIntervalExistingSkillWrapper manageWrapper) {
        XC_SC010_PopulateSkillsOnResources_U.ManageExistingSkillWrapper wr = new XC_SC010_PopulateSkillsOnResources_U.ManageExistingSkillWrapper();
        Integer numberIntervalToDelete = 0;

        if(manageWrapper.unionDates.listInterval.size() < manageWrapper.existingServiceResourceSkill.size()) {
            numberIntervalToDelete = manageWrapper.existingServiceResourceSkill.size() - manageWrapper.unionDates.listInterval.size();
        }

        for(Integer i=0;i<numberIntervalToDelete;i++) {
            wr.listSkillToDelete.add(manageWrapper.existingServiceResourceSkill[i]);
            manageWrapper.existingServiceResourceSkill.remove(i);
        }

        Integer riemp = 0;
        Map<String,Id> skillMap = XC_UTIL_Skill.getMapSkills();
        for(Integer i=0; i<manageWrapper.existingServiceResourceSkill.size(); i++) {
            ServiceResourceSkill skillToManage = new ServiceResourceSkill();
            skillToManage.SkillId = skillMap.get(manageWrapper.skillDocAss.XC_SkillName__c);
            skillToManage.ServiceResourceId = manageWrapper.srId;
            //skillToManage.Id = manageWrapper.existingServiceResourceSkill[i].Id;
            skillToManage.SkillLevel = 1;
            skillToManage.XC_CertificationStartDate__c = manageWrapper.unionDates.listInterval[riemp].startDate;
            skillToManage.XC_CertificationEndDate__c = manageWrapper.unionDates.listInterval[riemp].endDate;
            skillToManage.EffectiveStartDate = manageWrapper.unionDates.listInterval[riemp].startDate;
            calculateEndDate(skillToManage, manageWrapper.existingServiceResourceSkill[i].XC_AssignmentEndDate__c);
            //skillToManage.EffectiveEndDate = manageWrapper.unionDates.listInterval[riemp].startDate; 
            wr.listSkillToDelete.add(new ServiceResourceSkill(Id = manageWrapper.existingServiceResourceSkill[i].Id));
            wr.listSkillToInsert.add(skillToManage);
            riemp++;
        }

        Integer i = 0; 
        while(manageWrapper.unionDates.listInterval.size() > riemp) {
            ServiceResourceSkill skillToAdd = new ServiceResourceSkill();
            skillToAdd.SkillId = skillMap.get(manageWrapper.skillDocAss.XC_SkillName__c);
            skillToAdd.ServiceResourceId = manageWrapper.srId;
            skillToAdd.SkillLevel = 1;
            skillToAdd.XC_CertificationStartDate__c = manageWrapper.unionDates.listInterval[i].startDate;
            skillToAdd.XC_CertificationEndDate__c = manageWrapper.unionDates.listInterval[i].endDate;
            skillToAdd.EffectiveStartDate = manageWrapper.unionDates.listInterval[i].startDate;
            skillToAdd.EffectiveEndDate = manageWrapper.unionDates.listInterval[i].endDate;
            wr.listSkillToInsert.add(skillToAdd);
            riemp++;
            i++;
        }

        return wr;
    }
}