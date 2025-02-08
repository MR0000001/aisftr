/**
 * The class XC_REST_CustomerInteraction_W.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 24/04/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Util for XC_REST_CustomerInteraction
 **/

public without sharing class XC_REST_CustomerInteraction_W {

    /**
     * The Class WrapperRequest.
     *
     * @description wrapper request of REST call
     */
    public class WrapperRequest {
        
        /** The Customer interaction. */
        public WrapperCustomerInteraction CustomerInteraction;
    }


    /**
     * The Class WrapperCustomerInteraction.
     *
     * @description wrapper customer interaction of REST call
     */
    public class WrapperCustomerInteraction {
        
        /** The Customer interaction ID. */
        public String CustomerInteractionID;
        
        /** The Contact ID. */
        public String ContactID;
        
        /** The Lead ID. */
        public String LeadID;
        
        /** The Email. */
        public String Email;
        
        /** The Phone. */
        public String Phone;
        
        /** The Channel. */
        public String Channel;
        
        /** The Communication type. */
        public String CommunicationType;
        
        /** The Source. */
        public String Source;
        
        /** The Order ID. */
        public String OrderID;
        
        /** The Opportunity ID. */
        public String OpportunityID;
        
        /** The Service appointment ID. */
        public String ServiceAppointmentID;
        
        /** The Account ID. */
        public String AccountID;
        
        /** The Work order ID. */
        public String WorkOrderID;
        
        /** The Case ID. */
        public String CaseID;
        
        /** The Doc URL list. */
        public String DocURLList;
        
        /** The Doc ID list. */
        public String DocIDList;

        /** The Legal Entity. */
        public String LegalEntity;

        public String ZuoraInvoice;
        public String ZuoraInvoiceItem;
        public String ZuoraSubscription;
        public String ZuoraBillingAccount;
        public String BusinessLine;

        public String AdditionalInfo1;
        public String AdditionalInfo2;
        public String AdditionalInfo3;
        public String AdditionalInfo4;
        public String AdditionalInfo5;
        public String AdditionalInfo6;
        public String AdditionalInfo7;
        public String AdditionalInfo8;
        public String AdditionalInfo9;
        public String AdditionalInfo10;

        public String InvoiceNumber;
        public String RateNumber;

    }
    

    /**
     * The Class WrapperResponse.
     *
     * @description wrapper response of REST call
     */
    public class WrapperResponse {
        
        /** The Result. */
        public XC_UTIL_Integration.Result Result = new XC_UTIL_Integration.Result();
        
        /** The Customer interaction. */
        public WrapperCustomerInteraction CustomerInteraction;
    }
    

    /**
     * The Class WrapperResult.
     *
     * @description wrapper result
     */
    public class WrapperResult {
        
        /** The success. */
        public Boolean success = false;
        
        /** The error message. */
        public String errorMessage;
        
        /** The cust interaction. */
        public XC_Customer_Interaction__c custInteraction;
    }

}