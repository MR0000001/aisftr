/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 23/04/2019
* @description XC_UTIL_Sobject_U_Retrieve – Method for XC_UTIL_Sobject
*/
public without sharing class XC_UTIL_Sobject_U_Retrieve {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Sobject_U_Retrieve');

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given an Id returns the  object Type
     * @return String
     * @param recordId
     */
    public static String getObjectType(Id recordId){
        if(recordId != null){
            Schema.SObjectType token = recordId.getSObjectType(); 
            Schema.DescribeSObjectResult dr = token.getDescribe(); 
            return dr.getName();
        } else{
            return '';
        } 
    } 

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given a list of sobject return the sublist of sobject for which at least a field is changed (for update triggers)
     * @param fieldList
     * @param mapOld
     * @param mapNew
     * @return List<sObject>
     */
    /*public static List<sObject> getListChanged(List<String> fieldList, Map<Id,sObject> mapOld, Map<Id,sObject> mapNew){ 
        List<sObject> listChanged = new List<sObject>();
        XC_UTIL_Sobject_U.CheckChangeWrapper checkChangeWrapper = new XC_UTIL_Sobject_U.CheckChangeWrapper();
        checkChangeWrapper.fieldList = fieldList;
        checkChangeWrapper.oldMap = mapOld;
        checkChangeWrapper.newMap = mapNew;
        for(sObject s : mapNew.values()){
            checkChangeWrapper.oId = (Id) s.get('Id');
            if(XC_UTIL_Sobject_U.checkChanges(checkChangeWrapper)){
                listChanged.add(s);
            }
        }
        return listChanged;
    }*/

    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description Given a list of sobject return the sublist of sobject for which at least a field is changed (for update triggers)
     * @param chWrapper
     * @return List<sObject>
     */
    /*public static List<sObject> getListChanged(XC_UTIL_Sobject.ChangeWrapper chWrapper){ 
        List<sObject> listChanged = new List<sObject>();
        XC_UTIL_Sobject_U.CheckChangeWrapper checkChangeWrapper = new XC_UTIL_Sobject_U.CheckChangeWrapper();
        checkChangeWrapper.fieldList = chWrapper.fieldList;
        checkChangeWrapper.oldMap = chWrapper.oldMap;
        checkChangeWrapper.newMap = chWrapper.newMap;
        for(sObject s : chWrapper.listSObjects){
            checkChangeWrapper.oId = (Id) s.get('Id');
            if(XC_UTIL_Sobject_U.checkChanges(checkChangeWrapper)){
                listChanged.add(s);
            }
        }
        return listChanged;
    }*/

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given a objectName and a list of FieldSet Names returns all fields inserted in the fieldsets
     * @param objName
     * @param fieldSetList
     * @return List<String>
     */
    public static List<String> getFieldsFromListFieldSets(String objName, List<String> fieldSetList){
        Set<String> fieldsToQuery = new Set<String>();
        for(String fieldSetName : fieldSetList){
            fieldsToQuery.addAll(getListFieldsFromFieldSet(objName, fieldSetName));
        }
        fieldsToQuery.add('Id');
        List<String> fieldsToQueryList = new List<String>();
        fieldsToQueryList.addAll(fieldsToQuery);
        return fieldsToQueryList;
    } 

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Method to get list fields from field set
     * @param objName
     * @param fieldSetName
     * @return List<String>
     */
    public static List<String> getListFieldsFromFieldSet(String objName, String fieldSetName){
        List<String> fieldNames = new List<String>();
        for(FieldSetMember fsm : Schema.getGlobalDescribe().get(objName).getDescribe().fieldSets.getMap().get(fieldSetName).getFields()){
            fieldNames.add(fsm.FieldPath);
        }
        return fieldNames;
    } 

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com & Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com
     * @description Given an Id returns all fields
     * @param objName
     * @param fieldName
     * @param recordId
     * @return String
     */
    public static String getFieldValue(String objName, String fieldName, String recordId){  
        Schema.SObjectType obj = Schema.getGlobalDescribe().get(objName);
        // Modifica Salvatore Agrillo 05/04/2019
        String query = String.escapeSingleQuotes('SELECT '+ fieldName + ' FROM '+ objName + ' WHERE Id = :recordId');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'query->' + query);
        List<sObject> results = Database.query(query);
        if(results.size() >= 1){
            return (String)(results[0].get(fieldName));
        }
        
        return '';
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description Given an Id returns a field object value
     * @param objName
     * @param fieldName
     * @param recordId
     * @return String
     */
    public static Object getFieldValueObject(String objName, String fieldName, String recordId){  
        Schema.SObjectType obj = Schema.getGlobalDescribe().get(objName);
        // Modifica Salvatore Agrillo 05/04/2019
        String query = String.escapeSingleQuotes('SELECT '+ fieldName + ' FROM '+ objName + ' WHERE Id = :recordId');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'query->' + query);
        List<sObject> results = Database.query(query);
        if(results.size() >= 1){
            return results[0].get(fieldName);
        }
        return '';
    }

    /**
     * @author Nicolò Leonardi - nleonardi@deloitte.it
     * @description Give an Id return Record Type Developer Name
     * @param recordTypeId
     * @return String
     */
    public static String retrieveRecordTypNameFromId(Id recordTypeId) {
        String recordTypeName;
        if(recordTypeId != null) {
            recordTypeName = [SELECT Id, DeveloperName FROM RecordType WHERE Id=:recordTypeId][0].DeveloperName;
        }
        return recordTypeName;
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com 
     * @description Given a list of sObject retuns the List of Ids
     * @param listSObjects
     * @return List<Id>
     */
    public static List<Id> getIds(List<sObject> listSObjects){
        List<Id> listIds = new List<Id>();
        for(sObject s : listSObjects){
            if(s.get('Id')!=null) {
                listIds.add((Id) s.get('Id'));
            }
        }
        return listIds;
    }

    /**
     * @description Get set IDs from list Sobject
     * @param listSObjects
     * @return Set<Id>
     */
    public static Set<Id> getSetIds(List<sObject> listSObjects){
        Set<Id> listIds = new Set<Id>();
        for(sObject s : listSObjects){
            if(s.get('Id')!=null) {
                listIds.add((Id) s.get('Id'));
            }
        }
        return listIds;
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @description Given a list of sObject and a String fieldname, return a Set of Id taken on fieldName field
     * @param listSObjects
     * @param fieldName
     * @return Set<Id>
     */
    public static Set<Id> getSetIdsOnField(List<sObject> listSObjects, String fieldName){
        Set<Id> ids = new Set<Id>();
        for(sObject sobj : listSObjects){
            if(sobj.get(fieldName)!=null) {
                ids.add((Id) sobj.get(fieldName));
            }
        }
        return ids;
    }

    /**
     * @description Given a list of sObject and a String fieldname, return a Set of Id taken on fieldName field
     * @param listSObjects
     * @param fieldName
     * @return Set<String>
     */
    public static Set<String> getSetIdsStringOnField(List<sObject> listSObjects, String fieldName){
        Set<String> ids = new Set<String>();
        for(sObject sobj : listSObjects){
            if(sobj.get(fieldName)!=null) {
                ids.add((String) sobj.get(fieldName));
            }
        }
        return ids;
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given a list of sObject and a String field retuns the List of values of that field
     * @param listSObjects
     * @param fieldName
     * @return List<String>
     */
    public static List<String> getListFieldValues(List<sObject> listSObjects, String fieldName){
        List<String> setFieldvalues = new List<String>();
        for(sObject s : listSObjects) {
            if(s.get(fieldName) != null) {
                setFieldvalues.add((String) s.get(fieldName));
            }
        }
        return setFieldvalues;
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
        List<String> setFieldvalues = getListFieldValues(listSObjects, fieldName);
        setFieldvalues.add(null);
        return setFieldvalues;
    } 

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given a list of sObject and a String field retuns the Set of values of that field
     * @param listSObjects
     * @param fieldName
     * @return Set<String>
    **/
    public static Set<String> getSetFieldValues(List<sObject> listSObjects, String fieldName){
        Set<String> setFieldvalues = new Set<String>();
        for(sObject s : listSObjects) {
            if(s.get(fieldName) != null) {
                setFieldvalues.add((String) s.get(fieldName));
            }
        }
        return setFieldvalues;
    } 


    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given a sObject Name retuns the List of all fields API Names
     * @param objectName
     * @return List<String>
     */
    public static List<String> getListAllFields(String objectName){
        List<String> fieldNames = new List<String>();
        Schema.SObjectType obj                      = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> fieldMap   = obj.getDescribe().fields.getMap();
        for(SObjectField field : fieldMap.values()){
            fieldNames.add(field.getDescribe().getName());
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'all fields:'+fieldNames);
        return fieldNames;
    }
    

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given a sObject Name and a field retuns the Field Type
     * @param objectName
     * @param fieldName
     * @return Schema.DisplayType
     */
    public static Schema.DisplayType getFieldType(String objectName, String fieldName){
        Schema.SObjectType obj                      = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> fieldMap   = obj.getDescribe().fields.getMap();
        Schema.SObjectField field = fieldMap.get(fieldName);
        Schema.DisplayType fieldType = field.getDescribe().getType();
        return fieldType;
    } 

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given a sObject Name and a picklist field retuns the list of picklist values as Schema.PicklistEntry
     * @param objectName
     * @param fieldName
     * @return List<Schema.PicklistEntry>
     */
    public static List<Schema.PicklistEntry> retrieveAllPicklistValues(String objectName, String fieldName){ 
        List<Schema.PicklistEntry> listActiveValues = new List<Schema.PicklistEntry>();
        try{ 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'language->' + UserInfo.getLanguage());
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
            Schema.DescribeSObjectResult describeObjResult = objType.getDescribe();
            Schema.DescribeFieldResult describeResult = describeObjResult.fields.getMap().get(fieldName).getDescribe();
            List<Schema.PicklistEntry> allPicklistValues = describeResult.getPicklistValues();
            for(Schema.PicklistEntry f : allPicklistValues){
                if(f.isActive()){
                    listActiveValues.add(f);
                }
            }
        }catch (Exception e) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Error in method XC_UTIL.Sobject.getPicklistValues: '+e.getMessage()+' at line: '+e.getLineNumber());
        }
        return listActiveValues; 
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @description Given a sObject Name, a picklist field and a value of this picklist, 
     * retuns the label for this value, translated by the User session (if the translation exists)
     * @param objectName
     * @param fieldName
     * @param fieldValue
     * @return string label
     */
    public static String retrieveLabelPicklistValue(String objectName, String fieldName, String fieldValue){ 
        String labelResult = '';
        try{ 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'language->' + UserInfo.getLanguage());
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'objectName->' + objectName + ' - fieldName->' + fieldName + ' - fieldValue->' + fieldValue);

            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
            Schema.DescribeSObjectResult describeObjResult = objType.getDescribe();
            Schema.DescribeFieldResult describeResult = describeObjResult.fields.getMap().get(fieldName).getDescribe();
            List<Schema.PicklistEntry> allPicklistValues = describeResult.getPicklistValues();
            for(Schema.PicklistEntry pkEntry : allPicklistValues){
                if(pkEntry.isActive() && pkEntry.getValue() == fieldValue){
                    labelResult = pkEntry.getLabel();
                }
            }
        }catch (Exception e) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Error in method XC_UTIL_Sobject_U_Retrieve.retrieveLabelPicklistValue: '+e.getMessage()+' at line: '+e.getLineNumber());
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'labelResult->' + labelResult);
        return labelResult; 
    }

    /**
     * @author Ivan Nocenti - 
     * @description Given a sObject Name and the field name (picklist field), the method retuns the List of all picklist values (not labels)
     * @param objectName
     * @param fieldName
     * @return List<String>
     */
    public static List<String> getPicklistValues(String objectName, String fieldName){ 
        List<String> lstPickvals = new List<String>();
        List<Schema.PicklistEntry> picklistValues = retrieveAllPicklistValues(objectName, fieldName);
        for (Schema.PicklistEntry a : picklistValues) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        } 
        return lstPickvals; 
    }


    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @description Given a sObject Name, a picklist field and a value of this picklist, 
     * retuns the value for this label, translated by the User session (if the translation exists)
     * @param objectName
     * @param fieldName
     * @param fieldLabel
     * @return string value
     */
    public static String retrieveValuePicklistLabel(String objectName, String fieldName, String fieldLabel){ 

        try{ 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'language->' + UserInfo.getLanguage());
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'objectName->' + objectName + ' - fieldName->' + fieldName + ' - fieldLabel->' + fieldLabel);

            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
            Schema.DescribeSObjectResult describeObjResult = objType.getDescribe();
            Schema.DescribeFieldResult describeResult = describeObjResult.fields.getMap().get(fieldName).getDescribe();
            List<Schema.PicklistEntry> allPicklistValues = describeResult.getPicklistValues();
            for(Schema.PicklistEntry pkEntry : allPicklistValues){
                if(pkEntry.isActive() && pkEntry.getLabel() == fieldLabel){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'valueResult -> ' + pkEntry.getValue());
                    return pkEntry.getValue();
                }
            }
        }catch (Exception e) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Error in method XC_UTIL_Sobject_U_Retrieve.retrieveLabelPicklistValue: '+e.getMessage()+' at line: '+e.getLineNumber());
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Value not found');
        return fieldLabel; 
    }

}