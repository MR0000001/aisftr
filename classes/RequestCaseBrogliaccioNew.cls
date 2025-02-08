/**
 * Created by snekkanti002 on 21/09/2021.
 */

public without sharing class RequestCaseBrogliaccioNew {
    public List<InserisciSegnalazione> InserisciSegnalazione = new List<InserisciSegnalazione>();

    public class InserisciSegnalazione {
        public Req req = new Req();
    }

    public class Req {
        public String PortalID;
        public Datetime DtCreazione;
        public String Classificazione;
        public String Citta;
        public String Indirizzo;
        public String Civico;
        public String Segnalatore;
        public String TelefonoSegnalatore;
        public String Latitudine;
        public String Longitudine;
        public String Note;
        public String NumeroImmagini;
    }

    public RequestCaseBrogliaccioNew(List<Case> cases) {
        for(Case c : cases) {
            InserisciSegnalazione seg = new InserisciSegnalazione();

            seg.req.PortalID = c.Id;
            seg.req.DtCreazione = c.CreatedDate;
            seg.req.Classificazione = c.Case_Specification__c;
            seg.req.Citta = 'Roma';
            seg.req.Indirizzo = c.Street_Address__c;
            seg.req.Civico = (c.Number_Address__c != null) ? String.valueOf(c.Number_Address__c) : '0';
            seg.req.Segnalatore = c.Account.Name;
            seg.req.TelefonoSegnalatore = (c.ContactMobile != null) ? String.valueOf(c.ContactMobile) : '0';
            seg.req.Latitudine = (c.Geolocation__Latitude__s != null) ? String.valueOf(c.Geolocation__Latitude__s) : '0.0';
            seg.req.Longitudine = (c.Geolocation__Longitude__s != null) ? String.valueOf(c.Geolocation__Longitude__s) : '0.0';
            seg.req.Note = c.Subject;
            seg.req.NumeroImmagini = (c.Brogliaccio_N_Attachment__c != null) ? String.valueOf(c.Brogliaccio_N_Attachment__c) : '0';

            this.InserisciSegnalazione.add(seg);
        }
    }
}