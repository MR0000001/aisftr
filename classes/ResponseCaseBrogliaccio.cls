/**
 * Created by SNEKKANTI00 on 23/02/2021.
 */

public with sharing class ResponseCaseBrogliaccio {
    public InserisciSegnalazioneResponse InserisciSegnalazioneResponse;

    public class InserisciSegnalazioneResponse {
        public List<InserisciSegnalazioneResult> InserisciSegnalazioneResult;
    }

    public class InserisciSegnalazioneResult {
        public Boolean Esito;
        public String DescrEsito;
        public Integer IDSegnalazione;
        public String PortalID;
    }
}