@Istest
public class XC_TR_Case_UpdateDealStatus_TEST {
    static testmethod void updateDealStatus(){
        test.startTest();
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        opp[0].XC_DealRegistrationStatus__c='Approval Needed';
        insert opp;
        List<Case> casePartner = XC_DF_Case.createCases(1);
        casePartner[0].XC_Subtype__c = 'XC193';
        casePartner[0].XC_Resolution__c='R135';
        casePartner[0].XC_Opportunity__c= opp[0].id;
        
        XC_TR_Case_UpdateDealStatus.updateDealStatus(casePartner);
        test.stopTest();
        
    }
     static testmethod void updateDealStatus1(){
        test.startTest();
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        opp[0].XC_DealRegistrationStatus__c='Not Approved';
        insert opp;
        List<Case> casePartner = XC_DF_Case.createCases(1);
        casePartner[0].XC_Subtype__c = 'XC193';
        casePartner[0].XC_Resolution__c='R136';
        casePartner[0].XC_Opportunity__c= opp[0].id;
        
        XC_TR_Case_UpdateDealStatus.updateDealStatus(casePartner);
        test.stopTest();
        
    }
}