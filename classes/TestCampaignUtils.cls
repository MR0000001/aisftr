/**
 * @author            : Davide Desideri
 * @created date      :
 * @description       :
 * @testClasses       :
 * @last modified by  : Davide Desideri
 * @last modified on  : 13-06-2023
 **/
@isTest
public with sharing class TestCampaignUtils {
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

    CampaignMember cm = new CampaignMember();
    cm.CampaignId = camp.Id;
    cm.ContactId = c.Id;
    cm.CountTarget__c = 2;
    cm.Phone_MC__c = '06060606';
    insert cm;
  }

  @isTest
  public static void TestCampaignUtilsKOUpsert() {
    List<Campaign_Member_Error__c> returnedList = new List<Campaign_Member_Error__c>();
    List<CampaignMember> cmList = [SELECT Id, CampaignId, ContactId, Phone_MC__c,CountTarget__c FROM CampaignMember LIMIT 1];
    List<Lead> leads = new List<Lead>();
    for (Integer i = 0; i < 100; i++) {
      leads.add(new Lead(LastName = '', Company = 'testCompany'));
    }

    List<Lead> leadsToPass = new List<Lead>();
    Lead L = new Lead();
    leadsToPass.add(L);
    /* Switch to the runtime limit context */
    Test.startTest();

    /* Exercise the method */
    List<Database.upsertResult> results = Database.upsert(leadsToPass, Lead.Fields.Id, false);
    CampaignUtils.checkResults(results, cmList);

    Test.stopTest();
  }
}