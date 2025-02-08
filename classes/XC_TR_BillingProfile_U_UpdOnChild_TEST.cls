@isTest
public class XC_TR_BillingProfile_U_UpdOnChild_TEST {
	
    @isTest
    public static void manageStatusUpdate_StatusActive(){
        Test.startTest();
            List<NE__Billing_Profile__c> bp = XC_DF_BillingProfile.createBillingProfile(1);
            bp[0].XC_Status__c = 'Waiting External Activation';
            update bp;
            
            XC_BillingProfileLineItem__c bpli = [SELECT Id FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__c =: bp[0].Id ];
            bpli.XC_Status__c = 'Waiting External Activation';
            update bpli;
        
        	bp[0].XC_Status__c = 'Active';
        	update bp;
        	
        	XC_BillingProfileLineItem__c bpliUpdated = [SELECT Id, XC_Status__c FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__c =: bp[0].Id ];
        	System.assert(bpliUpdated.XC_Status__c == 'Active'); 
        
        Test.stopTest();
    }
    
    @isTest
    public static void manageStatusUpdate_StatusRefused(){
        List<NE__Billing_Profile__c> bp = XC_DF_BillingProfile.createBillingProfile(1);
        bp[0].XC_Status__c = 'Waiting External Activation';
        update bp;
        
        XC_BillingProfileLineItem__c bpli = [SELECT Id FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__c =: bp[0].Id ];
        bpli.XC_Status__c = 'Waiting External Activation';
        update bpli;
        
        Test.startTest();
        	bp[0].XC_Status__c = 'Refused';
        	update bp;
        	
        	XC_BillingProfileLineItem__c bpliUpdated = [SELECT Id, XC_Status__c FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__c =: bp[0].Id ];
        	System.assert(bpliUpdated.XC_Status__c == 'Refused'); 
        
        Test.stopTest();
    }    
}