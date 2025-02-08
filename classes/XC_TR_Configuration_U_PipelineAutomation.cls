/**
 *
 * @author :              Andrea Di Cicco
 * @date Creation :       16/01/2019
 * @date Modification :   dd/mm/yyyy
 * @description :         class to manage the opportunity stage starting from opportunity status
 * 
 */
public with sharing class XC_TR_Configuration_U_PipelineAutomation {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Configuration_U_PipelineAutomation');
    /** 
    * @description manage the Stage changing
    * @param listNew the list new
    * @param mapOld the map old
    * @param mapNew the map new
    */
    public static void manageStage(List<NE__Order__c> listNew, Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew){

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In XC_TR_Configuration_U_PipelineAutomation.manageStage');
        Set<String> listAllLE = new Set<String>();
        listAllLE.addAll(XC_UTIL_Sobject.getListFieldValues (listNew,'XC_LegalEntity__c'));
        Set<String> segmFilter = new Set<String>();
        segmFilter.addAll(XC_UTIL_Sobject.getListFieldValues (listNew,'XC_Segment__c'));
        Map<String,XC_CM_LegalEntity_Configuration__mdt> isActiveComplexProduct =XC_Util_LegalEntityOneOrg.getOrgConfigLegalEntities( listAllLE, segmFilter);
        List<String> opportunityId = new List<String>();
        List<NE__Order__c> ordersWithPipeline = new List<NE__Order__c>();
        for(NE__Order__c order : listNew){
            if(order.XC_Segment__c != 'B2C' && ((order.XC_LegalEntity__c != 'EnelXMobilityChile' && order.XC_LegalEntity__c != 'EnelX' && order.XC_LegalEntity__c != 'Codensa' && order.XC_LegalEntity__c != 'EnelDistribucion') || isActiveComplexProduct.get(order.XC_LegalEntity__c + order.XC_Segment__c).XC_ComplexProductActive__c)){
                ordersWithPipeline.add(order);
            }
        }

        if(ordersWithPipeline.isEmpty()){
            return;
        }
        opportunityId = XC_UTIL_Sobject.getListFieldValues(ordersWithPipeline, 'NE__OptyId__c');

        if(opportunityId.isEmpty() || !Schema.sObjectType.Opportunity.isAccessible()){
            return;
        }
        Map<Id, Opportunity> parentOpportunityMap = 
                            new Map<Id, Opportunity>([SELECT 
                                                    StageName, XC_PipelineStatus__c, XC_PreparedProposalDate__c,  XC_PresentedProposalDate__c, XC_AcceptedProposalDate__c, XC_SignedContractDate__c
                                                    FROM Opportunity 
                                                    WHERE Id IN: opportunityId]);
        if(!parentOpportunityMap.isEmpty()){
            updateOpportunity( listNew,  mapOld, parentOpportunityMap);
        }
    }


    private static void updateOpportunity(List<NE__Order__c> listNew, Map<Id,NE__Order__c> mapOld, Map<Id, Opportunity> parentOpportunityMap){
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        for(NE__Order__c order : listNew){
            Opportunity opp = new Opportunity();
            if(order.NE__OptyId__c == null){
                continue;
            }
            opp = parentOpportunityMap.get(order.NE__OptyId__c);
            if(order.XC_Status__c == 'Notified to client' && mapOld.get(order.id).XC_Status__c != 'Notified to client'){
                opp.StageName = 'Prepared Proposal';
                opp.XC_PipelineStatus__c = 'Prepared proposal';
                opp.XC_PreparedProposalDate__c = System.today();
                opp.XC_SubStatus_GB__c = null;
            }else if(order.XC_Status__c == 'Accepted' && mapOld.get(order.id).XC_Status__c != 'Accepted'){
                opp.StageName = 'Accepted proposal';
                opp.XC_PipelineStatus__c = 'Accepted proposal';
                opp.XC_AcceptedProposalDate__c = System.today();
                opp.XC_SubStatus_GB__c = null;
            }else if(order.XC_Status__c == 'In Provisioning' && mapOld.get(order.id).XC_Status__c != 'In Provisioning'){
                opp.StageName = 'Closed Won';
                opp.XC_SubStatus_GB__c = null;
            }
            oppToUpdate.add(opp);
        }
        XC_UTIL_DML.updateRecords(oppToUpdate);
    }
}