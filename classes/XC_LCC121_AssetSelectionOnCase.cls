/**
 * The Class XC_LCC121_AssetSelectionOnCase.
 *
 * @author: Monica Cutillo monica.cutillo@nttdata.com
 * @date Creation: 19/06/2019
 * @description XC_LCC121_AssetSelectionOnCase – Controller of XC_LCP121_AssetSelectionOnCase
 */
public without sharing class XC_LCC121_AssetSelectionOnCase {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC109_TakeChargeLead');
    
    /**
     * @description Class Wrapper
     **/
    public class AssetsAttachData{
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String resultMessage = '';
        @AuraEnabled 
        public String typeMessage = '';
        @AuraEnabled
        public List<Asset> assets = new List<Asset>();
        @AuraEnabled
        public List<Id> relatedAssetIds = new List<Id>();
    }
    
    /**
     * @description getAssetsByAddress
     * @param caseId case Id
     * @return result wrapper with List<Asset> associated with same address case
     **/
    @AuraEnabled
    public static AssetsAttachData getAssetsByAddress(Id caseId){
        //se il WO è stato associato la sezione non è accessibile
        AssetsAttachData result = checkIfAccessible(caseId);
        if(!result.success){
            return result;
        }

        Id addressId = XC_UTIL_Sobject.getFieldValue('Case', 'XC_Address__c', caseId);
        if(addressId==null){
            result.resultMessage = Label.XC_CL_NoAddressSelectedOnCaseMess;
            result.success = false;
            return result;
        }
        
        List<Asset> assets = retrieveAssetsByAddress(addressId);
        if(!assets.isEmpty()){
            result.success = true;
            result.assets = assets;
            
            List<XC_CaseAsset__c> joCaseAssetData = retrieveRelatedCaseAssets(caseId);
            if(!joCaseAssetData.isEmpty()){
                List<Id> assetIds = new List<Id>();
                for(XC_CaseAsset__c jo : joCaseAssetData){
                    assetIds.add(jo.XC_Asset__c);
                }
                result.relatedAssetIds = assetIds;
            }
        }else{
            result.success = false;
            result.resultMessage = Label.XC_CL_NoAssetsForAddressMess;
        }

        return result;
    }

    /**
     * @description checkIfAccessible
     * @param caseId case Id
     * @return result wrapper
     **/
    private static AssetsAttachData checkIfAccessible(Id caseId){
        AssetsAttachData result = new AssetsAttachData();
        String woId = XC_UTIL_Sobject.getFieldValue('Case', 'XC_WorkOrder__c', caseId);
        if(String.isNotBlank(woId)){
            result.success = false;
            result.resultMessage = Label.XC_CL_WOAssociatedMess;
        }else{
            result.success = true;
        }
        return result;
    }

    /**
     * @description attachAssets
     * @param caseId case Id
     * @param assetToAttach assets to attach
     * @return result wrapper
     **/
    @AuraEnabled
    public static AssetsAttachData attachAssets(Id caseId, List<Asset> assetToAttach){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ CALL attachAssets - caseId='+caseId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ assetToAttach='+assetToAttach);

        System.Savepoint beforeDMLSavepoint = Database.setSavepoint();
        XC_UTIL_Sobject.WrapperResult detRes = deleteOldCaseAssetRelations(caseId);
        if(!detRes.success){
            return doRollback(detRes, beforeDMLSavepoint);
        }
        XC_UTIL_Sobject.WrapperResult insRes = insertNewCaseAssetRelations(caseId, assetToAttach);
        if(!insRes.success){
            return doRollback(insRes, beforeDMLSavepoint);
        }

        Case caso = new Case();
        caso.Id = caseId;
        caso.XC_AssetAttached__c = (assetToAttach!=null && !assetToAttach.isEmpty());
        if(!assetToAttach.isEmpty()){      //Fix requested by Alberto [MC 20191112]
            caso.AssetId = assetToAttach[0].Id;
        }
        List<XC_UTIL_Sobject.WrapperResult> dmlResults = XC_UTIL_DML.updateRecords(new List<Case> {caso});
        XC_UTIL_Sobject.WrapperResult dmlRes = XC_UTIL_Sobject.getGlobalDMLResults(dmlResults);
        AssetsAttachData result = new AssetsAttachData();
        result.success = dmlRes.success;
        result.resultMessage = (result.success) ? Label.XC_CL_OperationCompleted : dmlRes.errorMessage;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ assetToAttach result = '+result);
        return result;
    }

    /**
     * @description doRollback
     * @param dmlResult dml Result wrapper
     * @param beforeDMLSavepoint Database Savepoint
     * @return result wrapper
     **/
    private static AssetsAttachData doRollback(XC_UTIL_Sobject.WrapperResult dmlResult, System.Savepoint beforeDMLSavepoint){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ attachAssets to Case Rollback@@@ errMess='+dmlResult.errorMessage);
        Database.rollback(beforeDMLSavepoint);
        AssetsAttachData result = new AssetsAttachData();
        result.resultMessage = dmlResult.errorMessage;
        return result;
    }

    /**
     * @description retrieveRelatedCaseAssets
     * @param caseId case Id
     * @return result wrapper
     **/
    private static List<XC_CaseAsset__c> retrieveRelatedCaseAssets(Id caseId){
        Map<Id, XC_CaseAsset__c> joCaseAssetData = new Map<Id,XC_CaseAsset__c>(
            [SELECT Id, XC_Asset__c FROM XC_CaseAsset__c WHERE XC_Case__c =: caseId ]
        );
        return joCaseAssetData.values();
    }

    /**
     * @description deleteOldCaseAssetRelations
     * @param caseId case Id
     * @return result wrapper
     **/
    private static XC_UTIL_Sobject.WrapperResult deleteOldCaseAssetRelations(Id caseId){
        List<XC_CaseAsset__c> joCaseAssetData = retrieveRelatedCaseAssets(caseId);
        List<XC_UTIL_Sobject.WrapperResult>  dmlResult = XC_UTIL_DML.deleteRecords(joCaseAssetData);
        return XC_UTIL_Sobject.getGlobalDMLResults(dmlResult);
    }

    /**
     * @description insertNewCaseAssetRelations
     * @param caseId case Id
     * @param assetToAttach assets to attach
     * @return result wrapper
     **/
    private static XC_UTIL_Sobject.WrapperResult insertNewCaseAssetRelations(Id caseId, List<Asset> assetToAttach){
        if(assetToAttach == null || assetToAttach.isEmpty()){
            XC_UTIL_Sobject.WrapperResult result = new XC_UTIL_Sobject.WrapperResult();
            result.success = true;
            return result;
        }
        
        List<XC_CaseAsset__c> newJO = new List<XC_CaseAsset__c>();
        XC_CaseAsset__c jo;
        for(Asset asset : assetToAttach){
            jo = new XC_CaseAsset__c();
            jo.XC_Case__c = caseId;
            jo.XC_Asset__c = asset.Id;
            newJO.add(jo);
        }
        List<XC_UTIL_Sobject.WrapperResult>  dmlResult = XC_UTIL_DML.insertRecords(newJO);
        return XC_UTIL_Sobject.getGlobalDMLResults(dmlResult);
    }

    /**
     * @description retrieveAssetsByAddress
     * @param addressId address Id
     * @return List<Asset> associated with address in input
     **/
    private static List<Asset> retrieveAssetsByAddress(Id addressId){
        Map<Id,Asset> assetData = new Map<Id,Asset>(
            [SELECT Id, Name, Status, XC_Product_Type__c, XC_Product_Subtype__c 
             FROM Asset 
             WHERE XC_Product_Type__c =: Label.XC_CL_ProductTypeEquipment AND XC_Address__c =: addressId
             AND Status =: Label.XC_CL_Asset_StatusActive]);
        return assetData.values();
    }

}