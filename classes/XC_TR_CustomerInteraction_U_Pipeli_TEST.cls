@isTest
public class XC_TR_CustomerInteraction_U_Pipeli_TEST {
    static testMethod void manageStage(){
        test.startTest();
         List<Contract> contractList = XC_DF_Contract.createContracts(2);
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1,'Active');
         List<Opportunity> oppList = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        for(Opportunity opp : oppList){
            opp.StageName = 'Presented Proposal';
            opp.XC_PipelineStatus__c = 'Presented Proposal';
            opp.XC_PresentedProposalDate__c = System.today();
            opp.XC_Segment__c ='B2B';
            opp.AccountId = accList.get(0).id;
            opp.StageName = 'Draft'; 
            opp.Name = 'TEST'; 
            opp.CloseDate =System.today(); 
        }
        insert oppList;
        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
        ci.XC_Communication_Type__c = 'Quote_Doc';
        ci.XC_OpportunityId__c= oppList[0].id;
        insert ci;
        Map<Id,XC_Customer_Interaction__c > mapNew = new Map<Id,XC_Customer_Interaction__c>();
        mapNew.put(ci.id,ci);
        XC_TR_CustomerInteraction_U_Pipeline.manageStage(mapNew);
        test.stopTest();
    }
}