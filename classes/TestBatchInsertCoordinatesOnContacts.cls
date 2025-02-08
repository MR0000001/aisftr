/**
 * @author            : Davide Desideri
 * @created date      :
 * @description       :
 * @testClasses       :
 * @last modified by  : Davide Desideri
 * @last modified on  : 12-06-2023
 **/
@isTest
public with sharing class TestBatchInsertCoordinatesOnContacts {
  @TestSetup
  public static void setup() {
    TestDataFactory.createWSO2Keys();
    List<Account> personAccount = TestDataFactory.createAccounts();
    Contact c = [SELECT Id FROM Contact LIMIT 1];
    c.Flag_Stato__c = '0';
    c.OtherStreet = 'VIA GIUSEPPE PEREGO 8';
    c.MobilePhone = '3293909334';
    c.OtherLatitude = null;
    update c;
  }

  @isTest
  public static void TestBatch() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeoroma(true));
    Test.startTest();
    Database.executeBatch(new BatchInsertCoordinatesOnContacts(), 5);
    Test.stopTest();
  }

  @isTest
  public static void TestBatchWithNullAddress() {
    Test.startTest();
    List<Contact> cont = [SELECT Id, OtherStreet FROM Contact WHERE OtherStreet = NULL];
    BatchInsertCoordinatesOnContacts batch = new BatchInsertCoordinatesOnContacts();
    Database.executeBatch(batch, 5);
    batch.execute(null, cont);
    Test.stopTest();
  }

  @isTest
  public static void TestBatchWithIncompleteAddress() {
    Test.startTest();
    List<Contact> cont = [SELECT Id, OtherStreet FROM Contact WHERE OtherStreet = NULL];
    cont[0].OtherStreet = 'VIA ROMA';
    update cont;
    BatchInsertCoordinatesOnContacts batch = new BatchInsertCoordinatesOnContacts();
    Database.executeBatch(batch, 5);
    batch.execute(null, cont);
    Test.stopTest();
  }

  @isTest
  public static void TestBatchScheduled() {
    Test.startTest();
    BatchInsertCoordinatesOnContacts batch = new BatchInsertCoordinatesOnContacts();
    Database.executeBatch(batch, 5);

    System.schedule('BatchInsertCoordinatesOnContacts', '0 17 * ? * * *', batch);
    Test.stopTest();
  }
}