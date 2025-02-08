/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 07/07/2020
* @date Modification dd/mm/yyyy
* @description  – XC_IN_QRS02_CreateAddress_TEST
*/ 
@isTest
public class XC_IN_QRS02_CreateAddress_TEST {
    
    @TestSetup
    static void setup(){
        List<Account> accs = XC_DF_Account.createResidentialAccounts(1);
        insert accs;
        
        XC_UTIL_QueuedRequest_W.WrapperRequest wr = new XC_UTIL_QueuedRequest_W.WrapperRequest();
        wr.Account = new XC_UTIL_Account.AccountIFWrapper();
        wr.Account.AccountID = 'test';
        wr.Address = new List<XC_UTIL_Address.AddressWrapper>();
        XC_UTIL_Address.AddressWrapper addw = new XC_UTIL_Address.AddressWrapper();
        addw.Country='Italy';
        addw.City='Roma';
        addw.Region='Lazio';
        addw.Address = 'Del Corso';
        addw.StreetNumber = '12';
        addw.StreetType = 'Via';
        addw.ZipCode = '00186';
        addw.Province = 'Roma';
        addw.Municipality = 'Lazio';
        wr.Address.add(addw);
            
        XC_QueuedRequest__c r = new XC_QueuedRequest__c();
        r.XC_RequestBody__c = JSON.serialize(wr);
        r.XC_ClientSystem__c = 'CommodityItalyB2C';
        insert r;
        
    	XC_QueuedRequestStep__c q2 = new XC_QueuedRequestStep__c();
        q2.XC_QueuedRequest__c = r.Id;
        q2.XC_StepSequence__c = 2;
        insert q2;
        
        XC_QueuedRequestStep__c q1 = new XC_QueuedRequestStep__c();
        q1.XC_QueuedRequest__c = r.Id;
        q1.XC_StepSequence__c = 1;
        insert q1;
    }
    
    static testMethod void callexecuteAddressCreationEmptyReq(){
        
       	XC_UTIL_QueuedRequest_W.WrapperRequest wr = new XC_UTIL_QueuedRequest_W.WrapperRequest();
        wr.Account = new XC_UTIL_Account.AccountIFWrapper();
        wr.Account.AccountID = 'test';
        
        XC_QueuedRequestStep__c q = [
            SELECT Id, XC_QueuedRequest__r.XC_RequestBody__c
            FROM XC_QueuedRequestStep__c
        	where XC_StepSequence__c = 2][0];
        
        XC_QueuedRequestStep__c q1 = [
            SELECT Id, XC_ExecutionResponse__c
            FROM XC_QueuedRequestStep__c
        	where XC_StepSequence__c = 1][0];
        
        q1.XC_ExecutionResponse__c = JSON.serialize(wr); 
        update q1;
        
        List<XC_IN_QRS02_CreateAddress.InputWrapper> inputs = new List<XC_IN_QRS02_CreateAddress.InputWrapper>();
        XC_IN_QRS02_CreateAddress.InputWrapper i = new XC_IN_QRS02_CreateAddress.InputWrapper();
        i.stepId = q.id;
        inputs.add(i);
        
        test.startTest();
        XC_IN_QRS02_CreateAddress.executeAccountCreation(inputs);
        test.stopTest();
    }

    static testMethod void callexecuteAddressCreationErr(){
        
       	XC_UTIL_QueuedRequest_W.WrapperRequest wr = new XC_UTIL_QueuedRequest_W.WrapperRequest();
        wr.Account = new XC_UTIL_Account.AccountIFWrapper();
        wr.Account.AccountID = [select id from account][0].id;
        
        XC_QueuedRequestStep__c q = [
            SELECT Id, XC_QueuedRequest__r.XC_RequestBody__c
            FROM XC_QueuedRequestStep__c
        	where XC_StepSequence__c = 2][0];
        
        XC_QueuedRequestStep__c q1 = [
            SELECT Id, XC_ExecutionResponse__c
            FROM XC_QueuedRequestStep__c
        	where XC_StepSequence__c = 1][0];
        
        q1.XC_ExecutionResponse__c = JSON.serialize(wr); 
        update q1;
        
        List<XC_IN_QRS02_CreateAddress.InputWrapper> inputs = new List<XC_IN_QRS02_CreateAddress.InputWrapper>();
        XC_IN_QRS02_CreateAddress.InputWrapper i = new XC_IN_QRS02_CreateAddress.InputWrapper();
        i.stepId = q.id;
        inputs.add(i);
        
        test.startTest();
        XC_IN_QRS02_CreateAddress.executeAccountCreation(inputs);
        test.stopTest();
    }

	static testMethod void callexecuteAddressCreationOK(){
        
       	XC_UTIL_QueuedRequest_W.WrapperRequest wr = new XC_UTIL_QueuedRequest_W.WrapperRequest();
        wr.Account = new XC_UTIL_Account.AccountIFWrapper();
        wr.Account.AccountID = [select id from account][0].id;
        
        insert xc_df_contact.createResidentialContacts([select id from account]);
        
        XC_QueuedRequestStep__c q = [
            SELECT Id, XC_QueuedRequest__r.XC_RequestBody__c
            FROM XC_QueuedRequestStep__c
        	where XC_StepSequence__c = 2][0];
        
        XC_QueuedRequestStep__c q1 = [
            SELECT Id, XC_ExecutionResponse__c
            FROM XC_QueuedRequestStep__c
        	where XC_StepSequence__c = 1][0];
        
        q1.XC_ExecutionResponse__c = JSON.serialize(wr); 
        update q1;
        
        List<XC_IN_QRS02_CreateAddress.InputWrapper> inputs = new List<XC_IN_QRS02_CreateAddress.InputWrapper>();
        XC_IN_QRS02_CreateAddress.InputWrapper i = new XC_IN_QRS02_CreateAddress.InputWrapper();
        i.stepId = q.id;
        inputs.add(i);
        
        test.startTest();
        XC_IN_QRS02_CreateAddress.executeAccountCreation(inputs);
        test.stopTest();
    }
    
    static testMethod void callexecuteAddressCreationDupl(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
       	XC_Address__c add = new XC_Address__c();
        add.XC_Account__c = [select id from account][0].id;
        add.XC_AddressCountry__c = 'Italy';
        add.XC_City__c = 'Roma';
        add.XC_Region__c = 'Lazio';
		add.XC_StreetTypeText__c = 'Via';
        add.XC_Address__c = 'Del Corso';
        add.XC_StreetNumber__c = '12';
        add.XC_Municipality__c = 'Lazio';
        add.XC_AddressProvince__c = 'Roma';
        insert add;
                
       	XC_UTIL_QueuedRequest_W.WrapperRequest wr = new XC_UTIL_QueuedRequest_W.WrapperRequest();
        wr.Account = new XC_UTIL_Account.AccountIFWrapper();
        wr.Account.AccountID = [select id from account][0].id;
        
        insert xc_df_contact.createResidentialContacts([select id from account]);
        
        XC_QueuedRequestStep__c q = [
            SELECT Id, XC_QueuedRequest__r.XC_RequestBody__c
            FROM XC_QueuedRequestStep__c
        	where XC_StepSequence__c = 2][0];
        
        XC_QueuedRequestStep__c q1 = [
            SELECT Id, XC_ExecutionResponse__c
            FROM XC_QueuedRequestStep__c
        	where XC_StepSequence__c = 1][0];
        
        q1.XC_ExecutionResponse__c = JSON.serialize(wr); 
        update q1;
        
        List<XC_IN_QRS02_CreateAddress.InputWrapper> inputs = new List<XC_IN_QRS02_CreateAddress.InputWrapper>();
        XC_IN_QRS02_CreateAddress.InputWrapper i = new XC_IN_QRS02_CreateAddress.InputWrapper();
        i.stepId = q.id;
        inputs.add(i);
        
        test.startTest();
        XC_IN_QRS02_CreateAddress.executeAccountCreation(inputs);
        XC_IN_QRS02_CreateAddress.executeAccountCreation(inputs);
        test.stopTest();
    }

}