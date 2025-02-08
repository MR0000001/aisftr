/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 16/04/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_Query - Util class for SOQL
*/

public without sharing class XC_UTIL_Query {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Query');

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 16/04/2019
    * @date Modification dd/mm/yyyy
    * @description Method for select fields from a record
    * @param setFields - Set<String>
    * @param recordId - Id
    * @return sObject
    */
    public static sObject selectFields(Set<String> setFields, Id recordId) {
        return selectFieldsList(setFields, recordId)[0];
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 16/04/2019
    * @date Modification dd/mm/yyyy
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
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'query->' + query);
        if(!token.isAccessible() && listFields.isEmpty()) {
            return new List<sObject>();
        }
        return Database.query(query);
    }
    
     /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Returns true if all DML are success
     * @param dmlResultList
     * @return Boolean
     */
    public static Boolean checkDMLResults(List<XC_UTIL_Sobject.WrapperResult> dmlResultList){
        /*for(XC_UTIL_Sobject.WrapperResult wr : dmlResultList){
            if(!wr.success){
                return false;
            }
        }
        return true;*/
        XC_UTIL_Sobject.WrapperResult result = getGlobalDMLResults(dmlResultList);
        return result.success;
    }
    
     /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com -  Marco Rosa - marco.rosa@nttdata.com
     * @description Returns a global wrapper result from all DML 
     * @param dmlResultList
     * @return Boolean
     */
    public static XC_UTIL_Sobject.WrapperResult getGlobalDMLResults(List<XC_UTIL_Sobject.WrapperResult> dmlResultList){
        XC_UTIL_Sobject.WrapperResult result = new XC_UTIL_Sobject.WrapperResult();
        result.success = true;
        for(XC_UTIL_Sobject.WrapperResult wr : dmlResultList){
            if(!wr.success){
                result.success = false;
                result.errorMessage = wr.errorMessage;
                return result;
            }
        }
        return result;
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
        List<sObject> listChanged = new List<sObject>();
        for(sObject s : mapNew.values()){
            Id oId = (Id) s.get('Id');
            Boolean isChanged = false;
            if(oId != null) {
                for(String field : fieldList){
                    if(mapNew.get(oId).get(field) != mapOld.get(oId).get(field)){
                        isChanged = true;
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Field different->' + field + ' - ' + mapOld.get(oId).get(field) + ' -> ' + mapNew.get(oId).get(field));
                        break;
                    }
                } 
            }
            if(isChanged){
                listChanged.add(s);
            }
        }
        return listChanged;
    }

    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description Given a list of sobject return the sublist of sobject for which at least a field is changed (for update triggers)
     * @param chWrapper
     * @return List<sObject>
     * @Modified by Salvatore Agrillo - salvatore.agrillo@nttdata.com - 06/05/2019
     */
    public static List<sObject> getListChanged(XC_UTIL_Sobject.ChangeWrapper chWrapper) { 
        List<sObject> listChanged = new List<sObject>();
        for(sObject s : chWrapper.listSObjects){
            Id oId = (Id) s.get('Id');
            Boolean isChanged = false;
            if(oId != null) {
                for(String field : chWrapper.fieldList){
                    if(chWrapper.newMap.get(oId).get(field) != chWrapper.oldMap.get(oId).get(field)){
                        if(chWrapper.checkOldValueNull){
                            if(chWrapper.oldMap.get(oId).get(field) != null){
                                continue;
                            }
                        }
                        isChanged = true;
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Field different->' + field + ' - ' + chWrapper.oldMap.get(oId).get(field) + ' -> ' + chWrapper.newMap.get(oId).get(field));
                        break;
                    }
                } 
            }
            if(isChanged) {
                listChanged.add(s);
            }
        }
        return listChanged;
    }

}