/**
 * @author            : Davide Desideri
 * @created date      :
 * @description       :
 * @testClasses       : TestDeleteCampaignMemberTrigger
 * @last modified by  : Davide Desideri
 * @last modified on  : 07-06-2023
 **/
public with sharing class CampaignMemberService {
  public static void TriggerHandlerBeforeDelete(List<CampaignMember> cmList) {
    List<Profile> p = [
      SELECT Id, Name
      FROM Profile
      WHERE
        Id = :userinfo.getProfileId()
        AND (Name = 'System Administrator'
        OR Name = 'Protezione Civile'
        OR Name = 'Amministratore di Sistema')
      LIMIT 1
    ];
    for (CampaignMember cm : cmList) {
      if ((p.size() < 1)) {
        cm.addError(System.Label.CampaignMember_Delete);
      }
    }
  }
}