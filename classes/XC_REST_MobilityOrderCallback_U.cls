/**
 * The Class XC_REST_MobilityOrderCallback_U.
 *
 * @author            : Giulio Serra giserra@deloitte.it
 * @date Creation     : 08/02/2019
 * @date Modification : 10/06/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : Util for XC_REST_MobilityOrderCallback
 */

public class XC_REST_MobilityOrderCallback_U {
    
    
    /**
     * The Class RequestWrapper.
     *
     * @description the wrapper request
     */
    public class RequestWrapperCallback{
        
        public RequestWrapper Order = new RequestWrapper();
    }
    
    
    /**
     * The Class RequestWrapper.
     *
     * @description the wrapper request
     */
    public class RequestWrapper{
        
        /** The Order id. */
        public String OrderId;//Y
        
        /** The Asset ID. */
        public String AssetID;//Y
        
        /** The Z subscription id. */
        public String ZSubscriptionId;  //Y
        
        /** The Z charge number. */
        public String ZChargeNumber;    //Y
        
        /** The Z account id. */
        public String ZAccountId;   //Y
        
        /** The Start date subscription. */
        public String StartDateSubscription;    //Y
        
        /** The Company code. */
        public String CompanyCode;  
        
        /** The Cost center. */
        public String CostCenter;

        /** The Z subscription number. */
        public String ZSubscriptionNumber;

        /** The Prod ID. */
        public String ProdID;

        /** The Old ZAccount Id. */
        public String OldZAccountId;

        /** The Old ZSubscription Id. */
        public String OldZSubscriptionId;

        /** The Account ID. */
        public String AccountID;
        
        /** The Effective Date. */
        public Date EffectiveDate;

        /** The eMobility Transaction Id. */
        public String emobTransactionId;

        /** The is Change flag. */
        public Boolean isChangeOpenCharge;
        
        /** The Step ID. */
        public String StepID;
    }
    

    /**
     * The Class ResponseWrapper.
     *
     * @description the wrapper response
     */
    public class ResponseWrapper{
        
        /** The Result. */
        public XC_UTIL_Integration.Result Result = new  XC_UTIL_Integration.Result();
    }

}