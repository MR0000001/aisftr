/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 16/06/2021
* @description XC_SC057_FixECA – Batch to clone ECA for Catalog Item
*/

public without sharing class XC_SC057_FixECA implements Database.Batchable<sObject>, Schedulable {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC057_FixECA');

    /**
     * @description Method to schedule Batch
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC057_FixECA(), 50000);
    }  

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Start method for batch
     * @param bc - BatchableContext 
     * @return Database.getQueryLocator
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Retrieve global values from Custom Setting:
        List<String> listInvolvedCatalogs = XC_CS_UtilityGlobalValues__c.getInstance('CatalogNameToFixECA').Value__c.split(',');
        List<String> listExternalCatalog = XC_CS_UtilityGlobalValues__c.getInstance('ExternalCatalogNameToFixECA').Value__c.split(',');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Search Catalog Item not configured for Catalog Name (' + listInvolvedCatalogs + ') and External Catalog (' + listExternalCatalog + ')'); 
        // Retrieve all Catalog Items with no Billing ECAs:
        String query =  'SELECT Id, NE__Type__c, NE__ProductId__c,NE__ProductId__r.XC_Product_Type__c, NE__ProductId__r.XC_Product_Subtype__c, NE__Product_Name__c, NE__Catalog_Category_Name__c, NE__Catalog_Category_Name__r.name, NE__Catalog_Id__c,NE__Catalog_Id__r.name  ' +
                        'FROM NE__Catalog_Item__c ' +
                        'WHERE NE__Catalog_Id__r.Name IN :listInvolvedCatalogs ' +
                        'AND Id NOT IN ' + 
                            '(SELECT B2WExtCat__Commercial_Catalog_Item__c ' +
                            'FROM B2WExtCat__External_Catalog_Association__c ' +
                            'WHERE B2WExtCat__External_Catalog_Item__r.B2WExtCat__External_Catalog__r.B2WExtCat__External_Catalog_Name__c IN :listExternalCatalog) ';
        return Database.getQueryLocator(query);
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Execute method for batch
     * @param bc - BatchableContext
     * @param scope - List<NE__Catalog_Item__c> 
    */
    public void execute(Database.BatchableContext bc, List<NE__Catalog_Item__c> scope) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Catalog Items without ECAs: ' + scope.size());
        // Retrieve global values from Custom Setting:
        List<String> listInvolvedCatalogs = XC_CS_UtilityGlobalValues__c.getInstance('CatalogNameToFixECA').Value__c.split(',');
        List<String> listExternalCatalog = XC_CS_UtilityGlobalValues__c.getInstance('ExternalCatalogNameToFixECA').Value__c.split(',');
        // Retrieve all Catalog Items for Involved Catalog Categories with billing ECAs:
        Set<Id> involvedCatalogCategories = new Set<Id>();
        for(NE__Catalog_Item__c ci : scope) {
            if(String.isNotBlank(ci.NE__Catalog_Category_Name__c) && String.isNotBlank(ci.NE__Catalog_Id__c)) {
                involvedCatalogCategories.add(ci.NE__Catalog_Category_Name__c);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Involved Catalog Categories: ' + involvedCatalogCategories);
        String  queryTarget =   'SELECT Id, NE__Type__c, NE__ProductId__c, NE__ProductId__r.XC_Product_Type__c, NE__ProductId__r.XC_Product_Subtype__c, NE__Product_Name__c, NE__Catalog_Category_Name__c,NE__Catalog_Category_Name__r.name, NE__Catalog_Id__c,NE__Catalog_Id__r.name, (';
                queryTarget +=  XC_UTIL_Sobject.selectAllFieldsGetSelect('B2WExtCat__External_Catalog_Association__c');
                queryTarget +=  ' FROM B2WExtCat__External_Catalog_Associations__r' +
                                ' WHERE B2WExtCat__External_Catalog_Item__r.B2WExtCat__External_Catalog__r.B2WExtCat__External_Catalog_Name__c IN :listExternalCatalog) ' + 
                                ' FROM NE__Catalog_Item__c' +
                                ' WHERE NE__Catalog_Id__r.name IN :listInvolvedCatalogs' +
                                ' AND NE__Catalog_Category_Name__c IN :involvedCatalogCategories AND Id IN' +
                                ' (SELECT B2WExtCat__Commercial_Catalog_Item__c' +
                                ' FROM B2WExtCat__External_Catalog_Association__c' +
                                ' WHERE B2WExtCat__External_Catalog_Item__r.B2WExtCat__External_Catalog__r.B2WExtCat__External_Catalog_Name__c IN :listExternalCatalog'+
                                ' AND B2WExtCat__External_Catalog_Item__r.B2WExtCat__External_Catalog_Item_Code__c != null)';
        List<NE__Catalog_Item__c> targetCatalogItems = Database.query(queryTarget);
        /*List<NE__Catalog_Item__c> targetCatalogItems = new List<NE__Catalog_Item__c>([
            SELECT Id, NE__Type__c, NE__ProductId__c, NE__ProductId__r.XC_Product_Type__c, NE__ProductId__r.XC_Product_Subtype__c, NE__Product_Name__c, NE__Catalog_Category_Name__c,NE__Catalog_Category_Name__r.name, NE__Catalog_Id__c,NE__Catalog_Id__r.name, 
                (SELECT Id, B2WExtCat__Start_Date__c
                FROM B2WExtCat__External_Catalog_Associations__r 
                WHERE B2WExtCat__External_Catalog_Item__r.B2WExtCat__External_Catalog__r.B2WExtCat__External_Catalog_Name__c IN :listExternalCatalog) 
            FROM NE__Catalog_Item__c 
            WHERE NE__Catalog_Id__r.name IN :listInvolvedCatalogs 
                    AND NE__Catalog_Category_Name__c IN :involvedCatalogCategories
                    AND Id IN 
                        (SELECT B2WExtCat__Commercial_Catalog_Item__c 
                        FROM B2WExtCat__External_Catalog_Association__c 
                        WHERE B2WExtCat__External_Catalog_Item__r.B2WExtCat__External_Catalog__r.B2WExtCat__External_Catalog_Name__c IN :listExternalCatalog)]);*/
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Size target: ' + targetCatalogItems.size());

        // Create a map for targetCatalogItems with key = subtype+category+catalog+type
        Map<String, NE__Catalog_Item__c> targetcategoriesCatalogItemsMap = new Map<String, NE__Catalog_Item__c>();
        for(NE__Catalog_Item__c ci : targetCatalogItems) {
            String key = ci.NE__ProductId__r.XC_Product_Type__c + ci.NE__ProductId__r.XC_Product_Subtype__c + ci.NE__Catalog_Category_Name__c + ci.NE__Catalog_Id__c + ci.NE__Type__c;
            targetcategoriesCatalogItemsMap.put(key, ci);
        }      
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Map target Catalog Item: ' + targetcategoriesCatalogItemsMap); 
        
        // For each Catalog Items not configured, clone Billing ECAs if exists a configured catalog item configured to the same catalog, the same catalog category and the same subtype
        List<B2WExtCat__External_Catalog_Association__c> allNewEcas = new List<B2WExtCat__External_Catalog_Association__c>();
        for(NE__Catalog_Item__c ciNotConfigured : scope) {
            if(String.isNotBlank(ciNotConfigured.NE__ProductId__r.XC_Product_Type__c) && String.isNotBlank(ciNotConfigured.NE__ProductId__r.XC_Product_Subtype__c) && String.isNotBlank(ciNotConfigured.NE__Catalog_Category_Name__c) && String.isNotBlank(ciNotConfigured.NE__Catalog_Id__c) && String.isNotBlank(ciNotConfigured.NE__Type__c)) {
                String keyToSearch = ciNotConfigured.NE__ProductId__r.XC_Product_Type__c + ciNotConfigured.NE__ProductId__r.XC_Product_Subtype__c + ciNotConfigured.NE__Catalog_Category_Name__c + ciNotConfigured.NE__Catalog_Id__c + ciNotConfigured.NE__Type__c;
                if(String.isNotBlank(keyToSearch) && targetcategoriesCatalogItemsMap.containsKey(keyToSearch) && targetcategoriesCatalogItemsMap.get(keyToSearch) != null) {
                    NE__Catalog_Item__c targetCatalogItem = targetcategoriesCatalogItemsMap.get(keyToSearch);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Not configured: ' + ciNotConfigured.NE__Product_Name__c + '(' + ciNotConfigured.id + ', ' + ciNotConfigured.NE__Catalog_Category_Name__r.name + ', ' + ciNotConfigured.NE__Catalog_Id__r.name + ') ---> Configured: ' + targetCatalogItem.NE__Product_Name__c + '(' + targetCatalogItem.id + ', ' + targetCatalogItem.NE__Catalog_Category_Name__r.name + ', ' + targetCatalogItem.NE__Catalog_Id__r.name + ')');
                    allNewEcas.addAll(cloneECAs(ciNotConfigured, targetCatalogItem.B2WExtCat__External_Catalog_Associations__r));
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Size list: ' + allNewEcas.size());

        // DML operation:
        String valueInsertDML = XC_CS_UtilityGlobalValues__c.getInstance('InsertRecordsToFixECA').Value__c;
        if(valueInsertDML == 'true') {
            List<XC_UTIL_Sobject.WrapperResult> listDMLResult = XC_UTIL_Sobject.insertListRecords(allNewEcas);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Result DML: ' + listDMLResult[0]); 
            if(!XC_UTIL_Sobject.checkDMLResults(listDMLResult)) {
                XC_UTIL_Sobject.insertRecord(new XC_BatchErrorLog__c(
                    XC_TypeOfOperation__c = 'Fix ECA',
                    XC_ErrorMessage__c = 'Error to insert ' + String.valueOf(allNewEcas.size()) + ' ECAs: ' + listDMLResult[0].errorMessage
                ));
            } 
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Finish method for batch
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ FINISH batch XC_SC057_FixECA'); 
    } 

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 16/06/2021
     * @description Method to clone ECAs for Catalog Item not configured
     * @param ciNotConfigured - NE__Catalog_Item__c 
     * @param toBeClonedECAs - List<B2WExtCat__External_Catalog_Association__c>
     * @return List<B2WExtCat__External_Catalog_Association__c>
    */
    public static List<B2WExtCat__External_Catalog_Association__c> cloneECAs(NE__Catalog_Item__c ciNotConfigured, List<B2WExtCat__External_Catalog_Association__c> toBeClonedECAs){
        List<B2WExtCat__External_Catalog_Association__c> newEcas = new List<B2WExtCat__External_Catalog_Association__c>();
        for(B2WExtCat__External_Catalog_Association__c tbcEca : toBeClonedECAs) {
            B2WExtCat__External_Catalog_Association__c newEca = tbcEca.clone(false, true, false, false);
            newEca.B2WExtCat__Commercial_Catalog_Item__c = ciNotConfigured.id;
            newEca.B2WExtCat__Source_External_Catalog_Association__c = '';
            newEcas.add(newEca);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Catalog Item ' + ciNotConfigured.Id + ' there are created ' + newEcas.size() + ' ECAs'); 
        return newEcas;
    }

}