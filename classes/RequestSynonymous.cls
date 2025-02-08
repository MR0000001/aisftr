/**
 * Created by SNEKKANTI00 on 22/02/2021.
 */

public with sharing class RequestSynonymous {
    public String id_sf;
    public String nome;
    public String sinonimo_1;
    public String sinonimo_2;
    public String sinonimo_3;
    public String sinonimo_4;
    public String sinonimo_5;
    public String sinonimo_6;
    public String sinonimo_7;
    public String sinonimo_8;
    public String sinonimo_9;
    public String sinonimo_10;

    public RequestSynonymous(Synonymous__c syn) {
        this.id_sf = syn.Id;
        this.nome = syn.Taxonomy_Value__c;
        this.sinonimo_1 = syn.Synonym_value_1__c;
        this.sinonimo_2 = syn.Synonym_value_2__c;
        this.sinonimo_3 = syn.Synonym_value_3__c;
        this.sinonimo_4 = syn.Synonym_value_4__c;
        this.sinonimo_5 = syn.Synonym_value_5__c;
        this.sinonimo_6 = syn.Synonym_value_6__c;
        this.sinonimo_7 = syn.Synonym_value_7__c;
        this.sinonimo_8 = syn.Synonym_value_8__c;
        this.sinonimo_9 = syn.Synonym_value_9__c;
        this.sinonimo_10 = syn.Synonym_value_10__c;
    }
}