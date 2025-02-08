/**
 * @author            : Davide Desideri
 * @created date      :
 * @description       :
 * @testClasses       :
 * @last modified by  : Davide Desideri
 * @last modified on  : 31-05-2023
 **/
trigger CampaignTrigger on Campaign(before update) {
  private FeatureEnablement__mdt skipTrigger = FeatureEnablement__mdt.getInstance('CampaignTrigger');

  if (skipTrigger == null || skipTrigger.isActive__c) {
    if (Trigger.isUpdate) {
      if (Trigger.isBefore) {
        CampaingService.TriggerHandlerBeforeUpdate(Trigger.oldMap, Trigger.newMap);
      }
    }
  }
}