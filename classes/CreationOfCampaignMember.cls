/**
 * @author            : Davide Desideri
 * @created date      :
 * @description       :
 * @testClasses       : CreationOfCampaignMember_Test
 * @last modified by  : Daniel Perrella
 * @last modified on  : 11-10-2023
 **/
global without sharing class CreationOfCampaignMember implements Database.Batchable<SObject>, Database.Stateful {
  private String campaignId;
  private Boolean hasError = false;
  public Campaign campaign;

  public CreationOfCampaignMember(String campaignId) {
    this.campaignId = campaignId;
  }

  global Database.QueryLocator start(Database.BatchableContext bc) {
    campaign = [
      SELECT Id, CountTarget__c, Geolocation__Latitude__s, Geolocation__Longitude__s, Distance__c, Privacy_Newsletter__c
      FROM Campaign
      WHERE Id = :campaignId
      LIMIT 1
    ];
    Decimal latitude = campaign.Geolocation__Latitude__s;
    Decimal longitude = campaign.Geolocation__Longitude__s;
    Decimal distance = campaign.Distance__c / 1000;
    String query =
      'SELECT Id,Flag_Stato__c,IsPersonAccount,Send_Communication__c,OtherAddress,AccountId,OtherPhone,MobilePhone,Phone_MC__c FROM Contact WHERE Flag_Stato__c = \'0\' AND IsPersonAccount = true AND Send_Communication__c = true AND DISTANCE(OtherAddress, GEOLOCATION( ' +
      latitude +
      ' , ' +
      longitude +
      ' ), \'km\') < ' +
      distance;
    if (campaign.Privacy_Newsletter__c) {
      query += ' AND Privacy_Newsletter__c = true';
    }
    System.debug('CreationOfCampaignMember.start - query:' + query);
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext bc, List<Contact> scope) {
    List<CampaignMember> campaignMemberList = new List<CampaignMember>();
    List<Campaign_Member_Error__c> campaignMemberErrorList = new List<Campaign_Member_Error__c>();

    for (Contact c : scope) {
      campaignMemberList.add(
        new CampaignMember(
          ContactId = c.Id,
          Status = 'Sent',
          CampaignId = this.campaignId,
          CampaignMember_Key__c = c.Id + this.campaignId,
          CountTarget__c = this.campaign.CountTarget__c,
          Phone_MC__c = c.Phone_MC__c
        )
      );
    }
    System.debug('numero dei campaign member da creare ' + campaignMemberList.size());
    // List<Database.SaveResult> results = Database.insert(campaignMemberList, false);
    List<Database.UpsertResult> results = Database.upsert(
      campaignMemberList,
      CampaignMember.Fields.CampaignMember_Key__c,
      false
    );
    campaignMemberErrorList = CampaignUtils.checkResults(results, campaignMemberList);
    if (!campaignMemberErrorList.isEmpty()) {
      Database.insert(campaignMemberErrorList);
      this.hasError = true;
    }
  }

  global void finish(Database.BatchableContext bc) {
    System.debug('FINISH at CreationOfCampaignMember end');
    if (this.hasError) {
      Database.executeBatch(
        new BatchReSubmitOfCampaignMembersErrors(this.campaignId, this.campaign.CountTarget__c),
        200
      );
    } else {
      // CampaignUtils.sendEmailFinishPopulateCampaign(campaignId);
      Database.executeBatch(new BatchDeleteExpiredCampaignMember(this.campaignId), 200);
    }
  }
}