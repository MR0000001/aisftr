/**
 * The Class XC_TR_BillProfLineItem_U_FillFields.
 *
 * @author            : Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 09/10/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Class to manage billing profile line item fields 
 **/ 



public without sharing class XC_TR_BillProfLineItem_U_FillFields {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_BillProfLineItem_U_FillFields');


    /**
    * populate fields on billing profile line item.
    * @param listNew the list new
    * @description populate the AccountID on billing profile line item
    */
    public static void fillFieldsOnInsert(List<XC_BillingProfileLineItem__c > listNew) {


        List<Id> billingProfileIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_BillingProfile__c');
        Set<String> countrySet = XC_UTIL_Sobject.getSetIdsStringOnField(listNew, 'XC_Country__c');

        Map<Id, NE__Billing_Profile__c > bpMap = new Map<Id, NE__Billing_Profile__c >([SELECT NE__Account__c FROM NE__Billing_Profile__c WHERE Id IN: billingProfileIds]);
        
        Map<String, String> countryCurrencyMap = new Map<String, String>();
        if(!countrySet.isEmpty()) {
            Map<Id, XC_CM_CountryISOCodeAssociation__mdt> countryMap = new Map<Id, XC_CM_CountryISOCodeAssociation__mdt>([
                                                                                        SELECT Id, XC_Country__c, XC_Currency__c
                                                                                        FROM XC_CM_CountryISOCodeAssociation__mdt
                                                                                        WHERE XC_Country__c IN: countrySet AND XC_Currency__c != null]);
            for(XC_CM_CountryISOCodeAssociation__mdt elem : countryMap.values()) {
                countryCurrencyMap.put(elem.XC_Country__c, elem.XC_Currency__c);
            }
        }

        for(XC_BillingProfileLineItem__c bpli : listNew){ 
           bpli.XC_Account__c = bpMap.get(bpli.XC_BillingProfile__c).NE__Account__c;
           bpli.XC_BillingProfileCopy__c = bpli.XC_BillingProfile__c;
           bpli.XC_Currency__c = (String.isNotBlank(bpli.XC_Country__c) && countryCurrencyMap.containsKey(bpli.XC_Country__c)) ? countryCurrencyMap.get(bpli.XC_Country__c) : ((bpli.XC_LegalEntity__c == 'EnelXMSP') ? 'EUR' : null);
        }

    }


    /**
     * ChangeBillingAddressOnZuora.
     * 
     * @author Luisana Rocco lrocco@deloitte.it
     * @param the mapmapOld old
     * @param mapNew the map new
     * @description Call Zuora when billing profile line item infos change
     */
    public static void changeInfosOnZuora(Map<Id, XC_BillingProfileLineItem__c> mapOld, Map<Id, XC_BillingProfileLineItem__c> mapNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_BillProfLineItem_U_FillFields.changeInfosOnZuora');

        List<XC_BillingProfileLineItem__c> listChanged = new List<XC_BillingProfileLineItem__c>();
        getChangedBpli(mapNew, mapOld, listChanged);

		XC_UTIL_Debug.debug(DEBUGACTIVE, '#listChanged -> ' + listChanged);
        for(XC_BillingProfileLineItem__c bpli : listChanged) {
            if(String.isNotBlank(bpli.XC_ZuoraId__c)){
                callZuoraAndUpdateInfos(JSON.serialize(bpli));
            }
		}
    }


    /**
     * callZuoraAndUpdateInfos.
     * 
     * @author Luisana Rocco lrocco@deloitte.it
     * @param bpliString the bpli
     * @param oldPEC the oldPEC
     * @param oldRecipientCode the oldRecipientCode
     * @description Call Zuora when field set field change
     */
    @future(callout=true)
    private static void callZuoraAndUpdateInfos(String bpliString) {

        XC_BillingProfileLineItem__c bpli = (XC_BillingProfileLineItem__c) JSON.deserialize(bpliString, XC_BillingProfileLineItem__c.class);

        Map<String, String> parametersMap = new Map<String, String>{'zuoraAccountId' => bpli.XC_ZuoraId__c,
                                                                    'billToId' => bpli.XC_BillToContactId__c,
                                                                    'soldToId' => bpli.XC_SoldToContactId__c,
                                                                    'billAddrId' => bpli.XC_BillToAddress__c,
                                                                    'soldAddrId' => bpli.XC_SoldToAddress__c,
                                                                    'legalEntity' => bpli.XC_LegalEntity__c,
                                                                    'billingProfileLineItemId' => bpli.Id};

        ZuoraWebService zws = new ZuoraWebService(XC_UTIL_Integration_U.getEntityNameWithStream(bpli.XC_LegalEntity__c, bpli.XC_Segment__c));
        ZuoraWebService.CreateZuoraAccountResponse responseUpdateAccount = zws.updateZuoraAccount(parametersMap);
        
    }


    /**
     * getChangedBpli.
     * 
     * @author Luisana Rocco lrocco@deloitte.it
     * @param mapNew the mapNew
     * @param fieldList the fieldList
     * @param bpliToUpdate the bpliToUpdate
     * @description get all bpli changed
     */
    public static void getChangedBpli(Map<Id, XC_BillingProfileLineItem__c> mapNew, Map<Id, XC_BillingProfileLineItem__c> mapOld, List<XC_BillingProfileLineItem__c> bpliToUpdate){

        Map<String, Map<Id, XC_BillingProfileLineItem__c>> legaEntityMap = new Map<String, Map<Id, XC_BillingProfileLineItem__c>>();
        
        Set<String> leSet = new Set<String>();
        Set<String> streamSet = new Set<String>();
        for(XC_BillingProfileLineItem__c bpli : mapNew.values()){
            if(!legaEntityMap.containsKey(bpli.XC_LegalEntity__c+bpli.XC_Segment__c)){
                Map<Id, XC_BillingProfileLineItem__c> bpliMap = new  Map<Id, XC_BillingProfileLineItem__c>();
                bpliMap.put(bpli.Id, bpli); 
                legaEntityMap.put(bpli.XC_LegalEntity__c+bpli.XC_Segment__c, bpliMap);
            }else{
                legaEntityMap.get(bpli.XC_LegalEntity__c+bpli.XC_Segment__c).put(bpli.Id, bpli);
            }
            leSet.add(bpli.XC_LegalEntity__c);
            streamSet.add(bpli.XC_Segment__c);
        }

        Map<Id,XC_CM_CountryLegalEntityAssociation__mdt> infos = new Map<Id,XC_CM_CountryLegalEntityAssociation__mdt>([SELECT Id, XC_Country__c, XC_Category__c , XC_LegalEntity__c
                                                                                                                       FROM XC_CM_CountryLegalEntityAssociation__mdt
                                                                                                                       WHERE XC_LegalEntity__c IN: leSet AND XC_Category__c IN: streamSet]);

        
        Map<String,String> leFieldSetName = new Map<String,String>{'EnelXItalia' => 'ZuoraContactExtraFields'};
        
        for(XC_CM_CountryLegalEntityAssociation__mdt cm : infos.values()) {
            String countryIso = Constants.COUNTRY_ISO_CODES.get(cm.XC_Country__c);
            String userLEStream = cm.XC_Category__c;
            String fieldSetKey = 'XC_' + countryIso + '_' + userLEStream +'_' + leFieldSetName.get(cm.XC_LegalEntity__c);
            List<XC_UTIL_FieldSet.FieldWrapper> fieldFromFieldSet = XC_UTIL_FieldSet.getFieldSetFields(fieldSetKey,'XC_BillingProfileLineItem__c');
            List<String> fieldList = new List<String>();
            for(XC_UTIL_FieldSet.FieldWrapper fieldWr: fieldFromFieldSet){
                fieldList.add(fieldWr.fieldName);
            }
            if(legaEntityMap.get(cm.XC_LegalEntity__c+cm.XC_Category__c) != null)
                bpliToUpdate.addAll((List<XC_BillingProfileLineItem__c>)XC_UTIL_Sobject.getListChanged(fieldList, mapOld, legaEntityMap.get(cm.XC_LegalEntity__c+cm.XC_Category__c)));
        }


        /*for(XC_BillingProfileLineItem__c bpli : mapNew.values()){
            if(!legaEntityMap.containsKey(bpli.XC_LegalEntity__c)){
                Map<Id, XC_BillingProfileLineItem__c> bpliMap = new  Map<Id, XC_BillingProfileLineItem__c>();
                bpliMap.put(bpli.Id, bpli); 
                legaEntityMap.put(bpli.XC_LegalEntity__c, bpliMap);
            }else{
                legaEntityMap.get(bpli.XC_LegalEntity__c).put(bpli.Id, bpli);
            }
        }

        Map<Id,XC_CM_CountryLegalEntityAssociation__mdt> infos = new Map<Id,XC_CM_CountryLegalEntityAssociation__mdt>([SELECT Id, XC_Country__c, XC_Category__c , XC_LegalEntity__c
                                                                                                                       FROM XC_CM_CountryLegalEntityAssociation__mdt
                                                                                                                       WHERE XC_LegalEntity__c IN: legaEntityMap.keySet()]);

        Map<String, XC_CM_CountryLegalEntityAssociation__mdt> mapLeInfos = new Map<String, XC_CM_CountryLegalEntityAssociation__mdt>();
        for(XC_CM_CountryLegalEntityAssociation__mdt info: infos.values()){
            mapLeInfos.put(info.XC_LegalEntity__c, info);
        }  

        for(String le : mapLeInfos.keySet()){
            String countryIso = Constants.COUNTRY_ISO_CODES.get(mapLeInfos.get(le).XC_Country__c);
            String userLEStream = mapLeInfos.get(le).XC_Category__c;
            String fieldSetKey = 'XC_' + countryIso + '_' + userLEStream +'_' + leFieldSetName.get(le);
            List<XC_UTIL_FieldSet.FieldWrapper> fieldFromFieldSet = XC_UTIL_FieldSet.getFieldSetFields(fieldSetKey,'XC_BillingProfileLineItem__c');
            List<String> fieldList = new List<String>();
            for(XC_UTIL_FieldSet.FieldWrapper fieldWr: fieldFromFieldSet){
                fieldList.add(fieldWr.fieldName);
            }
           
            bpliToUpdate.addAll((List<XC_BillingProfileLineItem__c>)XC_UTIL_Sobject.getListChanged(fieldList, mapOld, legaEntityMap.get(le)));
        }*/
    }


    /**
     * updateInvoiceDeliveryPrefOnBp.
     * 
     * @author Luisana Rocco lrocco@deloitte.it
     * @param mapNew the mapNew
     * @param mapOld the mapOld
     * @description update invoice delivery pref of bpli on BP when the bpli is Active 
     */
    public static void updateInvoiceDeliveryPrefOnBp(Map<Id, XC_BillingProfileLineItem__c> mapOld, Map<Id, XC_BillingProfileLineItem__c> mapNew){

        List<String> fieldList = new List<String>{'XC_Status__c'};
        List<XC_BillingProfileLineItem__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        Map<XC_BillingProfileLineItem__c, Id> bpliBpMap = new Map<XC_BillingProfileLineItem__c, Id> ();
        for(XC_BillingProfileLineItem__c bpli : listChanged) {
            if(bpli.XC_Status__c == 'Active' && !String.isBlank(bpli.XC_InvoiceDeliveryPreference__c) && !String.isBlank(bpli.XC_BillingProfile__c)){
                bpliBpMap.put(bpli, bpli.XC_BillingProfile__c);
            }
		}

        if(!bpliBpMap.isEmpty()){
            manageInvoiceDeliveryPrefOnBp(bpliBpMap);
        }
    }

    
    /**
     * manageInvoiceDeliveryPrefOnBp.
     * 
     * @author Luisana Rocco lrocco@deloitte.it
     * @param bpliBpMap the bpliBpMap
     * @description manage the invoice delivery pref of bpli on BP
     */
    public static void manageInvoiceDeliveryPrefOnBp(Map<XC_BillingProfileLineItem__c, Id> bpliBpMap){

        Map<Id, NE__Billing_Profile__c> bpMap = new Map<Id, NE__Billing_Profile__c>([SELECT XC_InvoiceDeliveryPref__c FROM NE__Billing_Profile__c WHERE Id IN: bpliBpMap.values()]);

        Set<NE__Billing_Profile__c> bpToUpdate = new Set<NE__Billing_Profile__c>();
        for(XC_BillingProfileLineItem__c bpli : bpliBpMap.keySet()){
            if(bpMap.get(bpli.XC_BillingProfile__c) != null){
                if(bpli.XC_InvoiceDeliveryPreference__c == Label.XC_CL_BpliInvoiceDeliveryPref && bpMap.get(bpli.XC_BillingProfile__c).XC_InvoiceDeliveryPref__c == 'SmartInvoice'){
                    continue;
                }
                if(bpli.XC_InvoiceDeliveryPreference__c != bpMap.get(bpli.XC_BillingProfile__c).XC_InvoiceDeliveryPref__c){
                    bpMap.get(bpli.XC_BillingProfile__c).XC_InvoiceDeliveryPref__c = (bpli.XC_InvoiceDeliveryPreference__c == Label.XC_CL_BpliInvoiceDeliveryPref) ? 'SmartInvoice' : bpli.XC_InvoiceDeliveryPreference__c;
                    bpToUpdate.add(bpMap.get(bpli.XC_BillingProfile__c));
                }
            }
        }

        if(!bpToUpdate.isEmpty()){
            List<NE__Billing_Profile__c> bpList = new List<NE__Billing_Profile__c>();
            bpList.addAll(bpToUpdate);
            XC_UTIL_Sobject.updateListRecords(bpList);
        }
    }
}