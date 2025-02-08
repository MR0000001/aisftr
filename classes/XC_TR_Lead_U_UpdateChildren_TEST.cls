/**
    * @author Emanuela Cacace ecacace@deloitte.it
    * @date Creation  23/05/2019 
    * @description XC_TR_Lead_U_UpdateChildren_TEST – Test class for XC_TR_Lead_U_UpdateChildren
    */ 
    @isTest
public with sharing class XC_TR_Lead_U_UpdateChildren_TEST {
     static testMethod void deletePersonalDocument(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            Test.startTest();
            List<XC_Address__c> add = XC_DF_Address.createAddress(1);
            insert add;
            List<Lead> l =XC_DF_Lead.createResidentialLeadsWithAddress(1);
            insert l; 
            l[0].XC_Country__c='Spain';
            l[0].XC_Address__c= 'Test';  
            l[0].XC_LeadAddress__c= add[0].Id; 
            add[0].XC_Lead__c = l[0].Id ; 
            update add;
            update l; 
            

            System.assertEquals(1, l.size());
         Test.stopTest();
     }
    
    static testMethod void createAddressTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Lead> l =XC_DF_Lead.createResidentialLeadsWithAddress(1);
        insert l; 
        l[0].XC_Country__c='Spain';
        l[0].XC_Address__c= 'Test';  
        Map<id, Lead> lmap = new Map<id, Lead>();
        lmap.put(l[0].id, l[0]);
        XC_TR_Lead_U_UpdateChildren.createAddress(lmap);
        
        System.assertEquals(1, l.size());
        Test.stopTest();
    }
    
    static testMethod void createAddressForDataImport(){
        List<Lead> l =XC_DF_Lead.createResidentialLeadsWithAddress(1);
        l[0].XC_Segment__c = 'B2B';
        l[0].XC_Country__c = 'Italy';
       	l[0].XC_City__c = 'Roma';
        l[0].XC_Address__c = 'Piazza del popolo 7';
        l[0].XC_MassivelyCreated__c = true;
        
        Test.startTest();
        	XC_TR_Lead_U_UpdateChildren.createAddressForDataImport(l);
        Test.stopTest();
    }

    
    static testMethod void createAddressForDataImportAfterInsert(){
        List<Lead> l =XC_DF_Lead.createResidentialLeadsWithAddress(1);
        l[0].XC_Segment__c = 'B2B';
        l[0].XC_Country__c = 'Italy';
       	l[0].XC_City__c = 'Roma';
        l[0].XC_Address__c = 'Piazza del popolo 7';
        l[0].XC_MassivelyCreated__c = true;
        
        Test.startTest();
        	XC_TR_Lead_U_UpdateChildren.createAddressForDataImportAfterInsert(l);
        Test.stopTest();
    }


}