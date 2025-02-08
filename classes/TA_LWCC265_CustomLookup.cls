public without sharing class TA_LWCC265_CustomLookup {

    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName,String objectIdentifier, String filterField, String searchString, String value, String condition, String recordLimit) {
        try {
            String limitRecord = '5';
            if(String.isNotBlank(recordLimit)){
                limitRecord = recordLimit;
            }

            List<RecordsData> recordsDataList = new List<RecordsData>();
            String query= 'SELECT Id, ' + filterField + (filterField.contains(objectIdentifier) ? '' : (', ' + objectIdentifier)) + ' FROM '+objectName;


            if(String.isNotBlank(value)) {
                query += ' WHERE Id = \''+ value + '\' LIMIT 49999';
            } else if(String.isNotBlank(condition)){
                query += ' WHERE '+filterField+
                		' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND '+ condition + ' LIMIT ' + limitRecord;
            } else {
                query += ' WHERE '+filterField+
                		' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' LIMIT ' + limitRecord;
            }

	        for(SObject s : Database.query(query)) {
	            recordsDataList.add( new RecordsData((String)s.get('id'), (String)s.get(objectIdentifier)));
	        }
            return recordsDataList;

	    } catch (Exception err) {
	    	if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
	    }
    }
 
    public class RecordsData {
        
        @AuraEnabled public String value;
        @AuraEnabled public String identifier;

        public RecordsData(String value, String identifier) {
            this.value = value;
            this.identifier = identifier;
        }
    }
}