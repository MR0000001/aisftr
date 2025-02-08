/**
 * Created by LCONATO00 on 11/11/2020.
 */

public with sharing class RequestAMA {
    public Avviso avviso = new Avviso();

    public class Avviso{
        public String idSegnalazioneEsterna;
        public String nome;
        public String cognome;
        public String telefono;
        public String indirizzoMail;
        public String descrTipologiaSegnalazioneEsterna;
        public String via;
        public String civico;
        public String esponenteCivico;
        public String dataRicezioneSegnalazione;
        public String oraRicezioneSegnalazione;
        public String testoBreve;
        public String tipologiaUtenza;
        public String codiceFiscale;
        public String partitaIVA;
        public String codiceClienteTARI;
        public String viaResidenzaBP;
        public String civicoResidenzaBP;
        public String esponenteCivicoResidenzaBP;
        public String capResidenzaBP;
        public String cittaResidenzaBP;
        public String provinciaResidenzaBP;
        public String dataNascita;
        public String luogoNascita;
        public String sesso;
        public String dataCostituzioneOrganizzazione;
        public String Tipologia_utenza;
    }

    public RequestAMA(Case caseToSend) {
        this.avviso.idSegnalazioneEsterna = caseToSend.CaseNumber;
        if(caseToSend.Case_Business_Account__c) {
            System.debug('Entered PG');
            if(caseToSend.Account.Name.length() > Integer.valueOf(Label.AmaRequest_NameLengthPG)) {
                System.debug('Entered length greater than 40');
                System.debug('caseToSend.Account.Name -> '+ caseToSend.Account.Name);
                this.avviso.nome = caseToSend.Account.Name.substring(0, Integer.valueOf(Label.AmaRequest_NameLengthPG));
                Integer endSurname = (caseToSend.Account.Name.length() < Integer.valueOf(Label.AmaRequest_NameLengthPG) + Integer.valueOf(Label.AmaRequest_SunrnameLengthPG) ? caseToSend.Account.Name.length() : Integer.valueOf(Label.AmaRequest_NameLengthPG) + Integer.valueOf(Label.AmaRequest_SunrnameLengthPG));
                this.avviso.cognome = caseToSend.Account.Name.substring(Integer.valueOf(Label.AmaRequest_NameLengthPG), endSurname);
                System.debug('nome -> '+ this.avviso.nome);
                System.debug('cognome -> '+ this.avviso.cognome);
            } else {
                System.debug('Entered length less than 40');
                this.avviso.nome = caseToSend.Account.Name;
                this.avviso.cognome = ''; //caseToSend.Account.Name;
            }
            this.avviso.Tipologia_utenza = Label.AmaRequest_UserTypePG;
        } else {
            System.debug('Entered PF');
            this.avviso.nome = (caseToSend.checkAnonymous__c) ? System.Label.AmaRequest_AnonymousName : caseToSend.Account.FirstName;
            this.avviso.cognome = (caseToSend.checkAnonymous__c) ? System.Label.AmaRequest_AnonymousName : caseToSend.Account.LastName;
        }
        this.avviso.telefono = (caseToSend.ContactPhone != null) ? caseToSend.ContactPhone : '';
        this.avviso.indirizzoMail = (caseToSend.ContactEmail != null) ? caseToSend.ContactEmail : '';
        this.avviso.descrTipologiaSegnalazioneEsterna = (caseToSend.Case_Specification__c != null && !caseToSend.Case_Specification__c.equalsIgnoreCase('')) ? caseToSend.Case_Specification__c.toUpperCase() : '';
        if(caseToSend.Street_Address__c != null && !caseToSend.Street_Address__c.equalsIgnoreCase('')) {
            if(caseToSend.Street_Address__c.length() > Integer.valueOf(System.Label.Ama_StreetLength)) {
                this.avviso.via = caseToSend.Street_Address__c.substring(0, Integer.valueOf(System.Label.Ama_StreetLength)).toUpperCase();
            } else {
                this.avviso.via = caseToSend.Street_Address__c.toUpperCase();
            }
        } else {
            this.avviso.via = '';
        }
        this.avviso.civico = (caseToSend.Number_Address__c != null) ? String.valueOf(Integer.valueOf(caseToSend.Number_Address__c)) : null;
        this.avviso.esponenteCivico = (caseToSend.Letter_Address__c != null && !caseToSend.Letter_Address__c.equalsIgnoreCase('')) ? caseToSend.Letter_Address__c : '';
        this.avviso.dataRicezioneSegnalazione = String.valueOf(caseToSend.CreatedDate.format('yyyyMMdd'));
        this.avviso.oraRicezioneSegnalazione = String.valueOf(caseToSend.CreatedDate.format('HHmmss'));
        this.avviso.testoBreve = '';
    }
}