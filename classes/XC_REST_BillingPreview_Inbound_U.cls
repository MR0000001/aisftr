/**
* @author Donato Lombardi - dolombardi@deloitte.it
* @date Creation 18/02/2020
* @description REST INTERFACE :
*/
public class XC_REST_BillingPreview_Inbound_U {

    /**
     * @description wrapper class for request
     */
    public class RequestWrapper {
        public List<BillingPreviewWrapper> billPreview;
    }

    /**
     * @description wrapper class for response
     */
    public class ResponseWrapper {
        public XC_UTIL_Integration.ResultSnakeCase result;

        /**
        * @description constructor
        */
        public ResponseWrapper(){
            this.result = new XC_UTIL_Integration.ResultSnakeCase();
        }
    }

    /**
     * @description wrapper class for wbe
     */
    public class BillingPreviewWrapper {
        public Decimal amount;
        public String success;
        public Decimal taxAmount;
        public String contractedMrr;
        public String amountWithoutTax;
        public String invoiceTargetDate;
        public String totalContractedValue;
        public String configurationItem;
        public List<InvocesItemWrapper> invoiceItems;
    }

    public class InvocesItemWrapper{
        public String quantity;
        public Decimal taxAmount;
        public String chargeName;
        public String productName;
        public Decimal chargeAmount;
        public String unitOfMeasure;
        public String serviceEndDate;
        public String serviceStartDate;
        public String chargeDescription;
        public String productRatePlanChargeId;
    }

    public class listWrapperBillingPreview{
        public List<BillingPreviewWrapper> listBilling;
    }

    /**
    * @description validate request
    * @param params the wrapper
    * @param header the header
    * @return the wrapper result
    */
    public static XC_UTIL_Integration.WrapperResult validatePutRequest(BillingPreviewWrapper params, Map<String,String> header){
        XC_UTIL_Integration.WrapperResult result = XC_UTIL_Integration.validateHeader(header);
       /* if(result.errorFlag && False) {
            return result;
        }


        if(params.amount == null || params.taxAmount.isEmpty()){
            result.errorMessage = 'ERROR. Missing mandatory field: wbes';
            result.errorFlag = true;
            return result;
        }*/

        //for(BillingPreviewWrapper w : params){
            Map<String,Object> wbesMandatory = new Map<String,Object>{
                    'amount' => params.amount,
                    'success' => params.success

            };

            result = XC_UTIL_Integration.checkMandatory(wbesMandatory);
            if(result.errorFlag) {
                return result;
            }
       // }

        return result;
    }
}