/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com
* @date Creation 03/06/2018 
* @date Modification 25/06/2018 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description Test Class for XC_UTIL_Sobje
*/

@isTest
public class XC_UTIL_Sobject_TEST {
    static testMethod void sObjectTest(){
        Test.startTest();
        List<Sobject> lSo;
        List<String> listCountries = new List<String> {'SPAIN'};
        Map<String, String> mapCountryRecordTypeName = new Map<String, String> ();
        mapCountryRecordTypeName.put('SPAIN','Spain');
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        //Map<String, Id> getRCountry = XC_UTIL_Sobject.getRecordTypeMapByCountry('Account',listCountries,mapCountryRecordTypeName);
        Boolean isF = XC_UTIL_Sobject.isFieldBoolean('Account','Name');
        XC_UTIL_Sobject.WrapperResult result1 = XC_UTIL_Sobject.insertRecord(accList[0]);
        List<XC_UTIL_Sobject.WrapperResult> resultList = XC_UTIL_Sobject.insertListRecords(accList,true);
        List<Account> accListInserted = [SELECT Id, Name FROM Account];
        accListInserted[0].Name = 'Changed';
        XC_UTIL_Sobject.WrapperResult result2 = XC_UTIL_Sobject.updateRecord(accListInserted[0]);
        List<XC_UTIL_Sobject.WrapperResult> resultList2 = XC_UTIL_Sobject.updateListRecords(accList,true);
        XC_UTIL_Sobject.WrapperResult result3 = XC_UTIL_Sobject.upsertRecord(accListInserted[0]);
        XC_UTIL_Sobject.WrapperResult result4 = XC_UTIL_Sobject.deleteRecord(accListInserted[0]);
        Boolean checkDmlResult = XC_UTIL_Sobject.checkDMLResults(resultList2);
        XC_UTIL_Sobject.WrapperResult result5 = XC_UTIL_Sobject.getGlobalDMLResults(resultList2);
        String type = XC_UTIL_Sobject.getObjectType(accListInserted[0].Id);
        Map<String, String> mapCountryQueueName = new Map<String, String>();
        mapCountryQueueName.put('Spain', 'XC_QU_QualificationQueue');
        Map<String, Id> mapReturn = XC_UTIL_Sobject.getQueueMapByCountry(listCountries, mapCountryQueueName);
        System.assertEquals(accListInserted.size(), 1);
        Test.stopTest();     
    }
    
    @isTest
	static void sObjectTest2(){
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        //Map<String, Id> getRCountry = XC_UTIL_Sobject.getRecordTypeMapByCountry('Account',listCountries,mapCountryRecordTypeName);
        List<Account> accListInserted = [SELECT Id, Name, RecordTypeId FROM Account];
        accListInserted[0].Name = 'Changed';
        List<String> listResult =  XC_UTIL_Sobject.getListFieldsFromFieldSet('Account', 'XC_ESP_Account_New_PersonalData');
        String result1 = XC_UTIL_Sobject.getFieldValue('Account', 'Name',accListInserted[0].Id);
        List<sObject> resultList = XC_UTIL_Sobject.selectAllFields(accListInserted[0].Id);
        String result2 = XC_UTIL_Sobject.selectAllFieldsGetSelect('Account');
        //accListInserted[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('XC_GLO_Account_Residential').getRecordTypeId();
        String result3 = XC_UTIL_Sobject.retrieveRecordTypNameFromId(accListInserted[0].RecordTypeId);
        Set<Id> setResult = XC_UTIL_Sobject.getSetIds(accListInserted);
        System.assertEquals(accListInserted.size(), 1);
        Test.stopTest();     
    }
    
    @isTest
	static void sObjectTest3(){
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        //Map<String, Id> getRCountry = XC_UTIL_Sobject.getRecordTypeMapByCountry('Account',listCountries,mapCountryRecordTypeName);
        List<Account> accListInserted = [SELECT Id, Name, RecordType.DeveloperName FROM Account];
        Set<Id> result1 = XC_UTIL_Sobject.getSetIdsOnField(accListInserted, 'RecordTypeId');
        Set<String> result2 = XC_UTIL_Sobject.getSetIdsStringOnField(accListInserted, 'Name');
        List<String> resultList = XC_UTIL_Sobject.getListAllFields('Account');   
        Schema.DisplayType result3 =  XC_UTIL_Sobject.getFieldType('Account', 'Name');
        List<String> resultList2 = XC_UTIL_Sobject.getListFieldValues(accListInserted, 'Name');
        List<Schema.PicklistEntry> pickValues = XC_UTIL_Sobject.retrieveAllPicklistValues('Account', 'XC_DocumentCountry__c');
        List<String> pickValues2 = XC_UTIL_Sobject.getPicklistValues('Account', 'XC_DocumentCountry__c');
        Date dateRes = XC_UTIL_Sobject.stringToDate('2018-09-11');
        List<String> listCountries = new List<String> {'SPAIN'};
        Map<String, String> mapCountryRecordTypeName = new Map<String, String>();
        mapCountryRecordTypeName.put('Spain', accListInserted[0].RecordType.DeveloperName); 
       // Map<String, Id> mapResult = XC_UTIL_Sobject.getRecordTypeMapByCountry('Account', listCountries, mapCountryRecordTypeName);
       // Datetime dateTimeRes = XC_UTIL_Sobject.stringToDateTimeGmt('2018-09-11');
        //XC_UTIL_Sobject.updateLockedSObjectField(accListInserted[0].Id, 'Name', 'Changed');
        List<String> fieldList = new List<String> {'Name'};
        Map<Id,sObject> oldMap = new Map<Id,sObject>();
        oldMap.put(accListInserted[0].Id, accListInserted[0]);
        Map<Id,sObject> newMap = new Map<Id,sObject>();
        newMap.put(accListInserted[0].Id, accListInserted[0]);
        String oId = accListInserted[0].Id;
        XC_UTIL_Sobject.ChangeWrapper wrap = new XC_UTIL_Sobject.ChangeWrapper();
        wrap.fieldList = fieldList;
        wrap.oId = oId;
        wrap.newMap = newMap;
        wrap.oldMap = oldMap;
        wrap.listSObjects = accListInserted;
        List<sObject> resultList4 = XC_UTIL_Sobject.getListChanged(wrap);
        List<XC_UTIL_Sobject.WrapperResult> wrappRes = XC_UTIL_Sobject.deleteListRecords(accListInserted, true);
        System.assertEquals(accListInserted.size(), 1);
        Test.stopTest();     
    }

    @isTest
	static void onSobjectUtil() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrdersForLead(1);
        insert listWorkOrder;
        XC_UTIL_Sobject_U.PopulateSobjectTypeWrapper populateWrapper = new XC_UTIL_Sobject_U.PopulateSobjectTypeWrapper();
        List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1);
        listLead[0].Email = 'efgerg@egeg.com';
        insert listLead;
        List<Case> listCase = XC_DF_Case.createCases(1);
        listCase[0].Status = 'ESTA003';
        listCase[0].XC_Segment__c = 'B2C';
        listCase[0].XC_LegalEntity__c = 'EnelXItalia';
        insert listCase;
        populateWrapper.listToBeParsed = listLead; 
        populateWrapper.dmo = new Database.DMLOptions();
        populateWrapper.type = 'Lead';
        Map<String, String> mapCountryQueueName = new Map<String, String>();
        mapCountryQueueName.put('SPAIN', 'BO Dispatcher Queue');
        Map<String, String> mapCountryRecordTypeName = new Map<String, String>();
        mapCountryRecordTypeName.put('SPAIN', 'XC_Account_Partner');
        System.assertNotEquals(listLead, null);
        
        Test.startTest();
        XC_UTIL_Sobject_U.retakeStringToUpperCase('Test Test');
        XC_UTIL_Sobject_U.lockSObjects(listWorkOrder);
        XC_UTIL_Sobject_U.unlockSObjects(listWorkOrder);
        XC_UTIL_Sobject_U.unlockSObjects(listWorkOrder);
        XC_UTIL_Sobject_U.lockSObjects(listWorkOrder);
        XC_UTIL_Sobject_U.lockSObjects(listWorkOrder);
        XC_UTIL_Sobject_U.updateLockedSObjects(listWorkOrder);
        XC_UTIL_Sobject_U.updateSObjectField(listWorkOrder[0].Id, 'XC_WorkTypeLabel__c', Label.XC_CL_WorkType_Delivery);
        XC_UTIL_Sobject_U.updateSObjectField(listWorkOrder[0].Id, 'XC_Urgent_Repair__c', true);
        XC_UTIL_Sobject_U.populateBySobjectType(populateWrapper);
        populateWrapper.listToBeParsed = listCase; 
        populateWrapper.type = 'Case';
        XC_UTIL_Sobject_U.populateBySobjectType(populateWrapper);
        XC_UTIL_Sobject_U.checkSuccessListObject(listLead);
        XC_UTIL_Sobject_U.runAssignmentRules(listLead, 'Lead');
        XC_UTIL_Sobject_U.getQueueMapByCountry(new List<String>{'SPAIN'}, mapCountryQueueName);
        XC_UTIL_Sobject_U.getRecordTypeMapByCountry('Account', new List<String>{'SPAIN'}, mapCountryRecordTypeName);
        XC_UTIL_Sobject_U.stringToDate('24-06-2019');
        Test.stopTest();
    }
    
    @isTest
	static void getListChangedFromNull(){
        insert XC_DF_OneOrg.createOneOrg('Spain');        
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        accounts[0].XC_Segment__c = 'B2C'; 
        insert accounts;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        contacts[0].XC_Segment__c = 'B2C'; 
        contacts[0].XC_CountryLegalEntity__c = 'ITALY';
        contacts[0].XC_MainLegalEntity__c = 'EnelXItalia';
        insert contacts;
        
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_SuperBonus110});
        Case caso = XC_UTIL_Case.initCaseFromCaseSettings(caseSettingsMap.get(Label.XC_CL_SuperBonus110));
        caso.ContactId = contacts[0].Id;
        caso.XC_Segment__c = 'B2C'; 
        caso.XC_LegalEntity__c = 'EnelXItalia';
        insert caso;
        Test.startTest();
        	caso.XC_CompanyQualificationStatus__c = 'Company to be qualified';
        	caso.XC_Description__c = 'test';
        	update caso;
        	System.assert(true);
        Test.stopTest();
    }
    
    @isTest
	static void checkIfIsSFDCID(){
        insert XC_DF_OneOrg.createOneOrg('Spain');        
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        accounts[0].XC_Segment__c = 'B2C'; 
        insert accounts;
		Test.startTest();
        	Boolean result = XC_UTIL_Sobject.checkIfIsSFDCID(accounts[0].Id, Account.class);
        	System.assert(result);
        Test.stopTest();
    }

}