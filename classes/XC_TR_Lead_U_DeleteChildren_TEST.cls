/**
    * @author Emanuela Cacace ecacace@deloitte.it
    * @date Creation  23/05/2019 
    * @description XC_TR_Lead_U_DeleteChildren_TEST – Test class for XC_TR_Lead_U_DeleteChildren
    */ 
    @isTest
public with sharing class XC_TR_Lead_U_DeleteChildren_TEST {
     // Test method for deletePersonalDocument 
     static testMethod void deletePersonalDocument(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            Test.startTest();
            List<Lead> l =XC_DF_Lead.createResidentialLeads(1);
            insert l; 
            XC_PersonalDocument__c pc =  new XC_PersonalDocument__c();
            pc.XC_Lead__c = l[0].Id ;
            insert pc;
            delete l ; 
            System.assertEquals(1, l.size());
            Test.stopTest();
     }

}