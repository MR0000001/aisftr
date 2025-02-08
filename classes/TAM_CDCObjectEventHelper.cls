/**
* @author Marco Lazzaroni - mlazzaroni@pic-informatica.it
* @date Creation 05/10/2021
* @description TAM_AsyncPublishCDE – Helper class for change data event integration
*/

public class TAM_CDCObjectEventHelper {

    @TestVisible
    private static Set<String> RTNames{
        get{
            if(RTNames == null) {
                initSRs();
            }
            return RTNames;
        }
        set;
    }

    @TestVisible
    private static Set<String> CNames{
        get{
            if(CNames == null) {
                initSRs();
            }
            return CNames;
        }
        set;
    }

    @TestVisible
    private static Set<String> XUNames{
        get{
            if(XUNames == null) {
                initSRs();
            }
            return XUNames;
        }
        set;
    }

    @TestVisible
    private static void initSRs() {
        List<StaticResource> SRs = [SELECT Id, Name, Body FROM StaticResource WHERE Name LIKE 'TAMAsset%EAI'];
        for(StaticResource SR : SRs) {
            Set<String> SRSet = (Set<String>)JSON.deserialize(SR.Body.toString(), Set<String>.class);
            if(SR.Name == 'TAMAssetTypesEAI') RTNames = SRSet;
            if(SR.Name == 'TAMAssetCountriesEAI') CNames = SRSet;
            if(SR.Name == 'TAMAssetUsrExclusionEAI') XUNames = SRSet;
        }
    }

    private static Map<String, RecordType> AssetRTsMap {
        get{
            if(AssetRTsMap == null) {
                AssetRTsMap = new Map<String, RecordType>();
                String devNameFilter = 'TAM\\_%';
                for(RecordType RT: [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Asset' AND DeveloperName LIKE :devNameFilter]) {
                    AssetRTsMap.put(RT.DeveloperName, RT);
                }
            }
            return AssetRTsMap;
        }
        set;
    }

    private static Map<String, RecordType> CaseRTsMap {
        get{
            if(CaseRTsMap == null) {
                for(RecordType RT: [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case']) {
                    CaseRTsMap.put(RT.DeveloperName, RT);
                }
            }
            return CaseRTsMap;
        }
        set;
    }

    public static Set<Id> getEligibleCaseIds (Set<Id> CaseIds) {
        System.debug('Check eligibility for ' + CaseIds.size() + ' case(s)...');
        Map<Id, Case> EligibleCaseMap = new Map<Id, Case>([
                SELECT Id
                FROM Case
                WHERE Id IN: CaseIds
                    AND XC_TechnicalAsset__c != NULL
                    AND XC_TechnicalAsset__r.RecordType.DeveloperName IN: RTNames
                    AND Country__c IN: CNames
                    AND (NOT(LastModifiedBy.Name IN: XUNames))]);
        System.debug('Found ' + EligibleCaseMap.size() + ' eligible case(s).');
        return EligibleCaseMap.keySet();
    }

    public static Map<String, Set<Id>> getEligibleAssetIdsByType (Set<Id> AssetIds) {
        System.debug('Check eligibility for ' + AssetIds.size() + ' asset(s)...');
        List<Asset> aList = [SELECT Id,
                RecordType.DeveloperName
                FROM Asset
                WHERE Id IN: AssetIds
                    AND RecordType.DeveloperName IN: RTNames
                    AND Country__c IN: CNames
                    AND (NOT(LastModifiedBy.Name IN: XUNames))];
        System.debug('Found ' + aList.size() + ' eligible asset(s).');
        Map<String, Set<Id>> AssetIdsByType = new Map<String, Set<Id>>();
        for(Asset a : aList) {
            if(AssetIdsByType.containsKey(a.RecordType.DeveloperName)) {
                AssetIdsByType.get(a.RecordType.DeveloperName).add(a.Id);
            } else {
                AssetIdsByType.put(a.RecordType.DeveloperName, new Set<Id>{a.Id});
            }
        }
        return AssetIdsByType;
    }

    public static Map<String, Set<Id>> getEligibleLocAssets (Set<Id> LocIds) {
        List<Asset> aList = [SELECT Id,
                RecordType.DeveloperName
                FROM Asset
                WHERE LocationId IN :LocIds
                    AND RecordType.DeveloperName IN: RTNames
                    AND Country__c IN: CNames
                    AND (NOT(LastModifiedBy.Name IN: XUNames))];
        Map<String, Set<Id>> AssetIdsByType = new Map<String, Set<Id>>();
        for(Asset a : aList) {
            if(AssetIdsByType.containsKey(a.RecordType.DeveloperName)) {
                AssetIdsByType.get(a.RecordType.DeveloperName).add(a.Id);
            } else {
                AssetIdsByType.put(a.RecordType.DeveloperName, new Set<Id>{a.Id});
            }
        }
        return AssetIdsByType;
    }

    public static List<String> getJSONPayload (String topic, String topicType, Set<Id> recordIds, Map<String, Object> header) {
        System.debug('Creating payload(s) for the following ' + topicType + ' objects:');
        for(Id objId : recordIds) {
            System.debug(objId);
        }
        List<Document> JSONs = [SELECT DeveloperName, Body FROM Document WHERE DeveloperName LIKE :topicType+'%'];
        Map<String, String> queries = new Map<String, String>();
        Map<String, Map<Id, SObject>> qRes = new Map<String, Map<Id, SObject>>();
        String payloadTemplate;
        List<String> payloads = new List<String>();
        Map<String, Blob> docMap = new Map<String, Blob>();
        for(Document doc : JSONs) {
            if(doc.DeveloperName.toLowerCase().endsWith('_queries')) {
                docMap.put('queries', doc.Body);
            }
            if(doc.DeveloperName.toLowerCase().endsWith('_fields')) {
                docMap.put('fields', doc.Body);
            }
            if(doc.DeveloperName.toLowerCase().endsWith('_json')) {
                docMap.put('template', doc.Body);
            }
        }

        //get the template
        if(docMap.containsKey('template')) {
            payloadTemplate = docMap.get('template').toString();
        } else {
            return null;
        }
        //get the fields for which updates must be published
        Set<String> changedFields = new Set<String>();
        if(docMap.containsKey('fields') && !((List<Object>)header.get('changedFields')).isEmpty()) {
            Set<String> fieldSet = (Set<String>)JSON.deserialize(docMap.get('fields').toString(), Set<String>.class);
            for(String field : fieldSet) {
                if(((Set<String>)JSON.deserialize(JSON.serialize(header.get('changedFields')), Set<String>.class)).contains(field)) {
                    changedFields.add(field);
                }
            }
            if(changedFields.isEmpty()) return null;
        }
        //get all data
        if(docMap.containsKey('queries')) {
            queries = (Map<String, String>)JSON.deserialize(docMap.get('queries').toString(), Map<String, String>.class);
            for(String qType : queries.keySet()) {
                String q = queries.get(qType).replace('%Ids%', '(\'' + String.join(new List<Id>(recordIds), '\',\'') + '\')');
                switch on qType {
                    when 'Main' {
                        qRes.put(qType, new Map<Id, SObject>(Database.query(q)));
                    }
                    //get data from standard Asset relationships
                    when else {
                        List<SObject> qResList = Database.query(q);
                        if(!qResList.isEmpty()) {
                            Map<Id, SObject> resMap = new Map<Id, SObject>();
                            for (SObject res : qResList) {
                                resMap.put((Id) res.get('AssetId'), res.getSObject('RelatedAsset'));
                            }
                            if (!resMap.isEmpty()) {
                                qRes.put(qType, resMap);
                            }
                        }
                    }
                }
            }
        } else {
            return null;
        }
        Map<Id, Case> CasesMap;
        if(topic == 'cases') {
            CasesMap = new Map<Id, Case>(
                    [SELECT Id,
                            RecordType.Name,
                            XC_TechnicalAsset__r.RecordType.Name
                            FROM Case
                            WHERE Id IN :recordIds
                    ]
            );
        }

        //merge queries results with JSON template
        SObjectType SObjType;
        switch on topic {
            when 'assets' {
                SObjType = Schema.getGlobalDescribe().get('Asset');
            }
            when 'cases' {
                SObjType = Schema.getGlobalDescribe().get('Case');
            }
            when else {
                return null;
            }
        }
        Map<String, Schema.SObjectField> mfields = SObjType.getDescribe().fields.getMap();
        if(qRes.get('Main').isEmpty()) return null;

        for(Id recordId : recordIds) {
            String payload = payloadTemplate;
            Map<String, Object> fieldMap = qRes.get('Main').get(recordId).getPopulatedFieldsAsMap();

            for (String fieldName : fieldMap.keySet()) {
                String fValue = '"' + String.valueOf(fieldMap.get(fieldName)) + '"';
                if(!mfields.containsKey(fieldName) && !fieldName.contains('Label')) {
                    Map<String, Object> subFieldsMap = qRes.get('Main').get(recordId).getSObject(fieldName).getPopulatedFieldsAsMap();
                    fValue = JSON.serialize(subFieldsMap);
                }
                payload = payload.replace('%' + fieldName + '%', fValue);
            }
            if(qRes.size() > 1) {
                for(String qType : qRes.keySet()) {
                    if(qType != 'Main') {
                        if (qRes.get(qType).containsKey(recordId)) {
                            Map<String, Object> fMap = qRes.get(qType).get(recordId).getPopulatedFieldsAsMap();
                            payload = payload.replace('%' + qType + '%', JSON.serialize(fMap));
                        }
                    }
                }
            }
            if(topic == 'assets') {
                String AssetType = AssetRTsMap.get(topicType).Name;
                if(!String.isEmpty(AssetType)) {
                    payload = payload.replace('%assetType%', '"' + AssetType + '"');
                } else {
                    payload = payload.replace('%assetType%', '"' + topicType + '"');
                }
            }
            if(topic == 'cases' && CasesMap != null) {
                payload = payload.replace('%assetType%', '"' + CasesMap.get(recordId).XC_TechnicalAsset__r.RecordType.Name + '"');
                payload = payload.replace('%caseType%', '"' + CasesMap.get(recordId).RecordType.Name + '"');
            }
            if(header != null) {
                if(changedFields.isEmpty()) {
                    payload = payload.replace('%changedFields%', JSON.serialize(header.get('changedFields')));
                } else {
                    payload = payload.replace('%changedFields%', JSON.serialize(changedFields));
                }
                payload = payload.replace('%changeType%', JSON.serialize(header.get('changeType')));
                payload = payload.replace('%transactionKey%', JSON.serialize(header.get('transactionKey')));
                payload = payload.replace('%commitNumber%', JSON.serialize(header.get('commitNumber')));
                payload = payload.replace('%commitTimestamp%', String.valueOf(header.get('commitTimestamp')));
            }

            //clean non populated fields
            payload = payload.replaceAll('\\%(.*?)\\%', '""');
            payload = payload.replaceAll('\\n', '');		// remove LF
            payload = payload.replaceAll('\\r', '');		// remove CR
            payload = payload.replaceAll('\\t', '');		// remove Tabs

            payloads.add(payload);
        }

        return payloads;
    }

    public static void publishCDEPayload(String topic, List<String> payloads, Map<String, Object> header) {
        XC_Integration_Log__c log = new XC_Integration_Log__c();
        log.XC_Log_IntegrationType__c = 'Outbound';

        String AuthToken = getCacheEAIAuthToken();

        String msgKey = getKey();
        Map<String, List<Map<String, Map<String, Object>>>> msgMap = new Map<String, List<Map<String, Map<String, Object>>>>();
        List<Map<String, Map<String, Object>>> msgList = new List<Map<String, Map<String, Object>>>();
        for(String msg : payloads) {
            msgList.add(new Map<String, Map<String, Object>>{
                    'message' => (Map<String, Object>)JSON.deserializeUntyped(msg)
            });
        }
        msgMap.put('message_list', msgList);
        String message = JSON.serialize(msgMap);

        log.XC_Log_TransactionId__c = (String) header.get('transactionKey');
        log.Name = msgKey;

        String EndPoint = getEPFromNamedCredentials('XC_MasheryAuth', topic);
        log.XC_Log_EndPoint__c = EndPoint;
        log.XC_Log_IntegrationName__c = 'Mashery_KAFKAPublish';
        log.XC_Log_ServerSystem__c = 'Mashery/KAFKA';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(EndPoint);
        req.setMethod('POST');
        log.XC_Log_HTTP_Method__c = 'POST';

        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'bearer ' + AuthToken);
        log.XC_Log_Header__c = JSON.serialize(new Map<String, String>{
                'Content-Type' => req.getHeader('Content-Type'),
                'Authorization' => req.getHeader('Authorization')
        });

        req.setBody(message);
        log.XC_Log_Request__c = message;

        log.XC_Log_TimestampReq__c = String.valueOf(Datetime.now());
        try {
            HttpResponse res = new Http().send(req);
            log.XC_Log_IsSuccess__c = true;
            log.XC_Log_Response__c = res.getBody();
            log.XC_Log_Status__c = res.getStatusCode() + ': ' + res.getStatus();
        } catch (CalloutException e) {
            log.XC_Log_IsSuccess__c = false;
            log.XC_Log_Error__c = e.getMessage();
        } finally {
            log.XC_Log_TimestampResp__c = String.valueOf(Datetime.now());
            log.XC_Log_ClientSystem__c = 'XCustomerB2B/G';
            insert log;
        }

    }

    public static String getCacheEAIAuthToken() {
        Map<String, Object> AuthTokenData = new Map<String, Object>();
        if (Cache.Org.contains('local.TAM.AuthTokenData')) {
            try {
                AuthTokenData = (Map<String, Object>) Cache.Org.get('local.TAM.AuthTokenData');
            } catch(Exception e) {
                Cache.Org.remove('local.TAM.AuthTokenData');
                return getCacheEAIAuthToken();
            }
            if(((Datetime)AuthTokenData.get('IssuedDate')).addSeconds((Integer)AuthTokenData.get('expires_in')) < Datetime.now()) {
                AuthTokenData = getEAIAuthToken();
                Cache.Org.put('local.TAM.AuthTokenData', AuthTokenData);
            }
        } else {
            AuthTokenData = getEAIAuthToken();
            Cache.Org.put('local.TAM.AuthTokenData', AuthTokenData);
        }
        return (String)AuthTokenData.get('access_token');
    }

    public static Map<String, Object> getEAIAuthToken() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:XC_MasheryAuth');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type=client_credentials&client_id={!HTMLENCODE($Credential.Username)}&client_secret={!HTMLENCODE($Credential.Password)}');

        HttpResponse res = new Http().send(req);

        Map<String, Object> body = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        body.put('IssuedDate', Datetime.now());
        return body;
    }

    public static String getEPFromNamedCredentials(String NCName, String topic) {
        NamedCredential NC = [SELECT Endpoint FROM NamedCredential WHERE DeveloperName = :NCName LIMIT 1];
        Url EP = new Url(NC.Endpoint);
        String EndPoint = 'https://' + EP.getHost() + '/services/v1/publish/crm/' + topic;
        return EndPoint;
    }

    public static String getKey() {
        Blob b = Crypto.generateAesKey(128);
        String h = EncodingUtil.convertToHex(b);
        return h.substring(0,8)+ '-' + h.substring(8,12) + '-' + h.substring(12,16) + '-' + h.substring(16,20) + '-' + h.substring(20);
    }

}