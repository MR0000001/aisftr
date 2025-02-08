/**
 * The Class XC_REST_Employee.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 19/04/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Rest Resourse to get employee
 **/


public without sharing class XC_REST_Employee {
    
    /**
     * The Class WrapperResponse.
     *
     * @description the wrapper response
     */
    public class WrapperResponse {
        
        /** The Result. */
        public XC_UTIL_Integration.WrapperResult Result;

        /** The Employee Wrapper. */
        public EmployeeWrapper Employee;
    }


    /**
     * The Class EmployeeWrapper.
     *
     * @description the employee wrapper
     */
    public class EmployeeWrapper {
        
        /** The PersonID. */
        public Integer PersonID;

        /** The PersonNumber. */
        public Integer PersonNumber;

        /** The FirstName. */
        public String FirstName;

        /** The InvoiceNumber. */
        public String InvoiceNumber;

        /** The LastName. */
        public String LastName;
    }

    /**
     * CallToGetEmployee.
     *
     * @param employeeId the employee Id
     * @return the wrapper response
     * @description method to send a request to get employee
     */
    public static WrapperResponse callToGetEmployee(String employeeId) {
        WrapperResponse result = new WrapperResponse();

        XC_UTIL_RESTCallout.CSWrapper wrInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_Employee);
        if(wrInterface.activeInterface) {

            String url = wrInterface.url;
            String body = '{"Employee":{"EmployeeID":"' + employeeId + '"}}';
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'GetEmployee', 'HR');

            /* The request */
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('GET', url, headerDefinitions, body);
            System.debug('[getEmployee] request -> ' + request);
            System.debug('[getEmployee] request BODY -> ' + request.getBody());

            /* The response */
            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, headerDefinitions.get('TransactionID'), 'RetriveInvoice');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, headerDefinitions, 'RetriveInvoice');

            System.debug('[getEmployee] response -> ' + response);
            System.debug('[getEmployee] response BODY -> ' + response.getBody());

            result = (WrapperResponse) JSON.deserialize(response.getBody(), WrapperResponse.class);
        }

        return result;
    }


}