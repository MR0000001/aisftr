/**
 * @author            : Davide Desideri
 * @created date      :
 * @description       :
 * @testClasses       :
 * @last modified by  : Davide Desideri
 * @last modified on  : 05-06-2023
 **/
@isTest
public with sharing class BonificaIndirizziTest {
  @isTest
  public static void bonificaIndirizziTest1() {
    Test.startTest();
    BonificaIndirizzi.bonificaIndirizzo('VIA ROMA 10');
    Test.stopTest();
  }
}