@isTest
global class ZuoraWebservice_TEST_Mock implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest req) {
        
        String endpoint = req.getEndpoint();
        
        // Create a fake response.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        // Set response values
        switch on endpoint {
            when 'https://rest.sandbox.eu.zuora.com/oauth/token' {        // when block 1
                // code block 1
                res.setBody('{"access_token":"12345678929"}');
        		res.setStatusCode(200);
            }    
            when 'https://rest.sandbox.eu.zuora.com/v1/object/payment-method' {        // when block 2
                // code block 2
                res.setBody('{"status":"OK"}');
        		res.setStatusCode(200);
            }
            when 'https://rest.sandbox.eu.zuora.com/v1/rsa-signatures' {        // when block 3
                // code block 3
                res.setBody('{"rsa_signature":"1234567"}');
        		res.setStatusCode(200);
            }
            when 'https://rest.sandbox.eu.zuora.com/v1/action/query' {          // default block, optional
                // code block 4
                res.setBody('{"records": [{"Id": "2c93808457d787030157e0324aea5158"},{"Id": "2c93808457d787030157e0324aea5159"}],"size": 1,"done": true}');
        		res.setStatusCode(200);
            }
            when 'https://rest.sandbox.eu.zuora.com/v1/rateplan/123456567/productRatePlan'{
                res.setBody('{"status":"OK"}');
        		res.setStatusCode(200);
            }
            when 'https://rest.sandbox.eu.zuora.com/v1/action/subscribe'{
                res.setBody('[{"status":"OK"}]');
        		res.setStatusCode(200);    
            }
            when 'https://rest.sandbox.eu.zuora.com/v1/action/update'{
                res.setBody('[{"status":"OK"}]');
        		res.setStatusCode(200);        
            }
            when 'https://rest.sandbox.eu.zuora.com/v1/object/bill-run'{
                res.setBody('{"status":"OK"}');
        		res.setStatusCode(200);               
            }
            when 'https://rest.sandbox.eu.zuora.com/v1/subscriptions/123556566' {
                res.setBody('{"ratePlans":[{"id":"36237263327", "ratePlanCharges":[{"type":"OneTime"}]},{"id":"36237263327","ratePlanCharges":[{"type":"OneTime"}]}]}');
        		res.setStatusCode(200);      
            }
            when 'https://rest.sandbox.eu.zuora.com/v1/accounts'{
                res.setBody('{"status":"OK"}');
        		res.setStatusCode(200); 
            }
            when 'https://rest.sandbox.eu.zuora.com/v1/object/account/54674722'{
                res.setBody('{"status":"OK"}');
        		res.setStatusCode(200); 
            }
            when 'callout:XC_ZuoraWebServiceWorkflow/LinkAccountToExternalPaymentMethod/run'{
                res.setBody('{"status":"OK"}');
        		res.setStatusCode(200); 
            }
            when 'callout:XC_ZuoraWebServiceWorkflow' {
                res.setBody('{"status":"OK"}');
        		res.setStatusCode(200); 
            } 
            when 'https://rest.sandbox.eu.zuora.com/v1/accounts/123456'{
                res.setBody('{"status":"OK","success":"true"}');
        		res.setStatusCode(200); 
            }
        }
        
        // return response.
        return res;
    }

}