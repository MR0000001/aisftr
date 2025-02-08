/* @author Marco Ottaviano mottaviano@deloitte.it
* @date Creation 29/03/2021
* @description XC_SC047_AutoCloseLead_TEST – Test class for XC_SC047_AutoCloseLead
*/ 


@isTest
public class XC_SC047_AutoCloseLead_TEST {

    @TestSetup
    static void makeData(){
        insert XC_DF_OneOrg.createOneOrg('Spain');

        User adminUser = XC_DF_User.createUserAdmin();
        adminUser.XC_LegalEntity__c ='EnelXItalia';
        adminUser.Country__c = 'ITALY';
        insert adminUser;

        Test.startTest();
        System.runAs(adminUser) {
             
            List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1);
            listLead[0].XC_MainLegalEntity__c = 'EnelXItalia';
            listLead[0].XC_Segment__c ='B2C';
            insert listLead;
        }
        Test.stopTest();
    }

    @isTest
      static void ExecuteBatch() {
       
        Test.startTest();
        Database.executeBatch(new XC_SC047_AutoCloseLead(), 50); 
        XC_SC047_AutoCloseLead.getErrorLog('test', 'test');
        Test.stopTest();
    }
}