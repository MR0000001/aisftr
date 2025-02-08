/**
 * Created by snekkanti002 on 11/11/2022.
 */
@IsTest
global without sharing class MockHttpResponseAutoreturn implements HttpCalloutMock {

    global MockHttpResponseAutoreturn() {

    }

    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Accept', 'application/json');
        res.setStatusCode(200);
        if(req.getEndpoint().containsIgnoreCase('WSO2')) {
            res.setBody(getJSONBodyWso2());
        } else {
            res.setBody(getJSONBody());
        }

        return res;
    }

    private String getJSONBodyWso2() {
        String json = '{"access_token":"baf98fef-3c81-33b4-9889-c285e66f5bbd","scope":"am_application_scope default","token_type":"Bearer","expires_in":9223372036854775}';

        return json;
    }

    private String getJSONBody() {
        String json = '{"StoricoEventiAutoResponse":{"result":[{"Targa":"FK527MH","ModelloVeicolo":"Ford Kuga","LuogoRimozione":"VIA SANTA SEVERINA n. 41/F","TipoProcedimento":"Spostamento in luogo","DataOraCustodia":"24/09/2021 12:30","VeicoloRitirato":true,"DataOraRitiro":"24/09/2021 12:30","LuogoCustodia":"Via Santa Severina prox palo Acea n. 16"},{"Targa":"FK527MH","ModelloVeicolo":"Ford Kuga","LuogoRimozione":"VIA SANTA SEVERINA n. 41","TipoProcedimento":"Spostamento in luogo","DataOraCustodia":"21/05/2021 12:54","VeicoloRitirato":true,"DataOraRitiro":"21/05/2021 12:54","LuogoCustodia":"via Santa Severina pross. civ. 41"},{"Targa":"FK527MH","ModelloVeicolo":"Ford Kuga","LuogoRimozione":"VIA SANTA SEVERINA n. 41","TipoProcedimento":"Spostamento in luogo","DataOraCustodia":"08/04/2021 11:23","VeicoloRitirato":true,"DataOraRitiro":"08/04/2021 11:23","LuogoCustodia":"via santa severina palo acea 14"}]}}';

        return json;
    }
}