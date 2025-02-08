@isTest
public class XC_UTIL_PenaltyRefundCalculation_TEST {
    
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
    
    @isTest static void showPenaltyByMonths_UTIL() {
        
        List<NE__Bundle__c> listBundle = XC_DF_Bundle.createBundleRecords(1);
        insert listBundle;

        List<NE__Product__c> listProducts = XC_DF_Product.createProducts(1);
        listProducts[0].XC_Product_SubType__c = 'Bundle';
        listProducts[0].XC_Product_Type__c = 'Bundle';
        listProducts[0].Name= 'eHome_SPA_SetPrice';
        insert listProducts;
        
        List<Account> listAccount = XC_DF_Account.createResidentialAccounts(1);
        listAccount[0].IdentityNumber__c='338' + Integer.valueOf(Math.random() * Math.random()) + '1103'+ Integer.valueOf(Math.random() * Math.random());
        insert listAccount;

        List<XC_Address__c> addressList = XC_DF_Address.createAddress(listAccount);
        insert addressList;

        List<Asset> listAsset = XC_DF_Asset.createAssetWithBundleRecords(listProducts, listBundle[0], addressList[0]);
        listAsset[0].Name ='eHome_SPA_SetPrice';
        listAsset[0].XC_BillingModel__c = '3 years renting';
        listAsset[0].AccountId = listAccount[0].Id;
        listAsset[0].NE__RecurringChargeOv__c = 20;
        
        insert listAsset;

        List<Asset> listChildAsset = XC_DF_Asset.createAssetWithBundleRecords(listProducts, listBundle[0], addressList[0]);
        listChildAsset[0].AccountId = listAccount[0].Id;
        for(Asset a : listChildAsset) {
            a.parentId = listAsset[0].Id;
        }
        listAsset[0].InstallDate = Date.today();
        listAsset[0].NE__Activation_Date__c = Date.today();
        listAsset[0].XC_ActivationDate__c = Date.today();
        insert listChildAsset;

        List<String> listAttributes = new List<String>();
        listAttributes.add('Modelo de Pago');
        listAttributes.add('Modalidad de contratacion');

        List<NE__AssetItemAttribute__c> listAtt = XC_DF_Asset.createAssetItemAttributes(listAsset, listAttributes);
        insert listAtt;

        List<NE__Matrix_Parameter__c> listMatrix = XC_DF_MatrixParameter.createMatrixParameter(1);
        insert listMatrix;

        List<NE__Matrix_Parameter_Row__c> listMatrixRows = XC_DF_MatrixParameter.createMatrixParameterRows(listMatrix[0], listAsset, listProducts, '3 years renting');
        insert listMatrixRows;
        System.debug(listMatrixRows[0]);
        
        Test.startTest();
            XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper prcWr = XC_UTIL_PenaltyRefundCalculation.getCalculationInput(listAsset[0].Id, 'Rethinking', Date.today());
            XC_UTIL_ResultWrapper wr = XC_UTIL_PenaltyRefundCalculation.showPenaltyByMonths(prcWr);
        Test.stopTest();

        System.assert(wr.success == true);
        
    }
}