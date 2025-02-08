/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 09/05/2019 
* @date Modification 
* @description XC_TR_ConfigurationItem_U_BillingModel - Class to populate with a default value the billing model on the configuration items. 
*/ 
public without sharing class XC_TR_ConfigurationItem_U_BillingModel {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ConfigurationItem_U_BillingModel');

    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description onInsert - trigger on insert
    * @param listNew - the list of new Order Items
    */ 
    public static void onInsert(List<NE__OrderItem__c> listNew){
        populateNoPaymentRequired(listNew);
        populateDefaultBillingModel(listNew);
    }

    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description onUpdate - trigger on update
    * @param mapOld - the map of new Order Items old
    * @param mapNew - the map of new Order Items new
    */
    public static void onUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew){

        List<String> fieldList = new List<String>{'NE__BaseOneTimeFee__c','NE__BaseRecurringCharge__c','NE__OneTimeFeeOv__c','NE__RecurringChargeOv__c'};
        List<NE__OrderItem__c> confItemListChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        List<NE__OrderItem__c> confItemListChangedB2C = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c oi : confItemListChanged){
            if(oi.XC_Segment__c != 'B2B' && oi.XC_Segment__c != 'B2G'){
                confItemListChangedB2C.add(oi);
            }
        }
        if(!confItemListChanged.isEmpty()){
            populateNoPaymentRequired(confItemListChanged);
        }
        if(!confItemListChanged.isEmpty()){
            populateDefaultBillingModel(confItemListChangedB2C);
        }

    }

    /**
    * @description the method works to populate correctly the billing model on the bundle configuration item, it takes as correct
        value the one taken from the order item with subtype Parameter. It works on After Update, because the bundle configuration
        is not populated in insert. 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 4/9/2019 
    * @param mapOld 
    * @param mapNew 
    **/
    public static void onAfterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew){
        // FIX SS 03 09
        List<String> fieldListBundle = new List<String>{'NE__Bundle_Configuration__c'};       
        List<NE__OrderItem__c> confItemListChangedWithBundle = XC_UTIL_SObject.getListChanged(fieldListBundle, mapOld, mapNew);
        if(confItemListChangedWithBundle.isEmpty()){
            return;
        }
        Map<String, String> bundleMap = populateBillingModel(confItemListChangedWithBundle);
        List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>(); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@0310@@ bundleMap ---> ' + bundleMap);
        if(!bundleMap.containsKey('No value')){
            for(String orderBundleId: bundleMap.keySet()){
                NE__OrderItem__c orderItem = new NE__OrderItem__c(Id = orderBundleId);
                orderItem.XC_BillingModel__c = bundleMap.get(orderBundleId);
                orderItemList.add(orderItem);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@0310@@ Bundle Configuration ---> ' + orderItem.XC_BillingModel__c);
            }
            if(!orderItemList.isEmpty()){
                XC_UTIL_Sobject.updateListRecords(orderItemList);
            }
        }
    }
    
    private static Map<String, String> populateBillingModel (List<NE__OrderItem__c> confItemListChangedWithBundle){
        Map<String, String> bundleMap = new Map<String, String>();
        List<NE__OrderItem__c> orderItemParameter = new List<NE__OrderItem__c>();
        if(!confItemListChangedWithBundle.isEmpty()){
            for(NE__OrderItem__c orderItem : confItemListChangedWithBundle){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@0901202 NE__OneTimeFeeOv__c:  ' + orderItem.NE__OneTimeFeeOv__c);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@0901202 NE__RecurringChargeOv__c: ' + orderItem.NE__RecurringChargeOv__c);
                if(orderItem.XC_CountryFormula__c == 'Italy'){
                    if(orderItem.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment && orderItem.XC_BillingModel__c != 'Usage'){
                        orderItemParameter.add(orderItem);
                    }
                }else{
                    if(orderItem.XC_Product_Subtype__c == Label.XC_CL_ProductSubtype_Parameter 
                    || (orderItem.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment && orderItem.XC_BillingModel__c != 'Usage')){
                        orderItemParameter.add(orderItem);
                    }
                }
            }
            if(!orderItemParameter.isEmpty()){
                for(NE__OrderItem__c orderItem : orderItemParameter){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@0309@@ BillingModel ---> ' + orderItem.XC_BillingModel__c);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@0309@@ Bundle Configuration ---> ' + orderItem.NE__Bundle_Configuration__c);
                    bundleMap.put(orderItem.NE__Bundle_Configuration__c, orderItem.XC_BillingModel__c);
                }
            } else {
                bundleMap.put('No value', 'No value');
            }
        } else {
            bundleMap.put('No value', 'No value');
        }
        return bundleMap;
    }
    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 30/10/2020 
    * @description populateNoPaymentRequired - populate the payment method as No Payment Required is needed
    * @param orderItemList - the list of Order Items new or with NE__OneTimeFeeOv__c or NE__RecurringChargeOv__c changed
    */ 
    private static void populateNoPaymentRequired(List<NE__OrderItem__c> orderItemList){

        Map<String, XC_CM_LegalEntity_Configuration__mdt> noPaymentRequiredLegalEntitySegmentMap = getCustomMetadataInfo(orderItemList); 
        for(NE__OrderItem__c orderItem : orderItemList){
            if((String.isEmpty(orderItem.NE__Root_Order_Item__c) && String.isEmpty(orderItem.NE__Bundle_Configuration__c) && FeatureManagement.checkPermission('XC_Brazil_MVP')) //DCR 01/03/2022 - MVP Brazil
            || (String.isEmpty(orderItem.NE__Root_Order_Item__c) && String.isEmpty(orderItem.NE__Bundle_Configuration__c)
            && noPaymentRequiredLegalEntitySegmentMap.containsKey(orderItem.XC_LegalEntityFormula__c+orderItem.XC_Segment__c) 
            && noPaymentRequiredLegalEntitySegmentMap.get(orderItem.XC_LegalEntityFormula__c+orderItem.XC_Segment__c).XC_NotShowZeroPricedProds__c
            && checkIfUsage(orderItem, 0) && orderItem.XC_PaymentMethod__c != Label.XC_CL_PaymentMethod_CommodityOffer
            && orderItem.XC_Product_Type__c != Label.XC_CL_ProductTypeBundle)) {
                orderItem.XC_PaymentMethod__c = Label.XC_CL_PaymentMethod_NoPaymentRequired;
            }
        }
    }

    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description populateDefaultBillingModel - populate Default Billing Model
    * @param orderItemList - the list of Order Items new or with NE__OneTimeFeeOv__c or NE__RecurringChargeOv__c changed
    */ 
    public static void populateDefaultBillingModel(List<NE__OrderItem__c> orderItemList) {
        
        Set<Id> catalogIds = XC_UTIL_Sobject.getSetIdsOnField(orderItemList, 'NE__Catalog__c');
        Map<Id, NE__Catalog__c> catalogsMap = new Map<Id, NE__Catalog__c>([SELECT Id, XC_LIC_Name__c FROM NE__Catalog__c WHERE ID IN: catalogIds]);

        for(NE__OrderItem__c orderItem : orderItemList){
            if(checkIfOneShot(orderItem, 1)){
                orderItem.XC_BillingModel__c = Label.XC_CL_ConfItemAttr_OneShot;
            } else if(checkIfRecurring(orderItem, 1)){
                orderItem.XC_BillingModel__c = Label.XC_CL_BillingModel_Recurring;
            } else if(checkIfDownpaymentAndInstallment(orderItem, 1)){
                orderItem.XC_BillingModel__c = Label.XC_CL_BillingModel_DownpaymentAndInstallment;
            } else if(checkIfUsage(orderItem, 1)&& checkLegalEntityAndStream(orderItem, catalogsMap)){
                checkOnOneTimeAndRecurringCharge(orderItem, catalogsMap);
                //orderItem.XC_BillingModel__c = Label.XC_CL_BillingModel_Usage;
            }
        } 
    }
    
    /**
    * @description method required to manage the scenario in which the order item has both NE__BaseOneTimeFee__c and NE__BaseRecurringCharge__c equals to 0, and in some B2B
                    cases the billing model is not necessary Usage.
    * @author salvatore.scarpato@nttdata.com | 9/4/2020 
    * @param orderItem 
    **/
    private static void checkOnOneTimeAndRecurringCharge(NE__OrderItem__c orderItem, Map<Id, NE__Catalog__c> catalogsMap){
        if(checkIfOneShot(orderItem, 2)){
            orderItem.XC_BillingModel__c = Label.XC_CL_ConfItemAttr_OneShot;
        } else if(checkIfRecurring(orderItem, 2)){
            orderItem.XC_BillingModel__c = Label.XC_CL_BillingModel_Recurring;
        } else if(checkIfDownpaymentAndInstallment(orderItem, 2)){
            orderItem.XC_BillingModel__c = Label.XC_CL_BillingModel_DownpaymentAndInstallment;
        } else if(checkIfUsage(orderItem, 2) && checkLegalEntityAndStream(orderItem, catalogsMap)){
            orderItem.XC_BillingModel__c = Label.XC_CL_BillingModel_Usage;
        }
    }

    /**
    * @description get from the custom metadata legalEntity the info to verify if "No Payment Required" is an accepted billing model  
    * @author salvatore.scarpato@nttdata.com | 30/104/2020 
    * @param orderItem 
    **/
    private static Map<String,XC_CM_LegalEntity_Configuration__mdt> getCustomMetadataInfo (List<NE__OrderItem__c> orderItemList){
        Map<String,XC_CM_LegalEntity_Configuration__mdt> noPaymentRequiredLegalEntitySegmentMap = new Map<String,XC_CM_LegalEntity_Configuration__mdt>();
        Set<String> legalEntitySet = new Set<String>();
        Set<String> segmentSet = new Set<String>();
        for(NE__OrderItem__c orderItem : orderItemList){
            legalEntitySet.add(orderItem.XC_LegalEntityFormula__c);
            segmentSet.add(orderItem.XC_Segment__c);
        }
        if(!legalEntitySet.isEmpty() && !segmentSet.isEmpty()){
            noPaymentRequiredLegalEntitySegmentMap = XC_Util_LegalEntityOneOrg.getOrgConfigLegalEntities(legalEntitySet, segmentSet);
        }
        return noPaymentRequiredLegalEntitySegmentMap;
    }

    /**
    * @description 
    * @author 
    * @param orderItemList 
    * @return String 
    **/
    public static String checkBillingModel(List<NE__OrderItem__c> orderItemList) {
        for(NE__OrderItem__c o : orderItemList){
            if(o.XC_IsAProduct__c){
                return o.XC_BillingModel__c;
            }
        }
        return '';
    }
    

    /**
    * @description 
    * @author 
    * @param orderItemList 
    * @param mapOld 
    * @param mapNew 
    **/
    public static void setModelFromBundle(List<NE__OrderItem__c> orderItemList, Map<Id,NE__OrderItem__c> mapOld, Map<Id,NE__OrderItem__c> mapNew) {
        List<NE__OrderItem__c> itemToUpdate = new List<NE__OrderItem__c> (); 
        List<String> fieldList = new List<String>{'XC_BillingModel__c','XC_PaymentMethod__c','XC_BillingProfileLineItem__c'}; 
        List<String> fieldListPayment = new List<String>{'XC_PaymentMethod__c', 'XC_BillingProfileLineItem__c'}; 
        List<NE__OrderItem__c> confItemListChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        List<NE__OrderItem__c> confItemListChangedPayment = XC_UTIL_SObject.getListChanged(fieldListPayment, mapOld, mapNew);
        if(confItemListChanged.isEmpty()){
            return;
        }
        if(!confItemListChangedPayment.isEmpty()){
            checkExternalFinancingPayment(confItemListChanged);
        }
        List<NE__OrderItem__c> onlyBundleList = checkIfBundle(confItemListChanged);
        if(onlyBundleList.isEmpty()){
            return;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'onlyBundleList = '+onlyBundleList);
        Set<Id> bundleIds = XC_UTIL_Sobject.getSetIds(onlyBundleList);
        List<NE__OrderItem__c> confItemList = new List<NE__OrderItem__c>([SELECT id,NE__Bundle_Configuration__c FROM NE__OrderItem__c WHERE NE__Bundle_Configuration__c IN: bundleIds AND XC_Product_Type__c!='Bundle']);
        
        for(NE__OrderItem__c orderIt : confItemList){
            for(NE__OrderItem__c o : onlyBundleList){
                if(orderIt.NE__Bundle_Configuration__c == o.id ){
                    orderIt.XC_BillingModel__c = o.XC_BillingModel__c;
                    orderIt.XC_PaymentMethod__c = o.XC_PaymentMethod__c;
                    orderIt.XC_BillingProfileLineItem__c = o.XC_BillingProfileLineItem__c;
                    itemToUpdate.add(orderIt);
                }
            }
        }
        XC_UTIL_Sobject.updateListRecords(itemToUpdate);
    }

    /**
    * @description 
    * @author  
    * @param orderItemList 
    * @return List<NE__OrderItem__c> 
    **/
    public static List<NE__OrderItem__c> checkIfBundle(List<NE__OrderItem__c> orderItemList){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In checkIfBundle con '+orderItemList);
        List<NE__OrderItem__c> bundleList = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c orderIt : orderItemList){
            if(orderIt.XC_Product_Type__c== Label.XC_CL_ProductTypeBundle){
                bundleList.add(orderIt);
            }
        }
        return bundleList;
    }
    
     /**
     * @author Roberta Cossiga - rcossiga@deloitte.it
     * @date 05/11/2019
     * @description Method to create External Financing Case
     * @param orderItemList - List<NE__OrderItem__c>
     */
    public static void checkExternalFinancingPayment(List<NE__OrderItem__c> orderItemList){
        List<String> orderIds = XC_UTIL_Sobject.getListFieldValues(orderItemList, 'NE__OrderId__c');
        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_CMD_ExternalFinancing});
        XC_CM_Case_Type_Setting__mdt caseMDT = mapCaseSetting.get(Label.XC_CL_CMD_ExternalFinancing);
        Map<Id, NE__Order__c> mapExternalFinancingCase = getExternalFinancingCase(orderIds, caseMDT);
        if(caseMDT == null) {
            throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_CMD_ExternalFinancing}));
        }
        Map<String,Case> caseMapToInsert = new Map<String,Case>();
        String rtOrder = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        for(NE__OrderItem__c orderIt : orderItemList){
            if(!String.isBlank(orderIt.XC_PaymentMethod__c) && orderIt.XC_PaymentMethod__c == 'External Financing' && 
                mapExternalFinancingCase.get(orderIt.NE__OrderId__c).XC_Cases__r.isEmpty() &&
                orderIt.XC_BillingProfileLineItem__c != null && 
                mapExternalFinancingCase.get(orderIt.NE__OrderId__c).RecordTypeId == rtOrder 
            ) {
                Case c = XC_UTIL_Case.initCaseFromCaseSettings(caseMDT);
                c.AccountId = mapExternalFinancingCase.get(orderIt.NE__OrderId__c).NE__AccountId__c;
                c.ContactId = mapExternalFinancingCase.get(orderIt.NE__OrderId__c).NE__OptyId__r.XC_Contact__c;
                //c.Origin = Label.XC_CL_CaseOriginCAN002;
                c.XC_Order__c = orderIt.NE__OrderId__c;
                caseMapToInsert.put(c.XC_Order__c, c); 
            }
        }
        XC_UTIL_Sobject.insertListRecords(caseMapToInsert.values());
        XC_UTIL_Sobject.runAssignmentRules(caseMapToInsert.values(),'Case');
    }
    
 /**
 * @author Roberta Cossiga - rcossiga@deloitte.it
 * @date 05/11/2019
 * @description Method to get External Financing Case
 * @param orderId - String
 * @return Map<Id, NE__Order__c>
 */
    public static Map<Id, NE__Order__c> getExternalFinancingCase(List<String> orderIds, XC_CM_Case_Type_Setting__mdt caseMDT) {
        return new Map<Id, NE__Order__c>([
                SELECT Id,NE__Type__c, NE__AccountId__c,NE__OptyId__r.XC_Contact__c,RecordTypeId,
                    (SELECT Id
                    FROM XC_Cases__r
                    WHERE SubCause__c =: caseMDT.XC_Sub_Cause__c 
                    AND Reason =: caseMDT.XC_Case_Reason__c
                    AND XC_Subtype__c =: caseMDT.XC_Sub_Type__c
                    /*AND Status =: Label.XC_CL_Case_Open*/)
                FROM NE__Order__c
                WHERE Id IN: orderIds]);
    }


        
    private static Boolean checkIfOneShot(NE__OrderItem__c orderItem, Integer checkNumber) {
        if(checkNumber == 1){
            return (orderItem.NE__BaseOneTimeFee__c > 0 && orderItem.NE__BaseRecurringCharge__c == 0);
        } else {
            return (orderItem.NE__OneTimeFeeOv__c > 0 && orderItem.NE__RecurringChargeOv__c == 0);
        }
    }
    
    private static Boolean checkIfRecurring(NE__OrderItem__c orderItem, Integer checkNumber){
        if(checkNumber == 1){
            return (orderItem.NE__BaseOneTimeFee__c == 0 && orderItem.NE__BaseRecurringCharge__c > 0);
        } else{ 
            return (orderItem.NE__OneTimeFeeOv__c == 0 && orderItem.NE__RecurringChargeOv__c > 0);
        }
    }
    
    private static Boolean checkIfDownpaymentAndInstallment(NE__OrderItem__c orderItem, Integer checkNumber){
        if(checkNumber == 1){
            return (orderItem.NE__BaseOneTimeFee__c > 0 && orderItem.NE__BaseRecurringCharge__c > 0);
        } else {
            return (orderItem.NE__OneTimeFeeOv__c > 0 && orderItem.NE__RecurringChargeOv__c > 0);
        }
    }

    private static Boolean checkIfUsage(NE__OrderItem__c orderItem, Integer checkNumber){
        if (checkNumber == 1) {
            return (orderItem.NE__BaseOneTimeFee__c == 0 && orderItem.NE__BaseRecurringCharge__c == 0);
        } else {
            return (orderItem.NE__OneTimeFeeOv__c == 0 && orderItem.NE__RecurringChargeOv__c == 0);
        }
    }

    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @date Creation 07/04/2020
     * @description check payment method of a bundle item
     * @param mapOld the map old
     * @param mapNew the map new
     * @param orderItemList the order item list
     */
    public static void checkPaymentMethodOfBundle(List<NE__OrderItem__c> orderItemList, Map<Id,NE__OrderItem__c> mapOld, Map<Id,NE__OrderItem__c> mapNew) {

        List<NE__OrderItem__c> itemToUpdate = new List<NE__OrderItem__c> ();
        List<String> fieldList = new List<String>{'XC_PaymentMethod__c'};
        List<NE__OrderItem__c> confItemListChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);

        if(confItemListChanged.isEmpty()){
            return;
        }

        Map<Id, NE__OrderItem__c> bundleMap = new Map<Id, NE__OrderItem__c>();
        for(NE__OrderItem__c orderIt : confItemListChanged){
            if(orderIt.XC_Product_Type__c == Label.XC_CL_ProductTypeBundle && (orderIt.XC_LegalEntityFormula__c == Label.XC_CL_LegalEntity_Italy || orderIt.XC_LegalEntityFormula__c == Label.XC_CL_LegalEntity_EnelXMobilityItalia)){
                bundleMap.put(orderIt.Id, orderIt);
            }
        }

        if(!bundleMap.isEmpty()){
           
            checkPaymentMethodOfIncentiveBundle(bundleMap);
        }
       
    }


    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @date Creation 07/04/2020
     * @description check payment method of a bundle with incentive
     * @param mapOld the map old
     * @param mapNew the map new
     * @param orderItemList the order item list
     */
    public static void checkPaymentMethodOfIncentiveBundle(Map<Id, NE__OrderItem__c> bundleMap){

        Map<Id, NE__OrderItem__c> confItemList = new Map<Id, NE__OrderItem__c>([SELECT Id, NE__Bundle_Configuration__c, XC_Product_Subtype__c FROM NE__OrderItem__c WHERE NE__Bundle_Configuration__c IN: bundleMap.KeySet() AND XC_Product_Subtype__c =: Label.XC_CL_ProductSubtypeIncentive]);
        Set<Id> bundleConfig = new Set<Id>();
        for(NE__OrderItem__c orderIt : confItemList.values()){
            bundleConfig.add(orderIt.NE__Bundle_Configuration__c);
        }

        if(!bundleConfig.isEmpty()){
            for(NE__OrderItem__c orderIt : bundleMap.values()){
                if(bundleConfig.contains(orderIt.Id) && !String.isBlank(orderIt.XC_PaymentMethod__c) && (!checkIncentivePaymentMethodforItems(orderIt))){
                    orderIt.addError(Label.XC_CL_IncentivePaymentError);
                }
            }
        }

    }
    /**
     * @author Marco Ottaviano mottaviano@deloitte.it
     * @date Creation 16/02/2021
     * @description check payment method of a bundle with incentive NR1084 
     * @param orderIt the order item list
     */
    private static Boolean checkIncentivePaymentMethodforItems(NE__OrderItem__c orderIt) {
        Boolean returnBool = true;
        if(orderIt.XC_Product_Subtype__c == Label.XC_CL_ProductSubtypeWallbox && (orderIt.XC_PaymentMethod__c == Label.XC_CL_BankTransfer || orderIt.XC_PaymentMethod__c == Label.XC_CL_Payment_ExternalFinancing || orderIt.XC_PaymentMethod__c ==Label.XC_CL_Credit_Card)) {
            returnBool = true;
        //General Case without check of Product SubType
        } else if((orderIt.XC_PaymentMethod__c != Label.XC_CL_BankTransfer && orderIt.XC_PaymentMethod__c != Label.XC_CL_Payment_ExternalFinancing)) {
         returnBool = false;
        }
       return returnBool;
    }

    private static Boolean checkLegalEntityAndStream(NE__OrderItem__c orderItem, Map<Id, NE__Catalog__c> catalogsMap){
        Set<String> setStream = new Set<String>();
        setStream.add('B2B');
        setStream.add('B2G');
        Boolean check = True;
        if(setStream.contains(orderItem.XC_Segment__c) && catalogsMap.get(orderItem.NE__Catalog__c) != null && !catalogsMap.get(orderItem.NE__Catalog__c).XC_LIC_Name__c.containsIgnoreCase('eMobility')) {
            check = False;
        }
        if(setStream.contains(orderItem.XC_Segment__c) && catalogsMap.get(orderItem.NE__Catalog__c) != null && (orderItem.XC_LegalEntity__c == 'EnelXMSP' || orderItem.XC_LegalEntity__c == 'EnelXMobilityHolding')){
            check = true;
        }
        return check;
    }
	
	    /**
     * @author Andrea DI Cicco
     * @date Creation 07/04/2020
     * @description set the billing mother of a child conf item as the father's BM
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void populateBillingModelComplexProd( Map<Id,NE__OrderItem__c> mapOld, Map<Id,NE__OrderItem__c> mapNew){
        for(NE__OrderItem__c oi : mapNew.values()){
            if((oi.XC_Segment__c == 'B2B'|| oi.XC_Segment__c == 'B2G') && oi.NE__Parent_Order_Item__c != null && mapNew.get(oi.NE__Parent_Order_Item__c)!= null){
                oi.XC_BillingModel__c = mapNew.get(oi.NE__Parent_Order_Item__c).XC_BillingModel__c;
            }
            if((oi.XC_Segment__c == 'B2B'|| oi.XC_Segment__c == 'B2G') && oi.XC_BillingModel__c == null && (oi.XC_LegalEntity__c == 'EnelXMSP' || oi.XC_LegalEntity__c == 'EnelXMobilityHolding' || oi.XC_LegalEntity__c == 'EnelXMobilitySpain')){
                oi.XC_BillingModel__c = 'Usage';
            }
            
        }
    }
    
}