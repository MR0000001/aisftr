/**
 * Created by snekkanti002 on 17/05/2022.
 */

public without sharing class ResponseAutoreturn {
    public StoricoEventiAutoResponse storicoEventiAutoResponse;

    public class StoricoEventiAutoResponse {
        public List<Result> result;
    }

    public class Result {
        public String Targa;
        public String ModelloVeicolo;
        public String LuogoRimozione;
        public String TipoProcedimento;
        public String DataOraCustodia;
        public String Deposito;
        public Boolean VeicoloRitirato;
        public String DataOraRitiro;
        public String LuogoCustodia;
    }
}