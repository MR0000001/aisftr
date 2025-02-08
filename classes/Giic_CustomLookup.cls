/**
* @Author	:		Manas Ranjan Tripathy
* @Date		:		01/07/2019
* @description used with custom lookup aura component
* @Desc		:		Controller for Lookup Lightning Component
* */
public with sharing class Giic_CustomLookup{
       /** 
    * @author Pradeep Kumar
    * @date Creation 01/07/2019
    * @description // 
    * @param condQueryLike string
    * @param fieldName string
    * @return string
    */
    private static string getCondLike(string condQueryLike, string fieldName){
        return fieldName + condQueryLike;
    }

    
     /** 
    * @author Manas Tripathi
    * @date Creation 01/07/2019
    * @description JSON of list of ResultWrapper to Lex Components
    * @param objectName - Name of SObject
    * @param fldAPIText - API name of field to display to user while searching
    * @param fldAPIVal - API name of field to be returned by Lookup COmponent
    * @param lim   - Total number of record to be returned
    * @param fldAPISearch - API name of field to be searched
    * @param searchText - text to be searched
    * @return String
    * */
    @AuraEnabled(cacheable=true)
    public static String searchDB(String objectName, String fldAPIText, String fldAPIVal, 
    	Integer lim,String fldAPISearch,String searchText){
                                      
        String query = String.escapeSingleQuotes('SELECT '+ fldAPIText+' ,'+fldAPIVal + ' FROM '+objectName);
                query += ' WHERE '+ getCondLike('\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'',+fldAPISearch+' LIKE ') ;
                query += String.escapeSingleQuotes(' LIMIT '+lim);
        
        List<sObject> sobjList = Database.query(query);
        List<ResultWrapper> lstRet = new List<ResultWrapper>();
        
        for(SObject s : sobjList){
            ResultWrapper obj = new ResultWrapper();
            obj.objName = objectName;
            obj.text = String.valueOf(s.get(fldAPIText)) ;
            obj.val = String.valueOf(s.get(fldAPIVal))  ;
            lstRet.add(obj);
        } 
        return JSON.serialize(lstRet) ;
    }                              
     /**
     * @author Pradeep Kumar
     * @date 10/07/2019
     * @description ResultWrapper Wrapper
     */
    public class ResultWrapper{
        /**
        * @description objName object name
        */
        public String objName {get;set;}
        /**
        * @description text text
        */
        public String text{get;set;}
        /**
        * @description val val
        */
        public String val{get;set;}
    }
}