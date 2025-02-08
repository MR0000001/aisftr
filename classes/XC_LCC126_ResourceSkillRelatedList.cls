/**
* @author Roberta Cossiga rcossiga@deloitte.it || Emanuela Cacace ecacace@deloitte.it || Federico Amici federico.amici@nttdata.com
* @date Creation 04/07/2019
* @date Modification 29/04/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description  XC_TR_WorkOrderLineItem_U_CloseWOLI
*/
public without sharing class XC_LCC126_ResourceSkillRelatedList {

    /** @description ResultWrapper */
    public class ResultWrapper {
        @AuraEnabled
    	public List<WrapperServiceResourceSkill> listWrapperSrS = new List<WrapperServiceResourceSkill>();
        @AuraEnabled
    	public Boolean isCommunity = false;
    }

    /** @description the wrapper returned to the component */
    public class WrapperServiceResourceSkill {
        @AuraEnabled
    	public String name = '';
        @AuraEnabled
    	public Decimal skillLevel;
		@AuraEnabled
    	public DateTime startDate;
        @AuraEnabled
        public DateTime endDate;
		@AuraEnabled
    	public Date certStartDate;
        @AuraEnabled
        public Date certEndDate;
        @AuraEnabled
        public String sRsId;
    }

    @AuraEnabled
    /**
    * @author Roberta Cossiga rcossiga@deloitte.it || Emanuela Cacace ecacace@deloitte.it || Federico Amici federico.amici@nttdata.com
    * @date Creation 04/07/2019
    * @date Modification dd/mm/yyyy
    * @param recordId the service resource id
    * @description  retrieves data for the component
    * @return the json string
    */
    public static String retrieveData(String recordId){
        ResultWrapper outputWrapper = new ResultWrapper();

        // For listWrapperSrS:
        Map<String, List<ServiceResourceSkill>> mapServiceResourceMasterLabel = new Map<String, List<ServiceResourceSkill>>();
        Map<Id, ServiceResourceSkill> mapServiceResourceSkill = 
            new Map<Id, ServiceResourceSkill>([SELECT Id, XC_CertificationEndDate__c, XC_CertificationStartDate__c, Skill.MasterLabel, SkillLevel, EffectiveStartDate, EffectiveEndDate, XC_IsSkillActive__c, ServiceResourceId
                                                   FROM ServiceResourceSkill
                                                   WHERE ServiceResourceId =: recordId]);
        List<ServiceResourceSkill> listServiceResourceSkill = mapServiceResourceSkill.values();
        for (ServiceResourceSkill sRs : listServiceResourceSkill){
            if (!mapServiceResourceMasterLabel.containskey(sRs.Skill.MasterLabel)){
                mapServiceResourceMasterLabel.put(sRs.Skill.MasterLabel, new List<ServiceResourceSkill>());
            }
            mapServiceResourceMasterLabel.get(sRs.Skill.MasterLabel).add(sRs);
        }
        for(String masterLabel : mapServiceResourceMasterLabel.keySet()){    
            XC_UTIL_ServiceResourceSkill.SkillCheckWrapper wrapperDuplicate = XC_UTIL_ServiceResourceSkill.checkServiceResourceSkill(mapServiceResourceMasterLabel.get(masterLabel));
            WrapperServiceResourceSkill wrapperSrS = new WrapperServiceResourceSkill();
            wrapperSrS.name = wrapperDuplicate.nameSkill;
            wrapperSrS.skillLevel = wrapperDuplicate.skillLevel;
            wrapperSrS.startDate = wrapperDuplicate.startDate;
            wrapperSrS.endDate = wrapperDuplicate.endDate;
            wrapperSrS.certStartDate = wrapperDuplicate.certStartDate;
            wrapperSrS.certEndDate = wrapperDuplicate.certEndDate;
            wrapperSrS.sRsId = wrapperDuplicate.srsId;
            outputWrapper.listWrapperSrS.add(wrapperSrS);               
        }

        // For isCommunity:
        String idUser = UserInfo.getUserId();
        List<User> user = new List<User>([SELECT Account.isPartner FROM User WHERE Id = :idUser]);
        outputWrapper.isCommunity = user[0].Account.isPartner;
        return JSON.serialize(outputWrapper);
    }
    
    @AuraEnabled 
    /**
    * @author Roberta Cossiga rcossiga@deloitte.it || Emanuela Cacace ecacace@deloitte.it || Federico Amici federico.amici@nttdata.com
    * @date Creation 04/07/2019
    * @date Modification dd/mm/yyyy
    * @param jsonUpdate the json containing data to be updated
    * @description  retrieves data for the component
    * @return the json result 
    */
    public static String callToUpdate(String jsonUpdate){
        System.debug('??->json'+ jsonUpdate);
        List<WrapperServiceResourceSkill> listWrapperSRSkill = 
            (List<WrapperServiceResourceSkill>)JSON.deserialize(jsonUpdate, List<WrapperServiceResourceSkill>.class);
        
        Boolean startDateUpdated;
        Boolean endDateUpdated;
        ServiceResourceSkill srSkill;
        List<ServiceResourceSkill> listSRSkill = new List<ServiceResourceSkill>();

        for(WrapperServiceResourceSkill wr : listWrapperSRSkill) {
            startDateUpdated = false;
            endDateUpdated = false;

            srSkill = new ServiceResourceSkill(Id = wr.sRsId);
            if(wr.endDate != null && wr.endDate <= wr.certEndDate) {
                srSkill.EffectiveEndDate = wr.endDate;
                startDateUpdated = true;
            }else{
                XC_UTIL_SObject.WrapperResult wrapp = new XC_UTIL_SObject.WrapperResult();
                wrapp.success = false;
                wrapp.errorMessage = 'End Date must be lass than or equal to Certification End Date';
                return JSON.serialize(wrapp);
            }
            if(wr.startDate != null) {
                srSkill.EffectiveStartDate = wr.startDate;
                endDateUpdated = true;
            }

            if(startDateUpdated || endDateUpdated) {
                listSRSkill.add(srSkill);
            }
        }
        
        List<XC_UTIL_SObject.WrapperResult> listWr = new List<XC_UTIL_SObject.WrapperResult>();
        XC_UTIL_SObject.WrapperResult wrapToReturn = new XC_UTIL_SObject.WrapperResult();
        if(!listSRSkill.isEmpty()) {
            listWr = XC_UTIL_SObject.updateListRecords(listSRSkill);
        }
        for(XC_UTIL_SObject.WrapperResult wrap : listWr){
            if(wrap.success == false){
                wrapToReturn = wrap;
            }
        }

        return JSON.serialize(wrapToReturn);
    }

        @AuraEnabled 
    /**
    * @author Roberta Cossiga rcossiga@deloitte.it || Emanuela Cacace ecacace@deloitte.it || Federico Amici federico.amici@nttdata.com
    * @date Creation 05/07/2019
    * @date Modification dd/mm/yyyy
    * @param mapResourcesSkills map o Service Resources Skill Field
    * @description  retrieves data for the component
    * @return the XC_UTIL_ResultWrapper wrapper
    */
    public static XC_UTIL_ResultWrapper saveServiceResourceSkill(String mapResourcesSkills){
        Map<String,Object> mapServiceResourceSkill = (Map<String, Object>) JSON.deserializeUntyped(mapResourcesSkills);
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper(); 
        ServiceResourceSkill sRs = new ServiceResourceSkill();
        String skillLevelString = (String) (mapServiceResourceSkill.get('skillLevel'));
        String assignmentStartDateString = (String) (mapServiceResourceSkill.get('assignmentStartDate'));
        String assignmentEndDateString = (String) (mapServiceResourceSkill.get('assignmentEndDate'));
        sRs.ServiceResourceId = (String) (mapServiceResourceSkill.get('recordId'));
        sRs.SkillId = (String) mapServiceResourceSkill.get('skillId');
        sRs.SkillLevel = Decimal.valueOf(skillLevelString);
        sRs.XC_AssignmentStartDate__c = Date.valueOf(assignmentStartDateString);
        sRs.XC_AssignmentEndDate__c = Date.valueOf(assignmentEndDateString);
        srs.EffectiveStartDate = sRs.XC_AssignmentStartDate__c;
       	XC_UTIL_Sobject.WrapperResult sobjectResult = XC_UTIL_Sobject.insertRecord(sRs);
        if(sobjectResult.success == true){
            wr.success = true;
            wr.resultMessage = Label.XC_CL_Success;
            wr.recordId = sobjectResult.recordId;
        } else{ 
            wr.resultMessage = sobjectResult.errorMessage;
            wr.success = false;  
        }
        return wr;
    }  
        
}