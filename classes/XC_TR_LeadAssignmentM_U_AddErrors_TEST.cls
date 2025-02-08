@isTest
public with sharing class XC_TR_LeadAssignmentM_U_AddErrors_TEST {
    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        List<XC_LeadAssignmentMaster__c> leadAssignmentMasterList = new List<XC_LeadAssignmentMaster__c>();
        for(Integer i = 0; i<5; i++){
            XC_LeadAssignmentMaster__c lam = new XC_LeadAssignmentMaster__c();
            lam.XC_LegalEntity__c  = 'EndesaX';
            lam.XC_RecordTypePick__c = 'Spain';
            lam.XC_ProductCategoryOfInterest__c = 'Iluminación LED';
            lam.XC_Email__c = 'Testleadtest@test.it';
            lam.XC_Country__c = 'Spain';
            lam.XC_City__c = 'Madrid';
            lam.XC_PrimaryPhone__c = 'No';
            lam.XC_Address__c = 'Yes';
            lam.XC_ZipCode__c = '28001';
            lam.XC_Status__c = 'Assigned';
            lam.XC_AssignedToCreator__c  = true;
            system.debug('@TEST@ lam->'+ lam);
            leadAssignmentMasterList.add(lam); 
        } 
        insert leadAssignmentMasterList;
    }

    @IsTest
    static void testUpdate(){
        Test.startTest();
        List<XC_LeadAssignmentMaster__c> lamList = [SELECT ID, XC_ZipCode__c FROM XC_LeadAssignmentMaster__c];
        update lamList[0];
        System.assert(!lamList.isEmpty());
        Test.stopTest();
    }

    @IsTest
    static void testDelete(){
        Test.startTest();
        List<XC_LeadAssignmentMaster__c> lamList = [SELECT ID, XC_ZipCode__c FROM XC_LeadAssignmentMaster__c];
        delete lamList[0];
        System.assert(!lamList.isEmpty());
        Test.stopTest();
    }
}