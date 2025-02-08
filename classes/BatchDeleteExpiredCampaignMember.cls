/**
 * @author            : Davide Desideri
 * @created date      :
 * @description       :
 * @testClasses       : CreationOfCampaignMember_Test
 * @last modified by  : Davide Desideri
 * @last modified on  : 07-06-2023
 **/
global with sharing class BatchDeleteExpiredCampaignMember implements Database.Batchable<SObject>, Database.Stateful {
  public Id campaignId;

  global BatchDeleteExpiredCampaignMember(Id campaignId) {
    this.campaignId = campaignId;
  }

  global Database.QueryLocator start(Database.BatchableContext bc) {
    Integer passedCampaignCountTarget = integer.valueOf(
      [SELECT CountTarget__c FROM Campaign WHERE Id = :campaignId LIMIT 1].CountTarget__c
    );
    System.debug(passedCampaignCountTarget);
    string query = 'SELECT Id,CountTarget__c,CampaignId FROM CampaignMember WHERE CountTarget__c != :passedCampaignCountTarget AND CampaignId =:campaignId';
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext bc, List<CampaignMember> scope) {
    delete scope;
  }

  global void finish(Database.BatchableContext bc) {
    CampaignUtils.sendEmailFinishPopulateCampaign(this.campaignId);
  }
}