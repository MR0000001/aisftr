@isTest
public class XC_TR_Case_PopulateBPLI_TEST {
    @isTest 
    static void test() {
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
               
        NE__Billing_Profile__c bp = new NE__Billing_Profile__c(NE__Account__c = accountList[0].id);
        insert bp;
        XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(XC_BillingProfile__c = bp.Id);
        insert bpli;
        
        Zuora__CustomerAccount__c zCA = new Zuora__CustomerAccount__c();
        zCA.Zuora__Account__c = accountList[0].id;
        zCa.Zuora__External_Id__c = '123456';
        zCa.Zuora__Zuora_Id__c = '123456';
        zCa.XC_BillingProfLineItem_LookUp__c = bpli.Id;
        insert zCA;
        
        Zuora__ZInvoice__c zuoraZInvoice = new Zuora__ZInvoice__c();
        zuoraZInvoice.Zuora__Balance2__c = 3;
        zuoraZInvoice.Zuora__BillingAccount__c = zCA.Id;
        insert zuoraZInvoice;
        
        Case complCase = new Case();
        complCase.Reason = Label.XC_CL_CaseReason_ComplaintValue;
        complCase.SubCause__c = 'ATCL030';
        complCase.AccountId = accountList[0].Id;
        complCase.XC_Invoice__c = zuoraZInvoice.Id;
        
        //insert complCase;
        
        XC_TR_Case_PopulateBPLI.setBillingProfileLineItem(new List<Case>{complCase});
    } 
}