/**
 * @author            : Daniel Perrella
 * @created date      : 11-10-2023
 * @description       : 
 * @testClasses       : 
 * @last modified by  : Daniel Perrella
 * @last modified on  : 11-10-2023
**/
@IsTest
public without sharing class AmaTari_Test {
  @TestSetup
  public static void setup() {
    TestDataFactory.createWSO2Keys();
  }

  @IsTest
  public static void getCfOK() {
    Test.startTest();
    try {
      Test.setMock(HttpCalloutMock.class, new MockHttpResponseAmaTari(true));
      AmaTariController.getTari('AAAAAAAAAA',false);
    } catch (Exception e) {
      System.debug('Exception at: ' + e.getMessage());
    }
    Test.stopTest();
  }

  @IsTest
  public static void getPivaOk() {
    Test.startTest();
    try {
      Test.setMock(HttpCalloutMock.class, new MockHttpResponseAmaTari(true));
      AmaTariController.getTari('010101',true);
    } catch (Exception e) {
      System.debug('Exception at: ' + e.getMessage());
    }
    Test.stopTest();
  }

  @IsTest
  public static void getCfKO() {
    Test.startTest();
    try {
      Test.setMock(HttpCalloutMock.class, new MockHttpResponseAmaTari(false));
      AmaTariController.getTari('AAAAAAAAAA',false);
    } catch (Exception e) {
      System.debug('Exception at: ' + e.getMessage());
    }
    Test.stopTest();
  }

  @IsTest
  public static void getAvvisiPagamentoOK() {
    Test.startTest();
    try {
      Test.setMock(HttpCalloutMock.class, new MockHttpResponseAmaTari(true));
      AmaTariController.getAvvisiPagamento('01010','010101');
    } catch (Exception e) {
      System.debug('Exception at: ' + e.getMessage());
    }
    Test.stopTest();
  }

  @IsTest
  public static void getAvvisiPagamentoKO() {
    Test.startTest();
    try {
      Test.setMock(HttpCalloutMock.class, new MockHttpResponseAmaTari(false));
      AmaTariController.getAvvisiPagamento('01010','010101');
    } catch (Exception e) {
      System.debug('Exception at: ' + e.getMessage());
    }
    Test.stopTest();
  }

  @IsTest
  public static void getOperandiTranscoding() {
    Test.startTest();
    try {
      AmaTariController.getOperandiTranscoding();
    } catch (Exception e) {
      System.debug('Exception at: ' + e.getMessage());
    }
    Test.stopTest();
  }
}