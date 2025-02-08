/**
 * Created by SNEKKANTI00 on 12/07/2021.
 */

public without sharing class RequestGEDCase {
    public List<Casi> casi = new List<Casi>();

    public class Casi {
        public Autenticazione autenticazione = new Autenticazione();
        public TipologiaDocumenti tipologiaDocumenti = new TipologiaDocumenti();
        public DatiProtocollazione datiProtocollazione = new DatiProtocollazione();
        public Mittente mittente = new Mittente();
    }

    public class Autenticazione {
        public String codiceFiscale;
    }

    public class TipologiaDocumenti {
        public String codiceProceduraChiamante;
        public String codiceDocumento;
    }

    public class DatiProtocollazione {
        public String testoOggetto;
        public String idUnivocoProceduraChiamante;
        public String id;
        public Boolean isDocumentoRiservato;
        public String codiceDocumentoLogico;
        public Boolean isEsistente;
    }

    public class Mittente {
        public String tipoNominativo;
        public String descrizioneNominativo;
        public String codiceFiscale;
        public Date dataNascita;
        public String email;
        public Indirizzo indirizzo = new Indirizzo();
    }

    public class Indirizzo {
        public String descrizioneVia;
        public String cap;
        public String descrizioneComune;
        public String descrizioneProvincia;
    }

    public RequestGEDCase(List<Case> cases) {
        for(Case c : cases) {
            Casi casiSingolo = new Casi();
            if(c.Case_Business_Account__c) {
                casiSingolo.mittente.descrizioneNominativo = c.Account.Name;
                casiSingolo.mittente.codiceFiscale = String.isNotBlank(c.Account.Account_Fiscal_Code__c) ? c.Account.Account_Fiscal_Code__c + '/': '';
                casiSingolo.mittente.codiceFiscale += String.isNotBlank(c.Account.Partita_IVA__c) ? c.Account.Partita_IVA__c : casiSingolo.mittente.codiceFiscale.removeEnd('/');
                casiSingolo.mittente.email = c.Account.Email_Account__c;
                casiSingolo.mittente.indirizzo.descrizioneVia = c.Account.BillingStreet;
                casiSingolo.mittente.indirizzo.cap = c.Account.BillingPostalCode;
                casiSingolo.mittente.indirizzo.descrizioneComune = c.Account.BillingCity;
                casiSingolo.mittente.indirizzo.descrizioneProvincia = c.Account.BillingState;
                casiSingolo.mittente.tipoNominativo = Label.LegalEntities_GED_PersonLegal;
            } else {
                casiSingolo.mittente.codiceFiscale = c.Account.Fiscal_Code__pc;
                casiSingolo.mittente.descrizioneNominativo = c.Account.LastName+'/'+c.Account.FirstName;
                casiSingolo.mittente.email = c.Account.PersonEmail;
                casiSingolo.mittente.indirizzo.descrizioneVia = c.Account.PersonOtherStreet;
                casiSingolo.mittente.indirizzo.cap = c.Account.PersonOtherPostalCode;
                casiSingolo.mittente.indirizzo.descrizioneComune = c.Account.PersonOtherCity;
                casiSingolo.mittente.indirizzo.descrizioneProvincia = c.Account.PersonOtherState;
                casiSingolo.mittente.tipoNominativo = Label.LegalEntities_GED_PersonPhysical;
            }
            casiSingolo.autenticazione.codiceFiscale = c.ProtocolCFUser__c;
            casiSingolo.datiProtocollazione.idUnivocoProceduraChiamante = 'CRM_' + c.CaseNumber;
            casiSingolo.datiProtocollazione.id = c.Id;
            casiSingolo.datiProtocollazione.testoOggetto = c.Subject;
            casiSingolo.datiProtocollazione.isDocumentoRiservato = false;
            casiSingolo.datiProtocollazione.codiceDocumentoLogico = c.DOC_LOGIC__c;
            casiSingolo.datiProtocollazione.isEsistente = true;
            casiSingolo.mittente.dataNascita = c.Persona_Fisica__r.PersonBirthdate;
            casiSingolo.tipologiaDocumenti.codiceProceduraChiamante = c.COD_SIS__c;
            casiSingolo.tipologiaDocumenti.codiceDocumento = c.COD_DOC__c;

            this.casi.add(casiSingolo);
        }
    }
}