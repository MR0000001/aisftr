public with sharing class RequestRSM {
    public InviaSegnalazione inviaSegnalazione;

    public class InviaSegnalazione{
        public Segnalazione segnalazione;
    }

    public class Segnalazione{
        public String identificativo;
        public String targa;
        public String numeroConcessione;
        public String comuneRilascio;
        public String idComune;
        public String dataAccesso;
        public String oraInizioAccesso;
        public String dataFineAccesso;
        public String oraFineAccesso;
    }
    
}