/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  14/05/2019 
* @description XC_TR_Account_TEST – Test class for XC_TR_Account
*/ 
@isTest
public with sharing class XC_TR_Account_TEST {
    //Test method getServiceAppointmentToUpdate
    static testMethod void insertTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        Test.stopTest();
        System.assertEquals(true, !accList.isEmpty());
    }
    
    static testMethod void deleteTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        delete accList; 
        Test.stopTest();
    }
    
    @isTest
    static void testCF() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        accList[0].XC_FirstName__c = 'testa';
        accList[0].XC_LastName__c = 'testa';
        accList[0].XC_AccountType__c = 'Residential';
        accList[0].IdentityNumber__c = 'TSTTST80A01H501G';
        accList[0].IdentityType__c = 'CF';
        
        
        
        insert accList;
        
        accList[0].IdentityNumber__c = 'abc';
        try{
            update accList;
        } catch(exception e){
            xc_util_debug.debug(true, e+'');
        }
        
        Test.stopTest();
    }
    
        @isTest
    static void updateacc() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);

        
        
        
        insert accList;
        accList[0].XC_FirstName__c = 'testa';
        accList[0].XC_LastName__c = 'testa';
        acclist[0].XC_Notes__c = 'test';
        acclist[0].XC_DocumentsUploadComplete__c = true;

        
        update accList;

        
        Test.stopTest();
    }
    
    
}