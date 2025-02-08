/**
 * The class XC_REST_CustomerInteraction_UU.
 *
 * @author            : Federico Amici - federico.amici@nttdata.com
 * @date Creation     : 07/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Util for XC_REST_CustomerInteraction
 **/
public with sharing class XC_REST_CustomerInteraction_UU {

    /**
     * Manage Insert.
     *
     * @param wrReq the wrapper request
     * @param wrResp the wrapper response
     * @description method to manage insert of Customer Interaction
     */ 
    public static void manageInsert(XC_REST_CustomerInteraction_W.WrapperRequest wrReq, XC_REST_CustomerInteraction_W.WrapperResponse wrResp) {

        List<Contact> contactList = new List<Contact>();
        List<Lead> leadList = new List<Lead>();

        if(String.isNotBlank(wrReq.CustomerInteraction.ContactID)) {

            if(!Schema.sObjectType.Contact.isAccessible()){
                wrResp.Result.Message = 'INTERNAL ERROR';
                wrResp.Result.ErrorCode = '500';
                wrResp.Result.logError = Label.XC_CL_ContactNotAccess;
                return;
            }
            contactList = [SELECT Id, Name, Email, MobilePhone, XC_Preferredlanguageofcontact__c, AccountId FROM Contact WHERE Id =: wrReq.CustomerInteraction.ContactID]; /*ESCEP-1828 MCutillo 11/05/2019*/
            if(contactList.isEmpty()) {
                wrResp.Result.Message = Label.XC_CL_ContactIdNotValid;
                wrResp.Result.ErrorCode = '400';
                return;
            }
            wrReq.CustomerInteraction.AccountId = contactList[0].AccountId;

        } else if(String.isNotBlank(wrReq.CustomerInteraction.LeadID)) {

            if(!Schema.sObjectType.Lead.isAccessible()){
                wrResp.Result.Message = 'INTERNAL ERROR';
                wrResp.Result.ErrorCode = '500';
                wrResp.Result.logError = 'Lead object is not accessible';
                return;
            }
            leadList = [SELECT Id, Name, Email, MobilePhone FROM Lead WHERE Id =: wrReq.CustomerInteraction.LeadID];
            if(leadList.isEmpty()) {
                wrResp.Result.Message = Label.XC_CL_LeadIDNotValid;
                wrResp.Result.ErrorCode = '400';
                return;
            }

        } else if(String.isNotBlank(wrReq.CustomerInteraction.AccountID)) {
            
            contactList = [SELECT Id, Name, Email, MobilePhone, XC_Preferredlanguageofcontact__c FROM Contact WHERE AccountId =: wrReq.CustomerInteraction.AccountID AND XC_PrimaryContact__c = true]; 
            if(contactList.isEmpty()) {
                wrResp.Result.Message = 'ERROR: AccountID not valid';
                wrResp.Result.ErrorCode = '400';
                return;
            }
            wrReq.CustomerInteraction.ContactID = contactList[0].Id;
        
        } else if(String.isNotBlank(wrReq.CustomerInteraction.Email)) {

            contactList = [SELECT Id, Name, Email, MobilePhone, XC_Preferredlanguageofcontact__c, AccountId FROM Contact WHERE Email =: wrReq.CustomerInteraction.Email]; 
            if(contactList.isEmpty()) {
                leadList = [SELECT Id, Name, Email, MobilePhone FROM Lead WHERE Email =: wrReq.CustomerInteraction.Email]; 
                if(leadList.isEmpty()) {
                    wrResp.Result.Message = 'ERROR: Email not valid';
                    wrResp.Result.ErrorCode = '400';
                    return;
                
                } else{
                    wrReq.CustomerInteraction.LeadID = leadList[0].Id;
                }
            } else{
                wrReq.CustomerInteraction.ContactID = contactList[0].Id;
                wrReq.CustomerInteraction.AccountId = contactList[0].AccountId;
            }
        }
        
        XC_REST_CustomerInteraction_W.WrapperResult result = XC_REST_CustomerInteraction_U.createCustomerInteraction(wrReq.CustomerInteraction, leadList, contactList);
        manageCreationCustomerInteraction(result, wrResp);
  
    }

    private static void manageCreationCustomerInteraction(XC_REST_CustomerInteraction_W.WrapperResult result, XC_REST_CustomerInteraction_W.WrapperResponse wrResp) {

        if(result.success) {
            XC_UTIL_SObject.WrapperResult custInterInsertResult = XC_UTIL_SObject.insertRecord(result.custInteraction);
            if(custInterInsertResult.success) {
                wrResp.Result.Message = 'Operation completed successfully';
                wrResp.Result.ErrorCode = '0';
                wrResp.CustomerInteraction = new XC_REST_CustomerInteraction_W.WrapperCustomerInteraction();
                wrResp.CustomerInteraction.CustomerInteractionID = custInterInsertResult.recordId;

            } else {
                wrResp.Result.Message = 'INTERNAL ERROR';
                wrResp.Result.ErrorCode = '500';
                wrResp.Result.logError = 'INTERNAL ERROR: ' + custInterInsertResult.errorMessage;
            }

        } else {
            wrResp.Result.Message = 'INTERNAL ERROR: ' + result.errorMessage;
            wrResp.Result.ErrorCode = '500';
            wrResp.Result.logError = 'INTERNAL ERROR: ' + result.errorMessage;
        }

    }

    /**
     * Validate Request Customer Interaction.
     *
     * @param custInter the customer interaction wrapper
     * @return the Wrapper Result
     * @description method to verify if Customer Interaction required parameters are correctly filled
     */
    public static XC_UTIL_Integration.WrapperResult validateRequestCustomerInteraction(XC_REST_CustomerInteraction_W.WrapperCustomerInteraction custInter){
        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();


        if(String.isBlank(custInter.LegalEntity)){
            validateResult.errorMessage = Label.XC_CL_MandatoryField + 'CustomerInteraction.LegalEntity';
            validateResult.errorFlag = true;
            return validateResult;
        }
        if(String.isBlank(custInter.Channel)){
            validateResult.errorMessage = Label.XC_CL_MandatoryField + 'CustomerInteraction.Channel';
            validateResult.errorFlag = true;
            return validateResult;
        }
        if(String.isBlank(custInter.CommunicationType)){
            validateResult.errorMessage = Label.XC_CL_MandatoryField + 'CustomerInteraction.CommunicationType';
            validateResult.errorFlag = true;
            return validateResult;
        }
        if(String.isBlank(custInter.ContactID) && String.isBlank(custInter.LeadID) && String.isBlank(custInter.Phone) && String.isBlank(custInter.Email) && String.isBlank(custInter.AccountID)){
            validateResult.errorMessage = Label.XC_CL_MandatoryField + 'CustomerInteraction.ContactID, CustomerInteraction.LeadID, CustomerInteraction.Phone, CustomerInteraction.Email, CustomerInteraction.AccountID';
            validateResult.errorFlag = true;
            return validateResult;
        }

        return validateResult;
    }

}