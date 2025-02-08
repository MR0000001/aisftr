/**
 * @author            : Davide Desideri
 * @created date      :
 * @description       :
 * @testClasses       : ReSubmitOfCampaignMembersErrors_Test
 * @last modified by  : Davide Desideri
 * @last modified on  : 06-06-2023
 **/
global without sharing class BatchReSubmitOfCampaignMembersErrors implements Database.Batchable<SObject>, Database.Stateful {
  // private String campaignIdParameter;
  public Id campaignId;
  public Decimal countTarget;

  public BatchReSubmitOfCampaignMembersErrors(Id campaignId, Decimal countTargets) {
    this.campaignId = campaignId;
    this.countTarget = countTargets;
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    string query = 'SELECT Id, ContactId__c, CampaignId__c,CountTarget__c,CampaignMember_Key__c,Phone_MC__c FROM Campaign_Member_Error__c WHERE CampaignId__c =:campaignId AND CountTarget__c =:countTarget';
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext bc, List<Campaign_Member_Error__c> scope) {
    List<CampaignMember> cmList = new List<CampaignMember>();
    Map<String, Campaign_Member_Error__c> campaignMemberErrorMap = new Map<String, Campaign_Member_Error__c>();
    List<Campaign_Member_Error__c> campaignMemberErrorListToDelete = new List<Campaign_Member_Error__c>();

    List<Id> contactIdList = new List<Id>();

    for (Campaign_Member_Error__c cme : scope) {
      campaignMemberErrorMap.put(cme.ContactId__c, cme);
      cmList.add(
        new CampaignMember(
          CampaignId = this.campaignId,
          ContactId = cme.ContactId__c,
          Status = 'Sent',
          CountTarget__c = cme.CountTarget__c,
          CampaignMember_Key__c = cme.CampaignMember_Key__c,
          Phone_MC__c = cme.Phone_MC__c
        )
      );
    }

    // Database.insert(cmList, false);
    List<Database.UpsertResult> results = Database.upsert(cmList, CampaignMember.Fields.CampaignMember_Key__c, false);

    for (CampaignMember newCampaignMember : cmList) {
      if (newCampaignMember.Id != null) {
        if (campaignMemberErrorMap.containsKey(newCampaignMember.ContactId)) {
          campaignMemberErrorListToDelete.add(campaignMemberErrorMap.get(newCampaignMember.ContactId));
        }
      }
    }
    delete campaignMemberErrorListToDelete;
  }

  global void finish(Database.BatchableContext bc) {
    System.debug('FINISH at BatchReSubmitOfCampaignMembersErrors end');
    // CampaignUtils.sendEmailFinishPopulateCampaign(campaignIdParameter);
    Database.executeBatch(new BatchDeleteExpiredCampaignMember(this.campaignId), 200);
  }
}