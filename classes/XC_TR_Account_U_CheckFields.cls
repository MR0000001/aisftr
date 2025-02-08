/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 31/03/2020
* @description XC_TR_Account_U_CheckFields – Util class to validate inserted/updated accounts
*/  

public without sharing class XC_TR_Account_U_CheckFields {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Account_U_CheckFields');

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 31/03/2020
     * @description Method to validate inserted account
     * @param mapNew - Map<Id, Account> 
    */ 
    public static void checkOnInsert(Map<Id, Account> mapNew) { 
        // Check for major age:  
        Map<Id, Account> mapAccountToCheckAge = new Map<Id, Account>();
        for(Account acc : mapNew.values()) {
            if(acc.XC_ReceivingChannel__c != Label.XC_CL_ChannelCommodityPartner) {
                mapAccountToCheckAge.put(acc.Id, acc);
            }
        }
        if(mapAccountToCheckAge.values().isEmpty()) {
            return;
        }
        Map<String, Date> mapAccountBirthday = new Map<String, Date>();
        Map<String, List<String>> mapAccountLegalEntity = new Map<String, List<String>>();
        List<String> listFields = XC_UTIL_Sobject.getListAllFields('Account');
        for(Account acc : mapAccountToCheckAge.values()) {
            if(String.isNotBlank(String.valueOf(acc.XC_BirthDate__c))) {
                for(String nameField : listFields) {
                    if(nameField.contains('XC_GiveDataTo_') && acc.get(nameField) == true) {
                        String currentLegalEntity = nameField.replace('XC_GiveDataTo_','').replace('__c','');
                        mapAccountLegalEntity.put(acc.Id, new List<String>{currentLegalEntity});
                        mapAccountBirthday.put(acc.Id, acc.XC_BirthDate__c);
                        break;
                    }
                }
            }
        }
        if(mapAccountBirthday.values().isEmpty()) {
            return;
        }
        List<sObject> listSobjectWithError = XC_UTIL_Date.checkAdultAge(mapAccountToCheckAge, mapAccountLegalEntity, mapAccountBirthday);
        for(sObject obj : listSobjectWithError) {
            obj.addError(Label.XC_CL_ErrorAdultAge);
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 31/03/2020
     * @description Method to validate updated account
     * @param mapNew - Map<Id, Account> 
     * @param mapOld - Map<Id, Account> 
    */ 
    public static void checkOnUpdate(Map<Id, Account> mapOld, Map<Id, Account> mapNew) { 
        // Check for major age: 
        List<String> listFieldsChanged = new List<String>{'XC_Birthdate__c'};
        List<String> listFields = XC_UTIL_Sobject.getListAllFields('Account');
        for(String nameField : listFields) {
            if(nameField.contains('XC_GiveDataTo_')) {
                listFieldsChanged.add(nameField);
            }
        }
        List<Account> listAccountToManage = XC_UTIL_Sobject.getListChanged(listFieldsChanged, mapOld, mapNew);
        if(listAccountToManage.isEmpty()) {
            return;
        }
        Map<Id, Account> mapAccount = new Map<Id, Account>();
        for(Account acc : listAccountToManage) {
            if(acc.XC_ReceivingChannel__c != Label.XC_CL_ChannelCommodityPartner) {
            mapAccount.put(acc.Id, acc);
        }
        }
        checkOnInsert(mapAccount);
    }

    

    /**
     * @author Lorenzo Evangelisti - lorenzo.evangelisti@webresults.it
     * @date creation - 20/06/2022
     * @description Method to check if Account Partner name changed to update group name - EXSFDCSL-352 
     * @param mapOld - map Id -> old value of record
     * @param listNew - List<Account> new values of records
    */
    public static void checkGroupNameHasChanged(Map<Id, Account> mapOld, List<Account> listNew){
        System.debug('I have been here --> ' + mapOld.get(listNew[0].Id).Name + ' oldname, ' + listNew[0].Name + ' newname.');
        Map<String, String> groupNamesOldToNew = new Map<String, String>();
        for(Account aNew : listNew){
            if(XC_UTIL_Account.isPartner(aNew.RecordTypeID)){
                String oldName = mapOld.get(aNew.Id).Name;
                if(aNew.Name != oldName){
                    groupNamesOldToNew.put(oldName, aNew.Name);
                }
            }
        }

        if(!groupNamesOldToNew.isEmpty()){
            List<Group> groupsNameChanged = [SELECT Id, Name FROM Group WHERE Name in: groupNamesOldToNew.keySet()];
            for(Group g : groupsNameChanged){
                g.Name = groupNamesOldToNew.get(g.Name);
            }
    
            if(!groupsNameChanged.isEmpty()){
                XC_UTIL_SObject.updateListRecords(groupsNameChanged);
            }
        }
    }

}