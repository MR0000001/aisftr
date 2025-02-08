/**
* @author Domenico Del Prete - domenico.delprete@nttdata.com
* @date Creation 22/03/2021
* @description XC_SC046_PopulateAssetAnnualRenewIndex – Batch used to populate XC_AnnualRenewalDateIndex__c on Asset
*/
public without sharing class XC_SC046_PopulateAssetAnnualRenewIndex implements Schedulable, Database.Batchable<sObject> {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC046_PopulateAssetAnnualRenewIndex');

        /**
     * @description execute method
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        Database.executeBatch(new XC_SC046_PopulateAssetAnnualRenewIndex(), 200);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Batch XC_SC046_PopulateAssetAnnualRenewIndex in execution'); 
    }

    /**
     * @description Start method for batch
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In XC_SC046_PopulateAssetAnnualRenewIndex');
        Date firstOfLastMonthDate = Date.today().addMonths(-1).addYears(-1).toStartOfMonth();
        Date firstOfNextMonthDate = firstOfLastMonthDate.addMonths(2);
        String query = 'SELECT Id, XC_AnnualRenewalDate__c, XC_AnnualRenewalDateIndex__c FROM Asset WHERE Status <> \'' +'Inactive' + '\' AND((XC_ContractStartDate__c >= ' + String.valueOf(firstOfLastMonthDate) +' AND XC_ContractStartDate__c < ' + String.valueOf(firstOfNextMonthDate) +') OR (XC_AnnualRenewalDateIndex__c >= ' + String.valueOf(firstOfLastMonthDate) +' AND XC_AnnualRenewalDateIndex__c < ' + String.valueOf(firstOfNextMonthDate) +' )) AND XC_AnnualRenewalDate__c != null AND XC_CheckAnnualRenewalDate__c = false AND ( XC_Product_Type__c IN (\'' +'Service' + '\',\'' +'Equipment' + '\') OR ( XC_Product_Type__c = \''+'Bundle'+'\' AND XC_Product_Subtype__c <> \''+'Parameter'+'\' AND XC_BillingModel__c LIKE \''+'%renting%'+'\' AND NE__Bundle_Configuration__c = null) OR ( XC_Product_Type__c = \''+'Coverage'+'\' AND XC_Segment__c = \''+'B2C'+'\' AND (XC_LegalEntity__c = \''+'EnelXItalia'+'\' OR XC_LegalEntity__c = \''+'EnelXMobilityItalia'+'\') AND XC_BillingModel__c = \''+'Recurring'+'\' ))';
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Query for scope --> ' + query);
        System.debug('@@@ Query for scope --> ' + query);
        return Database.getQueryLocator(query);                                         
    }  

    /**
    * @description Execute method for batch
    * @param bc - Database.BatchableContext
    * @param scope - List<WorkOrder>
    */
    public void execute(Database.BatchableContext bc, List<Asset> scope) {
        List<Asset> listOfAsset = new List<Asset>();
        for(Asset asset : scope){
            if(asset.XC_AnnualRenewalDate__c != null){
                asset.XC_AnnualRenewalDateIndex__c = asset.XC_AnnualRenewalDate__c;
                listOfAsset.add(asset);
            }
        }
        XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultList = XC_UTIL_Sobject.updateListRecords(listOfAsset);
        XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        // Batch Error Log for fail:
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();
        for(XC_UTIL_Sobject.WrapperResult wr : wrapperResultList){
            if(!wr.success){
                XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                bel.Name = 'XC_SC046_PopulateAssetAnnualRenewIndex';
                bel.XC_ErrorMessage__c = wr.errorMessage;
                bel.XC_TypeOfOperation__c = 'Populate XC_AnnualRenewalDateIndex__c batch';
                bel.XC_RecordId__c = wr.errorObjectId; 
                errorLog.add(bel);
            }
        }
        XC_UTIL_Sobject.insertListRecords(errorLog);
    }


    /**
     * @description Finish method for batch
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Finish Batch SC046');
    }   
}