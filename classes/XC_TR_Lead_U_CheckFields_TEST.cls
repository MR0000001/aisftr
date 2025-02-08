/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 31/03/2020
* @description XC_TR_Lead_U_CheckFields_TEST – Test class for XC_TR_Lead_U_CheckFields
*/  

@isTest
private class XC_TR_Lead_U_CheckFields_TEST {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Lead_U_CheckFields_TEST');

    @isTest
    static void onMajorAge() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Lead ld = XC_DF_Lead.createResidentialLead();
        ld.XC_BirthDate__c = Date.today().addYears(-100);
        ld.XC_MainLegalEntity__c = 'EndesaX';

        Test.startTest();
        insert ld;
        ld.XC_BirthDate__c = Date.today().addYears(-90);
        update ld;
        System.assertNotEquals(ld.Id, null);
        Test.stopTest();
    }

    @isTest
    static void onStatus() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Lead ld = XC_DF_Lead.createSohoLeads(1)[0];
        ld.XC_MainLegalEntity__c = 'EndesaX';
        ld.XC_Segment__c = 'B2B';
        insert ld;

        Test.startTest();
        ld.Status = Label.XC_CL_ErrorStatusLead;
        update ld;
        Test.stopTest();
    }

}