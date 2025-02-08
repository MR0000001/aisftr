/**
 * Created by SNEKKANTI00 on 10/12/2020.
 */

public with sharing class ResponseNIC {

    @AuraEnabled
    public Municipio municipio = new Municipio();
    @AuraEnabled
    public NICError nicError;

    public class Municipio {
        @AuraEnabled
        public Integer numberMunicipio;
        @AuraEnabled
        public String romanNumeralMunicipio;
        @AuraEnabled
        public Integer IdMunicipio;
    }

    public class NICError {
        @AuraEnabled
        public String message;

        public NICError(String message) {
            this.message = message;
        }
    }
}