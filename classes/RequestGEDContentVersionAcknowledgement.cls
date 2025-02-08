/**
 * Created by SNEKKANTI00 on 12/07/2021.
 */

public without sharing class RequestGEDContentVersionAcknowledgement {

    public List<CasiConAllegati> casiConAllegati = new List<CasiConAllegati>();

    public class CasiConAllegati {
        public Autenticazione autenticazione = new Autenticazione();
        public String codiceProcedura;
        public String codiceDocumento;
        public String utenteConnesso;
        public String tipoProtocollo;
        public String annoProtocollo;
        public String progressivoProtocollo;
        List<Allegati> allegati = new List<Allegati>();
    }

    public class Allegati {
        public String nomeFile;
        public String id;
    }

    public class Autenticazione {
        public String codiceFiscale;
    }

    public RequestGEDContentVersionAcknowledgement(Map<Case, List<ContentVersion>> caseCvsMap) {
        for(Case c : caseCvsMap.keySet()) {
            CasiConAllegati singolo = new CasiConAllegati();
            singolo.autenticazione.codiceFiscale = c.ProtocolCFUser__c;
            singolo.codiceProcedura = c.COD_SIS__c;
            singolo.codiceDocumento = c.COD_DOC__c;
            singolo.utenteConnesso = c.ProtocolCFUser__c;
            singolo.tipoProtocollo = c.Protocol_Number__c;
            singolo.annoProtocollo = c.YearProtocol__c;
            singolo.progressivoProtocollo = c.ID_Protocollo__c;

            this.casiConAllegati.add(singolo);

            List<ContentVersion> contentVersions = caseCvsMap.get(c);

            for(ContentVersion cv : contentVersions) {
                Allegati allegato = new Allegati();

                allegato.id = cv.Id;
                allegato.nomeFile = cv.Title + '.' + cv.FileExtension;

                singolo.allegati.add(allegato);
            }
        }
    }
}