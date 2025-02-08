/**
 * The Class XC_LCC242_ButtonCreationRepairWO.
 *
 * @author Monica Cutillo - mcutillo@deloitte.it && Eleni Tsiolaki - etsiolaki@deloitte.gr
 * @date Creation 08/03/2021
 * @date Modification dd/mm/yyyy
 * @description Controller of the lightning component XC_LCP242_ButtonCreationRepairWO
 */
public without sharing class XC_LCC242_ButtonCreationRepairWO {

    /**
    * @description checkAndPrepareRepairPreconditions
    * @param caseList 
    * @return XC_UTIL_Sobject.WrapperResult 
    **/
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkAndPrepareRepairPreconditions(String caseId){
        XC_UTIL_ResultWrapper result = new XC_UTIL_ResultWrapper();
        Id idObj = caseId;
        Map<Id,Case> caso = XC_LCC242_ButtonCreationRepairWO_D.retrieveInformationsFromCase(new Set<Id>{idObj});
        
        XC_CM_Case_Type_Setting__mdt repairType = XC_TR_Case_U_CaseRepair_V.retrieveCaseRepairSettings();
        if(repairType == null || !XC_UTIL_Case.matchSettings(caso.get(idObj), repairType)){
            result.resultMessage = Label.XC_CL_WorkOrder_NoRepairServices;
            return result;
        }

        if(!(caso.get(idObj).WorkOrders).isEmpty()){
            result.resultMessage = Label.XC_CL_RepairWorkOrderAlreadyCreated;
            return result;
        }

        XC_UTIL_ResultWrapper checkAssetRes = checkAssetConditions(caso.get(idObj));
        if(!checkAssetRes.success){
            return checkAssetRes;
        }

        result.success = true;
        return result;
    }
    
    /**
    * @description workOrderCreation
    * @param paramsMap input Map<String,Object>  
    * @return XC_UTIL_Sobject.WrapperResult 
    **/
    @AuraEnabled
    public static XC_UTIL_ResultWrapper workOrderCreation(Map<String,Object> paramsMap){
        Id idObj = String.valueOf(paramsMap.get('recordId'));
        String subtype = String.valueOf(paramsMap.get('subtype'));
        Map<Id,Case> caseData = XC_LCC242_ButtonCreationRepairWO_D.retrieveInformationsFromCase(new Set<Id>{idObj});
        caseData.values()[0].XC_SubType__c = subtype;

        Map<Id,XC_CM_Case_Repair_Configuration__mdt> confMap = XC_TR_Case_U_CaseRepair.getCaseRepairConfiguration(caseData.values());
        if(confMap.values().isEmpty()){
            XC_UTIL_ResultWrapper result = new XC_UTIL_ResultWrapper();
            result.resultMessage = Label.XC_CL_WorkOrder_NoRepairServices;
            return result;
        }
        
        return completeConfigForWorkOrderRepair(caseData.get(idObj));
    }

    /**
    * @description checkAndPrepareRepairPreconditions
    * @param caseList 
    * @return XC_UTIL_Sobject.WrapperResult 
    **/
    private static XC_UTIL_ResultWrapper checkAssetConditions(Case Caso){
        XC_UTIL_ResultWrapper result = new XC_UTIL_ResultWrapper();
        if(String.isBlank(caso.AssetId)){
            result.resultMessage = Label.XC_CL_NoAssetForCase;
            return result;
        }
        if(caso.Asset.XC_Product_Type__c != Label.XC_CL_ProductTypeEquipment || caso.Asset.Status != Label.XC_CL_Asset_StatusActive){
            result.resultMessage = Label.XC_CL_NoCorrectAssetForCase;
            return result;
        }
        
        List<XC_CaseAsset__c> joCaseAssetData = XC_LCC242_ButtonCreationRepairWO_D.retrieveRelatedCaseAssets(caso.Id);
        if(joCaseAssetData.isEmpty()){
            if(String.isBlank(caso.Asset.XC_Address__c)){
                result.resultMessage = Label.XC_CL_NoAddressPresentOnAsset;
                return result;
            }
        }

        result.success = true;
        return result;
    }

    /**
    * @description completeConfigForWorkOrderRepair
    * @param caseList 
    * @return XC_UTIL_Sobject.WrapperResult 
    **/
    private static XC_UTIL_ResultWrapper completeConfigForWorkOrderRepair(Case caso){
        System.Savepoint beforeDMLSavepoint = Database.setSavepoint();

        List<XC_CaseAsset__c> joCaseAssetData = XC_LCC242_ButtonCreationRepairWO_D.retrieveRelatedCaseAssets(caso.Id);
        if(joCaseAssetData.isEmpty()){
            XC_CaseAsset__c caseAssetRelation = new XC_CaseAsset__c( XC_Case__c = caso.Id, XC_Asset__c = caso.AssetId );
            List<XC_UTIL_Sobject.WrapperResult> insertResult = XC_UTIL_DML.insertRecords(new List<Sobject>{caseAssetRelation});
            if(!insertResult[0].success){
                return doRollback(insertResult[0],beforeDMLSavepoint);
            }
            caso.XC_AssetAttached__c = true;
            caso.XC_Address__c = caso.Asset.XC_Address__c;
        }
        
        List<XC_UTIL_Sobject.WrapperResult> updateResult = XC_UTIL_DML.updateRecords(new List<Sobject>{caso});
        if(!updateResult[0].success){
            System.debug('error in ' + updateResult[0].errorMessage);
            return doRollback(updateResult[0],beforeDMLSavepoint);
        }

        XC_UTIL_ResultWrapper result = new XC_UTIL_ResultWrapper();
        result.success = true;
        return result;
    }

    //private static Case createAutomaticAttachAsset()

    /**
     * @description deleteOldCaseAssetRelations
     * @param caseId case Id
     * @return result wrapper
     **/
    /*private static XC_UTIL_Sobject.WrapperResult deleteOldCaseAssetRelations(Id caseId){
        List<XC_CaseAsset__c> joCaseAssetData = XC_LCC242_ButtonCreationRepairWO_D.retrieveRelatedCaseAssets(caseId);
        List<XC_UTIL_Sobject.WrapperResult>  dmlResult = XC_UTIL_DML.deleteRecords(joCaseAssetData);
        return XC_UTIL_Sobject.getGlobalDMLResults(dmlResult);
    }*/

    /**
     * @description doRollback
     * @param dmlResult dml Result wrapper
     * @param beforeDMLSavepoint Database Savepoint
     * @return result wrapper
     **/
    private static XC_UTIL_ResultWrapper doRollback(XC_UTIL_Sobject.WrapperResult dmlResult, System.Savepoint beforeDMLSavepoint){
        Database.rollback(beforeDMLSavepoint);
        XC_UTIL_ResultWrapper result = new XC_UTIL_ResultWrapper();
        result.resultMessage = dmlResult.errorMessage;
        return result;
    }
}