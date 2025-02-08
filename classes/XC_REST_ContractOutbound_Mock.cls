/**
* @author Federico Amici federico.amici@nttdata.com
* @date Creation 26/02/2018
* @date Modification dd/mm/yyyy
* @description XC_REST_Contract_Outbound_Mock – Class that handles the mock callout for XC_REST_Contract_Outbound
*/
@isTest
public without sharing class XC_REST_ContractOutbound_Mock implements HttpCalloutMock {
	
    /** 
		* @description The HTTP response.
		* @param request the HTTP request
		* @return the response
		*/
    public HTTPResponse respond(HTTPRequest request) {
		
    	// Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json;charset=UTF-8');
        if(request.getMethod() == 'GET') {
        	
        	response.setBody('{"Result": {' +
									'"ErrorCode": "0",' +
									'"Message": "Operation completed successfully"'+
								'},'+
								'"Contract": [' +
									'{' +
										'"AccountID": "a1b0D000000F8UeQAK",' +
										'"ContractStartDate": "2019-02-04",' +
										'"ContractTerm": "Term of fontract",' +
										'"Currency": "EUR",' +
										'"AddressID":"ESP-FAKE-001",'+
										'"AddressData":"ES01239991239_Test Barcelona",'+
										'"Status": "Active",' +
										'"ContractNumber": "12345678"' + //[DeAv 21/12/2021 TPB added ContractNumber]
										'},' +
									'{' +
										'"AccountID": "a1b0D000000F8UeGrE",' +
										'"ContractStartDate": "2019-02-07",' +
										'"ContractTerm": "Term of fontract",' +
										'"Currency": "EUR",' +
										'"AddressID":"ESP-FAKE-001",'+
										'"AddressData":"ES01239991239_Test Barcelona",'+
										'"Status": "Active",' +
										'"ContractNumber": "87654321"' + //[DeAv 21/12/2021 TPB added ContractNumber]
									'}' +
								']' +
							'}');
			System.debug('@@@ MOCK @@@ ' + response);	
        }

        response.setStatusCode(200);
        return response; 
	}
	
}