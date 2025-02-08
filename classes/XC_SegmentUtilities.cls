public class XC_SegmentUtilities {
    
    public static final String ERROR_MESSAGE = 'No configuration found';
	
    public static String getParentSegment(String recordId, String lookupField) {
        lookupField = lookupField.replace('__c', '__r');
        String objectName = XC_UTIL_Sobject_U_Retrieve.getObjectType(recordId);
        String query = 'SELECT ' + lookupField + '.XC_Segment__c FROM ' + objectName + ' WHERE Id = :recordId';
		SObject target = Database.query(query);
        return (String)target.getSObject(lookupField).get('XC_Segment__c');
    }

    public static RTConfigWrapper getLegEntityConfig(String childRecordId, String lookupField, String orgId, String legalEntity) {
        String parentSegment = getParentSegment(childRecordId, lookupField);
        XC_CM_LegalEntity_Configuration__mdt[] config = [
            SELECT XC_RecordType_WorkOrder__c, XC_RecordType_Opportunity__c, XC_RecordType_Contract__c, XC_Country__c, XC_LegalEntityOverrideForLogistic__c 
            FROM XC_CM_LegalEntity_Configuration__mdt 
            WHERE XC_OrgId__c = :orgId AND XC_LegalEntity__c = :legalEntity AND XC_Stream__c = :parentSegment
        ];

        if (config.size() > 0) {
            return new RTConfigWrapper(config[0].XC_RecordType_WorkOrder__c, config[0].XC_RecordType_Opportunity__c, config[0].XC_RecordType_Contract__c, config[0].XC_Country__c);
        } else {
            throw new NoConfigException(ERROR_MESSAGE);
        }
    }
    

    /**
     * @author Nicola Mariniello - nmariniello@deloitte.it 
     * @date Creation 21/04/2020
     * @date Modification dd/mm/yyyy
     * @description Get the Record type for legal entity e stream
     * @param recordIds - the record Ids Set
     * @param apiNameObject - the api Name of the ObjectObject
     * @return the Map with the object id as key and Segment as value
     */
    public static Map<Id, String> getSegmentFromObject(Set<Id> recordIds, String apiNameObject) {
        
        Map<Id, String> objectIdStreamMap = new Map<Id, String>();
        if(recordIds.isEmpty()) {
            return objectIdStreamMap;
        }

        String query = 'SELECT Id, XC_Segment__c FROM ' + apiNameObject + ' WHERE Id IN :recordIds';
		List<SObject> target = Database.query(String.escapeSingleQuotes(query));

        for(SObject obj : target) {
            objectIdStreamMap.put(obj.Id, (String)obj.get('XC_Segment__c'));
        }

        return objectIdStreamMap;
    }


    /**
     * @author Nicola Mariniello - nmariniello@deloitte.it 
     * @date Creation 21/04/2020
     * @date Modification dd/mm/yyyy
     * @description Get the Record type for legal entity e stream
     * @param legalEntitySet - the legal Entity Set
     * @param streamSet - the stream Set
     * @return the Map with LE+STREAM as key and RTConfigWrapper as value
     */
    public static Map<String, RTConfigWrapper> getLegEntityConfig(Set<String> legalEntitySet, Set<String> streamSet) {

        Map<String, RTConfigWrapper> recordTypesMap = new Map<String, RTConfigWrapper>();
        if(legalEntitySet.isEmpty() || streamSet.isEmpty()) {
            return recordTypesMap;
        }

        Map<Id, XC_CM_LegalEntity_Configuration__mdt> legalEnConfigMap = 
            new Map<Id, XC_CM_LegalEntity_Configuration__mdt>([SELECT Id, XC_LegalEntity__c, XC_Stream__c, XC_Country__c, XC_RecordType_Opportunity__c, XC_RecordTypeOpportunityBP__c,
                                                                    XC_RecordType_Contract__c, XC_RecordType_WorkOrder__c, XC_LegalEntityOverrideForLogistic__c
                                                                FROM XC_CM_LegalEntity_Configuration__mdt
                                                                WHERE XC_OrgId__c =: UserInfo.getOrganizationId() AND 
                                                                    XC_LegalEntity__c IN :legalEntitySet AND XC_Stream__c IN :streamSet]);

        for(XC_CM_LegalEntity_Configuration__mdt legalEnConfig : legalEnConfigMap.values()) {
            recordTypesMap.put(legalEnConfig.XC_LegalEntity__c+legalEnConfig.XC_Stream__c,
                                new RTConfigWrapper(legalEnConfig.XC_RecordType_WorkOrder__c, legalEnConfig.XC_RecordType_Opportunity__c, legalEnConfig.XC_RecordType_Contract__c, legalEnConfig.XC_Country__c, legalEnConfig.XC_RecordTypeOpportunityBP__c, legalEnConfig.XC_LegalEntityOverrideForLogistic__c));
        }

        return recordTypesMap;
    }


    public class RTConfigWrapper {
        public String workOrderRT;
        public String opportunityRT;
        public String contractRT;
        public String country;
        public String opportunityRTBP;
        public string legalEntityOverrideForLogistic;

        public RTConfigWrapper(String workOrderRT, String opportunityRT, String contractRT, String country) {
            this.workOrderRT = workOrderRT;
            this.opportunityRT = opportunityRT;
            this.contractRT = contractRT;
            this.country = country;
        }
        public RTConfigWrapper(String workOrderRT, String opportunityRT, String contractRT, String country, String opportunityRTBP) {
            this.workOrderRT = workOrderRT;
            this.opportunityRT = opportunityRT;
            this.contractRT = contractRT;
            this.country = country;
            this.opportunityRTBP = opportunityRTBP;
        }
        public RTConfigWrapper(String workOrderRT, String opportunityRT, String contractRT, String country, String opportunityRTBP, String legalEntityOverrideForLogistic) {
            this.workOrderRT = workOrderRT;
            this.opportunityRT = opportunityRT;
            this.contractRT = contractRT;
            this.country = country;
            this.opportunityRTBP = opportunityRTBP;
            this.legalEntityOverrideForLogistic = legalEntityOverrideForLogistic;
        }
    }

    public class NoConfigException extends Exception {}
}