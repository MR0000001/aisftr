/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 29/06/2019
* @date Modification dd/mm/yyyy
* @description  – XC_UTIL_LeadDuplication_TEST - Class test for XC_UTIL_LeadDuplication
*/
@isTest 
private class XC_UTIL_LeadDuplication_TEST {
    /** 
* Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @description insert records
*/
    @TestSetup 
    static void insertRecords(){ 
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<Lead> leadListToInsert = XC_DF_Lead.createResidentialLeads(1);
        
        Lead exLead =leadListToInsert[0];
        exLead.XC_DocumentCountry__c = 'Spain';
        exLead.Email = 'test@testlead.it';
        exLead.XC_DocumentType__c = 'Passport';
        exLead.XC_DocumentNumber__c = 'AL1092001';
        exLead.XC_MainLegalEntity__c = 'EndesaX';
        exLead.FirstName = 'LeadTest';
        exLead.LastName= 'LeadTest';
        exLead.XC_PhonePrefix__c='+39';
        exLead.XC_LeadPhone__c= '0817898789';
        insert leadListToInsert;
    }
    
    static testMethod void callUtilLeadDuplication(){
        List<Lead> leadList = new List<Lead>([SELECT Id, XC_StreetType__c, Email, Status, Phone, FirstName, LastName, XC_DocumentType__c, XC_DocumentNumber__c, XC_LeadPhone__c, XC_PhonePrefix__c, XC_ProductCategoryOfInterest__c, XC_ConcatenatedAddress__c, XC_MainLegalEntity__c, RecordTypeId, 
                                              XC_Address__c, XC_StreetNumber__c, XC_ZipCode__c, XC_City__c, XC_Province__c FROM Lead]);
        
        Test.startTest();
        XC_UTIL_LeadDuplication.checkDuplicates(leadList);
        Test.stopTest();
        
        System.assertEquals(1, leadList.size());
    }
    
    static testMethod void leadDuplicatedPartial(){
        List<Lead> leadList = new List<Lead>([SELECT Id, XC_StreetType__c, Email, Status, Phone, FirstName, LastName, XC_DocumentType__c, XC_DocumentNumber__c, XC_LeadPhone__c, XC_PhonePrefix__c, XC_ProductCategoryOfInterest__c, XC_ConcatenatedAddress__c, XC_MainLegalEntity__c, RecordTypeId, 
                                              XC_Address__c, XC_StreetNumber__c, XC_ZipCode__c, XC_City__c, XC_Province__c FROM Lead LIMIT 1]);
        Lead oldLead = leadList[0];
        
        Lead ld = new Lead();
        ld.XC_DocumentCountry__c = 'Spain';
        ld.Company = 'Company';
        ld.Email = 'test@testlead.it';
        ld.XC_DocumentType__c = 'Passport';
        ld.XC_DocumentNumber__c = 'AL1092001';
        ld.XC_MainLegalEntity__c = 'EndesaX';
        ld.FirstName = 'LeadTestW';
        ld.LastName= 'LeadTestW';
        ld.XC_PhonePrefix__c='+39';
        ld.XC_LeadPhone__c= '0817898782';
        
        List<Lead> newLeadList = new List<Lead>();
        newLeadList.add(ld);
        Test.startTest();
        XC_UTIL_LeadDuplication.checkDuplicates(newLeadList);
        Test.stopTest();
        
        System.assertEquals(1, newLeadList.size());
    }
    
    static testMethod void leadDuplicatedTotal(){
        List<Lead> leadList = new List<Lead>([SELECT Id, XC_StreetType__c, Email, Status, Phone, FirstName, LastName, XC_DocumentType__c, XC_DocumentNumber__c, XC_LeadPhone__c, XC_PhonePrefix__c, XC_ProductCategoryOfInterest__c, XC_ConcatenatedAddress__c, XC_MainLegalEntity__c, RecordTypeId, 
                                              XC_Address__c, XC_StreetNumber__c, XC_ZipCode__c, XC_City__c, XC_Province__c FROM Lead LIMIT 1]);
        Lead oldLead = leadList[0];
        
        Lead ld = new Lead();
        ld.RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
        ld.XC_DocumentCountry__c = 'Spain';
        ld.Company = 'Company';
        ld.Email = 'test@testlead.it';
        ld.XC_DocumentType__c = 'Passport';
        ld.XC_DocumentNumber__c = 'AL1092001';
        ld.XC_MainLegalEntity__c = 'EndesaX';
        ld.FirstName = 'LeadTest';
        ld.LastName= 'LeadTest';
        ld.XC_PhonePrefix__c='+39';
        ld.XC_LeadPhone__c= '0817898782';
        
        List<Lead> newLeadList = new List<Lead>();
        newLeadList.add(ld);
        Test.startTest();
        XC_UTIL_LeadDuplication.checkDuplicates(newLeadList);
        Test.stopTest();
        
        System.assertEquals(1, newLeadList.size());
    }
    
    static testMethod void leadDuplicatedWithAddressAndProduct(){
        List<Lead> leadList = new List<Lead>([SELECT Id, XC_StreetType__c, Email, Status, Phone, FirstName, LastName, XC_DocumentType__c, XC_DocumentNumber__c, XC_LeadPhone__c, XC_PhonePrefix__c, XC_ProductCategoryOfInterest__c, XC_ConcatenatedAddress__c, XC_MainLegalEntity__c, RecordTypeId, 
                                              XC_Address__c, XC_StreetNumber__c, XC_ZipCode__c, XC_City__c, XC_Province__c FROM Lead LIMIT 1]);
        Lead oldLead = leadList[0];
        
        Lead ld = new Lead();
        ld.RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
        ld.XC_DocumentCountry__c = 'Spain';
        ld.Company = 'Company';
        ld.Email = 'test@testlead.it';
        ld.XC_DocumentType__c = 'Passport';
        ld.XC_DocumentNumber__c = 'AL1092001';
        ld.XC_MainLegalEntity__c = 'EndesaX';
        ld.FirstName = 'LeadTest';
        ld.LastName= 'LeadTest';
        ld.XC_PhonePrefix__c='+39';
        ld.XC_LeadPhone__c= '0817898782';
        ld.XC_ProductCategoryOfInterest__c = 'Boiler';
        ld.XC_ConcatenatedAddress__c ='Calle Espana 23';
        ld.XC_StreetType__c = 'Street';
        ld.XC_Address__c = 'Espana';
        ld.XC_StreetNumber__c = '22';
        ld.XC_ZipCode__c ='08082';
        ld.XC_City__c='Barcelona';
        ld.XC_Province__c='Barcelona';
        
        List<Lead> newLeadList = new List<Lead>();
        newLeadList.add(ld);
        Test.startTest();
        XC_UTIL_LeadDuplication.checkDuplicates(newLeadList);
        Test.stopTest();
        
        System.assertEquals(1, newLeadList.size());
    }
    
    static testMethod void leadDuplicatedWIthExistingProductCategory(){
        List<Lead> leadList = new List<Lead>([SELECT Id, XC_StreetType__c, Email, Status, Phone, FirstName, LastName, XC_DocumentType__c, XC_DocumentNumber__c, XC_LeadPhone__c, XC_PhonePrefix__c, XC_ProductCategoryOfInterest__c, XC_ConcatenatedAddress__c, XC_MainLegalEntity__c, RecordTypeId, 
                                              XC_Address__c, XC_StreetNumber__c, XC_ZipCode__c, XC_City__c, XC_Province__c FROM Lead LIMIT 1]);
        Lead oldLead = leadList[0];
        oldLead.XC_ProductCategoryOfInterest__c = 'Caldera';
        update oldLead;
        Lead ld = new Lead();
        ld.RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
        ld.XC_DocumentCountry__c = 'Spain';
        ld.Company = 'Company';
        ld.Email = 'test@testlead.it';
        ld.XC_DocumentType__c = 'Passport';
        ld.XC_DocumentNumber__c = 'AL1092001';
        ld.XC_MainLegalEntity__c = 'EndesaX';
        ld.FirstName = 'LeadTest';
        ld.LastName= 'LeadTest';
        ld.XC_PhonePrefix__c='+39';
        ld.XC_LeadPhone__c= '0817898782';
        ld.XC_ProductCategoryOfInterest__c = 'Calentador';
        List<Lead> newLeadList = new List<Lead>();
        newLeadList.add(ld);
        Test.startTest();
        XC_UTIL_LeadDuplication.checkDuplicates(newLeadList);
        Test.stopTest();
        
        System.assertEquals(1, newLeadList.size());
    }
    
    
    static testMethod void leadDuplicatedWIthExistingAddress(){
        List<Lead> leadList = new List<Lead>([SELECT Id, XC_StreetType__c, Email, Status, Phone, FirstName, LastName, XC_DocumentType__c, XC_DocumentNumber__c, XC_LeadPhone__c, XC_PhonePrefix__c, XC_ProductCategoryOfInterest__c, XC_ConcatenatedAddress__c, XC_MainLegalEntity__c, RecordTypeId, 
                                              XC_Address__c, XC_StreetNumber__c, XC_ZipCode__c, XC_City__c, XC_Province__c FROM Lead LIMIT 1]);
        Lead oldLead = leadList[0];
        oldLead.XC_ConcatenatedAddress__c ='Calle Espana 23';
        oldLead.XC_StreetType__c = 'Street';
        oldLead.XC_Address__c = 'Espana';
        oldLead.XC_StreetNumber__c = '22';
        oldLead.XC_ZipCode__c ='08082';
        oldLead.XC_City__c='Barcelona';
        oldLead.XC_Province__c='Barcelona';        
        update oldLead;
        Lead ld = new Lead();
        ld.RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
        ld.XC_DocumentCountry__c = 'Spain';
        ld.Company = 'Company';
        ld.Email = 'test@testlead.it';
        ld.XC_DocumentType__c = 'Passport';
        ld.XC_DocumentNumber__c = 'AL1092001';
        ld.XC_MainLegalEntity__c = 'EndesaX';
        ld.FirstName = 'LeadTest';
        ld.LastName= 'LeadTest';
        ld.XC_PhonePrefix__c='+39';
        ld.XC_LeadPhone__c= '0817898782';
        ld.XC_ProductCategoryOfInterest__c = 'Calentador';
        ld.XC_ConcatenatedAddress__c ='Calle Espana 21';
        ld.XC_StreetType__c = 'Street';
        ld.XC_Address__c = 'Espanola';
        ld.XC_StreetNumber__c = '11';
        ld.XC_ZipCode__c ='08081';
        ld.XC_City__c='Barca';
        ld.XC_Province__c='Barca';        
        List<Lead> newLeadList = new List<Lead>();
        newLeadList.add(ld);
        Test.startTest();
        XC_UTIL_LeadDuplication.checkDuplicates(newLeadList);
        Test.stopTest();
        
        System.assertEquals(1, newLeadList.size());
    }
    
    static testMethod void leadDuplicatedWIthExistingAddressAndProduct(){
        List<Lead> leadList = new List<Lead>([SELECT Id, XC_StreetType__c, Email, Status, Phone, FirstName, LastName, XC_DocumentType__c, XC_DocumentNumber__c, XC_LeadPhone__c, XC_PhonePrefix__c, XC_ProductCategoryOfInterest__c, XC_ConcatenatedAddress__c, XC_MainLegalEntity__c, RecordTypeId, 
                                              XC_Address__c, XC_StreetNumber__c, XC_ZipCode__c, XC_City__c, XC_Province__c FROM Lead LIMIT 1]);
        Lead oldLead = leadList[0];
        oldLead.XC_ProductCategoryOfInterest__c = 'Calentador';        
        update oldLead;
        Lead ld = new Lead();
        ld.RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
        ld.XC_DocumentCountry__c = 'Spain';
        ld.Company = 'Company';
        ld.Email = 'test@testlead.it';
        ld.XC_DocumentType__c = 'Passport';
        ld.XC_DocumentNumber__c = 'AL1092001';
        ld.XC_MainLegalEntity__c = 'EndesaX';
        ld.FirstName = 'LeadTest';
        ld.LastName= 'LeadTest';
        ld.XC_PhonePrefix__c='+39';
        ld.XC_LeadPhone__c= '0817898782';
        ld.XC_ProductCategoryOfInterest__c = 'Calentador';
        ld.XC_ConcatenatedAddress__c ='Calle Espana 21';
        ld.XC_StreetType__c = 'Street';
        ld.XC_Address__c = 'Espanola';
        ld.XC_StreetNumber__c = '11';
        ld.XC_ZipCode__c ='08081';
        ld.XC_City__c='Barca';
        ld.XC_Province__c='Barca';        
        List<Lead> newLeadList = new List<Lead>();
        newLeadList.add(ld);
        Test.startTest();
        XC_UTIL_LeadDuplication.checkDuplicates(newLeadList);
        Test.stopTest();
        
        System.assertEquals(1, newLeadList.size());
    }
    
    static testMethod void leadDuplicatedWIthEqualProduct(){
        List<Lead> leadList = new List<Lead>([SELECT Id, XC_StreetType__c, Email, Status, Phone, FirstName, LastName, XC_DocumentType__c, XC_DocumentNumber__c, XC_LeadPhone__c, XC_PhonePrefix__c, XC_ProductCategoryOfInterest__c, XC_ConcatenatedAddress__c, XC_MainLegalEntity__c, RecordTypeId, 
                                              XC_Address__c, XC_StreetNumber__c, XC_ZipCode__c, XC_City__c, XC_Province__c FROM Lead LIMIT 1]);
        Lead oldLead = leadList[0];
        oldLead.XC_ProductCategoryOfInterest__c = 'Calentador';        
        update oldLead;
        Lead ld = new Lead();
        ld.RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
        ld.XC_DocumentCountry__c = 'Spain';
        ld.Company = 'Company';
        ld.Email = 'test@testlead.it';
        ld.XC_DocumentType__c = 'Passport';
        ld.XC_DocumentNumber__c = 'AL1092001';
        ld.XC_MainLegalEntity__c = 'EndesaX';
        ld.FirstName = 'LeadTest';
        ld.LastName= 'LeadTest';
        ld.XC_PhonePrefix__c='+39';
        ld.XC_LeadPhone__c= '0817898782';
        ld.XC_ProductCategoryOfInterest__c = 'Calentador';
        ld.XC_ConcatenatedAddress__c ='|||||';      
        List<Lead> newLeadList = new List<Lead>();
        newLeadList.add(ld);
        Test.startTest();
        XC_UTIL_LeadDuplication.checkDuplicates(newLeadList);
        Test.stopTest();
        
        System.assertEquals(1, newLeadList.size());
    }
    
    static testMethod void leadDuplicatedWIthEmailDuplicated(){
        List<Lead> leadList = new List<Lead>([SELECT Id, XC_StreetType__c, Email, Status, Phone, FirstName, LastName, XC_DocumentType__c, XC_DocumentNumber__c, XC_LeadPhone__c, XC_PhonePrefix__c, XC_ProductCategoryOfInterest__c, XC_ConcatenatedAddress__c, XC_MainLegalEntity__c, RecordTypeId, 
                                              XC_Address__c, XC_StreetNumber__c, XC_ZipCode__c, XC_City__c, XC_Province__c FROM Lead LIMIT 1]);
        Lead oldLead = leadList[0];
        oldLead.Email = 'testinglead@test.it';        
        update oldLead;
        Lead ld = new Lead();
        ld.RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
        ld.XC_DocumentCountry__c = 'Spain';
        ld.Company = 'Company TEST';
        ld.Email = 'testinglead@test.it'; 
        List<Lead> newLeadList = new List<Lead>();
        newLeadList.add(ld);
        Test.startTest();
        XC_UTIL_LeadDuplication.checkDuplicates(newLeadList);
        Test.stopTest();
        
        System.assertEquals(1, newLeadList.size());
    }
    
    static testMethod void leadDuplicatedWIthPhoneDuplicated(){
        List<Lead> leadList = new List<Lead>([SELECT Id, XC_StreetType__c, Email, Status, Phone, FirstName, LastName, XC_DocumentType__c, XC_DocumentNumber__c, XC_LeadPhone__c, XC_PhonePrefix__c, XC_ProductCategoryOfInterest__c, XC_ConcatenatedAddress__c, XC_MainLegalEntity__c, RecordTypeId, 
                                              XC_Address__c, XC_StreetNumber__c, XC_ZipCode__c, XC_City__c, XC_Province__c FROM Lead LIMIT 1]);
        Lead oldLead = leadList[0];
        oldLead.XC_PhonePrefix__c = '+34';
        oldLead.XC_LeadPhone__c = '612345678';        
        update oldLead;
        Lead ld = new Lead();
        ld.RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
        ld.XC_DocumentCountry__c = 'Spain';
        ld.Company = 'Company TEST';
        ld.XC_PhonePrefix__c = '+34';
        ld.XC_LeadPhone__c = '612345678'; 
        List<Lead> newLeadList = new List<Lead>();
        newLeadList.add(ld);
        Test.startTest();
        XC_UTIL_LeadDuplication.checkDuplicates(newLeadList);
        Test.stopTest();
        
        System.assertEquals(1, newLeadList.size());
    }
    
    static testMethod void leadDuplicatedB2B(){
        List<Lead> leadList = new List<Lead>([SELECT Id, XC_StreetType__c, Email, Status, Phone, FirstName, LastName, XC_DocumentType__c, XC_DocumentNumber__c, XC_LeadPhone__c, XC_PhonePrefix__c, XC_ProductCategoryOfInterest__c, XC_ConcatenatedAddress__c, XC_MainLegalEntity__c, RecordTypeId, 
                                              XC_Address__c, XC_StreetNumber__c, XC_ZipCode__c, XC_City__c, XC_Province__c FROM Lead LIMIT 1]);
        Lead oldLead = leadList[0];
        Id b2BRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        
        Lead ld = new Lead();
        ld.RecordTypeId = b2BRecordTypeId;
        ld.XC_DocumentCountry__c = 'Spain';
        ld.XC_Segment__c = 'B2B';
        ld.Company = 'CompanyB2B';
        ld.Email = 'testB2B@testlead.it';
        ld.XC_DocumentType__c = 'Passport';
        ld.XC_DocumentNumber__c = 'AL1092099';
        ld.XC_MainLegalEntity__c = 'EndesaX';
        ld.FirstName = 'LeadTestW';
        ld.LastName= 'LeadTestW';
        ld.XC_PhonePrefix__c='+39';
        ld.XC_LeadPhone__c= '0817898733';
        
        List<Lead> newLeadList = new List<Lead>();
        newLeadList.add(ld);
        insert newLeadList;
        
        Lead ld2 = new Lead();
        ld2.RecordTypeId = b2BRecordTypeId;
        ld2.XC_DocumentCountry__c = 'Spain';
        ld2.XC_Segment__c = 'B2B';
        ld2.Company = 'CompanyB2B';
        ld2.Email = 'testB2B@testlead.it';
        ld2.XC_DocumentType__c = 'Passport';
        ld2.XC_DocumentNumber__c = 'AL1092099';
        ld2.XC_MainLegalEntity__c = 'EndesaX';
        ld2.FirstName = 'LeadTestW';
        ld2.LastName= 'LeadTestW';
        ld2.XC_PhonePrefix__c='+39';
        ld2.XC_LeadPhone__c= '0817898733';
        List<Lead> newLeadList2 = new List<Lead>();
        newLeadList2.add(ld2);
        Test.startTest();
        XC_UTIL_LeadDuplication.checkDuplicates(newLeadList2);
        Test.stopTest();
        
        System.assertEquals(1, newLeadList.size());
    }
}