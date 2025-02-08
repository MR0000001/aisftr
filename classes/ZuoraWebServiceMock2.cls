/**
*@Author: Francesco Imperioli fimperioli@deloitte.it
*@Description: TestClass MOCK for ZuoraWebService
*@History: Createddate 24-06-2019
**/

@isTest
public class ZuoraWebServiceMock2 implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        ZuoraWebService.CreatePaymentMethodResponse respBody = new ZuoraWebService.CreatePaymentMethodResponse();
        respBody.success='true';
        respBody.errors=new List<ZuoraWebService.Error>();
        respBody.Id='test';
        respBody.ZuoraAccountId='a123456';
        res.setBody(JSON.Serialize(respBody));
        res.setStatusCode(200);
        return res;
    }

}