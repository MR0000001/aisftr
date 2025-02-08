@istest
public class XC_TR_Case_CreditMemoAssign_test {
    static testMethod void afterInsertManageContract(){
        test.startTest();
         List<Opportunity> opp = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        opp[0].XC_DealRegistrationStatus__c='Approval Needed';
        insert opp;
        Zuora__ZInvoice__c zuo =new Zuora__ZInvoice__c();
        zuo.Zuora__AmountWithoutTax__c=1;
        insert zuo;
        List<Case> casePartner = XC_DF_Case.createCases(1);
        casePartner[0].XC_Subtype__c = 'XC266';
        casePartner[0].XC_Opportunity__c= opp[0].id;
        casePartner[0].XC_Invoice__c=zuo.id;
        casePartner[0].XC_CreditMemo__c=zuo.Zuora__AmountWithoutTax__c;
        insert casePartner;
        test.stopTest();
        
    }
}