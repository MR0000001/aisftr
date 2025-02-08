/**
 * @author              Luisana Rocco lrocco@deloitte.it
 * @date Creation       11/10/2021
 * @date Modification   
 * @description         test class for XC_IN_QRS08_GetAsset_CO
 */

@isTest
public without sharing class XC_IN_QRS08_GetAsset_CO_TEST {

    @TestSetup
	static void setup(){ 


        List<NE__Billing_Profile__c> bp = XC_DF_BillingProfile.createBillingProfile(1);
        bp[0].XC_CommodityContractID__c = '0989878770111';
        bp[0].NE__Payment__c = 'Commodity Bill';
        update(bp);

        XC_BillingProfileLineItem__c bpli = [SELECT Id, XC_BillingProfile__c, XC_BillingProfile__r.NE__Account__c, XC_SoldToAddress__c FROM XC_BillingProfileLineItem__c  WHERE XC_BillingProfile__c =: bp[0].Id][0];
        bpli.XC_LegalEntity__c = 'EndesaX';
        bpli.XC_DocumentType__c = 'NIF';
        bpli.XC_DocumentNumber__c = '53672895A';
        bpli.XC_DocumentCountry__c = 'Spain';
        update bpli; 

        XC_Address__c addr = new XC_Address__c(Id = bpli.XC_SoldToAddress__c, XC_AddressCountry__c = 'Spain');
        update addr;


        XC_PersonalDocument__c pd = new XC_PersonalDocument__c();
        pd.XC_DocumentType__c = 'NIF';
        pd.XC_DocumentNumber__c = '53672895A';
        pd.XC_Account__c = bpli.XC_BillingProfile__r.NE__Account__c;
        insert pd;
       

        List<Account> accList = new List<Account>{new Account(Id = bpli.XC_BillingProfile__r.NE__Account__c)};
  
        NE__Product__c prod = new NE__Product__c();
        prod.XC_LIC_Product_Name__c = 'OK Gas Basic';
        insert prod;

        
        Asset ass = new Asset();
        ass.XC_BillingProfileLineItem__c = bpli.Id;
        ass.NE__ProdId__c = prod.id;
        ass.Name='Test';
        ass.XC_LegalEntity__c = 'EndesaX';
        ass.XC_Segment__c = 'B2C';

        insert ass; 
        

       
        XC_QueuedRequest__c qr = new XC_QueuedRequest__c();
        qr.XC_RequestBody__c = '{"Account":{"AccountType":"Residential","Status":"Active","FirstName":"Test","LastName":"Test","MainPhonePrefix":"+34","MainPhone":"629876113","PrimaryEmail":"testCO@test.com","PhonePrefix":"","Phone":"","Country":"Spain","PreferenceLanguage":"Spanish"},"BillingProfile":[{"LegalEntity":"EndesaX","PaymentMethod":"","InvoicePreferredLanguage":"Spanish","InvoiceDeliveryPref":"Email","CommodityContractNum":"0989878770111","CommodityBillingCycleFrequency":"01"}],"Order":{"OrderType":"Change Order", "OrderSubType":"Change of ownership", "LegalEntity":"EndesaX","OrderStatus":"In Progress","Channel":"Market","IntegrationID":"33939308383328","CommodityContractNum":"0989878770111","IBAN":"ES04949494848949484", "OldAccountDNI": "53672895A"}}';
        qr.XC_ClientSystem__c = 'CommoditySpainB2C';
        qr.XC_TransactionId__c = 'Test';
        insert qr;

        qr.XC_Status__c  = 'In Progress';
        update qr;

        XC_REST_Account_W.WrapperResponse responseWrPreviousStep = new XC_REST_Account_W.WrapperResponse();
        responseWrPreviousStep.Account = new XC_UTIL_Account.AccountIFWrapper();
        responseWrPreviousStep.Account.AccountID = accList[0].Id;


        List<XC_QueuedRequestStep__c> qsList = [SELECT XC_StepSequence__c, XC_StepLabel__c, XC_ExecutionResponse__c  FROM XC_QueuedRequestStep__c];
        system.debug('QRLIST' + qsList);

        for(XC_QueuedRequestStep__c qs : qsList){
            if(qs.XC_StepSequence__c == 1){
                qs.XC_ExecutionResponse__c = JSON.serialize(responseWrPreviousStep);  
            }
        }
        update qsList;

        XC_QueuedRequestStep__c qrs = new XC_QueuedRequestStep__c();
		qrs.XC_StepLabel__c = 'Get Asset';
		qrs.XC_QueuedRequest__c = qr.Id;
		upsert qrs;
     
    }


    @isTest
	static void getAsset(){

        try{
            XC_QueuedRequestStep__c qrGetAsset = [SELECT Id, XC_QueuedRequest__r.XC_RequestBody__c FROM XC_QueuedRequestStep__c where XC_StepLabel__c =: 'Get Asset'][0];
        
            List<XC_IN_QRS08_GetAsset_CO.InputWrapper> inputs = new List<XC_IN_QRS08_GetAsset_CO.InputWrapper>();
            XC_IN_QRS08_GetAsset_CO.InputWrapper i = new XC_IN_QRS08_GetAsset_CO.InputWrapper();
            i.stepId = qrGetAsset.id;
            inputs.add(i);
        
            test.startTest();
            XC_IN_QRS08_GetAsset_CO.executeGetAssetCO(inputs);
            test.stopTest();

        }catch(Exception e){
            System.Debug('Exception ' + e.getMessage() + 'TRACE:: ' + e.getStackTraceString());        
        }      
    }
      
      
    @isTest
	static void getAssetKO(){
        

        NE__Billing_Profile__c bp =  [SELECT Id FROM NE__Billing_Profile__c LIMIT 1][0];
        bp.XC_CommodityContractID__c = '098987877011100';
        update(bp);

        
        try{
            XC_QueuedRequestStep__c qrGetAsset = [SELECT Id, XC_QueuedRequest__r.XC_RequestBody__c FROM XC_QueuedRequestStep__c where XC_StepLabel__c =: 'Get Asset'][0];

            List<XC_IN_QRS08_GetAsset_CO.InputWrapper> inputs = new List<XC_IN_QRS08_GetAsset_CO.InputWrapper>();
            XC_IN_QRS08_GetAsset_CO.InputWrapper i = new XC_IN_QRS08_GetAsset_CO.InputWrapper();
            i.stepId = qrGetAsset.id;
            inputs.add(i);
        
            test.startTest();
            XC_IN_QRS08_GetAsset_CO.executeGetAssetCO(inputs);
            test.stopTest();
        }catch(Exception e){
            System.Debug('Exception ' + e.getMessage() + 'TRACE:: ' + e.getStackTraceString());        
        }      
    }

}