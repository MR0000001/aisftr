/**
 * @author            : Davide Desideri
 * @created date      :
 * @description       :
 * @testClasses       :
 * @last modified by  : Daniel Perrella
 * @last modified on  : 12-06-2023
 **/
@isTest
public with sharing class FlowAction_CreationOfCampaignMember_Test {
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
    camp.Distance__c = 2;
    camp.Geolocation__Longitude__s = double.valueOf('12.490667866110426');
    camp.Geolocation__Latitude__s = double.valueOf('41.90126572748891');

    insert camp;
  }

  @isTest
  public static void FlowActionTest() {
    List<Campaign> campList = new List<Campaign>(
      [SELECT Id, Geolocation__Latitude__s, Geolocation__Longitude__s, Distance__c FROM Campaign LIMIT 1]
    );
    FlowAction_CreationOfCampaignMember.Request req = new FlowAction_CreationOfCampaignMember.Request();
    req.CampaignId = campList[0].Id;
    req.BatchSize = 1;
    List<FlowAction_CreationOfCampaignMember.Request> reqList = new List<FlowAction_CreationOfCampaignMember.Request>();
    reqList.add(req);
    Test.startTest();
    FlowAction_CreationOfCampaignMember.callBatchCreationOfCampaignMember(reqList);
    Test.stopTest();
  }
}