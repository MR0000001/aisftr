/**
 * @author            : Davide Desideri
 * @created date      : 
 * @description       : 
 * @testClasses       : 
 * @last modified by  : Davide Desideri
 * @last modified on  : 07-06-2023
**/
@isTest
public with sharing class TestCampaignTrigger {
  @TestSetup
  public static void setup() {
    List<Account> personAccount = TestDataFactory.createAccounts();
    Contact c = [SELECT Id FROM Contact LIMIT 1];
    Campaign camp = new Campaign(Name = 'Campagna Test', Status = 'Approval Alert');
    insert camp;

    CampaignMember cm = new CampaignMember();
    cm.campaignId = camp.Id;
    cm.Status = 'Sent';
    cm.ContactId = c.Id;
    insert cm;
  }

  @isTest
  public static void TestUpdateTrigger() {
    Campaign camp = [SELECT Id, Status FROM Campaign LIMIT 1];
    camp.Status = 'Target Citizens';
    try {
      update camp;
    } catch (Exception e) {
      System.debug('Exception: ' + e.getMessage());
    }
  }
}