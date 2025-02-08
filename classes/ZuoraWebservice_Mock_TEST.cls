/**
 * @File Name          : ZuoraWebservice_Mock_TEST.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 21/4/2020, 10:39:24
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    21/4/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
@isTest
global class ZuoraWebservice_Mock_TEST implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest req) {
        
        String endpoint = req.getEndpoint();
        
        // Create a fake response.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        system.debug('Endpoint : ' + endpoint);
        // Set response values
        switch on endpoint {
            when 'https://rest.sandbox.eu.zuora.com/oauth/token' {        // when block 1
                // code block 1
                res.setBody('{"access_token":"12345678929"}');
                res.setStatusCode(200);
            } 
            when 'callout:XC_ZuoraAuth' {        // when block 1
                // code block 1
                res.setBody('{"access_token":"12345678929"}');
                res.setStatusCode(200);
            }
            //when 'https://rest.sandbox.eu.zuora.com/v1/object/payment-method' {        // when block 2
            when 'callout:XC_ZuoraBasePath/v1/object/payment-method' {        // when block 2
                // code block 2
                res.setBody('{"status":"OK"}');
                res.setStatusCode(200);
            }
            when 'https://rest.sandbox.eu.zuora.com/v1/rsa-signatures' {        // when block 3
                // code block 3
                res.setBody('{"rsa_signature":"1234567"}');
                res.setStatusCode(200);
            }
            when 'callout:XC_ZuoraBasePath/v1/rsa-signatures' {        // when block 3
                // code block 3
                res.setBody('{"rsa_signature":"1234567"}');
                res.setStatusCode(200);
            }
            when 'https://rest.eu.zuora.com/v1/rsa-signatures' {        // when block 3
                // code block 3
                res.setBody('{"rsa_signature":"1234567"}');
                res.setStatusCode(200);
            }
            when 'https://rest.sandbox.eu.zuora.com/v1/action/query' {          // default block, optional
                // code block 4
                res.setBody('{"records": [{"Id": "2c93808457d787030157e0324aea5158"},{"Id": "2c93808457d787030157e0324aea5159"}],"size": 1,"done": true}');
                res.setStatusCode(200);
            }
             when 'callout:XC_ZuoraBasePath/v1/action/query' {          // default block, optional
                // code block 4
                res.setBody('{"records": [{"Id": "2c93808457d787030157e0324aea5158"},{"Id": "2c93808457d787030157e0324aea5159"}],"size": 1,"done": true}');
                res.setStatusCode(200);
            }
            when 'https://rest.sandbox.eu.zuora.com/v1/rateplan/123456567/productRatePlan'{
                res.setBody('{"status":"OK"}');
                res.setStatusCode(200);
            }
             when 'callout:XC_ZuoraBasePath/v1/rateplan/123456567/productRatePlan'{
                res.setBody('{"status":"OK"}');
                res.setStatusCode(200);
            }
            when 'https://rest.sandbox.eu.zuora.com/v1/action/subscribe'{
                res.setBody('[{"status":"OK"}]');
                res.setStatusCode(200);    
            }
            when 'callout:XC_ZuoraBasePath/v1/action/subscribe'{
                res.setBody('[{"status":"OK"}]');
                res.setStatusCode(200);    
            }
            when 'https://rest.sandbox.eu.zuora.com/v1/action/update'{
                res.setBody('[{"status":"OK"}]');
                res.setStatusCode(200);        
            }
            when 'callout:XC_ZuoraBasePath/v1/action/update'{
                res.setBody('[{"status":"OK"}]');
                res.setStatusCode(200);        
            }
            when 'https://rest.sandbox.eu.zuora.com/v1/object/bill-run'{
                res.setBody('{"status":"OK"}');
                res.setStatusCode(200);               
            }
            when 'callout:XC_ZuoraBasePath/v1/object/bill-run'{
                res.setBody('{"status":"OK"}');
                res.setStatusCode(200);               
            }
            when 'https://rest.sandbox.eu.zuora.com/v1/subscriptions/123556566' {
                res.setBody('{"ratePlans":[{"id":"36237263327", "ratePlanCharges":[{"type":"OneTime"}]},{"id":"36237263327","ratePlanCharges":[{"type":"OneTime"}]}]}');
                res.setStatusCode(200);      
            }
            when 'callout:XC_ZuoraBasePath/v1/subscriptions/123556566' {
                res.setBody('{"ratePlans":[{"id":"36237263327", "ratePlanCharges":[{"type":"OneTime"}]},{"id":"36237263327","ratePlanCharges":[{"type":"OneTime"}]}]}');
                res.setStatusCode(200);      
            }
            //when 'https://rest.sandbox.eu.zuora.com/v1/accounts'{
            when 'callout:XC_ZuoraBasePath/v1/accounts'{
                res.setBody('{"status":"OK"}');
                res.setStatusCode(200); 
            }
            when 'callout:XC_UpdateZuoraAccount'{
                res.setBody('{"status":"OK"}');
                res.setStatusCode(200); 
            }
            //when 'https://rest.sandbox.eu.zuora.com/v1/object/account/54674722'{
            when 'callout:XC_ZuoraBasePath/v1/object/account/54674722'{
                res.setBody('{"status":"OK"}');
                res.setStatusCode(200); 
            }when 'callout:XC_ZuoraWebServiceWorkflow/LinkAccountToExternalPaymentMethod/run' {
                res.setBody('{"status":"OK"}');
        		res.setStatusCode(200);
            //} when 'https://rest.sandbox.eu.zuora.com/v1/accounts/123456'{
            } when 'callout:XC_ZuoraBasePath/v1/accounts/123456'{
                res.setBody('{"status":"OK","success":"true"}');
                res.setStatusCode(200); 
             } when 'callout:XC_UpdateZuoraAccount/123456'{
                res.setBody('{"status":"OK","success":"true"}');
                res.setStatusCode(200); 
            } when 'callout:XC_ZuoraWebServiceWorkflow/MixedVATSubscription/run'{
                res.setBody('{"errors" : []  , "id" : "123456" , "type" : "test" , "status" : "ok" , "runTime" : "0", "createdAt" : "0", "updatedAt" : "0" , "name" : "name" , "originalWorkflowId" : "test123"}');
                res.setStatusCode(200);
            } when 'callout:XC_ZuoraWebServiceWorkflow/CalculateBillingPreview_SF/run'{
                res.setBody('{"errors" : []  , "id" : "123456" , "type" : "test" , "status" : "ok" , "runTime" : "0", "createdAt" : "0", "updatedAt" : "0" , "name" : "name" , "originalWorkflowId" : "test123"}');
                res.setStatusCode(200);
            } when 'callout:XC_ZuoraBasePath/objects/records/default/EsportatoriAbituali'{
                res.setBody('{"Errors" : []  , "Id" : "123456" , "Success" : "true"}');
                res.setStatusCode(200);
            }
        }
        
        // return response.
        return res;
    }

}