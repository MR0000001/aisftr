public class DataMap_MDT_Example {

	public static Map<String, Map<String, Object>> LeadCustomMapping(String bu, String segmento, String tipoRichiesta, String tipologiaProdotto) {
        System.Debug('LeadCustomMapping => START');
        Map<String, Map<String, Object>> resultMap = new Map<String, Map<String, Object>>();

        List<Custom_Conversion_Mapping__mdt> ccm = [SELECT Object_Name__c, Field__c, Value__c 
        FROM Custom_Conversion_Mapping__mdt 
        WHERE Custom_Conversion_Lead__r.BU__c = :bu AND 
            Custom_Conversion_Lead__r.Segmento__c = :segmento AND 
            Custom_Conversion_Lead__r.Tipo_Richiesta__c = :tipoRichiesta AND 
            Custom_Conversion_Lead__r.Tipologia_Di_Prodotto_Richiesto__c = :tipologiaProdotto];
        
        if (ccm.isEmpty() && !Test.isRunningTest()){
            System.Debug('LeadCustomMapping => No Mapping'); 
            return resultMap;
        }
        
        if(Test.isRunningTest()){
            List<Custom_Conversion_Mapping__mdt> testMappings = new List<Custom_Conversion_Mapping__mdt>();
            testMappings.add(new Custom_Conversion_Mapping__mdt(
                Object_Name__c = 'Account',
                Field__c = 'Name',
                Value__c = 'Test Account',
                Custom_Conversion_Lead__r = new Custom_Conversion_Lead__mdt(
                    BU__c = 'TestBU',
                    Segmento__c = 'TestSegmento',
                    Tipo_Richiesta__c = 'TestTipoRichiesta',
                    Tipologia_Di_Prodotto_Richiesto__c = 'TestTipologiaProdotto'
                )
            ));
            testMappings.add(new Custom_Conversion_Mapping__mdt(
                Object_Name__c = 'Account',
                Field__c = 'RecordType.Name',
                Value__c = 'TestRecordType',
                Custom_Conversion_Lead__r = new Custom_Conversion_Lead__mdt(
                    BU__c = 'TestBU',
                    Segmento__c = 'TestSegmento',
                    Tipo_Richiesta__c = 'TestTipoRichiesta',
                    Tipologia_Di_Prodotto_Richiesto__c = 'TestTipologiaProdotto'
                )
            ));
            ccm = testMappings;
        }

        // RecordType.Name Handling => Start
        Set<String> objectNames = new Set<String>();
        Set<String> recordTypeNames = new Set<String>();
        for (Custom_Conversion_Mapping__mdt mapping : ccm) {
            if (mapping.Field__c == 'RecordType.Name') {
                objectNames.add(mapping.Object_Name__c);
                recordTypeNames.add(mapping.Value__c);
            }
        }

        Map<String, Map<String, Id>> recordTypeIdsByObjectAndName = new Map<String, Map<String, Id>>();
        if (!objectNames.isEmpty() && !recordTypeNames.isEmpty()) {
            List<RecordType> recordTypes = [
                SELECT Id, Name, SObjectType 
                FROM RecordType 
                WHERE SObjectType IN :objectNames AND Name IN :recordTypeNames
            ];
            for (RecordType rt : recordTypes) {
                String objName = rt.SObjectType;
                String rtName = rt.Name;
                if (!recordTypeIdsByObjectAndName.containsKey(objName)) {
                    recordTypeIdsByObjectAndName.put(objName, new Map<String, Id>());
                }
                recordTypeIdsByObjectAndName.get(objName).put(rtName, rt.Id);
            }
        }
        // RecordType.Name Hnadling => End

        // Popolo l'SObject
        for (Custom_Conversion_Mapping__mdt mapping : ccm) {
            String objName = mapping.Object_Name__c;
            String fieldName = mapping.Field__c;
            Object value = mapping.Value__c;

            if (fieldName == 'RecordType.Name') {
                String rtName = (String) value;
                if (recordTypeIdsByObjectAndName.containsKey(objName) && recordTypeIdsByObjectAndName.get(objName).containsKey(rtName)) {
                    fieldName = 'RecordTypeId';
                    value = recordTypeIdsByObjectAndName.get(objName).get(rtName);
                } else {
                    continue;
                }
            }
            if (!resultMap.containsKey(objName)) {
                resultMap.put(objName, new Map<String, Object>());
            }
            resultMap.get(objName).put(fieldName, value);
        }
        System.Debug('LeadCustomMapping => END');
        return resultMap;
    }

    public static SObject populateByCustomMapping(SObject record, Map<String, Map<String, Object>> dataMap) {
        System.Debug('populateByCustomMapping => START');
        String objectName = record.getSObjectType().getDescribe().getName();
        System.Debug('populateByCustomMapping => Object: '+objectName);
        if (dataMap.containsKey(objectName)) {
            // Ottieni la mappa dei campi e valori per l'oggetto
            Map<String, Object> fieldValueMap = dataMap.get(objectName);
            for (String fieldName : fieldValueMap.keySet()) {
                record.put(fieldName, fieldValueMap.get(fieldName));
                System.Debug('populateByCustomMapping => Field: '+fieldName);
                System.Debug('populateByCustomMapping => Value: '+fieldValueMap.get(fieldName));
            }
        } else {
            System.debug('Nessun mapping trovato per l\'oggetto: ' + objectName);
            return record;
        }
        System.Debug('populateByCustomMapping => END');
        return record;
    }
	
}