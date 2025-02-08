/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation  07/02/2020 
* @description XC_TR_RFID_Card_TEST – Test class for XC_TR_RFID_Card_Handler
*/ 
@isTest
public class XC_TR_RFID_Card_TEST {
    @isTest
    static void insertTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        XC_RFID_Card__c rfidCard = new XC_RFID_Card__c();
        insert rfidCard;
        Test.stopTest();
        System.assertEquals(true, rfidCard.Id != null);
    }
    
     @isTest
    static void updateTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        XC_RFID_Card__c rfidCard = new XC_RFID_Card__c();
        insert rfidCard;
        update rfidCard;
        Test.stopTest();
        System.assertEquals(true, rfidCard.Id != null);
    }
    
    @isTest
    static void deleteTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
       	XC_RFID_Card__c rfidCard = new XC_RFID_Card__c();
        insert rfidCard;
        delete rfidCard;
        Test.stopTest();
        System.assertEquals(true, rfidCard.Id != null);
    }
}