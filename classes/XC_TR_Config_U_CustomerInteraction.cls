/**
 * The Class XC_TR_Config_U_CustomerInteraction.
 *
 * @author            : Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 01/07/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Class to manage Customer Interaction for Configuration
 **/ 


public without sharing class XC_TR_Config_U_CustomerInteraction {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Config_U_CustomerInteraction');

    /**
     * CreateCustomerInteractionForAcceptedQuote.
     * 
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     * @description Create Customer Interfaction for Quote when the status is Accepted
     */
    public static void createCustomerInteractionForAcceptedQuote(List<NE__Order__c> listNew, Map<Id, NE__Order__c> mapOld, Map<Id, NE__Order__c> mapNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_Configuration_U_CustomerInteraction.createCustomerInteractionForAcceptedQuote');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#listNew -> ' + listNew);
        List<String> fieldList = new List<String>{'XC_Status__c'}; 
        List<NE__Order__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        List<NE__Order__c> quoteList = new List<NE__Order__c>();
        for(NE__Order__c conf : listChanged) {
            if(conf.RecordTypeId == Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId() && conf.XC_Status__c == Label.XC_CL_Configuration_QuoteAccepted) {
                quoteList.add(conf);    
            }
        }
        if(!quoteList.isEmpty()) {
            createCustomerInteraction(quoteList);
        }
    }
    
    
    /**
     * CreateCustomerInteraction.
     * 
     * @param quoteList the list of quote with status 'Accepted'
     * @description Create Customer Interaction
     */
    private static void createCustomerInteraction(List<NE__Order__c> quoteList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_Configuration_U_CustomerInteraction.createCustomerInteraction');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#quoteList -> ' + quoteList);

        List<Id> quoteIdList = XC_UTIL_Sobject.getIds(quoteList);
        Map<Id, NE__Order__c> quoteMap = new Map<Id, NE__Order__c>([SELECT Id, NE__OptyId__c, NE__OptyId__r.XC_Contact__c, NE__OptyId__r.XC_Contact__r.Name, NE__OptyId__r.XC_Contact__r.Email,
                                                                    NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c, NE__AccountId__c,
                                                                    (SELECT Id, XC_Doxee_URL__c, XC_Doxee_ID_external__c FROM Documents_to_sign1__r WHERE XC_Signed__c = true)
                                                                    FROM NE__Order__c WHERE Id IN: quoteIdList]);
       	

        List<Map<String,Object>> interactions = new List<Map<String,Object>>();
        for(NE__Order__c quote : quoteMap.values()) {
            if(!quote.Documents_to_sign1__r.isEmpty()) {

                String doxeeURL = quote.Documents_to_sign1__r[0].XC_Doxee_URL__c;
                String doxeeId = quote.Documents_to_sign1__r[0].XC_Doxee_ID_external__c;
                for(Integer i = 1; i < quote.Documents_to_sign1__r.size(); i++) {
                    doxeeURL += ';' + quote.Documents_to_sign1__r[i].XC_Doxee_URL__c;
                    doxeeId += ';' + quote.Documents_to_sign1__r[i].XC_Doxee_ID_external__c;
                }

                Map<String, Object> customerMap = new Map<String, Object>{'contactId' => quote.NE__OptyId__r.XC_Contact__c,
                                                                            'fullName' => quote.NE__OptyId__r.XC_Contact__r.Name,
                                                                            'email' => quote.NE__OptyId__r.XC_Contact__r.Email,
                                                                            'preferredlanguage' => quote.NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c,
                                                                            'orderId' => quote.Id,
                                                                            'opportunityId' => quote.NE__OptyId__c,
                                                                            'accountId' => quote.NE__AccountId__c,
                                                                            'customerType' => 'Send_Documents',
                                                                            'docURL' => doxeeURL,
                                                                            'docID' => doxeeId
                                                                            };

                interactions.add(customerMap);
            }
        }

        if(!interactions.isEmpty()) {
            List<XC_UTIL_Sobject.WrapperResult> result = XC_UTIL_CustomerInteractionGeneration.manageCustomerInteractionInsert(interactions);
            for(XC_UTIL_Sobject.WrapperResult res : result) {
                if(!res.success) {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '#errorOnInsertCustomerInteraction -> ' + res.errorMessage);
                }
            }
        }
    }

}