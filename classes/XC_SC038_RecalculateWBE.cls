/**
* @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 27/11/2020
* @description XC_SC038_RecalculateWBE – Schedulable classe used to automatically recalculateWBE on Orders
*/

public without sharing class XC_SC038_RecalculateWBE implements Schedulable, Database.Batchable<sObject> {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC038_RecalculateWBE');

    /**
     * @description Method to schedule Batch
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC038_RecalculateWBE(), 1);
    }  
    
    /**
     * @description Start method for batch
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) { 
        String query = 'SELECT Id, XC_ForceWBERecalculation__c FROM NE__Order__c WHERE XC_ForceWBERecalculation__c = true LIMIT 50000';
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Query for scope --> ' + query);
        return Database.getQueryLocator(query);                                         
    } 
 
    /**
    * @description Execute method for batch
    * @param bc - Database.BatchableContext
    * @param scope - List<NE__Order__c>
    */
    public void execute(Database.BatchableContext bc, List<NE__Order__c> scope) {
        if(scope.isEmpty()) {
            return;
        }
        List<String> listOrderIds = XC_UTIL_Sobject.getIds(scope);
        String query = XC_UTIL_Sobject.selectAllFieldsGetSelect('NE__OrderItem__c');
        query = query + ', NE__ProdId__r.XC_LIC_Product_Name__c, NE__Parent_Order_Item__r.XC_CMProfitCenter__c, NE__Parent_Order_Item__r.XC_CMCostCenter__c, NE__OrderId__r.RecordType.DeveloperName, ' +
            ' NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProductLine__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProductServiceType__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProfitCenter__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_CostCenter__c, ' +
            ' NE__CatalogItem__r.Id, NE__CatalogItem__r.XC_ProfitCenter__c, NE__CatalogItem__r.XC_CostCenter__c, NE__CatalogItem__r.XC_ProductServiceType__c, NE__CatalogItem__r.XC_ProductLine__c, NE__OrderId__r.XC_Country__c, NE__OrderId__r.XC_LegalEntity__c, ' +
            ' NE__OrderId__r.Id, NE__OrderId__r.NE__OptyId__r.Id, NE__OrderId__r.XC_Segment__c, NE__OrderId__r.NE__OptyId__r.XC_Company__c, NE__OrderId__r.NE__OptyId__r.Business__c, NE__OrderId__r.NE__OptyId__r.XC_ReceivingChannel__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, ' +
            ' (SELECT Id FROM Assets__r) ' +
            ' FROM NE__OrderItem__c ' +
            ' WHERE NE__OrderId__c IN :listOrderIds';
        List<NE__OrderItem__c> listOrderItemFiltered = Database.query(String.escapeSingleQuotes(query));
        if(listOrderItemFiltered.isEmpty()) {
            return;
        }
        List<NE__OrderItem__c> listOrderItemToUpdate = XC_TR_ConfigurationItem_U_GenerateWBE.populateWBEfields(listOrderItemFiltered);
        List<NE__OrderItem__c> listOrderItemsToUpdate = new List<NE__OrderItem__c>();
        Map<Id, NE__OrderItem__c> mapOrderItem = new Map<Id, NE__OrderItem__c>();
        for(NE__OrderItem__c oiProcessed : listOrderItemToUpdate) {
            listOrderItemsToUpdate.add(new NE__OrderItem__c(
                Id = oiProcessed.Id,
                XC_WBE__c = oiProcessed.XC_WBE__c,
                XC_CMProfitCenter__c = oiProcessed.XC_CMProfitCenter__c,
                XC_CMCostCenter__c = oiProcessed.XC_CMCostCenter__c
            ));
            mapOrderItem.put(oiProcessed.Id, oiProcessed);
        }
        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true); 
        XC_UTIL_Sobject.updateListRecords(listOrderItemsToUpdate);
        for(NE__Order__c order: scope){
            order.XC_ForceWBERecalculation__c = false;
        }
        XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true); 
        XC_UTIL_Sobject.updateListRecords(scope);

        List<Asset> listAssetToUpdate = new List<Asset>();
        for(NE__OrderItem__c oi : listOrderItemFiltered) {
            if(mapOrderItem.containsKey(oi.Id)) {
                NE__OrderItem__c oiUpdated = mapOrderItem.get(oi.Id);
                for(Asset ass : oi.Assets__r) {
                    listAssetToUpdate.add(new Asset(
                        Id = ass.Id,
                        XC_WBE__c = oi.XC_WBE__c,
                        XC_CMProfitCenter__c = oi.XC_CMProfitCenter__c,
                        XC_CMCostCenter__c = oi.XC_CMCostCenter__c
                    ));
                }
            }
        }
        XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true); 
        XC_UTIL_Sobject.updateListRecords(listAssetToUpdate);
    } 
    
    /**
     * @description Finish method for batch
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Finish Batch XC_SC038_RecalculateWBE ');
    } 

}