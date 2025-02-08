public with sharing class ResponseAUC {
    @AuraEnabled
    public List<posizioniPerAnno> posizioniPerAnno = new List<posizioniPerAnno>();
    @AuraEnabled
    public Error errore = new Error();
    public class posizioniPerAnno{
        @AuraEnabled
        public String annoRiferimento;
        @AuraEnabled
        public List<posizioniPerTributo> posizioniPerTributo = new List<posizioniPerTributo>();
    }
    public class posizioniPerTributo{
        @AuraEnabled
        public String tipoTributo;
        @AuraEnabled
        public String numPosizioni;
        @AuraEnabled
        public List<posizioneContribuente> posizioneContribuente = new List<posizioneContribuente>();
    }
    public class posizioneContribuente {
        @AuraEnabled
        public String tipoTributo;
        @AuraEnabled
        public String annoRiferimento;
        @AuraEnabled
        public String dataEmissione;
        @AuraEnabled
        public String dataScadenza;
        @AuraEnabled
        public String dataPagamento;
        @AuraEnabled
        public String descPosizione;
        @AuraEnabled
        public String importoDovIntero;
        @AuraEnabled
        public String importoDovRidotto;
        @AuraEnabled
        public String importoDovMaggiorato;
        @AuraEnabled
        public String importoPagato;
        @AuraEnabled
        public List<pagamentiPosizione> pagamentiPosizione = new List<pagamentiPosizione>();
    }
    public class pagamentiPosizione {
        @AuraEnabled
        public String importoPag;
        @AuraEnabled
        public String dataPagamento;
        @AuraEnabled
        public String idPagamento;
        @AuraEnabled
        public String intermediarioPag;
    }
    public class Error{
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String message;
 
 
    }
}