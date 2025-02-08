/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @date Creation 05/04/2019
* @date Modification 08/04/2019 Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description XC_LCC120_NewCase custom controller for the lightning component XC_LCP120_NewCase.
*/
public  class XC_LCC120_NewCase {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC120_NewCase');

    /**
    * @author dpalamides
    * @date Creation 05/04/2019
    * @description NewCaseQueryDataWrap
    */
    public Class NewCaseQueryDataWrap{
        public String accountId;
        public String contactId;
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to manage CaseRecordType
     * @param caseReason
     * @return XC_UTIL_ResultWrapper
	 */
    /*@AuraEnabled
    public static XC_UTIL_ResultWrapper getCaseRecordType(String caseReason){
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = true;
        wr.resultMessage = 'No recordType found';
        String legalEntity = XC_UTIL_User.getLegalEntityFromUser();
        List<Case> caseList = new List<Case>();
        Case cs = new Case(Reason = caseReason , XC_LegalEntity__c=legalEntity);
        caseList.add(cs);
        Map<String,String> reasonRecordTypeMap = XC_UTIL_Case.getCaseRecordType(caseList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'reasonRecordTypeMap = '+reasonRecordTypeMap);
        List<String> recordTypeList = reasonRecordTypeMap.values();
        if(!recordTypeList.isEmpty()){
            wr.resultMessage = 'Found Record Type Id ' +recordTypeList[0];
            wr.recordId = recordTypeList[0];
        }else{
            wr.recordId = XC_UTIL_Case.getDefaultCaseRecordType(legalEntity);
            wr.resultMessage = 'Found Default Record Type Id '+wr.recordId;
        }
        return checkUserRTAccessibility(wr);
    }*/

    

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description getConfigInformation
     * @param caseReason
     * @return XC_UTIL_ResultWrapper
	 */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper getConfigInformation(String recordId, String sObjectName){
        String accId;
        String segment;
        //List<String> leToSkip = new List<String>{'Codensa','EnelDistribucion','EnelX'};
        Map<Id,Account> accData;
        Map<String,Object> objInfoData = new Map<String,Object>();
        if(sObjectName == 'Account'){
            accId = recordId;
            accData = new Map<Id,Account>([
                SELECT Id, XC_Segment__c //, XC_GiveDataTo_EnelDistribucion__c, XC_GiveDataTo_EnelX__c, XC_GiveDataTo_Codensa__c
                FROM Account WHERE Id = :recordId
            ]);
            if(!accData.isEmpty()){
                /*createOnlyFromPrimaryContact = (String.isBlank(accData.values()[0].XC_Segment__c)) || (accData.values()[0].XC_Segment__c == 'B2C') || 
                                                accData.values()[0].XC_GiveDataTo_EnelDistribucion__c || accData.values()[0].XC_GiveDataTo_EnelX__c || accData.values()[0].XC_GiveDataTo_Codensa__c;*/
                segment = accData.values().XC_Segment__c;                                                
            }
        } else if(sObjectName == 'Asset'){
            Map<Id,Asset> assetsData = new Map<Id,Asset>([
                SELECT Id, AccountId, ContactId, XC_Segment__c, XC_LegalEntity__c, XC_Address__c, 
                       TAM_IsLogical__c, TAM_IsTechnical__c, TAM_CommercialAsset__c, TAM_BusinessLine__c
                  FROM Asset WHERE Id =: recordId
            ]);
            accId = (String)assetsData.values()[0].get('AccountId');
            segment = (String)assetsData.values()[0].get('XC_Segment__c');
            if((Boolean)assetsData.values()[0].get('TAM_IsLogical__c') || (Boolean)assetsData.values()[0].get('TAM_IsTechnical__c')){
                objInfoData.put('accountId',assetsData.values()[0].get('AccountId'));
                objInfoData.put('contactId',assetsData.values()[0].get('ContactId'));
                objInfoData.put('isLogic',assetsData.values()[0].get('TAM_IsLogical__c'));
                objInfoData.put('isTechnical',assetsData.values()[0].get('TAM_IsTechnical__c'));
                objInfoData.put('address',(String)assetsData.values()[0].get('XC_Address__c'));
                objInfoData.put('commercialAsset',(String)assetsData.values()[0].get('TAM_CommercialAsset__c'));
                objInfoData.put('businessLine',(String)assetsData.values()[0].get('TAM_BusinessLine__c'));
            }else{
                objInfoData.put('isLogic',false);
                objInfoData.put('isTechnical',false);
                objInfoData.put('accountId',assetsData.values()[0].get('AccountId'));
                objInfoData.put('contactId',assetsData.values()[0].get('ContactId'));
            }
        } else{
            String query = String.escapeSingleQuotes('SELECT Id, AccountId, XC_Segment__c, XC_LegalEntity__c FROM  ' + sObjectName + ' WHERE Id = :recordId');
            List<SObject> objData = Database.query(query);
            /*createOnlyFromPrimaryContact = (String.isBlank((String)objData[0].get('XC_Segment__c'))) || (objData[0].get('XC_Segment__c') == 'B2C') || 
                                            leToSkip.contains((String)objData[0].get('XC_LegalEntity__c'));*/
            accId = (String)objData[0].get('AccountId');
            segment = (String)objData[0].get('XC_Segment__c');
        }

        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = true;
        Boolean isCommunity = XC_UTIL_Environment.isCommunity();
        objInfoData.put('isCommunity',isCommunity);

        /*********/
        String legalEntity = XC_UTIL_User.getLegalEntityFromUser();
        Map<String, XC_CM_LegalEntity_Configuration__mdt> leMapping = XC_Util_LegalEntityOneOrg.getOrgConfigLegalEntities(new Set<String>{legalEntity}, new Set<String>{segment});
        Boolean createOnlyFromPrimaryContact = leMapping.get(legalEntity+segment)==null || !leMapping.get(legalEntity+segment).XC_ComplexProductActive__c;
        objInfoData.put('onlyPrimaryContact', createOnlyFromPrimaryContact);
        /*********/

        objInfoData.put('segment',segment);
        if(sObjectName == 'Account' && accData != null && !accData.isEmpty()){
            objInfoData.put('accountSegment', accData.values()[0].XC_Segment__c);
        }
        if(!createOnlyFromPrimaryContact){
            objInfoData.put('contactData', selectAvaibleContact(accId));
        }else{
            objInfoData.put('primaryContact', getPrimaryContact(accId));
        }
        wr.objectInfo = JSON.serialize(objInfoData);
        return wr;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description searchContactForAccount
     * @param accountId The selected Account Id
     * @return XC_UTIL_ResultWrapper
	 */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper searchContactForAccount(String accountId){
        return getConfigInformation(accountId, 'Account');
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description getPrimaryContact
     * @param accountId The Account Id
     * @return result List<Contact>
	 */
    private static List<Map<String,String>> getPrimaryContact(String accountId){
        List<Map<String,String>> result = new List<Map<String,String>>();
        Map<Id,Contact> contact = new Map<Id,Contact>([
            SELECT Id, Name FROM Contact WHERE AccountId =: accountId AND XC_PrimaryContact__c = true
        ]);
        
        Map<String,String> contactMap = new Map<String,String>();
        if(!(contact.values()).isEmpty()){
            contactMap.put('key' , contact.values()[0].id);
            contactMap.put('value' , contact.values()[0].Name);
            result.add(contactMap);
        }
        return result;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description Select avaible Contact from Account.
     * @param recordId the Account record id
     * @return data to view From Account (Contacts and Address)
     */
    private static List<Map<String,String>> selectAvaibleContact(String recordId) {
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        Map<String,Object> objData = new Map<String,Object>();

        Map<id, AccountContactRelation> relData = new  Map<id, AccountContactRelation>([
            SELECT Id, ContactId, IsActive, IsDeleted
              FROM AccountContactRelation 
             WHERE AccountId =: recordId
               AND IsActive = true
               AND IsDeleted = false
        ]);

        Set<Id> contactIds = new Set<Id>();
        for(AccountContactRelation rel : relData.values()){
            contactIds.add(rel.ContactId);
        }

        Map<id, Contact> contacts = new  Map<id, Contact>([
            SELECT Id, Name FROM Contact WHERE Id IN: contactIds ORDER BY Name
        ]);
        List<Map<String,String>> contactData = new List<Map<String,String>>();
        Map<String,String> contactMap;
        for(Contact cont : contacts.values()){
            contactMap = new Map<String,String>();
            contactMap.put('key' , cont.id);
            contactMap.put('value' , cont.Name);
            contactData.add(contactMap);
        }
        return contactData;
    }

    /**
     * @author Nicola Mariniello - nmariniello@deloitte.it
     * @description Method to manage CaseRecordType
     * @param caseReason
     * @return XC_UTIL_ResultWrapper
	 */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper getCaseRecordType(String caseReason, String accountSegment, String parentId){

        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = true;
        wr.resultMessage = 'No recordType found';

        String legalEntity = XC_UTIL_User.getLegalEntityFromUser();
        String segment = null;

        String objectType = XC_UTIL_Sobject.getObjectType(parentId);

        if(String.isNotBlank(objectType) && Schema.getGlobalDescribe().get(objectType).newSObject().getSobjectType().getDescribe().fields.getMap().containsKey('XC_Segment__c')) {
            Map<Id, String> segmentMap = XC_SegmentUtilities.getSegmentFromObject(new Set<Id>{parentId}, objectType);
            segment = segmentMap.get(parentId);
        } else if(String.isNotBlank(accountSegment)){
            segment = accountSegment;
        }

        List<Case> caseList = new List<Case>();
        Case cs = new Case(Reason = caseReason , XC_LegalEntity__c = legalEntity, XC_Segment__c = segment);
        caseList.add(cs);
        Map<String,String> reasonRecordTypeMap = XC_UTIL_Case.getCaseRecordType(caseList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'reasonRecordTypeMap = '+reasonRecordTypeMap);
        List<String> recordTypeList = reasonRecordTypeMap.values();
        if(!recordTypeList.isEmpty()){
            wr.resultMessage = 'Found Record Type Id ' +recordTypeList[0];
            wr.recordId = recordTypeList[0];
            wr.rtDevName = Schema.SObjectType.Case.getRecordTypeInfosById().get(recordTypeList[0]).getDeveloperName(); //DeAv 04.07.2022 - NR2330
        }else{
            //wr.recordId = XC_UTIL_Case.getDefaultCaseRecordType(legalEntity);
            Map<String,String> defaultRT = XC_UTIL_Case.getDefaultCaseRecordTypeByMetadata(new Set<String>{legalEntity}, new Set<String>{segment});
            String defRTName;
            if(defaultRT.get(legalEntity + segment) != null){
                defRTName = defaultRT.get(legalEntity + segment);
            }else{
                defRTName = defaultRT.get('master_default');
            }
            System.debug('@@@defRTName'+defRTName);
            wr.recordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(defRTName).getRecordTypeId();
            wr.resultMessage = 'Found Default Record Type Id '+wr.recordId;
            wr.rtDevName = defRTName; //DeAv 04.07.2022 - NR2330
            System.debug('@@@recordId'+wr.recordId);
            System.debug('@@@rtDevName'+wr.rtDevName);
        }
        return checkUserRTAccessibility(wr);
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description Method to get the Related AccountId
     * @param recordId
     * @return XC_UTIL_ResultWrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper getRelatedAccountId(String recordId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'NewCase > RelatedAccountId > for >'+recordId);
        Id objId = recordId;
        String sobjectType = objId.getSObjectType().getDescribe().getName();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'sobjectType >'+sobjectType);

        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        Map<String,Object> objInfoData = new Map<String,Object>();
        Boolean isCommunity = XC_UTIL_Environment.isCommunity();
        objInfoData.put('isCommunity',isCommunity);
        String relAccId;
        String segment;
        if(sobjectType == 'Contact'){
            Set<Id> recordIds = new Set<Id>();
            recordIds.add(recordId);
            Map<Id, String> segmentMap =  XC_SegmentUtilities.getSegmentFromObject( recordIds,  sobjectType);
            //wr.objectInfo = segmentMap.get(recordId);
            segment = segmentMap.get(recordId);
            if(segmentMap.get(recordId) == 'B2C'){
                relAccId = XC_UTIL_Sobject.getFieldValue('Contact', 'AccountId', recordId); 
            }else{
                List<AccountContactRelation> accContactRelationshipList =  new List<AccountContactRelation>();
                if(Schema.sObjectType.AccountContactRelation.isAccessible()){
                    accContactRelationshipList = [Select AccountId, Account.Name from AccountContactRelation where ContactId = : recordId ];
                }
                List<Map<String, String>> relatedAccount = new List<Map<String, String>>();
                for(AccountContactRelation acc : accContactRelationshipList){
                    Map<String, String> accInfo = new Map<String, String>();
                    accInfo.put('key', acc.AccountId);
                    accInfo.put('value', acc.Account.Name);
                    relatedAccount.add(accInfo);
                }
                wr.fieldName = JSON.serialize(relatedAccount);
                wr.success = true;
            }
        }
        if(sobjectType == 'Zuora__ZInvoice__c'){
            //relAccId = XC_UTIL_Sobject.getFieldValue('Zuora__ZInvoice__c', 'Zuora__Account__c', recordId);
            Map<Id,Zuora__ZInvoice__c> zInvoice = new Map<Id,Zuora__ZInvoice__c>([
                SELECT id, Zuora__Account__c, Zuora__Account__r.XC_Segment__c
                  FROM Zuora__ZInvoice__c
                 WHERE Id =: recordId
            ]);
            relAccId = zInvoice.values()[0].Zuora__Account__c;
            segment = zInvoice.values()[0].Zuora__Account__r.XC_Segment__c;
        }
        if(sobjectType == 'project_cloud__Project_Task__c'){
            List<project_cloud__Project_Task__c> listTask = new List<project_cloud__Project_Task__c>();
            listTask =  [select id, project_cloud__Project_Phase__r.project_cloud__Project__r.ccpe_ocp__Account__c, project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Segment__c  from project_cloud__Project_Task__c where id = :recordId];
            relAccId = listTask[0].project_cloud__Project_Phase__r.project_cloud__Project__r.ccpe_ocp__Account__c;
            System.debug('IDAccount--> '+relAccId);
            segment = listTask[0].project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Segment__c;
            //relAccId = XC_UTIL_Sobject.getFieldValue('project_cloud__Project_Task__c', 'Zuora__Account__c', recordId);
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'relAccId='+relAccId);
        if(String.isNotBlank(relAccId)){
            wr.success = true;
            wr.recordId = relAccId;
        }
        objInfoData.put('segment',segment);
        wr.objectInfo = JSON.serialize(objInfoData);
        return wr;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
	 * @date Creation 05/12/2019
     * @description check the user visibility on RT
     * @param caseRTResult
     * @return XC_UTIL_ResultWrapper in input if user has the access on RT, error othewise
     */
    private static XC_UTIL_ResultWrapper checkUserRTAccessibility(XC_UTIL_ResultWrapper caseRTResult){
        System.debug('rtTocheck--> '+caseRTResult.recordId);
        Id rtTocheck = caseRTResult.recordId;

        Schema.RecordTypeInfo rtInfo = Schema.SObjectType.Case.getRecordTypeInfosById().get(rtTocheck);
        if(rtInfo.isAvailable()){
            return caseRTResult;
        }
        //else return error
        XC_UTIL_ResultWrapper errorWr = new XC_UTIL_ResultWrapper();
        errorWr.resultMessage = Label.XC_CL_UserCantCreateCaseRTMess;
        return errorWr;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description Method to get the Invoice AccountId
     * @param zinvoiceId
     * @return XC_UTIL_ResultWrapper
     */
    /*@AuraEnabled
    public static XC_UTIL_ResultWrapper getInvoiceAccountId(String zinvoiceId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'CALL getInvoiceAccountId -> zinvoiceId='+zinvoiceId);
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        String invoiceAccId = XC_UTIL_Sobject.getFieldValue('Zuora__ZInvoice__c', 'Zuora__Account__c', zinvoiceId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'getInvoiceAccountId -> invoiceAccId='+invoiceAccId);
        if(String.isNotBlank(invoiceAccId)){
            wr.success = true;
            wr.recordId = invoiceAccId;
        }
        return wr;
    }*/

    /**
     * @author dpalamides
     * @description Method to get the Related AccountId and ContactId
     * @param recordId
     * @return String
     */
    /*@AuraEnabled
    public static String getRelatedAccountAndContactId(String recordId){
        NewCaseQueryDataWrap resp = new NewCaseQueryDataWrap();

        resp.accountId = XC_UTIL_Sobject.getFieldValue('Asset', 'AccountId', recordId);
        resp.contactId = XC_UTIL_Sobject.getFieldValue('Asset', 'ContactId', recordId);

        return JSON.serialize(resp);
    }*/

    /**
     * @author dpalamides
     * @description Method to get the Related AccountId and ContactId
     * @param recordId
     * @return XC_UTIL_ResultWrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper getCaseSegment(String recordId){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        Map<String,Object> objInfoData = new Map<String,Object>();
        Boolean isCommunity = XC_UTIL_Environment.isCommunity();
        objInfoData.put('isCommunity',isCommunity);

        Set<Id> recordIds = new Set<Id>();
        recordIds.add(recordId);
        Map<Id, String> segmentMap =  XC_SegmentUtilities.getSegmentFromObject( recordIds,  'Case');
        objInfoData.put('segment', segmentMap.get(recordId));
        
        rw.objectInfo = JSON.serialize(objInfoData);
        return rw; // segmentMap.get(recordId);
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description retrieve the info needed for the init 
     * @return XC_UTIL_ResultWrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper getInitInfo(){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        Map<String,Object> objInfoData = new Map<String,Object>();
        Boolean isCommunity = XC_UTIL_Environment.isCommunity();
        objInfoData.put('isCommunity', isCommunity);
        rw.objectInfo = JSON.serialize(objInfoData);
        return rw;
    }

    /**
    * @author Denise Avolio - denise.avolio@accenture.com
    * @description search AccountId from Asset - NR2330
    * @return XC_UTIL_ResultWrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper searchAccountFromAsset(String recordId){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        Map<String,Object> objInfoData = new Map<String,Object>();
        Asset ass = [SELECT Id, AccountId, Account.Name FROM Asset WHERE Id =:recordId LIMIT 1];
        objInfoData.put('accFromAssetId', String.valueOf(ass.AccountId));
        rw.objectInfo = JSON.serialize(objInfoData);
        return rw;
    }

}