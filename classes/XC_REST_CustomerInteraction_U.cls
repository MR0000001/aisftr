/**
 * The class XC_REST_CustomerInteraction_U.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 05/02/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Util for XC_REST_CustomerInteraction
 **/


public without sharing class XC_REST_CustomerInteraction_U {

    /**
     * Validate Request.
     *
     * @param mapHeader the map header
     * @param wrReq the wrapper request
     * @return the Wrapper Result
     * @description method to verify if Header and Customer Interaction required parameters are correctly filled
     */
    public static XC_UTIL_Integration.WrapperResult validateRequest(Map<String, String> mapHeader, XC_REST_CustomerInteraction_W.WrapperRequest wrReq){       
        XC_UTIL_Integration.WrapperResult validateResult = XC_UTIL_Integration.validateHeader(mapHeader);
        if(validateResult.errorFlag) {
            return validateResult;
        }

        validateResult = XC_UTIL_RESTInbound.checkObjectPermission('XC_Customer_Interaction__c', 'create');
        if(validateResult.errorFlag){
            return validateResult; 
        }       

        if(wrReq.CustomerInteraction == null) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField +'CustomerInteraction';
            validateResult.errorFlag = true;
            return validateResult;
        }

        validateResult = XC_REST_CustomerInteraction_UU.validateRequestCustomerInteraction(wrReq.CustomerInteraction);

        return validateResult;
    }

    /**
     * CreateCustomerInteraction.
     *
     * @param custInter the customer interaction wrapper
     * @param leadList the lead list
     * @param conList the contact list
     * @return the wrapper result
     * @description Method to create a Customer Interaction record from WrapperCustomerInteraction
     */ 
    public static XC_REST_CustomerInteraction_W.WrapperResult createCustomerInteraction(XC_REST_CustomerInteraction_W.WrapperCustomerInteraction custInter, List<Lead> leadList, List<Contact> conList) {
        
        XC_REST_CustomerInteraction_W.WrapperResult result = new XC_REST_CustomerInteraction_W.WrapperResult();

        Map<String, Object> custInterParametersMap = new Map<String, Object>{
            'XC_LegalEntity__c' => (custInter.LegalEntity=='Endesa Energía SAU' || (String.isNotBlank(custInter.LegalEntity) && custInter.LegalEntity.equalsIgnoreCase('Endesa X Servicios SL')))? 'EndesaX':custInter.LegalEntity,
            'XC_ContactId__c' => custInter.ContactID,
            'XC_LeadId__c' => custInter.LeadID,
            'XC_Channel__c' => custInter.Channel,
            'XC_Communication_Type__c' => custInter.CommunicationType,
            'XC_Source__c' => custInter.Source,
            'XC_OrderId__c' => custInter.OrderID,
            'XC_OpportunityId__c' => custInter.OpportunityID,
            'XC_ServiceAppointmentId__c' => custInter.ServiceAppointmentID,
            'XC_AccountId__c' => custInter.AccountID,
            'XC_WorkOrderId__c' => custInter.WorkOrderID, 
            'XC_CaseId__c' => custInter.CaseID,
            'XC_Doc_URL_List__c' => custInter.DocURLList, 
            'XC_Doc_Id_List__c' => custInter.DocIDList,
            'XC_Invoice__c' => custInter.ZuoraInvoice,
            'XC_InvoiceItem__c' => custInter.ZuoraInvoiceItem,
            'XC_Subscription__c' => custInter.ZuoraSubscription,
            'XC_BillingAccount__c' => custInter.ZuoraBillingAccount,
            'XC_BusinessLine__c' => custInter.BusinessLine,
            'XC_AdditionalInfo1__c' => custInter.AdditionalInfo1,
            'XC_AdditionalInfo2__c' => custInter.AdditionalInfo2,

            'XC_AdditionalInfo3__c' => custInter.AdditionalInfo3,
            'XC_AdditionalInfo4__c' => custInter.AdditionalInfo4,
            'XC_AdditionalInfo5__c' => custInter.AdditionalInfo5,
            'XC_AdditionalInfo6__c' => custInter.AdditionalInfo6,
            'XC_AdditionalInfo7__c' => custInter.AdditionalInfo7,
            'XC_AdditionalInfo8__c' => custInter.AdditionalInfo8,
            'XC_AdditionalInfo9__c' => custInter.AdditionalInfo9,
            'XC_AdditionalInfo10__c' => custInter.AdditionalInfo10,
            'XC_InvoiceNumber__c' => custInter.InvoiceNumber,
            'XC_RateNumber__c' => custInter.RateNumber

        };

        XC_Customer_Interaction__c custInterToInsert = new XC_Customer_Interaction__c();
        for(String field : custInterParametersMap.keySet()) {
            if(custInterParametersMap.get(field) != null) {
                custInterToInsert.put(field, custInterParametersMap.get(field));
            }
        }

        result = manageEmailOfCI(custInter, leadList, conList);
        if(!result.success) {
            return result;
        }
        custInterToInsert.XC_Email__c = result.custInteraction.XC_Email__c;

        result = managePhoneOfCI(custInter, leadList, conList);
        if(!result.success) {
            return result;
        }
        custInterToInsert.XC_Phone__c = result.custInteraction.XC_Phone__c;

        if(leadList.size() > 0 && String.isNotBlank(leadList.get(0).Name)) {
            custInterToInsert.XC_Recipient__c = leadList.get(0).Name;
        } else if(conList.size() > 0 && String.isNotBlank(conList.get(0).Name)) {

            setContactData(conList.get(0), custInterToInsert); /*ESCEP-1828 MCutillo 11/05/2019*/
        }

        if(String.isNotBlank(custInter.AccountID)&&(String.isBlank(custInter.ContactID))) { 
            List <Contact> c = new List<Contact>([SELECT Id, XC_PrimaryContact__c, AccountId, Name, XC_Preferredlanguageofcontact__c FROM Contact WHERE AccountID =: custInter.AccountID AND XC_PrimaryContact__c = true]); 
            custInterToInsert.XC_ContactId__c = c[0].Id;
            custInterToInsert.XC_Recipient__c = c[0].Name;
            custInterToInsert.XC_Preferredlanguageofcontact__c = c[0].XC_Preferredlanguageofcontact__c;
        }

        List<XC_Customer_Interaction__c> custInterList = new List<XC_Customer_Interaction__c>{custInterToInsert};
        //XC_UTIL_CustomerInteractionGeneration.checkOpportunityIdNotBlank(custInterList); /*ESCEP-1839 MCutillo 10/05/2019*/

        result.success = true;
        result.custInteraction = custInterList.get(0);
        return result;
    }

    /**
     * Set Contact data on customer interaction - ESCEP-1828 MCutillo 11/05/2019
     *
     * @param contact the Contact obj
     * @param custInter the Customer Interaction obj
     * @description Method to Set Contact data on customer interaction.
     */ 
    private static void setContactData(Contact contact, XC_Customer_Interaction__c custInter){
        custInter.XC_Recipient__c = contact.Name;
        if(contact.XC_Preferredlanguageofcontact__c!=null){
            custInter.XC_Preferredlanguageofcontact__c = contact.XC_Preferredlanguageofcontact__c;
        }
    }

    /**
     * Manage Email Of CI.
     *
     * @param custInter the customer interaction wrapper
     * @param leadList the lead list
     * @param conList the contact list
     * @return the wrapper result
     * @description method to manage email of Customer Interaction
     */ 
    public static XC_REST_CustomerInteraction_W.WrapperResult manageEmailOfCI(XC_REST_CustomerInteraction_W.WrapperCustomerInteraction custInter, List<Lead> leadList, List<Contact> conList) {

        XC_REST_CustomerInteraction_W.WrapperResult result = new XC_REST_CustomerInteraction_W.WrapperResult();
        XC_Customer_Interaction__c custInterToInsert = new XC_Customer_Interaction__c();

        if(String.isNotBlank(custInter.Email)) {
            custInterToInsert.XC_Email__c = custInter.Email;
        } else if(leadList.size() > 0 && String.isNotBlank(leadList.get(0).Email)) {
            custInterToInsert.XC_Email__c = leadList.get(0).Email;
        } else if(conList.size() > 0 && String.isNotBlank(conList.get(0).Email)) {
            custInterToInsert.XC_Email__c = conList.get(0).Email;
        } else if(custInter.Channel == 'Email') {
            result.success = false;
            result.errorMessage = Label.XC_CL_CustomerInteraction_Email;
            return result;
        }

        result = checkEmail(custInter, custInterToInsert);
        if(!result.success) {
            return result;
        }

        result.success = true;
        result.custInteraction = custInterToInsert;
        return result;
    }


    /**
     * Check Email.
     *
     * @param custInter the customer interaction wrapper
     * @param custInterToInsert the customer interaction to insert
     * @return the wrapper result
     * @description method to check email of Customer Interaction
     */ 
    public static XC_REST_CustomerInteraction_W.WrapperResult checkEmail(XC_REST_CustomerInteraction_W.WrapperCustomerInteraction custInter, XC_Customer_Interaction__c custInterToInsert) {

        XC_REST_CustomerInteraction_W.WrapperResult result = new XC_REST_CustomerInteraction_W.WrapperResult();

        if(String.isNotBlank(custInter.Email) && String.isNotBlank(custInterToInsert.XC_Email__c) && custInterToInsert.XC_Email__c != custInter.Email) {
            result.success = false;
            result.errorMessage = Label.XC_CL_CustomerInteraction_difEmail;
            return result;
        }

        result.success = true;
        return result;
    }


    /**
     * Manage Phone Of CI.
     *
     * @param custInter the customer interaction wrapper
     * @param leadList the lead list
     * @param conList the contact list
     * @return the wrapper result
     * @description method to manage phone of Customer Interaction
     */ 
    public static XC_REST_CustomerInteraction_W.WrapperResult managePhoneOfCI(XC_REST_CustomerInteraction_W.WrapperCustomerInteraction custInter, List<Lead> leadList, List<Contact> conList) {

        XC_REST_CustomerInteraction_W.WrapperResult result = new XC_REST_CustomerInteraction_W.WrapperResult();
        XC_Customer_Interaction__c custInterToInsert = new XC_Customer_Interaction__c();

        if(String.isNotBlank(custInter.Phone)) {
            custInterToInsert.XC_Phone__c = custInter.Phone;
        } else if(leadList.size() > 0 && String.isNotBlank(leadList.get(0).MobilePhone)) {
            custInterToInsert.XC_Phone__c = leadList.get(0).MobilePhone;
        } else if(conList.size() > 0 && String.isNotBlank(conList.get(0).MobilePhone)) {
            custInterToInsert.XC_Phone__c = conList.get(0).MobilePhone;
        } else if(custInter.Channel == 'SMS') {
            result.success = false;
            result.errorMessage = Label.XC_CL_CustomerInteraction_Phone;
            return result;
        }

        result = checkPhone(custInter, custInterToInsert);
        if(!result.success) {
            return result;
        }

        result.success = true;
        result.custInteraction = custInterToInsert;
        return result;
    }


    /**
     * Check Phone.
     *
     * @param custInter the customer interaction wrapper
     * @param custInterToInsert the customer interaction to insert
     * @return the wrapper result
     * @description method to check phone of Customer Interaction
     */ 
    public static XC_REST_CustomerInteraction_W.WrapperResult checkPhone(XC_REST_CustomerInteraction_W.WrapperCustomerInteraction custInter, XC_Customer_Interaction__c custInterToInsert) {

        XC_REST_CustomerInteraction_W.WrapperResult result = new XC_REST_CustomerInteraction_W.WrapperResult();

        if(String.isNotBlank(custInter.Phone) && String.isNotBlank(custInterToInsert.XC_Phone__c) && custInterToInsert.XC_Phone__c != custInter.Phone) {
            result.success = false;
            result.errorMessage = Label.XC_CL_CustomerInteraction_difPhone;
            return result;
        } 

        result.success = true;
        return result;
    }
    
}