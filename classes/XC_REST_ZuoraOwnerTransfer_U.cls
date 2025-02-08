/**
* @author Federico Amici - federico.amici@nttdata.com
* @description Util class for XC_REST_ZuoraOwnerTransfer
* @lastModify 
*/
public class XC_REST_ZuoraOwnerTransfer_U {
 
    /** 
    * @description Wrapper that is used in the request
    */
    public class WrapperRequest {
        public List<WrapperRequestZuora> requests;
        public String legalEntity;
        public String stream;
        public String transactionID;
    }

    /**
    * @description RatePlan Wrapper
    */
    public class RatePlanWrapper {
        public String ProductRatePlanId;
    }

    /**
    * @description RatePlanCharge Wrapper
    */
    public class RatePlanChargeWrapper {
        public String ProductRatePlanChargeId;
        public Integer Quantity;
    }

    /**
    * @description RatePlanChargeData Wrapper
    */
    public class RatePlanChargeDataWrapper {
        public RatePlanChargeWrapper RatePlanCharge;
    }

    /**
    * @description RatePlanData Wrapper
    */
    public class RatePlanDataWrapper {
        public RatePlanWrapper RatePlan;
        public List<RatePlanChargeDataWrapper> RatePlanChargeData;
    }

    /**
    * @description Amendments Wrapper
    */
    public class AmendmentWrapper {
        public String ContractEffectiveDate;
        public String Description;
        public String Name;
        public RatePlanDataWrapper RatePlanData;
        public String Status;
        public String SubscriptionId;
        public String Type;
        public String DestinationAccountId;
        public String DestinationInvoiceOwnerId;
        public String AutoRenew;
        public String ServiceActivationDate;
        public String RenewalTermPeriodType;
        public Integer RenewalTerm;
        public String CurrentTermPeriodType;
        public Integer CurrentTerm;
        public String TermStartDate;
        public String TermType;
    }

    /**
    * @description PreviewOptions
    */
    public class PreviewOptionsWrapper {
        public Boolean EnablePreviewMode;
    }

    /**
    * @description AmendOptions
    */
    public class AmendOptionsWrapper {
        public String GenerateInvoice;
    }

    /**
    * @description WrapperRequestZuora wrapper
    */
    public class WrapperRequestZuora {
        public List<AmendmentWrapper> Amendments;
        public PreviewOptionsWrapper PreviewOptions;
        public AmendOptionsWrapper AmendOptions;
    }

    /**
    * @description The wrapper used to store the response
    */
    public class WrapperResponse {
        public List<WrapperResult> results;
    }

    /**
    * @description The wrapper  result used to store the response
    */
    public class WrapperResult {
        public String SubscriptionId;
        public Decimal TotalDeltaTcv;
        public List<String> AmendmentIds;
        public Decimal TotalDeltaMrr;
        public Boolean Success;
        public List<Errors> Errors;
    }


    public class Errors {
        /** The code. */
        public String code;
        
        /** The message. */
        public String message;
    }
}