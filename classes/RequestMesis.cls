public with sharing class RequestMesis {
    String cf;
    String codicePratica;

    public RequestMesis(String fiscalCode, String practiceCode) {
        this.cf = fiscalCode;
        this.codicePratica = practiceCode;
    }
}