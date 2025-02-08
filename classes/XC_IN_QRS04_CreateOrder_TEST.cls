/**
 * @author              Luisana Rocco lrocco@deloitte.it
 * @date Creation       30/06/2020
 * @date Modification   
 * @description         test class for XC_IN_QRS04_CreateOrder
 */

@isTest
public without sharing class XC_IN_QRS04_CreateOrder_TEST {

    @TestSetup
	static void setup(){ 


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


        NE__Family__c fam = new NE__Family__c();
        fam.name = 'Test';
        insert fam;

        NE__DynamicPropertyDefinition__c propdef = new NE__DynamicPropertyDefinition__c();
        propdef.Name='Pfp';
        insert propdef;

        NE__ProductFamilyProperty__c famProp= new NE__ProductFamilyProperty__c();
        famProp.NE__FamilyId__c=fam.id;
        famProp.NE__PropId__c = propdef.id;
        insert famProp; 

        NE__Catalog_Item__c catItem = XC_DF_CatalogItem.createCatalogItem();
        catItem.Catalog_item_code__c = 'TestCatItem';
        catItem.NE__UsageCode__c = 'TestCatItem';
        insert catItem;

        NE__Catalog__c catalog = [Select id from NE__Catalog__c LIMIT 1];
        catalog.XC_LIC_Name__c = 'e-Home IT';
        update catalog;
        

        List<Account> acc = [SELECT Id, (SELECT Id, XC_BillingProfile__c  FROM XC_BillingProfileLineItems__r), (SELECT Id  FROM Addresses__r) FROM Account LIMIT 1];
        XC_QueuedRequest__c qr = new XC_QueuedRequest__c();
        qr.XC_RequestBody__c = '{"Order":{"Channel":"EnelEnergiaItalia","Document":[{"ContractUrl":"http:z"}],"IntegrationID":"1231213123","LegalEntity":"EnelXItalia","OrderItem":[{"Attribute":[{"Name":"Test:Pfp","ProductFamilyPropertyID":"a1V1l000000PNaMEAW","Value":"Monthly"}],"BaseOneTimeFee":0.00,"BaseRecurringCharge":7.50,"BundleConfiguration":null,"ContractType":"Light","ProdID":"TestCatItem","Quantity":1}],"OrderStatus":"In progress"}}';
        qr.XC_ClientSystem__c = 'CommodityItalyB2C';
        qr.XC_TransactionId__c = 'Test';
        insert qr;

        XC_REST_Account_W.WrapperResponse responseWrPreviousStepAddress = new XC_REST_Account_W.WrapperResponse();
        responseWrPreviousStepAddress.Account = new XC_UTIL_Account.AccountIFWrapper();
        responseWrPreviousStepAddress.Account.AccountID = acc[0].Id;
        responseWrPreviousStepAddress.Address = new List<XC_UTIL_Address.AddressWrapper>();
        XC_UTIL_Address.AddressWrapper addressWr = new XC_UTIL_Address.AddressWrapper();
        addressWr.AddressID = acc[0].Addresses__r[0].Id;
        responseWrPreviousStepAddress.Address.add(addressWr); 

        XC_REST_Account_W.WrapperResponse responseWrPreviousStepBP = new XC_REST_Account_W.WrapperResponse();
        responseWrPreviousStepBP.Account = new XC_UTIL_Account.AccountIFWrapper();
        responseWrPreviousStepBP.Account.AccountID = acc[0].Id;
        responseWrPreviousStepBP.BillingProfile = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
        XC_UTIL_BillingProfile.BillingProfileIFWrapper billingProfileWr = new  XC_UTIL_BillingProfile.BillingProfileIFWrapper();
        billingProfileWr.BillingProfileID = acc[0].XC_BillingProfileLineItems__r[0].XC_BillingProfile__c;
        responseWrPreviousStepBP.BillingProfile.add(billingProfileWr);



        List<XC_QueuedRequestStep__c> qsList = [SELECT XC_StepSequence__c, XC_ExecutionResponse__c  FROM XC_QueuedRequestStep__c];

        for(XC_QueuedRequestStep__c qs : qsList){
            if(qs.XC_StepSequence__c == 2){
                qs.XC_ExecutionResponse__c = JSON.serialize(responseWrPreviousStepAddress);  
            }
            else  if(qs.XC_StepSequence__c == 3){
                qs.XC_ExecutionResponse__c = JSON.serialize(responseWrPreviousStepBP);
            }
        }
        update qsList;
     
    }

    @isTest
	static void inserOrder(){
        
        XC_QueuedRequestStep__c qsOrder = [SELECT Id, XC_QueuedRequest__r.XC_RequestBody__c FROM XC_QueuedRequestStep__c where XC_StepSequence__c = 4][0];

        List<XC_IN_QRS04_CreateOrder.InputWrapper> inputs = new List<XC_IN_QRS04_CreateOrder.InputWrapper>();
        XC_IN_QRS04_CreateOrder.InputWrapper i = new XC_IN_QRS04_CreateOrder.InputWrapper();
        i.stepId = qsOrder.id;
        inputs.add(i);
        
        test.startTest();
        XC_IN_QRS04_CreateOrder.executeOrderCreation(inputs);
        XC_IN_QRS04_CreateOrder.skipTestMFL();
        test.stopTest();


    }

    @isTest
	static void prodIdNotValidTest(){
        
        NE__Catalog_Item__c catItem = [SELECT Id FROM NE__Catalog_Item__c LIMIT 1][0];
        catItem.Catalog_item_code__c = 'TestCatItemCode';
        catItem.NE__UsageCode__c = 'TestCatItemCode';
        update catItem;

        XC_QueuedRequestStep__c qsOrder = [SELECT Id, XC_QueuedRequest__r.XC_RequestBody__c FROM XC_QueuedRequestStep__c where XC_StepSequence__c = 4][0];

        List<XC_IN_QRS04_CreateOrder.InputWrapper> inputs = new List<XC_IN_QRS04_CreateOrder.InputWrapper>();
        XC_IN_QRS04_CreateOrder.InputWrapper i = new XC_IN_QRS04_CreateOrder.InputWrapper();
        i.stepId = qsOrder.id;
        inputs.add(i);
        
        test.startTest();
        XC_IN_QRS04_CreateOrder.executeOrderCreation(inputs);
        test.stopTest();

    }

    
    @isTest
	static void pfpNotValidTest(){
        
        NE__DynamicPropertyDefinition__c propdef = [SELECT Id FROM NE__DynamicPropertyDefinition__c LIMIT 1][0];
        propdef.Name = 'Test';
        update propdef;

        XC_QueuedRequestStep__c qsOrder = [SELECT Id, XC_QueuedRequest__r.XC_RequestBody__c FROM XC_QueuedRequestStep__c where XC_StepSequence__c = 4][0];

        List<XC_IN_QRS04_CreateOrder.InputWrapper> inputs = new List<XC_IN_QRS04_CreateOrder.InputWrapper>();
        XC_IN_QRS04_CreateOrder.InputWrapper i = new XC_IN_QRS04_CreateOrder.InputWrapper();
        i.stepId = qsOrder.id;
        inputs.add(i);
        
        test.startTest();
        XC_IN_QRS04_CreateOrder.executeOrderCreation(inputs);
        test.stopTest();

    }


}