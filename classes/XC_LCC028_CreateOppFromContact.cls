/**
 * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
 * @date Creation  10/10/2018
 * @date Modification 11/03/2019 Monica Cutillo - monica.cutillo@nttdata.com
 * @date Modification 25/10/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @description XC_LCC028_CreateOppFromContact – Controller for XC_LCP028_CreateOppFromContact
 */

public without sharing class XC_LCC028_CreateOppFromContact {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC028_CreateOppFromContact');

    /** @description ResultWrapper */
    public class ResultWrapper{
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public String resultMessage;
        @AuraEnabled
        public Contact contact;
        @AuraEnabled
        public Date d;
        @AuraEnabled
        public Boolean documentExists = false;
        @AuraEnabled
        public Boolean isSFMContact = false;
        @AuraEnabled
        public String objectType;
    }

    /** @description CheckOnAccount Result Wrapper */
    private class CheckOnAccount{
        /** @description documentExists check result field */
        Boolean documentExists = false;
        /** @description isAccoutActive heck result field */
        Boolean isAccoutActive = false;
    }

    /**
    * @author Mariateresa Mollica - mariateresa.mollica@accenture.com
    * @description check on Joint Venture Account (R1.1 2022 - NR2459)
    * @param objectType - String
    * @return recordId - String 
     */
	@AuraEnabled
    public static Boolean canCreateOpty(String recordId){
        String sobjectType = XC_UTIL_Sobject_U_Retrieve.getObjectType(recordId);
        Boolean createOpty = true;
        if(sobjectType == 'Account'){
            List<User> u = [SELECT XC_LegalEntities__c, XC_LegalEntity__c FROM User WHERE Id=:UserInfo.getUserId() AND Country__c = 'Italy' LIMIT 1];
            if((null!=u && !u.isEmpty()) && (u[0].XC_LegalEntity__c.equalsIgnoreCase('EnelXEwiva') || (u[0].XC_LegalEntities__c.equalsIgnoreCase('EnelXMobilityHolding;EnelXEwiva')))){
                List<Account> a = [SELECT XC_GiveDatato_EnelXEwiva__c, XC_Segment__c FROM Account WHERE Id=:recordId AND XC_Segment__c='B2B' AND XC_GiveDatato_EnelXEwiva__c=false LIMIT 1];
                if(null!=a && !a.isEmpty()) createOpty = false; 
            } 
        }
        return createOpty;
    }
    
    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description Gets the visible record type
    * @param objectType - String
    * @return List<RecordType>
     */
    @AuraEnabled
    public static List<RecordType> getVisibleRecordType(String objectType,String recordId) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ getVisibleRecordType - objectType = ' + objectType);
        Map<String,RecordType> mapDevNameRT = new Map<String,RecordType>();
        List<RecordType> visibleRecordType = XC_UTIL_SObject_CheckVisibility.getVisibleRecordType(objectType);
        if(!visibleRecordType.isEmpty() && String.isNotBlank(recordId)) {
            String sobjectType = XC_UTIL_Sobject_U_Retrieve.getObjectType(recordId);
            if(sobjectType == 'Contact'){
                String recordType = [SELECT RecordType.Name FROM Contact WHERE Id= : recordId LIMIT 1].RecordType.Name;
                if(recordType.contains('SFM')){
                    return visibleRecordType;
                }
            }
            Map<Id, String> mapIdSegment=XC_SegmentUtilities.getSegmentFromObject(new Set<Id>{recordId},sobjectType);
          
            for(RecordType rt: visibleRecordType) {
                mapDevNameRT.put(rt.DeveloperName,rt);
            }
            Map<Id, XC_CM_LegalEntity_Configuration__mdt> legalEnConfigMap =  new Map<Id, XC_CM_LegalEntity_Configuration__mdt>(
                [SELECT Id, XC_LegalEntity__c, XC_Stream__c, XC_Country__c, XC_RecordType_Opportunity__c, XC_RecordTypeOpportunityBP__c FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_OrgId__c =: UserInfo.getOrganizationId() AND XC_Stream__c IN : mapIdSegment.values()]);
            
            visibleRecordType.clear();
            Map<Id,RecordType> mapRecordTypeSelected = new Map<Id,RecordType>();
            for(XC_CM_LegalEntity_Configuration__mdt metada : legalEnConfigMap.values())  {
                if(mapDevNameRT.containsKey(metada.XC_RecordType_Opportunity__c)) {
                    mapRecordTypeSelected.put(mapDevNameRT.get(metada.XC_RecordType_Opportunity__c).Id,mapDevNameRT.get(metada.XC_RecordType_Opportunity__c));
                }
                if(metada.XC_RecordTypeOpportunityBP__c != null && mapDevNameRT.containsKey(metada.XC_RecordTypeOpportunityBP__c)) {
                    mapRecordTypeSelected.put(mapDevNameRT.get(metada.XC_RecordTypeOpportunityBP__c).Id,mapDevNameRT.get(metada.XC_RecordTypeOpportunityBP__c));
                }
            }


            visibleRecordType.addall(mapRecordTypeSelected.values());


        }
    
        return visibleRecordType;
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description Gets the current contact data
    * @param recordId - String
    * @return ResultWrapper
     */
    @AuraEnabled
    public static ResultWrapper getCurrentContactData(String recordId) {
        ResultWrapper resultWr = new ResultWrapper();
        resultWr.success = true;
        String recordTypeContact = '';
        resultWr.objectType = XC_UTIL_Sobject_U_Retrieve.getObjectType(recordId);
        CheckOnAccount checkResult = checkDocumentOnAccount(recordId, resultWr.objectType); //'Contact'
        resultWr.documentExists = checkResult.documentExists;
        
        String objCountry;
        if(resultWr.objectType == 'Account'){
            if(!checkResult.isAccoutActive){
                resultWr.success = false;
                resultWr.resultMessage = Label.XC_CL_AccountInactiveMess;
                return resultWr;
            }

            objCountry = XC_UTIL_Sobject.getFieldValue('Account','Country__c', recordId);
            resultWr.isSFMContact = false;
            
        } else {
            List<Contact> clist = XC_UTIL_Sobject.selectAllFields(recordId);
            objCountry = clist[0].Country__c;
            resultWr.contact = clist[0];
            recordTypeContact = Schema.SObjectType.Contact.getRecordTypeInfosById().get(clist[0].RecordTypeId).getDeveloperName();
            resultWr.isSFMContact = recordTypeContact.contains('SFM');
        }

        Map<String, Date> closeDateMap = new Map<String, Date>();
        closeDateMap = XC_UTIL_Opportunity.getDefaultCloseDateByCountry(new List<String>{objCountry});
        if(closeDateMap != null) {
            resultWr.d =  closeDateMap.get(objCountry);
        }

        /*List<Contact> clist = XC_UTIL_Sobject.selectAllFields(recordId);
        List<String> countryList = new List<String>();
        countryList.add(clist[0].Country__c);
        Map<String, Date> closeDateMap = new Map<String, Date>();
        closeDateMap = XC_UTIL_Opportunity.getDefaultCloseDateByCountry(countryList);
        resultWr.contact = clist[0];
        recordTypeContact = Schema.SObjectType.Contact.getRecordTypeInfosById().get(clist[0].RecordTypeId).getDeveloperName();
        resultWr.isSFMContact = recordTypeContact.contains('SFM');
        if(closeDateMap != null) {
            resultWr.d =  closeDateMap.get(clist[0].Country__c);
        }*/
        return resultWr;
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @Mod 25/10/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Gets the current contact  from Case
    * @param recordId - String
    * @return ResultWrapper
     */
    @AuraEnabled
    public static ResultWrapper getCurrentContactDataForCase(String recordId) {
        List<Case> c = new List<Case>([
                SELECT Id, ContactId
                FROM Case
                WHERE Id = :recordId]);
        return getCurrentContactData(c[0].ContactId);
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description Gets the contact id
    * @param recordId - String
    * @return XC_UTIL_ResultWrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper getContactId(Id recordId){
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = false;
        String sobjectType = recordId.getSObjectType().getDescribe().getName();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ CreateCase, SobjectType -> ' + sobjectType);

        if(sobjectType == 'Contact'){
            wr.success = true;
            wr.recordId = recordId;
            wr.objectInfo = 'Contact';
            if(isNullVatGroupAndTaxType(recordId)){
                wr.success = false;
                wr.resultMessage = Label.XC_CL_OpportunityErrorVaxType;
            }
        }else if(sobjectType == 'Case'){
            String contactId = XC_UTIL_Sobject.getFieldValue('Case','ContactId', recordId);
            if(contactId != null){
                wr.success = true;
                wr.recordId = contactId;
                wr.objectInfo = 'Case';
            }else{
                wr.success = false;
                wr.resultMessage = Label.XC_CL_NotAllowedWithoutContact;
            }
        }else if(sobjectType == 'WorkOrder'){
            manageWorkOrder(recordId, wr);
        }else if(sobjectType == 'Account'){
            wr.success = true;
            wr.recordId = recordId;
            wr.objectInfo = 'Account';
            if(isNullVatGroupAndTaxType(recordId)){
                wr.success = false;
                wr.resultMessage = Label.XC_CL_OpportunityErrorVaxType;
            }
        }
        return wr;
    }

    /**
    * @description Manage Work Order
    * @param recordId - Id
    * @param wr - XC_UTIL_ResultWrapper
    */
    private static void manageWorkOrder(Id recordId, XC_UTIL_ResultWrapper wr){
        String contactId = XC_UTIL_Sobject.getFieldValue('WorkOrder','ContactId', recordId);
        if(contactId != null){
            if(isWORepair(recordId)){
                wr.success = true;
                wr.recordId = contactId;
                wr.objectInfo = 'WorkOrder';
            }else{
                wr.success = false;
                wr.resultMessage = Label.XC_CL_CreateOppOnlyForWORepair;
            }
        }else{
            wr.success = false;
            wr.resultMessage = Label.XC_CL_NotAllowedWithoutContact;
        }
    }

    /**
    * @description Check if Work Order is a Repair
    * @param recordId - String
    * @return Boolean
    */
    private static Boolean isWORepair(String recordId){
        String workTypeId = XC_UTIL_Sobject.getFieldValue('WorkOrder','WorkTypeId', recordId);
        String workTypeName = XC_UTIL_Sobject.getFieldValue('WorkType','Name', workTypeId);
        return XC_UTIL_WorkType.isRepair(workTypeName);
    }

    /**
    * @description check if document is populated on Account
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 4/11/2019 
    * @param recordId id of record
    * @param sObjectName id of sObject
    * @return CheckOnAccount 
    **/
    private static CheckOnAccount checkDocumentOnAccount(String recordId, String sObjectName) {
        CheckOnAccount result = new CheckOnAccount();
        String query;
        if(sObjectName == 'Account'){
            query = String.escapeSingleQuotes('SELECT ID, XC_Status__c, XC_DocumentCountry__c, IdentityType__c, IdentityNumber__c FROM ACCOUNT WHERE ID = :recordId');
        } else {
            query = String.escapeSingleQuotes('SELECT ID, XC_Status__c, XC_DocumentCountry__c, IdentityType__c, IdentityNumber__c FROM ACCOUNT WHERE ID IN (SELECT AccountId FROM  ' + sObjectName + ' WHERE ID = :recordId)');
        }
        System.debug('Query: ' + query);
        List<Account> accList = Database.query(query);

        //Check Documentation
        List<Account> accountsWithDoc = new List<Account>();
        for(Account acc : accList){
            if(String.isNotBlank(acc.XC_DocumentCountry__c) && String.isNotBlank(acc.IdentityType__c) && String.isNotBlank(acc.IdentityNumber__c)){
                accountsWithDoc.add(acc);
            }
        }
        result.documentExists = !accountsWithDoc.isEmpty();

        //Check Account Inactive
        if(sObjectName == 'Account'){
            if(!accountsWithDoc.isEmpty()){
                result.isAccoutActive = (accountsWithDoc[0].XC_Status__c != 'Inactive');
            }
        }

        return result;

        /*String query;
        if(sObjectName == 'Account'){
            query = String.escapeSingleQuotes('SELECT ID, XC_Status__c FROM ACCOUNT WHERE XC_DocumentCountry__c != NULL AND IdentityType__c != NULL AND IdentityNumber__c != NULL AND ID = :recordId');
        } else {
            query = String.escapeSingleQuotes('SELECT ID FROM ACCOUNT WHERE XC_DocumentCountry__c != NULL AND IdentityType__c != NULL AND IdentityNumber__c != NULL AND ID IN (SELECT AccountId FROM  ' + sObjectName + ' WHERE ID = :recordId)');
        }
        System.debug('Query: ' + query);
        List<Account> accList = Database.query(query);
        return result.documentExists = !accList.isEmpty();*/
    }
    private static Boolean isNullVatGroupAndTaxType(Id recordId){
        Schema.SObjectType objType = recordId.getSObjectType();
        if(objType == Contact.sObjectType){
            List<Contact> objInfo = [SELECT Account.XC_DocumentCountry__c, Account.XC_Segment__c, Account.XC_VatGroupType__c, Account.XC_AccountTaxType__c from Contact WHERE Id =: recordId];
            return !objInfo.isEmpty() && objInfo[0].Account.XC_DocumentCountry__c == 'Italy' && (objInfo[0].Account.XC_Segment__c == 'B2B' || objInfo[0].Account.XC_Segment__c == 'B2G') && (objInfo[0].Account.XC_AccountTaxType__c == null && objInfo[0].Account.XC_VatGroupType__c == null);
        }
        else{
            List<Account> objInfo = [SELECT XC_DocumentCountry__c, XC_Segment__c, XC_VatGroupType__c, XC_AccountTaxType__c from Account WHERE Id =: recordId]; 
            return !objInfo.isEmpty() && objInfo[0].XC_DocumentCountry__c == 'Italy' && (objInfo[0].XC_Segment__c == 'B2B' || objInfo[0].XC_Segment__c == 'B2G') && (objInfo[0].XC_AccountTaxType__c == null && objInfo[0].XC_VatGroupType__c == null);
        }
    }
}