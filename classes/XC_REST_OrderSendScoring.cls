/**
* @author Federico Amici - federico.amici@nttdata.com, Luisana Rocco - lrocco@deloitte.it
* @description REST that invokes DataLake service
*/
public with sharing class XC_REST_OrderSendScoring {
    
    public class WrapperScoring {
        public String AccountID;
        public String AccountScoring;
    }

    public class ResponseWrapper {
        public XC_UTIL_Integration.Result Result;
        public WrapperScoring Scoring;
    }

    /**
	 * @description Invokes DataLake API
	 * @param order the payment id
	 * @return the serialized wrapper
	 */
	public static String sendScoring(NE__Order__c order) {
       
        ResponseWrapper responseWr = new ResponseWrapper();
        WrapperScoring requestWr = new WrapperScoring();
        WrapperScoring responseScoring;
        Map<Id, Account> mapAccount;

		XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_SendScoring);
        
        if(!isActiveInterface.activeInterface) {
			responseWr.Result = new XC_UTIL_Integration.Result(); 
            responseWr.Result.ErrorCode = '400';
            responseWr.Result.Message = Label.XC_CL_InterfaceInactive;
            return JSON.serialize(responseWr, true);
        }
            
        try{
			String url = isActiveInterface.url;
            requestWr.AccountID = order.NE__AccountID__c;
            requestWr.AccountScoring = String.valueOf(order.XC_Scoring__c);

			String body =  JSON.serialize(requestWr, true);
			
			Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Create', 'Scoring', 'DataLake');

			HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
			HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request,'','SendScoring');

            if(checkResponseNull(response)) {
                if(checkBodyNull(response.getBody())) {
                    System.debug('RESPONSE before deserialize -> ' + response.getBody());
    			    responseWr = (ResponseWrapper) JSON.deserialize(response.getBody(), ResponseWrapper.class);
                    System.debug('RESPONSE after deserialize -> ' + responseWr);
                }
            }

            if(responseWr.Scoring == null) {
                return JSON.serialize(responseWr, true);
            }

            responseScoring = responseWr.Scoring;

            if(String.isNotBlank(responseScoring.AccountID)) {
                if(String.isBlank(responseScoring.AccountScoring)) {
                    responseWr.Result.ErrorCode = '400';
                    responseWr.Result.Message = Label.XC_CL_AccountScoring;
                    return JSON.serialize(responseWr, true);
                }

                mapAccount = new Map<Id, Account>([SELECT Id, XC_DataLakeScore__c FROM Account WHERE Id =:responseScoring.AccountID]);
                if(mapAccount.values().isEmpty()) {
                    responseWr.Result.ErrorCode = '400';
                    responseWr.Result.Message = Label.XC_CL_NoAccountFound;
                    return JSON.serialize(responseWr, true);
                }
     
                mapAccount.get(responseScoring.AccountID).XC_DataLakeScore__c = responseScoring.AccountScoring;
                XC_UTIL_Sobject.updateRecord(mapAccount.get(responseScoring.AccountID));
            }
            
            
        } catch(Exception e) {
            
            responseWr.Result.ErrorCode = '400';
            responseWr.Result.Message = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
        }

        return JSON.serialize(responseWr, true);
    }

    private static Boolean checkResponseNull(HttpResponse response) {
        return response != null;
    }

    private static Boolean checkBodyNull(String body) {
        return body != null;
    }
}