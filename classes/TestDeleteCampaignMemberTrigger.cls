/**
 * @author            : Davide Desideri
 * @created date      :
 * @description       :
 * @testClasses       :
 * @last modified by  : Davide Desideri
 * @last modified on  : 13-06-2023
 **/
@IsTest
public with sharing class TestDeleteCampaignMemberTrigger {
  @TestSetup
  public static void setup() {
    List<Account> personAccount = TestDataFactory.createAccounts();
    Contact c = [SELECT Id FROM Contact LIMIT 1];
    Campaign camp = new Campaign(Name = 'Campagna Test');
    insert camp;

    CampaignMember cm = new CampaignMember();
    cm.campaignId = camp.Id;
    cm.Status = 'Sent';
    cm.ContactId = c.Id;
    insert cm;
  }

  @IsTest
  public static void TestDeleteCampaignMember() {
    // User u = createUser();
    CampaignMember cmToDelete = [SELECT Id FROM CampaignMember LIMIT 1];
    Test.startTest();
    // System.runAs(u) {
    try {
      delete cmToDelete;
    } catch (Exception e) {
      System.debug('Exception: ' + e.getMessage());
    }
    // }
  }

  // public static user createUser() {
  //   return TestDataFactory.createAnotherUserWithRoleLeaderCC();
  // }
}