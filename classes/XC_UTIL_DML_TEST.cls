/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 17/05/2019
* @description XC_UTIL_DML_TEST – Test class for XC_UTIL_DML
*/ 

@isTest
private class XC_UTIL_DML_TEST {
    static testMethod void onInsert() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        System.assertEquals(1, Limits.getDmlStatements());
         
        Test.startTest();
        XC_UTIL_DML.insertRecords(new List<XC_ExceptionLog__c>{});
        XC_UTIL_DML.insertRecords(new List<Contact>{new Contact()});
        XC_UTIL_DML.throwExceptionInTest = true;
        XC_UTIL_DML.insertRecords(new List<XC_ExceptionLog__c>{new XC_ExceptionLog__c()});
		Test.stopTest();        
    }

    static testMethod void onUpdate() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_ExceptionLog__c excepLog = new XC_ExceptionLog__c();
        insert excepLog;     
        excepLog = [SELECT Id FROM XC_ExceptionLog__c LIMIT 1];
        System.assertEquals(2, Limits.getDmlStatements());
        
        Test.startTest();
        XC_UTIL_DML.updateRecords(new List<XC_ExceptionLog__c>{new XC_ExceptionLog__c()});
        XC_UTIL_DML.updateRecords(new List<XC_ExceptionLog__c>{});
        XC_UTIL_DML.updateRecords(new List<XC_ExceptionLog__c>{excepLog});
        XC_UTIL_DML.updateRecords(new List<Contact>{new Contact()});
        XC_UTIL_DML.throwExceptionInTest = true;
        XC_UTIL_DML.updateRecords(new List<XC_ExceptionLog__c>{new XC_ExceptionLog__c()});
		Test.stopTest();        
    }

    static testMethod void onDelete() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_ExceptionLog__c excepLog = new XC_ExceptionLog__c();
        insert excepLog;
        excepLog = [SELECT Id FROM XC_ExceptionLog__c LIMIT 1];
        System.assertEquals(2, Limits.getDmlStatements());
        
        Test.startTest();
        XC_UTIL_DML.deleteRecords(new List<XC_ExceptionLog__c>{excepLog});
        XC_UTIL_DML.deleteRecords(new List<XC_ExceptionLog__c>{});
        XC_UTIL_DML.throwExceptionInTest = true;
        XC_UTIL_DML.deleteRecords(new List<XC_ExceptionLog__c>{new XC_ExceptionLog__c()});
		Test.stopTest();        
    }

    static testMethod void onUpsert() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_ExceptionLog__c excepLog = new XC_ExceptionLog__c();
        insert excepLog;
        excepLog = [SELECT Id FROM XC_ExceptionLog__c LIMIT 1];
        System.assertEquals(2, Limits.getDmlStatements());
        
        Test.startTest();
        XC_UTIL_DML.upsertRecords(new List<XC_ExceptionLog__c>{excepLog});
        XC_UTIL_DML.upsertRecords(new List<XC_ExceptionLog__c>{new XC_ExceptionLog__c()});
        XC_UTIL_DML.upsertRecords(new List<XC_ExceptionLog__c>{});
        XC_UTIL_DML.upsertRecords(new List<Contact>{new Contact()});
        XC_UTIL_DML.throwExceptionInTest = true;
        XC_UTIL_DML.upsertRecords(new List<XC_ExceptionLog__c>{new XC_ExceptionLog__c()});
		Test.stopTest();        
    }
    
    static testMethod void onError() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        System.assertEquals(1, Limits.getDmlStatements());
        
        Test.startTest();
        XC_UTIL_DML_U.failedInTest = true;
        XC_UTIL_DML.insertRecords(new List<XC_ExceptionLog__c>{new XC_ExceptionLog__c()});
		Test.stopTest();        
    }
    
    static testMethod void insertRecordsCI(){
        List<XC_Customer_Interaction__c> ciList = XC_DF_CustomerInteraction.createCustomerInteraction(1);  
        ciList[0].XC_LegalEntity__c = 'EndesaX';
       Test.startTest();
        XC_UTIL_DML.insertRecords(ciList);
        Test.stopTest();
        
    }
    
}