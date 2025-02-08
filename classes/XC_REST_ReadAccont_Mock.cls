@isTest
global class XC_REST_ReadAccont_Mock implements HttpCalloutMock {
    
    global HttpResponse respond (HttpRequest req){

         
        XC_REST_ReadAccont_U.WrapperResponseHR wrResp = new  XC_REST_ReadAccont_U.WrapperResponseHR();
        wrResp.message = 'ok';

        HttpResponse response = new  HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(JSON.serialize(wrResp, true));
        response.setStatusCode(200);
        return response;


    }
 
    
    
    

}