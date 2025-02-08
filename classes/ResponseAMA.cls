public with sharing class ResponseAMA {
    public class avvisoResponse {
        public EsitoCaricamento esitoCaricamento;
    }
    public class EsitoCaricamento{
        public String codiceSegnalazione;
        public String esito;
        public String codiceErrore;
        public String descrizioneErrore;
    }

    public class avvisiResponse {
        public EsitoMass esitoCaricamento;
    }

    public class EsitoMass{
        public String idSegnalazioneEsterna;
        public String codiceSegnalazione;
        public String esito;
        public String codiceErrore;
        public String descrizioneErrore;
    }
}