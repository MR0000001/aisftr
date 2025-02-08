/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 05/07/2018
* @description XC_UTIL_ServiceResourceSkill – Util class for ServiceResourceSkill
*/

public with sharing class XC_UTIL_ServiceResourceSkill {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_ServiceResourceSkill'); 

    /** @description SkillCheckWrapper */
    public class SkillCheckWrapper {
        public Date startDate;
        public Date endDate;
        public String nameSkill = '';
        public String srsId = '';
        public Decimal skillLevel = 0.0;
        public Boolean isActive = false;
        public String serviceResourceId = '';
        public Date certStartDate;
        public Date certEndDate;
    }  

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Domenico Del Prete - domenico.delprete@nttdata.com
    * @date 05/07/2019
    * @description Method to check active/deactive skill
    * @param listServiceResourceSkill - List<ServiceResourceSkill>
    * @return SkillCheckWrapper 
    */ 
    public static SkillCheckWrapper checkServiceResourceSkill(List<ServiceResourceSkill> listServiceResourceSkill) {  
        SkillCheckWrapper wrapperResult = new SkillCheckWrapper();      
        if(listServiceResourceSkill.size() == 1) { 
            return populateSkillCheckWrapper(listServiceResourceSkill[0]);
        }
   
        List<SkillCheckWrapper> listIntervals = new List<SkillCheckWrapper>();
        for(ServiceResourceSkill srs : listServiceResourceSkill) {
            if(srs.XC_IsSkillActive__c == true) {
                return populateSkillCheckWrapper(srs);
            }
            SkillCheckWrapper myInterval = new SkillCheckWrapper();
            myInterval.startDate = date.newinstance(srs.EffectiveStartDate.year(), srs.EffectiveStartDate.month(), srs.EffectiveStartDate.day());
            myInterval.endDate = date.newinstance(srs.EffectiveEndDate.year(), srs.EffectiveEndDate.month(), srs.EffectiveEndDate.day());
            myInterval.nameSkill = srs.Skill.MasterLabel;
            myInterval.srsId = srs.Id;
            myInterval.skillLevel = srs.SkillLevel;
            myInterval.certStartDate = srs.XC_CertificationStartDate__c;
            myInterval.certEndDate = srs.XC_CertificationEndDate__c;
            listIntervals.add(myInterval);
        }

        orderServiceResourceSkill(listIntervals);
        if(Date.today() < listIntervals[0].startDate) {
            return listIntervals[0];
        }
        for(Integer i=1; i<listIntervals.size(); i++) {
            if(Date.today() > listIntervals[i-1].endDate && Date.today() < listIntervals[i].startDate) {
                return listIntervals[i];
            }
        }  
        if(Date.today() > listIntervals[listIntervals.size()-1].startDate) {
            return listIntervals[listIntervals.size()-1];
        }


        return wrapperResult;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 08/07/2019
    * @description Method to populate SkillCheckWrapper
    * @param srs - ServiceResourceSkill
    * @return SkillCheckWrapper
    */ 
    private static SkillCheckWrapper populateSkillCheckWrapper(ServiceResourceSkill srs) {
        System.debug('@@@@ ---> ' + srs.EffectiveEndDate);
        SkillCheckWrapper wrapperResult = new SkillCheckWrapper();
        wrapperResult.nameSkill = String.isBlank(srs.Skill.MasterLabel) ? '-' : srs.Skill.MasterLabel;
        wrapperResult.startDate = String.isBlank(string.ValueOf(srs.EffectiveStartDate)) ? null : date.newinstance(srs.EffectiveStartDate.year(), srs.EffectiveStartDate.month(), srs.EffectiveStartDate.day());
        wrapperResult.endDate = String.isBlank(string.ValueOf(srs.EffectiveEndDate)) ? null : date.newinstance(srs.EffectiveEndDate.year(), srs.EffectiveEndDate.month(), srs.EffectiveEndDate.day());
        wrapperResult.srsId = srs.Id;
        wrapperResult.skillLevel = srs.SkillLevel;
        wrapperResult.isActive = srs.XC_IsSkillActive__c;
        wrapperResult.certStartDate = srs.XC_CertificationStartDate__c;
        wrapperResult.certEndDate = srs.XC_CertificationEndDate__c;
        wrapperResult.serviceResourceId = srs.ServiceResourceId;
        return wrapperResult;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Valeria Martino - valeria.martino@nttdata.com
    * @date 08/07/2019
    * @description Method to order intervals
    * @param listIntervals - List<SkillCheckWrapper>
    */ 
    private static void orderServiceResourceSkill(List<SkillCheckWrapper> listIntervals) {
        SkillCheckWrapper temp = new SkillCheckWrapper();
        Boolean swapped = false;
        do {
            swapped = false;
            for(Integer i=0; i<(listIntervals.size()-1); i++) {
                if(listIntervals[i].startDate > listIntervals[i+1].startDate) {
                    temp = listIntervals[i];
                    listIntervals[i] = listIntervals[i+1];
                    listIntervals[i+1] = temp;
                    swapped = true;
                }
            }
        } while(swapped==true);
    }

}