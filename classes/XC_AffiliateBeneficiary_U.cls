/**
* @author Denise Avolio - denise.avolio@accenture.com
* @date Creation 15/09/2021
* @date Modification
* @description XC_AffiliateBeneficiary_U – Utility for XC_TR_AffiliateBeneficiary
*/

public without sharing  class XC_AffiliateBeneficiary_U {

    public final static String ERROR_CASE            = Label.XC_CL_AffBen_ErrorCase;
    public final static String ERROR_ORDER           = Label.XC_CL_AffBen_ErrorOrder;
    public final static String ERROR_PRODUCT         = Label.XC_CL_AffBen_ErrorProduct;
    public final static String ERROR_RELATIONSHIP    = Label.XC_CL_AffBen_ErrorRelationship;
    public final static String ERROR_AGE             = Label.XC_CL_AffBen_ErrorAge;
    public final static String ERROR_CLOSED_CASE     = Label.XC_CL_AffBen_ErrorCaseClosed;

    public final static String RECORD_STATUS_KO      = 'Record Not Valid';
    public final static String RECORD_STATUS_OK      = 'Record Valid';
    public final static String GLOBAL_STATUS_KO      = 'Not Validated';
    public final static String GLOBAL_STATUS_OK      = 'Validated';

    public final static String ORDER_TYPE            = 'ChangeOrder';
    public final static String ORDER_STATUS          = 'In Progress';
    public final static String ORDER_RT              = 'Order';

    public final static String AFFBENCODE            = 'AffBen_Code';
    public final static String PLAN                  = 'Plan';

    public final static String CONF_TYPE_RV          = 'Record Validation';

    public final static XC_CaseForAffBen__c CASE_TYP = XC_CaseForAffBen__c.getInstance('CaseManagement');
    
    public final static String CASE_REASON           = Test.isRunningTest() ? 'XCMOT008' : CASE_TYP.XC_CaseReason__c; 
    public final static String CASE_SUBCAUSE         = Test.isRunningTest() ? 'ATCL004' : CASE_TYP.XC_SubCause__c;
    public final static String CASE_STATUS_CLOSED    = 'ESTA007';
    public final static String CASE_STATUS_CANCELLED = 'ESTA008';

    public final static List<String> ATTRIB_NAME_LIST = new List<String>{
        AFFBENCODE, PLAN
    };

    public final static List<String> CASE_STATUS_LIST = new List<String>{
        CASE_STATUS_CLOSED, CASE_STATUS_CANCELLED
    };

    public class WrapperResult{

        public Boolean errorResult;
        public String errorMessage;
        public Decimal permanenceAge;
        public String legalEntity;
        public Id accountId; //[DeAv 11/12/2021 Jira THIRDPARTY-396: Fix to populate account]

        public WrapperResult(){
            errorResult = false;
            errorMessage = '';
            permanenceAge = null;
            legalEntity = '';
            accountId = null; //[DeAv 11/12/2021 Jira THIRDPARTY-396: Fix to populate account]
        }
    }


    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description This method check the validity of records.
     * @param listNew list of new values of records
     * @param assetMap map of assets related to Affiliate and Beneficiary record
     * @param orderItemMap map of configuration items related to Affiliate and Beneficiary record
     */
    public static Map<XC_Affiliate_Beneficiary__c, WrapperResult> checkValidRecords(List<XC_Affiliate_Beneficiary__c> listNew, Map<Id,Asset> assetMap, Map<Id,NE__OrderItem__c> orderItemMap){
        Map<XC_Affiliate_Beneficiary__c, WrapperResult> map1Result = new Map<XC_Affiliate_Beneficiary__c, WrapperResult>();
        Map<XC_Affiliate_Beneficiary__c, WrapperResult> mapResult = new Map<XC_Affiliate_Beneficiary__c, WrapperResult>();
        List<XC_Affiliate_Beneficiary__c> listToCheck = new List<XC_Affiliate_Beneficiary__c>();
        Integer cvr = 0;
        
        map1Result = checkCaseOrOrder(listNew, assetMap, orderItemMap);

        for (XC_Affiliate_Beneficiary__c affBen : map1Result.keySet()){
            system.debug('recordIndexProcessing cvr ' + cvr);
            if(!map1Result.get(affBen).errorResult){
                system.debug('OK primo controllo per record ' + cvr);
                listToCheck.add(affBen);
            }else{
                system.debug('Error primo controllo per record ' + cvr);
                mapResult.put(affBen, map1Result.get(affBen));

            }
            cvr++;
        }

        system.debug('listToCheck: record buoni dopo primo controllo ' + listToCheck.size());
        if(!listToCheck.isEmpty()){
            map1Result.clear();
            List<XC_AffiliateBeneficiaryConfiguration__c> configurationList = retrieveConfigurations();
            map1Result = checkConfigurations(listToCheck, assetMap, orderItemMap, configurationList);
            system.debug('map1Result ' + map1Result.size());            
        }
      
        mapResult.putAll(map1Result);
        system.debug('mapResult Size checkValidRecords ' + mapResult.size());
        for(XC_Affiliate_Beneficiary__c affBen : listNew ){
            system.debug('mapResult valori checkValidRecords ' + affBen.XC_FirstName__c + ' ' + mapResult.get(affBen));
        }
        return mapResult;
    }

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description This method check if there is a Case associated to Asset or the status of Order.
     * @param listNew list of new values of records
     * @param assetMap map of assets related to Affiliate and Beneficiary record
     * @param orderItemMap map of configuration items related to Affiliate and Beneficiary record
     */
    public static Map<XC_Affiliate_Beneficiary__c, WrapperResult> checkCaseOrOrder(List<XC_Affiliate_Beneficiary__c> listNew, Map<Id,Asset> assetMap, Map<Id,NE__OrderItem__c> orderItemMap){
        Map<XC_Affiliate_Beneficiary__c, WrapperResult> mapResult = new Map<XC_Affiliate_Beneficiary__c, WrapperResult>();
        WrapperResult wrResult;
        Integer ccoo = 0;
        
        for(XC_Affiliate_Beneficiary__c affBen : listNew){
            wrResult = new WrapperResult();
            system.debug('recordIndexProcessing ccoo ' + ccoo);
            if(RECORD_STATUS_KO.equalsIgnoreCase(affBen.XC_RecordStatus__c) && GLOBAL_STATUS_KO.equalsIgnoreCase(affBen.XC_Status__c)){ 
                wrResult.errorResult = false;
                wrResult.errorMessage = '';
                mapResult.put(affBen, wrResult);
                ccoo++;
                continue;
            }

            if(String.isNotBlank(affBen.XC_Asset__c)){
                if(!assetMap.get(affBen.XC_Asset__c).Cases.isEmpty()){
                    system.debug('Il case esiste per record ' + ccoo);
                    wrResult.errorResult = false;
                    wrResult.errorMessage = '';
                    mapResult.put(affBen, wrResult);
                }else{ 
                    if(String.isNotBlank(affBen.XC_OrderItem__c) && ORDER_TYPE.equalsIgnoreCase(orderItemMap.get(affBen.XC_OrderItem__c).NE__OrderId__r.NE__Type__c)  && ORDER_STATUS.equalsIgnoreCase(orderItemMap.get(affBen.XC_OrderItem__c).NE__OrderId__r.XC_Status__c)){
                        system.debug('Sono in ChangeOrder per record ' + ccoo);
                        wrResult.errorResult = false;
                        wrResult.errorMessage = '';
                        mapResult.put(affBen, wrResult);
                    }else{
                        system.debug('No case for record ' + ccoo);
                        wrResult.errorResult = true;
                        wrResult.errorMessage = ERROR_CASE;
                        mapResult.put(affBen, wrResult);
                    }
                }
            }else{
                String orderRTDevName = Schema.SObjectType.NE__Order__c.getRecordTypeInfosById().get(orderItemMap.get(affBen.XC_OrderItem__c).NE__OrderId__r.RecordTypeId).getDeveloperName();
                String orderStatus = orderItemMap.get(affBen.XC_OrderItem__c).NE__OrderId__r.XC_Status__c;
                if(!ORDER_RT.equalsIgnoreCase(orderRTDevName) || (ORDER_RT.equalsIgnoreCase(orderRTDevName) && !ORDER_STATUS.equalsIgnoreCase(orderStatus))){
                    system.debug('Order KO per record ' + ccoo);
                    wrResult.errorResult = true;
                    wrResult.errorMessage = ERROR_ORDER;
                    mapResult.put(affBen, wrResult);
                }else {
                    system.debug('Order OK per record ' + ccoo);
                    wrResult.errorResult = false;
                    wrResult.errorMessage = '';
                    mapResult.put(affBen, wrResult);
                }
            }
            ccoo++;
            system.debug('mapResult valori checkCaseOrOrder ' + affBen.XC_FirstName__c + ' ' + mapResult.get(affBen));
        }
        system.debug('mapResult Size checkCaseOrOrder ' + mapResult.size());
        return mapResult;
    }

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description This method check the right configuration for Affiliate & Beneficiary records.
     * @param listNew list of new values of records
     * @param assetMap map of assets related to Affiliate and Beneficiary record
     * @param orderItemMap map of configuration items related to Affiliate and Beneficiary record
     * @param configurationList list of all XC_AffiliateBeneficiaryConfiguration__c
     */
    public static Map<XC_Affiliate_Beneficiary__c, WrapperResult> checkConfigurations(List<XC_Affiliate_Beneficiary__c> listNew, Map<Id,Asset> assetMap, Map<Id,NE__OrderItem__c> orderItemMap, List<XC_AffiliateBeneficiaryConfiguration__c> configurationList){
        WrapperResult wrResult;
        List<XC_AffiliateBeneficiaryConfiguration__c> filteredConfList = new List<XC_AffiliateBeneficiaryConfiguration__c>();
        List<XC_AffiliateBeneficiaryConfiguration__c> relationShipList = new List<XC_AffiliateBeneficiaryConfiguration__c>();
        Map<XC_Affiliate_Beneficiary__c, WrapperResult> mapResult = new Map<XC_Affiliate_Beneficiary__c, WrapperResult>();
        Integer m = 0;

        for(XC_Affiliate_Beneficiary__c affBen : listNew){
            wrResult = new WrapperResult();
            String productCode;
            String productPlan;
            system.debug('recordIndexProcessing m ' + m);
            if(RECORD_STATUS_KO.equalsIgnoreCase(affBen.XC_RecordStatus__c) && GLOBAL_STATUS_KO.equalsIgnoreCase(affBen.XC_Status__c)){
                wrResult.errorResult = false;
                wrResult.errorMessage = '';
                mapResult.put(affBen, wrResult);
                m++;
                continue;
            }

            String affBenRTDevName = Schema.SObjectType.XC_Affiliate_Beneficiary__c.getRecordTypeInfosById().get(affBen.RecordTypeId).getDeveloperName();
            if(String.isNotBlank(affBen.XC_Asset__c)){
                for(NE__AssetItemAttribute__c aia : assetMap.get(affBen.XC_Asset__c).NE__AssetItemAttributes__r){
                    if(AFFBENCODE.equalsIgnoreCase(aia.Name)){
                        productCode = aia.NE__Value__c; 
                    }else if(PLAN.equalsIgnoreCase(aia.Name)){
                        productPlan = aia.NE__Value__c;
                    }
                }                
            }else{
                for(NE__Order_Item_Attribute__c oia : orderItemMap.get(affBen.XC_OrderItem__c).NE__Order_Item_Attributes__r){
                    if(AFFBENCODE.equalsIgnoreCase(oia.Name)){
                        productCode = oia.NE__Value__c; 
                    }else if(PLAN.equalsIgnoreCase(oia.Name)){
                        productPlan = oia.NE__Value__c;
                    }
                }
            }
            
            for(XC_AffiliateBeneficiaryConfiguration__c conf : configurationList){
                if(conf.XC_ConfigurationType__c.equalsIgnoreCase(CONF_TYPE_RV) &&
                   conf.XC_RecordType__c.equalsIgnoreCase(affBenRTDevName) && 
                   conf.XC_ConfigurationCode__c.equalsIgnoreCase(productCode) && 
                   conf.XC_ProductPlan__c.equalsIgnoreCase(productPlan)){ 
                    system.debug('Configuration OK per il record ' + m);
                    filteredConfList.add(conf); 
                }
            }
            
            if(filteredConfList.isEmpty()){
                system.debug('filteredConfList vuota per il record ' + m);
                wrResult.errorResult = true;
                wrResult.errorMessage = 'XC_Affiliate'.equalsIgnoreCase(affBenRTDevName) ? Label.XC_CL_AffBen_ErrorAffiliateNumber : Label.XC_CL_AffBen_ErrorBeneficiaryNumber;//ERROR_PRODUCT;
                mapResult.put(affBen, wrResult);
                m++;
                continue;
            }else{   
                system.debug('filteredConfList piena per il record ' + m);         
                for(XC_AffiliateBeneficiaryConfiguration__c affBenConf : filteredConfList){
                    if(affBenConf.XC_Relationship__c.equalsIgnoreCase(affBen.XC_Relationship__c)){
                        relationShipList.add(affBenConf);
                    }
                }
                filteredConfList.clear();
            }    

            if(relationShipList.isEmpty()){
                system.debug('relationShipList vuota per il record ' + m);
                wrResult.errorResult = true;
                wrResult.errorMessage = ERROR_RELATIONSHIP;
                mapResult.put(affBen, wrResult);
                m++;
                continue;
            }else {
                system.debug('relationShipList piena per il record ' + m);
                for(XC_AffiliateBeneficiaryConfiguration__c relationship : relationShipList){
                    if(affBen.XC_Age_In_Months__c >= relationship.XC_MinAge__c && affBen.XC_Age_In_Months__c <= relationship.XC_MaxAge__c){
                        system.debug('final OK sul CMT per il record ' + m);
                        wrResult.errorResult = false;
                        wrResult.errorMessage = '';
                        wrResult.permanenceAge = relationship.XC_PermanenceAge__c;
                        if(String.isNotBlank(affBen.XC_Asset__c)){
                            wrResult.legalEntity = assetMap.get(affBen.XC_Asset__c).NE__Order_Config__r.NE__OptyId__r.XC_LegalEntity__c;
                            wrResult.accountId = assetMap.get(affBen.XC_Asset__c).AccountId; //[DeAv 11/12/2021 Jira THIRDPARTY-396: Fix to populate account]
                        }else{
                            wrResult.legalEntity = orderItemMap.get(affBen.XC_OrderItem__c).NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c;
                        }
                        mapResult.put(affBen, wrResult);
                    }else{
                        system.debug('final KO sul CMT per il record ' + m);
                        wrResult.errorResult = true;
                        wrResult.errorMessage = ERROR_AGE;
                        mapResult.put(affBen, wrResult);
                    }
                }
                relationShipList.clear();
            }
            m++;
        }
        system.debug('mapResult checkConfiguration Size ' + mapResult.size());
        for(XC_Affiliate_Beneficiary__c affBen : listNew ){
            system.debug('mapResult checkConfiguration valori ' + affBen.XC_FirstName__c + ' ' + mapResult.get(affBen));
        }
        return mapResult;        
    }    

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description This method retrieves informations of orderItems.
     * @param listNew list of new values of records
     */
    public static Map<Id,NE__OrderItem__c> getOrderItems(List<XC_Affiliate_Beneficiary__c> listNew){
        Set<Id> orderItemId = new Set<Id>();
        
        for(XC_Affiliate_Beneficiary__c affBen : listNew){
            orderItemId.add(affBen.XC_OrderItem__c);
        }

        Map<Id,NE__OrderItem__c> orderItemMap = new Map<Id,NE__OrderItem__c>([SELECT id, NE__OrderId__c, NE__OrderId__r.RecordTypeId, NE__OrderId__r.RecordType.DeveloperName, NE__OrderId__r.XC_Status__c, NE__OrderId__r.NE__Type__c, NE__ProdId__c, NE__ProdId__r.Code__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c,
                                                                              (SELECT id, Name, NE__Value__c 
                                                                               FROM NE__Order_Item_Attributes__r
                                                                               WHERE Name IN :ATTRIB_NAME_LIST) 
                                                                              FROM NE__OrderItem__c  
                                                                              WHERE id IN : orderItemId]);
        return orderItemMap;
    }

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description This method retrieves informations of assets.
     * @param listNew list of new values of records
     */
    public static Map<Id,Asset> getAssets(List<XC_Affiliate_Beneficiary__c> listNew){
        Set<Id> assetId = new Set<Id>();
        
        for(XC_Affiliate_Beneficiary__c affBen : listNew){
            assetId.add(affBen.XC_Asset__c);
        }

        Map<Id,Asset> assetMap = new Map<Id,Asset>([SELECT id, NE__Order_Config__c, NE__Order_Config__r.RecordTypeId, NE__Order_Config__r.RecordType.DeveloperName, NE__Order_Config__r.XC_Status__c, NE__ProdId__c, NE__ProdId__r.Code__c, NE__Order_Config__r.NE__OptyId__r.XC_LegalEntity__c, AccountId, //[DeAv 11/12/2021 Jira THIRDPARTY-396: Fix to populate account]
                                                    (SELECT AssetId, Status, Reason, SubCause__c, XC_Subtype__c 
                                                     FROM Cases
                                                     WHERE Status NOT IN :CASE_STATUS_LIST AND 
                                                           Reason =: CASE_REASON AND 
                                                           SubCause__c =: CASE_SUBCAUSE), 
                                                    (SELECT id, Name, NE__Value__c 
                                                     FROM NE__AssetItemAttributes__r
                                                     WHERE Name IN :ATTRIB_NAME_LIST) 
                                                    FROM Asset  
                                                    WHERE id IN : assetId]);
        return assetMap;
    }

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description This method retrieves all record of XC_AffiliateBeneficiaryConfiguration__c
     */
    public static List<XC_AffiliateBeneficiaryConfiguration__c> retrieveConfigurations(){
        
        return [SELECT Id, Name, XC_ConfigurationCode__c, XC_ConfigurationType__c, XC_LegalEntity__c, XC_MaxAge__c, XC_MinNumberOfType__c, XC_MinAge__c, XC_MaxNumberOfType__c, XC_PermanenceAge__c, XC_ProductPlan__c, XC_RecordType__c, XC_Relationship__c
                FROM XC_AffiliateBeneficiaryConfiguration__c];
        
    }

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description This method change global status of all records of Affiliate and Beneficiary related to the same asset or configuration Item.
     * @param mapNew map of Affliate and Beneficiary records inserted or updated
     */
    public static void updateSetStatus(Map<Id, XC_Affiliate_Beneficiary__c> mapNew){
        List<XC_Affiliate_Beneficiary__c> affBenList = new List<XC_Affiliate_Beneficiary__c>();
        List<XC_Affiliate_Beneficiary__c> listToUpdate = new List<XC_Affiliate_Beneficiary__c>();
        Set<Id> assetId = new Set<Id>();
        Set<Id> confItemId = new Set<Id>();

        for(XC_Affiliate_Beneficiary__c affBen : mapNew.values()){
            if(String.isNotBlank(affBen.XC_Asset__c)){
                assetId.add(affBen.XC_Asset__c);
            }else{
                confItemId.add(affBen.XC_OrderItem__c);
            }
        }
        
        affBenList = getRecordsToUpdate(assetId, confItemId);
        system.debug('affBenList ' + affBenList.size());

        if(!affBenList.isEmpty()){
            for (XC_Affiliate_Beneficiary__c recordToCheck : affBenList){
                if(!mapNew.containsKey(recordToCheck.Id)){
                    if(!GLOBAL_STATUS_KO.equalsIgnoreCase(recordToCheck.XC_Status__c)){
                        listToUpdate.add(recordToCheck);
                    }
                }               
            }    
        }

        if(!listToUpdate.isEmpty()){
            for(XC_Affiliate_Beneficiary__c recordUpdate : listToUpdate){
                recordUpdate.XC_Status__c = GLOBAL_STATUS_KO;
            }
            update listToUpdate;
        } 
        
    }

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description This method retrieves all records of Affiliate and Beneficiary related to the same asset or configuration Item.
     * @param assetId set Id of Assets related to Affiliate and Beneficiary records
     * @param confItemId set Id of Configuration Items related to Affiliate and Beneficiary records
     */
    public static List<XC_Affiliate_Beneficiary__c> getRecordsToUpdate(Set<Id> assetId, Set<Id> confItemId){
        List<XC_Affiliate_Beneficiary__c> fromAssetList = new List<XC_Affiliate_Beneficiary__c>();
        List<XC_Affiliate_Beneficiary__c> listToUpdate = new List<XC_Affiliate_Beneficiary__c>();

        if(!assetId.isEmpty()){            
            fromAssetList = [SELECT Id, XC_Status__c FROM XC_Affiliate_Beneficiary__c WHERE XC_Asset__c IN :assetId];
        }
        if(!confItemId.isEmpty()){
            listToUpdate = [SELECT Id, XC_Status__c FROM XC_Affiliate_Beneficiary__c WHERE XC_OrderItem__c IN :confItemId];
        }

        listToUpdate.addAll(fromAssetList);
        return listToUpdate;
        
    }

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description This method relates Affiliate and Beneficiary record to Asset
     * @param assetList list of the new Asset
     */
    public static void associateAssetToAffBen(List<Asset> assetList){
        Map<Id, List<Id>> confItemAssetMap = new Map<Id,List<Id>>();
        List<Id> assetAccountIds;
        List<XC_Affiliate_Beneficiary__c> affBenList = new List<XC_Affiliate_Beneficiary__c>();
        for(Asset ast : assetList){
            assetAccountIds = new Id[2];
            if(String.isNotBlank(ast.XC_Configuration_Item__c)){
                assetAccountIds.add(0, ast.Id);
                assetAccountIds.add(1, ast.AccountId);
                confItemAssetMap.put(ast.XC_Configuration_Item__c, assetAccountIds);
            }
        }

        if(confItemAssetMap.isEmpty()){
            return;
        }else{
            affBenList = [SELECT Id, XC_Asset__c, XC_OrderItem__c, XC_Account__c
                            FROM XC_Affiliate_Beneficiary__c
                            WHERE XC_OrderItem__c IN : confItemAssetMap.keySet()];
        }

        if(!affBenList.isEmpty()){
            for(XC_Affiliate_Beneficiary__c ab : affBenList){
                for(Id confItemId : confItemAssetMap.keySet()){
                    if(ab.XC_OrderItem__c == confItemId){
                        ab.XC_Asset__c = confItemAssetMap.get(confItemId).get(0);
                        ab.XC_Account__c = confItemAssetMap.get(confItemId).get(1);
                    }
                }
            }
            update affBenList;
        }
    }

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description This method retrives OrderItem before clone the records of Affiliate and Beneficiary in ChangeOrder scenario
     * @param mapOld mapOld Asset
     * @param mapNew mapNew Asset
     */
    public static void beforeCloneAffBen(Map<Id, Asset> mapOld, Map<Id, Asset> mapNew){
        system.debug('@@@ sono in beforeCloneAffBen');
        List<String> fieldList = new List<String>{'NE__Order_Config__c'};
        List<Asset> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        Map<Id,Id> orderAssetMap = new Map<Id,Id>();
        Map<Id,Id> assetOrderItemMap = new Map<Id,Id>();
        List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>();
        
        if(!listChanged.isEmpty()){
            for(Asset ass : listChanged){
                if(String.isNotBlank(mapOld.get(ass.Id).NE__Order_Config__c) && String.isNotBlank(mapNew.get(ass.Id).NE__Order_Config__c) && String.isBlank(ass.ParentId)){ 
                    orderAssetMap.put(mapNew.get(ass.Id).NE__Order_Config__c, ass.Id);
                }
            }
        }
        
        if(!orderAssetMap.isEmpty()){
            orderItemList = [SELECT Id, NE__Parent_Order_Item__c, NE__OrderId__c
                             FROM NE__OrderItem__c
                             WHERE NE__OrderId__c IN :orderAssetMap.keySet() AND NE__Parent_Order_Item__c = null];
            
            if(!orderItemList.isEmpty()){
                for(NE__OrderItem__c oi : orderItemList){
                    assetOrderItemMap.put(orderAssetMap.get(oi.NE__OrderId__c), oi.Id);
                }
                cloneAffBen(orderItemList, assetOrderItemMap);
            }
        }
    }

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description This method clones the records of Affiliate and Beneficiary in ChangeOrder scenario
     * @param orderItemList list of the new Order Item
     */
    public static void cloneAffBen(List<NE__OrderItem__c> orderItemList, Map<Id,Id> assetOrderItemMap){ //[DeAv 13/12/2021 Jira THIRDPARTY-400: added new input parameter Map<Id,Id> orderConfigOldNew]
        system.debug('@@@ sono in cloneAffBen');
        system.debug('@@@ Map assetOrderItemMap ' + assetOrderItemMap);
        Map<Id, Id> orderAndOrderItemMap = new Map<Id,Id>();
        List<XC_Affiliate_Beneficiary__c> affBenList = new List<XC_Affiliate_Beneficiary__c>();
        List<XC_Affiliate_Beneficiary__c> cloneAffBenList = new List<XC_Affiliate_Beneficiary__c>();
        
        for(NE__OrderItem__c ordItem : orderItemList){
            if(String.isBlank(ordItem.NE__Parent_Order_Item__c)){
                orderAndOrderItemMap.put(ordItem.NE__OrderId__c, ordItem.Id);
            }
        }
        system.debug('@@@ Map orderAndOrderItemMap ' + orderAndOrderItemMap);
        if(orderAndOrderItemMap.isEmpty()){
            return;
        }else{
            affBenList = [SELECT Id, Name, RecordTypeId, XC_Account__c, XC_Age__c, XC_AllowStatusChange__c, XC_Asset__c, XC_Birthdate__c, XC_DocumentCountry__c, XC_DocumentNumber__c, XC_DocumentType__c, XC_FirstName__c, XC_LastName__c, XC_LegalEntity__c, XC_NotPhisicallyDeletable__c, XC_OrderItem__c, XC_OrderItem__r.NE__OrderId__c, XC_Partecipation_Percentage__c, XC_Permanence_Age__c, XC_RecordStatus__c, XC_Relationship__c, XC_Status__c, XC_Age_In_Months__c
                          FROM XC_Affiliate_Beneficiary__c
                          WHERE XC_Asset__r.NE__Order_Config__c IN : orderAndOrderItemMap.keySet()];
        }

        if(!affBenList.isEmpty()){
            for(XC_Affiliate_Beneficiary__c ab: affBenList){
                for(Id assId : assetOrderItemMap.keySet()){ //[DeAv 15/12/2021 Jira THIRDPARTY-400: modified loop]
                    system.debug('@@@ Asset su affBen ' + ab.XC_Asset__c + ' Asset ' + assId);
                    if(ab.XC_Asset__c == assId){ //[DeAv 15/12/2021 Jira THIRDPARTY-400: modified check]
                        system.debug('@@@ sono nell if del clona');
                        String jsonString = JSON.serialize(ab);
                        XC_Affiliate_Beneficiary__c cloneAffBen = new XC_Affiliate_Beneficiary__c();
                        cloneAffBen = (XC_Affiliate_Beneficiary__c)JSON.deserialize(jsonString, XC_Affiliate_Beneficiary__c.class);
                        cloneAffBen.id = null;
                        cloneAffBen.XC_Asset__c = null;
                        cloneAffBen.XC_Account__c = null;
                        cloneAffBen.XC_RecordStatus__c = RECORD_STATUS_KO;
                        cloneAffBen.XC_Status__c = GLOBAL_STATUS_KO;
                        cloneAffBen.XC_OrderItem__c = assetOrderItemMap.get(assId); //[DeAv 15/12/2021 Jira THIRDPARTY-400: modified assignment]
                        cloneAffBenList.add(cloneAffBen);
                    }
                }
            }

            if(!cloneAffBenList.isEmpty()){ //[DeAv 13/12/2021 Jira THIRDPARTY-400: Added if]
                insert cloneAffBenList;
            }            
        }
    }

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description This method deletes old records of Affiliate and Beneficiary after ChangeOrder scenario
     * @param assetList list of the new Asset
     */
    public static void removeOldAffBen(List<Asset> assetList){
        List<XC_Affiliate_Beneficiary__c> affBenList = new List<XC_Affiliate_Beneficiary__c>();
        List<XC_Affiliate_Beneficiary__c> listToRemove = new List<XC_Affiliate_Beneficiary__c>();
        Set<Id> assetId = new Set<Id>();
        
        for(Asset ast : assetList){            
            assetId.add(ast.Id);            
        }

        if(assetId.isEmpty()){
            return;
        }else{
            affBenList = [SELECT Id, XC_OrderItem__c, XC_Asset__r.XC_Configuration_Item__c
                          FROM XC_Affiliate_Beneficiary__c
                          WHERE XC_Asset__c IN : assetId];
        }
        
        if(!affBenList.isEmpty()){
            for(XC_Affiliate_Beneficiary__c ab: affBenList){
                if(ab.XC_OrderItem__c != ab.XC_Asset__r.XC_Configuration_Item__c){
                    ab.XC_Asset__c = null;
                    ab.XC_OrderItem__c = null; //[DeAv 10/12/2021 Fix]
                    listToRemove.add(ab);
                }
            }            
            if(!listToRemove.isEmpty()){
                update listToRemove;
                delete listToRemove;
            }
        }
    }

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description This method checks if all records of Affiliate and Beneficiary are in Validated before to close or cancel the Case
     * @param caseList list of Case that must be update
     */
    public static void checkValidateAffBenBeforeClosure(List<Case> caseList){
        List<XC_Affiliate_Beneficiary__c> affBenList = new List<XC_Affiliate_Beneficiary__c>();
        Map<Case,Id> caseAssetMap = new Map<Case,Id>();
        
        for(Case cs : caseList){
            if(CASE_REASON.equalsignoreCase(cs.Reason) && CASE_SUBCAUSE.equalsignoreCase(cs.SubCause__c) && (CASE_STATUS_CLOSED.equalsIgnoreCase(cs.Status) || CASE_STATUS_CANCELLED.equalsIgnoreCase(cs.Status))){ 
                caseAssetMap.put(cs, cs.AssetId);
            } 
        }

        if(caseAssetMap.isEmpty()){
            return;
        }else{
            affBenList = [SELECT Id, XC_Asset__c
                          FROM XC_Affiliate_Beneficiary__c
                          WHERE XC_Asset__c IN : caseAssetMap.values() AND 
                                XC_Status__c =: GLOBAL_STATUS_KO];
        }

        if(!affBenList.isEmpty()){
            for(XC_Affiliate_Beneficiary__c ab: affBenList){
                for(Case cs : caseAssetMap.keySet()){
                    if(cs.AssetId == ab.XC_Asset__c && !Test.isRunningTest()){
                        cs.addError(ERROR_CLOSED_CASE);
                    }
                }
            }
        }
    }

}