/**
 * @author Federico Amici - federico.amici@nttdata.com
 * @date 07/06/2019
 * @description XC_TR_Opportunity_U_ManageSubStatus - Manages the update of the XC_Substatus__c field on opportunity
 */
public with sharing class XC_TR_Opportunity_U_ManageSubStatus {
    
    /** 
    * @author Federico Amici - federico.amici@nttdata.com
    * @date 07/06/2019
    * @param listNew the list of opportunity to insert
    * @description updates the substatus field if condition matches
    */
    public static void updateSubstatusPicklist(List<Opportunity> listNew) {

        for(Opportunity o : listNew) {
            if(o.XC_CommercialVisitRequired__c && !o.XC_CommercialVisitStarted__c ) {
                o.XC_Substatus__c = Label.XC_CL_Opportunity_CommVisitToBeSched;
            } else {
                o.XC_Substatus__c = Label.XC_CL_Opportunity_QuoteOrderTBC;
            }
        }

    }

    /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @date 07/06/2019
    * @param listNew the list of opportunity to insert
    * @param mapOld the map of old opportunity versions to update
    * @param mapNew the map of new opportunity versions to update
    * @description updates the substatus field if condition matches
    */
    public static void updateSubstatusPicklist(List<Opportunity> listNew, Map<Id,Opportunity> mapOld, Map<Id,Opportunity> mapNew) {

        listNew = getOpportunityFiltered(mapOld, mapNew);
        if(listNew.isEmpty()) {
            return;
        }

        List<Id> listOpportunityIds = XC_UTIL_Sobject.getIds(listNew);
        List<Opportunity> listOpportunity = XC_TR_Opportunity_U_ManageSubStatus_D.getOpportunityAndRelatedQuotes(listOpportunityIds);
        Map<Id, List<NE__Order__c>> mapOpportunityToQuotes = getMapOpportunityToQuotes(listOpportunity);

        List<NE__Order__c> quoteList;
        Boolean wasAssignedServiceResource;
        Boolean commercialVisitStarted;
        Boolean commercialVisitRequired;
        Boolean closedWon;
        Boolean closedLost;

        for(Opportunity o : listNew) {
            quoteList = mapOpportunityToQuotes.get(o.Id);
            wasAssignedServiceResource = String.isNotBlank(o.XC_CommercialVisitAssignedResource__c);
            commercialVisitStarted = o.XC_CommercialVisitStarted__c;
            commercialVisitRequired = o.XC_CommercialVisitRequired__c;
            closedWon = o.StageName == Label.XC_CL_Opportunity_ClosedWon;
            closedLost = o.StageName == Label.XC_CL_Opportunity_ClosedLost;

            if(closedLost || closedWon) {
                 o.XC_Substatus__c = '';
            } else if (setPendingCommVisit(commercialVisitStarted, commercialVisitRequired, wasAssignedServiceResource)) {
                o.XC_Substatus__c = Label.XC_CL_Opportunity_PendingCommVisit;
            } /* else if(quoteList.isEmpty() && !wasAssignedServiceResource) {
                o.XC_Substatus__c = Label.XC_CL_Opportunity_QuoteOrderTBC;
            }*/
        }

    }

    private static Map<Id, List<NE__Order__c>> getMapOpportunityToQuotes(List<Opportunity> listOpportunity) {

        Map<Id, List<NE__Order__c>> mapOpportunityToQuotes = new Map<Id, List<NE__Order__c>>();

        for(Opportunity o : listOpportunity) {
            mapOpportunityToQuotes.put(o.Id, o.NE__Orders__r);
        }

        return mapOpportunityToQuotes;
    }
    
    private static Boolean setPendingCommVisit(Boolean commercialVisitStarted, Boolean commercialVisitRequired, Boolean wasAssignedServiceResource) {
        return !commercialVisitStarted && commercialVisitRequired && wasAssignedServiceResource;
    }

    private static List<Opportunity> getOpportunityFiltered(Map<Id, Opportunity> mapOld, Map<Id, Opportunity> mapNew) {
        List<Opportunity> listOpportunity = new List<Opportunity>();
        Opportunity oldO;
        Opportunity newO;

        for(Opportunity o : mapOld.values()) {
            oldO = mapOld.get(o.Id);    
            newO = mapNew.get(o.Id);    

            if(oldO.Name == newO.Name) {
                listOpportunity.add(newO);
            }
        }

        listOpportunity = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_CommercialVisitStarted__c', 'XC_CommercialVisitRequired__c',
                                                                           'XC_CommercialVisitAssignedResource__c', 'StageName'},
                                                                           mapOld, mapNew);
        return listOpportunity;
    }

}