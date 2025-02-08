/**
 * @author            : Davide Desideri
 * @created date      :
 * @description       :
 * @testClasses       :
 * @last modified by  : Davide Desideri
 * @last modified on  : 13-06-2023
 **/
@isTest
public with sharing class CreationOfCampaignMember_Test {
  @TestSetup
  public static void setup() {
    Campaign camp = new Campaign();
    camp.Name = 'test';
    camp.CountTarget__c = 0;
    camp.Distance__c = 10;
    camp.Geolocation__Latitude__s = double.valueOf('41.90126572748891');
    camp.Geolocation__Longitude__s = double.valueOf('12.490667866110426');
    insert camp;

    List<Account> personAccounts = TestDataFactory.createAccounts();
    Contact c = [SELECT Id FROM Contact WHERE IsPersonAccount = TRUE LIMIT 1];
    C.OtherLatitude = double.valueOf('41.90126572748891');
    C.OtherLongitude = double.valueOf('12.490667866110426');
    c.Flag_Stato__c = '0';
    c.MobilePhone = '3294930203';
    update c;
  }

  @isTest
  public static void CreationOfCampaignMemberMethod1() {
    Campaign campToPass = [SELECT Id FROM Campaign LIMIT 1];
    Test.startTest();
    Database.executeBatch(new CreationOfCampaignMember(campToPass.Id));
    Test.stopTest();
  }

  // @isTest
  // public static void CreationOfCampaignMemberMethodKO() {
  //   Campaign campToPass = [SELECT Id, CountTarget__c FROM Campaign LIMIT 1];
  //   user u = createUsers();
  //   System.runAs(u) {
  //     Test.startTest();
  //     try {
  //       Database.executeBatch(new CreationOfCampaignMember(campToPass.Id));
  //     } catch (Exception e) {
  //       System.debug('siamo exceptionali');
  //     }
  //     Test.stopTest();
  //   }
  // }

  // public static User createUsers() {
  //   User u = new User();
  //   u.LastName = 'Chatter';
  //   u.Email = 'ChatterTest1@test.com';
  //   u.Alias = 'TCcode2';
  //   u.Username = 'testRomaCapitale2@test.com';
  //   u.CommunityNickname = 'test122';
  //   u.LocaleSidKey = 'en_US';
  //   u.TimeZoneSidKey = 'GMT';
  //   u.ProfileId = [SELECT Id, Name FROM Profile WHERE Name = 'Chatter Free User'].Id;
  //   u.LanguageLocaleKey = 'en_US';
  //   u.EmailEncodingKey = 'UTF-8';
  //   u.IsActive = true;
  //   u.UserPermissionsMarketingUser = false;
  //   insert u;
  //   return u;
  // }
}