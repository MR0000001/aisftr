/**
 * Created by LCONATO00 on 22/07/2020.
 */

public with sharing class ConsultationController {
    @AuraEnabled
    public static Map<String, String> getPositions (){
        Map<String, String> options = new Map<String, String>();
        List<Posizioni__mdt> positions = PosizioniDAO.getAllPositions();
        for(Posizioni__mdt position : positions){
            options.put(position.Codice_Posizione__c,position.Label);

        }
        return options;
    }
    @AuraEnabled
    public static Case getCase (String recordId){
        system.debug('@@@ record Id '+recordId);
        system.debug('@@@ record Id '+CaseSelector.getCaseById(recordId));
        return CaseSelector.getCaseById(recordId);
    }

    @AuraEnabled
    public static Map<String, String> getTributesTypologies(){
        Map<String, String> options = new Map<String, String>();
        List<Tipologia_Tributo__mdt> tributeTypologies = TipologiaTributoDAO.getAllTributesTypologies();
        for(Tipologia_Tributo__mdt tributeTypology : tributeTypologies){
            options.put(tributeTypology.ID_Categoria__c,tributeTypology.Label);

        }
        return options;
    }
    /* wrapper class */
    @TestVisible
    public class caseListWrapper {
        @AuraEnabled
        public String tipoServizio{get;set;}
        @AuraEnabled
        public String annoScolastico{get;set;}
        @AuraEnabled
        public String nome{get;set;}
        @AuraEnabled
        public String cognome{get;set;}
        @AuraEnabled
        public String dataNascita{get;set;}
        @AuraEnabled
        public String telefonoRichiedente{get;set;}
        @AuraEnabled
        public String statoDomanda{get;set;}
        @AuraEnabled
        public String nota{get;set;}
        @AuraEnabled
        public String msgUid{get;set;}
        @AuraEnabled
        public String caseId{get;set;}
        public caseListWrapper(String tipoServizio, String annoScolastico, String nome,String cognome, String dataNascita, String telefonoRichiedente, String statoDomanda, String nota, String msgUid, String caseId){
            this.tipoServizio = tipoServizio;
            this.annoScolastico = annoScolastico;
            this.cognome = cognome;
            this.dataNascita = dataNascita;
            this.telefonoRichiedente = telefonoRichiedente;
            this.statoDomanda = statoDomanda;
            this.nota = nota;
            this.msgUid = msgUid;
            this.nome = nome;
            this.caseId = caseId;

        }
    }
    
    /** 
    @TestVisible
    public class tributesListWrapper {
        @AuraEnabled
        public String tipoTributo{get;set;}
        @AuraEnabled
        public String annoRiferimento{get;set;}
        @AuraEnabled
        public String dataEmissione{get;set;}
        @AuraEnabled
        public String dataScadenza{get;set;}
        @AuraEnabled
        public String dataPagamento{get;set;}
        @AuraEnabled
        public String descPosizione{get;set;}
        @AuraEnabled
        public String importoDovIntero{get;set;}
        @AuraEnabled
        public String importoDovRidotto{get;set;}
        @AuraEnabled
        public String importoDovMaggiorato{get;set;}
        @AuraEnabled
        public String importoPag{get;set;}
        @AuraEnabled
        public String importoPagato{get;set;}
        @AuraEnabled
        public String idPagamento{get;set;}
        @AuraEnabled
        public String intermediarioPag{get;set;}
        @AuraEnabled
        public Integer tributeId{get;set;}
        public tributesListWrapper(String tipoTributo, String annoRiferimento, String descPosizione,String importoDovIntero, String dataEmissione, String importoDovRidotto, String importoDovMaggiorato,
                String importoPag, String idPagamento, String intermediarioPag, String dataScadenza, String dataPagamento, String importoPagato, Integer tributeId){
            this.tipoTributo = tipoTributo;
            this.annoRiferimento = annoRiferimento;
            this.descPosizione = descPosizione;
            this.importoDovIntero = importoDovIntero;
            this.dataEmissione = dataEmissione;
            this.importoDovRidotto = importoDovRidotto;
            this.importoDovMaggiorato = importoDovMaggiorato;
            this.importoPag = importoPag;
            this.idPagamento = idPagamento;
            this.intermediarioPag = intermediarioPag;
            this.dataScadenza = dataScadenza;
            this.dataPagamento = dataPagamento;
            this.importoPagato = importoPagato;
            this.tributeId = tributeId;

        }
    }
    */
    @AuraEnabled
    public static List<caseListWrapper> fetchCaseWrapper(String fiscalCode, String caseNumber, String caseId){

        List<caseListWrapper> lstcaseListWrapper = new List<caseListWrapper>();
        /*for(Integer i = 0; i<100; i++){
            lstcaseListWrapper.add(new caseListWrapper('Test '+i,'Test '+i,'Test '+i,'Test '+i,'Test '+i,'Test '+i,'Test '+i,'TestTestTest TestTestTestTestTes tTestTestTestTes  tTestTestTe stTestTestT stTestTestTqwe qwjkfajhas kd aljfdsa  '+i,'Test '+i,'Test '+i));
        }*/
        ResponseMesis respMesis = MesisCallout.MesisCallout(fiscalCode, caseNumber);
        System.debug('respMesis: ' + respMesis);
        caseListWrapper wrapper = null;
        if(respMesis.retCode != null) {
            if(respMesis.retCode.equalsIgnoreCase('200')) {
                wrapper = new caseListWrapper(respMesis.domanda.tipoServizio, respMesis.domanda.annoScolastico, respMesis.domanda.alunno.nome, respMesis.domanda.alunno.cognome,respMesis.domanda.alunno.dataNascita, respMesis.domanda.telefonoRichiedente, respMesis.domanda.alunno.statoDomanda, respMesis.domanda.alunno.nota, respMesis.msgUid, caseId);
            } else {
                throw new AuraHandledException(System.Label.SchoolConsultation_Notfound);
            }
        } else {
            throw new AuraHandledException(System.Label.SchoolConsultation_ServerError);
        }

        lstcaseListWrapper.add(wrapper);

        // return the 'lstaccountListWrapper' list
        return lstcaseListWrapper;
    }
    @AuraEnabled
    public static ResponseAUC fetchTributesWrapper(String fiscalCode, Integer position, String year, String  tributeTypology){
        system.debug('@@@ fiscalCode '+fiscalCode);
        system.debug('@@@ position '+position);
        system.debug('@@@ year '+year);
        system.debug('@@@ tributeTypology '+tributeTypology);
        ResponseAUC response = new ResponseAUC();
        /** 
        for(Integer i = 0; i<100; i++){
            lsttributeListWrapper.add(new tributesListWrapper('Test '+i,'Test '+i,'Test '+i,'Test '+i,'Test '+i,'Test '+i,'Test '+i,'Test '+i,'Test '+i,'Test '+i,'Test '+i,'Test '+i,'Test '+i,i));
        }
        */
        
        response = AUCCallout.AUCCallout(fiscalCode, position, year, tributeTypology);
        system.debug('@@@ response '+response);
        // return the 'lstaccountListWrapper' list
        return response;
    }
    /**
    @AuraEnabled(cacheable = true)  
   public static List<Account> getAccountsList() {  
     String query = 'select id, Name from Account ';  
     List<Account> accs = Database.query(query);
     system.debug('@@@ accs '+accs);
     return accs;  
   }   
   @AuraEnabled(cacheable = true)  
   public static Integer getAccountsCount(String searchString) {  
     String query = 'select count() from Account ';  
     if (searchString != null && searchString != '') {  
       query += ' where name like \'%' + searchString + '%\' ';  
     }  
     return Database.countQuery(query);  
   }  
   */

    @AuraEnabled
    public static List<String> getAnonymousIds() {
        List<String> anonIds = new List<String>();
        OrgManagement__c setting = OrgManagement__c.getOrgDefaults();
        if(setting?.AnonymuosID_del__c != null) anonIds.add(setting.AnonymuosID_del__c);
        if(setting?.Anonymous_ContactID__c != null) anonIds.add(setting.Anonymous_ContactID__c);

        if(!anonIds.isEmpty()) return anonIds;

        return null;
    }
}