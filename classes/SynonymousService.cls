/**
 * Created by SNEKKANTI00 on 18/02/2021.
 */

public with sharing class SynonymousService {
    private static List<Synonymous__c> synonymousSent = null;
    private static Boolean isFromFuture = false;

    public static void setSynonymousTimeStamp(List<Synonymous__c> synonymous) {
        for(Synonymous__c syn : synonymous) {
            syn.Synonim_Timestamp_Chiamata_CDC__c = Datetime.Now();
        }
    }

    public static void setSynonymousBackupAndManageCallout(List<Synonymous__c> synonymous, Map<Id, Synonymous__c> oldSyns) {
        if(!isFromFuture) {
            List<Synonymous__c> synonymousToSend = new List<Synonymous__c>();
            for(Synonymous__c syn : synonymous) {
                if(syn.Synonim_Timestamp_Chiamata_CDC__c != null) {
                    System.debug('block');
                    syn.addError(System.Label.TaxonomySynonimyCDC_Error);
                } else {
                    System.debug('to send');
                    if(syn.Taxonomy_Value__c != oldSyns.get(syn.id).Taxonomy_Value__c  || syn.Synonym_value_1__c != oldSyns.get(syn.id).Synonym_value_1__c || syn.Synonym_value_2__c != oldSyns.get(syn.id).Synonym_value_2__c || syn.Synonym_value_3__c != oldSyns.get(syn.id).Synonym_value_3__c || syn.Synonym_value_4__c != oldSyns.get(syn.id).Synonym_value_4__c || syn.Synonym_value_5__c != oldSyns.get(syn.id).Synonym_value_5__c || syn.Synonym_value_6__c != oldSyns.get(syn.id).Synonym_value_6__c || syn.Synonym_value_7__c != oldSyns.get(syn.id).Synonym_value_7__c || syn.Synonym_value_8__c != oldSyns.get(syn.id).Synonym_value_8__c || syn.Synonym_value_9__c != oldSyns.get(syn.id).Synonym_value_9__c || syn.Synonym_value_10__c != oldSyns.get(syn.id).Synonym_value_10__c) {
                        syn.Taxonomy_Value_Backup__c = oldSyns.get(syn.id).Taxonomy_Value__c;
                        syn.Synonym_value_1_Backup__c = oldSyns.get(syn.id).Synonym_value_1__c;
                        syn.Synonym_value_2_Backup__c = oldSyns.get(syn.id).Synonym_value_2__c;
                        syn.Synonym_value_3_Backup__c = oldSyns.get(syn.id).Synonym_value_3__c;
                        syn.Synonym_value_4_Backup__c = oldSyns.get(syn.id).Synonym_value_4__c;
                        syn.Synonym_value_5_Backup__c = oldSyns.get(syn.id).Synonym_value_5__c;
                        syn.Synonym_value_6_Backup__c = oldSyns.get(syn.id).Synonym_value_6__c;
                        syn.Synonym_value_7_Backup__c = oldSyns.get(syn.id).Synonym_value_7__c;
                        syn.Synonym_value_8_Backup__c = oldSyns.get(syn.id).Synonym_value_8__c;
                        syn.Synonym_value_9_Backup__c = oldSyns.get(syn.id).Synonym_value_9__c;
                        syn.Synonym_value_10_Backup__c = oldSyns.get(syn.id).Synonym_value_10__c;
                        syn.Synonim_Timestamp_Chiamata_CDC__c = Datetime.now();

                        synonymousToSend.add(syn);
                    }
                }
            }
            if(!synonymousToSend.isEmpty()) {
                doCallout(synonymousToSend, false);
            }
        }
    }

    public static void doCallout(List<Synonymous__c> synonymous, Boolean isInsert) {
        List<Synonymous__c> synonymousToSend = synonymous;
        if(isInsert) synonymousToSend = synonymous.deepClone(true, false);

        String jobID = System.enqueueJob(new SynonymousCDCCalloutQueueable(synonymousToSend, isInsert));
        System.debug('jobID ' + jobID);
    }

    public static void calloutAndPostProcess(List<Synonymous__c> synsSent, String errorMsg, Boolean fullRollBack, Boolean isInsert) {
        Boolean rollBackAll = fullRollBack;
        Boolean isDeleted = false;
        isFromFuture = true;
        synonymousSent = synsSent;

        if(!rollBackAll) {
            if(isInsert) {
                for(Synonymous__c syn : synonymousSent) {
                    setRequiredFields('Sync', null, syn);
                }
            } else {
                for(Synonymous__c syn : synonymousSent) {
                    integrationSuccess('Sync', null, syn);
                }
            }
        } else {
            if(isInsert) {
                try {
                    DELETE synonymousSent;
                    isDeleted = true;
                } catch(Exception e) {
                    System.debug('Exception at SynonymousService.calloutAndPostProcess ' + e.getMessage());

                    Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
                    Database.SaveResult results = ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
                }
            } else {
                for(Synonymous__c syn : synonymousSent) {
                    integrationFailed('Not Sync', errorMsg, syn);
                }
            }
        }

        try {
            if(!isDeleted) UPDATE synonymousSent;
        } catch(Exception e) {
            System.debug('Exception at SynonymousService.calloutAndPostProcess ' + e.getMessage());

            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
            Database.SaveResult results = ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }

    private static void integrationSuccess(String syncValue, String errorMessage, Synonymous__c syn) {
        System.debug('integrationSuccess syn ' + syn);

        setRequiredFields(syncValue, errorMessage, syn);
        clearBackupFields(syn);
    }

    private static void integrationFailed(String syncValue, String errorMessage, Synonymous__c syn) {
        System.debug('integrationFailed syn ' + syn);

        setRequiredFields(syncValue, errorMessage, syn);
        resetFieldsWithBackupFields(syn);
    }

    private static void setRequiredFields(String syncValue, String errorMessage, Synonymous__c syn) {
        syn.Synonym_Sent_to_External__c = syncValue;
        syn.Synonym_Error_Message__c = errorMessage;
        syn.Synonim_Timestamp_Chiamata_CDC__c = null;
    }

    private static void clearBackupFields(Synonymous__c syn) {
        syn.Taxonomy_Value_Backup__c = null;
        syn.Synonym_value_1_Backup__c = null;
        syn.Synonym_value_1_Backup__c = null;
        syn.Synonym_value_2_Backup__c = null;
        syn.Synonym_value_3_Backup__c = null;
        syn.Synonym_value_4_Backup__c = null;
        syn.Synonym_value_5_Backup__c = null;
        syn.Synonym_value_6_Backup__c = null;
        syn.Synonym_value_7_Backup__c = null;
        syn.Synonym_value_8_Backup__c = null;
        syn.Synonym_value_9_Backup__c = null;
        syn.Synonym_value_10_Backup__c = null;
    }

    private static void resetFieldsWithBackupFields(Synonymous__c syn) {
        syn.Taxonomy_Value__c = syn.Taxonomy_Value_Backup__c;
        syn.Synonym_value_1__c = syn.Synonym_value_1_Backup__c;
        syn.Synonym_value_2__c = syn.Synonym_value_2_Backup__c;
        syn.Synonym_value_3__c = syn.Synonym_value_3_Backup__c;
        syn.Synonym_value_4__c = syn.Synonym_value_4_Backup__c;
        syn.Synonym_value_5__c = syn.Synonym_value_5_Backup__c;
        syn.Synonym_value_6__c = syn.Synonym_value_6_Backup__c;
        syn.Synonym_value_7__c = syn.Synonym_value_7_Backup__c;
        syn.Synonym_value_8__c = syn.Synonym_value_8_Backup__c;
        syn.Synonym_value_9__c = syn.Synonym_value_9_Backup__c;
        syn.Synonym_value_10__c = syn.Synonym_value_10_Backup__c;
    }
}