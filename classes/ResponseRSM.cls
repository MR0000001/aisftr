public with sharing class ResponseRSM {
    public class invioSegnalazioneResponse {
        public Esito esito;
    }
    public class Esito{
        public String valore;
        public String descrizione;
    }

    public class invioMassivoSegnalazioneResponse {
        public List<EsitoMass> esito;
    }

    public class EsitoMass{
        public String identificativo;
        public String valore;
        public String descrizione;
    }
}