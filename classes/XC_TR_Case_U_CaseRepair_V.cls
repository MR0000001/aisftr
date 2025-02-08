/**
 * The Class XC_TR_Case_U_CaseRepair_V.
 *
 * @author Andrea Bravaccino
 * @date Creation 25/7/2019
 * @description Util class for XC_TR_Case_U_CaseRepair
 */
public without sharing class XC_TR_Case_U_CaseRepair_V {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Case_U_CaseRepair_V');
    
    /** @description Wrapper for getNotCoverageAsset method*/
    public class ParameterWrapperNotCoverageAsset {
        public Map<Id,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> assetsCoverage;
        public Map<String, XC_CM_CaseUrgencyManagement__mdt> cmUrgencyManagementMap;
        public String urgentType;
        public String assetName;
        public String assetId;
        public Map<Id, Integer> assetCoverageTotalRepairMapWithId;
        public Map<Id, Integer> assetRemainingRepairsNumberMap;
    }

    /**
    * @description addErrorOnCaseAssetNotCovered
    * @author Andrea Bravaccino | 25/7/2019
    * @param c Case
    * @param notCoverageAsset Set<String> 
    */
    public static void addErrorOnCaseAssetNotCovered(Case c, Set<String> notCoverageAsset){
        String errorMessage;
        List<String> assetListName = new List<String>(notCoverageAsset);
        if (notCoverageAsset.size() > 1) {
            errorMessage = Label.XC_CL_TheseAssetAreNotCovered + ' ';
            errorMessage += String.join(assetListName, ', ');
        }else {
            errorMessage = Label.XC_CL_ThisAsset + ' ' + '[ ' +assetListName.get(0).remove(Label.XC_CL_HasADifferentSLA) + ' ] ' + Label.XC_CL_IsNotCovered;
        }
        c.addError(errorMessage);
    }

    /**
    * @description checkExistAsset
    * @author Andrea Bravaccino | 25/7/2019
    * @param  listNew List<Case>
    * @return List<Case>
    */
   public static List<Case> checkExistAsset(List<Case> listNew){ 
        List<Case> verifiedCase = new List<Case>();
        XC_CM_Case_Type_Setting__mdt repairSettings = retrieveCaseRepairSettings();
        if(repairSettings == null){
            return verifiedCase;
        }
        for (Case c : listNew) {
            if(!XC_UTIL_Case.matchSettings(c, repairSettings)){   /* ESCEP-2056 | Monica Cutillo | 26/8/2019 */ 
                continue;
            }
            if(c.XC_Address__c==null &&
                c.XC_Segment__c=='B2C') {
                c.addError(Label.XC_CL_NoAddressSelected);
                continue;
            }
            //check on segment NA 08012021
            if(!c.XC_AssetAttached__c &&
                c.XC_Segment__c=='B2C') {
                c.addError(Label.XC_CL_NoAssetsAttached);
                continue;
            }
            verifiedCase.add(c);
            
        }
        return verifiedCase;
    }

    /**
    * @description retrieveCaseRepairSettings
    * @author Monica Cutillo | 26/8/2019
    * @return the XC_CM_Case_Type_Setting__mdt or null
    */
    public static XC_CM_Case_Type_Setting__mdt retrieveCaseRepairSettings(){
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_RepairCaseSettingsName});
        return caseSettingsMap.get(Label.XC_CL_RepairCaseSettingsName);
    }

    /**
    * @description populateRootWorkOrder
    * @author Andrea Bravaccino | 25/7/2019
    * @param c Case 
    * @return WorkOrder
    */
    public static WorkOrder populateRootWorkOrder(Case c) {
        WorkOrder wo = new WorkOrder();
        //wo.XC_WorkTypeLabel__c = Label.XC_CL_WorkType_Repair;
        wo.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_Repair;
        wo.Street = c.XC_Address__r.XC_Address__c;
        wo.PostalCode = c.XC_Address__r.XC_PostalCode__c;
        wo.City = c.XC_Address__r.XC_City__c;
        wo.Country = c.XC_Address__r.XC_AddressCountry__c;
        wo.XC_Address__c = c.XC_Address__c;
        wo.CaseId = c.Id;
        wo.XC_HierarchyLevel__c = 0;
        wo.XC_isTree__c = true;
        wo.XC_Urgent_Repair__c = c.XC_Urgent__c;
        wo.XC_Commitment__c = c.XC_WithCommitment__c;
        wo.XC_LegalEntity__c = c.XC_LegalEntity__c;
        wo.XC_StatusReason__c = Label.XC_CL_StatusReason_Pendingassigntechnician;
        wo.XC_CreatedAutomaticallyBySystem__c = true;
        return wo;
    }

    /**
    * @description populateChildWorkOrder
    * @author Andrea Bravaccino | 25/7/2019
    * @param woRoot WorkOrder 
    * @param assetId Id 
    * @return WorkOrder
    */
    public static WorkOrder populateChildWorkOrder(WorkOrder woRoot, Id assetId) {
        WorkOrder wo = new WorkOrder();
        //wo.XC_WorkTypeLabel__c = woRoot.XC_WorkTypeLabel__c;
        wo.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_Repair;
        wo.XC_LegalEntity__c = woRoot.XC_LegalEntity__c;
        wo.Street = woRoot.Street;
        wo.PostalCode = woRoot.PostalCode;
        wo.City = woRoot.City;
        wo.Country = woRoot.Country;
        wo.XC_Address__c = woRoot.XC_Address__c;
        wo.ParentWorkOrderId = woRoot.Id;
        wo.XC_Urgent_Repair__c = woRoot.XC_Urgent_Repair__c;
        wo.XC_Commitment__c = woRoot.XC_Commitment__c;
        wo.AssetId = assetId;
        wo.XC_HierarchyLevel__c = 2;
        wo.XC_StatusReason__c = Label.XC_CL_StatusReason_Pendingassigntechnician;
        wo.XC_CreatedAutomaticallyBySystem__c = true;
        //wo.XC_isTree__c = true;
        return wo;
    }

    /**
    * @description getCmUrgencyManagementMap
    * @author Andrea Bravaccino | 30/7/2019
    * @return Map<String, XC_CM_CaseUrgencyManagement__mdt>
    */
    public static Map<String, XC_CM_CaseUrgencyManagement__mdt> getCmUrgencyManagementMap(){
        Map<String, XC_CM_CaseUrgencyManagement__mdt> cmUrgencyManagementMap = new Map<String, XC_CM_CaseUrgencyManagement__mdt>();
        List<XC_CM_CaseUrgencyManagement__mdt> cmUrgencyManagementList = new List<XC_CM_CaseUrgencyManagement__mdt>([SELECT Id, XC_Country__c, XC_TypeOfRepair__c, XC_SLA__c, XC_HourForEarliestStartTime__c, XC_HourForDueDate__c FROM XC_CM_CaseUrgencyManagement__mdt]);
        for (XC_CM_CaseUrgencyManagement__mdt cm : cmUrgencyManagementList) {
            cmUrgencyManagementMap.put(cm.XC_SLA__c, cm);
        }
        return cmUrgencyManagementMap;
    }

    /**
    * @description this method verifies that the asset has a priority accepted by the case
    * @author Andrea Bravaccino | 30/7/2019
    * @param ac XC_LCC067_RelatedAssetsByAccount_U.AssetCustom 
    * @param cmUrgencyManagementMap Map<String, XC_CM_CaseUrgencyManagement__mdt> 
    * @param urgentType String 
    * @return Boolean
    */
    public static Boolean isCoveredBySLA(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom ac, Map<String, XC_CM_CaseUrgencyManagement__mdt> cmUrgencyManagementMap,  String urgentType){
        Map<String, Integer> priorityMap = new Map<String, Integer>{
            'Urgent' => 1,
            'Commitment' => 2,
            'Non Urgent' => 3
        };
        XC_CM_CaseUrgencyManagement__mdt cm = cmUrgencyManagementMap.get(ac.sla);
        Integer priority = priorityMap.get(urgentType);
        System.debug('@@@cm: ' + cm);
        System.debug('@@@priority: ' + priority);
        System.debug('@@@cmUrgencyManagementMap: ' + cmUrgencyManagementMap);
        return cm != null && priority >= priorityMap.get(cm.XC_TypeOfRepair__c);
    }

    /**
    * @description getNotCoverageAsset
    * @author Andrea Bravaccino | 30/7/2019
    * @param wrapper ParameterWrapperNotCoverageAsset 
    * @return Set<String>
    */
    public static Boolean getNotCoverageAsset(ParameterWrapperNotCoverageAsset wrapper){
        Set<String> notCoverageAsset = new Set<String>();
        Map<Id, Integer> assetCoverageTotalRepairMapWithId = wrapper.assetCoverageTotalRepairMapWithId;
        Map<Id, Integer> assetRemainingRepairsNumberMap = wrapper.assetRemainingRepairsNumberMap;
        Map<Id,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> assetsCoverage = wrapper.assetsCoverage;
        Map<String, XC_CM_CaseUrgencyManagement__mdt> cmUrgencyManagementMap = wrapper.cmUrgencyManagementMap;
        String urgentType = wrapper.urgentType;
        String assetName = wrapper.assetName;
        String assetId = wrapper.assetId;
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> covList = assetsCoverage.get(assetId);
        if (covList == null || ( covList != null && covList.isEmpty()) ){
            return false;
        }
        Boolean foundCoverage = false;
        for (XC_LCC067_RelatedAssetsByAccount_U.AssetCustom ac : covList) {
            if (XC_TR_Case_U_CaseRepair_V.isCoveredBySLA(ac, cmUrgencyManagementMap, urgentType)){
                if(ac.bundleConfiguration != NULL && assetCoverageTotalRepairMapWithId.get(ac.Id) < 0){
                    wrapper.assetName = ac.Id;
                    return true;
                }else if(ac.bundleConfiguration != NULL && assetCoverageTotalRepairMapWithId.get(ac.Id) > 0 && !foundCoverage){
                    wrapper.assetName = ac.Id;
                    foundCoverage = true;
                }else if(assetCoverageTotalRepairMapWithId.get(ac.Id) < 0 && !foundCoverage){
                    wrapper.assetName = ac.Id;
                    foundCoverage = true;
                }else if(assetCoverageTotalRepairMapWithId.get(ac.Id) > 0 && !foundCoverage){
                    wrapper.assetName = ac.Id;
                    foundCoverage = true;
                }
            }
        }
        return foundCoverage;
    }

    /**
    * @description getVerifiedCase
    * @author Andrea Bravaccino | 30/7/2019
    * @param notCoverageAsset Set<String> 
    * @param c Case
    * @return List<Case>
    */
    public static List<Case> getVerifiedCase(Set<String> notCoverageAsset, Case c){
        List<Case> verifiedCase = new List<Case>();
        if (!notCoverageAsset.isEmpty()){ 
            XC_TR_Case_U_CaseRepair_V.addErrorOnCaseAssetNotCovered(c, notCoverageAsset);
        }else {
            verifiedCase.add(c);
        }
        return verifiedCase;
    }

    /**
    * @description getUrgentType
    * @author Andrea Bravaccino | 30/7/2019
    * @param c Case
    * @return String urgentType
    */
    public static String getUrgentType(Case c){
        String urgentType;
        if (c.XC_Urgent__c && !c.XC_WithCommitment__c){
            urgentType = 'Urgent';
        }else if(!c.XC_Urgent__c && c.XC_WithCommitment__c){
            urgentType = 'Commitment';
        }else if(!c.XC_Urgent__c && !c.XC_WithCommitment__c){
            urgentType = 'Non Urgent';
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@urgentType: ' + urgentType);
        return urgentType;
    }

    /**
    * @description get number of repair work order in the last year
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 21/11/2019 
    * @param assetCoverageMap 
    * @param assetCoverageTotalRepairMapWithId 
    * @return Map<Id, Integer> 
    **/
    public static Map<Id, Integer> getAssetRemainingRepairsNumberMap(Map<Id, List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> assetCoverageMap, Map<Id, Integer> assetCoverageTotalRepairMapWithId){
        Map<Id, Integer> assetRepairNumberMap = new Map<Id, Integer>();
        Map<Id, Integer> coverageAssetRepairNumberMap = new Map<Id, Integer>();
        Map<Id, Integer> assetRemainingRepairsNumberMap;

        Map<String, Integer> coverageTotalRepairMap = getCoverageTotalRepairMap(assetCoverageMap);
        
        Set<Id> assetForNumberOfRepair = new Set<Id>();
        Set<Id> setCoverageAssetIdForNumberUsage = new Set<Id>();
        for (Id assetId : assetCoverageMap.keySet()) {
            List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> coverageList = assetCoverageMap.get(assetId);
            for (XC_LCC067_RelatedAssetsByAccount_U.AssetCustom ac : coverageList) {
                Integer numberOfRepairCoverage = coverageTotalRepairMap.get(ac.name);
                coverageAssetRepairNumberMap.put(ac.Id, numberOfRepairCoverage);
                if(numberOfRepairCoverage >= 0){
                    setCoverageAssetIdForNumberUsage.add(ac.id);
                    assetForNumberOfRepair.add(assetId);
                    Integer totalRepair = assetRepairNumberMap.get(assetId);
                    totalRepair = totalRepair != NULL ? totalRepair + numberOfRepairCoverage : numberOfRepairCoverage;
                    assetRepairNumberMap.put(assetId, totalRepair);
                }
            }
            if(!assetRepairNumberMap.containsKey(assetId)){
                assetRepairNumberMap.put(assetId, -1);
                break;
            }
        }

        if(assetForNumberOfRepair.isEmpty()){
            assetCoverageTotalRepairMapWithId.putAll(coverageAssetRepairNumberMap);
            return assetRepairNumberMap;
        }

        Map<Id, Asset> assetMap = new Map<Id, Asset>([SELECT Id, XC_Product_Type__c, 
                                                 (SELECT Id FROM Work_Orders__r WHERE XC_IsCoveredCurrentYear__c = TRUE AND Status = :Label.XC_CL_Completed), 
                                                 (SELECT Id FROM WorkOrders WHERE XC_IsCoveredCurrentYear__c = TRUE AND Status = :Label.XC_CL_Completed AND XC_WorkTypeCategory__c = :Label.XC_CL_WorkType_Repair)
                                                 FROM Asset 
                                                 WHERE Id IN :assetForNumberOfRepair OR Id IN :setCoverageAssetIdForNumberUsage]);
        
        assetCoverageTotalRepairMapWithId.putAll(getIdIntegerMap(assetMap, setCoverageAssetIdForNumberUsage, coverageAssetRepairNumberMap));
        assetRemainingRepairsNumberMap = getIdIntegerMap(assetMap, assetForNumberOfRepair, assetRepairNumberMap);
        return assetRemainingRepairsNumberMap;
    }

    private static Map<Id,Integer> getIdIntegerMap(Map<Id, Asset> assetMap, Set<Id> setAssetIdForNumberUsage, Map<Id, Integer> assetRepairNumberMap){
        Map<Id, Integer> assetRemainingRepairsNumberMap = new Map<Id, Integer>();
        for (Id assetId : setAssetIdForNumberUsage) {
            Asset a = assetMap.get(assetId);
            Integer remainingrepairs;
            if(a.WorkOrders.isEmpty()){
                remainingrepairs = assetRepairNumberMap.get(a.Id);
            }else {
                remainingrepairs = assetRepairNumberMap.get(a.Id) - a.WorkOrders.size();
            }

            remainingrepairs = remainingrepairs < 0 ? 0 : remainingrepairs;
            assetRemainingRepairsNumberMap.put(a.Id, remainingrepairs);
        }
        return assetRemainingRepairsNumberMap;
    }

    private static Map<String, Integer> getCoverageTotalRepairMap(Map<Id, List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> assetCoverageMap){
        Map<String, Integer> coverageTotalRepairMap = new Map<String, Integer>();
        Set<String> coverageAssetNameSet = new Set<String>();
        for (Id assetId : assetCoverageMap.keySet()) {
            List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> wrapperList = assetCoverageMap.get(assetId);
            for (XC_LCC067_RelatedAssetsByAccount_U.AssetCustom wrapper : wrapperList) {
                coverageAssetNameSet.add(wrapper.name);
                coverageTotalRepairMap.put(wrapper.name, -1);
            }
        }

        List<NE__DocumentationCharacterist__c> docCharList = new List<NE__DocumentationCharacterist__c>([SELECT Id, NE__Value__c, LicName__c, NE__Product__r.name 
                                                                                                        FROM NE__DocumentationCharacterist__c 
                                                                                                        WHERE Name ='Reparaciones' AND NE__Product__r.Name IN :coverageAssetNameSet]);

        for (NE__DocumentationCharacterist__c docChar : docCharList) {
            coverageTotalRepairMap.put(docChar.NE__Product__r.Name, Integer.valueOf(docChar.NE__Value__c));
        }
        return coverageTotalRepairMap;
    }
}