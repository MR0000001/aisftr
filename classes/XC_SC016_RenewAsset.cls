/**
* @author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com & Sara Miozza sara.miozza@nttdata.com
* @date Creation 15/07/2019
* @date Modification 18/12/2019 by Valeria Martino - valeria.martino@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_SC016_RenewAsset – Batch used to automatically renew the asset
*/

public with sharing class XC_SC016_RenewAsset implements Schedulable, Database.Batchable<sObject>  {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC016_RenewAsset');

    /** @description Util Wrapper */
    private class UtilWrapper {
        List<Asset> assetToUpdateList = new List<Asset>();
        List<Case> caseToInsertList = new List<Case>();
        List<Contract> contractsToUpdateList = new List<Contract>();
    }     

    /**
     * @description execute method
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC016_RenewAsset(), 200);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'batch XC_SC016_RenewAsset ID ' + batchId); 
    }
    
    /**
     * @description start method
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */ 
    public Database.QueryLocator start(Database.BatchableContext bc ) {
        Date oneMonthFromTodayAdd = Date.Today().addMonths(1); 
        Date oneMonthFromTodayRemove = Date.Today().addMonths(-1);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In XC_SC016_RenewAsset, oneMonthFromTodayAdd -> ' + oneMonthFromTodayAdd + ' - oneMonthFromTodayRemove -> ' + oneMonthFromTodayRemove);
        return Database.getQueryLocator(
            'SELECT Id, XC_ContractEndDate__c, Status, XC_Product_Type__c, XC_Contract__c, XC_Contract__r.Status,  XC_Service_AutoRenew__c, XC_RenewalDuration__c,XC_Service_Last_Renewal_Date__c, XC_NearExpirationCaseCreated__c, NE__Bundle__c, AccountId, ContactId, Country__c, XC_LegalEntity__c ' +
            'FROM  Asset ' +
            'WHERE XC_ContractEndDate__c >= ' + String.valueOf(oneMonthFromTodayRemove) + ' AND XC_ContractEndDate__c <= ' + String.valueOf(oneMonthFromTodayAdd) + ' AND Status <> \'' + Label.XC_CL_Asset_StatusInactive + '\''+ 
            '  AND ( XC_Product_Type__c IN (\'' + Label.XC_CL_ProductTypeService +'\', \'' + Label.XC_CL_ProductTypeEquipment +'\') OR '+
            '      ( XC_Product_Type__c = \'' + Label.XC_CL_ProductTypeBundle +'\'' + ' AND XC_Product_Subtype__c <> \'Parameter\' AND XC_BillingModel__c LIKE \'%renting%\' AND NE__Bundle_Configuration__c = null) OR ' +
            '      ( XC_Product_Type__c = \'' + Label.XC_CL_ProductTypeCoverage + '\'' + ' AND XC_Segment__c  = \''+ 'B2C' + '\'' + ' AND (XC_LegalEntity__c = \'' + Label.XC_CL_LegalEntity_Italy + '\' OR XC_LegalEntity__c = \'' + Label.XC_CL_LegalEntity_EnelXMobilityItalia + '\')' + ' AND XC_BillingModel__c = \'' + Label.XC_CL_BillingModel_Recurring +'\' ) )'         );                                         
    }  
    
    /**
    * @description execute batch
    * @param bc - Database.BatchableContext
    * @param scope - List<Asset>
    */
    public void execute(Database.BatchableContext bc, List<Asset> scope) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Scope for batch -> ' + scope); 
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();  
        if(!scope.isEmpty()) {
            List<String> countryList = new List<String>();
            for(Asset ass : scope){
               countryList = new List<String>{ass.Country__c}; 
            }
            
            UtilWrapper utilWr = cycleOnAsset(scope, countryList);
            List<Asset> assetToUpdateList = utilWr.assetToUpdateList;
            List<Case> caseToInsertList = utilWr.caseToInsertList;
            List<Contract> contractsToUpdateList = utilWr.contractsToUpdateList;
            
            if(!caseToInsertList.isEmpty()) {
                List<String> caseRecordIdList = populateListCase(caseToInsertList);
                List<Case> caseList = new List<Case>([
                    SELECT Id, AssetId 
                    FROM Case 
                    WHERE Id IN: caseRecordIdList
                ]);
                XC_UTIL_Sobject.runAssignmentRules(caseList, 'Case');
                for(Case cs : caseList){
                    Asset ass = new Asset(Id = cs.AssetId);
                    ass.XC_NearExpirationCaseCreated__c = true;
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Asset -> ' + ass);
                    assetToUpdateList.add(ass);
                }                                                  
            } 

            //Review for Bundle and Coverage Inactivation [MC -  mcutillo@meloitte.it - 20200415]
            List<Asset> assetChildrenToUpd = childrenMngmAfterParentInactivation(assetToUpdateList);
            assetToUpdateList.addAll(assetChildrenToUpd);
            List<XC_UTIL_Sobject.WrapperResult> resultAssetList = XC_UTIL_Sobject.updateListRecords(assetToUpdateList);
            List<XC_UTIL_Sobject.WrapperResult> resultContractList = XC_UTIL_Sobject.updateListRecords(contractsToUpdateList);
            List<XC_UTIL_Sobject.WrapperResult> resultList = new List<XC_UTIL_Sobject.WrapperResult>();
            resultList.addAll(resultAssetList);
            resultList.addAll(resultContractList);
            for(XC_UTIL_Sobject.WrapperResult wr : resultList){
                if(!wr.success){
                    XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                    bel.Name = 'XC_SC016_RenewAsset';
                    bel.XC_ErrorMessage__c = wr.errorMessage;
                    bel.XC_TypeOfOperation__c = 'Renew Asset&Contract';
                    bel.XC_RecordId__c = wr.errorObjectId; 
                    errorLog.add(bel);
                }
            }
		    XC_UTIL_Sobject.insertListRecords(errorLog);
        }
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description children management after parent asset inactivation
     * @param rootAssets - List<Asset>
     * @return List<Asset> children to upd
     */
    private static List<Asset> childrenMngmAfterParentInactivation(List<Asset> rootAssets){
        List<Asset> assetChildrenToUpd = new List<Asset>();
        List<Asset> bundleRootInactive = new List<Asset>();
        List<Asset> serviceRootInactive = new List<Asset>();
        for(Asset ass : rootAssets){
            if(ass.Status == Label.XC_CL_Asset_StatusInactive){
                if(ass.XC_Product_Type__c == Label.XC_CL_ProductTypeService){
                	serviceRootInactive.add(ass);
                }
                else if(ass.XC_Product_Type__c == Label.XC_CL_ProductTypeBundle){
                	bundleRootInactive.add(ass);
                }
            }
        }
        if(serviceRootInactive.isEmpty() && bundleRootInactive.isEmpty()){
            return assetChildrenToUpd;
        }
        
        if(!serviceRootInactive.isEmpty()){
            assetChildrenToUpd.addAll(serviceChildrenInactivationMngm(serviceRootInactive));
        }
        if(!bundleRootInactive.isEmpty()){
            assetChildrenToUpd.addAll(bundleChildrenInactivationMngm(bundleRootInactive));
        }

        return assetChildrenToUpd;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description Inactivation of all children
     * @param serviceRoots - List<Asset>
     * @return List<Asset> children to upd
     */
    private static List<Asset> serviceChildrenInactivationMngm(List<Asset> serviceRoots){
        Set<Id> rootsId = XC_UTIL_Sobject.getSetIds(serviceRoots);
        Map<Id,Asset> assets = new Map<Id,Asset>([
            SELECT Id
            FROM  Asset 
            WHERE Status <> 'Inactive'
            AND NE__Root_Order_Item__c IN: rootsId
        ]);
        List<Asset> result = new List<Asset>();
        if(!assets.values().isEmpty()){
            for(Asset ass : assets.values()){
                ass.Status = Label.XC_CL_Asset_StatusInactive;
                ass.NE__Status__c = Label.XC_CL_Asset_Disconnected;
                result.add(ass);
            }
        }
        return result;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description Inactivation of all not Equipment Children + Change RT to Customer of Equipment children
     * @param bundleRoots - List<Asset>
     * @return List<Asset> children to upd
     */
    private static List<Asset> bundleChildrenInactivationMngm(List<Asset> bundleRoots){
        Set<Id> rootsId = XC_UTIL_Sobject.getSetIds(bundleRoots);
        Map<Id,Asset> assets = new Map<Id,Asset>([
            SELECT Id, XC_Product_Type__c
            FROM  Asset 
            WHERE Status <> 'Inactive'
            AND NE__Bundle_Configuration__c IN: rootsId AND XC_BillingModel__c LIKE '%renting%' 
        ]);
        List<Asset> result = new List<Asset>();
        if(!assets.values().isEmpty()){
            Id customerRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('XC_ESP_Customer').getRecordTypeId();
            for(Asset ass : assets.values()){
                if(ass.XC_Product_Type__c != Label.XC_CL_ProductTypeEquipment){
                    ass.Status = Label.XC_CL_Asset_StatusInactive;
                    ass.NE__Status__c = Label.XC_CL_Asset_Disconnected;
                    result.add(ass);
                }else{
                    ass.RecordTypeId = customerRTId;
                    result.add(ass);
                }
            }
        }
        return result;
    }

    /**
    * @description Populate List Case
    * @param caseToInsertList - List<Case>
    * @return List<String>
    */
    private static List<String> populateListCase(List<Case> caseToInsertList) {
        List<String> caseRecordIdList = new List<String>();
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultList = XC_UTIL_Sobject.insertListRecords(caseToInsertList, false);
        for(XC_UTIL_Sobject.WrapperResult wrResult : wrapperResultList){
            if(wrResult.success && wrResult.recordId!= null){
                caseRecordIdList.add(wrResult.recordId);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ caseRecordIdList -> ' + caseRecordIdList);
        return caseRecordIdList;
    }

    /**
    * @description cycleOnContractLineItem
    * @param scope - List<Asset>
    * @param countryList - List<String>
    * @return UtilWrapper
    */
    private static UtilWrapper cycleOnAsset(List<Asset> scope, List<String> countryList){
        Date oneMonthFromToday = Date.Today().addMonths(1);
        List<String> caseSettingNames = new List<String>{Label.XC_CL_AlertEndDateOnContractLineItem};
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
        XC_CM_Case_Type_Setting__mdt caseSettings = caseSettingsMap.get(Label.XC_CL_AlertEndDateOnContractLineItem);
        UtilWrapper utilWr = new UtilWrapper();
        Map<Id,Asset> mapAssetToUpdate = new Map<Id,Asset>();
        List<Asset> assetToUpdateList = new List<Asset>();
        List<Case> caseToInsertList = new List<Case>();
        LIst<Contract> contractsToUpdateList = new List<Contract>();

        for(Asset ass : scope){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For asset -> ' + ass);
            // Section dedicated to OK* product:
            if(ass.XC_Service_AutoRenew__c){ 
                System.debug('****ok***');
                ass.XC_Service_Last_Renewal_Date__c = Date.Today();
                ass.XC_ContractEndDate__c = ass.XC_ContractEndDate__c.addYears(1);
                mapAssetToUpdate.put(ass.Id,ass);
                //assetToUpdateList.add(ass);
            } else {
                // Deactive Assets and Contracts:
                if(checkActiveAsset(ass) && (ass.XC_RenewalDuration__c==null || ass.XC_RenewalDuration__c==0.0)) {
                    ass.Status = Label.XC_CL_Asset_StatusInactive;
                    ass.NE__Status__c = Label.XC_CL_Asset_Disconnected;
                    /*Contract contractToUpdate = new Contract(
                        Id = ass.XC_Contract__c,
                        Status = Label.XC_CL_Contract_Inactivated
                    );*/
                    mapAssetToUpdate.put(ass.Id,ass);
                    //assetToUpdateList.add(ass);
                    //contractsToUpdateList.add(contractToUpdate);
                }
                // Create a case when a month is missing from end date with:  
                // Reason = XCMOT008 – Subcause__c = ATCL007 – Status = ESTA007 – Priority = 0 - ContactId and AccountId taken from Asset
                if(checkForEquipment(ass)) {                  
                    Case cs = XC_UTIL_Case.initCaseFromCaseSettings(caseSettings);
                    cs.AccountId = ass.AccountId;
                    cs.Contactid = ass.ContactId;
                    cs.AssetId = ass.Id;
                    cs.XC_Segment__c = 'B2C';
                    cs.XC_LegalEntity__c = 'EndesaX';
                    caseToInsertList.add(cs);                    
                }
            }

            if(ass.XC_RenewalDuration__c!=null && ass.XC_RenewalDuration__c > 0) {
                ass.XC_Service_Last_Renewal_Date__c = Date.Today();
                ass.XC_ContractEndDate__c = ass.XC_ContractEndDate__c.addMonths(Integer.valueOf(ass.XC_RenewalDuration__c));
                mapAssetToUpdate.put(ass.Id,ass);
            }
        }
      
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ assetToUpdateList -> ' + mapAssetToUpdate.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ contractsToUpdateList -> ' + contractsToUpdateList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ caseToInsertList -> ' + caseToInsertList);
        utilWr.assetToUpdateList = mapAssetToUpdate.values();
        utilWr.caseToInsertList = caseToInsertList;
        utilWr.contractsToUpdateList = contractsToUpdateList;
        return utilWr; 
    }

    /**
     * @description Method to check conditions for Active Assets
     * @param ass - Asset
     * @return Boolean
    */
    private static Boolean checkActiveAsset(Asset ass) {
        return (ass.Status != Label.XC_CL_Asset_StatusInactive && ass.XC_ContractEndDate__c <= Date.Today() && 
               (ass.XC_Product_Type__c == Label.XC_CL_ProductTypeService || ass.XC_Product_Type__c == Label.XC_CL_ProductTypeBundle));
    }

    /**
     * @description Method to check conditions for Equipment
     * @param ass - Asset
     * @return Boolean
    */
    private static Boolean checkForEquipment(Asset ass) {
        Date oneMonthFromToday = Date.Today().addMonths(1);
        return ((ass.XC_LegalEntity__c == 'EndesaX' || ass.XC_LegalEntity__c == 'EnelXMobilitySpain') &&
                ass.NE__Bundle__c != null && !String.isEmpty(ass.NE__Bundle__c) && !ass.XC_NearExpirationCaseCreated__c &&
                ass.XC_ContractEndDate__c > Date.Today() && ass.XC_ContractEndDate__c <= oneMonthFromToday && 
                ass.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment);
    }

    /**
     * @description finish method
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Finish Batch SC016');
    }   

}