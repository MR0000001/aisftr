/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  06/06/2019 
* @description XC_UTIL_Trigger_TEST – Test class for XC_UTIL_Trigger
*/
@isTest
public with sharing class XC_UTIL_Trigger_TEST {

    //Test Method checkMapNew
    static testMethod void checkMapNew(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        List<Account> accts = XC_DF_Account.createResidentialAccounts(1);
        System.TriggerOperation operationType;
        Map<Id, SObject> mapNewS = new Map<Id, SObject>();
        mapNewS.put(accts[0].Id , accts[0]); 
        Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
        Boolean test3 = true; 
        Map<String, Object> mapStringObject = new Map<String, Object>();
        mapStringObject.put(accts[0].Id, test3);
        mapEventRecordsToBeReProcessed.put(operationType, mapStringObject);
        Map<Id, SObject> result =XC_UTIL_Trigger.checkMapNew(operationType, mapNewS, mapEventRecordsToBeReProcessed );
        System.assert(result!=null);
        Test.stopTest(); 
    }

        //Test Method filterMapNew
    static testMethod void filterMapNew(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        List<Account> accts = XC_DF_Account.createResidentialAccounts(1);
        Map<Id, SObject> mapNew = new Map<Id, SObject>();
        mapNew.put(accts[0].Id , accts[0]); 
        Boolean test3 = true; 
        Map<String, Object> mapRecordsToBeReProcessed = new  Map<String, Object>();
        mapRecordsToBeReProcessed.put(accts[0].Id, test3);
        Map<Id, SObject> result =XC_UTIL_Trigger.filterMapNew(mapNew, mapRecordsToBeReProcessed );
        System.assert(result!=null);
        Test.stopTest(); 
    }

        //Test Method stopRecursion
    static testMethod void stopRecursion(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        System.TriggerOperation operationType;
        Boolean test3 = true; 
        Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
        mapTriggerStopped.put(operationType , test3);
        Map<String, Object> mapStringObject = new  Map<String, Object>();
        Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
        mapEventRecordsToBeReProcessed.put(operationType ,mapStringObject);
        Boolean result =XC_UTIL_Trigger.stopRecursion(operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed );
        System.assert(result!=null);
        Test.stopTest(); 
    }

}