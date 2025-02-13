/**
* @author Federico Amici - federico.amici@nttdata.com
* @date Creation 04/09/2018
* @date Modification dd/mm/yyyy
* @description XC_UTIL_SObject_CheckVisibility – Check Visibility of the user
*/

public with sharing class XC_UTIL_SObject_CheckVisibility {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_SObject_CheckVisibility');

    /**
     * @description ...
     * @param listId id list
     * @param objName the object name
     * @return the id list
     */
    public static List<Id> checkVisibility(List<Id> listId, String objName) {
        String queryString = String.escapeSingleQuotes('SELECT ID FROM ' + objName + ' WHERE ID IN :listId');
        List<sObject> listSObject = Database.query(queryString);
        List<Id> listIDret = new List<Id>();
        for(sObject obj : listSObject) {
            listIDret.add(obj.ID);
        }
        return listIDret;
    }

    /**
     * @description retrive record type for the objectType in input
     * @param objectType the object name
     * @return the list of active RecordType
     */
    public static List<RecordType> getVisibleRecordType(String objectType) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '########### START getVisibleRecordType');
         
        List<String> recordTypeNameList = new List<String>();
        List<RecordType> recordTypeList = new List<RecordType>();
        Schema.SObjectType obj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult descr = obj.getDescribe();
        List<Schema.RecordTypeInfo> infos = descr.getRecordTypeInfos();
        String defaultRecordTypeName = populateRecordTypeName(infos, recordTypeNameList);
        
        System.debug('defaultRecordTypeName fuori '+defaultRecordTypeName);
        System.debug('In recordTypeNameList = '+recordTypeNameList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ recordTypeNameList : '+recordTypeNameList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'defaultRecordTypeName : '+defaultRecordTypeName);
        if(!recordTypeNameList.isEmpty() && Schema.SObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.fields.id.isAccessible() && Schema.sObjectType.RecordType.fields.Name.isAccessible() && Schema.sObjectType.RecordType.fields.SobjectType.isAccessible()) {
            String currentUserLanguage = UserInfo.getLanguage();
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ language: '+ currentUserLanguage );
            recordTypeList = [
                SELECT id, Name, SobjectType, DeveloperName,
                    (SELECT value FROM Localization WHERE Language =:currentUserLanguage LIMIT 1) //MR add for Translation
                FROM RecordType 
                WHERE SobjectType =: objectType and DeveloperName IN : recordTypeNameList];
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ recordTypeList: '+recordTypeList);
            
            for(RecordType rt : recordTypeList ){ //MR add for Translation
                XC_UTIL_Debug.debug(DEBUGACTIVE, rt.name + ' @@@ tr: '+ rt.Localization);
                if(!rt.Localization.isEmpty() && !String.isBlank(rt.Localization[0].value)){
                    rt.Name = rt.Localization[0].value; 
                }
            }
            
            
            return organizeRTPositions(defaultRecordTypeName, recordTypeList);
        }
        
        return recordTypeList;
    }

    /**
     * @description Populate RecordTypeName
     * @param infos - List<Schema.RecordTypeInfo>
     * @param defaultRecordTypeName - String
     * @param recordTypeNameList - List<String>
     */
    private static String populateRecordTypeName(List<Schema.RecordTypeInfo> infos,  List<String> recordTypeNameList){
        String defaultRecordTypeName='';
        for(Schema.RecordTypeInfo rti : infos){
            if(rti.isAvailable() && rti.DeveloperName!=null && rti.DeveloperName != 'Master'){ 
                if(rti.isDefaultRecordTypeMapping()){
                    System.debug('defaultRecordTypeName ='+ rti.DeveloperName);
                    defaultRecordTypeName = rti.DeveloperName;
                }
                recordTypeNameList.add(rti.DeveloperName);
            }
        } return defaultRecordTypeName;
    }

    /**
     * @description puts, if exists, the default record type at the top of the recordTypeList
     * @param defaultRecordTypeName the default Record Type Name
     * @param recordTypeList the list of recordType
     * @return the list of RecordType with the default at the top, if exixts
     */
    private static List<RecordType> organizeRTPositions(String defaultRecordTypeName, List<RecordType> recordTypeList){
        System.debug('defaultRecordTypeName ='+defaultRecordTypeName);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '########### organizeRTPositions - recordTypeList='+recordTypeList);
        if(defaultRecordTypeName==null || defaultRecordTypeName==''){
            return recordTypeList;
        }
        
        List<RecordType> result = new List<RecordType>();
        Integer counter = 0;
        for(RecordType rt: recordTypeList){
            if(rt.DeveloperName == defaultRecordTypeName){
                result.add(rt);
                break;
            }
            counter = counter+1;
        }
        recordTypeList.remove(counter);
        result.addAll(recordTypeList);
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '########### organizeRTPositions - result='+result);
        return result;
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @description For a locked record, update fieldName field with the value in input
     *              for the SObject with the id in input (unlock + update + lock)
     * @param id
     * @param fieldName
     * @param value
     */
    public static void updateLockedRecordFieldById(Id id, String fieldName, String value) {
        Approval.UnlockResult ur = Approval.unlock(id);
        if(ur.isSuccess()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Unlocked recordId = '+id);
            XC_UTIL_Sobject_U.updateSObjectField(id,fieldName,value);
            Approval.LockResult lr = Approval.lock(id);
            if(lr.isSuccess()){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Locked recordId = '+id);
            }
        }     
    }

}