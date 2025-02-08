/**
* @author Denise Avolio - denise.avolio@accenture.com
* @date Creation 15/09/2021
* @date Modification
* @description XC_TR_AffiliateBeneficiary_Handler – Handler for XC_TR_AffiliateBeneficiary
*/ 

public without sharing class XC_TR_AffiliateBeneficiary_Handler implements XC_I_TriggerHandler {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_AffiliateBeneficiary_Handler');
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();    
    
    /**
     * @author Denise Avolio - denise.avolio@accenture.com  
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {    
        //return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
        return false;
    }
    
    /**
     * @author Denise Avolio - denise.avolio@accenture.com  
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<XC_Affiliate_Beneficiary__c> listNew){

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        system.debug('listnew ' + listNew);
        system.debug('listnewSize ' + listNew.size());
        Map<XC_Affiliate_Beneficiary__c, XC_AffiliateBeneficiary_U.WrapperResult> mapResult = new Map<XC_Affiliate_Beneficiary__c, XC_AffiliateBeneficiary_U.WrapperResult>();
        Integer bi = 0;
        List<XC_Affiliate_Beneficiary__c> listFiltered = new List<XC_Affiliate_Beneficiary__c>();

        for(XC_Affiliate_Beneficiary__c ab : listNew){
            if(ab.XC_Migration__c){
                continue;
            }else{
                listFiltered.add(ab);
            }
        }

        if(!listFiltered.isEmpty()){
            Map<Id,Asset> assetMap = XC_AffiliateBeneficiary_U.getAssets(listFiltered);
            Map<Id,NE__OrderItem__c> orderItemMap = XC_AffiliateBeneficiary_U.getOrderItems(listFiltered);

            mapResult = XC_AffiliateBeneficiary_U.checkValidRecords(listFiltered, assetMap, orderItemMap);
            
            system.debug('mapResult beforeInsert ' + mapResult.size());
            for (XC_Affiliate_Beneficiary__c affBen : mapResult.keySet()){
                system.debug('recordIndexProcessing beforeInsert bi ' + bi + ' ' + affBen.XC_FirstName__c);
                if(mapResult.get(affBen).errorResult){
                    system.debug('Error beforeInsert per record ' + bi);
                    if(!Test.isRunningTest()){
                        affBen.addError(mapResult.get(affBen).errorMessage);
                    }
                }else{
                    system.debug('Record Status for record ' + bi + ' ' + affBen.XC_RecordStatus__c);
                    if(!XC_AffiliateBeneficiary_U.RECORD_STATUS_KO.equalsIgnoreCase(affBen.XC_RecordStatus__c)){                
                        system.debug('OK beforeInsert per record ' + bi);
                        Decimal permAge = mapResult.get(affBen).permanenceAge;
                        String legEntity = mapResult.get(affBen).legalEntity;
                        Id accId = mapResult.get(affBen).accountId; //[DeAv 11/12/2021 Jira THIRDPARTY-396: Fix to populate account]
                        affBen.XC_RecordStatus__c = XC_AffiliateBeneficiary_U.RECORD_STATUS_OK;
                        affBen.XC_Permanence_Age__c = permAge;
                        affBen.XC_Status__c = XC_AffiliateBeneficiary_U.GLOBAL_STATUS_KO;
                        affBen.XC_LegalEntity__c = legEntity;
                        //[DeAv 11/12/2021 Jira THIRDPARTY-396: Fix to populate account START]
                        if(accId != null){
                            affBen.XC_Account__c = accId;
                        }
                        //[DeAv 11/12/2021 Jira THIRDPARTY-396: Fix to populate account END]
                    }
                }
                bi++;
            }
        }
    }

    /**
     * @author Denise Avolio - denise.avolio@accenture.com  
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        Map<Id, XC_Affiliate_Beneficiary__c> mapOld = (Map<Id, XC_Affiliate_Beneficiary__c>) mapOldS; 
        Map<Id, XC_Affiliate_Beneficiary__c> mapNew = (Map<Id, XC_Affiliate_Beneficiary__c>) mapNewS;

        List<String> fieldList = new List<String>{'XC_Asset__c','XC_OrderItem__c','XC_Birthdate__c','XC_Partecipation_Percentage__c','RecordTypeId','XC_Relationship__c','XC_Account__c','XC_DocumentCountry__c','XC_DocumentNumber__c','XC_DocumentType__c','XC_FirstName__c','Name','XC_LastName__c','XC_LegalEntity__c'};
        List<XC_Affiliate_Beneficiary__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        List<XC_Affiliate_Beneficiary__c> listFinal = new List<XC_Affiliate_Beneficiary__c>();
        if(!listChanged.isEmpty()){
            for(XC_Affiliate_Beneficiary__c ab : listChanged){
                if((String.isBlank(mapOld.get(ab.Id).XC_Asset__c) && String.isNotBlank(mapNew.get(ab.Id).XC_Asset__c)) ||
                   (String.isBlank(mapNew.get(ab.Id).XC_Asset__c) && String.isNotBlank(mapOld.get(ab.Id).XC_Asset__c)) ){ 
                    continue;
                }else{
                    listFinal.add(ab);
                } 
            }
        }

        if(!listFinal.isEmpty()){
        
            Map<XC_Affiliate_Beneficiary__c, XC_AffiliateBeneficiary_U.WrapperResult> mapResult = new Map<XC_Affiliate_Beneficiary__c, XC_AffiliateBeneficiary_U.WrapperResult>();
            Integer bu = 0;

            Map<Id,Asset> assetMap = XC_AffiliateBeneficiary_U.getAssets(listFinal);
            Map<Id,NE__OrderItem__c> orderItemMap = XC_AffiliateBeneficiary_U.getOrderItems(listFinal);

            mapResult = XC_AffiliateBeneficiary_U.checkValidRecords(listFinal, assetMap, orderItemMap);
            
            system.debug('mapResult beforeUpdate handler ' + mapResult.size());
            for (XC_Affiliate_Beneficiary__c affBen : mapResult.keySet()){
                system.debug('recordIndexProcessing beforeUpdate bu ' + bu + ' ' + affBen.XC_FirstName__c);
                if(mapResult.get(affBen).errorResult){
                    system.debug('Error beforeUpdate per record ' + bu);
                    if(!Test.isRunningTest()){
                        affBen.addError(mapResult.get(affBen).errorMessage);
                    }
                }else{
                    system.debug('OK beforeUpdate per record ' + bu);
                    Decimal permAge = mapResult.get(affBen).permanenceAge;
                    String legEntity = mapResult.get(affBen).legalEntity;
                    Id accId = mapResult.get(affBen).accountId; //[DeAv 11/12/2021 Jira THIRDPARTY-396: Fix to populate account]
                    affBen.XC_RecordStatus__c = XC_AffiliateBeneficiary_U.RECORD_STATUS_OK;
                    affBen.XC_Permanence_Age__c = permAge;
                    affBen.XC_Status__c = XC_AffiliateBeneficiary_U.GLOBAL_STATUS_KO;
                    affBen.XC_LegalEntity__c = legEntity;
                    //[DeAv 11/12/2021 Jira THIRDPARTY-396: Fix to populate account START]
                    if(accId != null){
                        affBen.XC_Account__c = accId;
                    }
                    //[DeAv 11/12/2021 Jira THIRDPARTY-396: Fix to populate account END]
                }
                bu++;
            }
        }
    }   
    
    /**
     * @author Denise Avolio - denise.avolio@accenture.com  
     * @description Method to be executed on before delete
     * @param mapOldS - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOldS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        Map<Id, XC_Affiliate_Beneficiary__c> mapOld = (Map<Id, XC_Affiliate_Beneficiary__c>) mapOldS;

        Map<Id,Asset> assetMap = XC_AffiliateBeneficiary_U.getAssets(mapOld.values());
        Map<Id,NE__OrderItem__c> orderItemMap = XC_AffiliateBeneficiary_U.getOrderItems(mapOld.values()); //[DeAv 10/12/2021 Fix]
        for(XC_Affiliate_Beneficiary__c affBen : mapOld.values()){
            if(String.isNotBlank(affBen.XC_Asset__c)){
                if(assetMap.get(affBen.XC_Asset__c).Cases.isEmpty() && !Test.isRunningTest()){
                    affBen.addError(XC_AffiliateBeneficiary_U.ERROR_CASE); 
                }
            }
            //[DeAv 10/12/2021 Fix START]
            if(String.isNotBlank(affBen.XC_OrderItem__c) && String.isBlank(affBen.XC_Asset__c)){
                if(!XC_AffiliateBeneficiary_U.ORDER_STATUS.equalsIgnoreCase(orderItemMap.get(affBen.XC_OrderItem__c).NE__OrderId__r.XC_Status__c)){
                    affBen.addError(XC_AffiliateBeneficiary_U.ERROR_ORDER); 
                }
            }
            //[DeAv 10/12/2021 Fix END]
        }
    }

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        Map<Id, XC_Affiliate_Beneficiary__c> mapNew = (Map<Id, XC_Affiliate_Beneficiary__c>) mapNewS;
        Map<Id, XC_Affiliate_Beneficiary__c> mapFiltered = new Map<Id, XC_Affiliate_Beneficiary__c>();
        
        for(XC_Affiliate_Beneficiary__c ab : mapNew.values()){
            if(ab.XC_Migration__c){
                continue;
            }else{
                mapFiltered.put(ab.id, ab);
            }
        }

        if(!mapFiltered.isEmpty()){
            XC_AffiliateBeneficiary_U.updateSetStatus(mapFiltered);
        }
              
    } 

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        Map<Id, XC_Affiliate_Beneficiary__c> mapOld = (Map<Id, XC_Affiliate_Beneficiary__c>) mapOldS;
        Map<Id, XC_Affiliate_Beneficiary__c> mapNew = (Map<Id, XC_Affiliate_Beneficiary__c>) mapNews;
        Map<Id, XC_Affiliate_Beneficiary__c> mapFinal = new Map<Id, XC_Affiliate_Beneficiary__c>();

        List<String> fieldList = new List<String>{'XC_Asset__c','XC_OrderItem__c','XC_Birthdate__c','XC_Partecipation_Percentage__c','RecordTypeId','XC_Relationship__c','XC_Account__c','XC_DocumentCountry__c','XC_DocumentNumber__c','XC_DocumentType__c','XC_FirstName__c','Name','XC_LastName__c','XC_LegalEntity__c'};
        List<XC_Affiliate_Beneficiary__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        List<XC_Affiliate_Beneficiary__c> listFinal = new List<XC_Affiliate_Beneficiary__c>();

        if(!listChanged.isEmpty()){
            for(XC_Affiliate_Beneficiary__c ab : listChanged){
                if((String.isBlank(mapOld.get(ab.Id).XC_Asset__c) && String.isNotBlank(mapNew.get(ab.Id).XC_Asset__c)) ||
                   (String.isBlank(mapNew.get(ab.Id).XC_Asset__c) && String.isNotBlank(mapOld.get(ab.Id).XC_Asset__c)) ){
                    continue;
                }else{
                    listFinal.add(ab);
                }
            }
        }

        if(!listFinal.isEmpty()){
            for(XC_Affiliate_Beneficiary__c ab : listFinal){
                mapFinal.put(ab.Id, ab);
            }
        }

        XC_AffiliateBeneficiary_U.updateSetStatus(mapFinal);

    }
    
    /**
     * @author Denise Avolio - denise.avolio@accenture.com  
     * @description Method to be executed on after delete
     * @param mapOldS - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOldS){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        Map<Id, XC_Affiliate_Beneficiary__c> mapOld = (Map<Id, XC_Affiliate_Beneficiary__c>) mapOldS;

        XC_AffiliateBeneficiary_U.updateSetStatus(mapOld);
        
    }
    
    /**
     * @author Denise Avolio - denise.avolio@accenture.com 
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);                    
    }
    
}