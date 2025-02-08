/**
 *
 * @author :              Andrea Di Cicco
 * @date Creation :       16/01/2019
 * @date Modification :   dd/mm/yyyy
 * @description :         class to manage the opportunity stage starting from Contract
 * 
 */
public without sharing class XC_TR_Contract_U_PipelineAutomation {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Configuration_U_PipelineAutomation');
    /** 
    * @description when the contract is signed the opportunity is updated
    * @param mapOld the map old
    * @param mapNew the map new
    */
    public static void manageStage(Map<Id,Contract> mapOld, Map<Id,Contract> mapNew){

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In XC_TR_Configuration_U_PipelineAutomation.manageStage');
        
        List<String> opportunityId = new List<String>();
        List<Contract> contractsWithPipeline = new List<Contract>();
        Set<String> listAllLE = new Set<String>();
        listAllLE.addAll(XC_UTIL_Sobject.getListFieldValues (mapNew.values(),'XC_LegalEntity__c'));
        Set<String> segmFilter = new Set<String>();
        segmFilter.addAll(XC_UTIL_Sobject.getListFieldValues (mapNew.values(),'XC_Segment__c'));
        Map<String,XC_CM_LegalEntity_Configuration__mdt> isActiveComplexProduct =XC_Util_LegalEntityOneOrg.getOrgConfigLegalEntities( listAllLE, segmFilter);
        Id partnerRT = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_ContractPartner').getRecordTypeId();
        for(Contract contract : mapNew.values()){
            if(contract.RecordTypeId != partnerRT && contract.XC_Segment__c != 'B2C'&& ((contract.XC_LegalEntity__c != 'EnelX' && contract.XC_LegalEntity__c != 'EnelXMobilityChile' && contract.XC_LegalEntity__c != 'Codensa' && contract.XC_LegalEntity__c != 'EnelDistribucion')|| (contract.RecordTypeId != partnerRT && isActiveComplexProduct.get(contract.XC_LegalEntity__c + contract.XC_Segment__c) != null && isActiveComplexProduct.get(contract.XC_LegalEntity__c + contract.XC_Segment__c).XC_ComplexProductActive__c))){
                contractsWithPipeline.add(contract);
            }
        }

        if(contractsWithPipeline.isEmpty()){
            return;
        }
        opportunityId = XC_UTIL_Sobject.getListFieldValues(mapNew.values(), 'Opportunity__c');

        if(opportunityId.isEmpty() || !Schema.sObjectType.Opportunity.isAccessible()){
            return;
        }
        Map<Id, Opportunity> parentOpportunityMap = 
                            new Map<Id, Opportunity>([SELECT 
                                                    StageName, XC_PipelineStatus__c, XC_SignedContractDate__c,XC_ExpectedCODdate__c,
                                          XC_PresentedProposalDate__c,XC_AcceptedProposalDate__c,XC_PreparedProposalDate__c,XC_Penalty__c
                                                    FROM Opportunity 
                                                    WHERE Id IN: opportunityId]);
        if(!parentOpportunityMap.isEmpty()){
            updateOpportunity( mapNew.values(),  mapOld, parentOpportunityMap);
        }
    }


    private static void updateOpportunity(List<Contract> listNew, Map<Id,Contract> mapOld, Map<Id, Opportunity> parentOpportunityMap){
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        for(Contract contract : listNew){
            Opportunity opp = new Opportunity();
            if(contract.Opportunity__c == null){
                continue;
            }
            opp = parentOpportunityMap.get(contract.Opportunity__c);
            if(contract.XC_Signed__c && !mapOld.get(contract.id).XC_Signed__c  ){
                opp.StageName = 'Signed Contract';
                opp.XC_PipelineStatus__c = 'Signed Contract';
                opp.XC_SignedContractDate__c = System.today();
                opp.XC_SubStatus_GB__c = null;
                opp.XC_ExecutionOwner__c = UserInfo.getUserId();
                
                
                if(opp.XC_ExpectedCODdate__c==null){
                opp.XC_ExpectedCODdate__c = System.today();
                }
                if(opp.XC_PresentedProposalDate__c== null){
                opp.XC_PresentedProposalDate__c = System.today();
                }
                if(opp.XC_AcceptedProposalDate__c== null){
                opp.XC_AcceptedProposalDate__c  = System.today();
                }
                if(opp.XC_PreparedProposalDate__c== null){
                opp.XC_PreparedProposalDate__c  = System.today();
                }
                  if(opp.XC_Penalty__c== null){
                opp.XC_Penalty__c =  'No';
                  }
               
                oppToUpdate.add(opp);
            }

        }
        if(!oppToUpdate.isEmpty()){
            XC_UTIL_DML.updateRecords(oppToUpdate);
        }
    }
}