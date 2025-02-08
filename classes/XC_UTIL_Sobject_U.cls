/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 23/04/2019
* @description XC_UTIL_Sobject_U – Method for XC_UTIL_Sobject
*/

public without sharing class XC_UTIL_Sobject_U {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Sobject_U');
    
    /** @description CheckChangeWrapper */
    /*public class CheckChangeWrapper {
        public Id oId;
        public List<String> fieldList = new List<String>();
        public Map<Id,sObject> oldMap = new Map<Id,sObject>(); 
        public Map<Id,sObject> newMap = new Map<Id,sObject>();
    }*/

    /** @description PopulateSobjectTypeWrapper */
    public class PopulateSobjectTypeWrapper {
        public List<sObject> listToBeParsed = new List<sObject>();
        public String type;
        public List<sObject> listObj = new List<sObject>();
        public Database.DMLOptions dmo;
    }

    /**
     * @author Davide De Dona- Daniele Lico - davide.dedona@nttdata.com
     * @description Retake String to Upper case
     * @param stringTemp
     * @return String
     */
    public static String retakeStringToUpperCase(String stringTemp){
        if(stringTemp!=null){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ stringTemp ---> ' + stringTemp);
            List<String> elems = stringTemp.split(' ');
            stringTemp = '';
            for(String x : elems) {
                stringTemp += x.substring(0,1).toUpperCase()+x.substring(1,x.length()).toLowerCase() + ' ';
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ Finale stringTemp ---> ' + stringTemp);
        }
        return stringTemp; 
    }

     /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given a list of fields checks if at least one is changed (for update triggers)
     * @param checkChangeWrapper - CheckChangeWrapper
     * @return Boolean
     */
    /*public static Boolean checkChanges(CheckChangeWrapper checkChangeWrapper) {
        Boolean isChanged = false;
        if(checkChangeWrapper.oId == null) {
            return isChanged;
        }

        for(String field : checkChangeWrapper.fieldList){
            if(checkChangeWrapper.newMap.get(checkChangeWrapper.oId).get(field)!=checkChangeWrapper.oldMap.get(checkChangeWrapper.oId).get(field)){
                isChanged = true;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'field different->' + field + ' - ' + checkChangeWrapper.oldMap.get(checkChangeWrapper.oId).get(field) + ' -> ' + checkChangeWrapper.newMap.get(checkChangeWrapper.oId).get(field));
                break;
            }
        } 
        return isChanged;
    }*/

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com, Monica Cutillo - monica.cutillo@nttdata.com
     * @description Method to unlock an list of SObject 
     * @param sobjectsToUnLock
     */
    public static void unlockSObjects(List<SObject> sobjectsToUnLock){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'sobjectsToUnLock->' + sobjectsToUnLock);
        List<Approval.UnlockResult> unlockResults = Approval.unlock(sobjectsToUnLock, false);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ unlockResults ---> ' + unlockResults);
        for(Approval.UnlockResult lr : unlockResults) {
            if (lr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Successfully unlocked SObjects with ID: ' + lr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : lr.getErrors()) {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'The following error has occurred.');                    
                    //XC_UTIL_Debug.debug(DEBUGACTIVE, err.getStatusCode() + ': ' + err.getMessage());
                    //XC_UTIL_Debug.debug(DEBUGACTIVE, 'SObject fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

     /**
     * @author Marco Rosa - marco.rosa@nttdata.com, Monica Cutillo - monica.cutillo@nttdata.com
     * @description Method to lock a list of SObject 
     * @param sobjectsToLock
     */
    public static void lockSObjects(List<SObject> sobjectsToLock){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'sobjectsToLock->' + sobjectsToLock);
        List<Approval.LockResult> lockResults = Approval.lock(sobjectsToLock, false);
        for(Approval.LockResult lr : lockResults) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ For Lock Result ---> ' + lr);
            if (lr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Successfully locked SObject with ID: ' + lr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : lr.getErrors()) {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'The following error has occurred.');                    
                    //XC_UTIL_Debug.debug(DEBUGACTIVE, err.getStatusCode() + ': ' + err.getMessage());
                    //XC_UTIL_Debug.debug(DEBUGACTIVE, 'SObject fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @description update fieldName field with the value in input, for the SObject with the id in input
     * @param id
     * @param fieldName
     * @param value
     **/
    public static void updateSObjectField(Id id, String fieldName, String value) {
        //XC_UTIL_Debug.debug(DEBUGACTIVE, 'updateSObjectField > ');
        List<SObject> sobjects = new List<SObject>();
        SObject sObj = Schema.getGlobalDescribe().get(XC_UTIL_Sobject.getObjectType(id)).newSObject();
        sobj.Id = id;
        sobj.put(fieldName, value);
        sobjects.add(sobj);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ sobjects ---> ' + sobjects);
        try{
            Database.update(sobjects);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'SObject with recordId = '+id+' updated');
        } catch(Exception e){ 
            XC_UTIL_ExceptionLog.insertExceptionLog(e);
            //XC_UTIL_Debug.debug(DEBUGACTIVE, e.getMessage());
        }
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @description update fieldName field with the value in input, for the SObject with the id in input
    * @param id
     * @param fieldName
     * @param value
     **/
    public static void updateSObjectField(Id id, String fieldName, Boolean value) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'updateSObjectField > ');
        List<SObject> sobjects = new List<SObject>();
        SObject sObj = Schema.getGlobalDescribe().get(XC_UTIL_Sobject.getObjectType(id)).newSObject();
        sobj.Id = id;
        sobj.put(fieldName, value);
        sobjects.add(sobj);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ sobjects ---> ' + sobjects);
        try{
            Database.update(sobjects);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'SObject with recordId = '+id+' updated');
        } catch(Exception e){ 
            XC_UTIL_ExceptionLog.insertExceptionLog(e);
            //XC_UTIL_Debug.debug(DEBUGACTIVE, e.getMessage());
        }
    }

    /**
     * @description Populate in order to Sobject Type
     * @param populateWrapper - PopulateSobjectTypeWrapper
     */
    public static void populateBySobjectType(PopulateSobjectTypeWrapper populateWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ populateWrapper ---> ' + populateWrapper);
        if(populateWrapper.type == 'Case') {
            populateWrapper.listObj = new List<Case>();
            populateWrapper.listObj.addAll(populateWrapper.listToBeParsed);
            for(SObject c : populateWrapper.listObj){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ For case ---> ' + c);
                c = (Case)c;
                c.setOptions(populateWrapper.dmo);
            }
        } else if(populateWrapper.type == 'Lead') {
            populateWrapper.listObj = new List<Lead>();
            populateWrapper.listObj.addAll(populateWrapper.listToBeParsed);
            for(SObject ld : populateWrapper.listObj){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ For lead ---> ' + ld);
                ld = (Lead)ld;
                ld.setOptions(populateWrapper.dmo);
            }
        } 
    }

    /**
     * @description Check Database operation
     * @param listObj 
     */
    public static void checkSuccessListObject(List<sObject> listObj) {
        List<Database.SaveResult> srList = Database.update(listObj);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'srList->' + srList);
        for(Database.SaveResult sr : srList) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ For result ---> ' + sr);
            if(sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Successfully updated case. case ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'The following error has occurred.');                    
                    //XC_UTIL_Debug.debug(DEBUGACTIVE, err.getStatusCode() + ': ' + err.getMessage());
                    //XC_UTIL_Debug.debug(DEBUGACTIVE, 'casea fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Given a List of Leads runs standard assignment rules
     * @param listToBeParsed
     * @param type
     */
    public static void runAssignmentRules(List<sObject> listToBeParsed, String type){
        if(!listToBeParsed.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listToBeParsed ---> ' + listToBeParsed);
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.AssignmentRuleHeader.useDefaultRule = true;

            XC_UTIL_Sobject_U.PopulateSobjectTypeWrapper populateWrapper = new XC_UTIL_Sobject_U.PopulateSobjectTypeWrapper();
            populateWrapper.listToBeParsed = listToBeParsed;
            populateWrapper.type = type;
            populateWrapper.dmo = dmo;
            XC_UTIL_Sobject_U.populateBySobjectType(populateWrapper);
            List<sObject> listObj = populateWrapper.listObj;

            try{
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ For listObj ---> ' + listObj);
                XC_UTIL_Sobject_U.checkSuccessListObject(listObj);
            } catch(Exception e){ 
                XC_UTIL_ExceptionLog.insertExceptionLog(e);
                //XC_UTIL_Debug.debug(DEBUGACTIVE, e.getMessage());
            }
        }
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Return a Map CountryName->QueueId, given a map countryName->QueueName
     * @param listCountries
     * @param mapCountryQueueName
     * @return Map<String, Id> 
     */
    public static Map<String, Id> getQueueMapByCountry(List<String> listCountries, Map<String, String> mapCountryQueueName){
        Set<String> setCountries = new Set<String>(listCountries);
        Set<String> queueNames = new Set<String>();
        for(String countryName: setCountries){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ For country ---> ' + countryName);
            if(mapCountryQueueName.containsKey(countryName)){
                queueNames.add(mapCountryQueueName.get(countryName));
            }
        }
        Map<String, Id> mapCountryOwner = new Map<String, Id>();
        Map<Id, Group> mapQueues = new Map<Id, Group>([SELECT Id, DeveloperName 
                                FROM Group 
                                WHERE DeveloperName =: queueNames 
                                AND Type = 'Queue']);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ For mapQueues ---> ' + mapQueues);
        Map<String, Id> mapQueueId = new Map<String, Id>();
        for(Group qu : mapQueues.values()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ For group ---> ' + qu);
            mapQueueId.put(qu.DeveloperName, qu.Id);
        }

        for(String countryName: setCountries){
            String queueName = mapCountryQueueName.get(countryName); 
            Id queueId = mapQueueId.get(queueName);
            mapCountryOwner.put(countryName, queueId);
        } 
        return mapCountryOwner;
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
        Set<String> setCountries = new Set<String>(listCountries);  
        Map<String, Id> mapCountryRecordTypeId = new Map<String, Id>(); 
        Schema.SObjectType token = Schema.getGlobalDescribe().get(objectName); 
        for(String countryName : setCountries){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ For country ---> ' + countryName);
            countryName = countryName.toUpperCase();
            String recordTypeDeveloperName = mapCountryRecordTypeName.get(countryName);
            String recordTypeId = token.getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId(); 
            mapCountryRecordTypeId.put(countryName, recordTypeId);
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ For mapCountryRecordTypeId ---> ' + mapCountryRecordTypeId);
        return mapCountryRecordTypeId;
    }

    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Given a String return a Date with the correct format
     * @param dateString
     * @return Date
     */
    public static Date stringToDate(String dateString) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'dateString='+dateString);
        List<String> lstDate= dateString.split('-');
        if(!lstDate.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ For lstDate ---> ' + lstDate);
            Integer year=integer.valueof(lstDate[0]);
            Integer month=integer.valueof(lstDate[1]);
            Integer day = integer.valueof(lstDate[2]);
            
            Date d = Date.newInstance(year, month,day);
            return d;   
        }else{
            return null;
        }     
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @description Method to unlock a list of SObject, update 
     * @param listLocked
     */
    public static void updateLockedSObjects(List<SObject> listLocked){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listLocked->'+listLocked);
        XC_UTIL_Sobject_U.unlockSObjects(listLocked);
        try{
            Database.update(listLocked);
            XC_UTIL_Sobject_U.lockSObjects(listLocked);
        } catch(Exception e){
            XC_UTIL_ExceptionLog.insertExceptionLog(e);
            //XC_UTIL_Debug.debug(DEBUGACTIVE, e.getMessage());
        } 
    }

}