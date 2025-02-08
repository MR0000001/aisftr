/**
 * The Class XC_TR_Case_U_CaseRepair.
 *
 * @author Simone Trenta - strenta@deloitte.it
 * @date Creation 08/03/2019
 * @description 
 */
public without sharing class XC_TR_Case_U_CaseRepair {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Case_U_CaseRepair');

    /** @description Wrapper */
    public class PopulateParameterWrapper{
        public List<Asset> assetList;
        public Set<String> notCoverageAsset = new Set<String>();
        public Set<Id> notCoverageAssetId = new Set<Id>();
		public Map<Id,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> getAssetsCoverage;
		public String urgentType;
		public Map<String, XC_CM_CaseUrgencyManagement__mdt> cmUrgencyManagementMap;
        public Map<Id, Integer> assetCoverageTotalRepairMapWithId;
        public Map<Id, Integer> assetRemainingRepairsNumberMap;
    }

    /**
     * @description filterCaseRepair
     * @param caseList caseList
     * @param conf metadata XC_CM_Case_Repair_Configuration__mdt list
     * @return validation Cases
     */
    private static List<Case> filterCaseRepair(List<Case> caseList, List<XC_CM_Case_Repair_Configuration__mdt> conf) {
        List<Case> validationCases = new List<Case>();
        for (case c : caseList) {
            for (XC_CM_Case_Repair_Configuration__mdt mdt : conf) {
                if (checkCondition(c, mdt)) {
                    validationCases.add(c);
                }
                
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'filterCaseRepair result = '+validationCases);
        return validationCases;
    }

    /**
    * @description method to create work order for repair
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 25/9/2019 
    * @param caseList 
    * @return XC_UTIL_Sobject.WrapperResult 
    **/
    public static XC_UTIL_Sobject.WrapperResult workOrderCreation(List<Case> caseList){
        Savepoint sp = Database.setSavepoint();
        XC_UTIL_Sobject.WrapperResult resWrapper = new XC_UTIL_Sobject.WrapperResult();
        caseList = XC_TR_Case_U_CaseRepair_V.checkExistAsset(caseList);
        if(caseList.isEmpty()){
            resWrapper.success = false;
            resWrapper.errorMessage = Label.XC_CL_NoAssetForCase;
            return resWrapper;
        }

        Map<Id,XC_CM_Case_Repair_Configuration__mdt> confMap = getCaseRepairConfiguration(caseList);
        List<XC_CM_Case_Repair_Configuration__mdt> conf = confMap.values();
        if(conf.isEmpty()){
            resWrapper.success = false;
            resWrapper.errorMessage = Label.XC_CL_WorkOrder_NoRepairServices;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '######### NO Repair Case To Do');
            return resWrapper;
        }

        Map<Id, Id> assetIdCoverageName = new Map<Id, Id>();
        List<Case> validationCases = filterCaseRepair(caseList, conf);
        Map<Id,List<Asset>> attachedAssetsRelations = retrieveAttachedAssets(validationCases); //caseList
        List<Case> verifiedCases = checkCaseAsset(validationCases, attachedAssetsRelations, assetIdCoverageName);
          //NA modification for B2C management with B2B Asset
          List<case> caseWithouthB2BAsset= new List<Case>();
          for(case c:verifiedCases){
              if((c.XC_Asset_B2B__c==null ) &&  
                   c.XC_Segment__c=='B2C'
                    ){
                caseWithouthB2BAsset.add(c);
              }
          }
        resWrapper = insertWoRoot(caseWithouthB2BAsset, attachedAssetsRelations, assetIdCoverageName);
        if(!resWrapper.success){
            Database.rollback(sp);
        }
        return resWrapper;
    }

    /**
     * @description Work order creation.
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new 
     */
    public static void workOrderCreation(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'START XC_TR_Case_U_CaseRepair workOrderCreation');
        List<Case> caseList = XC_UTIL_SObject.getListChanged(new List<String>{'XC_Subtype__c','XC_AssetAttached__c'}, mapOld, mapNew);
        if (caseList.isEmpty()){
            return;
        }
        workOrderCreation(caseList);     
    }

    /**
     * @description getCaseRepairConfiguration
     * @param caseList input cases
     * @return the Map<Id,XC_CM_Case_Repair_Configuration__mdt> result
     */
    public static Map<Id,XC_CM_Case_Repair_Configuration__mdt> getCaseRepairConfiguration(List<Case> caseList){
        List<String> subTypes = XC_UTIL_Sobject.getListFieldValues(caseList, 'XC_Subtype__c');
        List<String> reasons = XC_UTIL_Sobject.getListFieldValues(caseList, 'Reason');
        List<String> subCauses = XC_UTIL_Sobject.getListFieldValues(caseList, 'SubCause__c'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Edited caseList = '+caseList + 'test trigger : - lists = '+subTypes+' '+reasons+' '+subCauses);
        Map<Id,XC_CM_Case_Repair_Configuration__mdt> confMap = new Map<Id,XC_CM_Case_Repair_Configuration__mdt>([ SELECT XC_Sub_Type__c, XC_WorkOrder_Needed__c, XC_Reason__c,
                                                            XC_Required_Product__c, XC_Sub_Cause__c
                                                            FROM XC_CM_Case_Repair_Configuration__mdt 
                                                            WHERE (XC_Sub_Type__c in : subTypes OR XC_Sub_Type__c = null) AND
                                                            XC_Reason__c in : reasons AND 
                                                            XC_Sub_Cause__c in : subCauses ]);
        return confMap;
    }
    
    /**
    * @description checkCaseAsset
    * @author Andrea Bravaccino | 25/7/2019
    * @param listNew List<Case> 
    * @param attachedAssetsRelations Map<Id, List<Asset>> 
    * @param assetIdCoverageName Map<Id, Id>
    * @return List<Case>
    */
    private static List<Case> checkCaseAsset(List<Case> listNew, Map<Id,List<Asset>> attachedAssetsRelations, Map<Id, Id> assetIdCoverageName){ 
        List<Case> verifiedCase = new List<Case>();
        Set<String> listAllLE = XC_UTIL_Sobject.getSetIdsStringOnField(listNew,'XC_LegalEntity__c');
        Set<String> segmFilter = XC_UTIL_Sobject.getSetIdsStringOnField(listNew,'XC_Segment__c');
        Map<String,XC_CM_LegalEntity_Configuration__mdt> configLE = XC_Util_LegalEntityOneOrg.getOrgConfigLegalEntities(listAllLE, segmFilter);

        Map<String, XC_CM_CaseUrgencyManagement__mdt> cmUrgencyManagementMap = XC_TR_Case_U_CaseRepair_V.getCmUrgencyManagementMap();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@cmUrgencyManagementMap: ' + cmUrgencyManagementMap);
        Set<Id> assetId = new Set<Id>();
        for(List<Asset> assets : attachedAssetsRelations.values()){
            for (Asset currentAsset : assets) {
                assetId.add(currentAsset.Id);
            }
        }

        Map<Id,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> getAssetsCoverage = XC_UTIL_AssetCoverage.getAssetsCoverageFileteredBySubtype(new List<Id>(assetId), Label.XC_CL_WorkType_Repair);
        Map<Id, Integer> assetCoverageTotalRepairMapWithId = new Map<Id, Integer>();
        Map<Id, Integer> assetRemainingRepairsNumberMap = XC_TR_Case_U_CaseRepair_V.getAssetRemainingRepairsNumberMap(getAssetsCoverage, assetCoverageTotalRepairMapWithId);
        for (Case c : listNew) {
            //Set<String> notCoverageAsset = new Set<String>();
            String urgentType = XC_TR_Case_U_CaseRepair_V.getUrgentType(c);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@urgentType: ' + urgentType);
            
            List<Asset> assetList = attachedAssetsRelations.get(c.id);
            /* NR0750 - [MC] 20200921 */
			List<XC_CaseAsset__c> listCaseAssets = new List<XC_CaseAsset__c>();
        listCaseAssets = [SELECT Id, XC_Case__c, XC_Asset__c, XC_Asset__r.Name,  XC_Asset__r.XC_ContractStartDate__c, XC_Asset__r.XC_ContractEndDate__c, XC_Asset__r.XC_Product_Subtype__c, XC_Asset__r.XC_Address__r.XC_AddressCountry__c, XC_Asset__r.XC_Address__c
                                    FROM XC_CaseAsset__c
                                    WHERE XC_Case__c = :listNew[0].id];
			
			System.debug('Donato '+listCaseAssets);
			System.debug('Donato '+listCaseAssets[0].XC_Asset__r.XC_Address__r.XC_AddressCountry__c );
			
				if(checkSkipCoverage(assetList, configLE.get(c.XC_LegalEntity__c + c.XC_Segment__c)) || listCaseAssets[0].XC_Asset__r.XC_Address__r.XC_AddressCountry__c == 'Portugal'){
                verifiedCase.add(c);
                continue;
            }
			

            PopulateParameterWrapper ppw = new PopulateParameterWrapper();
            ppw.assetList = assetList;
            ppw.getAssetsCoverage = getAssetsCoverage;
            ppw.urgentType = urgentType;
            ppw.cmUrgencyManagementMap = cmUrgencyManagementMap;
            ppw.assetCoverageTotalRepairMapWithId = assetCoverageTotalRepairMapWithId;
            ppw.assetRemainingRepairsNumberMap = assetRemainingRepairsNumberMap;
            assetIdCoverageName.putAll(verifyCoverageAsset(ppw));
            //notCoverageAsset = ppw.notCoverageAsset;
            /*for (Asset asset : assetList) {
                List<String> urgentTypeAssetNameId = new List<String>{urgentType, asset.name, asset.Id};
                XC_TR_Case_U_CaseRepair_V.ParameterWrapperNotCoverageAsset wrapper = new XC_TR_Case_U_CaseRepair_V.ParameterWrapperNotCoverageAsset();
                wrapper.assetsCoverage = getAssetsCoverage;
                wrapper.cmUrgencyManagementMap = cmUrgencyManagementMap;
                wrapper.urgentType = urgentType;
                wrapper.assetName = asset.Name;
                wrapper.assetId = asset.Id;
                Boolean isAssetCovered = XC_TR_Case_U_CaseRepair_V.getNotCoverageAsset(wrapper);
                if(!isAssetCovered){
                    notCoverageAsset.add(wrapper.assetName + ' ' + Label.XC_CL_HasADifferentSLA);
                }
            }*/
            verifiedCase.addAll(XC_TR_Case_U_CaseRepair_V.getVerifiedCase(ppw.notCoverageAsset, c)); //notCoverageAsset
        }
        return verifiedCase;
    }

    /**
    * @description checkSkipCoverage
    * @author Monica Cutillo - mcutillo@deloitte.it
    * @param assetList 
    * @param config 
    * @return true to skeep Coverage check, false otherwise
    **/
    private static Boolean checkSkipCoverage(List<Asset> assetList, XC_CM_LegalEntity_Configuration__mdt config){
        if(assetList == null || assetList.isEmpty() || config == null || String.isBlank(config.XC_RepairCoverageSkipBySubType__c)){
            return false;
        }
        for(Asset asset : assetList){
            if(String.isNotBlank(asset.XC_Product_Subtype__c) && (config.XC_RepairCoverageSkipBySubType__c).contains(asset.XC_Product_Subtype__c) || asset.XC_Address__r.XC_AddressCountry__c == 'Portugal'){
                return true;
			}
		}
        return false;
    }

    /**
    * @description 
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 9/10/2019 
    * @param ppw 
    * @return Set<String> 
    **/
    public static Map<Id, String> verifyCoverageAsset(PopulateParameterWrapper ppw){
        Map<Id, Id> assetIdCoverageName = new Map<Id, Id>();
        if(ppw == null || ppw.assetList == null){
            return assetIdCoverageName;
        }
        for (Asset asset : ppw.assetList) {
            if(ppw.assetRemainingRepairsNumberMap.get(asset.Id) != 0){
                List<String> urgentTypeAssetNameId = new List<String>{ppw.urgentType, asset.name, asset.Id};
                XC_TR_Case_U_CaseRepair_V.ParameterWrapperNotCoverageAsset wrapper = new XC_TR_Case_U_CaseRepair_V.ParameterWrapperNotCoverageAsset();
                wrapper.assetsCoverage = ppw.getAssetsCoverage;
                wrapper.cmUrgencyManagementMap = ppw.cmUrgencyManagementMap;
                wrapper.urgentType = ppw.urgentType;
                wrapper.assetName = asset.Name;
                wrapper.assetId = asset.Id;
                wrapper.assetRemainingRepairsNumberMap = ppw.assetRemainingRepairsNumberMap;
                wrapper.assetCoverageTotalRepairMapWithId = ppw.assetCoverageTotalRepairMapWithId;
                Boolean isAssetCovered = XC_TR_Case_U_CaseRepair_V.getNotCoverageAsset(wrapper);
                if(!isAssetCovered){
                    ppw.notCoverageAsset.add(wrapper.assetName + ' ' + Label.XC_CL_HasADifferentSLA);
                    ppw.notCoverageAssetId.add(wrapper.assetId);
                }else {
                    assetIdCoverageName.put(wrapper.assetId , wrapper.assetName);
                }
            }else {
                ppw.notCoverageAsset.add(asset.Name + ' ' + 'has finished repair services');
                ppw.notCoverageAssetId.add(asset.Id);
            }
            
        }
        return assetIdCoverageName;
    }

    /**
     * @description retrieveAttachedAssets
     * @param cases the cases list
     * @return map with relationd caseId > attached asset Id List
     */
    public static Map<Id,List<Asset>> retrieveAttachedAssets(List<Case> cases){
        Map<Id,List<Asset>> attachedAssetsRelations = new Map<Id,List<Asset>>();
        Set<Id> caseIds = XC_UTIL_Sobject.getSetIds(cases);
        Map<Id, XC_CaseAsset__c> joCaseAssetData = new Map<Id,XC_CaseAsset__c>(
            [SELECT Id, XC_Case__c, XC_Asset__c, XC_Asset__r.Name,  XC_Asset__r.XC_ContractStartDate__c, XC_Asset__r.XC_ContractEndDate__c, XC_Asset__r.XC_Product_Subtype__c, XC_Asset__r.XC_Address__r.XC_AddressCountry__c, XC_Asset__r.XC_Address__c
               FROM XC_CaseAsset__c 
              WHERE XC_Case__c IN: caseIds ]
        );
        for(XC_CaseAsset__c jo : joCaseAssetData.values()){
            if(attachedAssetsRelations.get(jo.XC_Case__c)==null){
                attachedAssetsRelations.put(jo.XC_Case__c, new List<Asset>());
            }
            Asset a = new Asset(Id = jo.XC_Asset__c, Name = jo.XC_Asset__r.Name, XC_Product_Subtype__c = jo.XC_Asset__r.XC_Product_Subtype__c, XC_Address__c = jo.XC_Asset__r.XC_Address__c);
            attachedAssetsRelations.get(jo.XC_Case__c).add(a);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ retrieveAttachedAssets result: '+attachedAssetsRelations);
        return attachedAssetsRelations;
    }

    /**
    * @description
    * @author Andrea Bravaccino | 24/7/2019
    * @param verifiedcase List<Case> 
    * @param attachedAssetsRelations Map<Id, List<Asset>> 
    * @param assetIdCoverageName Map<Id, Id>
    * @return XC_UTIL_Sobject.WrapperResult result of operation
    */
    private static XC_UTIL_Sobject.WrapperResult insertWoRoot(List<Case> verifiedcase, Map<Id,List<Asset>> attachedAssetsRelations, Map<Id, Id> assetIdCoverageName) {
        List<XC_UTIL_Sobject.WrapperResult> insertList;
        List<Case> verifiedCaseWithAddress = new List<Case>(
                                            [SELECT Id, XC_Urgent__c, XC_LegalEntity__c, XC_WithCommitment__c, XC_Address__c, XC_Address__r.XC_Address__c, XC_Address__r.XC_PostalCode__c,
                                            XC_Address__r.XC_City__c, XC_Address__r.XC_AddressCountry__c
                                            FROM Case
                                            WHERE Id IN: verifiedcase]);
        List<WorkOrder> woInsert = new List<WorkOrder>();
        List<WorkOrder> woChildToInsert = new List<WorkOrder>();
        for (Case c : verifiedCaseWithAddress) {
            WorkOrder woRoot = XC_TR_Case_U_CaseRepair_V.populateRootWorkOrder(c);
            List<Asset> assetList = attachedAssetsRelations.get(woRoot.CaseId);
            if (assetList != null && assetList.size() == 1){
                woRoot.AssetId = assetList.get(0).Id;
                woRoot.XC_HierarchyLevel__c = 2;
                woRoot.XC_isTree__c = false;
                woRoot.XC_Coverage__c = assetIdCoverageName.get(woRoot.AssetId);
            }else {
                woRoot.XC_WorkTypeLabel__c = Label.XC_CL_WorkType_Repair;
            }
            woInsert.add(woRoot);
        } 
        insertList = XC_UTIL_Sobject.insertListRecords(woInsert);
        if (!XC_UTIL_Sobject.checkDMLResults(insertList)) {
            return insertList.get(0);
        }
        for (WorkOrder woRoot : woInsert) {
            if (woRoot.AssetId == null){
                List<Asset> assetList = attachedAssetsRelations.get(woRoot.CaseId);
                if(assetList == null){
                    continue;
                }
                for (Asset asset : assetList) {
                    WorkOrder woChild = XC_TR_Case_U_CaseRepair_V.populateChildWorkOrder(woRoot, asset.Id);
                    woChild.XC_Coverage__c = assetIdCoverageName.get(woChild.AssetId);
                    woChildToInsert.add(woChild);
                } 
            }
        }
        insertList = XC_UTIL_Sobject.insertListRecords(woChildToInsert);
        if (!XC_UTIL_Sobject.checkDMLResults(insertList)) {
            return insertList.get(0);
        }

        XC_UTIL_Sobject.WrapperResult resWrapper = XC_UTIL_Skill.insertSkillOnParentFromChildren(woInsert);
        if (!resWrapper.success) {
            return resWrapper;
        }
        return updateInsertedWo(woInsert);
    }

    private static XC_UTIL_Sobject.WrapperResult updateInsertedWo(List<WorkOrder> woInsert){
        XC_UTIL_Sobject.WrapperResult resWrapper = new XC_UTIL_Sobject.WrapperResult();
        resWrapper.success = true;
        Map<Id, Set<Id>> rpToInsert = XC_UTIL_ResourcePreference_U.getResPrefFromChildren(woInsert);
        List<WorkOrder> woWithoutChildren = new List<WorkOrder>();
        List<WorkOrder> woWithChildren = new List<WorkOrder>();
        for (WorkOrder wo : woInsert) {
            Set<Id> rpIds = rpToInsert.get(wo.Id);
            if (rpIds.isEmpty() && wo.XC_isTree__c){
                woWithoutChildren.add(wo);
            }else {
                woWithChildren.add(wo);
            }
        }
        List<XC_UTIL_Sobject.WrapperResult> insertList = XC_UTIL_ResourcePreference.insertRequiredResourcePreferences(woWithChildren, rpToInsert);
        if (!XC_UTIL_Sobject.checkDMLResults(insertList)) {
            return insertList.get(0);
        }
        
        List<XC_UTIL_Sobject.WrapperResult> results = XC_TR_WorkOrder_U_RequiredResMgmt.manageRequiredResourcesOnInsert(woWithoutChildren);
        resWrapper.success = XC_UTIL_Sobject.checkDMLResults(results);
        if(!resWrapper.success){
            resWrapper.errorMessage = results.get(0).errorMessage;
        }
        return resWrapper;
    }

    private static Boolean checkCondition(Case c, XC_CM_Case_Repair_Configuration__mdt mdt){
        return c.Reason == mdt.XC_Reason__c && 
                    c.SubCause__c == mdt.XC_Sub_Cause__c && 
                    mdt.XC_WorkOrder_Needed__c &&
                    (mdt.XC_Sub_Type__c == null || c.XC_Subtype__c == mdt.XC_Sub_Type__c);
                    
    }

}