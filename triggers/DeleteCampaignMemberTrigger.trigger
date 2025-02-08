/**
 * @author            : Davide Desideri
 * @created date      :
 * @description       :
 * @testClasses       : TestDeleteCampaignMemberTrigger
 * @last modified by  : Davide Desideri
 * @last modified on  : 06-06-2023
 **/
trigger DeleteCampaignMemberTrigger on CampaignMember(before delete) {
  private FeatureEnablement__mdt skipTrigger = FeatureEnablement__mdt.getInstance('CampaignMemberTrigger');

  if (skipTrigger == null || skipTrigger.isActive__c) {
    if (Trigger.isDelete) {
      if (Trigger.isBefore) {
        CampaignMemberService.TriggerHandlerBeforeDelete(Trigger.old);
      }
    }
  }

}