/**
 * Created by SNEKKANTI00 on 26/02/2021.
 */

global with sharing class MockHttpResponseAnagraficaMultiple implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        res.setStatusCode(200);
        res.setBody(getJSONBody());
        return res;
    }

    global String getJSONBody() {

        //You need to structure you'r sample JSON reponse into a String. In this reponse you'll need to specify values that you'll be using to do an Assert at the end of TestBatchClass
        String jsonBody = '{"Elenco": {"PersonaElenco": [{"CodiceIndividuale": 48029795,"Nome": "ALESSANDRO","Cognome": "Proietti","DatadiNascita": {"Giorno": 29,"Mese": "09","Anno": 2008},"Sesso": "M","Indirizzo": "VIA CLAUZETTO N.58","FlagVivoResidente": 0,"CodiceFiscale": "PRTLSN08P29H50MN","Descrizione": "ALESSANDRO Proietti 29/09/2008 Via Clauzetto N.58"},{"CodiceIndividuale": 48048363,"Nome": "ALESSANDRO","Cognome": "Proietti","DatadiNascita": {"Giorno": 29,"Mese": "09","Anno": 2008},"Sesso": "M","Indirizzo": "VIA DELL\'ARCHEOLOGIA N.69","FlagVivoResidente": 0,"CodiceFiscale": "PRTLSN08P29H5L1G","Descrizione": "ALESSANDRO Proietti 29/09/2008 Via Dell\'archeologia N.69"}]}}';

        return jsonBody;
    }
}