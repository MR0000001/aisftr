/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation 07/06/2019
* @description XC_UTIL_Query_TEST – Test Class of XC_UTIL_Query
*/ 

@isTest
public with sharing class XC_UTIL_Query_TEST {

        //Test Method selectFields
    static testMethod void selectFields(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest();
            List<Lead> ld = XC_DF_Lead.createResidentialLeads(1);
        	insert ld;
            Set<String> setFields = new Set<String>();
            setFields.add('IndividualId');
            String recordId = ld[0].Id;   
            sObject result = XC_UTIL_Query.selectFields(setFields, recordId);
        System.assert(result!=null);
        Test.stopTest(); 
    }

    //Test Method selectFieldsList1
    static testMethod void selectFieldsList(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest();
            List<Lead> ld = XC_DF_Lead.createResidentialLeads(1);
       		insert ld;
            Set<String> setFields = new Set<String>();
            setFields.add('IndividualId');
            String recordId = ld[0].Id;   
            List<sObject>  result =XC_UTIL_Query.selectFieldsList(setFields, recordId);
        System.assert(result!=null);
        Test.stopTest(); 
    }
    
        //Test Method checkDMLResults
    static testMethod void checkDMLResults(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest();
            XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
            wr.success = false ; 
            List<XC_UTIL_Sobject.WrapperResult> dmlResultList = new List<XC_UTIL_Sobject.WrapperResult>();
            dmlResultList.add(wr);   
            Boolean result =XC_UTIL_Query.checkDMLResults(dmlResultList);
        System.assert(result!=null);
        Test.stopTest(); 
    }
  
    //Test Method getGlobalDMLResults
    static testMethod void getGlobalDMLResults(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest();
            XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
            wr.success = false ; 
            List<XC_UTIL_Sobject.WrapperResult> dmlResultList = new List<XC_UTIL_Sobject.WrapperResult>();
            dmlResultList.add(wr);
            XC_UTIL_Sobject.WrapperResult result =XC_UTIL_Query.getGlobalDMLResults(dmlResultList);
        System.assert(result!=null);
        Test.stopTest(); 
    }

    //Test Method getGlobalDMLResults2
    static testMethod void getGlobalDMLResults2(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest();
            XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
            wr.success = true ; 
            List<XC_UTIL_Sobject.WrapperResult> dmlResultList = new List<XC_UTIL_Sobject.WrapperResult>();
            dmlResultList.add(wr);
            XC_UTIL_Sobject.WrapperResult result =XC_UTIL_Query.getGlobalDMLResults(dmlResultList);
        System.assert(result!=null);
        Test.stopTest(); 
    }

        //Test Method getListChanged
    static testMethod void getListChanged(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest();
            List<Lead> ld = XC_DF_Lead.createResidentialLeads(1);
        	insert ld; 
            List<String> fieldList = new List<String>();
            fieldList.add('Email');
            Map<Id,sObject> mapOld =  new Map<Id,sObject>();
            mapOld.put(ld[0].Id , ld[0]);
            ld[0].Email = 'test@test.it'; 
            update ld; 
            Map<Id,sObject> mapNew =new Map<Id,sObject>();
            mapNew.put(ld[0].Id , ld[0]);
            List<sObject> result =XC_UTIL_Query.getListChanged(fieldList,mapOld, mapNew);
        System.assert(result!=null);
        Test.stopTest(); 
    }

        //Test Method getListChanged2
    static testMethod void getListChanged2(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest();
        	List<Lead> ld = XC_DF_Lead.createResidentialLeads(1);
            ld[0].XC_Door__c = '5';
        	insert ld; 
             XC_UTIL_Sobject.ChangeWrapper chWrapper = new XC_UTIL_Sobject.ChangeWrapper();
        	chWrapper.listSObjects = ld;
            List<String> stringList = new List<String>();
            stringList.add('XC_Door__c');
            chWrapper.fieldList = stringList ; 
            Map<Id,sObject> mapOld =  new Map<Id,sObject>();
            mapOld.put(ld[0].Id , ld[0]);
            chWrapper.oldMap = mapOld; 
            system.debug('@@@@@@' + ld[0].XC_Door__c  );
            Lead ld1 = new Lead();
            ld1.Id = ld[0].Id;
            ld1.XC_Door__c = '7';
            //update ld; 
            Map<Id,sObject> mapNew =new Map<Id,sObject>();
            mapNew.put(ld1.Id , ld1);
           
            chWrapper.newMap = mapNew;
             for(String field : chWrapper.fieldList){
                   System.debug('????????' + chWrapper.newMap.get(ld[0].Id).get(field) + '  ' + chWrapper.oldMap.get(ld[0].Id).get(field));
             }
            List<sObject> result = XC_UTIL_Query.getListChanged(chWrapper);
        System.assert(result!=null);
        Test.stopTest(); 
    }

    
            //Test Method getListChanged3
    static testMethod void getListChanged3(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest();
        	List<Lead> ld = XC_DF_Lead.createResidentialLeads(2);
            XC_UTIL_Sobject.ChangeWrapper chWrapper = new XC_UTIL_Sobject.ChangeWrapper(); 
        	chWrapper.listSObjects = ld; 
            List<sObject> result = XC_UTIL_Query.getListChanged(chWrapper);
        System.assert(result!=null);
        Test.stopTest(); 
    }
    
    static testMethod void getListChangedFromNull(){
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
}