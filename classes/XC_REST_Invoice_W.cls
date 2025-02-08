/**
* @author Monica Cutillo - monica.cutillo@nttdata.com
* @date Creation 16/07/2019
* @date Modification dd/mm/yyyy
* @description XC_REST_Invoice_W – Wrapper class for XC_REST_ReadInvoiceList
*/ 
public class XC_REST_Invoice_W {


    /**
     * The Class ReadInvoiceListResponse.
     * @description wrapper response REST call ReadInvoiceList
     */
    public class ReadInvoiceListResponse {
        
        /** The Result. */
        public XC_UTIL_Integration.Result Result = new XC_UTIL_Integration.Result();
        
        /** The retreaved RetrieveInvoice */
        public RetrieveInvoiceWrapper RetrieveInvoice;
        
        /** The retreaved Invoice list. */
        public List<InvoiceWrapper> Invoice;
    }

    /**
     * The Class RetrieveInvoice.
     * @description wrapper from response REST call ReadInvoiceList
     */
    public class RetrieveInvoiceWrapper {
        /** The retreaved Invoice list. */
        public List<InvoiceWrapper> Invoice;
    }

    /**
     * The Class InvoiceWrapper.
     * @description single InvoiceWrapper
     */
    public class InvoiceWrapper {
        public String InvoiceID;
        public String BusinessLine;
        public String ContractNumber;
        public String ContractID;
        public String ClientID;
        public String InvoiceNumber;
        public String CompanyOwner;
        public String InvoiceCode;
        public Datetime IssueDate;
        public String Amount;
        public String InvoiceStatus;
        public String ObligationPaid; //Boolean
        public String InvoiceSequential;
        public String CompanyCode;
        public String InvoiceReference;
        public String ContractSequential;
        public String ObligationSequential;
        public String FractionationIndicator;
        public Boolean FractionalObligation;
        public String BroadcasterML;
        public Datetime PaymentDateParentObligation;
         String PaymentBrand;
        public String AuthorizedRegistrationDate;
        public String WithdrawalAuthorizedDate;
        public Date DateFrom;
        public Date DateTo;
        public String TermEndDate;

        /** @description The Address. */
        public XC_UTIL_Address.AddressWrapper Address; 
    }

    /**
     * The Class ReadInvoiceListResponse.
     * @description wrapper response REST call ReadInvoiceList
     */
    public class ReadInvoiceInboundResponse {
        public XC_UTIL_Integration.Result Result = new XC_UTIL_Integration.Result();
        public List<InvoiceInboundWrapper> Invoice;
    }

    /**
     * The Class InvoiceWrapper.
     * @description single InvoiceWrapper
     */
    public class InvoiceInboundWrapper {
        public String invoice_number;
        public String zuora_invoice_id ;
        public String payment_method;
        public String invoice_amount;
        public String invoice_balance;
        public String invoice_paid_amount;
        public Date invoice_created_date;
        public String payment_method_information;

        public List<InvoiceItemInboundWrapper> InvoiceItem;
    }

    /**
     * The Class InvoiceWrapper.
     * @description single InvoiceWrapper
     */
    public class InvoiceItemInboundWrapper {
        public String single_item_amount;
        public String product_description;
    }

}