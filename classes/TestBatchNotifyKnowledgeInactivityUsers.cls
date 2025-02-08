/**
 * @author            : Daniel Perrella
 * @created date      :
 * @description       :
 * @testClasses       :
 * @last modified by  : Daniel Perrella
 * @last modified on  : 20-11-2023
 **/
@IsTest
public with sharing class TestBatchNotifyKnowledgeInactivityUsers {
  @TestSetup
  public static void setup() {
    String profileName = 'Istruttore';

    PermissionSetGroup psg = [SELECT Id, Status FROM PermissionSetGroup WHERE DeveloperName = :profileName];
    // force calculation of the PSG if it is not already Updated
    if (psg.Status != 'Updated') {
      Test.calculatePermissionSetGroup(psg.Id);
    }

    insert new User(
      isActive = true,
      UserPermissionsKnowledgeUser = true,
      ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName]
      .Id,
      LastName = 'Admin',
      Email = 'test1@test.com',
      Alias = 'NotifKM',
      Username = 'testRomaCapitale@test.com',
      CommunityNickname = 'test121',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'GMT',
      LanguageLocaleKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      SerialNumber__c = '1234TestClass',
      LastKnowledgeNotification__c = null
    );
  }

  @IsTest
  public static void execute() {
    insert new UserNotificationKM__c(NoNotifications__c = false, Inactivity_Days__c = 1);
    Test.startTest();
    String sch0 = '0 00 * * * ?';
    System.schedule(
      'ScheduleNotifyKnowledgeInactivityUsers ' + ' hh:10',
      sch0,
      new BatchNotifyKnowledgeInactivityUsers()
    );
    Test.stopTest();
  }
}