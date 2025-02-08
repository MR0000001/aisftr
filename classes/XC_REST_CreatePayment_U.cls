/**
 * ***************************************************************************************************.
 *
 * @author Luisana Rocco lrocco@deloitte.it
 * @date Creation 13/12/2018
 * @date Modification 09/11/2020
 * @description XC_REST_CreatePayment – Rest Resource in outbound for create Payment
 * ****************************************************************************************************
 */

public  class XC_REST_CreatePayment_U {

    
    /** 
     * @description The Class WrapperRequest.
     */
    public class WrapperRequest {

        /** The stream. */
        public String stream;

        /** The value date. */
        public Date VALUE_DATEReplace;
        
        /** The generic info. */
        public String GenericInfoReplace;
        
        /** The order number. */
        public String CRMContractNumberReplace;

        /** The configuration item id. */
        public String crmConfigurationItem; 

        /** The legal entity. */
        public String legalEntity;
        
        /** The account id. */
        public String accountId;
        
        /** The amount. */
        public Double amount;
        
        /** The comment. */
        public String comment;
        
        /** The currency name. */
        public String currencyName; 
        
        /** The debit memos. */
        public List<DebitMemos> debitMemos = new List<DebitMemos>();
        
        /** The effective date. */
        public Date effectiveDate;
        
        /** The finance information. */
        public FinanceInformation financeInformation = new FinanceInformation();
        
        /** The gateway id. */
        public String gatewayId; 
        
        /** The invoices. */
        public List<Invoices> invoices = new List<Invoices>();
        
        /** The payment method id. */
        public String paymentMethodId; 
        
        /** The reference id. */
        public String referenceId;
        
        /** The type. */
        public String type; 
        
        /** The integration id. */
        public String integrationId; 
        
        /** The integration status. */
        public String integrationStatus; 
        
        /** The origin. */
        public String origin; 
        
        /** The sync date. */
        public String syncDate; 
        
        /** The transaction name. */
        public String transactionName; 
        
        /** The property name. */
        public String propertyName;
    }

    /**
     * @description  The Class DebitMemos.
     */
    public class DebitMemos {
        
        /** The amount. */
        public Double amount;
        
        /** The debit memo id. */
        public String debitMemoId;
        
        /** The items. */
        public List<Items> items;
    }

    /**
     * @description The Class Items.
     */
    public class Items {
        
        /** The amount. */
        public Double amount;
        
        /** The debit memo item id. */
        public String debitMemoItemId;

        /** The debit invoice item id. */
        public String invoiceItemId;
        
        /** The tax item id. */
        public String taxItemId;
    }

    /**
     * @description The Class Invoices.
     */
    public class Invoices {
        
        /** The amount. */
        public Double amount;
        
        /** The invoice id. */
        public String invoiceId;
        
        /** The items. */
        public List<Items> items; 
    }

    /**
     * @description The Class WrapperResponse.
     */
    public class WrapperResponse {
        
        /** The id. */
        public String id;
        
        /** The number N. */
        public String numberN; 
        
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
        public String currencyName; 
        
        /** The effective date. */
        public String effectiveDate;
        
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
        public FinanceInformation financeInformation = new FinanceInformation();
        
        /** The reasons. */
        public List<Reasons> reasons = new List<Reasons>();
        
        /** The success. */
        public Boolean success;
    }

    /**
     * @description The Class FinanceInformation.
     */
    public class FinanceInformation {
        
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

    /**
     * @description The Class Reasons.
     */
    public class Reasons {
        
        /** The code. */
        public Integer code;
        
        /** The message. */
        public String message;
    }


 
}