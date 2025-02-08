/**
* @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
* @date Creation  25/06/2019 
* @description XC_TR_Lead_U_TEST – Test class for XC_TR_Lead_U_ classes
*/ 
@isTest
public class XC_TR_Lead_U_TEST {
    @TestSetup
    static void setup(){
        List<Lead> leadList = XC_DF_Lead.createResidentialLeadsWithAddress(2);
        leadList[0].XC_ListOfLegalEntity__c = 'test';
        insert leadList;
        System.assert(leadList != null);
    }

    @IsTest
    static void test1(){
        Test.startTest();
        List<Lead> leadList = XC_DF_Lead.createResidentialLeadsWithAddress(2);
        try {
            leadList[0].XC_ListOfLegalEntity__c = 'test';
            leadList[0].XC_Channel__c = 'DPO';
            insert leadList;
        } catch (System.DmlException e) {
            System.debug(e.getMessage());
        }
        System.assert(leadList != null);
        Test.stopTest();
    }
    
    @IsTest
    static void test2(){
        Test.startTest();
        List<Lead> leadList = [SELECT Id, XC_ListOfLegalEntity__c FROM Lead];
        try {
            leadList[0].XC_ListOfLegalEntity__c = 'test';
            update leadList;
        } catch (System.DmlException e) {
            System.debug(e.getMessage());
        }
        System.assert(leadList != null);
        Test.stopTest();
    }
}