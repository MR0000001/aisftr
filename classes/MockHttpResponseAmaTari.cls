/**
 * @author            : Daniel Perrella
 * @created date      : 11-10-2023
 * @description       :
 * @testClasses       :
 * @last modified by  : Daniel Perrella
 * @last modified on  : 11-10-2023
 **/
@IsTest
global without sharing class MockHttpResponseAmaTari implements HttpCalloutMock {
  private Boolean isOK;
  public MockHttpResponseAmaTari(Boolean isOK) {
    this.isOK = isOK;
  }

  global HttpResponse respond(HttpRequest req) {
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Accept', 'application/json');
    res.setStatusCode(200);

    if (!this.isOK) {
      res.setBody(getKo());
    } else if (req.getEndpoint().containsIgnoreCase('WSO2')) {
      res.setBody(getJSONBodyWso2());
    } else if (req.getEndpoint().containsIgnoreCase('anagrafiche/partita-iva')) {
      res.setBody(getPiva());
    } else if (req.getEndpoint().containsIgnoreCase('anagrafiche/codice-fiscale')) {
      res.setBody(getCf());
    } else if (req.getEndpoint().containsIgnoreCase('avvisi-pagamento')) {
      res.setBody(getAvvisiPagamento());
    }
    return res;
  }

  private String getKo() {
    return '{"ErrorCode":500,"MessageDescription":,"MessageError":InternalServerError,"TimeStamp":}';
  }

  private String getJSONBodyWso2() {
    return '{"access_token":"baf98fef-3c81-33b4-9889-c285e66f5bbd","scope":"am_application_scope default","token_type":"Bearer","expires_in":9223372036854775}';
  }

  private String getPiva() {
    return '{"BP": [{"Email": null,"Frazione": "ROMA","TelefonoCellulare": 333333333,"PartitaIVA": "IT00000000000","IndirizzoLegale": "VIA TEST TEST","CodiceFiscale": "AAAAAA00L00A000A","Localita": "ROMA","Pec": null,"Paese": "IT","CAP": "00175","Telefono": null,"NumeroCivico": 1,"PreCivico": null,"CodiceBP": "0020000000","Nome": "TEST TEST","Fax": null,"Cognome": null,"Provincia": "RM","CA": [{"Paese": "IT","CAP": "00175","Frazione": "ROMA","Indirizzo": "VIA TEST","BloccoEmissione": null,"Flag_contratti_attivi": "true","NumeroCivico": 1,"PreCivico": null,"CodiceBP": "0020000000","CodiceCA": "000002000000","Localita": "ROMA","Provincia": "RM","CONTRATTI": [{"Frazione": "ROMA","BoxSubalterno2": null,"CodiceCA": "000002000000","Localita": "ROMA","BoxParticella1": null,"BoxParticella2": null,"CantinaClasse": null,"CantinaSubalterno": null,"ImmobiliSubalterno": 4,"ImmobiliClasse": null,"Categoria": 21,"Indirizzo": "VIALE TEST","BoxFoglio1": null,"CodiceContratto": "0002445809","BoxFoglio2": null,"BoxSubalterno1": null,"CodiceBP": "0020000000","CodiceImpianto": "0002250176","CantinaParticella": null,"ImmobiliSezione": null,"ImmobiliParticella": 35,"CantinaSezione": null,"ImmobiliFoglio": 567,"DataCessazione": "31-12-9999","CAP": "00199","BoxSezione1": null,"TipologiaUtenza": "Non Domestico","BoxClasse2": null,"BloccoCalcolo": null,"NumeroCivico": 27,"PreCivico": null,"CantinaFoglio": null,"BoxClasse1": null,"BoxSezione2": null,"DataAttivazione": "01-01-2014","INFO_IMPIANTO": [{"CodiceOperando": "5COMUNE","CodiceContratto": "0002445809","DataFineValidita": "16-04-1959","Valore": "5RM0000","CodiceBP": "0020000000","CodiceCA": "000002000000","CodiceImpianto": "0002250176","DataInizioValidita": "01-01-2014"},{"CodiceOperando": "5SUPERFSOG","CodiceContratto": "0002445809","DataFineValidita": "16-04-1959","Valore": " 36.0000000","CodiceBP": "0020000000","CodiceCA": "000002000000","CodiceImpianto": "0002250176","DataInizioValidita": "01-01-2014"}]}]}]}]}';
  }

  private String getCf() {
    return '{"BP":[{"Email":"test@gmail.com","Frazione":null,"TelefonoCellulare":null,"PartitaIVA":null,"IndirizzoLegale":"PIAZZATEST","CodiceFiscale":"AAAAAA00L00A000A","Localita":"ROMA","Pec":null,"Paese":"IT","CAP":"00131","Telefono":333333333,"NumeroCivico":1,"PreCivico":null,"CodiceBP":"0010000000","Nome":"TEST","Fax":null,"Cognome":"TEST","Provincia":"RM","CA":[{"Paese":"IT","CAP":"00131","Frazione":null,"Indirizzo":"PIAZZATEST","BloccoEmissione":null,"Flag_contratti_attivi":"false","NumeroCivico":1,"PreCivico":null,"CodiceBP":"0010000000","CodiceCA":"000002000000","Localita":"ROMA","Provincia":"RM","CONTRATTI":[{"Frazione":null,"BoxSubalterno2":null,"CodiceCA":"000002000000","Localita":"ROMA","BoxParticella1":null,"BoxParticella2":null,"CantinaClasse":null,"CantinaSubalterno":null,"ImmobiliSubalterno":null,"ImmobiliClasse":null,"Categoria":"01","Indirizzo":"VIATEST","BoxFoglio1":null,"CodiceContratto":"0002000000","BoxFoglio2":null,"BoxSubalterno1":null,"CodiceBP":"0010000000","CodiceImpianto":"0002000001","CantinaParticella":null,"ImmobiliSezione":null,"ImmobiliParticella":null,"CantinaSezione":null,"ImmobiliFoglio":null,"DataCessazione":"13-01-2021","CAP":"00132","BoxSezione1":null,"TipologiaUtenza":"Domestico","BoxClasse2":null,"BloccoCalcolo":null,"NumeroCivico":195,"PreCivico":null,"CantinaFoglio":null,"BoxClasse1":null,"BoxSezione2":null,"DataAttivazione":"23-06-2017","INFO_IMPIANTO":[{"CodiceOperando":"5COMUNE","CodiceContratto":"0002000000","DataFineValidita":"16-04-1959","Valore":"5RM0000","CodiceBP":"0010000000","CodiceCA":"000002000000","CodiceImpianto":"0002000001","DataInizioValidita":"23-06-2017"},{"CodiceOperando":"5MQ_APPART","CodiceContratto":"0002000000","DataFineValidita":"16-04-1959","Valore":"50.0000000","CodiceBP":"0010000000","CodiceCA":"000002000000","CodiceImpianto":"0002000001","DataInizioValidita":"23-06-2017"},{"CodiceOperando":"5PERSONE","CodiceContratto":"0002000000","DataFineValidita":"16-04-1959","Valore":"1.0000000","CodiceBP":"0010000000","CodiceCA":"000002000000","CodiceImpianto":"0002000001","DataInizioValidita":"23-06-2017"}]}]},{"Paese":"IT","CAP":"00131","Frazione":null,"Indirizzo":"PIAZZATEST","BloccoEmissione":null,"Flag_contratti_attivi":"true","NumeroCivico":1,"PreCivico":null,"CodiceBP":"0010000000","CodiceCA":"000002000002","Localita":"ROMA","Provincia":"RM","CONTRATTI":[{"Frazione":null,"BoxSubalterno2":null,"CodiceCA":"000002000002","Localita":"ROMA","BoxParticella1":3670,"BoxParticella2":null,"CantinaClasse":null,"CantinaSubalterno":null,"ImmobiliSubalterno":538,"ImmobiliClasse":null,"Categoria":"01","Indirizzo":"PIAZZATEST","BoxFoglio1":295,"CodiceContratto":"0003000000","BoxFoglio2":null,"BoxSubalterno1":69,"CodiceBP":"0010000000","CodiceImpianto":"0002000001","CantinaParticella":null,"ImmobiliSezione":null,"ImmobiliParticella":3670,"CantinaSezione":null,"ImmobiliFoglio":295,"DataCessazione":"31-12-9999","CAP":"00131","BoxSezione1":null,"TipologiaUtenza":"Domestico","BoxClasse2":null,"BloccoCalcolo":null,"NumeroCivico":1,"PreCivico":null,"CantinaFoglio":null,"BoxClasse1":null,"BoxSezione2":null,"DataAttivazione":"10-11-2021","INFO_IMPIANTO":[{"CodiceOperando":"5COMUNE","CodiceContratto":"0003000000","DataFineValidita":"16-04-1959","Valore":"5RM0000","CodiceBP":"0010000000","CodiceCA":"000002000002","CodiceImpianto":"0002000001","DataInizioValidita":"01-01-2003"},{"CodiceOperando":"5MQ_ALTRI","CodiceContratto":"0003000000","DataFineValidita":"16-04-1959","Valore":"9.0000000","CodiceBP":"0010000000","CodiceCA":"000002000002","CodiceImpianto":"0002000001","DataInizioValidita":"01-01-2003"},{"CodiceOperando":"5MQ_APPART","CodiceContratto":"0003000000","DataFineValidita":"16-04-1959","Valore":"38.0000000","CodiceBP":"0010000000","CodiceCA":"000002000002","CodiceImpianto":"0002000001","DataInizioValidita":"01-01-2003"},{"CodiceOperando":"5MQ_GARAGE","CodiceContratto":"0003000000","DataFineValidita":"16-04-1959","Valore":"14.0000000","CodiceBP":"0010000000","CodiceCA":"000002000002","CodiceImpianto":"0002000001","DataInizioValidita":"01-01-2003"},{"CodiceOperando":"5PERSONE","CodiceContratto":"0003000000","DataFineValidita":"16-04-1959","Valore":"1.0000000","CodiceBP":"0010000000","CodiceCA":"000002000002","CodiceImpianto":"0002000001","DataInizioValidita":"01-01-2003"}]}]}]}]}';
  }
  private String getAvvisiPagamento() {
    return '{"T_DOCUMENTI":[{"NDOCUMENTO":"0000100000000000","TIPO":"F","TIPO_CONTRATTO":"NDOM","IMPORTO_APERTO":609,"DOCUMENTO_EC":null,"IMPORTO_TOTALE":609,"FAEDN":"31-07-2023","STUDT":"15-09-2023","IMPORTO_PAGAT":0,"DATA_DOC":"15-06-2023"},{"NDOCUMENTO":"0000100000000001","TIPO":"F","TIPO_CONTRATTO":"NDOM","IMPORTO_APERTO":580.35,"DOCUMENTO_EC":null,"IMPORTO_TOTALE":580.35,"FAEDN":"20-12-2022","STUDT":"00-00-0000","IMPORTO_PAGAT":0,"DATA_DOC":"13-10-2022","SOLLECITO":[{"NUMSOLL":"0003000000","DATA_SOLL":"13-10-2022"}]}]}';
  }

}