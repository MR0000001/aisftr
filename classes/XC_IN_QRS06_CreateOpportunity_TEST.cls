/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 11-04-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   11-04-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
@isTest
public  class XC_IN_QRS06_CreateOpportunity_TEST {

    @TestSetup
    static void setup(){

        List<XC_QueuedRequest__c> qrList = XC_DF_QueuedRequest.createQueuedRequestAccountOpportunity(1);
        insert qrList;


        List<NE__Billing_Profile__c> bp = XC_DF_BillingProfile.createBillingProfile(1);

        XC_BillingProfileLineItem__c bpli = [SELECT Id, XC_BillingProfile__c, XC_BillingProfile__r.NE__Account__c, XC_SoldToAddress__c FROM XC_BillingProfileLineItem__c  WHERE XC_BillingProfile__c =: bp[0].Id][0];
        bpli.XC_LegalEntity__c = 'EnelXItalia';
        bpli.XC_DocumentType__c = 'Codice Fiscale';
        bpli.XC_DocumentNumber__c = 'BRMMRA72p95I438H';
        bpli.XC_DocumentCountry__c = 'Italy';
        update bpli; 

        XC_Address__c addr = new XC_Address__c(Id = bpli.XC_SoldToAddress__c, XC_AddressCountry__c = 'Italy', XC_Region__c = 'Basilicata');
        update addr;
       

        List<Account> accList = new List<Account>{new Account(Id = bpli.XC_BillingProfile__r.NE__Account__c)};
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accList);
        conList[0].XC_PrimaryContact__c = true;
        insert conList;

        List<Account> acc = [SELECT Id, (SELECT Id, XC_BillingProfile__c  FROM XC_BillingProfileLineItems__r), (SELECT Id  FROM Addresses__r) FROM Account LIMIT 1];

        XC_REST_Account_W.WrapperResponse responseWrPreviousStepAddress = new XC_REST_Account_W.WrapperResponse();
        responseWrPreviousStepAddress.Account = new XC_UTIL_Account.AccountIFWrapper();
        responseWrPreviousStepAddress.Account.AccountID = acc[0].Id;
        responseWrPreviousStepAddress.Address = new List<XC_UTIL_Address.AddressWrapper>();
        XC_UTIL_Address.AddressWrapper addressWr = new XC_UTIL_Address.AddressWrapper();
        addressWr.AddressID = acc[0].Addresses__r[0].Id;
        responseWrPreviousStepAddress.Address.add(addressWr); 


        
        List<XC_QueuedRequestStep__c> qsList = [SELECT XC_StepSequence__c, XC_ExecutionResponse__c,XC_StepLabel__c  FROM XC_QueuedRequestStep__c];

        for(XC_QueuedRequestStep__c qs : qsList){
            if(qs.XC_StepLabel__c == 'Create Account'){
                qs.XC_ExecutionResponse__c = JSON.serialize(responseWrPreviousStepAddress);  
            }
            else  if(qs.XC_StepLabel__c == 'Create Address'){
                qs.XC_ExecutionResponse__c = JSON.serialize(responseWrPreviousStepAddress);
            }
        }
        update qsList;


    }

    @isTest
    static void testOpportunityCreation(){

        XC_QueuedRequestStep__c qrs = [SELECT ID FROM XC_QueuedRequestStep__c WHERE XC_StepLabel__c = 'Create Opportunity' LIMIT 1];
        XC_IN_QRS06_CreateOpportunity.InputWrapper iw = new XC_IN_QRS06_CreateOpportunity.InputWrapper();
        iw.stepId = qrs.Id;
        
        Test.startTest();
            XC_IN_QRS06_CreateOpportunity.manageOpportunityCreation(new List<XC_IN_QRS06_CreateOpportunity.InputWrapper>{iw});
        Test.stopTest();

    }

    @isTest
    static void testOpportunityCreationQueueable(){
        XC_QueuedRequestStep__c qrs = [SELECT ID FROM XC_QueuedRequestStep__c WHERE XC_StepLabel__c = 'Create Opportunity' LIMIT 1];
        XC_IN_QRS06_CreateOpportunity.InputWrapper iw = new XC_IN_QRS06_CreateOpportunity.InputWrapper();
        iw.stepId = qrs.Id;
        
        Test.startTest();
            XC_IN_QRS06_CreateOpportunity.executeOpportunityCreation(new List<XC_IN_QRS06_CreateOpportunity.InputWrapper>{iw});
        Test.stopTest();
    }



}