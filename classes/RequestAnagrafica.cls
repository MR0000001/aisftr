/**
* Created by SNEKKANTI00 on 17/12/2020.
*/

public with sharing class RequestAnagrafica {
    public VerificaAnagrafica VerificaAnagrafica = new VerificaAnagrafica();
    
    public RequestAnagrafica(Integer searchType, Integer individualCode, String taxCode, String gender, String surname, String name, Integer birthDay, 
                             Integer birthMonth, Integer birthYear) {
        this.VerificaAnagrafica.TipoInterr = searchType;
        this.VerificaAnagrafica.CodiceIndividuale = individualCode;
        this.VerificaAnagrafica.CodiceFiscale = taxCode;
        this.VerificaAnagrafica.Sesso = gender;
        this.VerificaAnagrafica.Cognome = surname;
        this.VerificaAnagrafica.Nome = name;
        this.VerificaAnagrafica.GiornoNascita = birthDay;
        this.VerificaAnagrafica.MeseNascita = birthMonth;
        this.VerificaAnagrafica.AnnoNascita = birthYear;
    }
    
    
    public class VerificaAnagrafica {
        public Integer TipoInterr;
        public Integer CodiceIndividuale;
        public String CodiceFiscale;
        public String Sesso;
        public String Cognome;
        public String Nome;
        public Integer GiornoNascita;
        public Integer MeseNascita;
        public Integer AnnoNascita;
    }
}