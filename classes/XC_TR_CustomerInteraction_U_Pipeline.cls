/**
 *
 * @author :              Andrea Di Cicco
 * @date Creation :       16/01/2019
 * @date Modification :   dd/mm/yyyy
 * @description :         class to manage the opportunity stage starting from Customer Interaction
 * 
 */
public without sharing class XC_TR_CustomerInteraction_U_Pipeline {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Configuration_U_PipelineAutomation');
    /** 
    * @description when the contract is signed the opportunity is updated
    * @param mapNew the map new
    */
    public static void manageStage(Map<Id,XC_Customer_Interaction__c > mapNew){
        List<String> parentOppId = new List<String>();
        for(XC_Customer_Interaction__c  ci : mapNew.values()){
            if(ci.XC_Communication_Type__c == 'Quote_Doc' && ci.XC_OpportunityId__c  != null){
                parentOppId.add(ci.XC_OpportunityId__c);
            }
        }
        if(parentOppId.isEmpty()|| !Schema.sObjectType.Opportunity.isAccessible()){
            return;
        }
        List<Opportunity> parentOpportunity = 
                            new List<Opportunity>([SELECT 
                                    StageName, XC_PipelineStatus__c, XC_PresentedProposalDate__c
                                FROM Opportunity 
                                WHERE XC_Segment__c != 'B2C' 
                                AND Id IN: parentOppId]);
        if(parentOpportunity != null && !parentOpportunity.isEmpty()){
            updateOpportunity( parentOpportunity);
        }
    }

    private static void updateOpportunity(List<Opportunity> parentOpportunity){
        for(Opportunity opp : parentOpportunity){
            opp.StageName = 'Presented Proposal';
            opp.XC_PipelineStatus__c = 'Presented Proposal';
            opp.XC_PresentedProposalDate__c = System.today();
        }
        XC_UTIL_DML.updateRecords(parentOpportunity);
    }
}