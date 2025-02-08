/**
 * The Class XC_REST_CreditMemo_U.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 29/04/2019
 * @date Modification : dd/mm/yyyy
 * @description       : UTIL for XC_REST_CreditMemo
 **/


public without sharing class XC_REST_CreditMemo_U {

    /**
     * The Class WrapperRequest.
     *
     * @description wrapper request of REST call
     */
    public class WrapperRequest {
        
        /** The account Id. */
        public String accountId;

        /** The comment. */
        public String comment;

        /** The effective Date. */
        public String effectiveDate;

        /** The reason Code. */
        public String reasonCode;

        /** The integration Id. */
        public String integrationId;

        /** The integration Status. */
        public String integrationStatus;

        /** The origin. */
        public String origin;

        /** The sync Date. */
        public String syncDate;

        /** The transaction. */
        public String transactionX;

        /** The account Id. */
        public List<ChargesWrapper> charges = new List<ChargesWrapper>();
    }


    /**
     * The Class ChargesWrapper.
     *
     * @description wrapper charges of REST call
     */
    public class ChargesWrapper {

        /** The amount. */
        public Double amount;

        /** The charge Id. */
        public String chargeId;

        /** The comment. */
        public String comment;

        /** The memo Item Amount. */
        public Double memoItemAmount;

        /** The service End Date. */
        public String serviceEndDate;

        /** The service Start Date. */
        public String serviceStartDate;

        /** The charge Id. */
        public FinanceInfosWrapper financeInformation;
    }


    /**
     * The Class FinanceInfosWrapper.
     *
     * @description wrapper finance informations of REST call
     */
    public class FinanceInfosWrapper {

        /** The deferred Revenue Accounting Code. */
        public String deferredRevenueAccountingCode;

        /** The on Account Accounting Code. */
        public String onAccountAccountingCode;

        /** The recognized Revenue Accounting Code. */
        public String recognizedRevenueAccountingCode;

        /** The revenue Recognition Rule Name. */
        public String revenueRecognitionRuleName;
    }


    /**
     * The Class WrapperResponse.
     *
     * @description wrapper response of REST call
     */
    public class WrapperResponse {
        
        /** The success. */
        public Boolean success;
        
        /** The id. */
        public String id;

        /** The number. */
        public String numberX;

        /** The account id. */
        public String accountId;

        /** The currency. */
        public String currencyX;

        /** The credit Memo Date. */
        public String creditMemoDate;

        /** The target Date. */
        public String targetDate;

        /** The posted By Id. */
        public String postedById;

        /** The posted On. */
        public String postedOn;

        /** The status. */
        public String status;

        /** The amount. */
        public Double amount;

        /** The tax Amount. */
        public Double taxAmount;

        /** The total Tax Exempt Amount. */
        public Double totalTaxExemptAmount;

        /** The unapplied Amount. */
        public Double unappliedAmount;

        /** The refund Amount. */
        public Double refundAmount;

        /** The applied Amount. */
        public Double appliedAmount;

        /** The comment. */
        public String comment;

        /** The source. */
        public String source;

        /** The source id. */
        public String sourceId;

        /** The referred Invoice id. */
        public String referredInvoiceId;

        /** The reason Code. */
        public String reasonCode;

        /** The created Date. */
        public String createdDate;

        /** The created By id. */
        public String createdById;

        /** The updated Date. */
        public String updatedDate;

        /** The updated By id. */
        public String updatedById;

        /** The cancelled On. */
        public String cancelledOn;

        /** The cancelled By id. */
        public String cancelledById;

        /** The latest PDF File Id. */
        public String latestPDFFileId;

        /** The transferred To Accounting. */
        public String transferredToAccounting;

        /** The exclude From Auto Apply Rules. */
        public Boolean excludeFromAutoApplyRules;

        /** The auto Apply Upon Posting. */
        public Boolean autoApplyUponPosting;
        
        /** The reasons. */
        public List<Reasons> reasons;
    }


    /**
     * The Class Reasons.
     *
     * @description wrapper reasons of REST call
     */
    public class Reasons {
        
        /** The code. */
        public Integer code;
        
        /** The message. */
        public String message;
    }
}