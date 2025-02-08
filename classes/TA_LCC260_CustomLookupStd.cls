/**
 * @description       : 
 * @author            : benjamin.geronimo
 * @group             : WebResults
 * @last modified on  : 26-07-2021
 * @last modified by  : benjamin.geronimo
 * Modifications Log 
 * Ver   Date         Author              Modification
 * 1.0   05-07-2021   benjamin.geronimo   Initial Version
**/
public with sharing class TA_LCC260_CustomLookupStd {

    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    /**
    * @description 
    * @author benjamin.geronimo | 05-07-2021 
    * @param objectName 
    * @param filterField 
    * @param searchString 
    * @param value 
    * @param relatedRecordParentId 
    * @param parentFieldAPIName 
    * @return List<RecordsData> 
    **/
    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String value, String relatedRecordParentId, String parentFieldAPIName) {
        List<RecordsData> recordsDataList = new List<RecordsData>();
        try { 
            system.debug('APEX method call => '+relatedRecordParentId+' ==>'+ parentFieldAPIName);
            
            
            String query ='';
            if(relatedRecordParentId=='' && parentFieldAPIName==''){
                query = 'SELECT Id, ' + filterField + ' FROM '+objectName;    
            }
            else{
                query = 'SELECT Id, '+ parentFieldAPIName + ' ,' + filterField + ' FROM ' + objectName + 
                        ' WHERE '+ parentFieldAPIName + '= \'' + relatedRecordParentId + '\'' ;    
            }
            
            if(relatedRecordParentId=='' && parentFieldAPIName==''){
                if(String.isNotBlank(value)) {
                    query += ' WHERE Id = \''+ value + '\' LIMIT 49999';
                } else if(String.isNotBlank(filterField)) {
                    query += ' WHERE '+filterField+
                            ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\' LIMIT 49999';
                }
            }
            else{
                if(String.isNotBlank(value)) {
                    query += ' AND Id = \''+ value + '\' LIMIT 49999';
                } else if(String.isNotBlank(filterField)) {
                    query += ' AND '+filterField+
                            ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\' LIMIT 49999';
                }
            }
            System.debug('Query=> =>'+query);
            for(SObject s : Database.query(query)) {
                
                recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
            }
            
            
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC259_QualityCheckCreateRecord] getCurrentRecord - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC259_QualityCheckCreateRecord', 'getCurrentRecord', errorMessage, 0, errorMessage, null);
        }

        return recordsDataList;
    }
 
}