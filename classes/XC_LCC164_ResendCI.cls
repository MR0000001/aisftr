/**
 * The Class XC_LCC164_ResendCI.
 *
 * @author Simone Trenta - strenta@deloitte.it, Giuseppe Di Bonito - gdibonito@deloitte.it
 * @date Creation 16/10/2019
 * @date Modification dd/mm/yyyy
 * @description 
 */
public without sharing class XC_LCC164_ResendCI {

    /**
    * @author Simone Trenta - strenta@deloitte.it, Giuseppe Di Bonito - gdibonito@deloitte.it
    * @date Creation 16/10/2019
    * @date Modification dd/mm/yyyy
    * @description clone ci for resend  
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper resend(String idCI, String email) {
        
        Map<Id, XC_Customer_Interaction__c> ciMap = new Map<Id, XC_Customer_Interaction__c>([
            SELECT 
                Id, XC_AccountId__c, XC_Anonymous__c, XC_BillingProfileId__c, 
                XC_CaseId__c, XC_CaseReason__c, XC_Channel__c, XC_Communication_Type__c,
                XC_Connection_ID__c, XC_ContactId__c, XC_DestinationInteractionID__c, XC_Direction__c,
                XC_Doc_ID_List__c, XC_Doc_URL_List__c, XC_Email__c, XC_Enel_Call_Number__c, XC_Enel_Tel_Number__c, 
                XC_EWT__c, XC_GL_Name__c, XC_LeadId__c, XC_LegalEntity__c, XC_OpportunityId__c, XC_OrderId__c, 
                XC_Phone__c, XC_PhotoURL__c, XC_Preferredlanguageofcontact__c, XC_ProductId__c, XC_ServiceAppointmentExId__c, 
                XC_ServiceAppointmentId__c, XC_SkipCommunication__c, XC_Source__c, XC_Subject__c, 
                XC_SurveyId__c , XC_SurveyUrl__c, XC_WO_WorkType__c, XC_WorkOrderId__c,XC_Segment__c, XC_Invoice__c, 
                XC_Subscription__c, XC_BusinessLine__c, xc_billingaccount__c, XC_Recipient__c, XC_AssetId__c, XC_ConfigurationItem__c, 
                XC_AdditionalInfo1__c, XC_AdditionalInfo2__c, XC_AdditionalInfo3__c, XC_LeadIdEncrypt__c
            FROM XC_Customer_Interaction__c
            WHERE id =: idCI
        ]);

        XC_Customer_Interaction__c ci = ciMap.values()[0];
        ci.id = null;
        if(email != null){
            ci.XC_Email__c = email;
        }
        XC_UTIL_Sobject.WrapperResult res = XC_UTIL_Sobject.insertRecord(ci);
        XC_UTIL_ResultWrapper rew = new XC_UTIL_ResultWrapper();
        rew.success = res.success;
        rew.resultMessage = res.errorMessage;
        rew.recordId = res.recordId;

        return rew;
    }
    
    /**
    * @author Giuseppe Di Bonito - gdibonito@deloitte.it
    * @date Creation 10/07/2020
    * @date Modification dd/mm/yyyy
    * @description get emails to check for resend ci
    */
    @AuraEnabled
    public static Map<String, String> getEmails(String idCI) {
        
        List<XC_Customer_Interaction__c> ciList = new List<XC_Customer_Interaction__c>([
            SELECT Id, XC_Channel__c, XC_ContactId__c, XC_Email__c, XC_LeadId__c, XC_ContactId__r.Email, XC_LeadId__r.Email
            FROM XC_Customer_Interaction__c  
            WHERE id =: idCI
        ]);

        Map<String, String> emailsMap = new Map<String, String>();
        emailsMap.put('channel', ciList[0].XC_Channel__c);
        emailsMap.put('ciEmail', ciList[0].XC_Email__c);
        emailsMap.put('contactEmail', ciList[0].XC_ContactId__r.Email);
        emailsMap.put('leadEmail', ciList[0].XC_LeadId__r.Email);

        return emailsMap;
    }

}