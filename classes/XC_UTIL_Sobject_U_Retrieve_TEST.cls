/**
* @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
* @date Creation  19/06/2019 
* @description XC_UTIL_Sobject_U_Retrieve_TEST – Test to cover XC_UTIL_Sobject_U_Retrieve
*/ 
@isTest
publiC class XC_UTIL_Sobject_U_Retrieve_TEST {
    @TestSetup
    private static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;

        List<Opportunity> o = XC_DF_Opportunity.createOpportunity(1, true);
        insert o;
    }

    @isTest
    private static void deleteOpportunity() {
        Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        delete o;
        Test.stopTest();

        System.assert([SELECT Count() FROM Opportunity] == 0);
    }

    @isTest
    private static void getSetIdsOnFieldTEST(){
        Opportunity o = [SELECT Id, RecordTypeId FROM Opportunity LIMIT 1];
        List<SObject> sObjectList = new List<SObject>();
        sObjectList.add( (SObject) o);
        Set<Id> ids = XC_UTIL_Sobject_U_Retrieve.getSetIdsOnField(sObjectList, 'id');
        System.assert(ids != null);
    }
   
    @isTest
    private static void getSetIdsTEST(){
        Opportunity o = [SELECT Id, RecordTypeId FROM Opportunity LIMIT 1];
        List<SObject> sObjectList = new List<SObject>();
        sObjectList.add( (SObject) o);
        Set<Id> ids = XC_UTIL_Sobject_U_Retrieve.getSetIds(sObjectList);
        System.assert(ids != null);
    }
    @isTest
    private static void getSetIdsStringOnFieldTEST(){
        Opportunity o = [SELECT Id, RecordTypeId FROM Opportunity LIMIT 1];
        List<SObject> sObjectList = new List<SObject>();
        sObjectList.add( (SObject) o);
        Set<String> idsString = XC_UTIL_Sobject_U_Retrieve.getSetIdsStringOnField(sObjectList, 'id');
        System.assert(idsString != null);
    }
    
    @isTest
    private static void retrieveRecordTypNameFromIdTEST(){
        Opportunity o = [SELECT Id, RecordTypeId FROM Opportunity LIMIT 1];
        Id rtId = o.RecordTypeId;
        String idsString = XC_UTIL_Sobject_U_Retrieve.retrieveRecordTypNameFromId(rtId);
        System.assert(idsString != null);
    }
    
    @isTest
    private static void getFieldValueTEST(){
        Opportunity o = [SELECT Id, RecordTypeId FROM Opportunity LIMIT 1];
        String idsString = XC_UTIL_Sobject_U_Retrieve.getFieldValue('Opportunity', 'RecordTypeId', o.id);
        System.assert(idsString != null);
    }
    
    @isTest
    private static void getSetFieldValuesTEST(){
        Opportunity o = [SELECT Id, RecordTypeId FROM Opportunity LIMIT 1];
        List<SObject> sObjectList = new List<SObject>();
        sObjectList.add( (SObject) o);
        Set<String> idsString = XC_UTIL_Sobject_U_Retrieve.getSetFieldValues(sObjectList, 'RecordTypeId');
        System.assert(idsString != null);
    }
    
    @isTest
    private static void getFieldTypeTEST(){
        Opportunity o = [SELECT Id, RecordTypeId FROM Opportunity LIMIT 1];
        Schema.DisplayType idsString = XC_UTIL_Sobject_U_Retrieve.getFieldType('Opportunity', 'RecordTypeId');
        System.assert(idsString != null);
    }
    
    @isTest
    private static void getListAllFieldsTEST(){
        Opportunity o = [SELECT Id, RecordTypeId FROM Opportunity LIMIT 1];
        List<String> listAllFields = XC_UTIL_Sobject_U_Retrieve.getListAllFields('Opportunity');
        System.assert(listAllFields != null);
    }
    
    @isTest
    private static void getObjectTypeTEST(){
        Opportunity o = [SELECT Id, RecordTypeId FROM Opportunity LIMIT 1];
        String idsString = XC_UTIL_Sobject_U_Retrieve.getObjectType(o.id);
        System.assert(idsString != null);
    }
    
    @isTest
    private static void getListFieldsFromFieldSetTEST(){
        Opportunity o = [SELECT Id, RecordTypeId FROM Opportunity LIMIT 1];
        List<String> listAllFields = XC_UTIL_Sobject_U_Retrieve.getListFieldsFromFieldSet('Account','XC_ESP_Account_New_Mandatory');
        System.assert(listAllFields != null);
    }
    
    @isTest
    private static void getFieldsFromListFieldSetsTEST(){
        Opportunity o = [SELECT Id, RecordTypeId FROM Opportunity LIMIT 1];
        List<String> stringList = new List<String>();
        stringList.add('XC_ESP_Account_New_Mandatory');
        List<String> listAllFields = XC_UTIL_Sobject_U_Retrieve.getFieldsFromListFieldSets('Account', stringList);
        System.assert(listAllFields != null);
    }
}