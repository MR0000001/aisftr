public without sharing class XC_LWCC003_StrikeLookup {
           // Method to fetch lookup search result   
           @AuraEnabled(cacheable=true)
           public static Map<String, sObject> fetchLookupData(String searchKey , String sObjectApiName, String key) {
            String recordTypeAccountPartner = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
               List<sObject> returnList = new List<sObject> ();
               List<sObject> listOfObject = new List<sObject>();
               Schema.SObjectType obj = Schema.getGlobalDescribe().get(sObjectApiName);
               Map<String, Schema.SObjectField> fieldMap = obj.getDescribe().fields.getMap();
               List<String> fieldNameList = new List<String>(fieldMap.keySet());
               String query = 'SELECT ';
               query += String.join(fieldNameList,',');     
               string sWildCardText = '%' + searchKey + '%';
               string sQuery = query+ String.escapeSingleQuotes(' FROM ' + sObjectApiName +' WHERE ')+key+' LIKE \''+sWildCardText +'\'  AND RecordTypeId =\''+recordTypeAccountPartner +'\'LIMIT 5';
               listOfObject = Database.query(sQuery);
               String vatNumber1 = 'XC_VAT_Number1__c';
               String vatNumber2 = 'XC_VAT_Number2__c';
               String identityNumber = 'IdentityNumber__c';
               Map<String, sObject> mapStringsObject = new Map<String, sObject>();
               String nameAccount = '';
               for (sObject objToAdd : listOfObject) {
                    nameAccount = (String)objToAdd.get(key);
                    if((String)objToAdd.get(vatNumber2) != null && (String)objToAdd.get(vatNumber2) != ''){
                        nameAccount = nameAccount + ' - ' + (String)objToAdd.get(vatNumber2);
                    }else if ((String)objToAdd.get(vatNumber1) != null && (String)objToAdd.get(vatNumber1) != ''){
                        nameAccount = nameAccount + ' - ' + (String)objToAdd.get(vatNumber1);
                    }else if((String)objToAdd.get(identityNumber) != null && (String)objToAdd.get(identityNumber) != ''){
                        nameAccount = nameAccount + ' - ' + (String)objToAdd.get(identityNumber);
                    }
                    mapStringsObject.put(nameAccount, objToAdd);
               }
               System.debug('-->'+mapStringsObject);
               return mapStringsObject;
           }
           
           // Method to fetch lookup default value 
           @AuraEnabled
           public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
            String recordTypeAccountPartner = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
               string sRecId = recordId;    
               string sQuery = 'Select Id, Name From ' + sObjectApiName + ' Where Id = : sRecId AND RecordTypeId =\''+recordTypeAccountPartner +'\' LIMIT 1';
               for (sObject obj: database.query(sQuery)) {
                   return obj;
               }
               return null;
           }
}