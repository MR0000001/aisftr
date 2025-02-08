/**
 * @author            : Davide Desideri
 * @created date      :
 * @description       :
 * @testClasses       : TestDeleteExpiredCampaignMemberErrors
 * @last modified by  : Davide Desideri
 * @last modified on  : 12-06-2023
 **/
global without sharing class BatchDeleteExpiredCampaignMemberErrors implements Database.Batchable<SObject>, Schedulable {
  private static BatchDeleteExpiredCampaignMemberErrors__c setting = BatchDeleteExpiredCampaignMemberErrors__c.getInstance();

  global Database.QueryLocator start(Database.BatchableContext BC) {
    Date createdDateToDelete = Date.today().addMonths(integer.valueOf('-' + setting.Previous_Months__c));
    System.debug(createdDateToDelete);
    String query = 'SELECT id, ContactId__c, CampaignId__c FROM Campaign_Member_Error__c WHERE CreatedDate <: createdDateToDelete ';
    System.debug(query);
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext bc, List<Campaign_Member_Error__c> scope) {
    delete scope;
  }

  global void finish(Database.BatchableContext bc) {
    System.debug('FINISH at BatchDeleteExpiredCampaignMemberErrors end');
  }

  global static void execute(SchedulableContext ctx) {
    try {
      Database.executeBatch(new BatchDeleteExpiredCampaignMemberErrors(), Integer.valueOf(setting.Batch_Size__c));
    } catch (Exception e) {
      throw ErrorLogEventHandler.standardExceptionLog(e);
    }
  }
}