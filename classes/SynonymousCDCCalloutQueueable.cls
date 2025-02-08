/**
 * Created by SNEKKANTI00 on 24/02/2021.
 */

public with sharing class SynonymousCDCCalloutQueueable implements Queueable, Database.AllowsCallouts {
    private List<Synonymous__c> synonymous;
    private Boolean isInsert;

    public SynonymousCDCCalloutQueueable(List<Synonymous__c> synonymous, Boolean isInsert) {
        this.isInsert = isInsert;
        this.synonymous = synonymous;
    }

    public void execute(QueueableContext qc) {
        SynonymousCDCCallout.synonymousCDCCallout(this.synonymous, this.isInsert);
    }
}