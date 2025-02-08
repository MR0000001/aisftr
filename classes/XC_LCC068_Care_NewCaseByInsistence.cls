/**
 *  
 * ===================================================================================.
 *
 * @author           AJJL
 * @version          V0.1
 * @className        XC_LCC068_Care_NewCaseByInsistence
 * @description      Controller from XC_LCP068_Care_NewCaseByInsistence
 * @email            ajimenez@deloitte.es
 * @testClass        N/A
 * @dateCreated      2019/01/09
 * @Modify           Federico Amici [17/01/2019], Changed L61 to use XC_UTIL_SObject.insertRecord() method
 * ==============================================================================================================================
 */
public without sharing class XC_LCC068_Care_NewCaseByInsistence {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC068_Care_NewCaseByInsistence');

    /**
    * @description The Class WrapperDoInit.
    */
    public class WrapperDoInit {
        @AuraEnabled
        public Boolean check = false;
        @AuraEnabled
        public List<Map<String, String>> resolutionPicklistMap = new List<Map<String, String>>();
        @AuraEnabled
        public List<Map<String, String>> resultPicklistMap = new List<Map<String, String>>();
        @AuraEnabled
        public Boolean complaintRTCase = false;
        @AuraEnabled
        public Boolean sameOwner = false;
        @AuraEnabled
        public String caseSubtype;
        @AuraEnabled
        public Boolean isCommunity = false;
        @AuraEnabled
        public Boolean communitySpain = false;
        @AuraEnabled
        public Boolean qualityCheckCase = false;
        @AuraEnabled
        public Boolean createRepairWO = false;
    }

    /**
     * @description Creates the case.
     * @param recordId the record id
     * @return the x C UTI L result wrapper 
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper createCase(Id recordId) {
        XC_UTIL_ResultWrapper newWr = new XC_UTIL_ResultWrapper();
        newWr.success=false;

        String sobjectType = recordId.getSObjectType().getDescribe().getName();
        List<SObject> objectList = populateListSobject(sobjectType, recordId); //recordTypeId
        if(sobjectType == 'Case' && (((Case)objectList[0]).Status == Label.XC_CL_Case_Status007 || ((Case)objectList[0]).Status == Label.XC_CL_Case_Status008)) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Case Status -> ' + ((Case)objectList[0]).Status);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Case By Insistence NOT created!');
            newWr.resultMessage = Label.XC_CL_InsistenceCaseNotCreatedForCaseWrongStatus;
            return newWr; 
        } else if(sobjectType == 'Opportunity' && (((Opportunity)objectList[0]).StageName == Label.XC_CL_Opportunity_ClosedLost || ((Opportunity)objectList[0]).StageName == Label.XC_CL_Opportunity_ClosedWon)) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Opportunity StageName -> ' + ((Opportunity)objectList[0]).StageName);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Case By Insistence NOT created!');
            newWr.resultMessage = Label.XC_CL_InsistenceCaseNotCreatedForOpportunityWrongStatus;
            return newWr; 
        } else if(sobjectType == 'WorkOrder' && (((WorkOrder)objectList[0]).Status == Label.XC_CL_WorkOrder_Canceled || ((WorkOrder)objectList[0]).Status == Label.XC_CL_WorkOrder_Completed || ((WorkOrder)objectList[0]).Status == Label.XC_CL_CannotComplete)) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ WorkOrder Status -> ' + ((WorkOrder)objectList[0]).Status);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Case By Insistence NOT created!');
            newWr.resultMessage = Label.XC_CL_InsistenceCaseNotCreatedForWorkorderWrongStatus;
            return newWr; 
        }

        List<String> caseSettingNames = new List<String>{Label.XC_CL_ComplianCaseSettingsName};
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames); 
        if(caseSettingsMap.isEmpty() || caseSettingsMap.get(Label.XC_CL_ComplianCaseSettingsName)==null){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ No Match on XC_CM_Case_Type_Setting__mdt with settingName='+Label.XC_CL_ComplianCaseSettingsName);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Case By Insistence NOT created!');
            newWr.resultMessage =  String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_ComplianCaseSettingsName});
            return newWr; 
        } 
        
        XC_CM_Case_Type_Setting__mdt caseSettings = caseSettingsMap.get(Label.XC_CL_ComplianCaseSettingsName);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ caseSettings='+caseSettings);
        
        //Id rtWorkOrderXCSpain = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_ESP_WorkOrder).getRecordTypeId(); //XC_AT_Constants.WO_RECORD_TYPE_XC_ATTENTION_ESPANA
        //Id rtOppXCSpain = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_RT_OpportunitySpain).getRecordTypeId(); //XC_AT_Constants.OPP_RECORD_TYPE_XC_ATTENTION_ESPANA
        //Id recordTypeId = CaseDAO.newInstance().getActiveRecordtypeIdByDeveloperName(XC_AT_Constants.CASE_RECORD_TYPE_XC_ATTENTION_ESPANA);
        //Case caso = createCase(recordTypeId,caseSettings);
        Case caso = XC_UTIL_Case.initCaseFromCaseSettings(caseSettings);
        //XC_TR_Case_U_Care.addOriginCase(caso); 

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createCase, sobjectType'+sobjectType); 
        // ====================== Test compliance button on this objects  ============================//
        
        caso = populateCaseFields(objectList, caso, recordId);   
        List<XC_UTIL_Sobject.WrapperResult> wrs = XC_UTIL_DML.insertRecords(new List<Case>{caso});
        XC_UTIL_Sobject.WrapperResult wr = wrs[0];
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Insistence insert RW='+wr);
        if(!wr.success){
            return new XC_UTIL_ResultWrapper(wr);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ new Insistence Case Id='+caso.Id);
  
        newWr = incrementSobjectCounter(objectList,sobjectType,wr);
        if(!newWr.success){
            return newWr;
        } 

        Map<Id,Case> casoListMap = new Map<Id,Case>([SELECT Id,CaseNumber FROM Case WHERE Id =: caso.Id]);
        if(!casoListMap.isEmpty()){
            wr.objectInfo = String.valueOf(casoListMap.values()[0].CaseNumber);
        } 
        
        newWr = new XC_UTIL_ResultWrapper(wr);
        newWr.success = true;
        return newWr;
    }

    /**
    * @description helper method.
    * @param recordTypeId
    * @param caseSettings
    * @return Case
    */
    /*private static Case createCase(Id recordTypeId,XC_CM_Case_Type_Setting__mdt caseSettings){ 
        Case caso = new Case();
        caso.RecordTypeId = recordTypeId;
        caso.Reason = caseSettings.XC_Case_Reason__c;
        caso.SubCause__c = caseSettings.XC_Sub_Cause__c;
        caso.XC_Subtype__c = caseSettings.XC_Sub_Type__c;
        caso.Status = caseSettings.XC_Status__c;
        caso.Priority = caseSettings.XC_Priority__c; 
        return caso; 
    }*/
         
    /**
    * @description incrementSobjectCounter
    * @param objectList
    * @param sobjectType
    * @param wr
    * @return XC_UTIL_ResultWrapper
    */
    private static XC_UTIL_ResultWrapper incrementSobjectCounter(List<SObject> objectList,String sobjectType,XC_UTIL_SObject.WrapperResult wr){
        XC_UTIL_ResultWrapper newWr = new XC_UTIL_ResultWrapper();
        if(wr.success && sobjectType == 'Opportunity'){
            XC_UTIL_SObject.WrapperResult  wrForUpdate = incrementOpportunityCounter((Opportunity)objectList.get(0));
            newWr = new XC_UTIL_ResultWrapper(wrForUpdate); 
            replaceMessageOpportunityCloseDate(newWr);
        }else if(wr.success && sobjectType == 'Case'){
            XC_UTIL_SObject.WrapperResult  wrForUpdate = incrementCaseCounter((Case)objectList.get(0));
            newWr = new XC_UTIL_ResultWrapper(wrForUpdate);
        }else if(wr.success && sobjectType == 'WorkOrder'){
            newWr.success = true;
        }
        return newWr;
    }

    /**
    * @description replaceMessageOpportunityCloseDate
    * @param newWr
    */
    private static void replaceMessageOpportunityCloseDate(XC_UTIL_ResultWrapper newWr){
        if((newWr.resultMessage).contains(Label.XC_CL_Opp_CloseDateMustBe)){
            newWr.resultMessage = Label.XC_CL_Opp_CloseDateMustBe;
        }
    }  

    /**
        * @description helper method for create case.
        * @param sobjectType 
        * @param recordId
        * @return 
        */
    private static List<SObject> populateListSobject(String sobjectType, Id recordId){ //, Id recordTypeId
        Id rtWorkOrderXCSpain = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_ESP_WorkOrder).getRecordTypeId(); //XC_AT_Constants.WO_RECORD_TYPE_XC_ATTENTION_ESPANA
        Id rtOppXCSpain = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_RT_OpportunitySpain).getRecordTypeId(); //XC_AT_Constants.OPP_RECORD_TYPE_XC_ATTENTION_ESPANA
        
        List<SObject> objectList;
        if(sobjectType == 'WorkOrder'){
            Map<Id,SObject> objectListMap  = new Map<Id,SObject>([
                SELECT Id,AccountId,ContactId,Status, XC_ReclamationCounter__c
                FROM WorkOrder WHERE Id =: recordId 
                AND RecordTypeId =: rtWorkOrderXCSpain LIMIT 1]);
            objectList = objectListMap.values();
        }else if(sobjectType == 'Opportunity'){
            Map<Id,SObject> objectListMap  = new Map<Id,SObject>([
                SELECT Id,AccountId,XC_Contact__c,XC_ReclamationCounter__c,StageName  
                FROM Opportunity WHERE Id =: recordId 
                AND RecordTypeId =: rtOppXCSpain LIMIT 1]);
            objectList = objectListMap.values();
        }else if(sobjectType == 'Case'){
            Map<Id,SObject> objectListMap  = new Map<Id,SObject>([
                SELECT Id,AccountId,ContactId,XC_ReclamationCounter__c,Status  
                FROM Case WHERE Id =: recordId LIMIT 1]);
                //AND RecordTypeId =: recordTypeId LIMIT 1]);
            objectList = objectListMap.values();
        }
        return objectList;
    }

    /**
    * @description helper method for create case.
    * @param objectList
    * @param caso 
    * @param recordId 
    * @return Sobject
    */
    private static Case populateCaseFields(List<SObject> objectList, Case caso, Id recordId){  
        String sobjectType = recordId.getSObjectType().getDescribe().getName();
        //Id rtWorkOrderXCSpain = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(XC_AT_Constants.WO_RECORD_TYPE_XC_ATTENTION_ESPANA).getRecordTypeId();
        //Id rtOppXCSpain = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(XC_AT_Constants.OPP_RECORD_TYPE_XC_ATTENTION_ESPANA).getRecordTypeId();
        
        if(objectList == null || objectList.isEmpty()){
            return caso;
        }
        if(sobjectType == 'WorkOrder'){
            WorkOrder wo = (WorkOrder)objectList.get(0);
            caso.XC_WorkOrder__c = wo.Id;
            caso.AccountId=wo.AccountId;
            if(wo.ContactId != null){
                caso.ContactId = wo.ContactId;
            }
            wo.XC_ReclamationCounter__c = wo.XC_ReclamationCounter__c == null ? 1 : wo.XC_ReclamationCounter__c+1;
            XC_UTIL_Sobject.updateRecord(wo);
        }else if(sobjectType == 'Opportunity'){
            Opportunity opp = (Opportunity)objectList.get(0);
            caso.XC_Opportunity__c = opp.Id;
            caso.AccountId=opp.AccountId;
            if(opp.XC_Contact__c != null){
                caso.ContactId = opp.XC_Contact__c;
            }
        }else if(sobjectType == 'Case'){
            Case c = (Case)objectList.get(0);
            caso.ParentId = c.Id;
            caso.AccountId=c.AccountId;
            if(c.ContactId != null){
                caso.ContactId=c.ContactId;
            }
        } 
        return caso;
    }

    /**
    * @description Increment opportunity counter.
    * @param opp the opp
    * @return the x C UTI L S object. wrapper result
    */
    public static XC_UTIL_SObject.WrapperResult incrementOpportunityCounter(Opportunity opp){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'entrato in incrementOpportunityCounter con oppId = '+opp.id);
        if(opp.XC_ReclamationCounter__c==null){
            opp.XC_ReclamationCounter__c=0;
        }
        opp.XC_ReclamationCounter__c++;
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'COUNTER = '+opp.XC_ReclamationCounter__c);
        //return XC_UTIL_SObject.updateRecord(opp);
        List<XC_UTIL_Sobject.WrapperResult> res = XC_UTIL_DML.updateRecords(new List<sObject>{opp});
        return res[0];
    }

    /**
    * @description Increment case counter.
    * @param c the c
    * @return the x C UTI L S object. wrapper result
    */
    public static XC_UTIL_SObject.WrapperResult incrementCaseCounter(Case c){
        if(c.XC_ReclamationCounter__c==null){
            c.XC_ReclamationCounter__c=0;
        }
        c.XC_ReclamationCounter__c++;
        c.Priority = XC_AT_Constants.TRIGGER_PRIORITY_2;
        List<XC_UTIL_Sobject.WrapperResult> res = XC_UTIL_DML.updateRecords(new List<sObject>{c});
        //return XC_UTIL_SObject.updateRecord(c);
        return res[0];
    }

    /**
    * @author Riccardo Cossu riccardo.cossu@nttdata.com  & Roberta Porrega roberta.porrega@nttdata.com 
    * @description   Suspende / Resume Zuora 
    * @param recordId the record id
    * @return the switch util
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper getSwitchUtil(String recordId){ 
        Map<Id,Case> casesMap = new Map<Id,Case>([SELECT AssetId FROM Case WHERE ID =: recordId]);
        List<Case> cases=casesMap.values();
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = false;
        wr.resultMessage = Label.XC_CL_CaseChangeOrderError;
        if(!cases.isEmpty()){
            return XC_LCC085_Suspende_Resume.getSwitchUtil(cases[0].AssetId);            
        }else{
            return wr;
        }
    }

    /**
    * @description Sets the case status cancel.
    *
    * @param recordId the record id
    * @param cancelValues
    * @return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper setCaseStatusCancel(String recordId, String cancelValues){
        Map<String, Object> cancelValuesMap = (Map<String, Object>) JSON.deserializeUntyped(cancelValues);

        Case c = new Case(id = recordId);
        c.Status = XC_AT_Constants.TRIGGER_STATUS_ESTA008;
        c.XC_Resolution__c = (String) cancelValuesMap.get('resolution');
        c.XC_Result__c = (String) cancelValuesMap.get('result');
        c.CaseRemarks__c  = (String) cancelValuesMap.get('caseRemarks');
        XC_UTIL_ResultWrapper newWr = new XC_UTIL_ResultWrapper(XC_UTIL_SObject.updateRecord(c)); 
        return newWr;       
    }

    /**
    * @description Check if Case has Parent Work Order.
    *
    * @param recordId the record id
    * @return the x C UTI L result wrapper
    */
    /*@AuraEnabled
    public static Boolean checkParentWo (String recordId){
        Boolean check = false;
        Map<Id,Case> casesMap = new Map<Id,Case>([SELECT Id, XC_WorkOrder__c
                                                  FROM Case 
                                                  WHERE Id =: recordId]); 
        List<Case> cases=casesMap.values();
        if (cases[0].XC_WorkOrder__c!=null){
            check = true;
        }
        return check;       
    }*/


    /**
    * @description get Case Informations.
    *
    * @param recordId the record id
    * @return the WrapperDoInit
    */
    @AuraEnabled
    public static WrapperDoInit getCaseInformations (String recordId) { 
        
        WrapperDoInit caseInfosMap = new WrapperDoInit();
        //For check community user
        String idUser = UserInfo.getUserId();
        List<User> user = new List<User>([SELECT Id, Country__c FROM User WHERE Id = :idUser  AND Profile.UserLicense.Name = 'Partner Community']);
        if(!user.isEmpty()){
            caseInfosMap.isCommunity = true;
            if(user[0].Country__c.equalsIgnoreCase('Spain')){
                caseInfosMap.communitySpain = true;
            }
        }
        Map<Id,Case> casesMap = new Map<Id,Case>([
            SELECT Id, XC_WorkOrder__c, SubCause__c, XC_Subtype__c, RecordTypeId, RecordType.DeveloperName, OwnerId,
                   Reason, XC_LegalEntity__c, XC_Segment__c
              FROM Case 
             WHERE Id =: recordId]);  
        List<Case> caseList = casesMap.values();
        if (caseList[0].XC_WorkOrder__c != null) {
            caseInfosMap.check = true;
        }

        Map<String,String> familyInfo = XC_UTIL_Case.getCaseRecordTypeFamily(caseList);
        Map<String,XC_CM_LegalEntity_Configuration__mdt> leConfig = XC_Util_LegalEntityOneOrg.getOrgConfigLegalEntities(new Set<String>{caseList[0].XC_LegalEntity__c}, new Set<String>{caseList[0].XC_Segment__c});
        //if(caseList[0].RecordType.DeveloperName == 'XC_ESP_Complaint_Case') {
        if(familyInfo.get(caseList[0].Reason) == 'Complaint' && !(leConfig.get(caseList[0].XC_LegalEntity__c+caseList[0].XC_Segment__c)).XC_DisableManualCreationIndemnification__c){
            caseInfosMap.complaintRTCase = true;
            caseInfosMap.caseSubtype = String.isNotBlank(caseList[0].XC_Subtype__c) ?  caseList[0].XC_Subtype__c : '';
        }

        if(caseList[0].OwnerId== UserInfo.getUserId() ){
            caseInfosMap.sameOwner= true;
        }else{
            caseInfosMap.sameOwner= false;
        }

        caseInfosMap.resolutionPicklistMap.add(new Map<String, String>{'value' => '', 'label' => '--None--'});
        /*XC_UTIL_DependentPicklist.PicklistWrapper mapWrapper = XC_UTIL_DependentPicklist.getDependentPicklist('Case', 'SubCause__c', 'XC_Resolution__c');
        List<Schema.PicklistEntry> picklistResolution = Schema.Case.XC_Resolution__c.getDescribe().getPicklistValues();
        
        //caseInfosMap.resolutionPicklistMap.add(new Map<String, String>{'value' => picklistResolution[16].getValue(), 'label' => picklistResolution[16].getLabel()});
        for(Schema.PicklistEntry pe : picklistResolution) {
            if(pe.isActive() && mapWrapper.pickListMap.get(caseList[0].SubCause__c).contains(pe.getValue())) {
                caseInfosMap.resolutionPicklistMap.add(new Map<String, String>{'value' => pe.getValue(), 'label' => pe.getLabel()});
            }
        }*/
        List<Schema.PicklistEntry> picklistResolution = Schema.Case.XC_Resolution__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry pe : picklistResolution) {
            if(pe.isActive() && pe.getValue() == 'R017') {
                caseInfosMap.resolutionPicklistMap.add(new Map<String, String>{'value' => pe.getValue(), 'label' => pe.getLabel()});
            }
        }


        // SA - 18/01/2021
        // Retrieve Result value from Custom Setting:
        XC_CS_SetAllowedValues__c csValesResolution;
        String nameCS = 'Case_Cancel_'+caseList[0].RecordType.DeveloperName;
        if(nameCS.length() <= 38) {
            csValesResolution = XC_CS_SetAllowedValues__c.getInstance(nameCS);
        }
        if(csValesResolution == null) {
            csValesResolution = XC_CS_SetAllowedValues__c.getInstance('Case_Cancel_DefaultValues');
        }
        List<String> listResolutionValues = csValesResolution.XC_Set_Values__c.split(';');
        List<Schema.PicklistEntry> picklistResult = Schema.Case.XC_Result__c.getDescribe().getPicklistValues();
        List<Map<String, String>> resultActivePicklistValues = new List<Map<String, String>>();
        caseInfosMap.resultPicklistMap.add(new Map<String, String>{'value' => '', 'label' => '--None--'});
        for(Schema.PicklistEntry pe : picklistResult) {
            if(pe.isActive() && listResolutionValues.contains(pe.getValue())) {
                caseInfosMap.resultPicklistMap.add(new Map<String, String>{'value' => pe.getValue(), 'label' => pe.getLabel()});
            }
        }
        List<String> listValueInserted = new List<String>();
        for(Integer i=0; i<caseInfosMap.resultPicklistMap.size(); i++) {
            listValueInserted.add(caseInfosMap.resultPicklistMap[i].get('value'));
        }
        for(String valueToInsert : listResolutionValues) {
            if(!listValueInserted.contains(valueToInsert)) {
                caseInfosMap.resultPicklistMap.add(new Map<String, String>{'value' => valueToInsert, 'label' => valueToInsert});
            }
        }
        //caseInfosMap.resultPicklistMap.addAll(getResultPicklistValues(caseList[0].RecordTypeId, resultActivePicklistValues, 'XC_Result__c'));
        

        
        String nameCaseTypeSetting = 'XC_NoComplianceQualityCheck';
        XC_CM_Case_Type_Setting__mdt cts = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{nameCaseTypeSetting}).get(nameCaseTypeSetting);
        if(caseList[0].Reason == cts.XC_Case_Reason__c && caseList[0].XC_Subtype__c == cts.XC_Sub_Type__c && caseList[0].SubCause__c == cts.XC_Sub_Cause__c){
            caseInfosMap.qualityCheckCase = true;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ MAP -> ' + caseInfosMap);

        //ET - 08/03/2021
        //Create Repair Work Order Button
        Map<String,XC_CM_LegalEntity_Configuration__mdt> legalEntityConfMap = XC_Util_LegalEntityOneOrg.getConfigLegalEntityCaringInfo(new Set<String>{caseList[0].XC_LegalEntity__c}, new Set<String>{caseList[0].XC_Segment__c});
        String keyValue  = caseList[0].XC_LegalEntity__c + caseList[0].XC_Segment__c;
        if(legalEntityConfMap.get(keyValue) != null) {
            caseInfosMap.createRepairWO = legalEntityConfMap.get(keyValue).XC_EnableRepairButtonOnCase__c;
        }
        return caseInfosMap;       
    }


     /**
    * @description get Result Picklist Values.
    *
    * @param objectName the object Name 
    * @param recordTypeId the record type Id
    * @param apiNameField String
    * @return the List<Map<String, String>>
    */
    public static List<Map<String, String>> getActiveValueByRecordType(String objectName, String recordTypeId, String apiNameField){

        HttpRequest reqTok = XC_UTIL_RESTCallout.getTokenRequest();
        Http http = new Http();
        HttpResponse resTok = http.send(reqTok);
        
        Map<String, Object> accessMap = (Map<String, Object>) JSON.deserializeUntyped(resTok.getBody());
        //Endpoint
        String endpoint = getPicklistValuesEndpoint(objectName, recordTypeId, apiNameField);
        //HTTP Request send
        HttpRequest req = getPicklistValuesRequest(accessMap, endpoint);
        System.debug('REQUEST CALLOUT PICKLIST ENDPOINT AFTER : '+ req.getEndpoint());
        HTTPResponse res = http.send(req);

        //Parse response
        List<Map<String, String>> result = new List<Map<String, String>>();
        Map<String,Object> root = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
        if(!root.containsKey('values')){ 
            return result; 
        }

        List<Object> pValues = (List<Object>) root.get('values');
        for(Object pValue : pValues){
            Map<String, Object> pValueMap = (Map<String,Object>) pValue;
            result.add(new Map<String, String>{'value' => ((String)pValueMap.get('value')), 'label' => ((String)pValueMap.get('label'))});
        }

        return result;
    }

    /**
    * @description get Result Picklist Values Request.
    * @param accessMap
    * @param endpoint
    * @return the HttpRequest
    */
    @TestVisible
    private static HttpRequest getPicklistValuesRequest(Map<String, Object> accessMap, String endpoint){
        String tok = String.valueOf(accessMap.get('access_token'));
        String instance_url=String.valueOf(accessMap.get('instance_url'));
        System.debug('ENDPOINTBEFORE: ' + endpoint);
        String s2 =endPoint.substringAfter('/services');
        String finalEndpoint=instance_url+'/services'+s2;
        EncodingUtil.urlEncode(finalEndpoint,'UTF-8');
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + tok); 
        req.setEndpoint(finalEndpoint);
        req.setMethod('GET');
        return req;
    }

    /**
    * @description get Result Picklist Values Endpoint.
    * @param objectName
    * @param recordTypeId
    * @param apiNameField
    * @return the Endpoint
    */
    @TestVisible
    private static String getPicklistValuesEndpoint(String objectName, String recordTypeId, String apiNameField){
        String endpoint = URL.getSalesforceBaseUrl().toExternalForm();
        endpoint += '/services/data/v41.0';
        endpoint += '/ui-api/object-info/{0}/picklist-values/{1}/{2}';
        endpoint = String.format(endpoint, new String[]{objectName, recordTypeId, apiNameField});
        return endpoint;
    }

    /**
    * @description get Result Picklist Values.
    *
    * @param recordTypeId the record type id
    * @param resultActivePicklistValues the list of active values
    * @param apiNameField String
    * @return the List<Map<String, String>>
    */
    @AuraEnabled
    public static List<Map<String, String>> getResultPicklistValues(String recordTypeId, List<Map<String, String>> resultActivePicklistValues, String apiNameField) {
        List<Map<String, String>> result = getActiveValueByRecordType('Case', recordTypeId, apiNameField);
        return checkResultPicklistValues(resultActivePicklistValues, result);
    }

    /**
    * @description Check Picklist Values.
    * @param resultActivePicklistValues the list of active values
    * @param activeValues 
    * @return the List<Map<String, String>>
    */
    public static List<Map<String, String>> checkResultPicklistValues(List<Map<String, String>> resultActivePicklistValues, List<Map<String, String>> activeValues){
        List<Map<String, String>> resultPicklistValues = new List<Map<String, String>>();
        for(Map<String, String> elementAll : resultActivePicklistValues) {
            Boolean found = false;
            for(Map<String, String> element : activeValues) {
                if(element.get('value') == elementAll.get('value')) {
                    found = true;
                    break;
                }
            }
         
            if(!found) {
                resultPicklistValues.add(elementAll);
            }
        }
        
        return resultPicklistValues;
    }

    /**
    * @description Verify Primary Contact.
    *
    * @param caseId the caseId
    * @return XC_UTIL_ResultWrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkPrimaryContact(String caseId) {
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        List<Case> caseList = new List<Case>([SELECT Id, Reason, SubCause__c, XC_Subtype__c, XC_Segment__c, CreatedDate, ContactId, Contact.XC_PrimaryContact__c, Contact.AccountId, AccountId, XC_LegalEntity__c, AssetId FROM Case WHERE Id=: caseId LIMIT 1]);
        if(!caseList.isEmpty() && caseList[0].Contact.XC_PrimaryContact__c && caseList[0].AccountId != null && caseList[0].AccountId == caseList[0].Contact.AccountId || checkPrimaryContactB2BG(caseList)){
            resWrapper.success = true;
            resWrapper.isValid = checkWorkOrder(caseList[0]); //check for the NR0769
        }else{
            resWrapper.success = false;
            resWrapper.resultMessage = label.XC_CL_OnlyPrimaryContact;
        }
        return resWrapper;
    }

    /**
     * @author Giulia Sciammarella gsciammarella@deloitte.it
     * @description NR0769: check if the asset related to case has at least one work orders with specific fields value
     * @param cInit the case to disconnect 
     * @return true if a work order was found 
     * 
	*/
    @TestVisible
 	private static boolean checkWorkOrder(Case cInit) {
    	if(cInit.Reason !='XCMOT009' || cInit.SubCause__c !='ATCL194'|| cInit.XC_Subtype__c !='XC165' || cInit.AssetId == null || cInit.XC_Segment__c  != 'B2C' ){                
            return false;      
        }
     	List<WorkOrder> wo = [select id ,XC_WorkTypeCategory__c,Status, AssetId , createdDate 
                              from WorkOrder 
                              where Status ='Completed'
                           	  and XC_WorkTypeCategory__c ='Planned Maintenance' 
                              and AssetId =: cInit.assetId  ];
     	Date firstDate = (cInit.CreatedDate).Date();
     	
     	for(WorkOrder wo1 : wo){         
            if(wo1.CreatedDate.Date().monthsBetween(firstDate) <=12){
                return true;
            }
     	}
     	
        return false;
 	}
    
     //20211118_DD_ERR_02 - start
    /**
    * @description Verify Subscription status.
    *
    * @param caseId the caseId
    * @return XC_UTIL_ResultWrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkSubscriptionAsset(String caseId) {
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        List<Case> caseList = new List<Case>([SELECT Id, AssetId, Asset.Status, Asset.XC_SubscriptionName__c 
                                              FROM Case 
                                              WHERE Id=: caseId 
                                              LIMIT 1]);
        resWrapper.success = true;
        if(!caseList.isEmpty() && String.isNotBlank(caseList[0].AssetId)){
            if(String.isBlank(caseList[0].Asset.XC_SubscriptionName__c)){
                resWrapper.success = false;
                resWrapper.resultMessage = Label.XC_CL_LCC068_SubscriptionBlank;
            }else{
                Zuora__Subscription__c sub = XC_IN031_DeactivateAutomaticRenewal_D.getSubscription(caseList[0].Asset.XC_SubscriptionName__c);
                if(sub.Zuora__Status__c == 'Suspended' || caseList[0].Asset.Status == Label.XC_CL_Asset_StatusSuspended){
                	resWrapper.success = false;
                	resWrapper.resultMessage = Label.XC_CL_LCC068_SubscriptionOrAssetSuspended;
                }
            }
        }
        return resWrapper;
    }
	//20211118_DD_ERR_02 - end


    /**
    * @description documentVerification
    * @author Del Prete Domenico | 5/8/2019
    * @param recordId - Id
    * @return XC_LCC139_DocumentVerification.ResultWrapper
    */
    @AuraEnabled
    public static XC_LCC139_DocumentVerification.ResultWrapper documentVerification (Id recordId){
        XC_LCC139_DocumentVerification.ResultWrapper  rw = XC_LCC139_DocumentVerification.documentVerification(recordId);
        return rw;
    }

    /**
    * @description
    * @author Anna Maria Rosanova | 5/8/2019
    * @param recordId - Id
    * @return XC_LCC140_BackCompliance.ResultWrapper
    */
    @AuraEnabled
    public static XC_LCC139_DocumentVerification.ResultWrapper backCompliance (Id recordId){
        XC_LCC139_DocumentVerification.ResultWrapper  rw = XC_LCC140_BackCompliance.backCompliance(recordId);
        return rw;
    }
    
    /**
    * @description Method to recalculate urgency
    * @author Massimiliano Avallone | 25/09/2019
    * @param recordId - Id
    * @return XC_LCC140_BackCompliance.ResultWrapper
    */
    @AuraEnabled
    public static XC_LCC157_RecalculateUrgency.ResultWrapper updateStatus(Id recordId) {
        //XC_LCC157_RecalculateUrgency.ResultWrapper  rw = XC_LCC157_RecalculateUrgency.updateStatus(recordId);
        //return rw;
        return XC_LCC157_RecalculateUrgency.cancelWO(recordId); 
    }

    /**
    * @description Method to create new WO for recalculate urgency
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 26/03/2021
    * @param cs - Case
    * @return XC_LCC140_BackCompliance.ResultWrapper
    */
    @AuraEnabled
    public static XC_LCC157_RecalculateUrgency.ResultWrapper createWorkOrder(String caseId) {
        //XC_LCC157_RecalculateUrgency.ResultWrapper  rw = XC_LCC157_RecalculateUrgency.createWorkOrder(cs);
        XC_LCC157_RecalculateUrgency.ResultWrapper  rw = XC_LCC157_RecalculateUrgency.createNewWoRepair(caseId);
        return rw;
    }
    
    /**
    * @description 
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 20/12/2019 
    * @param recordId 
    * @return Boolean 
    **/
    @AuraEnabled
    public static XC_UTIL_ResultWrapper suspendActionAsset(Id recordId){

        XC_UTIL_ResultWrapper wrapper = new XC_UTIL_ResultWrapper();
        Map<String, Map<String, String>> mapToPopulateWrapper = new Map<String, Map<String, String>>();
    
        Map<Id,Case> cMap = new Map<Id,Case>([
            SELECT AccountId, Account.XC_SohoType__c, ContactId, Contact.Name, Contact.Email, Contact.XC_Preferredlanguageofcontact__c, XC_LegalEntity__c,
                   Reason, XC_Subtype__c, XC_Invoice__c, XC_Invoice__r.Zuora__External_Id__c, XC_Segment__c
            FROM Case
            WHERE id =: recordId 
        ]);

        String invoice = cMap.values()[0].XC_Invoice__c;
        
        List<Asset> assetListToUpdate = XC_UTIL_Asset.getAssetsFromInvoice(invoice).values();
        List<Id> assetListToUpdateIds = XC_UTIL_Sobject.getIds(assetListToUpdate);
        if(assetListToUpdate.isEmpty()){
            wrapper.resultMessage = Label.XC_CL_TherearenoAssetforthesubscription;
            wrapper.success = false;
            return wrapper;
        }

        for (Asset a : assetListToUpdate) {
            if(!((!String.isBlank(a.NE__Bundle_Configuration__c)||a.XC_Product_Type__c == 'Bundle')&&a.XC_BillingModel__c.contains('renting')) && String.isNotBlank(a.XC_Subscription__r.Zuora__External_Id__c)) { 
                mapToPopulateWrapper.put(a.XC_Subscription__r.Zuora__External_Id__c, new Map<String, String>{'legalEntity' => a.XC_LegalEntity__c, 'subNumber' => a.XC_Subscription__r.Zuora__SubscriptionNumber__c});
            }
            a.Status = Label.XC_CL_Asset_StatusSuspended;
        }

        Map<Id,Asset> childAssetMap = new Map<Id, Asset>([
            SELECT Id, Status
            FROM Asset
            WHERE NE__Root_Order_Item__c IN: assetListToUpdateIds
        ]);
        if(!childAssetMap.values().isEmpty()){
            for(Asset a : childAssetMap.values()){
                a.Status = Label.XC_CL_Asset_StatusSuspended;
                if(!assetListToUpdate.contains(a)){
                    assetListToUpdate.add(a);
                }
            }
        }

        if(!mapToPopulateWrapper.isEmpty()){
            System.enqueueJob(new SuspendSubscription (mapToPopulateWrapper, cMap.values()[0], assetListToUpdate[0].NE__ProdId__c));
        }
            

        List<XC_UTIL_Sobject.WrapperResult> wrList = XC_UTIL_Sobject.updateListRecords(assetListToUpdate);
        for (XC_UTIL_Sobject.WrapperResult wr : wrList) {
            if(!wr.success){
                wrapper.success = false;
                wrapper.resultMessage = wr.errorMessage;
                return wrapper;
            }
        }
        
        return new XC_UTIL_ResultWrapper(true); 
    }


    public class SuspendSubscription implements Queueable, Database.AllowsCallouts {
    
        Map<String, Map<String, String>> mapToPopulateWrapper = new Map<String, Map<String, String>>();
        Case c = new Case();
        String prodId = '';


        public SuspendSubscription(Map<String, Map<String, String>> mapToPopulateWrapper, Case c, String prodId) {
            this.mapToPopulateWrapper = mapToPopulateWrapper;
            this.c = c;
            this.prodId = prodId;
        }
        

        public void execute(QueueableContext context) {

            String subNumbers = '';
            List<XC_Integration_Log__c> integrationLogToInsert = new List<XC_Integration_Log__c>();

            for (String subscription : mapToPopulateWrapper.keySet()) {
                XC_REST_SuspendSubscription.WrapperRequest wr = new XC_REST_SuspendSubscription.WrapperRequest();
                wr.legalEntity = mapToPopulateWrapper.get(subscription).get('legalEntity');
                wr.stream = c.XC_Segment__c;
                wr.suspendPolicy = 'Today';
                XC_REST_SuspendSubscription.WrapperResponse wrRes = XC_REST_SuspendSubscription.suspendSubscription(subscription, wr);
                if(wrRes != null) { 
                    if(wrRes.integrationLog != null) { //se l'interfaccia è inactive nn ci sono log
                        integrationLogToInsert.addAll(wrRes.integrationLog);
                    }
                    if(wrRes.success) {
                        subNumbers = subNumbers + mapToPopulateWrapper.get(subscription).get('subNumber') + ',';
                    }
                }
            }

            if(!integrationLogToInsert.isEmpty()){
                XC_UTIL_Sobject.insertListRecords(integrationLogToInsert);
            }

            if(String.isBlank(subNumbers)) {
                return;
            }


            /*_____________________CREATE CUSTOMER INTERACTION_____________________*/
            String businessLine = 'eHome';
            if(c.Reason == 'XCMOT015' && c.XC_Subtype__c == 'XC026') {
                businessLine = 'eMobility';
            } else if (c.Account.XC_SohoType__c == 'B2B') {
                businessLine = 'eIndustry';
            } else if (c.Account.XC_SohoType__c == 'Public Administrations') {
                businessLine = 'eCity';
            }

            List<Map<String,Object>> interactions = new List<Map<String,Object>>();
            Map<String,Object> data = new Map<String,Object>();
            data.put('customerType', Label.XC_CL_ConfirmSuspension);
            data.put('skipComunication', false);
            data.put('preferredlanguage', c.Contact.XC_Preferredlanguageofcontact__c);
            data.put('accountId', c.AccountId);
            data.put('contactId', c.ContactId);
            data.put('fullName', c.Contact.Name);
            data.put('email', c.Contact.Email);
            data.put('legalEntity', c.XC_LegalEntity__c);
            data.put('productId', prodId);
            data.put('invoice', c.XC_Invoice__r.Zuora__External_Id__c);
            data.put('subscription', subNumbers.removeEnd(','));
            data.put('businessLine', businessLine);
            data.put('sent', false);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Data CI --> ' + data);
            interactions.add(data);
            XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromCases(interactions);
        }
    }

    private static Boolean checkPrimaryContactB2BG(List<Case> caseList){
        Boolean check = false;
        Set<String> segmenet = new Set<String>{'B2B','B2G'};
        Set<String> legalEntity = new Set<String>{'EnelXItalia','EnelXMobilityItalia','Cogenio','EnelSole'};
        if(!caseList.isEmpty() && legalEntity.contains(caseList[0].XC_LegalEntity__c) && segmenet.contains(caseList[0].XC_Segment__c) && caseList[0].AccountId != null && caseList[0].AccountId == caseList[0].Contact.AccountId){
            check = true;
        }
        return check;
    }

        /**
    * @description quality Check Method
    * @author Salvatore Scarpato | 14/12/2020
    * @param recordId - Id
    * @return XC_UTIL_ResultWrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper qualityCheckUpdate (Id recordId){
        List<Case> caseList = new List<Case>([SELECT id, XC_CheckList__c FROM Case WHERE Id =: recordId]);
        XC_B2BG_QualityCheck__c qualityCheck = new XC_B2BG_QualityCheck__c (Id = caseList[0].XC_CheckList__c);
        qualityCheck.XC_Status__c = 'In modification (controller)';      
        XC_UTIL_ResultWrapper newWr = new XC_UTIL_ResultWrapper(XC_UTIL_SObject.updateRecord(qualityCheck)); 
        XC_UTIL_Entitlement.completeMilestone(new List<Case>{new Case(Id = recordId)}, 'XC_ITA_QualityCheck', System.now());
        return newWr;
    }
     /**
     * @description Creates the case.
     * @param recordId the record id
     * @return isB2BItaly 
     */
    @AuraEnabled
    public static boolean checkItaly(Id recordId){
       boolean isB2BGItaly=true;
        case c=[select id,XC_LegalEntity__c,XC_Segment__c,Country__c 
              from case 
              where id=:recordId]; 
      if( 
          (c.XC_LegalEntity__c=='EnelXItalia'           ||
            c.XC_LegalEntity__c=='EnelXMSP'             ||
            c.XC_LegalEntity__c=='Cogenio'              ||
            c.XC_LegalEntity__c=='EnelSole'             ||
            c.XC_LegalEntity__c=='YouSaveSpA'           ||
            c.XC_LegalEntity__c=='ESCoComuniSrl'        ||
            c.XC_LegalEntity__c=='EnelXMobility'        ||
            c.XC_LegalEntity__c=='EnelXMobilityItalia'  ||
            c.XC_LegalEntity__c=='EnelXMobilityHolding'

         ) &&
         (
             c.XC_Segment__c=='B2B' ||
             c.XC_Segment__c=='B2G'
         )
       ){
           isB2BGItaly=false;
       }
       return isB2BGItaly;        
    }
}