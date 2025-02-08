/**
* @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 28/06/2019
* @date Modification 01/07/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com & Domenico Del Prete - domenico.delprete@nttdata.com
* @description XC_UTIL_LeadConversion – Util class for LeadConversion methods
*/

public without sharing class XC_UTIL_LeadConversion {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_LeadConversion');

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com & Domenico Del Prete - domenico.delprete@nttdata.com
     * @param ld - Lead
     * @param objectName - String 
     * @param objectToUpdate - sObject
     * @description Method to populate Account/Contact/Opportunity data based on Lead data.
     */
    public static void populateSobjectDataByLeadData(Lead ld, String objectName, sObject objectToUpdate){    
        String country = ld.Country__c.toUpperCase();
        Map<String, String> mapObjectFieldLeadField = new Map<String, String>(); 
        List<XC_CM_LeadConversionMapping__mdt> listFieldsMapping = new List<XC_CM_LeadConversionMapping__mdt>([
            SELECT Id, XC_LeadField__c, XC_DestinationField__c 
            FROM XC_CM_LeadConversionMapping__mdt
            WHERE XC_Country__c = :country AND 
                    XC_DestinationObject__c = :objectName AND
                    XC_LeadRecordType__c = :ld.XC_LeadRecordType__c

        ]);
        for(XC_CM_LeadConversionMapping__mdt cm : listFieldsMapping) {
            mapObjectFieldLeadField.put(cm.XC_DestinationField__c, cm.XC_LeadField__c);
        }
       
        populateSobjectDataByLeadData(ld, objectToUpdate, mapObjectFieldLeadField);
       
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com & Domenico Del Prete - domenico.delprete@nttdata.com
     * @param ld - Lead
     * @param objectToUpdate - sObject
     * @param mapObjectFieldLeadField - Map<String, String>
     * @description Method to populate Account/Contact/Opportunity data based on Lead data.
     */
    public static void populateSobjectDataByLeadData(Lead ld, sObject objectToUpdate, Map<String, String> mapObjectFieldLeadField){
        Set<String> objectFields = mapObjectFieldLeadField.keyset();
        for(String objectField : objectFields) {
            if(objectToUpdate.get(objectField) == null && ld.get(mapObjectFieldLeadField.get(objectField)) != null) {
                objectToUpdate.put(objectField, ld.get(mapObjectFieldLeadField.get(objectField)));
            }
        }
    } 

}