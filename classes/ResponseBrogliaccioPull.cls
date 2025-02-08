/**
 * Created by SNEKKANTI00 on 30/06/2021.
 */

public with sharing class ResponseBrogliaccioPull {
    public StatoSegnalazioneResponse StatoSegnalazioneResponse;

    public class StatoSegnalazioneResponse {
        public List<StatoSegnalazioneResult> StatoSegnalazioneResult;
    }

    public class StatoSegnalazioneResult {
        public Boolean Esito;
        public String CodiceEnte;
        public Double StatoIntervento;
        public Integer VerbatelID;
        public String DescrStato;
        public String DescrEsito;
        public String DescrStatoIntervento;
        public Double Stato;
        public Double EsitoIntervento;
        public String DescrEsitoIntervento;
    }
}