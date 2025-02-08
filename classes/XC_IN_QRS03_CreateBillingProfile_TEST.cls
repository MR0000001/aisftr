/**
 * @File Name          : XC_IN_QRS03_CreateBillingProfile_TEST.cls
 * @Description        : TEST CALSS For XC_IN_QRS03_CreateBillingProfile
 * @Author             : Marco Ottaviano mottaviano@deloitte.it
 * @Group              : 
 * @Last Modified By   : 
 * @Last Modified On   : 13/07/2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1     13/07/2020     Marco Ottaviano
**/

@isTest
public without sharing class XC_IN_QRS03_CreateBillingProfile_TEST {
    
 @TestSetup
 static void makeData(){
	 insert XC_DF_OneOrg.createOneOrg('Spain');
   
    List<XC_QueuedRequest__c> qrList = XC_DF_QueuedRequest.createQueuedRequest(1);
    insert qrList;
     
    List<XC_QueuedRequestStep__c> qrs = [SELECT ID FROM  XC_QueuedRequestStep__c ORDER BY XC_StepSequence__c ASC];
    XC_IN_QRS01_CreateAccount.InputWrapper iw = new XC_IN_QRS01_CreateAccount.InputWrapper();
    iw.stepId = qrs[0].Id;
     
    XC_IN_QRS02_CreateAddress.InputWrapper iw2 = new XC_IN_QRS02_CreateAddress.InputWrapper();
    iw2.stepId = qrs[1].Id;
        
    Test.startTest();
            XC_IN_QRS01_CreateAccount.manageAccountCreation(new List<XC_IN_QRS01_CreateAccount.InputWrapper>{iw});
            List<Account> accCrated = [SELECT ID FROM Account];
            XC_Address__c addressToInsert = new XC_Address__c();
            addressToInsert.XC_Account__c = accCrated.get(0).Id;
            addressToInsert.XC_Address__c = 'Address Name that have to pass the 80 charachter in order to cover the class to test';
            addressToInsert.XC_City__c = 'Madrid';
            addressToInsert.XC_AddressCountry__c = 'Spain';
            addressToInsert.XC_PostalCode__c = '28080';
            addressToInsert.XC_AddressProvince__c = 'Madrid';
            addressToInsert.XC_StreetNumber__c = '1';
            addressToInsert.XC_StreetType__c = 'Street'; 
            addressToInsert.XC_Municipality__c   = 'Test';
            addressToInsert.XC_Stair__c = '7';
            addressToInsert.XC_Floor__c = 'B';
            addressToInsert.XC_DeliveryAddress__c = TRUE;
            addressToInsert.XC_BillingAddress__c = TRUE;
            insert addressToInsert;
            
        Test.stopTest();
 }

 @isTest
 static void testone() {
    XC_QueuedRequestStep__c qrs = [SELECT ID FROM  XC_QueuedRequestStep__c WHERE XC_StepLabel__c ='Create Billing Profile'];
  
    
    XC_QueuedRequestStep__c qrsAdd = [SELECT Id,XC_RelatedRecordsIds__c,XC_ExecutionResponse__c FROM XC_QueuedRequestStep__c WHERE XC_StepLabel__c ='Create Address'];
    List<Account> acc = [SELECT Id, Name, (SELECT Id, XC_BillingProfile__c  FROM XC_BillingProfileLineItems__r), (SELECT Id  FROM Addresses__r) FROM Account LIMIT 1];
      System.debug('Acc created: '+acc[0]);

    XC_REST_Account_W.WrapperResponse responseWrPreviousStepAddress = new XC_REST_Account_W.WrapperResponse();
    responseWrPreviousStepAddress.Account = new XC_UTIL_Account.AccountIFWrapper();
    responseWrPreviousStepAddress.Account.AccountID = acc[0].Id;
    responseWrPreviousStepAddress.Address = new List<XC_UTIL_Address.AddressWrapper>();
    XC_UTIL_Address.AddressWrapper addressWr = new XC_UTIL_Address.AddressWrapper();
    addressWr.AddressID = acc[0].Addresses__r[0].Id;
    responseWrPreviousStepAddress.Address.add(addressWr); 

    qrsAdd.XC_ExecutionResponse__c = JSON.serialize(responseWrPreviousStepAddress);
    update qrsAdd;

    System.debug('Address created: '+ [SELECT Id,Name FROM XC_Address__c WHERE ID =: acc[0].Addresses__r[0].Id]);



    XC_IN_QRS03_CreateBillingProfile.InputWrapper iw = new XC_IN_QRS03_CreateBillingProfile.InputWrapper();
    iw.stepId = qrs.Id;

    Test.startTest();
        XC_IN_QRS03_CreateBillingProfile.executeBillingProfileCreation(new List<XC_IN_QRS03_CreateBillingProfile.InputWrapper>{iw});
    Test.stopTest();

 }

 
 @isTest
 static void testwo() {
    List<User> user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId()];
    user[0].XC_EnabledToSkip__c = true;
    update user;

    XC_QueuedRequestStep__c qrs = [SELECT ID FROM  XC_QueuedRequestStep__c WHERE XC_StepLabel__c ='Create Billing Profile'];
  
    
    XC_QueuedRequestStep__c qrsAdd = [SELECT Id,XC_RelatedRecordsIds__c,XC_ExecutionResponse__c FROM XC_QueuedRequestStep__c WHERE XC_StepLabel__c ='Create Address'];
    List<Account> acc = [SELECT Id, Name, (SELECT Id, XC_BillingProfile__c  FROM XC_BillingProfileLineItems__r), (SELECT Id  FROM Addresses__r) FROM Account LIMIT 1];
      System.debug('Acc created: '+acc[0]);

    XC_REST_Account_W.WrapperResponse responseWrPreviousStepAddress = new XC_REST_Account_W.WrapperResponse();
    responseWrPreviousStepAddress.Account = new XC_UTIL_Account.AccountIFWrapper();
    responseWrPreviousStepAddress.Account.AccountID = acc[0].Id;
    responseWrPreviousStepAddress.Address = null;
   // XC_UTIL_Address.AddressWrapper addressWr = new XC_UTIL_Address.AddressWrapper();
   // addressWr.AddressID = acc[0].Addresses__r[0].Id;
   // responseWrPreviousStepAddress.Address.add(addressWr); 

    qrsAdd.XC_ExecutionResponse__c = JSON.serialize(responseWrPreviousStepAddress);
    update qrsAdd;

    System.debug('Address created: '+ [SELECT Id,Name FROM XC_Address__c WHERE ID =: acc[0].Addresses__r[0].Id]);


     Test.startTest();
        
        NE__Billing_Profile__c billingToInsert = new NE__Billing_Profile__c(NE__Account__c=acc[0].Id, NE__Payment__c='Commodity Bill',XC_CommodityContractID__c = '0039256378',XC_isGuest__c = 'false');
        insert billingToInsert;
        XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(XC_BillingProfile__c=billingToInsert.id, XC_SoldToAddress__c=acc[0].Addresses__r[0].Id,XC_BillToAddress__c=acc[0].Addresses__r[0].Id, XC_Account__c=acc[0].Id);
        insert bpli;



    XC_IN_QRS03_CreateBillingProfile.InputWrapper iw = new XC_IN_QRS03_CreateBillingProfile.InputWrapper();
    iw.stepId = qrs.Id;

   
        XC_IN_QRS03_CreateBillingProfile.executeBillingProfileCreation(new List<XC_IN_QRS03_CreateBillingProfile.InputWrapper>{iw});
    Test.stopTest();

 }
    
   @isTest
    static void manageErrors_test() {
        XC_QueuedRequestStep__c qrs = [SELECT ID FROM  XC_QueuedRequestStep__c WHERE XC_StepLabel__c ='Create Billing Profile'];
        List<Account> acc = [SELECT Id, Name, (SELECT Id  FROM Addresses__r) FROM Account];
        NE__Billing_Profile__c billingToInsert = new NE__Billing_Profile__c(NE__Account__c=acc[0].Id, NE__Payment__c='Commodity Bill',XC_CommodityContractID__c = '0039256378',XC_isGuest__c = 'false');
        insert billingToInsert;
        XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(XC_BillingProfile__c=billingToInsert.id, XC_SoldToAddress__c=acc[0].Addresses__r[0].Id,XC_BillToAddress__c=acc[0].Addresses__r[0].Id, XC_Account__c=acc[0].Id);
        insert bpli;
     	XC_UTIL_Account.AccountIFWrapper accWr= new XC_UTIL_Account.AccountIFWrapper();
        accWr.AccountID = acc[0].Id;
        XC_REST_Account_W.WrapperResponse wrapperResp = new XC_REST_Account_W.WrapperResponse();
        XC_UTIL_Integration.Result utilRes = new XC_UTIL_Integration.Result();
        utilRes.ErrorCode ='500';
        utilRes.Message ='Already exist a Billing profile with this Commodity Contract';
        wrapperResp.Result = utilRes;
        wrapperResp.Account = accWr;
        
        XC_REST_Account_W.WrapperRequest wrReq = new XC_REST_Account_W.WrapperRequest();
        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wbp = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
        XC_UTIL_BillingProfile.BillingProfileIFWrapper pb = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
        pb.CommodityContractNum ='0039256378';
        wbp.add(pb);
        wrReq.BillingProfile = wbp;
        
        Test.startTest();
        	XC_IN_QRS03_CreateBillingProfile.manageErrors(qrs,wrapperResp,wrReq);
        Test.stopTest();
        
    }


}