public without sharing class Utils {
    
    /**
    * @description Method for select fields from a record
    * @param setFields - Set<String>
    * @param recordId - Id
    * @return sObject
    */
    public static sObject selectFields(Set<String> setFields, Id recordId) {
        return selectFieldsList(setFields, recordId)[0];
    }

    /**
    * @description Method for select fields from a record
    * @param setFields - Set<String>
    * @param recordId - Id
    * @return listResult - List<sObject>
    */
    public static List<sObject> selectFieldsList(Set<String> setFields, Id recordId) {
        Schema.DescribeSObjectResult token = recordId.getSObjectType().getDescribe();
        String objectName = token.getName();
        List<String> listFields = new List<String>();
        listFields.addAll(setFields);
        String fieldName = String.join(listFields, ', ');
        String query = String.escapeSingleQuotes('SELECT ' + fieldName + ' FROM ' + objectName + ' WHERE Id = :recordId');
        System.debug('query->' + query);
        if(!token.isAccessible() && listFields.isEmpty()) {
            return new List<sObject>();
        }
        return Database.query(query);
    }

}