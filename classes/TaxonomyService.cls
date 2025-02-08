/**
 * Created by SNEKKANTI00 on 18/02/2021.
 */

public with sharing class TaxonomyService {
    private static List<Taxonomy__c> taxesSent = null;
    private static Boolean isFromFuture = false;

    public static void setTaxonomyTimeStamp(List<Taxonomy__c> taxes) {
        for(Taxonomy__c tax : taxes) {
            if(tax.Tax_CDC_Visible__c){
                tax.Tax_Timestamp_Chiamata_CDC__c = Datetime.Now();
            }
        }
    }

    public static void setTaxonomyBackupAndManageCallout(List<Taxonomy__c> taxes, Map<Id, Taxonomy__c> oldTaxes) {
        if(!isFromFuture) {
            List<Taxonomy__c> taxesToSend = new List<Taxonomy__c>();
            for(Taxonomy__c tax : taxes) {
                if(tax.Tax_Timestamp_Chiamata_CDC__c != null) {
                    System.debug('block');
                    tax.addError(System.Label.TaxonomySynonimyCDC_Error);
                } else {
                    System.debug('to send');
                    System.debug('tax -> '+ tax);
                    System.debug('oldTaxes.get(tax.id) -> '+ oldTaxes.get(tax.id));
                    if((tax.Tax_CDC_Visible__c == true || tax.Tax_CDC_Visible__c != oldTaxes.get(tax.id).Tax_CDC_Visible__c)
                            && (tax.Tax_Specification__c != oldTaxes.get(tax.id).Tax_Specification__c
                            || tax.Tax_Topic_Service__c != oldTaxes.get(tax.id).Tax_Topic_Service__c
                            || tax.Tax_Theme_Area__c != oldTaxes.get(tax.id).Tax_Theme_Area__c
                            || tax.Tax_Geolocalization__c != oldTaxes.get(tax.id).Tax_Geolocalization__c
                            || tax.Tax_CDC_Visible__c != oldTaxes.get(tax.id).Tax_CDC_Visible__c
                            || tax.Tax_Type__c !=  oldTaxes.get(tax.id).Tax_Type__c
                            || tax.Geo_Municipality__c != oldTaxes.get(tax.id).Geo_Municipality__c
                            || tax.CDC_Case__c != oldTaxes.get(tax.id).CDC_Case__c
                            || tax.Useful_Info__c != oldTaxes.get(tax.id).Useful_Info__c)
                            ) {
                        tax.Tax_Specification_Backup__c = oldTaxes.get(tax.id).Tax_Specification__c;
                        tax.Tax_Topic_Service_Backup__c = oldTaxes.get(tax.id).Tax_Topic_Service__c;
                        tax.Tax_Theme_Area_Backup__c = oldTaxes.get(tax.id).Tax_Theme_Area__c;
                        tax.Tax_Geolocalization_Backup__c = oldTaxes.get(tax.id).Tax_Geolocalization__c;
                        tax.Tax_CDC_Visible_Backup__c = oldTaxes.get(tax.id).Tax_CDC_Visible__c;
                        tax.Tax_Type_Backup__c = oldTaxes.get(tax.id).Tax_Type__c;
                        tax.Geo_Municipality_Backup__c = oldTaxes.get(tax.id).Geo_Municipality__c;
                        tax.Tax_Timestamp_Chiamata_CDC__c = Datetime.now();
                        tax.CDC_Case_Backup__c = oldTaxes.get(tax.id).CDC_Case__c;
                        tax.Useful_Info_Backup__c = oldTaxes.get(tax.id).Useful_Info__c;

                        taxesToSend.add(tax);
                    }
                }
            }
            system.debug('taxesToSend -> ' + taxesToSend);
            if(!taxesToSend.isEmpty()) {
                doCallout(taxesToSend, false, true);
            }
        }
    }

    /*
    estensione della chiamata doCallout dove se forceToSend == true allora bypassa il controllo ed effettua comunque il callout
     */
    public static void doCallout(List<Taxonomy__c> taxonomies, Boolean isInsert, Boolean forceToSend) {
        List<Taxonomy__c> taxesToSend = new List<Taxonomy__c>();

        for(Taxonomy__c tax : taxonomies) {
            if(forceToSend || tax.Tax_CDC_Visible__c) {
                taxesToSend.add(tax);
            }
        }

        if(isInsert && taxesToSend != null && !taxesToSend.isEmpty()) taxesToSend = taxonomies.deepClone(true, false);

        if(taxesToSend != null && !taxesToSend.isEmpty()) {
            taxesToSend = taxonomies.deepClone(true, false);
            String jobID = System.enqueueJob(new TaxonomyCDCCalloutQueueable(taxesToSend, isInsert));
            System.debug('jobID ' + jobID);
        }
    }

    public static void calloutAndPostProcess(List<Taxonomy__c> taxesFromCallout, String errorMsg, Boolean fullRollBack, Boolean isInsert) {
        Boolean rollBackAll = fullRollBack;
        Boolean isDeleted = false;
        isFromFuture = true;
        taxesSent = taxesFromCallout;

        if(!rollBackAll) {
            if(isInsert) {
                for(Taxonomy__c tax : taxesSent) {
                    setRequiredFields('Sync', null, tax);
                }
            } else {
                for(Taxonomy__c tax : taxesSent) {
                    integrationSuccess('Sync', null, tax);
                }
            }
        } else {
            if(isInsert) {
                try {
                    DELETE taxesSent;
                    isDeleted = true;
                } catch(Exception e) {
                    System.debug('Exception at TaxonomyService.calloutAndPostProcess ' + e.getMessage());

                    Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
                    Database.SaveResult results = ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
                }
            } else {
                for(Taxonomy__c tax : taxesSent) {
                    integrationFailed('Not Sync', errorMsg, tax);
                }
            }
        }

        try {
            if(!isDeleted) UPDATE taxesSent;
        } catch(Exception e) {
            System.debug('Exception at TaxonomyService.calloutAndPostProcess ' + e.getMessage());

            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
            Database.SaveResult results = ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }

    private static void integrationSuccess(String syncValue, String errorMessage, Taxonomy__c tax) {
        System.debug('integrationSuccess taxes ' + tax);

        setRequiredFields(syncValue, errorMessage, tax);
        clearBackupFields(tax);
    }

    private static void integrationFailed(String syncValue, String errorMessage, Taxonomy__c tax) {
        System.debug('integrationFailed taxes ' + tax);

        setRequiredFields(syncValue, errorMessage, tax);
        resetFieldsWithBackupFields(tax);
    }

    private static void setRequiredFields(String syncValue, String errorMessage, Taxonomy__c tax) {
        tax.Tax_Sent_to_External__c = syncValue;
        tax.Tax_Error_Message__c = errorMessage;
        tax.Tax_Timestamp_Chiamata_CDC__c = null;
    }

    @TestVisible
    private static void clearBackupFields(Taxonomy__c tax) {
        tax.Tax_Specification_Backup__c = null;
        tax.Tax_Topic_Service_Backup__c = null;
        tax.Tax_Theme_Area_Backup__c = null;
        tax.Tax_Geolocalization_Backup__c = false;
        tax.Tax_CDC_Visible_Backup__c = false;
        tax.Tax_Type_Backup__c = null;
        tax.Geo_Municipality_Backup__c = null;
        tax.CDC_Case_Backup__c = false;
        tax.Useful_Info_Backup__c = null;
    }

    private static void resetFieldsWithBackupFields(Taxonomy__c tax) {
        tax.Tax_Specification__c = tax.Tax_Specification_Backup__c;
        tax.Tax_Topic_Service__c = tax.Tax_Topic_Service_Backup__c;
        tax.Tax_Theme_Area__c = tax.Tax_Theme_Area_Backup__c;
        tax.Tax_Geolocalization__c = tax.Tax_Geolocalization_Backup__c;
        tax.Tax_CDC_Visible__c = tax.Tax_CDC_Visible_Backup__c;
        tax.Tax_Type__c = tax.Tax_Type_Backup__c;
        tax.Geo_Municipality__c = tax.Geo_Municipality_Backup__c;
        tax.CDC_Case__c = tax.CDC_Case_Backup__c;
        tax.Useful_Info__c = tax.Useful_Info_Backup__c;
    }
}