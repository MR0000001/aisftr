/**
 * @author        : DDesideri
 * @description   : 
 * @TestClasses   : AutoCompleteControllerTest
**/
public with sharing class AutoCompleteController {
    @AuraEnabled(cacheable=true)
    public static List<SObject> getRecords(String searchString, String objectApiName, String idFieldApiName, String valueFieldApiName, String extendedWhereClause, Integer maxRecords){
        searchString = String.escapeSingleQuotes(searchString);
        objectApiName = String.escapeSingleQuotes(objectApiName);
        idFieldApiName = String.escapeSingleQuotes(idFieldApiName);
        valueFieldApiName = String.escapeSingleQuotes(valueFieldApiName);
        extendedWhereClause = String.escapeSingleQuotes(extendedWhereClause);
        String match = '\'A\'';
        if(extendedWhereClause == null){
            extendedWhereClause = '';
        }
        
        String query = 'SELECT '+idFieldApiName+', '+valueFieldApiName+' FROM '+objectApiName+' WHERE '+valueFieldApiName+' LIKE \'%'+searchString+'%\' AND '+extendedWhereClause+' = '+match+'  LIMIT '+maxRecords;

        system.debug(Database.query(query));
        List<sObject> sobjList = Database.query(query);
        sobjList.sort();
        // return Database.query(query);
        return sobjList;
    }
}