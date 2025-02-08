/**
 * ***************************************************************************************************.
 *
 * @author Luisana Rocco lrocco@deloitte.it
 * @date Creation 04/02/2019
 * @date Modification dd/mm/yyyy
 * @description XC_REST_CreateAmendment – Rest Resource in outbound to create an Amendment
 * ****************************************************************************************************
 */

public class XC_REST_CreateAmendment_U {

      /**
       * @description The Class WrapperRequest.
       */
      public class WrapperRequest {
        
        /** The Auto renew. */
        public Boolean AutoRenew;
        
        /** The Contract effective date. */
        public String ContractEffectiveDate;
        
        /** The Current term. */
        public Integer CurrentTerm; 
        
        /** The Current term period type. */
        public String CurrentTermPeriodType; 
        
        /** The Customer acceptance date. */
        public String CustomerAcceptanceDate;
        
        /** The Description. */
        public String Description; 
        
        /** The Effective date. */
        public String EffectiveDate; 
        
        /** The Name. */
        public String Name; 
        
        /** The Renewal setting. */
        public String RenewalSetting; 
        
        /** The Renewal term. */
        public Integer RenewalTerm; 
        
        /** The Renewal term period type. */
        public String RenewalTermPeriodType; 
        
        /** The Service activation date. */
        public String ServiceActivationDate;
        
        /** The Specific update date. */
        public String SpecificUpdateDate;
        
        /** The Subscription id. */
        public String SubscriptionId;
        
        /** The Term start date. */
        public String TermStartDate;
        
        /** The Term type. */
        public String TermType;
        
        /** The Type. */
        public String Type;
        
        /** The Destination account id. */
        public String DestinationAccountId;
        
        /** The Destination invoice owner id. */
        public String DestinationInvoiceOwnerId;
        
        /** The Rate plan data. */
        public RatePlanDataWrapper RatePlanData;
    }

    /**
     * @description The Class RatePlanDataWrapper.
     */
    public class  RatePlanDataWrapper {
        
        /** The Rate plan. */
        public RatePlanWrapper RatePlan;
        
        /** The Rate plan charge data. */
        public List<RatePlanChargeDataWrapper> RatePlanChargeData;
    }

    /**
     * @description The Class RatePlanWrapper.
     */
    public class RatePlanWrapper {
        
        /** The Amendment subscription rate plan id. */
        public String AmendmentSubscriptionRatePlanId;
        
        /** The Product rate plan id. */
        public String ProductRatePlanId;
    }

    /**
     * @description The Class RatePlanChargeDataWrapper.
     */
    public class RatePlanChargeDataWrapper {
        
        /** The Amendment rate plan charge data. */
        public AmendmentRatePlanChargeDataWrapper AmendmentRatePlanChargeData;
    }

    /**
     * @description The Class AmendmentRatePlanChargeDataWrapper.
     */
    public class AmendmentRatePlanChargeDataWrapper {
        
        /** The Rate plan charge. */
        public RatePlanChargeWrapper RatePlanCharge;
        
        /** The Rate plan charge tier. */
        public List<RatePlanChargeTierWrapper> RatePlanChargeTier;
    }

    /**
     * @description The Class RatePlanChargeWrapper.
     */
    public class RatePlanChargeWrapper {
        
        /** The Bill cycle type. */
        public String BillCycleType;
        
        /** The Billing period. */
        public String BillingPeriod;
        
        /** The Billing timing. */
        public String BillingTiming;
        
        /** The Charge number. */
        public String ChargeNumber;
        
        /** The Discount amount. */
        public String DiscountAmount;
        
        /** The Discount percentage. */
        public String DiscountPercentage;
        
        /** The End date condition. */
        public String EndDateCondition;
        
        /** The List price base. */
        public String ListPriceBase;
        
        /** The Price. */
        public String Price;
        
        /** The Price change option. */
        public String PriceChangeOption;
        
        /** The Price increase percentage. */
        public String PriceIncreasePercentage;
        
        /** The Product rate plan charge id. */
        public String ProductRatePlanChargeId;
        
        /** The Quantity. */
        public String Quantity;
        
        /** The Rating group. */
        public String RatingGroup;
        
        /** The Rev rec code. */
        public String RevRecCode;
        
        /** The Rev rec trigger condition. */
        public String RevRecTriggerCondition;
        
        /** The Revenue recognition rule name. */
        public String RevenueRecognitionRuleName;
        
        /** The Specific billing period. */
        public String SpecificBillingPeriod;
        
        /** The Specific end date. */
        public String SpecificEndDate;
        
        /** The Trigger date. */
        public String TriggerDate;
        
        /** The Trigger event. */
        public String TriggerEvent;
        
        /** The Up to periods. */
        public String UpToPeriods;
        
        /** The Up to periods type. */
        public String UpToPeriodsType;
        
        /** The Weekly bill cycle day. */
        public String WeeklyBillCycleDay;
    }

    /**
     * @description The Class RatePlanChargeTierWrapper.
     */
    public class RatePlanChargeTierWrapper {
        
        /** The Amendment rate plan charge tier. */
        public AmendmentRatePlanChargeTierWrapper AmendmentRatePlanChargeTier;
    }

    /**
     * @description The Class AmendmentRatePlanChargeTierWrapper.
     */
    public class AmendmentRatePlanChargeTierWrapper {
        
        /** The Price format. */
        public String PriceFormat;
        
        /** The Rate plan charge id. */
        public String RatePlanChargeId;
    }

    /**
     * @description The Class WrapperResponse.
     */
    public class WrapperResponse {
        
        /** The id. */
        public String id;
        
        /** The success. */
        public Boolean success;
        
        /** The Errors. */
        public List<Errors> Errors;
    }

    /**
     * @description The Class Errors.
     */
    public class Errors {
        
        /** The code. */
        public String code;
        
        /** The message. */
        public String message;
    }
}