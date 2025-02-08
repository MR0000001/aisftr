/**
 * Created by snekkanti002 on 22/11/2022.
 */
@IsTest
global without sharing class MockHttpResponseIAM implements HttpCalloutMock {

    global MockHttpResponseIAM() {

    }

    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Accept', 'application/json');
        res.setStatusCode(200);

        System.debug('Endpoint: ' + req.getEndpoint());
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
        String json = '{"request":[{"CODICE_FISCALE":"BNCMRC92M30G148K","EMAIL":"m.benucci@nsr.it","TELEFONO_MOBILE":"3342289658","TELEFONO_FISSO":"06-671079999","FAX":"06-671079998"},{"CODICE_FISCALE":"FEEMGM99M65B218C","EMAIL":"o.dambrosio@nsr.it","TELEFONO_MOBILE":"3342289658","TELEFONO_FISSO":"06-671079999","FAX":"06-671079998"}]}';

        return json;
    }
}