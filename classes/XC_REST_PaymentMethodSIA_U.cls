/******************************************************************************************************
* @author            : Roberta Porrega roberta.porrega@nttdata.com - Simone Trenta strenta@deloitte.it
* @date Creation     : 08/05/2019
* @description       : XC_REST_PaymentMethodSIA – Rest Resourse for Payment SIA
******************************************************************************************************/
public class XC_REST_PaymentMethodSIA_U {

    /**
     * @description The Class Request Wrapper.
     */
    public class RequestWrapper{
        public String email ;
        public String typeX ;
        public String Firstname ;
        public String Surname ;
        public String Businessname;
        public String VATCode;
        public String BirthDate;
        public String BirthPlace;
        public String BirthProvince;
        public String BirthCountry;
        public Decimal Amount;
        public Decimal currencyX;
        public String note;
        public Map<String,String> additionalInfo = new Map<String,String>();
        public String address;
        public String addressCity;
        public String addressCountry;
    }

    /**
     * @description The Class Request Wrapper.
     */
    public class RequestWrapperSEPA{

        public String name;
        public String surname;
        public String email;
        public String nationalIdentificationCode;
        public String iban;
        public String mandateID;
        public String birthDate;
        public String birthPlace;
        public String birthProvince;
        public String birthCountry;
        public String note;
        public String type;
        public String address;
        public String addressCity;
        public String addressCountry;
        public String bp;

        public AdditionalInfoWrapper additionalInfo;
        public SDDWrapper sdd;
    }

    /**
     * @description The Class Response Wrapper.
     */
    public class ResponseWrapper{
        public String debtorStatus;
        public String debtorCode;
        public String redirectUrl;
        public String code ;
        public String details;

        public XC_Integration_Log__c integrationLog;
    }

    /**
     * @description The Class Response Wrapper.
     */
    public class AdditionalInfoWrapper{
        public String property1;
        public String property2;
    }

    /**
     * @description The Class Response Wrapper.
     */
    public class SDDWrapper{
        public String iban;
        public String mandateId;
        public String mandateDate;
    }

    /**
 * @description Check required parameters.
 * @param reqWrapp the addr to validate
 * @return the x C UTI L integration. result
 */

    public static XC_UTIL_Integration.Result checkRequiredParameters(requestWrapper reqWrapp){
        XC_UTIL_Integration.Result response = new XC_UTIL_Integration.Result();

        if(String.isBlank(reqWrapp.Email)) {
            response.ErrorCode = '400';
            response.Message = Label.XC_CL_MandatoryField +  ' Email';
            return response;
        }

        if(String.isBlank(reqWrapp.typeX)) {
            response.ErrorCode = '400';
            response.Message = Label.XC_CL_MandatoryField +  ' Type';
            return response;
        }

        if(reqWrapp.typeX != 'ONE_SHOT' && reqWrapp.typeX != 'RECURRENT') {
            response.ErrorCode = '400';
            response.Message = Label.XC_CL_WrongValue + ' Type';
            return response;
        }
        response.ErrorCode = '0';
        return response;
    }

}