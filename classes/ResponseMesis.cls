public with sharing class ResponseMesis {
    public String msgUid;
    public String timestamp;
    public String retCode;
    public String errore;
    public Domanda domanda = new Domanda();

    public class Domanda {
        public String tipoServizio;
        public String annoScolastico;
        public String telefonoRichiedente;
        public Alunno alunno = new Alunno();
    }

    public class Alunno {
        public String nome;
        public String cognome;
        public String dataNascita;
        public String statoDomanda;
        public String nota;
        public String url;
    }
}