/**
 * The Class XC_REST_NotifyPayment_U.
 *
 * @author            : Riccardo Cossu - riccardo.cossu@nttdata.com
 * @date Creation     : 13/12/2018
 * @date Modification : 29/04/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : UTIL for XC_REST_NotifyPayment
 **/


public class XC_REST_NotifyPayment_U {
     
    /**
     * The Class WrapperRequest.
     *
     * @description the wrapper request
     */
     public class WrapperRequest {
        
        /** The account id. */
        public String accountId;
        
        /** The amount. */
        public Double amount;
        
        /** The comment. */
        public String comment;
        
        /** The currency name. */
        public String currencyName; // field to replace
        
        /** The debit memos list. */
        public List<DebitMemos> debitMemosList;
        
        /** The effective date. */
        public Date effectiveDate;
        
        /** The finance information. */
        public FinanceInformationReq financeInformation;
        
        /** The gateway id. */
        public String gatewayId; 
        
        /** The invoices list. */
        public List<Invoices> invoicesList;
        
        /** The payment method id. */
        public String paymentMethodId; 
        
        /** The reference id. */
        public String referenceId;
        
        /** The type. */
        public String type; 
        
        /** The integration id. */
        public String integrationId; // field to replace
        
        /** The integration status. */
        public String integrationStatus; // field to replace
        
        /** The origin. */
        public String origin; // field to replace
        
        /** The sync date. */
        public String syncDate; // field to replace
        
        /** The transaction name. */
        public String transactionName; // field to replace
        
        /** The property name. */
        public String propertyName;
    }


    /**
     * The Class DebitMemos.
     *
     * @description the wrapper Debit Memos
     */
    public class DebitMemos {
        
        /** The amount. */
        public Double amount;
        
        /** The debit memo id. */
        public String debitMemoId;
        
        /** The items list. */
        public List<Items> itemsList;
    }


    /**
     * The Class Items.
     *
     * @description the wrapper items
     */
    public class Items {
        
        /** The amount. */
        public Double amount;
        
        /** The debit memo item id. */
        public String debitMemoItemId;
        
        /** The tax item id. */
        public String taxItemId;
    }


    /**
     * The Class FinanceInformationReq.
     *
     * @description the wrapper Finance Information Request
     */
    public class FinanceInformationReq {
        
        /** The bank account accounting code. */
        public String bankAccountAccountingCode;
        
        /** The transferred to accounting. */
        public String transferredToAccounting; 
        
        /** The unapplied payment accounting code. */
        public String unappliedPaymentAccountingCode;
    }


    /**
     * The Class Invoices.
     *
     * @description the wrapper Invoices
     */
    public class Invoices {
        
        /** The amount. */
        public Double amount;
        
        /** The invoice id. */
        public String invoiceId;
        
        /** The items list. */
        public List<Items> itemsList; 
    }


    /**
     * The Class WrapperResponse.
     *
     * @description the wrapper response
     */
    public class WrapperResponse {
        
        /** The id. */
        public String id;
        
        /** The number N. */
        public String numberN; // field to replace
        
        /** The status. */
        public String status;
        
        /** The type. */
        public String type;
        
        /** The account id. */
        public String accountId;
        
        /** The amount. */
        public Double amount;
        
        /** The applied amount. */
        public Double appliedAmount;
        
        /** The unapplied amount. */
        public Double unappliedAmount;
        
        /** The refund amount. */
        public Double refundAmount;
        
        /** The credit balance amount. */
        public Double creditBalanceAmount;
        
        /** The currency name. */
        public String currencyName; // field to replace
        
        /** The effective date. */
        public Date effectiveDate;
        
        /** The comment. */
        public String comment;
        
        /** The payment method id. */
        public String paymentMethodId;
        
        /** The payment method snapshot id. */
        public String paymentMethodSnapshotId;
        
        /** The auth transaction id. */
        public String authTransactionId;
        
        /** The bank identification number. */
        public String bankIdentificationNumber;
        
        /** The gateway id. */
        public String gatewayId;
        
        /** The gateway order id. */
        public String gatewayOrderId;
        
        /** The gateway response. */
        public String gatewayResponse;
        
        /** The gateway response code. */
        public String gatewayResponseCode;
        
        /** The gateway state. */
        public String gatewayState;
        
        /** The marked for submission on. */
        public String markedForSubmissionOn;
        
        /** The reference id. */
        public String referenceId;
        
        /** The second payment reference id. */
        public String secondPaymentReferenceId;
        
        /** The soft descriptor. */
        public String softDescriptor;
        
        /** The soft descriptor phone. */
        public String softDescriptorPhone;
        
        /** The submitted on. */
        public String submittedOn;
        
        /** The settled on. */
        public String settledOn;
        
        /** The cancelled on. */
        public String cancelledOn;
        
        /** The created date. */
        public String createdDate;
        
        /** The created by id. */
        public String createdById;
        
        /** The updated date. */
        public String updatedDate;
        
        /** The updated by id. */
        public String updatedById;
        
        /** The finance information. */
        public FinanceInformationRes financeInformation;
        
        /** The success. */
        public Boolean success;
    }


    /**
     * The Class FinanceInformationRes.
     *
     * @description the wrapper Finance Information Response
     */
    public class FinanceInformationRes {
        
        /** The bank account accounting code. */
        public String bankAccountAccountingCode;
        
        /** The bank account accounting code type. */
        public String bankAccountAccountingCodeType;
        
        /** The unapplied payment accounting code. */
        public String unappliedPaymentAccountingCode;
        
        /** The unapplied payment accounting code type. */
        public String unappliedPaymentAccountingCodeType;
        
        /** The transferred to accounting. */
        public String transferredToAccounting;
    }


}