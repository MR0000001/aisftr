/**
 * @author            : Daniel Perrella
 * @created date      :
 * @description       :
 * @testClasses       : CreationOfCampaignMember_Test,TestCampaignUtils
 * @last modified by  : Davide Desideri
 * @last modified on  : 13-06-2023
 **/
public with sharing class CampaignUtils {
  public static void sendEmailFinishPopulateCampaign(String campaignIdParameter) {
    if (String.isNotBlank(campaignIdParameter)) {
      List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

      EmailTemplate emailTemplete = [
        SELECT Id, DeveloperName
        FROM EmailTemplate
        WHERE DeveloperName = 'Send_Campaign_Alert'
        LIMIT 1
      ];

      Campaign campaignToUse = [
        SELECT Id, OwnerId, Owner.Email, Owner.IsActive, Status, Record_Read_Only__c
        FROM Campaign
        WHERE Id = :campaignIdParameter
      ];

      if (campaignToUse.Owner.IsActive) {
        Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(
          emailTemplete.Id,
          campaignToUse.OwnerId,
          campaignIdParameter
        );
        message.setTargetObjectId(campaignToUse.OwnerId); //required se presente template email
        // message.setToAddresses(new List<String>{ campaignToUse.Owner.Email });
        message.setToAddresses(new List<String>{ campaignToUse.Owner.Email });

        message.setSenderDisplayName(Email__c.getInstance().WorkingCase__c);
        message.setTreatTargetObjectAsRecipient(false);
        message.setUseSignature(false);
        message.setBccSender(false);
        message.setSaveAsActivity(false);
        messages.add(message);

        for (Messaging.SendEmailResult result : Messaging.sendEmail(messages)) {
          System.debug('isSuccess?: ' + result.isSuccess());
          if (!result.isSuccess()) {
            System.debug('error: ' + result.getErrors());
          }
        }
      }
      campaignToUse.Status = 'Awaiting Alert Activation';
      campaignToUse.Record_Read_Only__c = false;
      campaignToUse.UpdateAction__c = false;
      update campaignToUse;
    }
  }

  public static List<Campaign_Member_Error__c> checkResults(
    List<Database.UpsertResult> results,
    List<CampaignMember> campaignMemberList
  ) {
    List<Campaign_Member_Error__c> campaignMemberErrorList = new List<Campaign_Member_Error__c>();
    for (Integer i = 0; i < results.size(); i++) {
      if (!results[i].isSuccess()) {
        CampaignMember cm = campaignMemberList[i];
        String error = '';
        for (Database.Error err : results[i].getErrors()) {
          error += err.getMessage() + '\n';
        }
        campaignMemberErrorList.add(
          new Campaign_Member_Error__c(
            CampaignId__c = cm.CampaignId,
            ContactId__c = cm.ContactId,
            ErrorDescription__c = error,
            Phone_MC__c = cm.Phone_MC__c != null ? cm.Phone_MC__c : null,
            CampaignMember_Key__c = String.valueOf(cm.ContactId) + String.valueOf(cm.CampaignId),
            CountTarget__c = cm.CountTarget__c
          )
        );
      }
    }
    return campaignMemberErrorList;
  }
}