/**
 * Created by SNEKKANTI00 on 19/02/2021.
 */

public with sharing class RequestTaxonomy {
    
    public String stato;
    public String codice_case;
    public String area_t;
    public String argomento;
    public String specifica;
    public String coda;
    public String geo_loc;
    public String geo_loc2;
    public String pericolo;
    public String cdc;
    public Boolean cdc_case;
    public String useful_info;
    public String id_sf;

    public RequestTaxonomy(Taxonomy__c tax) {
        /*List<Schema.PicklistEntry> pickList = Schema.SObjectType.Taxonomy__c.fields.Tax_Type__c.getPicklistValues();
        for(Schema.PicklistEntry e : pickList) {
            if(e.getValue().equalsIgnoreCase(tax.Tax_Type__c))  this.codice_case = e.getLabel();
        }*/
        this.codice_case = tax.Tax_Type__c;
        this.id_sf = tax.Id;
        this.stato = String.valueOf(tax.Tax_Active__c);
        this.area_t = tax.Tax_Theme_Area__c;
        this.argomento = tax.Tax_Topic_Service__c;
        this.specifica = tax.Tax_Specification__c;
        this.geo_loc = String.valueOf(tax.Tax_Geolocalization__c);
        this.coda = tax.Tax_Queue__c;
        this.geo_loc2 = tax.Geo_Municipality__c;
        this.cdc = String.valueOf(tax.Tax_CDC_Visible__c);
        this.pericolo = String.valueOf(tax.Tax_Alert_Police_Warning__c);
        this.cdc_case = tax.CDC_Case__c;
        this.useful_info = tax.Useful_Info__c;
    }
}