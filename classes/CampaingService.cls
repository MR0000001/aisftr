/**
 * @author            : Daniel Perrella
 * @created date      :
 * @description       :
 * @testClasses       : TestCampaignTrigger
 * @last modified by  : Davide Desideri
 * @last modified on  : 07-06-2023
 **/
public with sharing class CampaingService {
  public static void TriggerHandlerBeforeUpdate(Map<Id, Campaign> triggerOld, Map<Id, Campaign> triggerNew) {
    for (Id key : triggerOld.keySet()) {
      {
        if (
          triggerOld.get(key).Status != triggerNew.get(key).Status &&
          triggerNew.get(key).Status == 'Target Citizens' &&
          (triggerNew.get(key).Geolocation__Longitude__s == null ||
          triggerNew.get(key).Geolocation__Latitude__s == null ||
          triggerNew.get(key).Distance__c == null)
        ) {
          triggerNew.get(key).addError(System.Label.ErrorApproveCampaign);
        }
      }
    }
  }
}