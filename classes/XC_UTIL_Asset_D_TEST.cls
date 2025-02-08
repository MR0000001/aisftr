/**
 * @author Monica Cutillo - mcutillo@deloitte.it
 * @date Creation 20/04/2020
 * @description XC_UTIL_Asset_D_TEST - test class for XC_UTIL_Asset_D.
 */
@isTest
public class XC_UTIL_Asset_D_TEST {
    @TestSetup
    static void setup()
    {	
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
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
        caso.SubCause__c = 'ATCL015';
        caso.AccountId = listAsset[0].AccountId;
        caso.ContactId = contacts[0].Id;
        caso.AssetId = listAsset[0].Id;
        caso.XC_Communication_Date__c = Date.today();
        insert caso;
        
        Test.startTest();
            XC_UTIL_ResultWrapper wr = XC_UTIL_DisconnectAssetManager.manageInitDisconnection(caso);
        Test.stopTest();
        
        System.assert(wr.success);
    }
    
    /* DECOMMENTARE QUANDO VIENE AGGIUNTA GESTIONE CAMPO XC_AssetListDetails__c su Case
    @isTest
    static void populateAssetListDetails_EquipmenmtAssociatedOnUpdate(){
        List<Account> accntList = XC_DF_Account.createResidentialAccounts(1);
        insert accntList;
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(accntList);
        insert contList;
        
        NE__Bundle__c  bundle = new NE__Bundle__c(NE__RecurringChargeFrequency__c = 'Monthly', NE__Start_Date__c = Date.Today());
        insert bundle;
		NE__Product__c product = new NE__Product__c(Name = 'Solution Caldera'); 
        product.XC_Product_Subtype__c = 'Boiler';
        product.XC_Product_Type__c = 'Equipment';
        insert product;
        List<Asset> assetList = XC_DF_Asset.createAssets(3);
        //Asset Bundle
        assetList[0].AccountId = accntList[0].Id;
        assetList[0].ContactId = contList[0].Id;
        assetList[0].Name = 'Bundre Root';
        assetList[0].XC_Product_Type__c = Label.XC_CL_ProductTypeBundle;
        assetList[0].XC_Product_Subtype__c = 'Air conditioning';
        assetList[0].XC_BillingModel__c = '3 years renting';
        assetList[0].NE__Bundle__c = bundle.Id;
        assetList[0].Status = 'Active';
        
        //Assets Equipment
        assetList[1].AccountId = accntList[0].Id;
        assetList[1].ContactId = contList[0].Id;
        assetList[1].Name = 'Bundre Children Eqp 1';
        assetList[1].SerialNumber = 'BC-C12345 44';
        assetList[1].XC_Product_Type__c = Label.XC_CL_ProductTypeEquipment;
        assetList[1].XC_Product_Subtype__c = 'Air conditioning';
        assetList[1].XC_BillingModel__c = '3 years renting';
        assetList[1].NE__Bundle__c = bundle.Id;
        assetList[1].NE__ProdId__c = product.Id;
        assetList[1].Status = 'Active';
        
        assetList[2].AccountId = accntList[0].Id;
        assetList[2].ContactId = contList[0].Id;
        assetList[2].Name = 'Bundre Children Eqp 2';
        assetList[2].SerialNumber = 'XS008890 F2';
        assetList[2].XC_Product_Type__c = Label.XC_CL_ProductTypeEquipment;
        assetList[2].XC_Product_Subtype__c = 'Air conditioning';
        assetList[2].XC_BillingModel__c = '3 years renting';
        assetList[2].NE__Bundle__c = bundle.Id;
        assetList[2].NE__ProdId__c = product.Id;
        assetList[2].Status = 'Active';
        
        insert assetList;
        assetList[1].NE__Bundle_Configuration__c = assetList[0].Id;
        assetList[2].NE__Bundle_Configuration__c = assetList[0].Id;
        update assetList;
        
        List<Case> caseList= XC_DF_Case.createCases(1);
        caseList[0].Reason = 'XCMOT005';
        caseList[0].SubCause__c = 'ATCL070';
        caseList[0].XC_Subtype__c = 'XC069';
        caseList[0].XC_CompliantApplicable__c = true;
        caseList[0].AccountId = accntList[0].Id;
        caseList[0].ContactId = contList[0].Id;
        caseList[0].AssetId = assetList[0].Id;
        caseList[0].XC_LegalEntity__c = 'EndesaX';
        Test.startTest();
        	insert caseList;
        	caseList[0].AssetId = assetList[1].Id;
        	update caseList;
        	Case caso = [SELECT Id, XC_AssetListDetails__c FROM Case WHERE Id =: caseList[0].Id];
        	System.assert(String.isNotBlank(caso.XC_AssetListDetails__c));
        Test.stopTest();
    }*/
}