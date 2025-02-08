/**
 * @author Monica Cutillo - mcutillo@deloitte.it
 * @date Creation 07/02/2020
 * @date Modification dd/mm/yyyy
 * @description XC_UTIL_DisconnectAssetManager_TEST - test class for XC_UTIL_DisconnectAssetManager.
 */
@isTest
public class XC_UTIL_DisconnectAssetManager_TEST {@TestSetup
    
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accountList);
        insert contacts;

        List<Asset> listAsset = XC_DF_Asset.createAssets(accountList);
        listAsset[0].ContactId = contacts[0].Id;
        insert listAsset;

        /*List<WorkOrder> listWO = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        listWO[0].AssetId = listAsset[0].Id;
        XC_UTIL_SObject.insertListRecords(listWO);*/
        //System.debug('### ' + listWO);
    }
    
    @isTest static void manageInitDisconnection_Claim() {
        List<Asset> asset = [Select Id, AccountId, ContactId FROM Asset];
        // 1- Complain Case creation
        Case complCase = new Case();
        complCase.Reason = Label.XC_CL_CaseReason_ComplaintValue;
        complCase.SubCause__c = 'ATCL008';
        complCase.Reason = 'XCMOT010';
        complCase.XC_Type_Intermediary__c = 'TI001';
        complCase.AccountId = asset[0].AccountId; // listAsset[0].AccountId;
        complCase.ContactId = asset[0].ContactId; // contacts[0].Id;
        complCase.AssetId = asset[0].Id; // listAsset[0].Id;
        insert complCase;
        // 2- Complain Case closure        
        Case casoToUpd = [SELECT Id FROM Case WHERE Id =: complCase.Id];
        casoToUpd.XC_Resolution__c = 'R019';
        casoToUpd.XC_Result__c = 'RS001';
        casoToUpd.CaseRemarks__c = 'test MC';
        update casoToUpd;
        // 3- Disconnection Case creation
        Case caso = new Case();
        caso.Reason = 'XCMOT010';
        caso.SubCause__c = 'ATCL008';
        caso.AccountId = asset[0].AccountId; // listAsset[0].AccountId;
        caso.ContactId = asset[0].ContactId; // contacts[0].Id;
        caso.AssetId = asset[0].Id; // listAsset[0].Id;
        caso.Status = 'ESTA001';
        insert caso;

        Test.startTest();
            XC_UTIL_ResultWrapper wr = XC_UTIL_DisconnectAssetManager.manageInitDisconnection(caso);
        Test.stopTest();
        
        System.assert(wr.success);
    }
    
    @isTest static void manageInitDisconnection_Complaint() {
        List<Asset> asset = [Select Id, AccountId, ContactId FROM Asset];
        
        // 1- Complain Case creation
        Case complCase = new Case();
        complCase.Reason = Label.XC_CL_CaseReason_ComplaintValue;
        complCase.SubCause__c = 'ATCL008';
        complCase.Reason = 'XCMOT010';
        complCase.XC_Type_Intermediary__c = 'TI001';
        complCase.AccountId = asset[0].AccountId; // listAsset[0].AccountId;
        complCase.ContactId = asset[0].ContactId; // contacts[0].Id;
        complCase.AssetId = asset[0].Id; // listAsset[0].Id;
        insert complCase;
        // 2- Complain Case closure        
        Case casoToUpd = [SELECT Id FROM Case WHERE Id =: complCase.Id];
        casoToUpd.XC_Resolution__c = 'R019';
        casoToUpd.XC_Result__c = 'RS001';
        casoToUpd.CaseRemarks__c = 'test MC';
        update casoToUpd;
        // 3- Disconnection Case creation
        Case caso = new Case();
        caso.Reason = 'XCMOT009';
        caso.SubCause__c = 'ATCL008';
        caso.AccountId = asset[0].AccountId; // listAsset[0].AccountId;
        caso.ContactId = asset[0].ContactId; // contacts[0].Id;
        caso.AssetId = asset[0].Id; // listAsset[0].Id;
        caso.Status = 'ESTA001';
        insert caso;

        Test.startTest();
            XC_UTIL_ResultWrapper wr = XC_UTIL_DisconnectAssetManager.manageInitDisconnection(caso);
        Test.stopTest();
        
        System.assert(wr.success);
    }
    
    @isTest static void manageInitDisconnection_Rethinking() {
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accountList);
        insert contacts;
        
        Zuora__Subscription__c subscr = new Zuora__Subscription__c();
        insert subscr;
        
        Zuora__ZInvoice__c invoice = new Zuora__ZInvoice__c();
        invoice.Zuora__Balance2__c = 0;
        insert invoice;
        
        Zuora__InvoiceItem__c invItem = new Zuora__InvoiceItem__c();
        invItem.Zuora__UnitPrice2__c = 10;
        invItem.Zuora__Charge_Amount2__c = 20;
        invItem.Zuora__TaxAmount2__c = -2;
        invItem.Zuora__Subscription__c = subscr.Id;
        invItem.Zuora__Invoice__c = invoice.Id;
        insert invItem;
        
        Contract contr = new Contract();
        contr.AccountId = accountList[0].Id;
        contr.StartDate = Date.today();
        contr.EndDate = (Date.today()).addMonths(24);
        contr.ContractTerm = 12;
        contr.CurrencyIsoCode = '';
        contr.RecordTypeId=Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_ESP_Contract').getRecordTypeId(); 
        contr.XC_Segment__c = 'B2C';
        contr.XC_LegalEntity__c = 'EndesaX';
        insert contr;
        Test.startTest();
        List<Asset> listAsset = XC_DF_Asset.createAssets(accountList);
        listAsset[0].ContactId = contacts[0].Id;
        listAsset[0].Status = 'Active';
        listAsset[0].XC_ActivationDate__c = Date.today();
        listAsset[0].XC_ActivationDate__c = Date.today();
        listAsset[0].XC_Subscription__c = subscr.Id;
        listAsset[0].XC_Subscription__r = subscr;
        //listAsset[0].XC_Contract__c = contr.Id;
        listAsset[0].XC_Contract__r = contr;
        insert listAsset;

        List<WorkOrder> listWO = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        listWO[0].AssetId = listAsset[0].Id;
        XC_UTIL_SObject.insertListRecords(listWO);
        System.debug('### ' + listWO);
        
        // Disconnection Case creation
        Case caso = new Case();
        caso.Reason = 'XCMOT010';
        caso.SubCause__c = 'ATCL008';
        caso.AccountId = listAsset[0].AccountId;
        caso.ContactId = contacts[0].Id;
        caso.AssetId = listAsset[0].Id;
        caso.XC_Communication_Date__c = Date.today();
        caso.Status = 'ESTA001';
        insert caso;
        
        
            XC_UTIL_ResultWrapper wr = XC_UTIL_DisconnectAssetManager.manageInitDisconnection(caso);
        Test.stopTest();
        
        System.assert(wr.success);
    }
    
    @isTest static void manageInitDisconnection_fromMigrazione() {
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accountList);
        insert contacts;
        
        Zuora__Subscription__c subscr = new Zuora__Subscription__c();
        subscr.Zuora__External_Id__c = '123stella';
        insert subscr;
        
        Zuora__ZInvoice__c invoice = new Zuora__ZInvoice__c();
        invoice.Zuora__Balance2__c = 0;
        insert invoice;
        
        Zuora__InvoiceItem__c invItem = new Zuora__InvoiceItem__c();
        invItem.Zuora__UnitPrice2__c = 10;
        invItem.Zuora__Charge_Amount2__c = 20;
        invItem.Zuora__TaxAmount2__c = -2;
        invItem.Zuora__Subscription__c = subscr.Id;
        invItem.Zuora__Invoice__c = invoice.Id;
        insert invItem;
        Test.startTest();
        List<Asset> listAsset = XC_DF_Asset.createAssets(accountList);
        listAsset[0].ContactId = contacts[0].Id;
        listAsset[0].Status = 'Active';
        listAsset[0].XC_ActivationDate__c = Date.today();
        listAsset[0].XC_ActivationDate__c = Date.today();
        listAsset[0].XC_SubscriptionId__c = subscr.Zuora__External_Id__c;
        insert listAsset;

        List<WorkOrder> listWO = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        listWO[0].AssetId = listAsset[0].Id;
        XC_UTIL_SObject.insertListRecords(listWO);
        System.debug('### ' + listWO);
        
        // Disconnection Case creation
        Case caso = new Case();
        caso.Reason = 'XCMOT010';
        caso.SubCause__c = 'ATCL008';
        caso.AccountId = listAsset[0].AccountId;
        caso.ContactId = contacts[0].Id;
        caso.AssetId = listAsset[0].Id;
        caso.XC_Communication_Date__c = Date.today();
        caso.Status = 'ESTA001';
        insert caso;
        
        
            XC_UTIL_ResultWrapper wr = XC_UTIL_DisconnectAssetManager.manageInitDisconnection(caso);
        Test.stopTest();
        
        System.assert(wr.success);
    }
    
    @isTest static void checkRethinking() {
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accountList);
        insert contacts;
        
        /*Zuora__Subscription__c subscr = new Zuora__Subscription__c();
        insert subscr;
        
        Zuora__ZInvoice__c invoice = new Zuora__ZInvoice__c();
        invoice.Zuora__Balance2__c = 0;
        insert invoice;
        
        Zuora__InvoiceItem__c invItem = new Zuora__InvoiceItem__c();
        invItem.Zuora__UnitPrice2__c = 10;
        invItem.Zuora__Charge_Amount2__c = 20;
        invItem.Zuora__TaxAmount2__c = -2;
        invItem.Zuora__Subscription__c = subscr.Id;*/

        List<Asset> listAsset = XC_DF_Asset.createAssets(accountList);
        listAsset[0].ContactId = contacts[0].Id;
        listAsset[0].Status = 'Active';
        listAsset[0].XC_ActivationDate__c = Date.today();
        //listAsset[0].XC_Subscription__c = subscr.Id;
        insert listAsset;

        List<WorkOrder> listWO = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        listWO[0].AssetId = listAsset[0].Id;
        XC_UTIL_SObject.insertListRecords(listWO);
        
        // Disconnection Case creation
        Case caso = new Case();
        caso.Reason = 'XCMOT010';
        caso.SubCause__c = 'ATCL008';
        caso.AccountId = listAsset[0].AccountId;
        caso.ContactId = contacts[0].Id;
        caso.AssetId = listAsset[0].Id;
        caso.XC_Communication_Date__c = Date.today();
        caso.Status = 'ESTA001';
        insert caso;
        
        Test.startTest();
            XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper prcWr = XC_UTIL_PenaltyRefundCalculation.getCalculationInput(listAsset[0].Id, 'Rethinking', Date.today());
            prcWr.caso = caso;
            XC_UTIL_ResultWrapper wr = XC_UTIL_DisconnectAssetManager.checkRethinking(prcWr);
        Test.stopTest();
        
        System.assert(wr.success);
    }
    
    @isTest static void preChecksToRefund() {
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accountList);
        insert contacts;

        List<Asset> listAsset = XC_DF_Asset.createAssets(accountList);
        listAsset[0].ContactId = contacts[0].Id;
        listAsset[0].Status = 'Active';
        listAsset[0].XC_ActivationDate__c = Date.today();
        listAsset[0].XC_ContractStartDate__c = Date.today();
        insert listAsset;

        List<WorkOrder> listWO = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        listWO[0].AssetId = listAsset[0].Id;
        XC_UTIL_SObject.insertListRecords(listWO);
        
        // Disconnection Case creation
        Case caso = new Case();
        caso.Reason = 'XCMOT009';
        caso.SubCause__c = 'ATCL008';
        caso.AccountId = listAsset[0].AccountId;
        caso.ContactId = contacts[0].Id;
        caso.AssetId = listAsset[0].Id;
        caso.XC_Communication_Date__c = Date.today();
        caso.Status = 'ESTA001';
        insert caso;
        
        Test.startTest();
            XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper prcWr = XC_UTIL_PenaltyRefundCalculation.getCalculationInput(listAsset[0].Id, 'Requested by technician', Date.today());
            prcWr.caso = caso;
            Boolean result = XC_UTIL_DisconnectAssetManager.preChecksToRefund(prcWr);
        Test.stopTest();
        
        System.assert(!result);
    }
}