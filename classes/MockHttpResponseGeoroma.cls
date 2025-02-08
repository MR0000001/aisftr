/**
 * Created by snekkanti002 on 06/09/2022.
 */
@IsTest
global without sharing class MockHttpResponseGeoroma implements HttpCalloutMock {

    private Boolean isOK;
    public MockHttpResponseGeoroma(Boolean isOK) {
        this.isOK = isOK;
    }

    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Accept', 'application/json');
        res.setStatusCode(200);

        if(req.getEndpoint().containsIgnoreCase('WSO2')) {
            res.setBody(getJSONBodyWso2());
        } else if(req.getEndpoint().containsIgnoreCase('GEOROMA_STREETS_LIST')) {
            if(this.isOK) {
                res.setBody(getStreetsList());
            } else {
                res.setBody(getStreetsListKO());
            }
        } else {
            if(this.isOK) {
                res.setBody(getStreetDetails());
            } else {
                res.setBody(getStreetDetailsKO());
            }
        }
        return res; 
    }

    private String getJSONBodyWso2() {
        return '{"access_token":"baf98fef-3c81-33b4-9889-c285e66f5bbd","scope":"am_application_scope default","token_type":"Bearer","expires_in":9223372036854775}';
    }

    private String getStreetsList() {
        return '{"indirizzi":[{"civici":[],"indirizzo":"VIA GIULIO ARISTIDE SARTORIO"}],"total":1,"page":1,"size":30}';
    }

    private String getStreetsListKO() {
        return '';
    }

    private String getStreetDetails() {
        return '{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"coordinates":[12.4409,41.8046],"type":"MultiPolygon"},"properties":{"TOPONIMO":"VIA GIUSEPPE PEREGO","NUMERO_CIVICO":8,"LETTERA":null,"ESPONENTE":null,"CODICE":null,"ID_CIVICO":394593,"ID_AREA_CIRCOLAZIONE":11656,"FID":307542,"PROVENIENZA":"TOPONOMASTICA","STATO":"UFFICIALE","MUNICIPIO":9,"NUMERO_ROMANO":"IX"},"id":"GeoromaCiviciLocator.fid--56a8a991_1830ed15dc4_-6fe7","bbox":[12.4409,41.8046,12.4409,41.8046]}],"bbox":[12.4409,41.8046,12.4409,41.8046]}';
    }

    private String getStreetDetailsKO() {
        return '';
    }
}