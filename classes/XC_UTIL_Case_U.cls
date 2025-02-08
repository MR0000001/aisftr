/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 18/04/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_Case_U –- Util class XC_UTIL_Case
*/
public without sharing class XC_UTIL_Case_U {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Case');

    /** @description Wrapper for create Administrative Case */
    public class AdministrativeCaseWrapper {
        public Map<Id, List<String>> mapConfItemComplianceMaster = new Map<Id, List<String>>();
        public Map<String, Id> mapQueueId = new Map<String, Id>();
        public Map<Id, XC_UTIL_ComplianceMaster.ComplianceWrapperResult> mapConfItemComplianceWrapper = new Map<Id, XC_UTIL_ComplianceMaster.ComplianceWrapperResult>();
        public Map<Id, NE__OrderItem__c> orderItemMap = new Map<Id, NE__OrderItem__c>();
        public XC_ComplianceMaster__c complianceMaster = new XC_ComplianceMaster__c();
    }

    /** @description PopulateCaseWrapper */
    public class PopulateCaseWrapper {
        public Case c;
        public XC_UTIL_Case.CaseRESTWrapper wrapper;
        public String accountID;
        public String contactID;
    }

    /** @description Wrapper for Update Case */
    public class UpdateCaseWrapper {
        public Boolean closeWO = false;
        public Boolean closeT = false;
        public Boolean closeC = false;
        public Boolean closeO = false;
        public Boolean closeConf = false;
        public Boolean parentCaseArePending = false;
        public Case c;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Create Administrative Case
     * @param wrapper - AdministrativeCaseWrapper
     * @return caseToInsertList - List<Case>
    **/
    public static List<Case> createAdministrativeCase(AdministrativeCaseWrapper wrapper) {
        List<Case> caseToInsertList = new List<Case>();
        List<String> complianceTypesInvolvedList = new List<String>();
        for(String ordItemId : wrapper.mapConfItemComplianceWrapper.keySet()){
            complianceTypesInvolvedList.add(wrapper.mapConfItemComplianceWrapper.get(ordItemId).complianceType);
        }
        List<String> caseSettingNames = new List<String>{Label.XC_CL_Compliance_1, Label.XC_CL_Compliance_2, Label.XC_CL_Compliance_3, Label.XC_CL_Compliance_4, Label.XC_CL_Compliance_5};
        //Map<String, XC_CM_CaseMapping__mdt> caseMapping = getCaseMapping(complianceTypesInvolvedList);
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
        for(String ordItemId : wrapper.mapConfItemComplianceWrapper.keySet()){
            Boolean needBreak = false;
            Case caseToCreate = new Case();
            if(wrapper.mapConfItemComplianceWrapper.get(ordItemId).check){
                if(!wrapper.orderItemMap.isEmpty() ){
                    caseToCreate.contactid = wrapper.orderItemMap.get(ordItemId).NE__OrderId__r.NE__OptyId__r.XC_Contact__c;
                } 
                XC_UTIL_Case_U_CreateCase.UtilityWrapper utilWrapper = new XC_UTIL_Case_U_CreateCase.UtilityWrapper();
                utilWrapper.administrativeCaseWrapper = wrapper;
                utilWrapper.caseToCreate = caseToCreate;
                utilWrapper.caseSettingsMap = caseSettingsMap;
                utilWrapper.ordItemId = ordItemId;
                XC_UTIL_Case_U_CreateCase.populateReasonAndSubCause(utilWrapper);
                caseToCreate.XC_LegalEntity__c = wrapper.orderItemMap.get(ordItemId).NE__OrderId__r.XC_LegalEntity__c;
                caseToCreate.XC_Order__c = wrapper.orderItemMap.get(ordItemId).NE__OrderId__c;
                caseToCreate.Type = Label.XC_CL_ComplianceVerification;  
                caseToCreate.XC_ComplianceMaster__c = wrapper.mapConfItemComplianceWrapper.get(ordItemId).complianceMaster.Id;
                //caseToCreate.Origin = Label.XC_CL_CaseOriginCAN002;
                if(wrapper.mapQueueId.containsKey(wrapper.mapConfItemComplianceWrapper.get(ordItemId).queue)){
                    caseToCreate.OwnerId = wrapper.mapQueueId.get(wrapper.mapConfItemComplianceWrapper.get(ordItemId).queue);
                }
                if(checkComplianceType(wrapper, ordItemId)){
                    caseToCreate.XC_OrderItem__c  = ordItemId;
                     needBreak = true;
                }else if (wrapper.mapConfItemComplianceWrapper.get(ordItemId).complianceType.equals(Label.XC_CL_Compliance_Reason_C1)){
                    needBreak = true;
                }
                                 
            }
            caseToInsertList.add(caseToCreate);
            if(needBreak){
                break;
            }
        } 
        
        for(Case caseApp : caseToInsertList){
           List<String> tempSubject = XC_UTIL_Case_U_Check.retrieveListNeededDocuments(wrapper);
           caseApp.Subject = Label.XC_CL_Case_ListDocument + ' ' + String.join(tempSubject,', ');
        }   
        return caseToInsertList;
    }
    
    /**
    * @description Populate case
    * @param populateCaseWrapper - PopulateCaseWrapper
    **/
    public static void populateCase(PopulateCaseWrapper populateCaseWrapper) {
        if(String.isNotBlank(populateCaseWrapper.wrapper.WorkOrderID)) {
            populateCaseWrapper.c.XC_WorkOrder__c = populateCaseWrapper.wrapper.WorkOrderID;
        }
        if(String.isNotBlank(populateCaseWrapper.wrapper.ParentCaseID)) {
            populateCaseWrapper.c.ParentId = populateCaseWrapper.wrapper.ParentCaseID;
        }
        if(String.isNotBlank(populateCaseWrapper.wrapper.OpportunityID)) {
            populateCaseWrapper.c.XC_Opportunity__c = populateCaseWrapper.wrapper.OpportunityID;
        }
        if(String.isNotBlank(populateCaseWrapper.wrapper.OrderID)) { 
            populateCaseWrapper.c.XC_Order__c = populateCaseWrapper.wrapper.OrderID;
        }
        if(String.isNotBlank(populateCaseWrapper.wrapper.OrderItemID)) { 
            populateCaseWrapper.c.XC_OrderItem__c = populateCaseWrapper.wrapper.OrderItemID;
        }
        if(String.isNotBlank(populateCaseWrapper.wrapper.AssetID)){
           populateCaseWrapper.c.AssetId = populateCaseWrapper.wrapper.AssetID;
        }
        // if(String.isNotBlank(populateCaseWrapper.wrapper.AddressID)){
        //    populateCaseWrapper.c.NotificationAddressPE__c = populateCaseWrapper.wrapper.AddressID;
        // }
        
        populateCaseIDs(populateCaseWrapper);
    }

    /**
    * @description Populate case (for cyclomatic complecity warning)
    * @param populateCaseWrapper - PopulateCaseWrapper
    **/
    private static void populateCaseIDs(PopulateCaseWrapper populateCaseWrapper) {
        /*if(String.isNotBlank(populateCaseWrapper.wrapper.ContractID)){
           populateCaseWrapper.c.NotificationAddressPE__c = populateCaseWrapper.wrapper.ContractID;
        }*/
        if(String.isNotBlank(populateCaseWrapper.accountID)){
            populateCaseWrapper.c.AccountId = populateCaseWrapper.accountID;
        }
        if(String.isNotBlank(populateCaseWrapper.contactID)){
            populateCaseWrapper.c.ContactId = populateCaseWrapper.contactID;
        }
        // For PUT method
        if(String.isNotBlank(populateCaseWrapper.wrapper.Owner)) {
            populateCaseWrapper.c.OwnerId = populateCaseWrapper.wrapper.Owner;
        }
    }

    /**
    * @description Populate Case to update it
    * @param wrapper - UpdateCaseWrapper
    **/
    public static void populateCaseToUpdate(UpdateCaseWrapper wrapper) {
        if(!wrapper.closeWO && !wrapper.closeConf && !wrapper.closeC && !wrapper.closeO ){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'metto in canceled questo :' +wrapper.c.id);
            wrapper.c.Status = Label.XC_CL_Case_Status008; //'CNT0009';
        }                
        else{
            wrapper.c.Status = Label.XC_CL_Case_Status007;
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'metto in chiuso questo :' +wrapper.c.id);
        }
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @description retrive record from XC_CM_CaseMapping__mdt by a Case List in input
     * @param caseList - List<Case>
     * @return Map<String, XC_CM_CaseMapping__mdt> with all possible record associated, 
     *          depending of caseReason, subcause and subType. A key is build with its concatenation.
     */
    public static Map<String, XC_CM_CaseMapping__mdt> retriveCaseMappingMtdFromCases(List<Case> caseList){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ retriveCaseMappingMtdFromCases From Cases='+caseList);
        Set<String> caseReasonValueSet = new Set<String>();
        Set<String> subcauseValueSet = new Set<String>();
        Set<String> subTypeValueSet = new Set<String>();
        
        for(Case caseObj: caseList){
            caseReasonValueSet.add(caseObj.Reason);
            subcauseValueSet.add(caseObj.Subcause__c);
            if(caseObj.XC_Subtype__c != null){
                subTypeValueSet.add(caseObj.XC_Subtype__c);
            }
        }

        if(!Schema.sObjectType.XC_CM_CaseMapping__mdt.isAccessible()){
            return new Map<String, XC_CM_CaseMapping__mdt>();
        }
        List<XC_CM_CaseMapping__mdt> caseTypeSettingsMtd = [
            SELECT Id, XC_CaseReason__c, XC_SubCause__c, XC_SubType__c, XC_ActionPlanTemplate__c
              FROM XC_CM_CaseMapping__mdt 
             WHERE XC_CaseReason__c IN: caseReasonValueSet
               AND XC_SubCause__c IN: subcauseValueSet
               AND ( XC_SubType__c IN: subTypeValueSet OR  XC_SubType__c = NULL )
        ];
        
        Map<String,XC_CM_CaseMapping__mdt> mappingResult = new Map<String,XC_CM_CaseMapping__mdt>();
        String mtdKey = '';
        for(XC_CM_CaseMapping__mdt mtd : caseTypeSettingsMtd){
            mtdKey = mtd.XC_CaseReason__c +'_'+ mtd.XC_SubCause__c;
            mtdKey = (mtd.XC_SubType__c != null) ? mtdKey +'_'+ mtd.XC_SubType__c : mtdKey;
            mappingResult.put(mtdKey, mtd);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ retriveCaseMappingMtdFromCases From Cases result='+mappingResult);
        return mappingResult;
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @description retrive record from XC_CM_Case_ESPAttentionTypes__mdt by a Case List in input
     * @param caseList - List<Case>
     * @return Map<String, XC_CM_Case_ESPAttentionTypes__mdt> with all possible record associated, 
     *          depending of caseReason, subcause and subType. A key is build with its concatenation.
     */
    public static Map<String, XC_CM_Case_ESPAttentionTypes__mdt> retriveCaseESPAttentionTypesFromCases(List<Case> caseList){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ retriveCaseESPAttentionTypes From Cases='+caseList);
        Set<String> caseReasonValueSet = new Set<String>();
        Set<String> subcauseValueSet = new Set<String>();
        Set<String> subTypeValueSet = new Set<String>();
        Set<String> legalEntitySet = new Set<String>();
		Set<String> streamValueSet = new Set<String>();
        for(Case caseObj: caseList){
            caseReasonValueSet.add(caseObj.Reason);
            subcauseValueSet.add(caseObj.Subcause__c);
			if(caseObj.XC_Segment__c != null){
                streamValueSet.add(caseObj.XC_Segment__c);
            }
            if(caseObj.XC_Subtype__c != null){
                subTypeValueSet.add(caseObj.XC_Subtype__c);
            }
            legalEntitySet.add(caseObj.XC_LegalEntity__c);

        }

        if(!Schema.sObjectType.XC_CM_Case_ESPAttentionTypes__mdt.isAccessible()){
            return new Map<String, XC_CM_Case_ESPAttentionTypes__mdt>();
        }
        List<XC_CM_Case_ESPAttentionTypes__mdt> caseTypeSettingsMtd = [
           // SELECT Id, XC_Case_Reason__c, XC_Sub_Cause__c, XC_Sub_Type__c, XC_SLAProcess__c,XC_LegalEntity__c
			SELECT Id, XC_Case_Reason__c, XC_Sub_Cause__c, XC_Sub_Type__c, XC_SLAProcess__c,XC_LegalEntity__c, XC_Stream__c, XC_AccountSLA__c //vdb added XC_AccountSLA__c CR760
              FROM XC_CM_Case_ESPAttentionTypes__mdt 
             WHERE XC_Case_Reason__c IN: caseReasonValueSet
               AND XC_Sub_Cause__c IN: subcauseValueSet
               AND ( XC_Sub_Type__c IN: subTypeValueSet OR  XC_Sub_Type__c = NULL )
               AND (XC_LegalEntity__c IN: legalEntitySet OR XC_LegalEntity__c = NULL)
			   AND (XC_Stream__c IN: streamValueSet )
        ];
        
        Map<String,XC_CM_Case_ESPAttentionTypes__mdt> settingsMap = new Map<String,XC_CM_Case_ESPAttentionTypes__mdt>();
        String mtdKey = '';
        for(XC_CM_Case_ESPAttentionTypes__mdt mtd : caseTypeSettingsMtd){
            mtdKey = mtd.XC_Case_Reason__c +'_'+ mtd.XC_Sub_Cause__c;
            mtdKey = (mtd.XC_Sub_Type__c != NULL) ? mtdKey +'_'+ mtd.XC_Sub_Type__c : mtdKey;
            mtdKey = (mtd.XC_LegalEntity__c != NULL) ? mtdKey +'_'+ mtd.XC_LegalEntity__c : mtdKey;
			mtdKey = (mtd.XC_LegalEntity__c != NULL) ? mtdKey +'_'+ mtd.XC_Stream__c : mtdKey;
            settingsMap.put(mtdKey, mtd);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ retriveCaseESPAttentionTypes From Cases result='+settingsMap);
        return settingsMap;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description getCaseRemarksByLegalEntity
     * @param caseSettings
     * @param legalEntity
     * @return CaseRemarks value
     */
    public static String getCaseRemarksByLegalEntity(XC_CM_Case_Type_Setting__mdt caseSettings, String legalEntity){
        return getCaseRemarksByLegalEntity(caseSettings, legalEntity, new Map<String,String>());
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description getCaseRemarksByLegalEntity
     * @param caseSettings
     * @param legalEntity
     * @param labelParameters
     * @return CaseRemarks value
     */
    public static String getCaseRemarksByLegalEntity(XC_CM_Case_Type_Setting__mdt caseSettings, String legalEntity, Map<String,String> labelParameters){
        String caseRemResValue = '';
        if(caseSettings == null){
            return '';
        }
        
        //STEP 1: search the right field from metadata
        String caseRemByLEFieldName = 'XC_CaseRemarks'+ legalEntity + '__c';
        Set<String> objectFields = Schema.SObjectType.XC_CM_Case_Type_Setting__mdt.fields.getMap().keySet();

        if(!objectFields.contains(caseRemByLEFieldName.toLowerCase())){
            caseRemResValue = caseSettings.XC_CaseRemarks__c;
        } else {
            caseRemResValue = (String)caseSettings.get(caseRemByLEFieldName.toLowerCase());
        }
        if(String.isBlank(caseRemResValue)){
            return '';
        }

        //STEP 2: replace parameters
        if(labelParameters == null || labelParameters.isEmpty()){
            return caseRemResValue;
        }
        for(String paramKey : labelParameters.keySet()){
            if(String.isNotBlank(labelParameters.get(paramKey))){
                caseRemResValue = caseRemResValue.replace(paramKey, labelParameters.get(paramKey));
            }
        }

        return caseRemResValue;
    }


      /**
     * @author Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
     * @description getCaseRemarksClosureByLegalEntity for XC_CM_CaseClosureDependencies__mdt 
     * @param caseClosureDep
     * @param legalEntity
     * @return CaseRemarks value
     */
    public static String getCaseRemarksClosureByLegalEntity(XC_CM_CaseClosureDependencies__mdt  caseClosureDep, String legalEntity){
        String caseRemResValue = '';
        if(caseClosureDep == null){
            return '';
        }
        
        String caseRemByLEFieldName = 'XC_CaseRemarks'+ legalEntity + '__c';
        Set<String> objectFields = Schema.SObjectType.XC_CM_CaseClosureDependencies__mdt.fields.getMap().keySet();

        if(!objectFields.contains(caseRemByLEFieldName.toLowerCase())){
            caseRemResValue = caseClosureDep.XC_CaseRemarks__c;
        } else {
            caseRemResValue = (String)caseClosureDep.get(caseRemByLEFieldName.toLowerCase());
        }
        if(String.isBlank(caseRemResValue)){
            return '';
        }

        return caseRemResValue;
    }


    private static Boolean checkComplianceType(AdministrativeCaseWrapper wrapper, String ordItemId){
        return (wrapper.mapConfItemComplianceWrapper.get(ordItemId).complianceType.equals(Label.XC_CL_Compliance_Reason_C2)
                || wrapper.mapConfItemComplianceWrapper.get(ordItemId).complianceType.equals(Label.XC_CL_Compliance_Reason_C3)
                || wrapper.mapConfItemComplianceWrapper.get(ordItemId).complianceType.equals(Label.XC_CL_Compliance_Reason_C4));
    }
}