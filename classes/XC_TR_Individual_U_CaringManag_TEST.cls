/**
    * @author Emanuela Cacace ecacace@deloitte.it
    * @date Creation  22/05/2019 
    * @description XC_TR_Individual_U_CaringManag_TEST – Test class for XC_TR_Individual_U_CaringManagement
    */ 
    @isTest
public with sharing class XC_TR_Individual_U_CaringManag_TEST {
     // Test method for deletePersonalDocument 
     static testMethod void deletePersonalDocument(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            Test.startTest();
                Individual i = new Individual();
                i.LastName='Rossi';
                i.XC_GiveDataToThirdParties__c= 'No'; 
                insert i ; 
                i.XC_GiveDataToThirdParties__c= 'Yes'; 
                update i ; 
            System.assertEquals('Yes', i.XC_GiveDataToThirdParties__c,'wrong assertEquals');
            Test.stopTest();
     }

}