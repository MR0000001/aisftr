/**
 * Created by FMARCHEGIA00 on 01/02/2021.
 */

public with sharing class TaxonomySelector {

    public static List<Taxonomy__c> getTaxonomieForCDCCase() {
        return [SELECT Tax_Theme_Area__c, Tax_Topic_Service__c, Tax_Specification__c,Geo_Municipality__c, Tax_Queue__c, toLabel(Tax_Type__c), MajorRoads__c
        FROM Taxonomy__c WHERE Tax_Active__c = true AND Tax_CDC_Visible__c = true];
    }

}