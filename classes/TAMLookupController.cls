/**
 * @description       :
 * @author            : Amit Singh (https://sfdcpanther.com/custom-lookup-in-lightning-web-component/)
 * @group             :
 * @last modified on  : 03-05-2022
 * @last modified by  : Marco Lazzaroni (mlazzaroni@pic-informatica.it)
**/
public with sharing class TAMLookupController {
    @AuraEnabled
    public static List<SObject> search(String objectName, List<String> fields, String searchTerm, String searchClause){
        String searchKeyword = searchTerm;
        String returningQuery = '';
        returningQuery = objectName+' ( Id, ' + String.join(fields,',') + (String.isBlank(searchClause) ? '' : ' WHERE ' + searchClause) + ')';
        String query = 'FIND :searchKeyword IN ALL FIELDS RETURNING '+returningQuery+' LIMIT 20';
        List<List<SObject>> searchRecords = new List<List<SObject>>();
        List<SObject> sObjList = new List<SObject>();
        if(String.isBlank(searchTerm)) {
            String soqlQuery = 'SELECT Id, ' + String.join(fields, ',') + ' FROM ' + objectName + ' WHERE ' + (String.isBlank(searchClause) ? '' : '(' + searchClause + ') AND ') + ' LastViewedDate = LAST_N_DAYS:15 ORDER BY LastViewedDate DESC LIMIT 20';
            sObjList = Database.query(soqlQuery);
            searchRecords.add(sObjList);
            return searchRecords.get(0);
        }
        If(searchTerm.length() < 3) {
            String soqlQuery = 'SELECT Id, ' + String.join(fields, ',') + ' FROM ' + objectName + ' WHERE ' + (String.isBlank(searchClause) ? '' : '(' + searchClause + ') AND ') + ' LastViewedDate = LAST_N_DAYS:15 AND ' + fields[0] + ' like \'%' + searchTerm + '%\' ORDER BY LastViewedDate DESC LIMIT 20';
            sObjList = Database.query(soqlQuery);
            searchRecords.add(sObjList);
        }else{
            searchRecords = Search.query(query);
        }
        return searchRecords.get(0);
    }

    @AuraEnabled
    public static SObject getRecentlyCreatedRecord(String recordId, List<String> fields, String objectName){
        SObject createdRecord;
        try {
            String query = 'SELECT Id, '+String.join(fields,',')+' FROM '+objectName+' WHERE Id = \''+recordId+'\'';
            List<SObject> sobjList = Database.query( query );
            createdRecord = sobjList.get(0);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return createdRecord;
    }
}