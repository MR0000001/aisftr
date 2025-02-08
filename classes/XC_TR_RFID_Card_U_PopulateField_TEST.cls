/**
* @author Dario Tramontin - dtramontin@deloitte.it 
* @date Creation 31/07/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_RFID_Card_U_PopulateField_TEST – Test for XC_TR_RFID_Card_U_PopulateField
*/
@isTest
public without sharing class XC_TR_RFID_Card_U_PopulateField_TEST {

    @IsTest
    static void onBeforeInsert(){
        XC_RFID_Card__c rfid= new XC_RFID_Card__c(); 
        rfid.Name='test';
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        insert rfid; 
        Test.stopTest();
        System.assert(rfid!=null,'Error insert RFID_Card');
    }
}