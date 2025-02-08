/**
*@Author: Francesco Imperioli fimperioli@deloitte.it
*@Description: TestClass MOCK for ZuoraWebService
*@History: Createddate 24-06-2019
**/
@isTest
public class ZuoraWebserviceMock implements HttpCalloutMock {



    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        ZuoraWebService.LinkPaymentMethodToAccountResponse respBody = new ZuoraWebService.LinkPaymentMethodToAccountResponse();
        respBody.success='true';
        respBody.errors=new List<ZuoraWebService.Error>();
        respBody.Id='test';
        res.setBody(JSON.Serialize(respBody));
        res.setStatusCode(200);
        return res;
    }

}