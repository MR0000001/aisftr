/**
* @author Federico Amici federico.amici@nttdata.com
* @date Creation 26/02/2018
* @date Modification dd/mm/yyyy
* @description XC_REST_Case_Outbound_Mock – Class that handles the mock callout for XC_REST_Case_Outbound
*/

/**
 * @description The Class XC_REST_CaseOutbound_Mock.
 */
@isTest
public without sharing class XC_REST_CaseOutbound_Mock implements HttpCalloutMock {

    /** The HTTP response. */ 
    // Implement this interface method
    public HTTPResponse 
 /**
  * @description Respond.
  *
  * @param request the request
	* @return HTTPRequest
  */
 respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json;charset=UTF-8');
        if(request.getMethod() == 'GET') { 
        	
        	response.setBody('{'+
							 '"Result": {'+
							    '"Message": "Operation completed successfully",'+
							    '"ErrorCode": "0"'+
							  '},'+
							  '"Case": ['+
							    '{'+
							      '"Status": "ESTA001",'+
							      '"Priority": "2",'+
							      '"Owner": "00536000002H7SnAAK",'+
							      '"CreatedDate": "2019-01-31 17:18:37",'+
							      '"Country": "Italy",'+
							      '"Channel": "AR01",'+
							      '"CaseType": "TIP002",'+
							      '"CaseReason": "MOT054",'+
							      '"CaseNumber": "23315463",'+
							      '"CaseID": "5000D000001lVJ8QAM",'+
							      '"AccountID": "0010D00000CmWhLQAV"'+
							    '}'+
							  ']'+
							'}');
							System.debug('@@@ MOCK @@@ ' + response);	
        } else if(request.getMethod() == 'POST') {

        	response.setBody('{' +
        							'"Result": {' + 
										'"ErrorCode": "0",'+
										'"Message": "Operation completed successfully"' +
									'},' +
									'"Case": {' + 
										'"CaseType": "TYPE",' +
										'"CaseID": "a1b0D000000F8UeQAK",' +
										'"CaseNumber": "129373564243",' +
										'"CaseReason": "MOT050",' +
										'"AccountID": "0010D00000CnH4NQAV"' +
									'}' +
							'}'	);	
			System.debug('@@@ MOCK @@@ ' + response);	
        } else if(request.getMethod() == 'PUT') {

        	response.setBody('{' +
        							'"Result": {' + 
										'"ErrorCode": "0",'+
										'"Message": "Operation completed successfully"' +
									'},' +
									'"Case": {' + 
										'"CaseType": "TYPE",' + 
										'"CaseID": "a1b0D000000F8UeQAK",' +
										'"CaseNumber": "129373564243",' +
										'"CaseReason": "MOT050",' +
										'"AccountID": "0010D00000CnH4NQAV"' +
									'}' +
							'}'	);	
			System.debug('@@@ MOCK @@@ ' + response);	
        }
        
        
        response.setStatusCode(200);
        return response; 
    }
}