/**
 * @author            : Davide Desideri
 * @created date      :
 * @description       :
 * @testClasses       :
 * @last modified by  : Davide Desideri
 * @last modified on  : 13-06-2023
 **/
@isTest
public with sharing class ReSubmitOfCampaignMembersErrors_Test {
  @TestSetup
  public static void setup() {

    List<Account> personAccounts = TestDataFactory.createAccounts();

    Contact c = [SELECT Id FROM Contact WHERE IsPersonAccount = TRUE LIMIT 1];
    C.OtherLatitude = double.valueOf('41.90126572748891');
    C.OtherLongitude = double.valueOf('12.490667866110426');
    c.Flag_Stato__c = '0';
    c.MobilePhone = '3294930203';

    update c;

    Campaign camp = new Campaign();
    camp.Name = 'test';
    camp.CountTarget__c = 0;
    insert camp;

    Campaign_Member_Error__c campMembError = new Campaign_Member_Error__c(
      CampaignId__c = camp.Id,
      ContactId__c = c.Id,
      ErrorDescription__c = 'error',
      CountTarget__c = 0
    );
    insert campMembError;
  }

  @isTest
  public static void ReSubmitOfCampaignMembersErrorsMethod1() {
    Campaign campToPass = [SELECT Id,CountTarget__c FROM Campaign LIMIT 1];
    Test.startTest();
    Database.executeBatch(new BatchReSubmitOfCampaignMembersErrors(campToPass.Id, campToPass.CountTarget__c), 5);
    Test.stopTest();
  }
}