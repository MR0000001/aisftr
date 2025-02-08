/**
* @author Simone Trenta - strenta@deloitte.it , Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation 06/08/2019
* @date Modification ..
* @description XC_TR_CampaignMember – Trigger on CampaignMember
*/

trigger XC_TR_CampaignMember on CampaignMember (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    XC_TR_Dispatcher.init(new XC_TR_CampaignMember_Handler(), Trigger.operationType);
}