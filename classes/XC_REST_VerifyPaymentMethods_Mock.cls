/**
 * *****************************************************************************************************.
 *
 * @author            : Simone Trenta strenta@deloitte.it - Chiara Turco cturco@deloitte.it - Emanuela Cacace ecacace@deloitte.it
 * @date Creation     : 03/06/2019
 * @date Modification : 
 * @description       : XC_REST_VerifyPaymentMethods_Mock – Mock class for verify payment zuora
 * *****************************************************************************************************
 */

@isTest
global class XC_REST_VerifyPaymentMethods_Mock implements HttpCalloutMock {

     global HTTPResponse respond(HTTPRequest req) {
     
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        if(Schema.sObjectType.Zuora_OAuth__c.isAccessible() && Schema.sObjectType.Zuora_OAuth__c.fields.EntityName__c.isAccessible() && Schema.sObjectType.Zuora_OAuth__c.fields.EntityId__c.isAccessible() && Schema.sObjectType.Zuora_OAuth__c.fields.Client_Secret__c.isAccessible() && Schema.sObjectType.Zuora_OAuth__c.fields.Client_Id__c.isAccessible() && Schema.sObjectType.Zuora_OAuth__c.fields.Host__c.isAccessible()){
            zws = [SELECT EntityName__c, EntityId__c, Client_Secret__c, Client_Id__c, Host__c FROM Zuora_OAuth__c WHERE EntityName__c LIKE '%Spain%' LIMIT 1];
        }
    
        String url = 'https://' + zws.Host__c + '/oauth/token';
         
       	// Optionally, only send a mock response for a specific endpoint
        System.assertEquals(url, req.getEndpoint());
         
        Map<String, String> resultMap = new  Map<String, String>();
        resultMap.put('access_token', 'test');
        resultMap.put('zuora_ids', 'test');
        resultMap.put('host', 'test');
        resultMap.put('zuora_ids', 'test');
         
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(resultMap, true));
        res.setStatusCode(200);
        return res;
     }
    
}