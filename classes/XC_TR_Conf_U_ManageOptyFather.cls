/**
 * @author Federico Amici - federico.amici@nttdata.com
 * @date 07/06/2019
 * @description XC_TR_Configuration_U_ManageOptySubStatus - Manages the update of the XC_Substatus__c and XC_QuotePresent__c fields on father opportunity
 */
public with sharing class XC_TR_Conf_U_ManageOptyFather {
    
    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @date 07/06/2019
     * @param listConfiguration list of the configuration to be inserted
     * @param mapOld map of old order versions
     * @param mapNew map of new order versions
     * @description updateFatherOpty - Manages the update of the XC_Substatus__c field on father opportunity
     */
    public static void updateFatherOpty(List<NE__Order__c> listConfiguration, Map<Id, NE__Order__c> mapOld, Map<Id, NE__Order__c> mapNew) {

        List<NE__Order__c> listQuotesFiltered = getQuotesFromListConfiguration(mapNew);
        if(listQuotesFiltered.isEmpty()) {
            return;
        }

        System.debug('after return  ' + listQuotesFiltered);

        List<Id> listOpportunityIds = XC_UTIL_SObject.getListFieldValues(listQuotesFiltered, 'NE__OptyId__c');
        if(listOpportunityIds.isEmpty()){       //FIX SS-DDP 19/11/2019
            return;
        }
        List<Opportunity> listOpportunity = XC_TR_Conf_U_ManageOptyFather_D.retrieveOpportunities(listOpportunityIds);
        Map<String, String> mapOptyIdToQuote = getMapOptyIdToQuote(listQuotesFiltered);

        String quoteTMPId;
        NE__Order__c quoteTMP;

        for(Opportunity o : listOpportunity) {
            o.XC_Substatus__c = Label.XC_CL_Opportunity_PendingQuoteAcceptation;
            o.XC_QuotePresent__c = true;
            quoteTMPId = mapOptyIdToQuote.get(o.Id);
            quoteTMP = mapNew.get(quoteTMPId);
            if(quoteTMP.XC_Status__c == Label.XC_CL_Configuration_QuoteAccepted) {
                o.XC_Substatus__c = Label.XC_CL_Opportunity_OrderInProgress;   
            }
        }

        XC_UTIL_Sobject.updateListRecords(listOpportunity);
    }

    private static List<NE__Order__c> getQuotesFromListConfiguration(Map<Id, NE__Order__c> mapNew) {

        List<NE__Order__c> listQuotes = new List<NE__Order__c>();
        Id quoteRT = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();

        for(NE__Order__c conf : mapNew.values()) {
            System.debug('conf.RT ' + conf.recordTypeId);
            if(quoteRT == conf.RecordTypeId) {
                listQuotes.add(conf);
                System.debug('conf.RT IN ' + conf.recordTypeId + ' ' + quoteRT);
            }
        }

        return listQuotes;
    }

    private static Map<String, String> getMapOptyIdToQuote(List<NE__Order__c> listQuotes) {

        Map<String, String> mapOptyIdToQuote = new Map<String, String>();

        for(NE__Order__c quote : listQuotes) {
            mapOptyIdToQuote.put(quote.NE__OptyId__c, quote.Id);
        }

        return mapOptyIdToQuote;
    }

}