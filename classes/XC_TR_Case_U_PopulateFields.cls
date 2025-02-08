/**
 * The Class XC_TR_Case_U_PopulateFields.
 *
 * @author            : Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 18/07/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Class to populate Case fields
 **/ 

public without sharing class XC_TR_Case_U_PopulateFields {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Case_U_PopulateFields');
 
    /**
    * populateLegalEntity.
    * @param listNew the list new
    * @description populate case legal entity
    */
    public static void populateLegalEntityAndGeoCountry(List<Case> listNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_Case_U_PopulateFields.populateLegalEntity');
        User runningUser;
        Map<Id, User> runningUserMap = new Map<Id, User>([SELECT Id, XC_LegalEntity__c FROM User WHERE Id = :UserInfo.getUserId()]);
        Map<String,String> leByRt = getDefaultLegalEntityByCaseRecordType(listNew);
        if(!runningUserMap.values().isEmpty()) {
            runningUser = runningUserMap.values()[0];
        }

        Set<Id> contactIds = XC_UTIL_Sobject.getSetIdsOnField(listNew, 'ContactId');
        //Map<Id, String> contactIdSegmentMap = XC_SegmentUtilities.getSegmentFromObject(contactIds, 'Contact');
        Map<Id, Contact> contactIdMap = getContactInfos(contactIds);
        List<String> picklistValues = XC_Util_Sobject.getPicklistValues('Case','XC_GeolocalizationCountry__c');
        String rtName;
        for(Case c : listNew){
            if(c.XC_GeolocalizationCountry__c== null && c.ContactId!= null &&  picklistValues.contains(contactIdMap.get(c.ContactId).Account.XC_Country__c.toLowerCase().capitalize() )){
                c.XC_GeolocalizationCountry__c = contactIdMap.get(c.ContactId).Account.XC_Country__c;
            }

            if(String.isNotBlank(c.ContactId)) {
                c.XC_Segment__c = contactIdMap.get(c.ContactId).XC_Segment__c;
            }
            if(String.isNotBlank(c.XC_LegalEntity__c)){
                continue;
            }
            if(c.Origin == Label.XC_CL_EmailToCaseOrigin && String.isNotBlank(c.RecordTypeId)){
                rtName = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(c.RecordTypeId).getDeveloperName();
                c.XC_LegalEntity__c = leByRt.get(rtName);
            }else if(runningUser!=null){
                c.XC_LegalEntity__c = runningUser.XC_LegalEntity__c;
            }
            if(String.isBlank(c.XC_LegalEntity__c)){
                c.addError(Label.XC_CL_Case_MissingLegalEntity);
            }
          
        }                 
    }

    /**
    * @author Monica Cutillo - mcutillo@deloitte.it
    * @description get Default LegalEntity by Case RecordType
    * @param listNew the list of new case
    * @return Map<String,String> with RT -> LE
    */
    public static Map<String,String> getDefaultLegalEntityByCaseRecordType(List<Case> listNew){
        Map<String,String> result = new Map<String,String>();
        Set<Id> rtIds = new Set<Id>(XC_UTIL_Sobject.getSetIdsOnField(listNew, 'RecordTypeId'));
        Set<String> rtNames = new Set<String>();
        for(Id id : rtIds){
            rtNames.add(Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(id).getDeveloperName());
        }
        if(rtNames.isEmpty()){
            return result;
        }

        Map<Id,XC_CM_CaseReasonRtMapping__mdt> mtds = new Map<Id,XC_CM_CaseReasonRtMapping__mdt>([
            SELECT Id, XC_CaseRecordType__c, XC_LegalEntity__c
              FROM XC_CM_CaseReasonRtMapping__mdt
             WHERE XC_CaseRecordType__c IN: rtNames
        ]);
        for(XC_CM_CaseReasonRtMapping__mdt mtd : mtds.values()){
            result.put(mtd.XC_CaseRecordType__c, mtd.XC_LegalEntity__c);
        }
        return result;
    }
    
    public static Map<Id, Contact> getContactInfos(Set<Id> contactIds){
        if(contactIds.isEmpty()){
            return null;
        }

        Map<Id,Contact> result = new Map<Id,Contact>([
            SELECT Id, XC_Segment__c,  Account.XC_Country__c
            FROM Contact
            WHERE Id IN :contactIds
        ]);

        return result;
    }
   
    /**
    * @author Monica Cutillo - mcutillo@deloitte.it
    * @description populate AssetListDetails field on update
    * @param listNew the list of new case
    */
    /*public static void populateAssetListDetails(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew) {
        List<String> fieldList = new List<String> { 'AssetId' };
        List<Case> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew); 
        if(!listChanged.isEmpty()) {
            populateAssetListDetails(listChanged);
        }
    }
    
    /**
    * @author Monica Cutillo - mcutillo@deloitte.it
    * @description populate AssetListDetails field
    * @param listNew the list of new case
    */
    /*public static void populateAssetListDetails(List<Case> listNew) {
        List<Case> casesToCalculate = new List<Case>();
        for(Case caso : listNew){
            if(String.isBlank(caso.AssetId)){
                caso.XC_AssetListDetails__c = null;
            }else{
                casesToCalculate.add(caso);
            }
        }
        if(!casesToCalculate.isEmpty()){
            Set<Id> assetsId = XC_UTIL_Sobject.getSetIdsOnField(casesToCalculate, 'AssetId');
            Map<Id,Id> relationsMapping = XC_UTIL_Asset_D.getAllBundleRootsId(assetsId);
            Set<Id> rootIds = new Set<Id>(relationsMapping.values());
            Map<Id,List<Asset>> equipmentData = XC_UTIL_Asset_D.retrieveAllBundleEquipmentData(rootIds);
            String assetListValue;
            List<Asset> eqpAssets;
            for(Case caso : casesToCalculate){
                assetListValue = '';
                eqpAssets = equipmentData.get( relationsMapping.get(caso.AssetId) );
                if(eqpAssets != null && !eqpAssets.isEmpty()){
                    for(Asset eqp : eqpAssets){
                        if(String.isNotBlank(assetListValue)){
                            assetListValue = assetListValue + ',';
                        }
                        assetListValue = assetListValue + eqp.Name + '<SN>' + eqp.SerialNumber;
                    }
                }
                caso.XC_AssetListDetails__c = assetListValue;
            }
        }
    }*/



    /**
    * setNeedInternalCheckOnInsert.
    * @author Nicola Mariniello - nmariniello@deloitte.it
    * @param listNew the list new
    * @description set Need Internal Check field on insert


    */
    public static void setNeedInternalCheckOnInsert(List<Case> listNew) {
        
        List<Case> casesToProcess = new List<Case>();
        Set<String> legalEntitySet = new Set<String>();
        Set<String> segmentSet = new Set<String>();
        for(Case c : listNew) {
            if(String.isNotBlank(c.XC_BusinessLine__c) && String.isNotBlank(c.XC_LegalEntity__c) && String.isNotBlank(c.XC_Segment__c)) {

                casesToProcess.add(c);
                legalEntitySet.add(c.XC_LegalEntity__c);
                segmentSet.add(c.XC_Segment__c);
            }
        }

        if(casesToProcess.isEmpty()) {
            return;
        }

        setNeedInternalCheck(casesToProcess, legalEntitySet, segmentSet);
    }


    /**
    * setNeedInternalCheck.
    * @author Nicola Mariniello - nmariniello@deloitte.it
    * @param casesToProcess the casesToProcess
    * @param legalEntitySet the legalEntitySet
    * @param segmentSet the segmentSet
    * @description set Need Internal Check field


    */
    public static void setNeedInternalCheck(List<Case> casesToProcess, Set<String> legalEntitySet, Set<String> segmentSet) {

        Map<Id, XC_CM_LegalEntity_Configuration__mdt> legalEntityConfigs = new Map<Id, XC_CM_LegalEntity_Configuration__mdt>([SELECT Id, XC_BusinessLineForNeedInternalCheck__c, XC_LegalEntity__c, XC_Stream__c
                                                                                                                                FROM XC_CM_LegalEntity_Configuration__mdt
                                                                                                                                WHERE XC_LegalEntity__c IN :legalEntitySet AND XC_Stream__c IN :segmentSet AND XC_OrgId__c = :UserInfo.getOrganizationId()]);
        Map<String, List<String>> keyBusinessLinesMap = new Map<String, List<String>>();
        for(XC_CM_LegalEntity_Configuration__mdt info : legalEntityConfigs.values()) {
            if(String.isNotBlank(info.XC_BusinessLineForNeedInternalCheck__c)) {
                keyBusinessLinesMap.put(info.XC_LegalEntity__c+info.XC_Stream__c, info.XC_BusinessLineForNeedInternalCheck__c.split(';'));
            }
        }

        for(Case c : casesToProcess) {

            if(keyBusinessLinesMap.containsKey(c.XC_LegalEntity__c+c.XC_Segment__c) && keyBusinessLinesMap.get(c.XC_LegalEntity__c+c.XC_Segment__c).contains(c.XC_BusinessLine__c)) {

                c.XC_NeedInternalCheck__c = true;
            }
        }

        return;
    }


    /**
    * setNeedInternalCheckOnUpdate.
    * @author Nicola Mariniello - nmariniello@deloitte.it
    * @param listNew the list new
    * @param mapOld the map Old
    * @param mapNew the map New
    * @description set Need Internal Check field on update
    */
    public static void setNeedInternalCheckOnUpdate(List<Case> listNew, Map<Id,Case> mapOld, Map<Id,Case> mapNew) {

        List<String> fieldList = new List<String> {'XC_BusinessLine__c'};
        List<Case> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew); 
        if(listChanged.isEmpty()) {
            return;
        }

        List<Case> casesToProcess = new List<Case>();
        Set<String> legalEntitySet = new Set<String>();
        Set<String> segmentSet = new Set<String>();
        for(Case c : listChanged) {
            if(String.isNotBlank(c.XC_BusinessLine__c) && String.isNotBlank(c.XC_LegalEntity__c) && String.isNotBlank(c.XC_Segment__c)) {
                casesToProcess.add(c);
                legalEntitySet.add(c.XC_LegalEntity__c);
                segmentSet.add(c.XC_Segment__c);
            }
        }

        if(casesToProcess.isEmpty()) {
            return;
        }
        
        setNeedInternalCheck(casesToProcess, legalEntitySet, segmentSet);
    }

    public static void updateLastQueue(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew){
        List<String> fieldList = new List<String>{'OwnerId'}; 
        List<Case> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        List<Account> accList = new List<Account>();
        if(!listChanged.isEmpty()) {
            Map<Case,String> mapCaseOwner = new Map<Case, String>();
            Map<Case,String> mapCaseOwnerOld = new Map<Case, String>();
            for(Case c : listNew){
                if(c.OwnerId!= null){
                    mapCaseOwner.put(c,c.OwnerId);
                    mapCaseOwnerOld.put(mapOld.get(c.Id),mapOld.get(c.Id).OwnerId);
                }
            }
            System.debug('CaseOwner:' + mapCaseOwner.values());
            System.debug('CaseOwnerOld:' + mapCaseOwnerOld.values());
            if(mapCaseOwner!=null ){
                System.debug('Update LastQueue');
                Map<Id,Group> queues = new Map<Id,Group>([SELECT Id, Name, Type FROM Group WHERE ID IN :mapCaseOwner.values() OR ID IN : mapCaseOwnerOld.values()]);
                //retrive Name, as Object Type Group 
                System.debug('Queues: ' + queues);
                for(Case c : listNew){
                    System.debug('OwnerOld Id: ' + mapCaseOwnerOld.get(c));
                    if(queues.get(mapCaseOwner.get(c))!= null && queues.get(mapCaseOwner.get(c)).Type=='Queue'){
                        System.debug('queue new: ' + queues.get(mapCaseOwner.get(c)).Name );
                        c.XC_LastQueue__c = queues.get(mapCaseOwner.get(c)).Name;
                    }else if(queues.get(mapCaseOwnerOld.get(c))!= null && queues.get(mapCaseOwnerOld.get(c)).Type=='Queue'){
                        c.XC_LastQueue__c = queues.get(mapCaseOwnerOld.get(c)).Name;
                        System.debug('queue new: ' + queues.get(mapCaseOwnerOld.get(c)).Name );
                    }
                    System.debug('*** esco **');
                }
            }
        }
        //NR2450 - 27062022 - Start
        //List<String> fieldPlafond = new List<String>{'XC_Plafond__c'}; 
        //List<Case> listChangedPlafond = XC_UTIL_Sobject.getListChanged(fieldPlafond, mapOld, mapNew);
        //if(!listChangedPlafond.isEmpty()) {
        for(Case c : listNew){
            //system.debug('sara listChangedPlafond: '+listChangedPlafond);
            system.debug('mario listNew: '+listNew);
            String RTCase = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(c.RecordTypeId).getDeveloperName();
            if(RTCase != 'XC_B2B_EnelXItalia_Management_Case')
                continue;
            system.debug('plafond: '+c.XC_Plafond__c);
            system.debug('accountID: '+c.AccountID);
            if(null != c.XC_Plafond__c ){
                Account acc = new Account(Id = c.AccountID, XC_PlafondTechnical__c = c.XC_Plafond__c);
                accList.add(acc);
            }else if(null == c.XC_Plafond__c && c.SubCause__c!=null && c.SubCause__c.equalsIgnoreCase('Azzeramento Plafond')){
                Account acc = new Account(Id = c.AccountID, XC_PlafondTechnical__c = null);
                accList.add(acc);
            }
        }
        //}
        if(!accList.isEmpty()){
            XC_TR_Account_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_Account_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            update accList;   
            XC_TR_Account_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_Account_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false); 
            
            if(!Test.isRunningTest()){
                for(Case c : listNew){
                    system.debug('Plafond old ' +mapOld.get(c.Id).XC_Plafond__c);
            		system.debug('Plafond new ' +mapNew.get(c.Id).XC_Plafond__c);
                    system.debug('Status Old '+mapOld.get(c.Id).Status);
            		system.debug('Status new '+mapNew.get(c.Id).Status);
                    if((mapOld.get(c.Id).Status == 'ESTA001' && mapNew.get(c.Id).Status == 'ESTA003') || (mapOld.get(c.Id).XC_Plafond__c != mapNew.get(c.Id).XC_Plafond__c && mapNew.get(c.Id).Status == 'ESTA003') ){
                        createSendInvoiceToCommodityLog(Json.Serialize(accList),c.XC_LegalEntity__c,c.XC_Segment__c);  
                    }      	    
                }
            }
            
        }
    }
    
    @Future(callout=true)
    public static void createSendInvoiceToCommodityLog(String jsonAccountsList, String legalEntity,String segment ){
        	system.debug('metodo future');
        	ZuoraWebservice zwbs = new ZuoraWebservice(XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity,segment));
        	zwbs.createSendInvoiceToCommodityLog(jsonAccountsList);
            
    }
    //END 2450

    /**
    * @author Denise Avolio - denise.avolio@accenture.com
    * @param listNew the list new
    * @description set Technical Asset on Case - NR2330
    */
    public static void setTechnicalAssetOnCaseB2BG(List<Case> listNew) {
        List<String> segmentList = new List<String>{'B2B','B2G'};
        List<String> legEntItaly = new List<String>{'EnelXItalia','EnelSole'}; 
        List<Case> caseList = new List<Case>();

        for(Case newCase : listNew){
            if('XCMOT002'.equalsIgnoreCase(newCase.Reason) && segmentList.contains(newCase.XC_Segment__c) && 
               'eCity'.equalsIgnoreCase(newCase.XC_BusinessLine__c) && 'Italy'.equalsIgnoreCase(newCase.Country__c) && 
               legEntItaly.contains(newCase.XC_LegalEntity__c) && String.isBlank(newCase.XC_TechnicalAsset__c)){
                caseList.add(newCase);
            }
        }

        if(caseList.isEmpty()){ 
            return;
        }

        List<Id> accIdList = XC_UTIL_Sobject.getListFieldValues(caseList, 'AccountId');
        List<Asset> assetList = [SELECT Id, AccountId 
                                 FROM Asset 
                                 WHERE AccountId IN :accIdList AND 
                                       RecordType.DeveloperName = 'TAM_Network' AND 
                                       Status IN ('Active','Installed') AND
                                       XC_LegalEntity__c IN :legEntItaly];
        if(assetList.isEmpty()){
            return;
        }

        Map<Case,List<Id>> caseAssetMap = new Map<Case,List<Id>>();
        for(Case cs : caseList){
            List<Id> idList = new List<Id>();
            for(Asset ass : assetList){            
                if(ass.AccountId==cs.AccountId){
                    idList.add(ass.Id);
                }
            }
            caseAssetMap.put(cs, idList);
        }

        for(Case cs : caseAssetMap.keySet()){
            if(caseAssetMap.get(cs).size()==1){
                cs.XC_TechnicalAsset__c = caseAssetMap.get(cs).get(0);
            }
        }
    }

}