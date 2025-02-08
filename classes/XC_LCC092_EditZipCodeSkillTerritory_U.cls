/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date 07/05/2019
 * @description XC_LCC092_EditZipCodeSkillTerritory_U - Util class for XC_LCC092_EditZipCodeSkillTerritory
 */

public without sharing class XC_LCC092_EditZipCodeSkillTerritory_U {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC092_EditZipCodeSkillTerritory');
    
    /** @description ChangeZipCodeSkillWrapper */
    public class ChangeZipCodeSkillWrapper {
        public List<String> skillChanged = new List<String>();
        public String zipCode = '';
        public String province = '';
        public String servTerr = '';
    }

    /** @description ZipCodeSkillTerrWrapper */
    public class ZipCodeSkillTerrWrapper {
        public XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        public String recordId = '';
        public String skillList = '';
        public String skillId = '';
        public String zipCode = '';
        public String province = '';
    }
    
    /**
     * @description Populate ResultWrapper for ZipCode SkillTerritory
     * @modify 07/05/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param populateWrapper - ZipCodeSkillTerrWrapper
     * @return XC_UTIL_ResultWrapper
     */
    public static XC_UTIL_ResultWrapper populateResultWrapper(ZipCodeSkillTerrWrapper populateWrapper) {
        if(populateWrapper.recordId!=null){ 
            XC_ZipCodeSkill_TerritoryAssociation__c zc = XC_LCC092_EditZipCodeSkillTerritory.setZipCodeValues(populateWrapper.recordId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@XC_ListOfSkillNames__c' + zc.XC_ListOfSkillNames__c + ' - skillList' + populateWrapper.skillList);
            List<String>  skillChanged = XC_LCC092_EditZipCodeSkillTerritory.checkSkillChanged(zc.XC_ListOfSkillNames__c,  populateWrapper.skillList );
            zc.XC_ListOfSkillNames__c = populateWrapper.skillList;
            System.debug('@@@zc.XC_ListOfSkillNames__c-->' +zc.XC_ListOfSkillNames__c);
            zc.XC_ListOfSkills__c = populateWrapper.skillId;
            zc.XC_ZipCode__c = populateWrapper.zipCode;
            zc.XC_Province__c = populateWrapper.province;
            XC_UTIL_Sobject.WrapperResult sobjectResult = XC_UTIL_Sobject.updateRecord(zc);
             
            if(!skillChanged.isEmpty()){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@skillChanged' + skillChanged);  
                ChangeZipCodeSkillWrapper changeWrapper = new ChangeZipCodeSkillWrapper();
                changeWrapper.skillChanged = skillChanged;
                changeWrapper.zipCode = zc.XC_ZipCode__c;
                changeWrapper.province = zc.XC_Province__c;
                changeWrapper.servTerr = zc.XC_ServiceTerritoryId__c;
                updateZipCodeSkillChanged(changeWrapper);
            }
            populateWrapper.rw = new XC_UTIL_ResultWrapper(sobjectResult); 
        }
        return populateWrapper.rw;
    }
    
    /**
     * @description Sets the zip code values
     * @param changeWrapper - ChangeZipCodeSkillWrapper
     */
    public static void updateZipCodeSkillChanged(ChangeZipCodeSkillWrapper changeWrapper) {
    	Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c> zipcodeterritoryMap = new Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c>([SELECT Id, XC_Province__c ,XC_ZipCode__c,XC_ListOfSkillNames__c ,XC_ServiceTerritoryId__c
                                                                                                                                    FROM XC_ZipCodeSkill_TerritoryAssociation__c
                                                                                                                                    WHERE XC_ZipCode__c =: changeWrapper.zipCode 
                                                                                                                                    AND XC_Province__c =: changeWrapper.province
                                                                                                                                    AND XC_ServiceTerritoryId__r.TopLevelTerritoryId =: changeWrapper.servTerr
                                                                                                                                    AND XC_ServiceTerritoryId__r.ParentTerritoryId  != null]);
        List<XC_ZipCodeSkill_TerritoryAssociation__c> zipcodeterritory = zipcodeterritoryMap.values();
        
	    Map<String,Id> skList = XC_UTIL_Skill.getMapSkills() ;       
        for(XC_ZipCodeSkill_TerritoryAssociation__c zc : zipcodeterritory){
            List<String> newSkillNames = new List<String>();
            List<String> newSkillId = new List<String>();
            List<String> zcSkillNames = zc.XC_ListOfSkillNames__c.split(';');
            for(String zcSkill : zcSkillNames){
            	for(String skillName : changeWrapper.skillChanged){
             		if(skillName != zcSkill){
                    	newSkillId.add(skList.get(zcSkill));
                        newSkillNames.add(zcSkill);
               		}
                }
            }
            zc.XC_ListOfSkillNames__c = String.join(newSkillNames , ';');
            zc.XC_ListOfSkills__c = String.join(newSkillId , ';'); 
        }    
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@CIao ciao figli' + zipcodeterritory);
        XC_UTIL_Sobject.updateListRecords(zipcodeterritory);
    }

}