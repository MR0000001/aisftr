/**
 * Created by snekkanti002 on 28/07/2021.
 */

global with sharing class MockHttpResponseGEDCase implements HttpCalloutMock {
    private List<String> caseIds = new List<String>();

    public MockHttpResponseGEDCase(List<String> caseIds) {
        this.caseIds = caseIds;
    }

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Accept', 'application/json');
        res.setStatusCode(200);
        if(req.getEndpoint().containsIgnoreCase('WSO2')) {
            System.debug('Endpoint: WSO2');
            res.setBody(getJSONBodyWso2());
        } else {
            System.debug('Endpoint: ' + req.getEndpoint());
            System.debug('JSON Body: ' + getJSONBody());
            res.setBody(getJSONBody());
        }

        return res;
    }

    private String getJSONBody() {
        String jsonBody = '{"apiWsResponse":{"errorCode":"000","errorMessage":"Operazione correttamente eseguita."},"listaNumeroProtollo":[{"codiceMittente":12651160,"dataProtocollo":1641896482000,"id":\"'+this.caseIds[0]+'\","error":{"errorMessage":"Operazione correttamente eseguita.","errorCode":"000"},"tipoProtocollo":"CD","annoProtocollo":2022,"progressivoProtocollo":1,"oraProtocollo":37260000}]}';

        return jsonBody;
    }

    private string getJSONBodyWso2() {
        String json = '{"access_token":"baf98fef-3c81-33b4-9889-c285e66f5bbd","scope":"am_application_scope default","token_type":"Bearer","expires_in":9223372036854775}';
        return json;
    }

}