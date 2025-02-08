/**
* @author Marco Rosa - marco.rosa@nttdata.com & Nicolò Leonardi - nleonardi@deloitte.it 
* @date Creation 21/08/2018
* @date Modification dd/mm/yyyy
* @description XC_UTIL_Sobject – Util class for sObject methods
*/

public without sharing class XC_UTIL_Sobject {         

    //*********************************** VARIABLES **************************************
    public static Boolean throwExceptionInTest  = false;
    private final static Boolean DEBUGACTIVE    = XC_UTIL_Debug.isActive('XC_UTIL_Sobject');
    //************************************************************************************
    
    //************************************ WRAPPERS **************************************
    /** @description WrapperResult */
    public class WrapperResult{ 
        public String recordId = '';
        public Boolean success = false;
        public String errorMessage = '';
        public String errorfieldName = '';
        public String errorObjectId = '';
        public String objectInfo = ''; 
    } 

    /** @description ChangeWrapper */
    public class ChangeWrapper {
        public String oId;
        public List<sObject> listSObjects;
        public List<String> fieldList;
        public Map<Id,sObject> oldMap;
        public Map<Id,sObject> newMap;
        /* if true the method checks if the previous value of the field was null, not otherwise */
        public Boolean checkOldValueNull = false;

        /** 
        * @description Costructor ChangeWrapper
        * @param listSObjects
        * @param fieldList
        * @param oldMap
        * @param newMap
        */
        /*public ChangeWrapper(List<sObject> listSObjects, List<String> fieldList, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
            this.listSObjects = listSObjects;
            this.fieldList = fieldList;
            this.oldMap = oldMap;
            this.newMap = newMap;
        }*/
    }

    /** @description ErrorSetWrapper */
    private class ErrorSetWrapper {
        String errorfieldName;
        String errorMessage;
    }
    //************************************************************************************



    //********************************* METHODS FOR DML **********************************

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given a Object makes an insert of the list
     * @param objectToInsert
     * @return WrapperResult
     */
    public static WrapperResult insertRecord(sObject objectToInsert){ 
        List<WrapperResult> wrapperList = insertListRecords(new List<sObject>{objectToInsert});
        return wrapperList[0];
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given a list of sObjects makes an insert of the list
     * @param listToInsertToCheck
     * @return List<WrapperResult>
     */
    public static List<WrapperResult> insertListRecords(List<sObject> listToInsertToCheck){
        return XC_UTIL_DML.insertRecords(listToInsertToCheck);
    }
    /**
     * @author Nicola Arrigo - narrigo@deloitte.it
     * @description Given a list of sObjects makes an insert of the list
     * @param listToInsertToCheck List<XC_Customer_Interaction__c> 
     * @return List<WrapperResult>
     */
    public static List<WrapperResult> insertListRecords(List<XC_Customer_Interaction__c> listToInsertToCheck){
        return XC_UTIL_DML.insertRecords(listToInsertToCheck);
    } 
    

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given a list of sObjects makes an insert of the list
     * @param listToInsertToCheck
     * @param allOrNone
     * @return List<WrapperResult>
     */
    public static List<WrapperResult> insertListRecords(List<sObject> listToInsertToCheck, Boolean allOrNone){
        return XC_UTIL_DML.insertRecords(listToInsertToCheck, allOrNone);
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given a sObject makes an update of the list
     * @param objectToUpdate
     * @return WrapperResult
     */
    public static WrapperResult updateRecord(sObject objectToUpdate){ 
        List<WrapperResult> wrapperList = updateListRecords(new List<sObject>{objectToUpdate});
        return wrapperList[0];
    }

    /**
     * @description Given a list of sObjects makes an update of the list
     * @param listToUpdateToCheck
     * @return List<WrapperResult>
     */
    public static List<WrapperResult> updateListRecords(List<sObject> listToUpdateToCheck){
        return XC_UTIL_DML.updateRecords(listToUpdateToCheck);
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Given a list of sObjects makes an update of the list with option allOrNone
     * @param listToUpdateToCheck
     * @param allOrNone
     * @return List<WrapperResult>
     */
    public static List<WrapperResult> updateListRecords(List<sObject> listToUpdateToCheck, Boolean allOrNone){
        return XC_UTIL_DML.updateRecords(listToUpdateToCheck, allOrNone);
    }

    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description Given a list of sObjects makes an upsert of the list
     * @param objectToUpsert
     * @return WrapperResult
     */
    public static WrapperResult upsertRecord(sObject objectToUpsert){ 
        List<WrapperResult> wrapperList = upsertListRecords(new List<sObject>{objectToUpsert});
        return wrapperList[0];
    }

    /**
     * @description Given a list of sObjects makes an upsert of the list
     * @param listToUpsert
     * @return List<WrapperResult>
     */
    public static List<WrapperResult> upsertListRecords(List<sObject> listToUpsert){
        return XC_UTIL_DML.upsertRecords(listToUpsert);
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Given a list of sObjects makes an upsert of the list with option allOrNone
     * @param listToUpsert
     * @param allOrNone
     * @return List<WrapperResult>
     */
    /*public static List<WrapperResult> upsertListRecords(List<sObject> listToUpsert, Boolean allOrNone){
        return XC_UTIL_DML.upsertRecords(listToUpsert, allOrNone);
    }*/

    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Given a list of sObjects makes the delete of the list
     * @param objectToDelete
     * @return WrapperResult
     */
    public static WrapperResult deleteRecord(sObject objectToDelete){
        List<WrapperResult> wrapperList = deleteListRecords(new List<sObject>{objectToDelete});
        return wrapperList[0];
    }

    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Given a list of sObjects makes the delete of the list
     * @param listToDeleteToCheck
     * @return List<WrapperResult>
     */
    public static List<WrapperResult> deleteListRecords(List<sObject> listToDeleteToCheck){
        return XC_UTIL_DML.deleteRecords(listToDeleteToCheck);
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Given a list of sObjects makes an delete of the list with option allOrNone
     * @param listToDelete
     * @param allOrNone
     * @return List<WrapperResult>
     */
    public static List<WrapperResult> deleteListRecords(List<sObject> listToDelete, Boolean allOrNone){
        return XC_UTIL_DML.deleteRecords(listToDelete, allOrNone);
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Returns true if all DML are success
     * @param dmlResultList
     * @return Boolean
     */
    public static Boolean checkDMLResults(List<WrapperResult> dmlResultList){
        return XC_UTIL_Query.checkDMLResults(dmlResultList);
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com -  Marco Rosa - marco.rosa@nttdata.com
     * @description Returns a global DML result
     * @param dmlResultList
     * @return XC_UTIL_Sobject.WrapperResult
     */
    public static XC_UTIL_Sobject.WrapperResult getGlobalDMLResults(List<WrapperResult> dmlResultList){
        return XC_UTIL_Query.getGlobalDMLResults(dmlResultList);
    }
    

    //************************************** UTILS ***************************************

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given an Id returns the  object Type
     * @return String
     * @param recordId
     */
    public static String getObjectType(Id recordId){ 
        return XC_UTIL_Sobject_U_Retrieve.getObjectType(recordId);
    } 

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given a list of sobject return the sublist of sobject for which at least a field is changed (for update triggers)
     * @param fieldList
     * @param mapOld
     * @param mapNew
     * @return List<sObject>
     * @Modified by Salvatore Agrillo - salvatore.agrillo@nttdata.com - 06/05/2019
     */
    public static List<sObject> getListChanged(List<String> fieldList, Map<Id,sObject> mapOld, Map<Id,sObject> mapNew){
        return XC_UTIL_Query.getListChanged(fieldList, mapOld, mapNew);
    }

    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description Given a list of sobject return the sublist of sobject for which at least a field is changed (for update triggers)
     * @param chWrapper
     * @return List<sObject>
     * @Modified by Salvatore Agrillo - salvatore.agrillo@nttdata.com - 06/05/2019
     */
    public static List<sObject> getListChanged(ChangeWrapper chWrapper) { 
        return XC_UTIL_Query.getListChanged(chWrapper);
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Method to get list fields from field set
     * @param objName
     * @param fieldSetName
     * @return List<String>
     */
    public static List<String> getListFieldsFromFieldSet(String objName, String fieldSetName){
        return XC_UTIL_Sobject_U_Retrieve.getListFieldsFromFieldSet(objName, fieldSetName);
    } 

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com & Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com
     * @description Given an Id returns alla fields
     * @param objName
     * @param fieldName
     * @param recordId
     * @return String
     */
    public static String getFieldValue(String objName, String fieldName, String recordId){
        return XC_UTIL_Sobject_U_Retrieve.getFieldValue(objName, fieldName, recordId);
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given an Id returns alla fields
     * @param recordId
     * @return List<sObject>
     */
    public static List<sObject> selectAllFields(Id recordId){           
        String objName = getObjectType(recordId); 
        return selectAllFields(new List<String>{recordId}, objName);
    } 

    /**
     * @description Select all fields
     * @param objName
     * @return String
     */
    public static String selectAllFieldsGetSelect(String objName){  
        Schema.SObjectType obj                      = Schema.getGlobalDescribe().get(objName);
        Map<String, Schema.SObjectField> fieldMap   = obj.getDescribe().fields.getMap();
        List<String> fieldNames                     = new List<String>(fieldMap.keySet());
        Set<String> fieldNameSet = new Set<String>(fieldNames); 
        fieldNameSet.remove('lastreferenceddate'); 
        fieldNameSet.remove('lastvieweddate'); 
        List<String> fieldNameList = new List<String>(fieldNameSet);
        String query = 'SELECT ';
        query += String.join(fieldNameList,',');
        return query;
    }

    /**
     * @description Select all fields
     * @param recordIdList
     * @param objName
     * @return List<sObject>
     */
    public static List<sObject> selectAllFields(List<String> recordIdList, String objName){  
        String query = String.escapeSingleQuotes(selectAllFieldsGetSelect(objName)); 
        query += String.escapeSingleQuotes(' FROM ' + objName +' WHERE id IN :recordIdList');
        List<sObject> results = Database.query(query); 
        return results;
    }

    /**
     * @author Nicolò Leonardi - nleonardi@deloitte.it
     * @description Give an Id return Record Type Developer Name
     * @param recordTypeId
     * @return String
     */
    public static String retrieveRecordTypNameFromId(Id recordTypeId) {
        return XC_UTIL_Sobject_U_Retrieve.retrieveRecordTypNameFromId(recordTypeId);
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given a list of sObject retuns the List of Ids
     * @param listSObjects
     * @return List<Id>
     */
    public static List<Id> getIds(List<sObject> listSObjects){
        return XC_UTIL_Sobject_U_Retrieve.getIds(listSObjects);
    }

    /**
     * @description Get set IDs from list Sobject
     * @param listSObjects
     * @return Set<Id>
     */
    public static Set<Id> getSetIds(List<sObject> listSObjects){
        return XC_UTIL_Sobject_U_Retrieve.getSetIds(listSObjects);
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @description Given a list of sObject and a String fieldname, return a Set of Id taken on fieldName field
     * @param listSObjects
     * @param fieldName
     * @return Set<Id>
     */
    public static Set<Id> getSetIdsOnField(List<sObject> listSObjects, String fieldName){
        return XC_UTIL_Sobject_U_Retrieve.getSetIdsOnField(listSObjects, fieldName);
    }

    /**
     * @description Given a list of sObject and a String fieldname, return a Set of Id taken on fieldName field
     * @param listSObjects
     * @param fieldName
     * @return Set<String>
     */
    public static Set<String> getSetIdsStringOnField(List<sObject> listSObjects, String fieldName){
        return XC_UTIL_Sobject_U_Retrieve.getSetIdsStringOnField(listSObjects, fieldName);
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given a list of sObject and a String field retuns the List of values of that field
     * @param listSObjects
     * @param fieldName
     * @return List<String>
     */
    public static List<String> getListFieldValues(List<sObject> listSObjects, String fieldName){
        return XC_UTIL_Sobject_U_Retrieve.getListFieldValues(listSObjects, fieldName);
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @description Given a list of sObject and a String field,
     * retuns the List of values of that field, included null value.
     * @param listSObjects
     * @param fieldName
     * @return List<String>
     */
    public static List<String> getListFieldValuesWithNullValue(List<sObject> listSObjects, String fieldName){
        return XC_UTIL_Sobject_U_Retrieve.getListFieldValuesWithNullValue(listSObjects, fieldName);
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given a sObject Name retuns the List of all fields API Names
     * @param objectName
     * @return List<String>
     */
    public static List<String> getListAllFields(String objectName){
        return XC_UTIL_Sobject_U_Retrieve.getListAllFields(objectName);
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given a sObject Name and a field retuns the Field Type
     * @param objectName
     * @param fieldName
     * @return Schema.DisplayType
     */
    public static Schema.DisplayType getFieldType(String objectName, String fieldName){
        return XC_UTIL_Sobject_U_Retrieve.getFieldType(objectName, fieldName);
    }    
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given a sObject Name and a picklist field retuns the list of picklist values as Schema.PicklistEntry
     * @param objectName
     * @param fieldName
     * @return List<Schema.PicklistEntry>
     */
    public static List<Schema.PicklistEntry> retrieveAllPicklistValues(String objectName, String fieldName){ 
        return XC_UTIL_Sobject_U_Retrieve.retrieveAllPicklistValues(objectName, fieldName);
    }

    /**
     * @author Ivan Nocenti - 
     * @description Given a sObject Name and the field name (picklist field), the method retuns the List of all picklist values (not labels)
     * @param objectName
     * @param fieldName
     * @return List<String>
     */
    public static List<String> getPicklistValues(String objectName, String fieldName){ 
        return XC_UTIL_Sobject_U_Retrieve.getPicklistValues(objectName, fieldName);
    }

    /**
     * @author Salvatore Scarpato - 
     * @description Given a String return a Date with the correct format
     * @param dateString
     * @return Date
     */
    public static Date stringToDate(String dateString) {
        return XC_UTIL_Sobject_U.stringToDate(dateString);
    }

    /**
     * @author Salvatore Scarpato -  
     * @description Given a String return a DateTime with the correct format
     * @param dateString
     * @return Datetime
     */
    public static Datetime stringToDateTimeGmt(String dateString) {
        /*List<String> lstDate= dateString.split('-');
        Integer year=integer.valueof(lstDate[0]);
        Integer month=integer.valueof(lstDate[1]);
        Integer day = integer.valueof(lstDate[2]);
        Integer hour = integer.valueof(lstDate[3]);
        Integer min = integer.valueof(lstDate[4]);
        Integer sec = integer.valueof(lstDate[5]);
        */

        DateTime resultDateTime = DateTime.ValueofGmt(dateString.replace('T', ' ')); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'resultDateTime>> '+resultDateTime);
        //DateTime myDateTime = DateTime.newInstanceGmt(year, month, day, hour, min, sec);
        return resultDateTime;        
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @description For a locked record, update fieldName field with the value in input
     *              for the SObject with the id in input (unlock + update + lock)
     * @param id
     * @param fieldName
     * @param value
     */
    public static void updateLockedSObjectField(Id id, String fieldName, String value) {
        List<SObject> sobjects = new List<SObject>();
        SObject sObj = Schema.getGlobalDescribe().get(XC_UTIL_Sobject.getObjectType(id)).newSObject();
        sobj.Id = id;
        sobj.put(fieldName, value);
        sobjects.add(sobj);
        XC_UTIL_Sobject_U.updateLockedSObjects(sobjects);
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Return a Map CountryName->QueueId, given a map countryName->QueueName
     * @param listCountries
     * @param mapCountryQueueName
     * @return Map<String, Id> 
     */ 
    public static Map<String, Id> getQueueMapByCountry(List<String> listCountries, Map<String, String> mapCountryQueueName){
        return XC_UTIL_Sobject_U.getQueueMapByCountry(listCountries, mapCountryQueueName);
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Return a Map CountryName->RecordTypeId, given a map CountryName->RecordTypeDeveloperName
     * @param objectName
     * @param listCountries
     * @param mapCountryRecordTypeName
     * @return Map<String, Id>
     */
    public static Map<String, Id> getRecordTypeMapByCountry(String objectName, List<String> listCountries, Map<String, String> mapCountryRecordTypeName){
        return XC_UTIL_Sobject_U.getRecordTypeMapByCountry(objectName, listCountries, mapCountryRecordTypeName);
    } 

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Checks if a field is Boolean
     * @param objName
     * @param fieldName
     * @return Boolean
     */
    public static Boolean isFieldBoolean(String objName, String fieldName){
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
        return fieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.Boolean;
    }

     /**
     * @author Arjun Rao H - arjun.raoh@accenture.com,  Enel X - NR2041 - Energy Communities, FT3-2021
     * @description - Checks if a field is Double
     * @param objName
     * @param fieldName
     * @return Boolean
     */
    public static Boolean isFieldDouble(String objName, String fieldName){
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
        return fieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.Double;
    }


    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given a List of Leads runs standard assignment rules
     * @param listToBeParsed
     * @param type
     */
    public static void runAssignmentRules(List<sObject> listToBeParsed, String type){
        XC_UTIL_Sobject_U.runAssignmentRules(listToBeParsed, type);
    }
    
    /**
    * @author Simone Trenta - strenta@deloitte.it , Giuseppe Di Bonito - gdibonito@deloitte.it
    * @description Match the picklist value ignoring case sensitivness
    * @param inputValue the input string
    * @param objectName the object api name
    * @param fieldName the picklist name
    * @return value the correct vaue
    */
    public static String getPicklistValueIgnoreCase(String inputValue, String objectName, String fieldName) {
        Schema.DescribeSObjectResult[] results = Schema.describeSObjects(new String[]{objectName});
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive() & entry.getValue().equalsIgnoreCase(inputValue)) {
                    return entry.getValue();
                }
            } 
        }
        return inputValue;
    }
    
        /**
     * @author Francesco Imperioli - fimperioli@deloitte.it
     * @description check if a String is a valid SFID with regex
     */
    public static Boolean checkIfIsSFDCID(String stringId, System.Type t){

        try {
            if ( Pattern.compile( '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ).matcher( stringId ).matches() ){
                // Try to assign it to an Id before checking the type
                Id id = stringId;
                // Use the Type to construct an instance of this sObject
                sObject sObj = (sObject) t.newInstance();
                // Set the ID of the new object to the value to test
                sObj.Id = id;
                // If the tests passed, it's valid
                return true;
            }
        } catch ( Exception e ){
            // StringException, TypeException
            System.Debug('INVALID ID FOUND ON : checkIfIsSFDCID ');
        }
        // ID is not valid
        return false;
    }  
    
    
}