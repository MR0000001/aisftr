/**
 * @author            : Davide Desideri
 * @created date      :
 * @description       :
 * @testClasses       :
 * @last modified by  : Davide Desideri
 * @last modified on  : 13-06-2023
 **/
@isTest
public with sharing class TestDeleteExpiredCampaignMemberErrors {
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

    Campaign_Member_Error__c cme = new Campaign_Member_Error__c();
    cme.CampaignId__c = camp.Id;
    cme.ContactId__c = c.Id;
    insert cme;
    Datetime yesterday = Datetime.now().addDays(-1);
    Test.setCreatedDate(cme.Id, yesterday);

    BatchDeleteExpiredCampaignMemberErrors__c setting = new BatchDeleteExpiredCampaignMemberErrors__c();
    setting.Previous_Months__c = 0.0;
    setting.Batch_Size__c = 5.0;
    insert setting;
  }

  @isTest
  public static void TestDeleteExpiredCampaignMemberError() {
    BatchDeleteExpiredCampaignMemberErrors__c setting = BatchDeleteExpiredCampaignMemberErrors__c.getInstance();
    Test.startTest();
    Database.executeBatch(new BatchDeleteExpiredCampaignMemberErrors(), Integer.valueOf(setting.Batch_Size__c));
    Test.stopTest();
  }

  @isTest
  public static void TestBatchScheduled() {
    BatchDeleteExpiredCampaignMemberErrors__c setting = BatchDeleteExpiredCampaignMemberErrors__c.getInstance();

    Test.startTest();
    BatchDeleteExpiredCampaignMemberErrors batch = new BatchDeleteExpiredCampaignMemberErrors();
    Database.executeBatch(batch, Integer.valueOf(setting.Batch_Size__c));

    System.schedule('BatchDeleteExpiredCampaignMemberErrors', '0 17 * ? * * *', batch);
    Test.stopTest();
  }
}