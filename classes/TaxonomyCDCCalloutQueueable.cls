/**
 * Created by SNEKKANTI00 on 24/02/2021.
 */

public with sharing class TaxonomyCDCCalloutQueueable implements Queueable, Database.AllowsCallouts {
    private List<Taxonomy__c> taxes;
    private Boolean isInsert;

    public TaxonomyCDCCalloutQueueable(List<Taxonomy__c> taxes, Boolean isInsert) {
        this.isInsert = isInsert;
        this.taxes = taxes;
    }

    public void execute(QueueableContext qc) {
        TaxonomyCDCCallout.taxonomyCDCCallout(this.taxes, this.isInsert);
    }
}