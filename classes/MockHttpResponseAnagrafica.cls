/**
 * Created by SNEKKANTI00 on 17/12/2020.
 */

@isTest
global with sharing class MockHttpResponseAnagrafica implements HttpCalloutMock {
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
        String jsonBody = '{"Persona":{"DatiAnagrafeRoma":{"DatiIndividuo":{"CodiceIndividuale":"4H077031","TipoIndividuo":{"FlagVivoResidente":0,"Vivo":"Viva","Residente":"Residente"}},"DatiFamiglia":{"CodiceFamiglia":44430870,"FlagPresenzaInFamiglia":1}},"PersonaCompleta":{"Sesso":"F","Nome":"MARCELLA","Cognome":"SALARI","DatadiNascita":{"Giorno":20,"Mese":11,"Anno":1977},"LuogodiNascita":{"NomeComune":"Roma","SiglaProvincia":"Rm","SiglaStato":"I","NomeStato":"Italia","CodiceComuneISTAT":"091","CodiceProvinciaISTAT":"058","CodiceStatoISTAT":100},"CodiceFiscale":"SLRMCL77S60H501S","Cittadinanza":{"DescrizioneCittadinanza":"Italiana","CodiceStatoISTAT":100},"StatoCivile":"Coniugata"},"DatiIndirizzo":{"Indirizzo":{"IndirizzoItaliano":{"CodiceVia":114158,"Toponimo":"Via Vincenzo Statella","indirizzoBreve":"Via Vincenzo Statella N.64 S.B I.15","NumeroCivico":{"Numero":64},"Scala":"B","Interno":15,"Municipio":11}},"ProtocolloDomicilio":{"NumeroProtocollo":"024298"}},"Nascita":{"DatadiNascita":{"Giorno":20,"Mese":11,"Anno":1977},"LuogodiNascita":{"NomeComune":"Roma","SiglaProvincia":"Rm","SiglaStato":"I","NomeStato":"Italia","CodiceComuneISTAT":"091","CodiceProvinciaISTAT":"058","CodiceStatoISTAT":100},"AttodiNascita":{"TipoRegistrazione":"I","ComuneRegistrazione":{"NomeComune":"Roma","SiglaProvincia":"Rm","SiglaStato":"I","NomeStato":"Italia","CodiceComuneISTAT":"091","CodiceProvinciaISTAT":"058","CodiceStatoISTAT":100},"Numero":"03580","Parte":1,"Serie":"A","Esponente":"00","Anno":1977},"Genitori":{"Padre":{"Nominativo":"GAUDENZIO"},"Madre":{"Nominativo":"VITA PIERA"}}},"Matrimonio":{"DatiConiuge":{"Coniuge":{"CodiceIndividuale":"4H077022","Cognome":"SERRA","Nome":"FABRIZIO","Sesso":"M"}},"DatadiMatrimonio":{"Giorno":23,"Mese":"07","Anno":2005},"LuogodiMatrimonio":{"NomeComune":"Monterosi","SiglaProvincia":"Vt","SiglaStato":"I","NomeStato":"Italia","CodiceComuneISTAT":"038","CodiceProvinciaISTAT":"056","CodiceStatoISTAT":100},"AttodiMatrimonio":{"TipoRegistrazione":"I","ComuneRegistrazione":{"NomeComune":"Monterosi","SiglaProvincia":"Vt","SiglaStato":"I","NomeStato":"Italia","CodiceComuneISTAT":"038","CodiceProvinciaISTAT":"056","CodiceStatoISTAT":100},"Numero":"00001","Parte":2,"Serie":"A","Esponente":"00","Anno":2005}},"SituazioneAnagrafe":{"Iscrizione":{"MotivodiIscrizione":"Immigrazione","DatadiIscrizione":{"Giorno":20,"Mese":"07","Anno":2020},"ComunediProvenienza":{"NomeComune":"Monterosi","SiglaProvincia":"Vt","SiglaStato":"I","NomeStato":"Italia","CodiceComuneISTAT":"038","CodiceProvinciaISTAT":"056","CodiceStatoISTAT":100},"ProtocolloIscrizione":{"NumeroProtocollo":"024298","AnnoProtocollo":2020}}}}}';

        return jsonBody;
    }
}