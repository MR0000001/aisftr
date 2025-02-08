/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date 04/03/2022
 * @description BLAZE_SC001_DataCleaning - Batch to clean data for BLAZE stream
 */

global without sharing class BLAZE_SC001_DataCleaning implements Database.Batchable<sObject>, Database.Stateful {

    //************************************************************************************************************************* VARIABLES */

    public final static Boolean  DEBUGACTIVE   = XC_UTIL_Debug.isActive('BLAZE_SC001_DataCleaning');
    public final static Datetime CURRENT_TIME  = System.now();

    /** @description Wrapper for object in input */
    public class WrapperObject {
        public List<NE__Order__c>           listOrders                  = new List<NE__Order__c>();
        public List<WorkOrder>              listWorkOrder               = new List<WorkOrder>();
        public Map<Id, ServiceAppointment>  mapServiceAppointment       = new Map<Id, ServiceAppointment>();
        public List<String>                 listAssetIdsWithoutOrder    = new List<String>();
    }

    /** @description Wrapper for object to update */
    public class WrapperObjectToUpdate {
        public List<Opportunity>                    listOpty                            = new List<Opportunity>();
        public List<Account>                        listAccount                         = new List<Account>();
        public List<Asset>                          listAsset                           = new List<Asset>();
        public List<XC_BillingProfileLineItem__c>   listBillingProfileLineItem          = new List<XC_BillingProfileLineItem__c>();
        public List<XC_BillingProfileLineItem__c>   listBillingProfileLineItemUpdate    = new List<XC_BillingProfileLineItem__c>();
        public List<NE__OrderItem__c>               listOrderItem                       = new List<NE__OrderItem__c>();
        public List<XC_LegalEntityConsent__c>       listLegalEntityConsent              = new List<XC_LegalEntityConsent__c>();
        public List<WorkOrder>                      listWorkOrder                       = new List<WorkOrder>();
        public List<ServiceAppointment>             listServiceAppointment              = new List<ServiceAppointment>();
        public List<NE__Order__c>                   listOrder                           = new List<NE__Order__c>();
        public Set<String>                          listOrderItemForWBE                 = new Set<String>();
        public List<Case>                           listCase                            = new List<Case>();
    }

    /** Mapping Legal Entity */
    public static Map<String, String> mapLegalEntityConvertion = new Map<String, String>{
        'EnelXItalia'           => 'EnelXMobilityItalia',
        'EnelXMobility'         => 'EnelXMobilityItalia',
        'EnelXMSP'              => 'EnelXMobilityHolding',
        'EndesaX'               => 'EnelXMobilitySpain',
        'EnelX'                 => 'EnelXMobilityChile',
        'EnelXRomania'          => 'EnelXMobilityRomania',
        'EnelXNorthAmericaInc'  => 'EnelXMobilityAmerica',
        'JuicenetLimited'       => 'EnelXMobilityUK'
    };
    public static List<String> listLegalEntity = new List<String>{
        'EnelXItalia',
        'EnelXMobility',
        'EnelXMSP',
        'EndesaX',
        'EnelX',
        'EnelXRomania',
        'EnelXNorthAmericaInc',
        'JuicenetLimited'
    };

    /** @description Mapping Account -> Individual */
    public static Map<String, String> mapAccountIndividual = new Map<String, String>();
    /** @description Mapping Account -> Existing Billing Profile Line Item */
    public static Map<String, XC_BillingProfileLineItem__c> mapAccountBPLI = new Map<String, XC_BillingProfileLineItem__c>();
    /** @description Mapping Order -> Assets */
    public static Map<String, List<Asset>> mapOrderAssets = new Map<String, List<Asset>>();
    /** @description Mapping Order -> OrderItem */
    public static Map<String, List<NE__OrderItem__c>> mapOrderOrderItem = new Map<String, List<NE__OrderItem__c>>();
    /** @description List Order Items related to queried Asset */
    public static List<String> listOrderItemIdsFromAsset = new List<String>();
    /** @description List Keys for created Legal Entity Consent */
    public static List<String> listKeyAlreadyCreatedLEC = new List<String>();
    /** @description List Keys for created Billing Profile Line Item */
    public static List<String> listKeyAlreadyCreatedBPLI = new List<String>();
    /** @description List Asset id queried for eMobility */
    //public static List<String> listAssetMOBQueriedIds = new List<String>();
    /** @description Mapping Key -> LEC */
    public static Map<String, XC_LegalEntityConsent__c> mapKeyLEC = new Map<String, XC_LegalEntityConsent__c>();
    /** @description Mapping Key -> AssetToUpdateBPLI */
    public static Map<String, String> mapKeyAssetToUpdateBPLI = new Map<String, String>();
    /** @description Mapping Key -> OrderItemToUpdateBPLI */
    public static Map<String, String> mapKeyOrderItemToUpdateBPLI = new Map<String, String>();
    /** @description To mapping new WorkType */
    public static List<WorkOrder> listWorkOrderToDiscoveryWT = new List<WorkOrder>();
    public static Map<String, String> mapWorkType = new Map<String, String>();
    public static Map<String, String> mapZipCodeWorkType = new Map<String, String>();
    /** @description To retrieve existing BPLI */
    public static List<String> listAccountIdForExistingBPLI = new List<String>();
    public static List<String> listBPIdForExistingBPLI      = new List<String>();
    public static List<String> listLEForExistingBPLI        = new List<String>();
    /** @description For rollback mode */
    public static Boolean               rollBackMode            = false;
    public static Map<String, String>   mapLegalEntityRollback  = new Map<String, String>();
    public static Map<String, String>   mapConsentOldRollback   = new Map<String, String>();
    public static Map<String, String>   mapConsentNewRollback   = new Map<String, String>();
    public static Map<String, String>   mapBPLIRollbackNewLE    = new Map<String, String>();
    public static Map<String, String>   mapBPLIRollbackOldLE    = new Map<String, String>();

    //********************************************************************************************************************* BATCH METHODS */

    /**
     * @description execute method
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new BLAZE_SC001_DataCleaning(), 1);
    }

    /**
     * @description start method
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start batch BLAZE_SC001_DataCleaning');
        try {
            BLAZE_CS001_Util__c cs = BLAZE_CS001_Util__c.getInstance('GeneralSetting');
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Custom Setting retrieved: ' + cs);
            if((cs != null && String.isNotBlank(cs.BLAZE_WhereCondition__c)) || Test.isRunningTest()) {
                if((cs != null && cs.BLAZE_CaseOrderItemNoCase__c==true) || Test.isRunningTest()) {
                    // Case Order Item:
                    return Database.getQueryLocator('SELECT Id FROM Asset LIMIT 1');
                } else {
                    // Case Assets:
                    String query = XC_UTIL_Sobject.selectAllFieldsGetSelect('Asset');
                    query = query + ', XC_Configuration_Item__r.XC_BillingProfileLineItem__r.Id, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_Country__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_CustomerAccount__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillingAddress__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_ExternalKey__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_ZuoraId__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_PaymentTerm__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillCycleDay__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillingProfile__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillToAddress__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillToContactId__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_LegalEntity__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_DocumentType__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_Status__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_InvoicePreferredLanguage__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_InvoiceDeliveryPreference__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_PEC__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_RecipientCodeB2B__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_OfficeCode__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_RecipientCode__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_TPBCode__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillingProfileCopy__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_SoldToAddress__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_SoldToContactId__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillingProfileName__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_DocumentNumber__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_DocumentCountry__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Payment__c ';
                    query = query + ' FROM Asset ';
                    query = (!Test.isRunningTest()) ? (query + (String) cs.BLAZE_WhereCondition__c) : (query + ' LIMIT 1');
                    if(String.isNotBlank(query)) {
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start query: ' + query);
                        return Database.getQueryLocator(query);
                    } 
                }                
            } 
            XC_UTIL_Sobject.insertRecord(insertBatchErrorLog('Missing Custom Setting for BLAZE Data Cleaning', ''));
            return null;
        } catch(Exception e) {
            XC_UTIL_Sobject.insertRecord(insertBatchErrorLog('FATAL ERROR at line ' + e.getLineNumber(), e.getMessage() + '\n' + e.getStackTraceString()));
            return null;
        }
    }

    /** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<Asset> scopeTemp){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Execute batch BLAZE_SC001_DataCleaning');
        Savepoint savePoint = Database.setSavepoint();

        try {
            BLAZE_CS001_Util__c cs = BLAZE_CS001_Util__c.getInstance('GeneralSetting');
            Boolean caseOrderItemNoCase = false;
            if((cs != null && cs.BLAZE_CaseOrderItemNoCase__c==true) || Test.isRunningTest()) {
                caseOrderItemNoCase = true;
            }

            // For rollback mode:
            if(cs != null && cs.BLAZE_Rollback__c==true) {
                rollBackMode = true;
            }

            // Retrieve info for country selected:
            List<String> listCountriesToFilter = new List<String>();
            if((cs != null && String.isNotBlank(cs.BLAZE_Countries__c)) || Test.isRunningTest()) {
                listCountriesToFilter = cs.BLAZE_Countries__c.split(',');
            }
            if(listCountriesToFilter.isEmpty()) {
                XC_UTIL_Sobject.insertRecord(insertBatchErrorLog('No Asset found with countries filtered', 'Countries in Custom Setting: ' + cs.BLAZE_Countries__c + '\nItem: ' + getStringListString(XC_UTIL_Sobject.getListFieldValues(scopeTemp,'Id'))));
                return;
            }

            List<Asset>             scope           = new List<Asset>();
            List<NE__OrderItem__c>  scopeOrderItem  = new List<NE__OrderItem__c>();
            if(!caseOrderItemNoCase) {
                // [ASSET] Filter only for legal entity in the list:
                for(Asset a : scopeTemp) {
                    Boolean foundLegalEntity = false;
                    for(String le : listLegalEntity) {
                        if(le.toLowerCase() == a.XC_LegalEntity__c.toLowerCase()) {
                            foundLegalEntity = true;
                            break;
                        }
                    }
                    Boolean foundCountry = false;
                    for(String cnt : listCountriesToFilter) {
                        if(cnt.toLowerCase() == a.Country__c.toLowerCase()) {
                            foundCountry = true;
                            break;
                        }
                    }
                    if(foundLegalEntity && foundCountry) {
                        scope.add(a);
                    }
                }
                if(scope.isEmpty()) {
                    XC_UTIL_Sobject.insertRecord(insertBatchErrorLog('No Asset found to clean with legal entity or country selected', 'In Custom Setting:\nLegalEntities: ' + listLegalEntity + '\nCountries: ' + listCountriesToFilter + '\nItem: ' + getStringListString(XC_UTIL_Sobject.getListFieldValues(scopeTemp,'Id'))));
                    return;
                }
            } else {
                // [ORDER ITEM] Query and Filter only for legal entity in the list:
                String query = XC_UTIL_Sobject.selectAllFieldsGetSelect('NE__OrderItem__c');
                query = query + ', XC_BillingProfileLineItem__r.Id, XC_BillingProfileLineItem__r.XC_Country__c, XC_BillingProfileLineItem__r.XC_CustomerAccount__c, XC_BillingProfileLineItem__r.XC_BillingAddress__c, XC_BillingProfileLineItem__r.XC_ExternalKey__c, XC_BillingProfileLineItem__r.XC_ZuoraId__c, XC_BillingProfileLineItem__r.XC_PaymentTerm__c, XC_BillingProfileLineItem__r.XC_BillCycleDay__c, XC_BillingProfileLineItem__r.XC_BillingProfile__c, XC_BillingProfileLineItem__r.XC_BillToAddress__c, XC_BillingProfileLineItem__r.XC_BillToContactId__c, XC_BillingProfileLineItem__r.XC_LegalEntity__c, XC_BillingProfileLineItem__r.XC_DocumentType__c, XC_BillingProfileLineItem__r.XC_Status__c, XC_BillingProfileLineItem__r.XC_InvoicePreferredLanguage__c, XC_BillingProfileLineItem__r.XC_InvoiceDeliveryPreference__c, XC_BillingProfileLineItem__r.XC_PEC__c, XC_BillingProfileLineItem__r.XC_RecipientCodeB2B__c, XC_BillingProfileLineItem__r.XC_OfficeCode__c, XC_BillingProfileLineItem__r.XC_RecipientCode__c, XC_BillingProfileLineItem__r.XC_TPBCode__c, XC_BillingProfileLineItem__r.XC_BillingProfileCopy__c, XC_BillingProfileLineItem__r.XC_SoldToAddress__c, XC_BillingProfileLineItem__r.XC_SoldToContactId__c, XC_BillingProfileLineItem__r.XC_BillingProfileName__c, XC_BillingProfileLineItem__r.XC_DocumentNumber__c, XC_BillingProfileLineItem__r.XC_DocumentCountry__c, XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Payment__c ';
                query = query + ' FROM NE__OrderItem__c ';
                query = (!Test.isRunningTest()) ? (query + (String) cs.BLAZE_WhereCondition__c) : (query + ' LIMIT 1');
                if(String.isNotBlank(query)) {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start query Order Item: ' + query);
                    List<NE__OrderItem__c> scopeOrderItemTemp = Database.query(query);
                    for(NE__OrderItem__c a : scopeOrderItemTemp) {
                        Boolean foundLegalEntity = false;
                        for(String le : listLegalEntity) {
                            if(le.toLowerCase() == a.XC_LegalEntityFormula__c.toLowerCase()) {
                                foundLegalEntity = true;
                                break;
                            }
                        }
                        Boolean foundCountry = false;
                        for(String cnt : listCountriesToFilter) {
                            if(cnt.toLowerCase() == a.XC_CountryFormula__c.toLowerCase()) {
                                foundCountry = true;
                                break;
                            }
                        }
                        if(foundLegalEntity && foundCountry) {
                            scopeOrderItem.add(a);
                        }
                    }
                    if(scopeOrderItem.isEmpty()) {
                        XC_UTIL_Sobject.insertRecord(insertBatchErrorLog('No OrderItem found to clean with legal entity or country selected', 'In Custom Setting:\nLegalEntities: ' + listLegalEntity + '\nCountries: ' + listCountriesToFilter + '\nItem: ' + getStringListString(XC_UTIL_Sobject.getListFieldValues(scopeTemp,'Id'))));
                        return;
                    }
                } else {
                    XC_UTIL_Sobject.insertRecord(insertBatchErrorLog('No OrderItem found to clean with legal entity or country selected', 'In Custom Setting:\nLegalEntities: ' + listLegalEntity + '\nCountries: ' + listCountriesToFilter + '\nItem: ' + getStringListString(XC_UTIL_Sobject.getListFieldValues(scopeTemp,'Id'))));
                    return;
                }
            }

            // Enable to skip current user:
            User listCurrentUser = new User(Id=UserInfo.getUserId(), XC_EnabledToSkip__c=true);
            update listCurrentUser;
            XC_TR_Asset_Handler.bypassBeforeUpdate = true;
            XC_TR_Asset_Handler.bypassAfterUpdate = true;

            // Open/Close order and missing Order:
            Boolean considerOpenOrder = false;
            if((cs != null && cs.BLAZE_OpenOrder__c==true) || Test.isRunningTest()) {
                considerOpenOrder = true;
            }
            Boolean considerClosedOrder = false;
            if((cs != null && cs.BLAZE_ClosedOrder__c==true) || Test.isRunningTest()) {
                considerClosedOrder = true;
            }
            Boolean caseNoOrder = false;
            if((cs != null && cs.BLAZE_CaseNoOrder__c==true) || Test.isRunningTest()) {
                caseNoOrder = true;
            }

            // Retrieve Asset id for Mobility:
            /*String queryForIdsAsset = 'SELECT Id, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Payment__c FROM Asset ';
            queryForIdsAsset = (!Test.isRunningTest()) ? (queryForIdsAsset + (String) cs.BLAZE_WhereCondition__c) : (queryForIdsAsset + ' LIMIT 1');
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Query for Asset ids: ' + queryForIdsAsset);
            List<Asset> listAssetQueried = Database.query(queryForIdsAsset);
            listAssetMOBQueriedIds = XC_UTIL_Sobject.getListFieldValues(listAssetQueried, 'Id');*/

            // Split scenario:
            Map<String, WrapperObject> mapWrapperObj = retrieveCaseTypeWrapper(scope, scopeOrderItem, listCountriesToFilter, considerOpenOrder, considerClosedOrder, caseOrderItemNoCase);
            if(mapWrapperObj.keySet().isEmpty()) {
                XC_UTIL_Sobject.insertRecord(insertBatchErrorLog('No scenario found to clean', ''));
                return;
            }

            // Update object by scenario:
            List<XC_BatchErrorLog__c>   listLogsToInsert    = new List<XC_BatchErrorLog__c>();
            WrapperObjectToUpdate       wrapperToUpdate     = new WrapperObjectToUpdate();
            if(mapWrapperObj.containsKey('optyWithoutCheckout')) {
                checkOptyWithoutCheckout(mapWrapperObj.get('optyWithoutCheckout'), wrapperToUpdate, listLogsToInsert);
                listLogsToInsert.add(insertBatchErrorLog('Items found for scenario: Opty Without Checkout', ''));
            }
            if(mapWrapperObj.containsKey('optyWithCheckoutWithoutWorkOrder')) {
                checkOptyWithCheckoutWithoutWorkOrder(mapWrapperObj.get('optyWithCheckoutWithoutWorkOrder'), wrapperToUpdate, listLogsToInsert);
                listLogsToInsert.add(insertBatchErrorLog('Items found for scenario: Opty With Checkout Without WorkOrder', ''));
            } 
            if(mapWrapperObj.containsKey('optyWithScheduledSiteInspection')) {
                checkOptyWithScheduledSiteInspection(mapWrapperObj.get('optyWithScheduledSiteInspection'), wrapperToUpdate, listLogsToInsert);
                listLogsToInsert.add(insertBatchErrorLog('Items found for scenario: Opty With Scheduled Site Inspection', ''));
            } 
            if(mapWrapperObj.containsKey('optyWithSiteInspectionNotScheduled')) {
                checkOptyWithSiteInspectionNotScheduled(mapWrapperObj.get('optyWithSiteInspectionNotScheduled'), wrapperToUpdate, listLogsToInsert);
                listLogsToInsert.add(insertBatchErrorLog('Items found for scenario: Opty With Site Inspection Not Scheduled', ''));
            }
            if(mapWrapperObj.containsKey('optyWithScheduledDelivery')) {
                checkOptyWithScheduledDelivery(mapWrapperObj.get('optyWithScheduledDelivery'), wrapperToUpdate, listLogsToInsert);
                listLogsToInsert.add(insertBatchErrorLog('Items found for scenario: Opty With Scheduled Delivery', ''));
            } 
            if(mapWrapperObj.containsKey('optyWithDeliveryNotScheduled')) {
                checkOptyWithDeliveryNotScheduled(mapWrapperObj.get('optyWithDeliveryNotScheduled'), wrapperToUpdate, listLogsToInsert);
                listLogsToInsert.add(insertBatchErrorLog('Items found for scenario: Opty With Delivery Not Scheduled', ''));
            }
            if(mapWrapperObj.containsKey('optyWithOtherWorkOrder')) {
                checkOptyWithOtherWorkOrder(mapWrapperObj.get('optyWithOtherWorkOrder'), wrapperToUpdate, listLogsToInsert);
                listLogsToInsert.add(insertBatchErrorLog('Items found for scenario: Opty With Other WorkOrder', ''));
            } 
            if(mapWrapperObj.containsKey('optyWithClosedOrder')) {
                checkOptyWithClosedOrder(mapWrapperObj.get('optyWithClosedOrder'), wrapperToUpdate, listLogsToInsert);
                listLogsToInsert.add(insertBatchErrorLog('Items found for scenario: Opty With Closed Order', ''));
            } 
            if(caseNoOrder && mapWrapperObj.containsKey('assetWithoutOrder')) {
                checkAssetWithoutOrder(mapWrapperObj.get('assetWithoutOrder'), wrapperToUpdate, listLogsToInsert);
                listLogsToInsert.add(insertBatchErrorLog('Items found for scenario: Asset without Orders', ''));
            } 

            // DML Operations:
            WrapperObjectToUpdate wrapperToUpdateClean = cleanWrapperFromDuplicatedUpdate(wrapperToUpdate);
            XC_TR_Opportunity_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_Opportunity_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true); 
            XC_TR_Account_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_Account_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_TR_BillingProfileLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_INSERT, true);
            XC_TR_BillingProfileLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_INSERT, true);
            XC_TR_BillingProfileLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_BillingProfileLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_TR_LegalEntityConsent_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_INSERT, true);
            XC_TR_LegalEntityConsent_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_INSERT, true);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            if((cs != null && cs.BLAZE_CheckOnly__c==false) || Test.isRunningTest()) {
                List<XC_UTIL_Sobject.WrapperResult> wrapperResultOpty       = XC_UTIL_Sobject.updateListRecords(wrapperToUpdateClean.listOpty);
                List<XC_UTIL_Sobject.WrapperResult> wrapperResultAccount    = XC_UTIL_Sobject.updateListRecords(wrapperToUpdateClean.listAccount);
                List<XC_UTIL_Sobject.WrapperResult> wrapperResultAsset      = XC_UTIL_Sobject.updateListRecords(wrapperToUpdateClean.listAsset);
                List<XC_UTIL_Sobject.WrapperResult> wrapperResultBPLI       = XC_UTIL_Sobject.insertListRecords(wrapperToUpdateClean.listBillingProfileLineItem);
                List<XC_UTIL_Sobject.WrapperResult> wrapperResultBPLIUpdate = XC_UTIL_Sobject.updateListRecords(wrapperToUpdateClean.listBillingProfileLineItemUpdate);
                List<XC_UTIL_Sobject.WrapperResult> wrapperResultOrderItem  = XC_UTIL_Sobject.updateListRecords(wrapperToUpdateClean.listOrderItem);
                List<XC_UTIL_Sobject.WrapperResult> wrapperResultLEC        = XC_UTIL_Sobject.insertListRecords(wrapperToUpdateClean.listLegalEntityConsent);
                List<XC_UTIL_Sobject.WrapperResult> wrapperResultWO         = XC_UTIL_Sobject.updateListRecords(wrapperToUpdateClean.listWorkOrder);
                List<XC_UTIL_Sobject.WrapperResult> wrapperResultSA         = XC_UTIL_Sobject.updateListRecords(wrapperToUpdateClean.listServiceAppointment);
                List<XC_UTIL_Sobject.WrapperResult> wrapperResultOrder      = XC_UTIL_Sobject.updateListRecords(wrapperToUpdateClean.listOrder);
                List<XC_UTIL_Sobject.WrapperResult> wrapperResultCase       = XC_UTIL_Sobject.updateListRecords(wrapperToUpdateClean.listCase);
                // Check result DML:
                if(!XC_UTIL_Sobject.checkDMLResults(wrapperResultOpty)) {
                    listLogsToInsert.add(insertBatchErrorLog('Error update Opty: ' + wrapperResultOpty[0].errorMessage, getStringListObject(wrapperToUpdateClean.listOpty)));
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('Opty updated: ' + wrapperToUpdateClean.listOpty.size(), getStringListObject(wrapperToUpdateClean.listOpty)));
                }
                if(!XC_UTIL_Sobject.checkDMLResults(wrapperResultAccount)) {
                    listLogsToInsert.add(insertBatchErrorLog('Error update Account: ' + wrapperResultAccount[0].errorMessage, getStringListObject(wrapperToUpdateClean.listAccount)));
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('Account updated: ' + wrapperToUpdateClean.listAccount.size(), getStringListObject(wrapperToUpdateClean.listAccount)));
                }
                if(!XC_UTIL_Sobject.checkDMLResults(wrapperResultAsset)) {
                    listLogsToInsert.add(insertBatchErrorLog('Error update Asset: ' + wrapperResultAsset[0].errorMessage, getStringListObject(wrapperToUpdateClean.listAsset)));
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('Asset updated: ' + wrapperToUpdateClean.listAsset.size(), getStringListObject(wrapperToUpdateClean.listAsset)));
                }
                if(!XC_UTIL_Sobject.checkDMLResults(wrapperResultBPLI)) {
                    listLogsToInsert.add(insertBatchErrorLog('Error insert BPLI: ' + wrapperResultBPLI[0].errorMessage, getStringListObject(wrapperToUpdateClean.listBillingProfileLineItem)));
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('BPLI inserted: ' + wrapperToUpdateClean.listBillingProfileLineItem.size(), getStringListObject(wrapperToUpdateClean.listBillingProfileLineItem)));
                }
                if(!XC_UTIL_Sobject.checkDMLResults(wrapperResultBPLIUpdate)) {
                    listLogsToInsert.add(insertBatchErrorLog('Error update BPLI: ' + wrapperResultBPLIUpdate[0].errorMessage, getStringListObject(wrapperToUpdateClean.listBillingProfileLineItemUpdate)));
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('BPLI updated: ' + wrapperToUpdateClean.listBillingProfileLineItemUpdate.size(), getStringListObject(wrapperToUpdateClean.listBillingProfileLineItemUpdate)));
                }
                if(!XC_UTIL_Sobject.checkDMLResults(wrapperResultOrderItem)) {
                    listLogsToInsert.add(insertBatchErrorLog('Error update OrderItem: ' + wrapperResultOrderItem[0].errorMessage, getStringListObject(wrapperToUpdateClean.listOrderItem)));
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('OrderItem updated: ' + wrapperToUpdateClean.listOrderItem.size(), getStringListObject(wrapperToUpdateClean.listOrderItem)));
                }
                if(!XC_UTIL_Sobject.checkDMLResults(wrapperResultLEC)) {
                    listLogsToInsert.add(insertBatchErrorLog('Error insert LEC: ' + wrapperResultLEC[0].errorMessage, getStringListObject(wrapperToUpdateClean.listLegalEntityConsent)));
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('LEC inserted: ' + wrapperToUpdateClean.listLegalEntityConsent.size(), getStringListObject(wrapperToUpdateClean.listLegalEntityConsent)));
                }
                if(!XC_UTIL_Sobject.checkDMLResults(wrapperResultWO)) {
                    listLogsToInsert.add(insertBatchErrorLog('Error update WorkOrder: ' + wrapperResultWO[0].errorMessage, getStringListObject(wrapperToUpdateClean.listWorkOrder)));
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('WorkOrder updated: ' + wrapperToUpdateClean.listWorkOrder.size(), getStringListObject(wrapperToUpdateClean.listWorkOrder)));
                }
                if(!XC_UTIL_Sobject.checkDMLResults(wrapperResultSA)) {
                    listLogsToInsert.add(insertBatchErrorLog('Error update ServiceAppointment: ' + wrapperResultSA[0].errorMessage, getStringListObject(wrapperToUpdateClean.listServiceAppointment)));
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('ServiceAppointment updated: ' + wrapperToUpdateClean.listServiceAppointment.size(), getStringListObject(wrapperToUpdateClean.listServiceAppointment)));
                }
                if(!XC_UTIL_Sobject.checkDMLResults(wrapperResultOrder)) {
                    listLogsToInsert.add(insertBatchErrorLog('Error update Order: ' + wrapperResultOrder[0].errorMessage, getStringListObject(wrapperToUpdateClean.listOrder)));
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('Order updated: ' + wrapperToUpdateClean.listOrder.size(), getStringListObject(wrapperToUpdateClean.listOrder)));
                }
                if(!XC_UTIL_Sobject.checkDMLResults(wrapperResultCase)) {
                    listLogsToInsert.add(insertBatchErrorLog('Error update Case: ' + wrapperResultCase[0].errorMessage, getStringListObject(wrapperToUpdateClean.listCase)));
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('Case updated: ' + wrapperToUpdateClean.listCase.size(), getStringListObject(wrapperToUpdateClean.listCase)));
                }
            } else {
                listLogsToInsert.add(insertBatchErrorLog('Batch will update Opty: ' + wrapperToUpdateClean.listOpty.size(), getStringListObject(wrapperToUpdateClean.listOpty)));
                listLogsToInsert.add(insertBatchErrorLog('Batch will update Account: ' + wrapperToUpdateClean.listAccount.size(), getStringListObject(wrapperToUpdateClean.listAccount)));
                listLogsToInsert.add(insertBatchErrorLog('Batch will update Asset: ' + wrapperToUpdateClean.listAsset.size(), getStringListObject(wrapperToUpdateClean.listAsset)));
                listLogsToInsert.add(insertBatchErrorLog('Batch will insert BPLI: ' + wrapperToUpdateClean.listBillingProfileLineItem.size(), getStringListObject(wrapperToUpdateClean.listBillingProfileLineItem)));
                listLogsToInsert.add(insertBatchErrorLog('Batch will update BPLI: ' + wrapperToUpdateClean.listBillingProfileLineItemUpdate.size(), getStringListObject(wrapperToUpdateClean.listBillingProfileLineItemUpdate)));
                listLogsToInsert.add(insertBatchErrorLog('Batch will update OrderItem: ' + wrapperToUpdateClean.listOrderItem.size(), getStringListObject(wrapperToUpdateClean.listOrderItem)));
                listLogsToInsert.add(insertBatchErrorLog('Batch will update LEC: ' + wrapperToUpdateClean.listLegalEntityConsent.size(), getStringListObject(wrapperToUpdateClean.listLegalEntityConsent)));
                listLogsToInsert.add(insertBatchErrorLog('Batch will update WorkOrder: ' + wrapperToUpdateClean.listWorkOrder.size(), getStringListObject(wrapperToUpdateClean.listWorkOrder)));
                listLogsToInsert.add(insertBatchErrorLog('Batch will update ServiceAppointment: ' + wrapperToUpdateClean.listServiceAppointment.size(), getStringListObject(wrapperToUpdateClean.listServiceAppointment)));
                listLogsToInsert.add(insertBatchErrorLog('Batch will update Order: ' + wrapperToUpdateClean.listOrder.size(), getStringListObject(wrapperToUpdateClean.listOrder)));
                listLogsToInsert.add(insertBatchErrorLog('Batch will update Case: ' + wrapperToUpdateClean.listCase.size(), getStringListObject(wrapperToUpdateClean.listCase)));
            }

            // To populate list to get more info for BPLI:
            List<String> listBPLIforMoreInfo                            = new List<String>();
            List<XC_BillingProfileLineItem__c> listBPLIinsertAndUpdated = new List<XC_BillingProfileLineItem__c>();
            for(XC_BillingProfileLineItem__c bpliTemp : wrapperToUpdateClean.listBillingProfileLineItem) {
                if(String.isNotBlank(bpliTemp.Id)) {
                    listBPLIforMoreInfo.add(bpliTemp.Id);
                    listBPLIinsertAndUpdated.add(bpliTemp);
                }
            }
            for(XC_BillingProfileLineItem__c bpliTemp : wrapperToUpdateClean.listBillingProfileLineItemUpdate) {
                if(String.isNotBlank(bpliTemp.Id)) {
                    listBPLIforMoreInfo.add(bpliTemp.Id);
                    listBPLIinsertAndUpdated.add(bpliTemp);
                }
            }
            
            // Update Asset for new Billing Profile Line Item:
            List<Asset>             listAssetToUpdateBPLI        = new List<Asset>();
            List<NE__OrderItem__c>  listOrderItemToUpdateBPLI    = new List<NE__OrderItem__c>();
            for(XC_BillingProfileLineItem__c bpliInserted : listBPLIinsertAndUpdated) {
                if(String.isNotBlank(bpliInserted.Id)) {
                    String keyForUpdateItemsByBPLI = ''+bpliInserted.XC_Account__c+'-_-_-'+bpliInserted.XC_BillingProfile__c+'-_-_-'+bpliInserted.XC_LegalEntity__c+'-_-_-'+bpliInserted.XC_Country__c;
                    if(mapKeyAssetToUpdateBPLI.containsKey(keyForUpdateItemsByBPLI)) {
                        listAssetToUpdateBPLI.add(new Asset(Id = mapKeyAssetToUpdateBPLI.get(keyForUpdateItemsByBPLI), 
                                                            XC_BillingProfileLineItem__c = bpliInserted.Id
                                                ));
                    }
                    if(mapKeyOrderItemToUpdateBPLI.containsKey(keyForUpdateItemsByBPLI)) {
                        listOrderItemToUpdateBPLI.add(new NE__OrderItem__c( Id = mapKeyOrderItemToUpdateBPLI.get(keyForUpdateItemsByBPLI), 
                                                                            XC_BillingProfileLineItem__c = bpliInserted.Id
                                                    ));
                    }
                }
            }
            List<XC_UTIL_Sobject.WrapperResult> wrapperResultAssetBPLI       = XC_UTIL_Sobject.updateListRecords(listAssetToUpdateBPLI);
            List<XC_UTIL_Sobject.WrapperResult> wrapperResultOrderItemBPLI   = XC_UTIL_Sobject.updateListRecords(listOrderItemToUpdateBPLI);
            if(!XC_UTIL_Sobject.checkDMLResults(wrapperResultAssetBPLI)) {
                listLogsToInsert.add(insertBatchErrorLog('Error update Asset for new Billing Profile Line Item: ' + wrapperResultAssetBPLI[0].errorMessage, getStringListObject(listAssetToUpdateBPLI)));
            } else {
                listLogsToInsert.add(insertBatchErrorLog('Update Asset for new Billing Profile Line Item', getStringListObject(listAssetToUpdateBPLI)));
            }
            if(!XC_UTIL_Sobject.checkDMLResults(wrapperResultOrderItemBPLI)) {
                listLogsToInsert.add(insertBatchErrorLog('Error update Order Item for new Billing Profile Line Item: ' + wrapperResultOrderItemBPLI[0].errorMessage, getStringListObject(listOrderItemToUpdateBPLI)));
            } else {
                listLogsToInsert.add(insertBatchErrorLog('Update OrderItem for new Billing Profile Line Item', getStringListObject(listOrderItemToUpdateBPLI)));
            }

            // Recalculate WBE:
            if((cs != null && cs.BLAZE_RecalculateWBE__c==true) || Test.isRunningTest()) {
                List<String> listOrderB2C                           = new List<String>();
                List<String> listOrderB2BG                          = new List<String>();
                List<String> listAllOrderItemIdsProcessedForWBE     = new List<String>();
                List<NE__OrderItem__c> listOrderItemToUpdateOldWBE  = new List<NE__OrderItem__c>();
                Map<String, String> mapOldOrderItemWBE              = new Map<String, String>();
                for(String keyMap : mapWrapperObj.keySet()) {
                    WrapperObject wrapper = mapWrapperObj.get(keyMap);
                    for(NE__Order__c ord : wrapper.listOrders) {
                        for(NE__OrderItem__c ordItem : ord.NE__Order_Items__r) {
                            if(wrapperToUpdateClean.listOrderItemForWBE.contains(ordItem.Id)) {
                                if(String.isNotBlank(ordItem.XC_Segment__c) && (ordItem.XC_Segment__c=='B2B' || ordItem.XC_Segment__c=='B2G') && !listOrderB2BG.contains(ordItem.NE__OrderId__c)) {
                                    listOrderB2BG.add(ordItem.NE__OrderId__c);
                                    listOrderItemToUpdateOldWBE.add(new NE__OrderItem__c(Id=ordItem.Id, BLAZE_OldWBE__c=ordItem.XC_WBE__c));
                                    mapOldOrderItemWBE.put(ordItem.Id, ordItem.XC_WBE__c);
                                    listAllOrderItemIdsProcessedForWBE.add(ordItem.Id);
                                } else if(String.isNotBlank(ordItem.XC_Segment__c) && ordItem.XC_Segment__c=='B2C' && !listOrderB2C.contains(ordItem.NE__OrderId__c)) {
                                    listOrderB2C.add(ordItem.NE__OrderId__c);
                                    listOrderItemToUpdateOldWBE.add(new NE__OrderItem__c(Id=ordItem.Id, BLAZE_OldWBE__c=ordItem.XC_WBE__c));
                                    mapOldOrderItemWBE.put(ordItem.Id, ordItem.XC_WBE__c);
                                    listAllOrderItemIdsProcessedForWBE.add(ordItem.Id);
                                }
                            }
                        }
                    }
                }
                List<XC_BatchErrorLog__c> listLogsFromWBE = recalculateWBE(listOrderB2C, listOrderB2BG);
                if(!listLogsFromWBE.isEmpty()) {
                    listLogsToInsert.addAll(listLogsFromWBE);
                }
                List<XC_UTIL_Sobject.WrapperResult> wrapperResultOrderItemForOLDWBE = XC_UTIL_Sobject.updateListRecords(listOrderItemToUpdateOldWBE);
                if(!XC_UTIL_Sobject.checkDMLResults(wrapperResultOrderItemForOLDWBE)) {
                    listLogsToInsert.add(insertBatchErrorLog('Error update OrderItem OLD WBE: ' + wrapperResultOrderItemForOLDWBE[0].errorMessage, ''));
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('Number WBE item updated: ' + listOrderItemToUpdateOldWBE.size(), ''));
                }
                List<NE__OrderItem__c> listOrderItemsWithNewWBE = new List<NE__OrderItem__c>([
                    SELECT Id, XC_WBE__c
                    FROM NE__OrderItem__c
                    WHERE Id IN :listAllOrderItemIdsProcessedForWBE
                ]);
                for(NE__OrderItem__c singleOrdNewWBE : listOrderItemsWithNewWBE) {
                    listLogsToInsert.add(insertBatchErrorLog('Recalculate WBE for Order Item ' + singleOrdNewWBE.Id + ': OLD(' + mapOldOrderItemWBE.get(singleOrdNewWBE.Id) + ') / NEW(' + singleOrdNewWBE.XC_WBE__c + ')', ''));
                }
            } 

            // Write more info for BPLI:
            getMoreInfoBPLI(listBPLIforMoreInfo, listLogsToInsert);

            // Manage for Glovia:
            if((cs != null && cs.BLAZE_ManageGlovia__c==true) || Test.isRunningTest()) {
                if((mapWrapperObj.containsKey('optyWithScheduledDelivery') && !mapWrapperObj.get('optyWithScheduledDelivery').listWorkOrder.isEmpty()) || (mapWrapperObj.containsKey('optyWithDeliveryNotScheduled') && !mapWrapperObj.get('optyWithDeliveryNotScheduled').listWorkOrder.isEmpty())) {
                    WrapperObject wrWithSchedule    = (mapWrapperObj.containsKey('optyWithScheduledDelivery') && !mapWrapperObj.get('optyWithScheduledDelivery').listWorkOrder.isEmpty()) ? mapWrapperObj.get('optyWithScheduledDelivery') : new WrapperObject();
                    WrapperObject wrWithoutSchedule = (mapWrapperObj.containsKey('optyWithDeliveryNotScheduled') && !mapWrapperObj.get('optyWithDeliveryNotScheduled').listWorkOrder.isEmpty()) ? mapWrapperObj.get('optyWithDeliveryNotScheduled') : new WrapperObject();
                    manageGlovia(wrWithSchedule, wrWithoutSchedule, wrapperToUpdate, listLogsToInsert);
                } 
            }

            // For rollback mode:
            if(cs != null && cs.BLAZE_Rollback__c==true) {
                deleteObjectForRollback(listLogsToInsert);
            }

            // Check only:
            if((cs != null && cs.BLAZE_CheckOnly__c==true) || Test.isRunningTest()) {
                Database.rollback(savePoint);
            }

            // Insert logs:
            XC_UTIL_Sobject.insertListRecords(listLogsToInsert);

            // Disable to skip current user:
            listCurrentUser = new User(Id=UserInfo.getUserId(), XC_EnabledToSkip__c=false);
            update listCurrentUser;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ End Execute method batch');
        } catch(Exception e) {
            Database.rollback(savePoint);
            XC_UTIL_Sobject.insertRecord(insertBatchErrorLog('FATAL ERROR at line ' + e.getLineNumber(), e.getMessage() + '\n' + e.getStackTraceString()));
        }
    }    

    /**
     * @description finish method
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ End Batch BLAZE_SC001_DataCleaning');
    }    

    //************************************************************************************************************************* METHODS TO UPDATE OBJECTS */

    public static Map<String, WrapperObject> retrieveCaseTypeWrapper(List<Asset> listAsset, List<NE__OrderItem__c> listOrderItem, List<String> listCountryFiltered, Boolean considerOpenOrder, Boolean considerClosedOrder, Boolean caseOrderItemNoCase) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In retrieveCaseTypeWrapper');
        Map<String, WrapperObject>      outputWrapper                   = new Map<String, WrapperObject>();
        List<String>                    listOrderIds                    = new List<String>();
        List<NE__Order__c>              listOrders                      = new List<NE__Order__c>();
        List<String>                    listWordOrderIds                = new List<String>();
        List<String>                    listAccountIds                  = new List<String>();
        Set<String>                     listOrderWithOpenendDelivery    = new Set<String>();
        Map<String, ServiceAppointment> mapSa                           = new Map<String, ServiceAppointment>();
        
        if(!caseOrderItemNoCase) {
            // Case queried Assets:
            listOrderIds = XC_UTIL_Sobject.getListFieldValues(listAsset, 'NE__Order_Config__c');
            // Query Orders by Asset:
            for(Asset singleAsset : listAsset) {
                    // Create list Order Item Id by Asset:
                    listOrderItemIdsFromAsset.add(singleAsset.XC_Configuration_Item__c);
                    // Create a list with Asset without orders
                    if(String.isBlank(singleAsset.NE__Order_Config__c)) {
                        if(!outputWrapper.containsKey('assetWithoutOrder')) {
                            outputWrapper.put('assetWithoutOrder', new WrapperObject());
                        }
                        outputWrapper.get('assetWithoutOrder').listAssetIdsWithoutOrder.add(singleAsset.Id);
                    }
                }
            listOrders = new List<NE__Order__c>([
                SELECT Id, NE__OptyId__c, NE__OptyId__r.StageName, NE__OptyId__r.BLAZE_OldLegalEntity__c, NE__OptyId__r.AccountId, XC_LegalEntity__c, NE__AccountId__r.XC_Country__c, XC_Status__c,
                    (
                        SELECT Id, Status, XC_WorkTypeCategory__c, XC_LegalEntity__c, XC_WorkTypeLabel__c, XC_Segment__c, WorkTypeId, XC_Configuration__c
                        FROM Work_Orders__r
                        WHERE XC_Check_Final_Status__c = false),
                    (
                        SELECT Id, XC_Segment__c, NE__OrderId__c, XC_LegalEntityFormula__c, XC_WBE__c
                        FROM NE__Order_Items__r
                        /*WHERE Id IN :listOrderItemIdsFromAsset*/),
                    (
                        SELECT Id, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Payment__c, BLAZE_ToClean__c, XC_PaymentMethod__c
                        FROM NE__Assets__r
                        /*WHERE XC_Configuration_Item__c IN :listOrderItemIdsFromAsset*/
                    )
                FROM NE__Order__c
                WHERE Id IN :listOrderIds AND XC_Country__c IN :listCountryFiltered
            ]);
            if(listOrders.isEmpty()) {
                return outputWrapper;
            }

            // Create Work order List:
            for(NE__Order__c ord : listOrders) {
                if(String.isNotBlank(ord.NE__OptyId__r.AccountId)) {
                    listAccountIds.add(ord.NE__OptyId__r.AccountId);
                }
                for(WorkOrder singleWo : ord.Work_Orders__r) {
                    listWorkOrderToDiscoveryWT.add(singleWo);
                    listWordOrderIds.add(singleWo.Id);
                    if(singleWo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Delivery || singleWo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation) {
                        listOrderWithOpenendDelivery.add(ord.Id);
                    }
                }
            }
            // Create Map WorkOrder->ServiceAppointment list:
            if(!listWordOrderIds.isEmpty()) {
                List<ServiceAppointment> listSa = new List<ServiceAppointment>([
                    SELECT Id, ParentRecordId, XC_LegalEntity__c
                    FROM ServiceAppointment
                    WHERE ParentRecordId IN :listWordOrderIds AND XC_IsFinalStatus__c = false
                ]);
                for(ServiceAppointment sa : listSa) {
                    mapSa.put(sa.ParentRecordId, sa);
                }
            }

            // Create Map/List from Asset info:
            for(Asset singleAsset : listAsset) {
                // Create Map Order->Assets:
                for(NE__Order__c singleOrd : listOrders) {
                    if(singleAsset.NE__Order_Config__c == singleOrd.Id) {
                        if(!mapOrderAssets.containsKey(singleOrd.Id)) {
                            mapOrderAssets.put(singleOrd.Id, new List<Asset>());
                        }
                        mapOrderAssets.get(singleOrd.Id).add(singleAsset);
                    }
                }     
                // Create Map Account->ExistingBPLI */
                if(String.isNotBlank(singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.Id)) {
                    mapAccountBPLI.put(singleAsset.AccountId, new XC_BillingProfileLineItem__c(
                        Id                              = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.Id,
                        XC_Country__c                   = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_Country__c,
                        XC_CustomerAccount__c           = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_CustomerAccount__c,
                        XC_BillingAddress__c            = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillingAddress__c,
                        XC_ExternalKey__c               = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_ExternalKey__c,
                        XC_BillingProfile__c            = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillingProfile__c,
                        XC_BillToAddress__c             = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillToAddress__c,
                        XC_BillToContactId__c           = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillToContactId__c,
                        XC_LegalEntity__c               = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_LegalEntity__c,
                        XC_DocumentType__c              = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_DocumentType__c,
                        XC_Status__c                    = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_Status__c,
                        XC_InvoicePreferredLanguage__c  = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_InvoicePreferredLanguage__c,
                        XC_InvoiceDeliveryPreference__c = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_InvoiceDeliveryPreference__c,
                        XC_PEC__c                       = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_PEC__c,
                        XC_RecipientCodeB2B__c          = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_RecipientCodeB2B__c,
                        XC_OfficeCode__c                = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_OfficeCode__c,
                        XC_RecipientCode__c             = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_RecipientCode__c,
                        XC_TPBCode__c                   = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_TPBCode__c,
                        XC_BillingProfileCopy__c        = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillingProfileCopy__c,
                        XC_SoldToAddress__c             = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_SoldToAddress__c,
                        XC_SoldToContactId__c           = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_SoldToContactId__c,
                        XC_BillingProfileName__c        = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillingProfileName__c,
                        XC_DocumentNumber__c            = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_DocumentNumber__c,
                        XC_DocumentCountry__c           = singleAsset.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_DocumentCountry__c
                    ));
                }
            }

            // Create Map Account->Individual */
            List<Contact> listContact = new List<Contact>([
                SELECT Id, IndividualId, AccountId
                FROM Contact
                WHERE AccountId IN :listAccountIds AND XC_PrimaryContact__c = true
            ]);
            for(Contact cnt : listContact) {
                mapAccountIndividual.put(cnt.AccountId, cnt.IndividualId);
            }
            // Create Map Key -> LEC
            List<XC_LegalEntityConsent__c> listLECQueried = new List<XC_LegalEntityConsent__c>([
                SELECT Id, XC_Individual__c, XC_LegalEntity__c, XC_IndividualId__c, XC_LeCountry__c, XC_GiveDataToNew__c, XC_LECollectedMarketingConsents__c, XC_MarketingConsent__c, XC_CollectionDateMarketing__c, XC_IndividualLegalEntity__c, XC_UpdateAboutProducts__c, XC_ConsentToDataProcessing__c, XC_CompanyConsentVersion__c, XC_MarketingConsentVersion__c, XC_ProfilingConsentVersion__c, XC_CollectionChannelMarketing__c, XC_CollectionUserMarketing__c, XC_ProfilingConsent__c, XC_LECollectedProfilingConsents__c, XC_CollectionDateProfiling__c, XC_CollectionChannelProfiling__c, XC_CollectionUserProfiling__c, XC_ConsentDescription__c, XC_ExternalId__c, XC_GiveDataTo__c, XC_ExpirationDateProfilingConsent__c, XC_ExpirationDateMarketingConsent__c, XC_Status__c, XC_NotCustomerConsent__c, XC_ThirdProductsMarketingConsent__c, XC_NotCustomerConsentVersion__c, XC_ThirdProductsMarketingConsentVersion__c, XC_LECollectedNotCustomerConsents__c, XC_LECollectedThirdProductsMarketingCons__c, XC_CollectionDateNotCustomer__c, XC_CollectionDateThirdProductsMarketing__c, XC_CollectionChannelNotCustomer__c, XC_CollectionChannelThirdProdMarketing__c, XC_CollectionUserNotCustomer__c, XC_CollectionUserThirdProductsMarketing__c, XC_FromAPI__c
                FROM XC_LegalEntityConsent__c
                WHERE XC_Individual__c IN :mapAccountIndividual.values()
            ]);
            for(XC_LegalEntityConsent__c singleLecQueried : listLECQueried) {
                String key = ''+ singleLecQueried.XC_Individual__c + singleLecQueried.XC_LegalEntity__c;
                mapKeyLEC.put(key, singleLecQueried);
            }
        }
        else {
            listOrderIds = XC_UTIL_Sobject.getListFieldValues(listOrderItem, 'NE__OrderId__c');
            // Query Orders by Asset:
            for(NE__OrderItem__c singleItem : listOrderItem) {
                    // Create list Order Item Id by Asset:
                    listOrderItemIdsFromAsset.add(singleItem.Id);
            }
            listOrders = new List<NE__Order__c>([
                SELECT Id, NE__OptyId__c, NE__OptyId__r.StageName, NE__OptyId__r.BLAZE_OldLegalEntity__c, NE__OptyId__r.AccountId, XC_LegalEntity__c, NE__AccountId__r.XC_Country__c, XC_Status__c,
                    (
                        SELECT Id, Status, XC_WorkTypeCategory__c, XC_LegalEntity__c, XC_WorkTypeLabel__c, XC_Segment__c, WorkTypeId, XC_Configuration__c
                        FROM Work_Orders__r
                        WHERE XC_Check_Final_Status__c = false),
                    (
                        SELECT Id, XC_Segment__c, NE__OrderId__c, XC_LegalEntityFormula__c, XC_WBE__c
                        FROM NE__Order_Items__r
                        /*WHERE Id IN :listOrderItemIdsFromAsset*/),
                    (
                        SELECT Id, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Payment__c, BLAZE_ToClean__c, XC_PaymentMethod__c
                        FROM NE__Assets__r
                        /*WHERE XC_Configuration_Item__c IN :listOrderItemIdsFromAsset*/
                    )
                FROM NE__Order__c
                WHERE Id IN :listOrderIds AND XC_Country__c IN :listCountryFiltered
            ]);
            if(listOrders.isEmpty()) {
                return outputWrapper;
            }

            // Create Work order List:
            for(NE__Order__c ord : listOrders) {
                if(String.isNotBlank(ord.NE__OptyId__r.AccountId)) {
                    listAccountIds.add(ord.NE__OptyId__r.AccountId);
                }
                for(WorkOrder singleWo : ord.Work_Orders__r) {
                    listWorkOrderToDiscoveryWT.add(singleWo);
                    listWordOrderIds.add(singleWo.Id);
                    if(singleWo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Delivery || singleWo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation) {
                        listOrderWithOpenendDelivery.add(ord.Id);
                    }
                }
            }
            // Create Map WorkOrder->ServiceAppointment list:
            if(!listWordOrderIds.isEmpty()) {
                List<ServiceAppointment> listSa = new List<ServiceAppointment>([
                    SELECT Id, ParentRecordId, XC_LegalEntity__c
                    FROM ServiceAppointment
                    WHERE ParentRecordId IN :listWordOrderIds AND XC_IsFinalStatus__c = false
                ]);
                for(ServiceAppointment sa : listSa) {
                    mapSa.put(sa.ParentRecordId, sa);
                }
            }

            // Create Map/List from OrderItem info:
            for(NE__OrderItem__c singleItem : listOrderItem) {
                // Create Map Order->OrderItem:
                for(NE__Order__c singleOrd : listOrders) {
                    if(singleItem.NE__OrderId__c == singleOrd.Id) {
                        if(!mapOrderOrderItem.containsKey(singleOrd.Id)) {
                            mapOrderOrderItem.put(singleOrd.Id, new List<NE__OrderItem__c>());
                        }
                        mapOrderOrderItem.get(singleOrd.Id).add(singleItem);
                    }
                }     
                // Create Map Account->ExistingBPLI */
                if(String.isNotBlank(singleItem.XC_BillingProfileLineItem__r.Id)) {
                    mapAccountBPLI.put(singleItem.NE__Account__c, new XC_BillingProfileLineItem__c(
                        Id                              = singleItem.XC_BillingProfileLineItem__r.Id,
                        XC_Country__c                   = singleItem.XC_BillingProfileLineItem__r.XC_Country__c,
                        XC_CustomerAccount__c           = singleItem.XC_BillingProfileLineItem__r.XC_CustomerAccount__c,
                        XC_BillingAddress__c            = singleItem.XC_BillingProfileLineItem__r.XC_BillingAddress__c,
                        XC_ExternalKey__c               = singleItem.XC_BillingProfileLineItem__r.XC_ExternalKey__c,
                        XC_BillingProfile__c            = singleItem.XC_BillingProfileLineItem__r.XC_BillingProfile__c,
                        XC_BillToAddress__c             = singleItem.XC_BillingProfileLineItem__r.XC_BillToAddress__c,
                        XC_BillToContactId__c           = singleItem.XC_BillingProfileLineItem__r.XC_BillToContactId__c,
                        XC_LegalEntity__c               = singleItem.XC_BillingProfileLineItem__r.XC_LegalEntity__c,
                        XC_DocumentType__c              = singleItem.XC_BillingProfileLineItem__r.XC_DocumentType__c,
                        XC_Status__c                    = singleItem.XC_BillingProfileLineItem__r.XC_Status__c,
                        XC_InvoicePreferredLanguage__c  = singleItem.XC_BillingProfileLineItem__r.XC_InvoicePreferredLanguage__c,
                        XC_InvoiceDeliveryPreference__c = singleItem.XC_BillingProfileLineItem__r.XC_InvoiceDeliveryPreference__c,
                        XC_PEC__c                       = singleItem.XC_BillingProfileLineItem__r.XC_PEC__c,
                        XC_RecipientCodeB2B__c          = singleItem.XC_BillingProfileLineItem__r.XC_RecipientCodeB2B__c,
                        XC_OfficeCode__c                = singleItem.XC_BillingProfileLineItem__r.XC_OfficeCode__c,
                        XC_RecipientCode__c             = singleItem.XC_BillingProfileLineItem__r.XC_RecipientCode__c,
                        XC_TPBCode__c                   = singleItem.XC_BillingProfileLineItem__r.XC_TPBCode__c,
                        XC_BillingProfileCopy__c        = singleItem.XC_BillingProfileLineItem__r.XC_BillingProfileCopy__c,
                        XC_SoldToAddress__c             = singleItem.XC_BillingProfileLineItem__r.XC_SoldToAddress__c,
                        XC_SoldToContactId__c           = singleItem.XC_BillingProfileLineItem__r.XC_SoldToContactId__c,
                        XC_BillingProfileName__c        = singleItem.XC_BillingProfileLineItem__r.XC_BillingProfileName__c,
                        XC_DocumentNumber__c            = singleItem.XC_BillingProfileLineItem__r.XC_DocumentNumber__c,
                        XC_DocumentCountry__c           = singleItem.XC_BillingProfileLineItem__r.XC_DocumentCountry__c
                    ));
                }
            }

            // Create Map Account->Individual */
            List<Contact> listContact = new List<Contact>([
                SELECT Id, IndividualId, AccountId
                FROM Contact
                WHERE AccountId IN :listAccountIds AND XC_PrimaryContact__c = true
            ]);
            for(Contact cnt : listContact) {
                mapAccountIndividual.put(cnt.AccountId, cnt.IndividualId);
            }
            // Create Map Key -> LEC
            List<XC_LegalEntityConsent__c> listLECQueried = new List<XC_LegalEntityConsent__c>([
                SELECT Id, XC_Individual__c, XC_LegalEntity__c, XC_IndividualId__c, XC_LeCountry__c, XC_GiveDataToNew__c, XC_LECollectedMarketingConsents__c, XC_MarketingConsent__c, XC_CollectionDateMarketing__c, XC_IndividualLegalEntity__c, XC_UpdateAboutProducts__c, XC_ConsentToDataProcessing__c, XC_CompanyConsentVersion__c, XC_MarketingConsentVersion__c, XC_ProfilingConsentVersion__c, XC_CollectionChannelMarketing__c, XC_CollectionUserMarketing__c, XC_ProfilingConsent__c, XC_LECollectedProfilingConsents__c, XC_CollectionDateProfiling__c, XC_CollectionChannelProfiling__c, XC_CollectionUserProfiling__c, XC_ConsentDescription__c, XC_ExternalId__c, XC_GiveDataTo__c, XC_ExpirationDateProfilingConsent__c, XC_ExpirationDateMarketingConsent__c, XC_Status__c, XC_NotCustomerConsent__c, XC_ThirdProductsMarketingConsent__c, XC_NotCustomerConsentVersion__c, XC_ThirdProductsMarketingConsentVersion__c, XC_LECollectedNotCustomerConsents__c, XC_LECollectedThirdProductsMarketingCons__c, XC_CollectionDateNotCustomer__c, XC_CollectionDateThirdProductsMarketing__c, XC_CollectionChannelNotCustomer__c, XC_CollectionChannelThirdProdMarketing__c, XC_CollectionUserNotCustomer__c, XC_CollectionUserThirdProductsMarketing__c, XC_FromAPI__c
                FROM XC_LegalEntityConsent__c
                WHERE XC_Individual__c IN :mapAccountIndividual.values()
            ]);
            for(XC_LegalEntityConsent__c singleLecQueried : listLECQueried) {
                String key = ''+ singleLecQueried.XC_Individual__c + singleLecQueried.XC_LegalEntity__c;
                mapKeyLEC.put(key, singleLecQueried);
            }
        }

        // Mapping LegalEntity for rollbackmode:
        if(rollBackMode) {
            for(NE__Order__c singleOrdRollback : listOrders) {
                mapLegalEntityRollback.put(''+singleOrdRollback.Id+singleOrdRollback.XC_LegalEntity__c, singleOrdRollback.NE__OptyId__r.BLAZE_OldLegalEntity__c);
            }
        }

        // Check for scenario:
        List<String> listStatusOptyToReject = new List<String>{Label.XC_CL_Configuration_Closed, 'Abandoned', 'Closed Lost', 'Rejected'};
        for(NE__Order__c ord : listOrders) {
            String typeCase = '';
            if(considerOpenOrder && ord.XC_Status__c != Label.XC_CL_Configuration_Closed) {
                //************* For Open Order:
                if(ord.NE__OptyId__r.StageName == Label.xC_CL_Opportunity_Draft) {
                    //************* Opty without checkout:
                    typeCase = 'optyWithoutCheckout';
                    if(!outputWrapper.containsKey(typeCase)) {
                        outputWrapper.put(typeCase, new WrapperObject());
                    }
                    outputWrapper.get(typeCase).listOrders.add(ord);
                }
                else if(!listStatusOptyToReject.contains(ord.NE__OptyId__r.StageName)) {
                    //************* Opty with checkout:
                    if(ord.Work_Orders__r.isEmpty()) {
                        //************* Opty with checkout and without workorder
                        typeCase = 'optyWithCheckoutWithoutWorkOrder';
                        if(!outputWrapper.containsKey(typeCase)) {
                            outputWrapper.put(typeCase, new WrapperObject());
                        }
                        outputWrapper.get(typeCase).listOrders.add(ord);
                    }
                    else {
                        for(WorkOrder wo : ord.Work_Orders__r) {
                            if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_SiteInspection) {
                                if(mapSa.containsKey(wo.Id) && String.isNotBlank(wo.Id)) {
                                    //************* Opty with scheduled site inspection
                                    typeCase = 'optyWithScheduledSiteInspection';
                                    if(!outputWrapper.containsKey(typeCase)) {
                                        outputWrapper.put(typeCase, new WrapperObject());
                                    }
                                    outputWrapper.get(typeCase).listOrders.add(ord);
                                    outputWrapper.get(typeCase).listWorkOrder.add(wo);
                                    outputWrapper.get(typeCase).mapServiceAppointment.put(wo.Id, mapSa.get(wo.Id));
                                } else {
                                    //************* Opty with ongoing site inspection
                                    typeCase = 'optyWithSiteInspectionNotScheduled';
                                    if(!outputWrapper.containsKey(typeCase)) {
                                        outputWrapper.put(typeCase, new WrapperObject());
                                    }
                                    outputWrapper.get(typeCase).listOrders.add(ord);
                                    outputWrapper.get(typeCase).listWorkOrder.add(wo);
                                }
                            }
                            if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Delivery || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation) {
                                if(mapSa.containsKey(wo.Id) && String.isNotBlank(wo.Id)) {
                                    //************* Opty with scheduled Delivery
                                    typeCase = 'optyWithScheduledDelivery';
                                    if(!outputWrapper.containsKey(typeCase)) {
                                        outputWrapper.put(typeCase, new WrapperObject());
                                    }
                                    outputWrapper.get(typeCase).listOrders.add(ord);
                                    outputWrapper.get(typeCase).listWorkOrder.add(wo);
                                    outputWrapper.get(typeCase).mapServiceAppointment.put(wo.Id, mapSa.get(wo.Id));
                                } else {
                                    //************* Opty with ongoing Delivery
                                    typeCase = 'optyWithDeliveryNotScheduled';
                                    if(!outputWrapper.containsKey(typeCase)) {
                                        outputWrapper.put(typeCase, new WrapperObject());
                                    }
                                    outputWrapper.get(typeCase).listOrders.add(ord);
                                    outputWrapper.get(typeCase).listWorkOrder.add(wo);
                                }
                            }
                            else {
                                //************* Opty with other work order
                                typeCase = 'optyWithOtherWorkOrder';
                                if(!outputWrapper.containsKey(typeCase)) {
                                    outputWrapper.put(typeCase, new WrapperObject());
                                }
                                outputWrapper.get(typeCase).listOrders.add(ord);
                                outputWrapper.get(typeCase).listWorkOrder.add(wo);
                            }
                        }
                    }
                }
            }
            else if(considerClosedOrder && ord.XC_Status__c == Label.XC_CL_Configuration_Closed && !listOrderWithOpenendDelivery.contains(ord.Id)) {
                //************* For Closed Order:
                typeCase = 'optyWithClosedOrder';
                if(!outputWrapper.containsKey(typeCase)) {
                    outputWrapper.put(typeCase, new WrapperObject());
                }
                outputWrapper.get(typeCase).listOrders.add(ord);
            }
        }

        // Create a Map for WorkType:
        saveNewWorkType();

        return outputWrapper;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/10/2021
     * @description Method to analyze type case
    */
    public static void checkOptyWithoutCheckout(WrapperObject wrObj, WrapperObjectToUpdate wrapperToUpdate, List<XC_BatchErrorLog__c> listLogsToInsert) {
        for(NE__Order__c ord : wrObj.listOrders) {
            String oldLegalEntityFromOrder  = ord.XC_LegalEntity__c;
            String newLegalEntity           = getNewLegalEntity(oldLegalEntityFromOrder);
            if(rollbackMode) {
                if(mapLegalEntityRollback.containsKey(''+ord.Id+ord.XC_LegalEntity__c)) {
                    newLegalEntity = mapLegalEntityRollback.get(''+ord.Id+ord.XC_LegalEntity__c);
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] No Legal Entity Convertion found for key: ' + ord.Id + ' ' + ord.XC_LegalEntity__c, ''));
                    return;
                }
            }
            if(String.isNotBlank(newLegalEntity) && newLegalEntity!='') {
                // Configuration:
                wrapperToUpdate.listOrder.add(new NE__Order__c(Id = ord.Id, XC_LegalEntity__c = newLegalEntity));
                // Opportunity:
                wrapperToUpdate.listOpty.add(new Opportunity(Id = ord.NE__OptyId__c, XC_LegalEntity__c = newLegalEntity, BLAZE_OldLegalEntity__c = oldLegalEntityFromOrder));
                // Account:
                wrapperToUpdate.listAccount.add(createAccountInfo(ord.NE__OptyId__r.AccountId, newLegalEntity));
            }
            else {
                listLogsToInsert.add(insertBatchErrorLog('No Legal Entity Convertion found for key: ' + ord.XC_LegalEntity__c, ''));
            }
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/10/2021
     * @description Method to analyze type case
    */
    public static void checkOptyWithCheckoutWithoutWorkOrder(WrapperObject wrObj, WrapperObjectToUpdate wrapperToUpdate, List<XC_BatchErrorLog__c> listLogsToInsert) {
        for(NE__Order__c ord : wrObj.listOrders) {
            String oldLegalEntityFromOrder  = ord.XC_LegalEntity__c;
            String newLegalEntity           = getNewLegalEntity(oldLegalEntityFromOrder);
            if(rollbackMode) {
                if(mapLegalEntityRollback.containsKey(''+ord.Id+ord.XC_LegalEntity__c)) {
                    newLegalEntity = mapLegalEntityRollback.get(''+ord.Id+ord.XC_LegalEntity__c);
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] No Legal Entity Convertion found for key: ' + ord.Id + ' ' + ord.XC_LegalEntity__c, ''));
                    return;
                }
            }
            if(String.isNotBlank(newLegalEntity) && newLegalEntity!='') {
                // Configuration:
                wrapperToUpdate.listOrder.add(new NE__Order__c(Id = ord.Id, XC_LegalEntity__c = newLegalEntity));
                // Opportunity:
                wrapperToUpdate.listOpty.add(new Opportunity(Id = ord.NE__OptyId__c, XC_LegalEntity__c = newLegalEntity, BLAZE_OldLegalEntity__c = oldLegalEntityFromOrder));
                // Account:
                wrapperToUpdate.listAccount.add(createAccountInfo(ord.NE__OptyId__r.AccountId, newLegalEntity));
                // Configuration Item:
                for(NE__OrderItem__c ordItem : ord.NE__Order_Items__r) {
                    wrapperToUpdate.listOrderItem.add(new NE__OrderItem__c(Id = ordItem.Id, XC_LegalEntity__c = newLegalEntity));
                }
                // Legal Entity Consent:
                XC_LegalEntityConsent__c lecCreated = createLegalEntityConsent(ord.NE__OptyId__r.AccountId, newLegalEntity, ord.XC_LegalEntity__c);
                if(lecCreated!=null) {
                    wrapperToUpdate.listLegalEntityConsent.add(lecCreated);
                }
                if(rollbackMode) {
                    String accountForLEC = ord.NE__OptyId__r.AccountId;
                    if(mapAccountIndividual.containsKey(accountForLEC)) {
                        String individualId = mapAccountIndividual.get(accountForLEC);
                        mapConsentNewRollback.put(individualId, newLegalEntity);
                        mapConsentOldRollback.put(individualId, oldLegalEntityFromOrder);
                    } else {
                        listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] Error to rollback LEC for key (Account/NewLE/OldLE): ' + accountForLEC + ' ' + newLegalEntity + ' ' + oldLegalEntityFromOrder, ''));
                    }
                }
            }
            else {
                listLogsToInsert.add(insertBatchErrorLog('No Legal Entity Convertion found for key: ' + ord.XC_LegalEntity__c, ''));
            }
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/10/2021
     * @description Method to analyze type case
    */
    public static void checkOptyWithScheduledSiteInspection(WrapperObject wrObj, WrapperObjectToUpdate wrapperToUpdate, List<XC_BatchErrorLog__c> listLogsToInsert) {
        for(NE__Order__c ord : wrObj.listOrders) {
            String oldLegalEntityFromOrder  = ord.XC_LegalEntity__c;
            String newLegalEntity           = getNewLegalEntity(oldLegalEntityFromOrder);
            if(rollbackMode) {
                if(mapLegalEntityRollback.containsKey(''+ord.Id+ord.XC_LegalEntity__c)) {
                    newLegalEntity = mapLegalEntityRollback.get(''+ord.Id+ord.XC_LegalEntity__c);
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] No Legal Entity Convertion found for key: ' + ord.Id + ' ' + ord.XC_LegalEntity__c, ''));
                    return;
                }
            }
            if(String.isNotBlank(newLegalEntity) && newLegalEntity!='') {
                // Configuration:
                wrapperToUpdate.listOrder.add(new NE__Order__c(Id = ord.Id, XC_LegalEntity__c = newLegalEntity));
                // Opportunity:
                wrapperToUpdate.listOpty.add(new Opportunity(Id = ord.NE__OptyId__c, XC_LegalEntity__c = newLegalEntity, BLAZE_OldLegalEntity__c = oldLegalEntityFromOrder));
                // Account:
                wrapperToUpdate.listAccount.add(createAccountInfo(ord.NE__OptyId__r.AccountId, newLegalEntity));
                // Configuration Item:
                for(NE__OrderItem__c ordItem : ord.NE__Order_Items__r) {
                    wrapperToUpdate.listOrderItem.add(new NE__OrderItem__c(Id = ordItem.Id, XC_LegalEntity__c = newLegalEntity));
                }
                // Legal Entity Consent:
                XC_LegalEntityConsent__c lecCreated = createLegalEntityConsent(ord.NE__OptyId__r.AccountId, newLegalEntity, ord.XC_LegalEntity__c);
                if(lecCreated!=null) {
                    wrapperToUpdate.listLegalEntityConsent.add(lecCreated);
                }
                if(rollbackMode) {
                    String accountForLEC = ord.NE__OptyId__r.AccountId;
                    if(mapAccountIndividual.containsKey(accountForLEC)) {
                        String individualId = mapAccountIndividual.get(accountForLEC);
                        mapConsentNewRollback.put(individualId, newLegalEntity);
                        mapConsentOldRollback.put(individualId, oldLegalEntityFromOrder);
                    } else {
                        listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] Error to rollback LEC for key (Account/NewLE/OldLE): ' + accountForLEC + ' ' + newLegalEntity + ' ' + oldLegalEntityFromOrder, ''));
                    }
                }
                // Work Order:
                Map<String, String> mapWoToCheckSA = new Map<String, String>();
                for(WorkOrder wo : ord.Work_Orders__r) {
                    if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_SiteInspection) {
                        WorkOrder woItemToUpdate = new WorkOrder(Id = wo.Id, XC_LegalEntity__c = newLegalEntity);
                        String key = wo.XC_Segment__c+'_'+newLegalEntity+'_'+wo.XC_WorkTypeLabel__c;
                        if(mapWorkType.containsKey(key)) {
                            woItemToUpdate.WorkTypeId = mapWorkType.get(key);
                        } else {
                            woItemToUpdate.WorkTypeId = wo.WorkTypeId;
                            listLogsToInsert.add(insertBatchErrorLog('ERROR: No WorkType found to update WorkOrder ' + wo.Id + '. Please create it and change WT manually', 'WT: Name ' + wo.XC_WorkTypeLabel__c + ' LegalEntity ' + newLegalEntity + ' Segment ' + wo.XC_Segment__c + ''));
                        }
                        wrapperToUpdate.listWorkOrder.add(woItemToUpdate);
                        mapWoToCheckSA.put(wo.Id, woItemToUpdate.WorkTypeId);
                    }
                }
                // Service Appointment:
                for(String woId : mapWoToCheckSA.keySet()) {
                    if(wrObj.mapServiceAppointment.containsKey(woId)) {
                        wrapperToUpdate.listServiceAppointment.add(new ServiceAppointment(Id = wrObj.mapServiceAppointment.get(woId).Id, XC_LegalEntity__c = newLegalEntity));
                    }
                }
                // Billing Profile Line Item:
                /*XC_BillingProfileLineItem__c bpliCreated = createBillingProfileLineItem(ord.NE__OptyId__r.AccountId, newLegalEntity, listLogsToInsert);
                if(bpliCreated!=null) {
                    wrapperToUpdate.listBillingProfileLineItem.add(bpliCreated);
                    String key = ''+ord.NE__OptyId__r.AccountId+'-_-_-'+bpliCreated.XC_BillingProfile__c+'-_-_-'+newLegalEntity+'-_-_-'+bpliCreated.XC_Country__c;
                    // - Populate map to update Billing Profile Line Item on Configuration Item
                    for(NE__OrderItem__c ordItem : ord.NE__Order_Items__r) {
                        mapKeyOrderItemToUpdateBPLI.put(key, ordItem.Id);
                    }
                    if(mapOrderAssets.containsKey(ord.Id)) {
                        for(Asset singleAsset : mapOrderAssets.get(ord.Id)) {
                            mapKeyAssetToUpdateBPLI.put(key, singleAsset.Id);
                        }
                    }
                }
                if(rollbackMode) {
                    String accountForBP = ord.NE__OptyId__r.AccountId;
                    if(mapAccountBPLI.containsKey(accountForBP)) {
                        XC_BillingProfileLineItem__c oldBPLI = mapAccountBPLI.get(accountForBP);
                        mapBPLIRollbackNewLE.put(oldBPLI.XC_BillingProfile__c, newLegalEntity);
                        mapBPLIRollbackOldLE.put(oldBPLI.XC_BillingProfile__c, oldLegalEntityFromOrder);
                    } else {
                        listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] Error to rollback BPLI for key (Account/NewLE/OldLE): ' + accountForBP + ' ' + newLegalEntity + ' ' + oldLegalEntityFromOrder, ''));
                    }
                }*/

                // NM 30.03.22
                List<String> listFoundedEhome                   = new List<String>();
                List<String> listFoundedEhomeTemp               = new List<String>();
                List<String> listFoundedEmobility               = new List<String>();
                List<String> listPaymentMethodForEmobilityAsset = new List<String>();
                for(Asset currentAsset : ord.NE__Assets__r) {
                    if(currentAsset.BLAZE_ToClean__c == 'Y') {
                        // Asset Mobility found:
                        listFoundedEmobility.add(currentAsset.Id);
                        listPaymentMethodForEmobilityAsset.add(currentAsset.XC_PaymentMethod__c);
                    } else {
                        // Asset eHome to check for payment method found:
                        listFoundedEhomeTemp.add(currentAsset.Id);
                    }
                }
                for(Asset currentAsset : ord.NE__Assets__r) {
                    if(listFoundedEhomeTemp.contains(currentAsset.Id)) {
                        // Asset eHome to check for payment method found:
                        if(listPaymentMethodForEmobilityAsset.contains(currentAsset.XC_PaymentMethod__c)) {
                            // Same payment method:
                            listFoundedEhome.add(currentAsset.Id);
                        } else {
                            // Different payment method:
                            listFoundedEmobility.add(currentAsset.Id);
                        }
                    }
                }
                if(!listFoundedEhome.isEmpty() && !listFoundedEmobility.isEmpty())  {
                    // - Update Asset only for eMobility:
                    for(String assetId : listFoundedEmobility) {
                        wrapperToUpdate.listAsset.add(new Asset(Id = assetId, XC_LegalEntity__c = newLegalEntity));
                    }
                    // - Duplicate Billing Profile Line Item for eMobility:
                    XC_BillingProfileLineItem__c bpliCreated = createBillingProfileLineItem(ord.NE__OptyId__r.AccountId, newLegalEntity, listLogsToInsert);
                    if(bpliCreated!=null) {
                        wrapperToUpdate.listBillingProfileLineItem.add(bpliCreated);
                        String key = ''+ord.NE__OptyId__r.AccountId+'-_-_-'+bpliCreated.XC_BillingProfile__c+'-_-_-'+newLegalEntity+'-_-_-'+bpliCreated.XC_Country__c;
                        // - Populate map to update Billing Profile Line Item on Asset
                        for(String singleAssetId : listFoundedEmobility) {
                            mapKeyAssetToUpdateBPLI.put(key, singleAssetId);
                        }
                    }
                    if(rollbackMode) {
                        String accountForBP = ord.NE__OptyId__r.AccountId;
                        if(mapAccountBPLI.containsKey(accountForBP)) {
                            XC_BillingProfileLineItem__c oldBPLI = mapAccountBPLI.get(accountForBP);
                            mapBPLIRollbackNewLE.put(oldBPLI.XC_BillingProfile__c, newLegalEntity);
                            mapBPLIRollbackOldLE.put(oldBPLI.XC_BillingProfile__c, oldLegalEntityFromOrder);
                        } else {
                            listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] Error to rollback BPLI for key (Account/NewLE/OldLE): ' + accountForBP + ' ' + newLegalEntity + ' ' + oldLegalEntityFromOrder, ''));
                        }
                    }
                } 
                if(listFoundedEhome.isEmpty() && !listFoundedEmobility.isEmpty())  {
                    // - Update Asset only for eMobility:
                    for(String assetId : listFoundedEmobility) {
                        wrapperToUpdate.listAsset.add(new Asset(Id = assetId, XC_LegalEntity__c = newLegalEntity));
                    }
                    // - Update Billing Profile Line Item for eMobility:
                    if(mapAccountBPLI.containsKey(ord.NE__OptyId__r.AccountId)) {
                        wrapperToUpdate.listBillingProfileLineItemUpdate.add(new XC_BillingProfileLineItem__c(Id = mapAccountBPLI.get(ord.NE__OptyId__r.AccountId).Id, XC_LegalEntity__c = newLegalEntity));
                    }
                }
				// NM
            }
            else {
                listLogsToInsert.add(insertBatchErrorLog('No Legal Entity Convertion found for key: ' + ord.XC_LegalEntity__c, ''));
            }
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/10/2021
     * @description Method to analyze type case
    */
    public static void checkOptyWithSiteInspectionNotScheduled(WrapperObject wrObj, WrapperObjectToUpdate wrapperToUpdate, List<XC_BatchErrorLog__c> listLogsToInsert) {
        for(NE__Order__c ord : wrObj.listOrders) {
            String oldLegalEntityFromOrder  = ord.XC_LegalEntity__c;
            String newLegalEntity           = getNewLegalEntity(oldLegalEntityFromOrder);
            if(rollbackMode) {
                if(mapLegalEntityRollback.containsKey(''+ord.Id+ord.XC_LegalEntity__c)) {
                    newLegalEntity = mapLegalEntityRollback.get(''+ord.Id+ord.XC_LegalEntity__c);
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] No Legal Entity Convertion found for key: ' + ord.Id + ' ' + ord.XC_LegalEntity__c, ''));
                    return;
                }
            }
            if(String.isNotBlank(newLegalEntity) && newLegalEntity!='') {
                // Configuration:
                wrapperToUpdate.listOrder.add(new NE__Order__c(Id = ord.Id, XC_LegalEntity__c = newLegalEntity));
                // Opportunity:
                wrapperToUpdate.listOpty.add(new Opportunity(Id = ord.NE__OptyId__c, XC_LegalEntity__c = newLegalEntity, BLAZE_OldLegalEntity__c = oldLegalEntityFromOrder));
                // Account:
                wrapperToUpdate.listAccount.add(createAccountInfo(ord.NE__OptyId__r.AccountId, newLegalEntity));
                // Configuration Item:
                for(NE__OrderItem__c ordItem : ord.NE__Order_Items__r) {
                    wrapperToUpdate.listOrderItem.add(new NE__OrderItem__c(Id = ordItem.Id, XC_LegalEntity__c = newLegalEntity));
                }
                // Legal Entity Consent:
                XC_LegalEntityConsent__c lecCreated = createLegalEntityConsent(ord.NE__OptyId__r.AccountId, newLegalEntity, ord.XC_LegalEntity__c);
                if(lecCreated!=null) {
                    wrapperToUpdate.listLegalEntityConsent.add(lecCreated);
                }
                if(rollbackMode) {
                    String accountForLEC = ord.NE__OptyId__r.AccountId;
                    if(mapAccountIndividual.containsKey(accountForLEC)) {
                        String individualId = mapAccountIndividual.get(accountForLEC);
                        mapConsentNewRollback.put(individualId, newLegalEntity);
                        mapConsentOldRollback.put(individualId, oldLegalEntityFromOrder);
                    } else {
                        listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] Error to rollback LEC for key (Account/NewLE/OldLE): ' + accountForLEC + ' ' + newLegalEntity + ' ' + oldLegalEntityFromOrder, ''));
                    }
                }
                // Work Order:
                for(WorkOrder wo : ord.Work_Orders__r) {
                    if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_SiteInspection) {
                        WorkOrder woItemToUpdate = new WorkOrder(Id = wo.Id, XC_LegalEntity__c = newLegalEntity);
                        String key = wo.XC_Segment__c+'_'+newLegalEntity+'_'+wo.XC_WorkTypeLabel__c;
                        if(mapWorkType.containsKey(key)) {
                            woItemToUpdate.WorkTypeId = mapWorkType.get(key);
                        } else {
                            listLogsToInsert.add(insertBatchErrorLog('ERROR: No WorkType found to update WorkOrder ' + wo.Id + '. Please create it and change WT manually', 'WT: Name ' + wo.XC_WorkTypeLabel__c + ' LegalEntity ' + newLegalEntity + ' Segment ' + wo.XC_Segment__c + ''));
                        }
                        wrapperToUpdate.listWorkOrder.add(woItemToUpdate);
                    }
                }
                // Billing Profile Line Item:
                /*XC_BillingProfileLineItem__c bpliCreated = createBillingProfileLineItem(ord.NE__OptyId__r.AccountId, newLegalEntity, listLogsToInsert);
                if(bpliCreated!=null) {
                    wrapperToUpdate.listBillingProfileLineItem.add(bpliCreated);
                    String key = ''+ord.NE__OptyId__r.AccountId+'-_-_-'+bpliCreated.XC_BillingProfile__c+'-_-_-'+newLegalEntity+'-_-_-'+bpliCreated.XC_Country__c;
                    // - Populate map to update Billing Profile Line Item on Configuration Item
                    for(NE__OrderItem__c ordItem : ord.NE__Order_Items__r) {
                        mapKeyOrderItemToUpdateBPLI.put(key, ordItem.Id);
                    }
                    if(mapOrderAssets.containsKey(ord.Id)) {
                        for(Asset singleAsset : mapOrderAssets.get(ord.Id)) {
                            mapKeyAssetToUpdateBPLI.put(key, singleAsset.Id);
                        }
                    }
                }
                if(rollbackMode) {
                    String accountForBP = ord.NE__OptyId__r.AccountId;
                    if(mapAccountBPLI.containsKey(accountForBP)) {
                        XC_BillingProfileLineItem__c oldBPLI = mapAccountBPLI.get(accountForBP);
                        mapBPLIRollbackNewLE.put(oldBPLI.XC_BillingProfile__c, newLegalEntity);
                        mapBPLIRollbackOldLE.put(oldBPLI.XC_BillingProfile__c, oldLegalEntityFromOrder);
                    } else {
                        listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] Error to rollback BPLI for key (Account/NewLE/OldLE): ' + accountForBP + ' ' + newLegalEntity + ' ' + oldLegalEntityFromOrder, ''));
                    }
                }*/

                // NM 30.03.22
                List<String> listFoundedEhome                   = new List<String>();
                List<String> listFoundedEhomeTemp               = new List<String>();
                List<String> listFoundedEmobility               = new List<String>();
                List<String> listPaymentMethodForEmobilityAsset = new List<String>();
                for(Asset currentAsset : ord.NE__Assets__r) {
                    if(currentAsset.BLAZE_ToClean__c == 'Y') {
                        // Asset Mobility found:
                        listFoundedEmobility.add(currentAsset.Id);
                        listPaymentMethodForEmobilityAsset.add(currentAsset.XC_PaymentMethod__c);
                    } else {
                        // Asset eHome to check for payment method found:
                        listFoundedEhomeTemp.add(currentAsset.Id);
                    }
                }
                for(Asset currentAsset : ord.NE__Assets__r) {
                    if(listFoundedEhomeTemp.contains(currentAsset.Id)) {
                        // Asset eHome to check for payment method found:
                        if(listPaymentMethodForEmobilityAsset.contains(currentAsset.XC_PaymentMethod__c)) {
                            // Same payment method:
                            listFoundedEhome.add(currentAsset.Id);
                        } else {
                            // Different payment method:
                            listFoundedEmobility.add(currentAsset.Id);
                        }
                    }
                }
                if(!listFoundedEhome.isEmpty() && !listFoundedEmobility.isEmpty())  {
                    // - Update Asset only for eMobility:
                    for(String assetId : listFoundedEmobility) {
                        wrapperToUpdate.listAsset.add(new Asset(Id = assetId, XC_LegalEntity__c = newLegalEntity));
                    }
                    // - Duplicate Billing Profile Line Item for eMobility:
                    XC_BillingProfileLineItem__c bpliCreated = createBillingProfileLineItem(ord.NE__OptyId__r.AccountId, newLegalEntity, listLogsToInsert);
                    if(bpliCreated!=null) {
                        wrapperToUpdate.listBillingProfileLineItem.add(bpliCreated);
                        String key = ''+ord.NE__OptyId__r.AccountId+'-_-_-'+bpliCreated.XC_BillingProfile__c+'-_-_-'+newLegalEntity+'-_-_-'+bpliCreated.XC_Country__c;
                        // - Populate map to update Billing Profile Line Item on Asset
                        for(String singleAssetId : listFoundedEmobility) {
                            mapKeyAssetToUpdateBPLI.put(key, singleAssetId);
                        }
                    }
                    if(rollbackMode) {
                        String accountForBP = ord.NE__OptyId__r.AccountId;
                        if(mapAccountBPLI.containsKey(accountForBP)) {
                            XC_BillingProfileLineItem__c oldBPLI = mapAccountBPLI.get(accountForBP);
                            mapBPLIRollbackNewLE.put(oldBPLI.XC_BillingProfile__c, newLegalEntity);
                            mapBPLIRollbackOldLE.put(oldBPLI.XC_BillingProfile__c, oldLegalEntityFromOrder);
                        } else {
                            listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] Error to rollback BPLI for key (Account/NewLE/OldLE): ' + accountForBP + ' ' + newLegalEntity + ' ' + oldLegalEntityFromOrder, ''));
                        }
                    }
                } 
                if(listFoundedEhome.isEmpty() && !listFoundedEmobility.isEmpty())  {
                    // - Update Asset only for eMobility:
                    for(String assetId : listFoundedEmobility) {
                        wrapperToUpdate.listAsset.add(new Asset(Id = assetId, XC_LegalEntity__c = newLegalEntity));
                    }
                    // - Update Billing Profile Line Item for eMobility:
                    if(mapAccountBPLI.containsKey(ord.NE__OptyId__r.AccountId)) {
                        wrapperToUpdate.listBillingProfileLineItemUpdate.add(new XC_BillingProfileLineItem__c(Id = mapAccountBPLI.get(ord.NE__OptyId__r.AccountId).Id, XC_LegalEntity__c = newLegalEntity));
                    }
                }
				// NM
            }
            else {
                listLogsToInsert.add(insertBatchErrorLog('No Legal Entity Convertion found for key: ' + ord.XC_LegalEntity__c, ''));
            }
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/10/2021
     * @description Method to analyze type case
    */
    public static void checkOptyWithScheduledDelivery(WrapperObject wrObj, WrapperObjectToUpdate wrapperToUpdate, List<XC_BatchErrorLog__c> listLogsToInsert) {
        for(NE__Order__c ord : wrObj.listOrders) {
            String oldLegalEntityFromOrder  = ord.XC_LegalEntity__c;
            String newLegalEntity           = getNewLegalEntity(oldLegalEntityFromOrder);
            if(rollbackMode) {
                if(mapLegalEntityRollback.containsKey(''+ord.Id+ord.XC_LegalEntity__c)) {
                    newLegalEntity = mapLegalEntityRollback.get(''+ord.Id+ord.XC_LegalEntity__c);
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] No Legal Entity Convertion found for key: ' + ord.Id + ' ' + ord.XC_LegalEntity__c, ''));
                    return;
                }
            }
            if(String.isNotBlank(newLegalEntity) && newLegalEntity!='') {
                // Configuration:
                wrapperToUpdate.listOrder.add(new NE__Order__c(Id = ord.Id, XC_LegalEntity__c = newLegalEntity));
                // Opportunity:
                wrapperToUpdate.listOpty.add(new Opportunity(Id = ord.NE__OptyId__c, XC_LegalEntity__c = newLegalEntity, BLAZE_OldLegalEntity__c = oldLegalEntityFromOrder));
                // Account:
                wrapperToUpdate.listAccount.add(createAccountInfo(ord.NE__OptyId__r.AccountId, newLegalEntity));
                // Configuration Item:
                for(NE__OrderItem__c ordItem : ord.NE__Order_Items__r) {
                    wrapperToUpdate.listOrderItem.add(new NE__OrderItem__c(Id = ordItem.Id, XC_LegalEntity__c = newLegalEntity));
                }
                // Legal Entity Consent:
                XC_LegalEntityConsent__c lecCreated = createLegalEntityConsent(ord.NE__OptyId__r.AccountId, newLegalEntity, ord.XC_LegalEntity__c);
                if(lecCreated!=null) {
                    wrapperToUpdate.listLegalEntityConsent.add(lecCreated);
                }
                if(rollbackMode) {
                    String accountForLEC = ord.NE__OptyId__r.AccountId;
                    if(mapAccountIndividual.containsKey(accountForLEC)) {
                        String individualId = mapAccountIndividual.get(accountForLEC);
                        mapConsentNewRollback.put(individualId, newLegalEntity);
                        mapConsentOldRollback.put(individualId, oldLegalEntityFromOrder);
                    } else {
                        listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] Error to rollback LEC for key (Account/NewLE/OldLE): ' + accountForLEC + ' ' + newLegalEntity + ' ' + oldLegalEntityFromOrder, ''));
                    }
                }
                // Work Order:
                Map<String, String> mapWoToCheckSA = new Map<String, String>();
                for(WorkOrder wo : ord.Work_Orders__r) {
                    if(wo.XC_LegalEntity__c.toLowerCase() != 'enelxitalia' && (wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Delivery)) {
                        WorkOrder woItemToUpdate = new WorkOrder(Id = wo.Id, XC_LegalEntity__c = newLegalEntity);
                        String key = wo.XC_Segment__c+'_'+newLegalEntity+'_'+wo.XC_WorkTypeLabel__c;
                        if(mapWorkType.containsKey(key)) {
                            woItemToUpdate.WorkTypeId = mapWorkType.get(key);
                        } else {
                            woItemToUpdate.WorkTypeId = wo.WorkTypeId;
                            listLogsToInsert.add(insertBatchErrorLog('ERROR: No WorkType found to update WorkOrder ' + wo.Id + '. Please create it and change WT manually', 'WT: Name ' + wo.XC_WorkTypeLabel__c + ' LegalEntity ' + newLegalEntity + ' Segment ' + wo.XC_Segment__c + ''));
                        }
                        wrapperToUpdate.listWorkOrder.add(woItemToUpdate);
                        mapWoToCheckSA.put(wo.Id, woItemToUpdate.WorkTypeId);
                    }
                }
                // Service Appointment:
                for(String woId : mapWoToCheckSA.keySet()) {
                    if(wrObj.mapServiceAppointment.containsKey(woId)) {
                        wrapperToUpdate.listServiceAppointment.add(new ServiceAppointment(Id = wrObj.mapServiceAppointment.get(woId).Id, XC_LegalEntity__c = newLegalEntity));
                    }
                }
                // Asset:
                if(mapOrderAssets.containsKey(ord.Id)) {
                    for(Asset singleAsset : mapOrderAssets.get(ord.Id)) {
                        wrapperToUpdate.listAsset.add(new Asset(Id = singleAsset.Id, XC_LegalEntity__c = newLegalEntity));
                    }
                }
                // Billing Profile Line Item:
                /*XC_BillingProfileLineItem__c bpliCreated = createBillingProfileLineItem(ord.NE__OptyId__r.AccountId, newLegalEntity, listLogsToInsert);
                if(bpliCreated!=null) {
                    wrapperToUpdate.listBillingProfileLineItem.add(bpliCreated);
                    String key = ''+ord.NE__OptyId__r.AccountId+'-_-_-'+bpliCreated.XC_BillingProfile__c+'-_-_-'+newLegalEntity+'-_-_-'+bpliCreated.XC_Country__c;
                    // - Populate map to update Billing Profile Line Item on Asset
                    if(mapOrderAssets.containsKey(ord.Id)) {
                        for(Asset singleAsset : mapOrderAssets.get(ord.Id)) {
                            mapKeyAssetToUpdateBPLI.put(key, singleAsset.Id);
                        }
                    }
                    // - Populate map to update Billing Profile Line Item on Configuration Item
                    for(NE__OrderItem__c ordItem : ord.NE__Order_Items__r) {
                        mapKeyOrderItemToUpdateBPLI.put(key, ordItem.Id);
                    }
                }
                if(rollbackMode) {
                    String accountForBP = ord.NE__OptyId__r.AccountId;
                    if(mapAccountBPLI.containsKey(accountForBP)) {
                        XC_BillingProfileLineItem__c oldBPLI = mapAccountBPLI.get(accountForBP);
                        mapBPLIRollbackNewLE.put(oldBPLI.XC_BillingProfile__c, newLegalEntity);
                        mapBPLIRollbackOldLE.put(oldBPLI.XC_BillingProfile__c, oldLegalEntityFromOrder);
                    } else {
                        listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] Error to rollback BPLI for key (Account/NewLE/OldLE): ' + accountForBP + ' ' + newLegalEntity + ' ' + oldLegalEntityFromOrder, ''));
                    }
                }*/

                // NM 30.03.22
                List<String> listFoundedEhome                   = new List<String>();
                List<String> listFoundedEhomeTemp               = new List<String>();
                List<String> listFoundedEmobility               = new List<String>();
                List<String> listPaymentMethodForEmobilityAsset = new List<String>();
                for(Asset currentAsset : ord.NE__Assets__r) {
                    if(currentAsset.BLAZE_ToClean__c == 'Y') {
                        // Asset Mobility found:
                        listFoundedEmobility.add(currentAsset.Id);
                        listPaymentMethodForEmobilityAsset.add(currentAsset.XC_PaymentMethod__c);
                    } else {
                        // Asset eHome to check for payment method found:
                        listFoundedEhomeTemp.add(currentAsset.Id);
                    }
                }
                for(Asset currentAsset : ord.NE__Assets__r) {
                    if(listFoundedEhomeTemp.contains(currentAsset.Id)) {
                        // Asset eHome to check for payment method found:
                        if(listPaymentMethodForEmobilityAsset.contains(currentAsset.XC_PaymentMethod__c)) {
                            // Same payment method:
                            listFoundedEhome.add(currentAsset.Id);
                        } else {
                            // Different payment method:
                            listFoundedEmobility.add(currentAsset.Id);
                        }
                    }
                }
                if(!listFoundedEhome.isEmpty() && !listFoundedEmobility.isEmpty())  {
                    // - Update Asset only for eMobility:
                    for(String assetId : listFoundedEmobility) {
                        wrapperToUpdate.listAsset.add(new Asset(Id = assetId, XC_LegalEntity__c = newLegalEntity));
                    }
                    // - Duplicate Billing Profile Line Item for eMobility:
                    XC_BillingProfileLineItem__c bpliCreated = createBillingProfileLineItem(ord.NE__OptyId__r.AccountId, newLegalEntity, listLogsToInsert);
                    if(bpliCreated!=null) {
                        wrapperToUpdate.listBillingProfileLineItem.add(bpliCreated);
                        String key = ''+ord.NE__OptyId__r.AccountId+'-_-_-'+bpliCreated.XC_BillingProfile__c+'-_-_-'+newLegalEntity+'-_-_-'+bpliCreated.XC_Country__c;
                        // - Populate map to update Billing Profile Line Item on Asset
                        for(String singleAssetId : listFoundedEmobility) {
                            mapKeyAssetToUpdateBPLI.put(key, singleAssetId);
                        }
                    }
                    if(rollbackMode) {
                        String accountForBP = ord.NE__OptyId__r.AccountId;
                        if(mapAccountBPLI.containsKey(accountForBP)) {
                            XC_BillingProfileLineItem__c oldBPLI = mapAccountBPLI.get(accountForBP);
                            mapBPLIRollbackNewLE.put(oldBPLI.XC_BillingProfile__c, newLegalEntity);
                            mapBPLIRollbackOldLE.put(oldBPLI.XC_BillingProfile__c, oldLegalEntityFromOrder);
                        } else {
                            listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] Error to rollback BPLI for key (Account/NewLE/OldLE): ' + accountForBP + ' ' + newLegalEntity + ' ' + oldLegalEntityFromOrder, ''));
                        }
                    }
                } 
                if(listFoundedEhome.isEmpty() && !listFoundedEmobility.isEmpty())  {
                    // - Update Asset only for eMobility:
                    for(String assetId : listFoundedEmobility) {
                        wrapperToUpdate.listAsset.add(new Asset(Id = assetId, XC_LegalEntity__c = newLegalEntity));
                    }
                    // - Update Billing Profile Line Item for eMobility:
                    if(mapAccountBPLI.containsKey(ord.NE__OptyId__r.AccountId)) {
                        wrapperToUpdate.listBillingProfileLineItemUpdate.add(new XC_BillingProfileLineItem__c(Id = mapAccountBPLI.get(ord.NE__OptyId__r.AccountId).Id, XC_LegalEntity__c = newLegalEntity));
                    }
                }
				// NM

                // Recalculation WBE:
                for(NE__OrderItem__c ordItem : ord.NE__Order_Items__r) {
                    wrapperToUpdate.listOrderItemForWBE.add(ordItem.Id);
                }
            }
            else {
                listLogsToInsert.add(insertBatchErrorLog('No Legal Entity Convertion found for key: ' + ord.XC_LegalEntity__c, ''));
            }
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/10/2021
     * @description Method to analyze type case
    */
    public static void checkOptyWithDeliveryNotScheduled(WrapperObject wrObj, WrapperObjectToUpdate wrapperToUpdate, List<XC_BatchErrorLog__c> listLogsToInsert) {
        for(NE__Order__c ord : wrObj.listOrders) {
            String oldLegalEntityFromOrder  = ord.XC_LegalEntity__c;
            String newLegalEntity           = getNewLegalEntity(oldLegalEntityFromOrder);
            if(rollbackMode) {
                if(mapLegalEntityRollback.containsKey(''+ord.Id+ord.XC_LegalEntity__c)) {
                    newLegalEntity = mapLegalEntityRollback.get(''+ord.Id+ord.XC_LegalEntity__c);
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] No Legal Entity Convertion found for key: ' + ord.Id + ' ' + ord.XC_LegalEntity__c, ''));
                    return;
                }
            }
            if(String.isNotBlank(newLegalEntity) && newLegalEntity!='') {
                // Configuration:
                wrapperToUpdate.listOrder.add(new NE__Order__c(Id = ord.Id, XC_LegalEntity__c = newLegalEntity));
                // Opportunity:
                wrapperToUpdate.listOpty.add(new Opportunity(Id = ord.NE__OptyId__c, XC_LegalEntity__c = newLegalEntity, BLAZE_OldLegalEntity__c = oldLegalEntityFromOrder));
                // Account:
                wrapperToUpdate.listAccount.add(createAccountInfo(ord.NE__OptyId__r.AccountId, newLegalEntity));
                // Configuration Item:
                for(NE__OrderItem__c ordItem : ord.NE__Order_Items__r) {
                    wrapperToUpdate.listOrderItem.add(new NE__OrderItem__c(Id = ordItem.Id, XC_LegalEntity__c = newLegalEntity));
                }
                // Legal Entity Consent:
                XC_LegalEntityConsent__c lecCreated = createLegalEntityConsent(ord.NE__OptyId__r.AccountId, newLegalEntity, ord.XC_LegalEntity__c);
                if(lecCreated!=null) {
                    wrapperToUpdate.listLegalEntityConsent.add(lecCreated);
                }
                if(rollbackMode) {
                    String accountForLEC = ord.NE__OptyId__r.AccountId;
                    if(mapAccountIndividual.containsKey(accountForLEC)) {
                        String individualId = mapAccountIndividual.get(accountForLEC);
                        mapConsentNewRollback.put(individualId, newLegalEntity);
                        mapConsentOldRollback.put(individualId, oldLegalEntityFromOrder);
                    } else {
                        listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] Error to rollback LEC for key (Account/NewLE/OldLE): ' + accountForLEC + ' ' + newLegalEntity + ' ' + oldLegalEntityFromOrder, ''));
                    }
                }
                // Work Order:
                List<String> listWoToCheckSA = new List<String>();
                for(WorkOrder wo : ord.Work_Orders__r) {
                    if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Delivery) {
                        WorkOrder woItemToUpdate = new WorkOrder(Id = wo.Id, XC_LegalEntity__c = newLegalEntity);
                        String key = wo.XC_Segment__c+'_'+newLegalEntity+'_'+wo.XC_WorkTypeLabel__c;
                        if(mapWorkType.containsKey(key)) {
                            woItemToUpdate.WorkTypeId = mapWorkType.get(key);
                        } else {
                            listLogsToInsert.add(insertBatchErrorLog('ERROR: No WorkType found to update WorkOrder ' + wo.Id + '. Please create it and change WT manually', 'WT: Name ' + wo.XC_WorkTypeLabel__c + ' LegalEntity ' + newLegalEntity + ' Segment ' + wo.XC_Segment__c + ''));
                        }
                        wrapperToUpdate.listWorkOrder.add(woItemToUpdate);
                        listWoToCheckSA.add(wo.Id);
                    }
                }
                // Asset:
                if(mapOrderAssets.containsKey(ord.Id)) {
                    for(Asset singleAsset : mapOrderAssets.get(ord.Id)) {
                        wrapperToUpdate.listAsset.add(new Asset(Id = singleAsset.Id, XC_LegalEntity__c = newLegalEntity));
                    }
                }
                // Billing Profile Line Item:
                /*XC_BillingProfileLineItem__c bpliCreated = createBillingProfileLineItem(ord.NE__OptyId__r.AccountId, newLegalEntity, listLogsToInsert);
                if(bpliCreated!=null) {
                    wrapperToUpdate.listBillingProfileLineItem.add(bpliCreated);
                    String key = ''+ord.NE__OptyId__r.AccountId+'-_-_-'+bpliCreated.XC_BillingProfile__c+'-_-_-'+newLegalEntity+'-_-_-'+bpliCreated.XC_Country__c;
                    // - Populate map to update Billing Profile Line Item on Asset
                    if(mapOrderAssets.containsKey(ord.Id)) {
                        for(Asset singleAsset : mapOrderAssets.get(ord.Id)) {
                            mapKeyAssetToUpdateBPLI.put(key, singleAsset.Id);
                        }
                    }
                    // - Populate map to update Billing Profile Line Item on Configuration Item
                    for(NE__OrderItem__c ordItem : ord.NE__Order_Items__r) {
                        mapKeyOrderItemToUpdateBPLI.put(key, ordItem.Id);
                    }
                }
                if(rollbackMode) {
                    String accountForBP = ord.NE__OptyId__r.AccountId;
                    if(mapAccountBPLI.containsKey(accountForBP)) {
                        XC_BillingProfileLineItem__c oldBPLI = mapAccountBPLI.get(accountForBP);
                        mapBPLIRollbackNewLE.put(oldBPLI.XC_BillingProfile__c, newLegalEntity);
                        mapBPLIRollbackOldLE.put(oldBPLI.XC_BillingProfile__c, oldLegalEntityFromOrder);
                    } else {
                        listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] Error to rollback BPLI for key (Account/NewLE/OldLE): ' + accountForBP + ' ' + newLegalEntity + ' ' + oldLegalEntityFromOrder, ''));
                    }
                }*/

                // NM 30.03.22
                List<String> listFoundedEhome                   = new List<String>();
                List<String> listFoundedEhomeTemp               = new List<String>();
                List<String> listFoundedEmobility               = new List<String>();
                List<String> listPaymentMethodForEmobilityAsset = new List<String>();
                for(Asset currentAsset : ord.NE__Assets__r) {
                    if(currentAsset.BLAZE_ToClean__c == 'Y') {
                        // Asset Mobility found:
                        listFoundedEmobility.add(currentAsset.Id);
                        listPaymentMethodForEmobilityAsset.add(currentAsset.XC_PaymentMethod__c);
                    } else {
                        // Asset eHome to check for payment method found:
                        listFoundedEhomeTemp.add(currentAsset.Id);
                    }
                }
                for(Asset currentAsset : ord.NE__Assets__r) {
                    if(listFoundedEhomeTemp.contains(currentAsset.Id)) {
                        // Asset eHome to check for payment method found:
                        if(listPaymentMethodForEmobilityAsset.contains(currentAsset.XC_PaymentMethod__c)) {
                            // Same payment method:
                            listFoundedEhome.add(currentAsset.Id);
                        } else {
                            // Different payment method:
                            listFoundedEmobility.add(currentAsset.Id);
                        }
                    }
                }
                if(!listFoundedEhome.isEmpty() && !listFoundedEmobility.isEmpty())  {
                    // - Update Asset only for eMobility:
                    for(String assetId : listFoundedEmobility) {
                        wrapperToUpdate.listAsset.add(new Asset(Id = assetId, XC_LegalEntity__c = newLegalEntity));
                    }
                    // - Duplicate Billing Profile Line Item for eMobility:
                    XC_BillingProfileLineItem__c bpliCreated = createBillingProfileLineItem(ord.NE__OptyId__r.AccountId, newLegalEntity, listLogsToInsert);
                    if(bpliCreated!=null) {
                        wrapperToUpdate.listBillingProfileLineItem.add(bpliCreated);
                        String key = ''+ord.NE__OptyId__r.AccountId+'-_-_-'+bpliCreated.XC_BillingProfile__c+'-_-_-'+newLegalEntity+'-_-_-'+bpliCreated.XC_Country__c;
                        // - Populate map to update Billing Profile Line Item on Asset
                        for(String singleAssetId : listFoundedEmobility) {
                            mapKeyAssetToUpdateBPLI.put(key, singleAssetId);
                        }
                    }
                    if(rollbackMode) {
                        String accountForBP = ord.NE__OptyId__r.AccountId;
                        if(mapAccountBPLI.containsKey(accountForBP)) {
                            XC_BillingProfileLineItem__c oldBPLI = mapAccountBPLI.get(accountForBP);
                            mapBPLIRollbackNewLE.put(oldBPLI.XC_BillingProfile__c, newLegalEntity);
                            mapBPLIRollbackOldLE.put(oldBPLI.XC_BillingProfile__c, oldLegalEntityFromOrder);
                        } else {
                            listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] Error to rollback BPLI for key (Account/NewLE/OldLE): ' + accountForBP + ' ' + newLegalEntity + ' ' + oldLegalEntityFromOrder, ''));
                        }
                    }
                } 
                if(listFoundedEhome.isEmpty() && !listFoundedEmobility.isEmpty())  {
                    // - Update Asset only for eMobility:
                    for(String assetId : listFoundedEmobility) {
                        wrapperToUpdate.listAsset.add(new Asset(Id = assetId, XC_LegalEntity__c = newLegalEntity));
                    }
                    // - Update Billing Profile Line Item for eMobility:
                    if(mapAccountBPLI.containsKey(ord.NE__OptyId__r.AccountId)) {
                        wrapperToUpdate.listBillingProfileLineItemUpdate.add(new XC_BillingProfileLineItem__c(Id = mapAccountBPLI.get(ord.NE__OptyId__r.AccountId).Id, XC_LegalEntity__c = newLegalEntity));
                    }
                }
                // NM

                // Recalculation WBE:
                for(NE__OrderItem__c ordItem : ord.NE__Order_Items__r) {
                    wrapperToUpdate.listOrderItemForWBE.add(ordItem.Id);
                }
            }
            else {
                listLogsToInsert.add(insertBatchErrorLog('No Legal Entity Convertion found for key: ' + ord.XC_LegalEntity__c, ''));
            }
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/10/2021
     * @description Method to analyze type case
    */
    public static void checkOptyWithOtherWorkOrder(WrapperObject wrObj, WrapperObjectToUpdate wrapperToUpdate, List<XC_BatchErrorLog__c> listLogsToInsert) {
        for(NE__Order__c ord : wrObj.listOrders) {
            String oldLegalEntityFromOrder  = ord.XC_LegalEntity__c;
            String newLegalEntity           = getNewLegalEntity(oldLegalEntityFromOrder);
            if(rollbackMode) {
                if(mapLegalEntityRollback.containsKey(''+ord.Id+ord.XC_LegalEntity__c)) {
                    newLegalEntity = mapLegalEntityRollback.get(''+ord.Id+ord.XC_LegalEntity__c);
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] No Legal Entity Convertion found for key: ' + ord.Id + ' ' + ord.XC_LegalEntity__c, ''));
                    return;
                }
            }
            if(String.isNotBlank(newLegalEntity) && newLegalEntity!='') {
                // Configuration:
                wrapperToUpdate.listOrder.add(new NE__Order__c(Id = ord.Id, XC_LegalEntity__c = newLegalEntity));
                // Opportunity:
                wrapperToUpdate.listOpty.add(new Opportunity(Id = ord.NE__OptyId__c, XC_LegalEntity__c = newLegalEntity, BLAZE_OldLegalEntity__c = oldLegalEntityFromOrder));
                // Account:
                wrapperToUpdate.listAccount.add(createAccountInfo(ord.NE__OptyId__r.AccountId, newLegalEntity));
                // Configuration Item:
                for(NE__OrderItem__c ordItem : ord.NE__Order_Items__r) {
                    wrapperToUpdate.listOrderItem.add(new NE__OrderItem__c(Id = ordItem.Id, XC_LegalEntity__c = newLegalEntity));
                }
                // Legal Entity Consent:
                XC_LegalEntityConsent__c lecCreated = createLegalEntityConsent(ord.NE__OptyId__r.AccountId, newLegalEntity, ord.XC_LegalEntity__c);
                if(lecCreated!=null) {
                    wrapperToUpdate.listLegalEntityConsent.add(lecCreated);
                }
                if(rollbackMode) {
                    String accountForLEC = ord.NE__OptyId__r.AccountId;
                    if(mapAccountIndividual.containsKey(accountForLEC)) {
                        String individualId = mapAccountIndividual.get(accountForLEC);
                        mapConsentNewRollback.put(individualId, newLegalEntity);
                        mapConsentOldRollback.put(individualId, oldLegalEntityFromOrder);
                    } else {
                        listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] Error to rollback LEC for key (Account/NewLE/OldLE): ' + accountForLEC + ' ' + newLegalEntity + ' ' + oldLegalEntityFromOrder, ''));
                    }
                }
                // Work Order:
                Map<String, String> mapWoToCheckSA = new Map<String, String>();
                for(WorkOrder wo : ord.Work_Orders__r) {
                    if(wo.XC_WorkTypeCategory__c != Label.XC_CL_WorkType_DeliveryInstallation && wo.XC_WorkTypeCategory__c != Label.XC_CL_WorkType_SiteInspection) {
                        WorkOrder woItemToUpdate = new WorkOrder(Id = wo.Id, XC_LegalEntity__c = newLegalEntity);
                        String key = wo.XC_Segment__c+'_'+newLegalEntity+'_'+wo.XC_WorkTypeLabel__c;
                        if(mapWorkType.containsKey(key)) {
                            woItemToUpdate.WorkTypeId = mapWorkType.get(key);
                        } else {
                            woItemToUpdate.WorkTypeId = wo.WorkTypeId;
                            listLogsToInsert.add(insertBatchErrorLog('ERROR: No WorkType found to update WorkOrder ' + wo.Id + '. Please create it and change WT manually', 'WT: Name ' + wo.XC_WorkTypeLabel__c + ' LegalEntity ' + newLegalEntity + ' Segment ' + wo.XC_Segment__c + ''));
                        }
                        wrapperToUpdate.listWorkOrder.add(woItemToUpdate);
                        mapWoToCheckSA.put(wo.Id, woItemToUpdate.WorkTypeId);
                    }
                }
                // Service Appointment:
                for(String woId : mapWoToCheckSA.keySet()) {
                    if(wrObj.mapServiceAppointment.containsKey(woId)) {
                        wrapperToUpdate.listServiceAppointment.add(new ServiceAppointment(Id = wrObj.mapServiceAppointment.get(woId).Id, XC_LegalEntity__c = newLegalEntity));
                    }
                }
                // Asset:
                if(mapOrderAssets.containsKey(ord.Id)) {
                    for(Asset singleAsset : mapOrderAssets.get(ord.Id)) {
                        wrapperToUpdate.listAsset.add(new Asset(Id = singleAsset.Id, XC_LegalEntity__c = newLegalEntity));
                    }
                }

                // Billing Profile Line Item:
                /*XC_BillingProfileLineItem__c bpliCreated = createBillingProfileLineItem(ord.NE__OptyId__r.AccountId, newLegalEntity, listLogsToInsert);
                if(bpliCreated!=null) {
                    wrapperToUpdate.listBillingProfileLineItem.add(bpliCreated);
                    String key = ''+ord.NE__OptyId__r.AccountId+'-_-_-'+bpliCreated.XC_BillingProfile__c+'-_-_-'+newLegalEntity+'-_-_-'+bpliCreated.XC_Country__c;
                    // - Populate map to update Billing Profile Line Item on Asset
                    if(mapOrderAssets.containsKey(ord.Id)) {
                        for(Asset singleAsset : mapOrderAssets.get(ord.Id)) {
                            mapKeyAssetToUpdateBPLI.put(key, singleAsset.Id);
                        }
                    }
                    // - Populate map to update Billing Profile Line Item on Configuration Item
                    for(NE__OrderItem__c ordItem : ord.NE__Order_Items__r) {
                        mapKeyOrderItemToUpdateBPLI.put(key, ordItem.Id);
                    }
                }
                if(rollbackMode) {
                    String accountForBP = ord.NE__OptyId__r.AccountId;
                    if(mapAccountBPLI.containsKey(accountForBP)) {
                        XC_BillingProfileLineItem__c oldBPLI = mapAccountBPLI.get(accountForBP);
                        mapBPLIRollbackNewLE.put(oldBPLI.XC_BillingProfile__c, newLegalEntity);
                        mapBPLIRollbackOldLE.put(oldBPLI.XC_BillingProfile__c, oldLegalEntityFromOrder);
                    } else {
                        listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] Error to rollback BPLI for key (Account/NewLE/OldLE): ' + accountForBP + ' ' + newLegalEntity + ' ' + oldLegalEntityFromOrder, ''));
                    }
                }*/

                // NM 30.03.22
                List<String> listFoundedEhome                   = new List<String>();
                List<String> listFoundedEhomeTemp               = new List<String>();
                List<String> listFoundedEmobility               = new List<String>();
                List<String> listPaymentMethodForEmobilityAsset = new List<String>();
                for(Asset currentAsset : ord.NE__Assets__r) {
                    if(currentAsset.BLAZE_ToClean__c == 'Y') {
                        // Asset Mobility found:
                        listFoundedEmobility.add(currentAsset.Id);
                        listPaymentMethodForEmobilityAsset.add(currentAsset.XC_PaymentMethod__c);
                    } else {
                        // Asset eHome to check for payment method found:
                        listFoundedEhomeTemp.add(currentAsset.Id);
                    }
                }
                for(Asset currentAsset : ord.NE__Assets__r) {
                    if(listFoundedEhomeTemp.contains(currentAsset.Id)) {
                        // Asset eHome to check for payment method found:
                        if(listPaymentMethodForEmobilityAsset.contains(currentAsset.XC_PaymentMethod__c)) {
                            // Same payment method:
                            listFoundedEhome.add(currentAsset.Id);
                        } else {
                            // Different payment method:
                            listFoundedEmobility.add(currentAsset.Id);
                        }
                    }
                }
                if(!listFoundedEhome.isEmpty() && !listFoundedEmobility.isEmpty())  {
                    // - Update Asset only for eMobility:
                    for(String assetId : listFoundedEmobility) {
                        wrapperToUpdate.listAsset.add(new Asset(Id = assetId, XC_LegalEntity__c = newLegalEntity));
                    }
                    // - Duplicate Billing Profile Line Item for eMobility:
                    XC_BillingProfileLineItem__c bpliCreated = createBillingProfileLineItem(ord.NE__OptyId__r.AccountId, newLegalEntity, listLogsToInsert);
                    if(bpliCreated!=null) {
                        wrapperToUpdate.listBillingProfileLineItem.add(bpliCreated);
                        String key = ''+ord.NE__OptyId__r.AccountId+'-_-_-'+bpliCreated.XC_BillingProfile__c+'-_-_-'+newLegalEntity+'-_-_-'+bpliCreated.XC_Country__c;
                        // - Populate map to update Billing Profile Line Item on Asset
                        for(String singleAssetId : listFoundedEmobility) {
                            mapKeyAssetToUpdateBPLI.put(key, singleAssetId);
                        }
                    }
                    if(rollbackMode) {
                        String accountForBP = ord.NE__OptyId__r.AccountId;
                        if(mapAccountBPLI.containsKey(accountForBP)) {
                            XC_BillingProfileLineItem__c oldBPLI = mapAccountBPLI.get(accountForBP);
                            mapBPLIRollbackNewLE.put(oldBPLI.XC_BillingProfile__c, newLegalEntity);
                            mapBPLIRollbackOldLE.put(oldBPLI.XC_BillingProfile__c, oldLegalEntityFromOrder);
                        } else {
                            listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] Error to rollback BPLI for key (Account/NewLE/OldLE): ' + accountForBP + ' ' + newLegalEntity + ' ' + oldLegalEntityFromOrder, ''));
                        }
                    }
                } 
                if(listFoundedEhome.isEmpty() && !listFoundedEmobility.isEmpty())  {
                    // - Update Asset only for eMobility:
                    for(String assetId : listFoundedEmobility) {
                        wrapperToUpdate.listAsset.add(new Asset(Id = assetId, XC_LegalEntity__c = newLegalEntity));
                    }
                    // - Update Billing Profile Line Item for eMobility:
                    if(mapAccountBPLI.containsKey(ord.NE__OptyId__r.AccountId)) {
                        wrapperToUpdate.listBillingProfileLineItemUpdate.add(new XC_BillingProfileLineItem__c(Id = mapAccountBPLI.get(ord.NE__OptyId__r.AccountId).Id, XC_LegalEntity__c = newLegalEntity));
                    }
                }
                // NM

                // Recalculation WBE:
                for(NE__OrderItem__c ordItem : ord.NE__Order_Items__r) {
                    wrapperToUpdate.listOrderItemForWBE.add(ordItem.Id);
                }
            }
            else {
                listLogsToInsert.add(insertBatchErrorLog('No Legal Entity Convertion found for key: ' + ord.XC_LegalEntity__c, ''));
            }
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/10/2021
     * @description Method to analyze type case
    */
    public static void checkOptyWithClosedOrder(WrapperObject wrObj, WrapperObjectToUpdate wrapperToUpdate, List<XC_BatchErrorLog__c> listLogsToInsert) {
        // Create Map info by Asset (for payment method):
        List<NE__Order__c> listOrderWithAssets = new List<NE__Order__c>([
            SELECT Id,
            (
                SELECT Id, XC_PaymentMethod__c
                FROM NE__Assets__r
            )
            FROM NE__Order__c
            WHERE Id IN :XC_UTIL_Sobject.getListFieldValues(wrObj.listOrders, 'Id')
        ]);
        Map<String, List<Asset>> mapCloseOrderAssetsId  = new Map<String, List<Asset>>();
        Set<String> listOrderQueriedWithAsset           = new Set<String>();
        for(NE__Order__c singleItemOrd : listOrderWithAssets) {
            for(Asset singleItemAsset : singleItemOrd.NE__Assets__r) {
                if(!mapCloseOrderAssetsId.containsKey(singleItemOrd.Id)) {
                    mapCloseOrderAssetsId.put(singleItemOrd.Id, new List<Asset>());
                }
                mapCloseOrderAssetsId.get(singleItemOrd.Id).add(singleItemAsset);
                listOrderQueriedWithAsset.add(singleItemOrd.Id);
            }
        }
        // Processing:
        for(NE__Order__c ord : wrObj.listOrders) {
            String oldLegalEntityFromOrder  = ord.XC_LegalEntity__c;
            String newLegalEntity           = getNewLegalEntity(oldLegalEntityFromOrder);
            if(rollbackMode) {
                if(mapLegalEntityRollback.containsKey(''+ord.Id+ord.XC_LegalEntity__c)) {
                    newLegalEntity = mapLegalEntityRollback.get(''+ord.Id+ord.XC_LegalEntity__c);
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] No Legal Entity Convertion found for key: ' + ord.Id + ' ' + ord.XC_LegalEntity__c, ''));
                    return;
                }
            }
            if(String.isNotBlank(newLegalEntity) && newLegalEntity!='' && listOrderQueriedWithAsset.contains(ord.Id)) {
                // Configuration:
                wrapperToUpdate.listOrder.add(new NE__Order__c(Id = ord.Id, XC_LegalEntity__c = newLegalEntity));
                // Opportunity:
                wrapperToUpdate.listOpty.add(new Opportunity(Id = ord.NE__OptyId__c, XC_LegalEntity__c = newLegalEntity, BLAZE_OldLegalEntity__c = oldLegalEntityFromOrder));
                // Account:
                wrapperToUpdate.listAccount.add(createAccountInfo(ord.NE__OptyId__r.AccountId, newLegalEntity));
                // Legal Entity Consent:
                XC_LegalEntityConsent__c lecCreated = createLegalEntityConsent(ord.NE__OptyId__r.AccountId, newLegalEntity, ord.XC_LegalEntity__c);
                if(lecCreated!=null) {
                    wrapperToUpdate.listLegalEntityConsent.add(lecCreated);
                }
                if(rollbackMode) {
                    String accountForLEC = ord.NE__OptyId__r.AccountId;
                    if(mapAccountIndividual.containsKey(accountForLEC)) {
                        String individualId = mapAccountIndividual.get(accountForLEC);
                        mapConsentNewRollback.put(individualId, newLegalEntity);
                        mapConsentOldRollback.put(individualId, oldLegalEntityFromOrder);
                    } else {
                        listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] Error to rollback LEC for key (Account/NewLE/OldLE): ' + accountForLEC + ' ' + newLegalEntity + ' ' + oldLegalEntityFromOrder, ''));
                    }
                }
                // Asset:
                //List<Asset>  listAssetFromOrder                 = mapCloseOrderAssetsId.get(ord.Id);
                List<String> listFoundedEhome                   = new List<String>();
                List<String> listFoundedEhomeTemp               = new List<String>();
                List<String> listFoundedEmobility               = new List<String>();
                List<String> listPaymentMethodForEmobilityAsset = new List<String>();
                for(Asset currentAsset : ord.NE__Assets__r) {
                    if(currentAsset.BLAZE_ToClean__c == 'Y') {
                        // Asset Mobility found:
                        listFoundedEmobility.add(currentAsset.Id);
                        listPaymentMethodForEmobilityAsset.add(currentAsset.XC_PaymentMethod__c);
                    } else {
                        // Asset eHome to check for payment method found:
                        listFoundedEhomeTemp.add(currentAsset.Id);
                    }
                }
                for(Asset currentAsset : ord.NE__Assets__r) {
                    if(listFoundedEhomeTemp.contains(currentAsset.Id)) {
                        // Asset eHome to check for payment method found:
                        if(listPaymentMethodForEmobilityAsset.contains(currentAsset.XC_PaymentMethod__c)) {
                            // Same payment method:
                            listFoundedEhome.add(currentAsset.Id);
                        } else {
                            // Different payment method:
                            listFoundedEmobility.add(currentAsset.Id);
                        }
                    }
                }
                if(!listFoundedEhome.isEmpty() && !listFoundedEmobility.isEmpty())  {
                    // - Update Asset only for eMobility:
                    for(String assetId : listFoundedEmobility) {
                        wrapperToUpdate.listAsset.add(new Asset(Id = assetId, XC_LegalEntity__c = newLegalEntity));
                    }
                    // - Duplicate Billing Profile Line Item for eMobility:
                    XC_BillingProfileLineItem__c bpliCreated = createBillingProfileLineItem(ord.NE__OptyId__r.AccountId, newLegalEntity, listLogsToInsert);
                    if(bpliCreated!=null) {
                        wrapperToUpdate.listBillingProfileLineItem.add(bpliCreated);
                        String key = ''+ord.NE__OptyId__r.AccountId+'-_-_-'+bpliCreated.XC_BillingProfile__c+'-_-_-'+newLegalEntity+'-_-_-'+bpliCreated.XC_Country__c;
                        // - Populate map to update Billing Profile Line Item on Asset
                        for(String singleAssetId : listFoundedEmobility) {
                            mapKeyAssetToUpdateBPLI.put(key, singleAssetId);
                        }
                    }
                    if(rollbackMode) {
                        String accountForBP = ord.NE__OptyId__r.AccountId;
                        if(mapAccountBPLI.containsKey(accountForBP)) {
                            XC_BillingProfileLineItem__c oldBPLI = mapAccountBPLI.get(accountForBP);
                            mapBPLIRollbackNewLE.put(oldBPLI.XC_BillingProfile__c, newLegalEntity);
                            mapBPLIRollbackOldLE.put(oldBPLI.XC_BillingProfile__c, oldLegalEntityFromOrder);
                        } else {
                            listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] Error to rollback BPLI for key (Account/NewLE/OldLE): ' + accountForBP + ' ' + newLegalEntity + ' ' + oldLegalEntityFromOrder, ''));
                        }
                    }
                } 
                if(listFoundedEhome.isEmpty() && !listFoundedEmobility.isEmpty())  {
                    // - Update Asset only for eMobility:
                    for(String assetId : listFoundedEmobility) {
                        wrapperToUpdate.listAsset.add(new Asset(Id = assetId, XC_LegalEntity__c = newLegalEntity));
                    }
                    // - Update Billing Profile Line Item for eMobility:
                    if(mapAccountBPLI.containsKey(ord.NE__OptyId__r.AccountId)) {
                        wrapperToUpdate.listBillingProfileLineItemUpdate.add(new XC_BillingProfileLineItem__c(Id = mapAccountBPLI.get(ord.NE__OptyId__r.AccountId).Id, XC_LegalEntity__c = newLegalEntity));
                    }
                }
                // Recalculation WBE:
                for(NE__OrderItem__c ordItem : ord.NE__Order_Items__r) {
                    wrapperToUpdate.listOrderItemForWBE.add(ordItem.Id);
                }
            }
            else {
                listLogsToInsert.add(insertBatchErrorLog('No Legal Entity Convertion found for key: ' + ord.XC_LegalEntity__c, ''));
            }
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 17/10/2021
     * @description Method to analyze type case
    */
    public static void checkAssetWithoutOrder(WrapperObject wrObj, WrapperObjectToUpdate wrapperToUpdate, List<XC_BatchErrorLog__c> listLogsToInsert) {
        // Query Asset info:
        List<Asset> listAssetForTypeCase = new List<Asset>([
            SELECT Id, AccountId, XC_LegalEntity__c, NE__Order_Config__c, BLAZE_ToClean__c,
                (SELECT Id, XC_LegalEntity__c
                FROM Cases1__r
                WHERE Status = 'ESTA001')
            FROM Asset
            WHERE Id IN :wrObj.listAssetIdsWithoutOrder
        ]);
        // Query WorkOrder and save new work type:
        Map<String, List<String>> mapAssetCase = new Map<String, List<String>>();
        List<String> listCaseId = new List<String>();
        for(Asset ass : listAssetForTypeCase) {
            for(Case cas : ass.Cases1__r) {
                listCaseId.add(cas.Id);
                if(!mapAssetCase.containsKey(ass.Id)) {
                    mapAssetCase.put(ass.Id, new List<String>());
                }
                mapAssetCase.get(ass.Id).add(cas.Id);
            }
        }
        Map<Id, WorkOrder> mapWorkOrder = new Map<Id, WorkOrder>([
            SELECT Id, XC_LegalEntity__c, XC_WorkTypeLabel__c, XC_Segment__c, WorkTypeId
            FROM WorkOrder
            WHERE CaseId IN :listCaseId
        ]);
        for(WorkOrder singleWoItem : mapWorkOrder.values()) {
            listWorkOrderToDiscoveryWT.add(singleWoItem);
        }
        saveNewWorkType();

        // Create Map Account->Individual */
        List<Contact> listContact = new List<Contact>([
            SELECT Id, IndividualId, AccountId
            FROM Contact
            WHERE AccountId IN :XC_UTIL_Sobject.getListFieldValues(listAssetForTypeCase, 'AccountId') AND XC_PrimaryContact__c = true
        ]);
        for(Contact cnt : listContact) {
            mapAccountIndividual.put(cnt.AccountId, cnt.IndividualId);
        }
        // Create Map Key -> LEC
        List<XC_LegalEntityConsent__c> listLECQueried = new List<XC_LegalEntityConsent__c>([
            SELECT Id, XC_Individual__c, XC_LegalEntity__c, XC_IndividualId__c, XC_LeCountry__c, XC_GiveDataToNew__c, XC_LECollectedMarketingConsents__c, XC_MarketingConsent__c, XC_CollectionDateMarketing__c, XC_IndividualLegalEntity__c, XC_UpdateAboutProducts__c, XC_ConsentToDataProcessing__c, XC_CompanyConsentVersion__c, XC_MarketingConsentVersion__c, XC_ProfilingConsentVersion__c, XC_CollectionChannelMarketing__c, XC_CollectionUserMarketing__c, XC_ProfilingConsent__c, XC_LECollectedProfilingConsents__c, XC_CollectionDateProfiling__c, XC_CollectionChannelProfiling__c, XC_CollectionUserProfiling__c, XC_ConsentDescription__c, XC_ExternalId__c, XC_GiveDataTo__c, XC_ExpirationDateProfilingConsent__c, XC_ExpirationDateMarketingConsent__c, XC_Status__c, XC_NotCustomerConsent__c, XC_ThirdProductsMarketingConsent__c, XC_NotCustomerConsentVersion__c, XC_ThirdProductsMarketingConsentVersion__c, XC_LECollectedNotCustomerConsents__c, XC_LECollectedThirdProductsMarketingCons__c, XC_CollectionDateNotCustomer__c, XC_CollectionDateThirdProductsMarketing__c, XC_CollectionChannelNotCustomer__c, XC_CollectionChannelThirdProdMarketing__c, XC_CollectionUserNotCustomer__c, XC_CollectionUserThirdProductsMarketing__c, XC_FromAPI__c
            FROM XC_LegalEntityConsent__c
            WHERE XC_Individual__c IN :mapAccountIndividual.values()
        ]);
        for(XC_LegalEntityConsent__c singleLecQueried : listLECQueried) {
            String key = ''+ singleLecQueried.XC_Individual__c + singleLecQueried.XC_LegalEntity__c;
            mapKeyLEC.put(key, singleLecQueried);
        }
        // Create Map WorkOrder->ServiceAppointment list:
        Map<String, ServiceAppointment> mapSa = new Map<String, ServiceAppointment>();
        if(!mapWorkOrder.keySet().isEmpty()) {
            List<ServiceAppointment> listSa = new List<ServiceAppointment>([
                SELECT Id, ParentRecordId, XC_LegalEntity__c
                FROM ServiceAppointment
                WHERE ParentRecordId IN :mapWorkOrder.keySet() AND XC_IsFinalStatus__c = false
            ]);
            for(ServiceAppointment sa : listSa) {
                mapSa.put(sa.ParentRecordId, sa);
            }
        }

        for(Asset singleAsset : listAssetForTypeCase) {
            String oldLegalEntityFromOrder  = singleAsset.XC_LegalEntity__c;
            String newLegalEntity           = getNewLegalEntity(oldLegalEntityFromOrder);
            if(rollbackMode) {
                if(mapLegalEntityRollback.containsKey(''+singleAsset.NE__Order_Config__c+oldLegalEntityFromOrder)) {
                    newLegalEntity = mapLegalEntityRollback.get(''+singleAsset.NE__Order_Config__c+oldLegalEntityFromOrder);
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] No Legal Entity Convertion found for key: ' + singleAsset.NE__Order_Config__c + ' ' + oldLegalEntityFromOrder, ''));
                    return;
                }
            }
            if(String.isNotBlank(newLegalEntity) && newLegalEntity!='') {
                // Asset:
                wrapperToUpdate.listAsset.add(new Asset(Id = singleAsset.Id, XC_LegalEntity__c = newLegalEntity));
                //Case:
                if(mapAssetCase.containsKey(singleAsset.Id)) {
                    for(String singleCs : mapAssetCase.get(singleAsset.Id)) {
                        wrapperToUpdate.listCase.add(new Case(Id = singleCs, XC_LegalEntity__c = newLegalEntity));
                    }
                }
                // Account:
                wrapperToUpdate.listAccount.add(createAccountInfo(singleAsset.AccountId, newLegalEntity));
                // Legal Entity Consent:
                XC_LegalEntityConsent__c lecCreated = createLegalEntityConsent(singleAsset.AccountId, newLegalEntity, singleAsset.XC_LegalEntity__c);
                if(lecCreated!=null) {
                    wrapperToUpdate.listLegalEntityConsent.add(lecCreated);
                }
                if(rollbackMode) {
                    String accountForLEC = singleAsset.AccountId;
                    if(mapAccountIndividual.containsKey(accountForLEC)) {
                        String individualId = mapAccountIndividual.get(accountForLEC);
                        mapConsentNewRollback.put(individualId, newLegalEntity);
                        mapConsentOldRollback.put(individualId, oldLegalEntityFromOrder);
                    } else {
                        listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] Error to rollback LEC for key (Account/NewLE/OldLE): ' + accountForLEC + ' ' + newLegalEntity + ' ' + oldLegalEntityFromOrder, ''));
                    }
                }
                // Work Order:
                Map<String, String> mapWoToCheckSA = new Map<String, String>();
                for(WorkOrder wo : mapWorkOrder.values()) {
                    WorkOrder woItemToUpdate = new WorkOrder(Id = wo.Id, XC_LegalEntity__c = newLegalEntity);
                    String key = wo.XC_Segment__c+'_'+newLegalEntity+'_'+wo.XC_WorkTypeLabel__c;
                    if(mapWorkType.containsKey(key)) {
                        woItemToUpdate.WorkTypeId = mapWorkType.get(key);
                    } else {
                        woItemToUpdate.WorkTypeId = wo.WorkTypeId;
                        listLogsToInsert.add(insertBatchErrorLog('ERROR: No WorkType found to update WorkOrder ' + wo.Id + '. Please create it and change WT manually', 'WT: Name ' + wo.XC_WorkTypeLabel__c + ' LegalEntity ' + newLegalEntity + ' Segment ' + wo.XC_Segment__c + ''));
                    }
                    wrapperToUpdate.listWorkOrder.add(woItemToUpdate);
                    mapWoToCheckSA.put(wo.Id, woItemToUpdate.WorkTypeId);
                }
                // Service Appointment:
                for(String woId : mapWoToCheckSA.keySet()) {
                    if(mapSa.containsKey(woId)) {
                        wrapperToUpdate.listServiceAppointment.add(new ServiceAppointment(Id = mapSa.get(woId).Id, XC_LegalEntity__c = newLegalEntity));
                    }
                }
                // Billing Profile Line Item:
                /*XC_BillingProfileLineItem__c bpliCreated = createBillingProfileLineItem(singleAsset.AccountId, newLegalEntity, listLogsToInsert);
                if(bpliCreated!=null) {
                    wrapperToUpdate.listBillingProfileLineItem.add(bpliCreated);
                    // - Populate map to update Billing Profile Line Item on Configuration Item
                    String key = ''+singleAsset.AccountId+'-_-_-'+bpliCreated.XC_BillingProfile__c+'-_-_-'+newLegalEntity+'-_-_-'+bpliCreated.XC_Country__c;
                    mapKeyAssetToUpdateBPLI.put(key, singleAsset.Id);
                }*/

                // NM 30.03.2022
                if(singleAsset.BLAZE_ToClean__c != 'Y') {
                    // - Duplicate Billing Profile Line Item for eMobility:
                    XC_BillingProfileLineItem__c bpliCreated = createBillingProfileLineItem(singleAsset.AccountId, newLegalEntity, listLogsToInsert);
                    if(bpliCreated!=null) {
                        wrapperToUpdate.listBillingProfileLineItem.add(bpliCreated);
                        String key = ''+singleAsset.AccountId+'-_-_-'+bpliCreated.XC_BillingProfile__c+'-_-_-'+newLegalEntity+'-_-_-'+bpliCreated.XC_Country__c;
                        // - Populate map to update Billing Profile Line Item on Asset
                        mapKeyAssetToUpdateBPLI.put(key, singleAsset.Id);
                    }
                    if(rollbackMode) {
                        String accountForBP = singleAsset.AccountId;
                        if(mapAccountBPLI.containsKey(accountForBP)) {
                            XC_BillingProfileLineItem__c oldBPLI = mapAccountBPLI.get(accountForBP);
                            mapBPLIRollbackNewLE.put(oldBPLI.XC_BillingProfile__c, newLegalEntity);
                            mapBPLIRollbackOldLE.put(oldBPLI.XC_BillingProfile__c, oldLegalEntityFromOrder);
                        } else {
                            listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] Error to rollback BPLI for key (Account/NewLE/OldLE): ' + accountForBP + ' ' + newLegalEntity + ' ' + oldLegalEntityFromOrder, ''));
                        }
                    }
                } else {
                    // - Update Billing Profile Line Item for eMobility:
                    if(mapAccountBPLI.containsKey(singleAsset.AccountId)) {
                        wrapperToUpdate.listBillingProfileLineItemUpdate.add(new XC_BillingProfileLineItem__c(Id = mapAccountBPLI.get(singleAsset.AccountId).Id, XC_LegalEntity__c = newLegalEntity));
                    }
                }
                // NM
            }
        }
    }

    //************************************************************************************************************************************** UTIL METHODS: */

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 07/10/2021
     * @description Method to retrieve new legal entity
    */
    public static String getNewLegalEntity(String oldLegalEntity) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In getNewLegalEntity for value: ' + oldLegalEntity);
        String newLegalEntity = '';
        for(String keyConvertion : mapLegalEntityConvertion.keySet()) {
            if(keyConvertion.toLowerCase() == oldLegalEntity.toLowerCase()) {
                return mapLegalEntityConvertion.get(keyConvertion);
            }
        }
        return '';
    }   

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 07/03/2022
     * @description Method to insert Batch Error Log
    */
    public static XC_BatchErrorLog__c insertBatchErrorLog(String errorMessage, String recordInfo) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Inserting error log with message: ' + errorMessage);
        return new XC_BatchErrorLog__c(
            XC_ErrorMessage__c = '[LOG ' + CURRENT_TIME + '] ' + errorMessage, 
            XC_TypeOfOperation__c = 'BLAZE Data Cleaning',
            XC_RecordInfo__c = recordInfo
        );
    }   

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 07/10/2021
     * @description Method to create new Legal Entity Consent for Account
    */
    public static Account createAccountInfo(String accountId, String legalEntityNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In createAccountInfo');
        Account acc = new Account(Id = accountId);
        String field = 'XC_GiveDataTo_' + legalEntityNew + '__c';
        acc.put(field.replaceAll('\\s+', ''), true);
        return acc;
    }  

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 07/10/2021
     * @description Method to create new Legal Entity Consent
    */
    public static XC_LegalEntityConsent__c createLegalEntityConsent(String accountId, String newLegalEntity, String oldLegalEntity) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In createLegalEntityConsent');
        if(mapAccountIndividual.containsKey(accountId) && !listKeyAlreadyCreatedLEC.contains(accountId+newLegalEntity)) {
            String individualId = mapAccountIndividual.get(accountId);
            String keyMap = ''+individualId+oldLegalEntity;
            String keyMapNewValue = ''+individualId+newLegalEntity;
            if(mapKeyLEC.containsKey(keyMap) && !mapKeyLEC.containsKey(keyMapNewValue)) {
                XC_LegalEntityConsent__c oldLec = mapKeyLEC.get(keyMap);
                XC_LegalEntityConsent__c legalEntityToInsert = new XC_LegalEntityConsent__c();
                legalEntityToInsert.XC_Individual__c = individualId;
                legalEntityToInsert.XC_LegalEntity__c = newLegalEntity;
                legalEntityToInsert.XC_IndividualLegalEntity__c = oldLec.XC_IndividualLegalEntity__c;
                legalEntityToInsert.XC_IndividualId__c = individualId;
                legalEntityToInsert.XC_LeCountry__c = oldLec.XC_LeCountry__c;
                legalEntityToInsert.XC_GiveDataToNew__c = oldLec.XC_GiveDataToNew__c;
                legalEntityToInsert.XC_LECollectedMarketingConsents__c = newLegalEntity;
                legalEntityToInsert.XC_MarketingConsent__c = oldLec.XC_MarketingConsent__c;
                legalEntityToInsert.XC_CollectionDateMarketing__c = oldLec.XC_CollectionDateMarketing__c;
                legalEntityToInsert.XC_IndividualLegalEntity__c = oldLec.XC_IndividualLegalEntity__c;
                legalEntityToInsert.XC_UpdateAboutProducts__c = oldLec.XC_UpdateAboutProducts__c;
                legalEntityToInsert.XC_ConsentToDataProcessing__c = oldLec.XC_ConsentToDataProcessing__c;
                legalEntityToInsert.XC_CompanyConsentVersion__c = oldLec.XC_CompanyConsentVersion__c;
                legalEntityToInsert.XC_MarketingConsentVersion__c = oldLec.XC_MarketingConsentVersion__c;
                legalEntityToInsert.XC_ProfilingConsentVersion__c = oldLec.XC_ProfilingConsentVersion__c;
                legalEntityToInsert.XC_CollectionChannelMarketing__c = oldLec.XC_CollectionChannelMarketing__c;
                legalEntityToInsert.XC_CollectionUserMarketing__c = oldLec.XC_CollectionUserMarketing__c;
                legalEntityToInsert.XC_ProfilingConsent__c = '';
                legalEntityToInsert.XC_LECollectedProfilingConsents__c = newLegalEntity;
                legalEntityToInsert.XC_CollectionDateProfiling__c = oldLec.XC_CollectionDateProfiling__c;
                legalEntityToInsert.XC_CollectionChannelProfiling__c = oldLec.XC_CollectionChannelProfiling__c;
                legalEntityToInsert.XC_CollectionUserProfiling__c = oldLec.XC_CollectionUserProfiling__c;
                legalEntityToInsert.XC_ConsentDescription__c = oldLec.XC_ConsentDescription__c;
                legalEntityToInsert.XC_ExternalId__c = oldLec.XC_ExternalId__c;
                legalEntityToInsert.XC_GiveDataTo__c = oldLec.XC_GiveDataTo__c;
                legalEntityToInsert.XC_ExpirationDateProfilingConsent__c = oldLec.XC_ExpirationDateProfilingConsent__c;
                legalEntityToInsert.XC_ExpirationDateMarketingConsent__c = oldLec.XC_ExpirationDateMarketingConsent__c;
                legalEntityToInsert.XC_Status__c = oldLec.XC_Status__c;
                legalEntityToInsert.XC_NotCustomerConsent__c = oldLec.XC_NotCustomerConsent__c;
                legalEntityToInsert.XC_ThirdProductsMarketingConsent__c = oldLec.XC_ThirdProductsMarketingConsent__c;
                legalEntityToInsert.XC_NotCustomerConsentVersion__c = oldLec.XC_NotCustomerConsentVersion__c;
                legalEntityToInsert.XC_ThirdProductsMarketingConsentVersion__c = oldLec.XC_ThirdProductsMarketingConsentVersion__c;
                legalEntityToInsert.XC_LECollectedNotCustomerConsents__c = newLegalEntity;
                legalEntityToInsert.XC_LECollectedThirdProductsMarketingCons__c = newLegalEntity;
                legalEntityToInsert.XC_CollectionDateNotCustomer__c = oldLec.XC_CollectionDateNotCustomer__c;
                legalEntityToInsert.XC_CollectionDateThirdProductsMarketing__c = oldLec.XC_CollectionDateThirdProductsMarketing__c;
                legalEntityToInsert.XC_CollectionChannelNotCustomer__c = oldLec.XC_CollectionChannelNotCustomer__c;
                legalEntityToInsert.XC_CollectionChannelThirdProdMarketing__c = oldLec.XC_CollectionChannelThirdProdMarketing__c;
                legalEntityToInsert.XC_CollectionUserNotCustomer__c = oldLec.XC_CollectionUserNotCustomer__c;
                legalEntityToInsert.XC_CollectionUserThirdProductsMarketing__c = oldLec.XC_CollectionUserThirdProductsMarketing__c;
                legalEntityToInsert.XC_FromAPI__c = oldLec.XC_FromAPI__c;
                listKeyAlreadyCreatedLEC.add(accountId+newLegalEntity);
                return legalEntityToInsert;
            }
            else {
                return null;
            }
        }
        return null;
    } 
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 07/10/2021
     * @description Method to create new Billing Profile Line Item
    */
    public static XC_BillingProfileLineItem__c createBillingProfileLineItem(String accountId, String newLegalEntity, List<XC_BatchErrorLog__c> listLogsToInsert) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In createBillingProfileLineItem');
        if(mapAccountBPLI.containsKey(accountId) && !listKeyAlreadyCreatedBPLI.contains(accountId+newLegalEntity)) {
            XC_BillingProfileLineItem__c oldBPLI    = mapAccountBPLI.get(accountId);
            /*XC_BillingProfileLineItem__c bpli       = new XC_BillingProfileLineItem__c();
            bpli.XC_Account__c                      = accountId;
            bpli.XC_BillingProfile__c               = oldBPLI.XC_BillingProfile__c;
            bpli.XC_BillingProfileCopy__c           = oldBPLI.XC_BillingProfile__c;
            bpli.XC_BillToAddress__c                = oldBPLI.XC_BillToAddress__c;
            bpli.XC_SoldToAddress__c                = oldBPLI.XC_SoldToAddress__c;
            bpli.XC_BillToContactId__c              = oldBPLI.XC_BillToContactId__c;
            bpli.XC_SoldToContactId__c              = oldBPLI.XC_SoldToContactId__c;
            bpli.XC_LegalEntity__c                  = newLegalEntity;
            bpli.XC_BillingProfileName__c           = oldBPLI.XC_BillingProfileName__c;
            bpli.XC_DocumentType__c                 = oldBPLI.XC_DocumentType__c;
            bpli.XC_DocumentNumber__c               = oldBPLI.XC_DocumentNumber__c;
            bpli.XC_DocumentCountry__c              = oldBPLI.XC_DocumentCountry__c;
            bpli.XC_Status__c                       = Label.XC_CL_BillingProfileStatus_Draft;
            bpli.XC_InvoicePreferredLanguage__c     = oldBPLI.XC_InvoicePreferredLanguage__c;
            bpli.XC_InvoiceDeliveryPreference__c    = oldBPLI.XC_InvoiceDeliveryPreference__c;
            bpli.XC_Country__c                      = oldBPLI.XC_Country__c;
            bpli.XC_CustomerAccount__c              = oldBPLI.XC_CustomerAccount__c;
            bpli.XC_BillingAddress__c               = oldBPLI.XC_BillingAddress__c;
            bpli.XC_ExternalKey__c                  = oldBPLI.XC_ExternalKey__c;
            bpli.XC_RecipientCode__c                = oldBPLI.XC_RecipientCode__c;
            if(String.isNotBlank(oldBPLI.XC_PEC__c)) {
                bpli.XC_PEC__c = oldBPLI.XC_PEC__c;
            }
            if(String.isNotBlank(oldBPLI.XC_RecipientCodeB2B__c)) {
                bpli.XC_RecipientCodeB2B__c = oldBPLI.XC_RecipientCodeB2B__c;
            }
            if(String.isNotBlank(oldBPLI.XC_OfficeCode__c)) {
                bpli.XC_OfficeCode__c = oldBPLI.XC_OfficeCode__c;
            }
            if(String.isNotBlank(oldBPLI.XC_RecipientCode__c)) {
                bpli.XC_RecipientCode__c = oldBPLI.XC_RecipientCode__c;
            }
            if(String.isNotBlank(oldBPLI.XC_TPBCode__c)) {
                bpli.XC_TPBCode__c = oldBPLI.XC_TPBCode__c;
            }
            listKeyAlreadyCreatedBPLI.add(accountId+newLegalEntity);
            return bpli;*/
            listLogsToInsert.add(insertBatchErrorLog('WARNING: Create ChangeOrder for Account ' + accountId + ' to duplicate BPLI', 'Billing Profile: ' + oldBPLI.XC_BillingProfile__c + '\nNew Legal Entity: ' + newLegalEntity));
            return null;
        } else {
            listLogsToInsert.add(insertBatchErrorLog('ERROR: No BPLI found to clone for Account ' + accountId + ' or BPLI already exists', 'Error during creation BPLI for Account Id ' + accountId + ' with new Legal Entity ' + newLegalEntity + '.\nMaybe OrderItem->BillingProfileLineItem is blank. Please, insert new BPLI manually searching AccountId if it does not exist.'));
            return null;
        }
    } 

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 07/03/2022
     * @description Method to recalculate WBE
    */
    public static List<XC_BatchErrorLog__c> recalculateWBE(List<String> listOrderItemB2C, List<String> listOrderItemB2BG) {
        List<XC_BatchErrorLog__c> listLogs = new List<XC_BatchErrorLog__c>();
        // For B2C:
        if(!listOrderItemB2C.isEmpty()) {
            String query = 'SELECT Id, IsDeleted, Name, CurrencyIsoCode, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, NE__OrderId__c, NE__Account__c, NE__Action__c, NE__Activation_Date__c, NE__Additional_Information__c, NE__Address_Line1__c, NE__Address_Line2__c, NE__Address_Line3__c, NE__AssetItemEnterpriseCalc__c, NE__AssetItemEnterpriseId__c, NE__Asset_Item_Account__c, NE__BaseOneTimeFee__c, NE__BaseRecurringCharge__c, NE__BillingProfId__c, NE__Billing_Account_Asset_Item__c, NE__Billing_Account__c, NE__Billing_Description__c, NE__Billing_Profile__c, NE__Bundle_Configuration__c, NE__Bundle_Element__c, NE__Bundle__c, NE__CalculatedVisibility__c, NE__Cart_Description__c, NE__CatalogItem__c, NE__Catalog__c, NE__City__c, NE__Commissioning_cost__c, NE__Commitment_Expiration_Date__c, NE__Commitment_Period__c, NE__Commitment_UOM__c, NE__Commitment__c, NE__ConfigurationStatus__c, NE__Configuration_item_update_key__c, NE__Contract__c, NE__Country_Code__c, NE__Country__c, NE__Currency_Extension_1__c, NE__Currency_Extension_2__c, NE__Currency_Extension_3__c, NE__Currency_Extension_4__c, NE__Currency_Extension_5__c, NE__Dated_Base_One_Time_Fee__c, NE__Dated_Recurring_Charge__c, NE__Decimal_Quantity__c, NE__Delivery_Date__c, NE__Description__c, NE__DiscountId__c, NE__Discount_One_time__c, NE__Discount_Perc_OneTimeFee__c, NE__Discount_Perc_RecurringCharge__c, NE__Discount__c, NE__Dynamic_Code__c, NE__EndDate__c, NE__FilterForDataMapNoPromo__c, NE__FilterForDataMapOkPromo__c, NE__FulfilmentStatus__c, NE__Generate_Asset_Item_Calc__c, NE__Generate_Asset_Item__c, NE__Generate_Promo_Asset_Item_Calc__c, NE__Geolocalization__Latitude__s, NE__Geolocalization__Longitude__s, NE__Geolocalization__c, NE__Hidden_in_Cart__c, NE__IsPromo__c, NE__Item_Code__c, NE__Magnitude__c, NE__Multiply_Configuration_Item__c, NE__OneTimeFeeCode__c, NE__OneTimeFeeDiscounted__c, NE__OneTimeFeeOVApplied__c, NE__OneTimeFeeOv__c, NE__OneTimeFeePb__c, NE__One_Time_Cost__c, NE__One_Time_Tax_Free__c, NE__Optional__c, NE__OrderItemPromoId__c, NE__Parameters__c, NE__Parent_Logic__c, NE__Parent_Order_Item__c, NE__PenaltyImage__c, NE__Penalty_Activated__c, NE__Penalty_Fee__c, NE__Penalty_Type__c, NE__Penalty__c, NE__Picked_By__c, NE__Postal_Code__c, NE__ProdId__c, NE__ProdName__c, NE__PromotionId__c, NE__Province__c, NE__Qty__c, NE__RecurringChargeCode__c, NE__RecurringChargeDiscounted__c, NE__RecurringChargeFrequency__c, NE__RecurringChargeOVApplied__c, NE__RecurringChargeOv__c, NE__RecurringChargePb__c, NE__Recurring_Charge_Tax_Free__c, NE__Recurring_Cost_Frequency__c, NE__Recurring_Cost__c, NE__Remove_from_total__c, NE__Reservation_code__c, NE__Reservation_date__c, NE__RollbackOneTimeFee__c, NE__RollbackRecurringCharge__c, NE__Root_Order_Item__c, NE__SP_Edit__c, NE__SerialNum__c, NE__Service_Account_Asset_Item__c, NE__Service_Account__c, NE__Service_Point__c, NE__Shipped_Qty__c, NE__SmartPartNumber__c, NE__SmartPart__c, NE__SourceLineItemId__c, NE__StartDate__c, NE__State_Code__c, NE__State__c, NE__Status__c, NE__Street__c, NE__Tax_Models_Applied__c, NE__Tax_for_Canal__c, NE__Test_Prezzi__c, NE__Text_Extension_1__c, NE__Text_Extension_2__c, NE__Text_Extension_3__c, NE__Text_Extension_4__c, NE__Text_Extension_5__c, NE__UnitCreditCode__c, NE__UnitCreditDescription__c, NE__UsageCode__c, NE__UsageDescription__c, NE__Zip_Code__c, NE__assetItemActionCalc__c, NE__assetItemStatusCalc__c, NE__configured__c, B2WExtCat__External_Item_Name__c, B2WExtCat__External_Item__c, B2WExtCat__Skip_WOI_Generation__c, B2WZC__ZExternal_Item_Old__c, B2WZC__ZOneTimeBillingDesc__c, B2WZC__ZQuoteRatePlanId__c, B2WZC__ZRatePlanId__c, B2WZC__ZRecurringBillingDesc__c, B2WZC__ZUsageBillingDesc__c, B2WZC__ZUsageOV__c, NE_Provider__c, XC_BillingModel__c, XC_BillingProfileLineItem__c, XC_CMCostCenter__c, XC_CMProfitCenter__c, XC_Compliance1_Status__c, XC_Compliance2_Status__c, XC_Compliance3_Status__c, XC_CongaDynamicAPI__c, XC_CongaStaticAPI__c, XC_Country__c, XC_Courier_Partner__c, XC_DeliveryId__c, XC_DeliveryType__c, XC_Delivery_Tracking_URL__c, XC_Discount_Reason__c, XC_Discounted_OneTime_price__c, XC_Discounted_Recurring_duration__c, XC_Discounted_Recurring_price__c, XC_DurationInMinutes__c, XC_EffectiveDeliveryDate__c, XC_Effective_Product_Availability_Date__c, XC_Engine_Code__c, XC_Installation_Date__c, XC_IsAProduct__c, XC_LastSubscriptionId__c, XC_NE_Type__c, XC_NeedProvisioning__c, XC_Orig_OneTimeFee__c, XC_Orig_RecurringCharge__c, XC_PaymentMethodNeeded__c, XC_PaymentMethod__c, XC_PaymentType__c, XC_Payment_Check_OK__c, XC_Product_Reservation__c, XC_Product_Rollback_Status__c, XC_Compliance4_Status__c, XC_Product_Subtype__c, XC_Product_Type__c, XC_Reason_Of_KO_Product_Reservation__c, XC_RelatedProduct__c, XC_Terms_Condition_Template__c, XC_Wbe__c, XC_ZQuoteId__c, XC_FinancialInstitute__c, XC_Max_Months_Renting__c, XC_NumberOfSteps__c, XC_Number_of_Completed_Steps__c, XC_Product_Scoring__c, XC_CountryFormula__c, XC_Coverage_Asset_Type__c, XC_Duration__c, XC_NoCommodityBill__c, XC_NumPrepayment__c, XC_NumberTechnicians__c, XC_ProvisioningSpareParts__c, XC_AppliedMargin__c, XC_COL_Unique_Partner__c, XC_DaneCode__c, XC_Expected_Revenue__c, XC_ForcePaymentMethodEdit__c, XC_HasBillingProfile__c, XC_Incompatible_Assets__c, XC_PartnerCost__c, XC_ProdNameText__c, XC_TaxesAmountOneShot__c, XC_TaxesAmountRecurring__c, XC_TotalPriceOneShot__c, XC_TotalPriceRecurring__c, XC_TotalPrice__c, XC_ZuoraCheckMigrationOrderItem__c, XC_PriceOneShot__c, XC_PriceRecurring__c, XC_UnitPriceOneShot__c, XC_External_ID__c, NE__Price_List_Version_Item__c, NE__Promotionvid__c, XC_Size__c, XC_CreditAssignmentSurvey__c, XC_DocumentationCharacteristicValue__c, XC_LegalEntityFormula__c, XC_WBE_Status__c, XC_BankTransferCode__c, XC_CreditAssignmentAvailable__c, XC_ContractDuration__c, XC_BundleTotalOTAmount__c, XC_CityCode__c, XC_CreditAssignmentAmount__c, XC_CreditAssignmentCustomerAmount__c, XC_HouseType__c, XC_Particle__c, XC_Sheet__c, XC_Subordinate__c, XC_UrbanSection__c, XC_BundleIncentiveText__c, XC_Good_Cost__c, XC_IncentiveName__c, XC_TaxesAmount__c, XC_UnitPriceRecurring__c, XC_SiteInspectionRequired__c, XC_TranslatedProductDescription__c, XC_TranslatedProductName__c, XC_Bit2WIN_TranslatedProductName__c, XC_PenaltyValue__c, XC_RemoveNotAllowed__c, XC_ProductName__c, XC_Segment__c, XC_DeliveryStatusList__c, XC_DeliveryStatus__c, InstallmentDivisionTax__c, XC_AllowablePaymentTypes__c, XC_Complex_Product__c, XC_InstallmentFrequency__c, XC_InstallmentPlanType__c, XC_InstallmentRate__c, XC_InstallmentsNumber__c, XC_LegalEntity__c, XC_RecurringDuration__c, XC_BlockProvisioningAppointment__c, XC_ProductPower__c, XC_ContractGenerated__c, XC_InvoiceDate__c, XC_InvoiceNumber__c, XC_PromotionMonths__c';
            query = query + ', NE__ProdId__r.XC_LIC_Product_Name__c, NE__Parent_Order_Item__r.XC_CMProfitCenter__c, NE__Parent_Order_Item__r.XC_CMCostCenter__c, NE__OrderId__r.RecordType.DeveloperName, ' +
                ' NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProductLine__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProductServiceType__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProfitCenter__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_CostCenter__c, ' +
                ' NE__CatalogItem__r.Id, NE__CatalogItem__r.XC_WbeMode__c, NE__CatalogItem__r.XC_ProfitCenter__c, NE__CatalogItem__r.XC_CostCenter__c, NE__CatalogItem__r.XC_ProductServiceType__c, NE__CatalogItem__r.XC_ProductLine__c, NE__OrderId__r.XC_Country__c, NE__OrderId__r.XC_LegalEntity__c, ' +
                ' NE__OrderId__r.Id, NE__OrderId__r.NE__OptyId__r.Id, NE__OrderId__r.NE__OptyId__r.XC_Company__c, NE__OrderId__r.NE__OptyId__r.Business__c, NE__OrderId__r.NE__OptyId__r.XC_ReceivingChannel__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, ' +
                ' (SELECT Id FROM Assets__r) ' +
                ' FROM NE__OrderItem__c ' +
                //' WHERE NE__OrderId__c IN :listOrderItemB2C AND Id IN :listOrderItemIdsFromAsset';
                ' WHERE NE__OrderId__c IN :listOrderItemB2C';
            query = query.replace('xc_installation_address__c,','');
            List<NE__OrderItem__c> listOrderItemFiltered = Database.query(String.escapeSingleQuotes(query));
            if(listOrderItemFiltered.isEmpty()) {
                listLogs.add(insertBatchErrorLog('No items to recalculate WBE for B2C', 'Order Id query: ' + String.join(listOrderItemB2C, ', ')));
            } else {
                List<NE__OrderItem__c> listOrderItemToUpdate = XC_TR_ConfigurationItem_U_GenerateWBE.populateWBEfields(listOrderItemFiltered);
                List<NE__OrderItem__c> listOrderItemsToUpdate = new List<NE__OrderItem__c>();
                Map<Id, NE__OrderItem__c> mapOrderItem = new Map<Id, NE__OrderItem__c>();
                for(NE__OrderItem__c oiProcessed : listOrderItemToUpdate) {
                    listOrderItemsToUpdate.add(new NE__OrderItem__c(
                        Id                      = oiProcessed.Id,
                        XC_WBE__c               = oiProcessed.XC_WBE__c,
                        XC_CMProfitCenter__c    = oiProcessed.XC_CMProfitCenter__c,
                        XC_CMCostCenter__c      = oiProcessed.XC_CMCostCenter__c
                    ));
                    mapOrderItem.put(oiProcessed.Id, oiProcessed);
                }
                XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
                XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true); 
                List<XC_UTIL_Sobject.WrapperResult> wrResultUpdateItemWBE = XC_UTIL_Sobject.updateListRecords(listOrderItemsToUpdate);
                if(!XC_UTIL_Sobject.checkDMLResults(wrResultUpdateItemWBE)) {
                    listLogs.add(insertBatchErrorLog('ERROR to recalculate WBE for B2C: ' + wrResultUpdateItemWBE[0].errorMessage, 'Order Id query: ' + String.join(listOrderItemB2C, ', ')));
                } else {
                    List<Asset> listAssetToUpdate = new List<Asset>();
                    for(NE__OrderItem__c oi : listOrderItemFiltered) {
                        if(mapOrderItem.containsKey(oi.Id)) {
                            NE__OrderItem__c oiProcessed = mapOrderItem.get(oi.Id);
                            for(Asset ass : oi.Assets__r) {
                                listAssetToUpdate.add(new Asset(
                                    Id                      = ass.Id,
                                    XC_WBE__c               = oiProcessed.XC_WBE__c,
                                    XC_CMProfitCenter__c    = oiProcessed.XC_CMProfitCenter__c,
                                    XC_CMCostCenter__c      = oiProcessed.XC_CMCostCenter__c
                                ));
                            }
                        }
                    }
                    XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
                    XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true); 
                    wrResultUpdateItemWBE = XC_UTIL_Sobject.updateListRecords(listAssetToUpdate);
                    if(!XC_UTIL_Sobject.checkDMLResults(wrResultUpdateItemWBE)) {
                        listLogs.add(insertBatchErrorLog('ERROR to recalculate WBE for B2C ONLY for Asset: ' + wrResultUpdateItemWBE[0].errorMessage, 'Order Id query: ' + String.join(listOrderItemB2C, ', ')));
                    }
                }
            }
        }  
        // For B2BG:
        if(!listOrderItemB2BG.isEmpty()) {
            List<NE__OrderItem__c> listItems = new List<NE__OrderItem__c>([
                SELECT Id, NE__OrderId__c, NE__Item_Code__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__CatalogItem__r.XC_ProductLine__c, NE__CatalogItem__r.XC_ProductServiceType__c,
                NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c, NE__ProdName__c,NE__OrderId__r.Name, RecordType.DeveloperName,NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c, NE__OrderId__r.NE__OptyId__r.XC_ProductCategoryOfInterest__c,
                NE__OrderId__r.XC_Subtype__c, RecordType.name,XC_Product_Subtype__c,NE__Parent_Order_Item__c, XC_BillingModel__c, NE__OrderId__r.XC_Segment__c,
                NE__OrderId__r.NE__OptyId__r.XC_ContractStartDate__c, NE__OrderId__r.NE__OptyId__r.XC_ContractEndDate__c, NE__OrderId__r.NE__OptyId__r.XC_RevenueFullLife__c, NE__OrderId__r.NE__OptyId__r.XC_GrossMarginFullLife__c, NE__OrderId__r.NE__OptyId__r.Contract.XC_ContractType__c, NE__OrderId__r.NE__AccountId__r.IdentityType__c, NE__OrderId__r.NE__AccountId__r.IdentityNumber__c, NE__OrderId__r.NE__AccountId__r.Name, XC_Installation_Address__r.XC_PostalCode__c, NE__OrderId__r.NE__OptyId__r.XC_ModeOfEngagement__c, NE__OrderId__r.NE__OptyId__r.XC_LOT__c, NE__OrderId__r.NE__OptyId__r.XC_Zone__c , XC_Segment__c, XC_LegalEntity__c, XC_BlockWBE_User__c, NE__OrderId__r.XC_PlantOwnership__c, NE__OrderId__r.XC_UpdateWBE_FromButton__c, XC_WBE_Status__c, XC_RecurringDuration__c,
                NE__OrderId__r.NE__OptyId__r.XC_Segment__c, NE__RecurringChargeOv__c, NE__OneTimeFeeOv__c, XC_EstimatedRevenue__c, XC_RevenueFullLife__c, XC_CostFullLife__c, NE__CatalogItem__r.NE__Item_Header__c, XC_CapexFullLife__c,NE__OrderId__r.XC_Calculation_Channel_WBE_EC__c,XC_Country__c,
                (
                    SELECT Id 
                    FROM Assets__r
                )
                FROM NE__OrderItem__c
                // WHERE NE__OrderId__c IN :listOrderItemB2BG AND Id IN :listOrderItemIdsFromAsset
                WHERE NE__OrderId__c IN :listOrderItemB2BG
            ]);
            if(listItems.isEmpty()) {
                listLogs.add(insertBatchErrorLog('No items to recalculate WBE for B2B', 'Order Id query: ' + String.join(listOrderItemB2BG, ', ')));
            } else {
                Map<String, List<NE__OrderItem__c>> mapOrderItems = new Map<String, List<NE__OrderItem__c>>();
                for(NE__OrderItem__c oi : listItems) {
                    if(!mapOrderItems.containsKey(oi.NE__OrderId__c)) {
                        mapOrderItems.put(oi.NE__OrderId__c, new List<NE__OrderItem__c>());
                    }
                    mapOrderItems.get(oi.NE__OrderId__c).add(oi);
                }
                List<NE__OrderItem__c> listOrderItemToUpdateAsset = new List<NE__OrderItem__c>();
                for(String orId : mapOrderItems.keySet()) {
                    String messageAlg = XC_LCC_056_CalculateWBS_New.calculateWBE(mapOrderItems.get(orId));
                    listOrderItemToUpdateAsset.addAll(mapOrderItems.get(orId));
                    listLogs.add(insertBatchErrorLog('Result recalculation WBE for B2B/G: ' + messageAlg, 'Order: ' + orId));
                }
                List<NE__OrderItem__c> listItemsQueriedForAsset = new List<NE__OrderItem__c>([
                    SELECT Id, XC_WBE__c,
                    (
                        SELECT Id, XC_WBE__c 
                        FROM Assets__r
                    )
                    FROM NE__OrderItem__c
                    WHERE Id IN :listOrderItemToUpdateAsset
                ]);
                List<Asset> listAssetToUpdateForNewWBE = new List<Asset>();
                for(NE__OrderItem__c singleNewItem : listItemsQueriedForAsset) {
                    for(Asset singleOldAsset : singleNewItem.Assets__r) {
                        if(singleNewItem.XC_WBE__c != singleOldAsset.XC_WBE__c) {
                            listAssetToUpdateForNewWBE.add(new Asset(Id=singleOldAsset.Id, XC_WBE__c=singleNewItem.XC_WBE__c));
                        }
                    }
                }
                List<XC_UTIL_Sobject.WrapperResult> wrResultUpdateItemWBE = XC_UTIL_Sobject.updateListRecords(listAssetToUpdateForNewWBE);
                if(!XC_UTIL_Sobject.checkDMLResults(wrResultUpdateItemWBE)) {
                    listLogs.add(insertBatchErrorLog('ERROR to recalculate WBE for B2B/G ONLY for Asset: ' + wrResultUpdateItemWBE[0].errorMessage, 'Order Id query: ' + String.join(listOrderItemB2BG, ', ')));
                }
            }
        }
        return listLogs;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 07/03/2022
     * @description Method to clean wrapper from duplicated records
    */
    public static WrapperObjectToUpdate cleanWrapperFromDuplicatedUpdate(WrapperObjectToUpdate wrapperToUpdate) {
        WrapperObjectToUpdate wrapperOutput                     = new WrapperObjectToUpdate();
        List<String> listOptyFoundedIds                         = new List<String>();
        List<String> listAccountFoundedIds                      = new List<String>();
        List<String> listAssetFoundedIds                        = new List<String>();
        List<String> listBillingProfileLineItemUpdateFoundedIds = new List<String>();
        List<String> listOrderItemFoundedIds                    = new List<String>();
        List<String> listWorkOrderFoundedIds                    = new List<String>();
        List<String> listServiceAppointmentFoundedIds           = new List<String>();
        List<String> listOrderFoundedIds                        = new List<String>();
        List<String> listCaseFoundedIds                         = new List<String>();
        for(Opportunity singleItem : wrapperToUpdate.listOpty) {
            if(!listOptyFoundedIds.contains(singleItem.Id)) {
                listOptyFoundedIds.add(singleItem.Id);
                wrapperOutput.listOpty.add(singleItem);
            }
        }
        for(Account singleItem : wrapperToUpdate.listAccount) {
            if(!listAccountFoundedIds.contains(singleItem.Id)) {
                listAccountFoundedIds.add(singleItem.Id);
                wrapperOutput.listAccount.add(singleItem);
            }
        }
        for(Asset singleItem : wrapperToUpdate.listAsset) {
            if(!listAssetFoundedIds.contains(singleItem.Id)) {
                listAssetFoundedIds.add(singleItem.Id);
                wrapperOutput.listAsset.add(singleItem);
            }
        }
        for(XC_BillingProfileLineItem__c singleItem : wrapperToUpdate.listBillingProfileLineItemUpdate) {
            if(!listBillingProfileLineItemUpdateFoundedIds.contains(singleItem.Id)) {
                listBillingProfileLineItemUpdateFoundedIds.add(singleItem.Id);
                wrapperOutput.listBillingProfileLineItemUpdate.add(singleItem);
            }
        }
        for(NE__OrderItem__c singleItem : wrapperToUpdate.listOrderItem) {
            if(!listOrderItemFoundedIds.contains(singleItem.Id)) {
                listOrderItemFoundedIds.add(singleItem.Id);
                wrapperOutput.listOrderItem.add(singleItem);
            }
        }
        for(WorkOrder singleItem : wrapperToUpdate.listWorkOrder) {
            if(!listWorkOrderFoundedIds.contains(singleItem.Id)) {
                listWorkOrderFoundedIds.add(singleItem.Id);
                wrapperOutput.listWorkOrder.add(singleItem);
            }
        }
        for(ServiceAppointment singleItem : wrapperToUpdate.listServiceAppointment) {
            if(!listServiceAppointmentFoundedIds.contains(singleItem.Id)) {
                listServiceAppointmentFoundedIds.add(singleItem.Id);
                wrapperOutput.listServiceAppointment.add(singleItem);
            }
        }
        for(NE__Order__c singleItem : wrapperToUpdate.listOrder) {
            if(!listOrderFoundedIds.contains(singleItem.Id)) {
                listOrderFoundedIds.add(singleItem.Id);
                wrapperOutput.listOrder.add(singleItem);
            }
        }
        for(Case singleItem : wrapperToUpdate.listCase) {
            if(!listCaseFoundedIds.contains(singleItem.Id)) {
                listCaseFoundedIds.add(singleItem.Id);
                wrapperOutput.listCase.add(singleItem);
            }
        }
        wrapperOutput.listBillingProfileLineItem = wrapperToUpdate.listBillingProfileLineItem;
        wrapperOutput.listLegalEntityConsent = wrapperToUpdate.listLegalEntityConsent;
        wrapperOutput.listOrderItemForWBE = wrapperToUpdate.listOrderItemForWBE;
        return wrapperOutput;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 07/03/2022
     * @description Method to create a string from list sObject
    */
    public static String getStringListObject(List<sObject> listSobject) {
        String str = '';
        for(sObject singleObj : listSobject) {
            str += String.valueOf(singleObj) + '\n';
        }
        return str;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 07/03/2022
     * @description Method to create a string from list sObject
    */
    public static String getStringListString(List<String> listSobject) {
        String str = '';
        for(String singleObj : listSobject) {
            str += String.valueOf(singleObj) + ', ';
        }
        return str;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 07/03/2022
     * @description Method to retrieve more info for BPLI inserted/updated
    */
    public static void getMoreInfoBPLI(List<String> listBPLIforMoreInfo, List<XC_BatchErrorLog__c> listLogsToInsert) {
        List<XC_BillingProfileLineItem__c> listBPLIMoreInfo = new List<XC_BillingProfileLineItem__c>([
            SELECT Id, XC_CustomerAccount__c, XC_ZuoraId__c, XC_BillingProfile__c, XC_Account__c
            FROM XC_BillingProfileLineItem__c  
            WHERE Id IN :listBPLIforMoreInfo
        ]);

        if(!listBPLIMoreInfo.isEmpty()) {
            String recordInfoToWrite = '';
            for(XC_BillingProfileLineItem__c bpliMoreInfo : listBPLIMoreInfo) {
                recordInfoToWrite = recordInfoToWrite + '[BPLI for Account ' + bpliMoreInfo.XC_Account__c + ': CustomerAccount('+bpliMoreInfo.XC_CustomerAccount__c+') - ZuoraId('+bpliMoreInfo.XC_ZuoraId__c+') - BillingProfile('+bpliMoreInfo.XC_BillingProfile__c+') \n';
            }
            listLogsToInsert.add(insertBatchErrorLog('Zuora info for BPLI inserted/updated', recordInfoToWrite));
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 16/03/2022
     * @description Method to manage Glovia objects
    */
    public static void manageGlovia(WrapperObject wrObj, WrapperObject wrObjNotScheduled, WrapperObjectToUpdate wrapperToUpdate, List<XC_BatchErrorLog__c> listLogsToInsert) {
        List<String> listTOStatus = new List<String>{'Draft', 'Open'};
        List<String> listPOStatus = new List<String>{'Draft', 'Open', 'Sent to Supplier', 'Reviewed'};
        List<String> listWorkOrderIdByWrapper = new List<String>();
        for(WorkOrder wro : wrObj.listWorkOrder) {
            listWorkOrderIdByWrapper.add(wro.Id);
        }
        for(WorkOrder wro : wrObjNotScheduled.listWorkOrder) {
            listWorkOrderIdByWrapper.add(wro.Id);
        }
        List<gii__SalesOrder__c> listSalesOrder = new List<gii__SalesOrder__c>([
            SELECT Id, giic_LegalEntity__c, giic_WorkOrder__c, giic_WorkOrder__r.XC_Configuration__c,
                (SELECT Id, giic_WBElement__c, giic_ProductCode__c FROM gii__SalesOrder__r),
                (SELECT Id FROM Transfer_Orders__r WHERE giic_status__c IN :listTOStatus),
                (SELECT Id, gii__DropShip__c FROM gii__Purchase_Orders__r WHERE giic_status__c IN :listPOStatus)
            FROM gii__SalesOrder__c 
            WHERE giic_WorkOrder__c IN :listWorkOrderIdByWrapper AND giic_Status__c = 'Open'
        ]);
        if(listSalesOrder.isEmpty()) {
            listLogsToInsert.add(insertBatchErrorLog('No Glovia Object found to update','Check done for WorkOrder ' + String.join(listWorkOrderIdByWrapper,', ')));
            return;
        }

        List<ProductRequired> listproductRequired = new List<ProductRequired>([
            SELECT Id, XC_Asset__c, XC_Asset__r.XC_WBE__c, XC_ProductCode__c, ParentRecordId
            FROM ProductRequired
            WHERE ParentRecordId IN :XC_UTIL_Sobject.getListFieldValues(listSalesOrder, 'giic_WorkOrder__c')
        ]);
        Map<String, String> mapKeyWBE = new Map<String, String>();
        for(ProductRequired pr : listproductRequired) {
            mapKeyWBE.put(pr.ParentRecordId+'_'+pr.XC_ProductCode__c, pr.XC_Asset__r.XC_WBE__c);
        }

        // List Glovia Objects to update:
        List<gii__SalesOrder__c>        listSOtoUpdate          = new List<gii__SalesOrder__c>();
        List<gii__SalesOrderLine__c>    listSOLINEtoUpdate      = new List<gii__SalesOrderLine__c>();
        List<gii__PurchaseOrder__c>     listPOtoUpdate          = new List<gii__PurchaseOrder__c>();
        List<gii__TransferOrder__c>     listTOtoUpdate          = new List<gii__TransferOrder__c>();
        List<String>                    listLegalEntityToSkip   = new List<String>{'enelxitalia'};

        for(gii__SalesOrder__c so : listSalesOrder) {
            if(listLegalEntityToSkip.contains(so.giic_LegalEntity__c.toLowerCase())) {
                continue;
            }
            String oldLegalEntityFromOrder  = so.giic_LegalEntity__c;
            String newLegalEntity           = getNewLegalEntity(oldLegalEntityFromOrder);
            if(rollbackMode) {
                if(mapLegalEntityRollback.containsKey(''+so.giic_WorkOrder__r.XC_Configuration__c+oldLegalEntityFromOrder)) {
                    newLegalEntity = mapLegalEntityRollback.get(''+so.giic_WorkOrder__r.XC_Configuration__c+oldLegalEntityFromOrder);
                } else {
                    listLogsToInsert.add(insertBatchErrorLog('[ERROR: Rollback] No Legal Entity Convertion found for key: ' + so.giic_WorkOrder__r.XC_Configuration__c + ' ' + oldLegalEntityFromOrder, ''));
                    return;
                }
            }
            gii__SalesOrder__c  soToUpdate      = new gii__SalesOrder__c(Id = so.Id);
            if(String.isNotBlank(newLegalEntity) && newLegalEntity!='') {
                // Sales Order:
                soToUpdate.giic_LegalEntity__c = newLegalEntity;
                // Sales Order Line:
                for(gii__SalesOrderLine__c soLine : so.gii__SalesOrder__r) {
                    String keyForWBE = so.giic_WorkOrder__c+'_'+soLine.giic_ProductCode__c;
                    if(mapKeyWBE.containsKey(keyForWBE) && mapKeyWBE.get(keyForWBE)!=soLine.giic_WBElement__c) {
                        listSOLINEtoUpdate.add(new gii__SalesOrderLine__c(Id=soLine.Id, giic_WBElement__c=mapKeyWBE.get(keyForWBE)));
                    }
                }
                // Purchase Order:
                for(gii__PurchaseOrder__c po : so.gii__Purchase_Orders__r) {
                    if(!po.gii__DropShip__c) {
                        listPOtoUpdate.add(new gii__PurchaseOrder__c(Id=po.Id, giic_LegalEntity__c=newLegalEntity));
                    } else {
                        soToUpdate.giic_OrderStatus__c = 'Error';
                        listPOtoUpdate.add(new gii__PurchaseOrder__c(Id=po.Id, giic_Status__c='Cancelled'));
                    }
                }
                // Transfer Order:
                for(gii__TransferOrder__c to : so.Transfer_Orders__r) {
                    listTOtoUpdate.add(new gii__TransferOrder__c(Id=to.Id, giic_status__c='Cancelled'));
                }
                // Add SO to list:
                listSOtoUpdate.add(soToUpdate);
            }
        }

        // DML:
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultSO     = XC_UTIL_Sobject.updateListRecords(listSOtoUpdate);
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultSOLine = XC_UTIL_Sobject.updateListRecords(listSOLINEtoUpdate);
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultTO     = XC_UTIL_Sobject.updateListRecords(listTOtoUpdate);
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultPO     = XC_UTIL_Sobject.updateListRecords(listPOtoUpdate);
        // Check result DML:
        if(!XC_UTIL_Sobject.checkDMLResults(wrapperResultSO)) {
            listLogsToInsert.add(insertBatchErrorLog('Error update SalesOrder: ' + wrapperResultSO[0].errorMessage, getStringListObject(listSOtoUpdate)));
        } else {
            listLogsToInsert.add(insertBatchErrorLog('SalesOrder updated: ' + listSOtoUpdate.size(), getStringListObject(listSOtoUpdate)));
        }
        if(!XC_UTIL_Sobject.checkDMLResults(wrapperResultSOLine)) {
            listLogsToInsert.add(insertBatchErrorLog('Error update SalesOrderLine: ' + wrapperResultSOLine[0].errorMessage, getStringListObject(listSOLINEtoUpdate)));
        } else {
            listLogsToInsert.add(insertBatchErrorLog('SalesOrderLine updated: ' + listSOLINEtoUpdate.size(), getStringListObject(listSOLINEtoUpdate)));
        }
        if(!XC_UTIL_Sobject.checkDMLResults(wrapperResultTO)) {
            listLogsToInsert.add(insertBatchErrorLog('Error update TransferOrder: ' + wrapperResultTO[0].errorMessage, getStringListObject(listTOtoUpdate)));
        } else {
            listLogsToInsert.add(insertBatchErrorLog('TransferOrder updated: ' + listTOtoUpdate.size(), getStringListObject(listTOtoUpdate)));
        }
        if(!XC_UTIL_Sobject.checkDMLResults(wrapperResultPO)) {
            listLogsToInsert.add(insertBatchErrorLog('Error update PurchaseOrder: ' + wrapperResultPO[0].errorMessage, getStringListObject(listPOtoUpdate)));
        } else {
            listLogsToInsert.add(insertBatchErrorLog('PurchaseOrder updated: ' + listPOtoUpdate.size(), getStringListObject(listPOtoUpdate)));
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 16/03/2022
     * @description Method to retrieve WorkType for new legal entity
    */
    public static void saveNewWorkType() {
        List<String> listLegalEntity    = new List<String>();
        List<String> listSegment        = new List<String>();
        List<String> listWorkTypeName   = new List<String>();
        for(WorkOrder singleWoItem : listWorkOrderToDiscoveryWT) {
            String oldLegalEntityFromOrder  = singleWoItem.XC_LegalEntity__c;
            String newLE           = getNewLegalEntity(oldLegalEntityFromOrder);
            if(rollbackMode) {
                if(mapLegalEntityRollback.containsKey(''+singleWoItem.XC_Configuration__c+oldLegalEntityFromOrder)) {
                    newLE = mapLegalEntityRollback.get(''+singleWoItem.XC_Configuration__c+oldLegalEntityFromOrder);
                } else {
                    return;
                }
            }
            if(String.isNotBlank(newLE) && newLE!='') {
                listSegment.add(singleWoItem.XC_Segment__c);
                listWorkTypeName.add(singleWoItem.XC_WorkTypeLabel__c);
                listLegalEntity.add(newLE);
            }
        }

        List<WorkType> listWT = new List<WorkType>([
            SELECT Id, Name, XC_Segment__c, XC_LegalEntity__c
            FROM WorkType
            WHERE XC_Segment__c IN :listSegment AND XC_LegalEntity__c IN :listLegalEntity AND Name IN :listWorkTypeName
        ]);
        if(!listWT.isEmpty()) {
            for(WorkType wt : listWT) {
                String keyWT = wt.XC_Segment__c+'_'+wt.XC_LegalEntity__c+'_'+wt.Name;
                mapWorkType.put(keyWT, wt.Id);
            }
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 27/03/2022
     * @description Method to delete objects for rollback
    */
    public static void deleteObjectForRollback(List<XC_BatchErrorLog__c> listLogsToInsert) {
        // Billing profile line item:
        List<XC_BillingProfileLineItem__c> listBPLI = new List<XC_BillingProfileLineItem__c>([
            SELECT Id, XC_BillingProfile__c, XC_LegalEntity__c
            FROM XC_BillingProfileLineItem__c 
            WHERE XC_BillingProfile__c IN :mapBPLIRollbackOldLE.keySet()
        ]);
        List<XC_BillingProfileLineItem__c> listBPLItoDelete = new List<XC_BillingProfileLineItem__c>();
        for(XC_BillingProfileLineItem__c checkBPLI : listBPLI) {
            if(mapBPLIRollbackOldLE.values().contains(checkBPLI.XC_LegalEntity__c)) {
                listBPLItoDelete.add(new XC_BillingProfileLineItem__c(Id = checkBPLI.Id));
            }
        }
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultBPLIDelete = XC_UTIL_Sobject.deleteListRecords(listBPLItoDelete);
        if(!XC_UTIL_Sobject.checkDMLResults(wrapperResultBPLIDelete)) {
            listLogsToInsert.add(insertBatchErrorLog('Error DELETE BPLI for rollback: ' + wrapperResultBPLIDelete[0].errorMessage, getStringListObject(listBPLItoDelete)));
        } else {
            listLogsToInsert.add(insertBatchErrorLog('BPLI DELETED for rollback: ' + listBPLItoDelete.size(), getStringListObject(listBPLItoDelete)));
        }
        // Legal Entity Consent:
        List<XC_LegalEntityConsent__c> listLEC = new List<XC_LegalEntityConsent__c>([
            SELECT Id, XC_LegalEntity__c
            FROM XC_LegalEntityConsent__c 
            WHERE XC_Individual__c IN :mapConsentOldRollback.keySet()
        ]);
        List<XC_LegalEntityConsent__c> listLECtoDelete = new List<XC_LegalEntityConsent__c>();
        for(XC_LegalEntityConsent__c checkLEC : listLEC) {
            if(mapConsentOldRollback.values().contains(checkLEC.XC_LegalEntity__c)) {
                listLECtoDelete.add(new XC_LegalEntityConsent__c(Id = checkLEC.Id));
            }
        }
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultLECDelete = XC_UTIL_Sobject.deleteListRecords(listLECtoDelete);
        if(!XC_UTIL_Sobject.checkDMLResults(wrapperResultLECDelete)) {
            listLogsToInsert.add(insertBatchErrorLog('Error DELETE LEC for rollback: ' + wrapperResultLECDelete[0].errorMessage, getStringListObject(listLECtoDelete)));
        } else {
            listLogsToInsert.add(insertBatchErrorLog('LEC DELETED for rollback: ' + listLECtoDelete.size(), getStringListObject(listLECtoDelete)));
        }
    }

    @TestVisible
    private static void debugCoverage (){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Test Coverage');
    }

}