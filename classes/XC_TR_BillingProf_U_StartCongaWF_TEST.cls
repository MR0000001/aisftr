/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation  27/07/2019 
* @description XC_TR_BillingProf_U_StartCongaWF_TEST – Test class on XC_TR_BillingProfile_U_StartCongaWF
*/ 
@isTest
public class XC_TR_BillingProf_U_StartCongaWF_TEST {
    @TestSetup
    static void setup(){ 
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        
        APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Mandato_SEPA', Country__c = 'Spain');
        insert template;
        APXTConga4__Conga_Template__c template2 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'QueryOnBillingPLI', Country__c = 'Spain');
        insert template2;
      
        APXTConga4__Conga_Merge_Query__c congaQuery1 = new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'QueryOnBillingProfil');
        insert congaQuery1;
      
        APXTConga4__Conga_Merge_Query__c congaQuery2 = new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'QueryOnBillingPLI');
        insert congaQuery2;

        List<WorkOrder> workOrder = XC_DF_WorkOrder.createWorkOrders (1, 'Planned Maintenance');

        List<NE__Billing_Profile__c> bpliList = XC_DF_BillingProfile.createBillingProfile(1);
        NE__Billing_Profile__c billingProf=  bpliList[0];
        billingProf.NE__Payment__c = Label.XC_CL_DirectDebt;
        billingProf.XC_SepaMandate__c = 'A1234';
        billingProf.NE__Iban__c = 'A1481481';
        billingProf.XC_BIC__c = 'ABC123';
        billingProf.XC_CreateMandate__c = true;
        update billingProf;
    }
    
  	static testMethod void updateBillingProfile() {
		Test.startTest();
        List<NE__Billing_Profile__c> billingProfList = new List<NE__Billing_Profile__c>([SELECT id,XC_CreateMandate__c FROM NE__Billing_Profile__c LIMIT 1]);
        NE__Billing_Profile__c billingProf = billingProfList[0];
        billingProf.XC_CreateMandate__c = true;        
        update billingProf;
		delete billingProf;
       	System.assertEquals(1, billingProfList.size());
		Test.stopTest();
    }
    
 	static testMethod void deleteBillingProfile() {
		Test.startTest();
        List<NE__Billing_Profile__c> billingProfList = new List<NE__Billing_Profile__c>([SELECT id,XC_CreateMandate__c FROM NE__Billing_Profile__c LIMIT 1]);
        NE__Billing_Profile__c billingProf = billingProfList[0];
		delete billingProf;
       	System.assertEquals(1, billingProfList.size());
		Test.stopTest();
    }
}