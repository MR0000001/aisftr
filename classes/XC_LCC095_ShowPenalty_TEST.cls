/**
 * @author Sara Miozza - sara.miozza@nttdata.com
 * @date Creation 21/05/2019
 * @date Modification dd/mm/yyyy
 * @description XC_LCC095_ShowPenalty_TEST - test class for XC_LCC095_ShowPenalty.
 */

@isTest
public class XC_LCC095_ShowPenalty_TEST {

    @TestSetup
    static void setup(){

        List<NE__Bundle__c> listBundle = XC_DF_Bundle.createBundleRecords(1);
        insert listBundle;

        List<NE__Product__c> listProducts = XC_DF_Product.createProducts(1);
        listProducts[0].XC_Product_SubType__c = 'Bundle';
        listProducts[0].XC_Product_Type__c = 'Bundle';
        insert listProducts;
        
        List<Account> listAccount = XC_DF_Account.createResidentialAccounts(1);
        listAccount[0].IdentityNumber__c='332' + Integer.valueOf(Math.random() * Math.random()) + '3173'+ Integer.valueOf(Math.random() * Math.random());
        insert listAccount;

        List<XC_Address__c> addressList = XC_DF_Address.createAddress(listAccount);
        insert addressList;

        List<Asset> listAsset = XC_DF_Asset.createAssetWithBundleRecords(listProducts, listBundle[0], addressList[0]);
        listAsset[0].Name ='Modelo de Pago';
        listAsset[0].AccountId = listAccount[0].Id;
        insert listAsset;

        List<Asset> listChildAsset = XC_DF_Asset.createAssetWithBundleRecords(listProducts, listBundle[0], addressList[0]);
        listChildAsset[0].AccountId = listAccount[0].Id;
        for(Asset a : listChildAsset) {
            a.parentId = listAsset[0].Id;
        }
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

    }

    @isTest static void showPenaltyTEST() {
    
        Asset a = [SELECT Id, NE__Status__c,NE__ProdId__c, NE__ProdId__r.Name, NE__Bundle__r.Name, NE__Activation_Date__c,
                                            XC_Address__r.XC_PricinRegion__c,
                                            (SELECT ID, name, NE__Value__c FROM NE__AssetItemAttributes__r 
                                            WHERE Name LIKE 'Modalidad de contratacion%' OR
                                                  Name = 'Modelo de Pago'
                                            LIMIT 1) 
                                    FROM Asset 
                                    WHERE parentId = ''
                                    LIMIT 1];

        System.debug('### test ###' +a);

        Test.startTest();
            XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper calcWr = XC_UTIL_PenaltyRefundCalculation.getCalculationInput(a.Id, 'Rethinking', Date.today());
        	XC_UTIL_ResultWrapper wr = XC_LCC095_ShowPenalty.showPenalty(calcWr);
        Test.stopTest();

        System.assert(wr.success == true);
    }

    @isTest static void showPenaltyTEST2() {
    
        Asset a = [SELECT Id, NE__Status__c,NE__ProdId__c, NE__ProdId__r.Name, NE__Bundle__r.Name, NE__Activation_Date__c,
                                            XC_Address__r.XC_PricinRegion__c,
                                            (SELECT ID, name, NE__Value__c FROM NE__AssetItemAttributes__r 
                                            WHERE Name LIKE 'Modalidad de contratacion%' OR
                                                  Name = 'Modelo de Pago'
                                            LIMIT 1) 
                                    FROM Asset 
                                    LIMIT 1];
        a.Status = 'In progress';
        update a;

        Test.startTest();
            XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper calcWr = XC_UTIL_PenaltyRefundCalculation.getCalculationInput(a.Id, 'Rethinking', Date.today());
        	XC_UTIL_ResultWrapper wr = XC_LCC095_ShowPenalty.showPenalty(calcWr);
        Test.stopTest();

        System.assert(wr.success == true);
    }
    
    @isTest static void showPenaltyTEST3New() {
        
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        accounts[0].IdentityNumber__c='331' + Integer.valueOf(Math.random() * Math.random()) + '3183'+ Integer.valueOf(Math.random() * Math.random());
        insert accounts;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        insert contacts;
        
        NE__Catalog__c catalog = new NE__Catalog__c(XC_LIC_Name__c = Label.XC_CL_Catalog_eHome, Name =Label.XC_CL_Catalog_eHome );
        insert catalog;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].AccountId = accounts[0].Id;
        assetList[0].ContactId = contacts[0].Id;
        assetList[0].Status = 'Active';
        assetList[0].XC_ActivationDate__c = Date.today();
        assetList[0].NE__Catalog__c = catalog.Id;
        insert assetList;
        
        Test.startTest();
            XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper prcWr = XC_UTIL_PenaltyRefundCalculation.getCalculationInput(assetList[0].Id, 'Rethinking', Date.today());
            XC_UTIL_ResultWrapper wr = XC_LCC095_ShowPenalty.showPenalty(prcWr);
        Test.stopTest();

        System.assert(wr.success == true);
    }
    
    @isTest static void showPenaltyTEST4New() {
        List<NE__Bundle__c> listBundle = XC_DF_Bundle.createBundleRecords(1);
        insert listBundle;

        List<NE__Product__c> listProducts = XC_DF_Product.createProducts(1);
        listProducts[0].XC_Product_SubType__c = 'Bundle';
        listProducts[0].XC_Product_Type__c = 'Bundle';
        listProducts[0].Name= 'eHome_SPA_SetPrice';
        listProducts[0].XC_LIC_Product_Name__c= 'eHome_SPA_SetPrice';
        insert listProducts;
        
        List<Account> listAccount = XC_DF_Account.createResidentialAccounts(1);
        listAccount[0].IdentityNumber__c='334' + Integer.valueOf(Math.random() * Math.random()) + '1173'+ Integer.valueOf(Math.random() * Math.random());
        insert listAccount;

        List<XC_Address__c> addressList = XC_DF_Address.createAddress(listAccount);
        insert addressList;

        List<Asset> listAsset = XC_DF_Asset.createAssetWithBundleRecords(listProducts, listBundle[0], addressList[0]);
        listAsset[0].Name ='eHome_SPA_SetPrice';
        listAsset[0].XC_BillingModel__c = '3 years renting';
        listAsset[0].AccountId = listAccount[0].Id;
        
        insert listAsset;

        List<Asset> listChildAsset = XC_DF_Asset.createAssetWithBundleRecords(listProducts, listBundle[0], addressList[0]);
        listChildAsset[0].AccountId = listAccount[0].Id;
        for(Asset a : listChildAsset) {
            a.parentId = listAsset[0].Id;
        }
        insert listChildAsset;
        
        listAsset[0].InstallDate = Date.today();
        listAsset[0].NE__Activation_Date__c = Date.today();
        listAsset[0].XC_ActivationDate__c = Date.today();
        update listAsset;

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
            //prcWr.billingMethod = Label.XC_CL_DiscBillMethod_PayRestOfTheYear;
            XC_UTIL_ResultWrapper wr = XC_LCC095_ShowPenalty.showPenalty(prcWr);
        Test.stopTest();

        System.assert(wr.success == true);
        
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

    @isTest static void showPenaltyTEST3() {
        Asset a = [SELECT Id, NE__Status__c,NE__ProdId__c, NE__ProdId__r.Name, NE__Bundle__r.Name, NE__Activation_Date__c,
                                        XC_Address__r.XC_PricinRegion__c,
                                        (SELECT ID, name, NE__Value__c FROM NE__AssetItemAttributes__r 
                                        WHERE Name LIKE 'Modalidad de contratacion%' OR
                                              Name = 'Modelo de Pago'
                                        LIMIT 1) 
                                FROM Asset 
                                LIMIT 1];
        List<NE__AssetItemAttribute__c> listAttr = [SELECT ID, Name, NE__Value__c FROM NE__AssetItemAttribute__c];
        delete listAttr;

        Test.startTest();
            XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper calcWr = XC_UTIL_PenaltyRefundCalculation.getCalculationInput(a.Id, 'Rethinking', Date.today());
            XC_UTIL_ResultWrapper wr = XC_LCC095_ShowPenalty.showPenalty(calcWr);
        Test.stopTest();

        System.assert(wr.success == true);
    }
    
    @isTest static void showPenaltyTEST4() {
        Asset a = [SELECT Id, NE__Status__c,NE__ProdId__c, NE__ProdId__r.Name, NE__Bundle__r.Name, NE__Activation_Date__c,
                                        XC_Address__r.XC_PricinRegion__c,
                                        (SELECT ID, name, NE__Value__c FROM NE__AssetItemAttributes__r 
                                        WHERE Name LIKE 'Modalidad de contratacion%' OR
                                              Name = 'Modelo de Pago'
                                        LIMIT 1) 
                                FROM Asset 
                                LIMIT 1];
        List<NE__Matrix_Parameter_Row__c> listMatrixRows = [SELECT ID, XC_Offline_Name_07__c, XC_Offline_Value_07__c,
                                                                    XC_Offline_Name_08__c, XC_Offline_Value_08__c,
                                                                    XC_Offline_Name_09__c, XC_Offline_Value_09__c,
                                                                    XC_Offline_Name_10__c, XC_Offline_Value_10__c,
                                                                    XC_Offline_Name_11__c, XC_Offline_Value_11__c,
                                                                    XC_Offline_Name_12__c, XC_Offline_Value_12__c,
                                                                    XC_Offline_Name_13__c, XC_Offline_Value_13__c
                                                                    FROM NE__Matrix_Parameter_Row__c];
        NE__Matrix_Parameter_Row__c row = listMatrixRows[0];
        row.XC_Offline_Name_07__c = '';
        row.XC_Offline_Value_07__c =  '';
        row.XC_Offline_Name_08__c = '';
        row.XC_Offline_Value_08__c = '';
        row.XC_Offline_Name_09__c =  '';
        row.XC_Offline_Value_09__c =  '';
        row.XC_Offline_Name_10__c =  '';
        row.XC_Offline_Value_10__c =  '';
        row.XC_Offline_Name_11__c =  '';
        row.XC_Offline_Value_11__c =  '';
        row.XC_Offline_Name_12__c =  '';
        row.XC_Offline_Value_12__c =  '';
        row.XC_Offline_Name_13__c =  '';
        row.XC_Offline_Value_13__c =  '';
        update listMatrixRows;

        Test.startTest();
            XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper calcWr = XC_UTIL_PenaltyRefundCalculation.getCalculationInput(a.Id, 'Rethinking', Date.today());
            XC_UTIL_ResultWrapper wr = XC_LCC095_ShowPenalty.showPenalty(calcWr);
        Test.stopTest();

        System.assert(wr.success == true);
    }
    
    @isTest static void showPenaltyTEST5() {
        Asset a = [SELECT Id, NE__Status__c,NE__ProdId__c, NE__ProdId__r.Name, NE__Bundle__r.Name, NE__Activation_Date__c,
                                        XC_Address__r.XC_PricinRegion__c,
                                        (SELECT ID, name, NE__Value__c FROM NE__AssetItemAttributes__r 
                                        WHERE Name LIKE 'Modalidad de contratacion%' OR
                                              Name = 'Modelo de Pago'
                                        LIMIT 1) 
                                FROM Asset 
                                LIMIT 1];
        a.XC_ActivationDate__c = Date.today() - 12;
        update a;

        Test.startTest();
            XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper calcWr = XC_UTIL_PenaltyRefundCalculation.getCalculationInput(a.Id, 'Rethinking', Date.today());
            XC_UTIL_ResultWrapper wr = XC_LCC095_ShowPenalty.showPenalty(calcWr);
        Test.stopTest();

        System.assert(wr.success == true);
    }
	
    @isTest static void showPenalty_NoPenalty() {
        
        List<Asset> a = [SELECT Id, NE__Status__c,NE__ProdId__c, NE__ProdId__r.Name, NE__Bundle__r.Name, NE__Activation_Date__c,
                                        XC_Address__r.XC_PricinRegion__c,
                                        (SELECT ID, name, NE__Value__c FROM NE__AssetItemAttributes__r 
                                        WHERE Name LIKE 'Modalidad de contratacion%' OR
                                              Name = 'Modelo de Pago'
                                        LIMIT 1) 
                                FROM Asset 
                                LIMIT 1];
        String assetId = a[0].Id;

        Test.startTest();
            XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper calcWr = XC_UTIL_PenaltyRefundCalculation.getCalculationInput(assetId, 'Complaint', Date.today());
        	XC_CM_DisconnectBillingMethod__mdt mtd = new XC_CM_DisconnectBillingMethod__mdt();
        	mtd.XC_BillingMethod__c = Label.XC_CL_DiscBillMethod_NoPenalty;
        	calcWr.billingMethod = mtd;
            XC_UTIL_ResultWrapper wr = XC_LCC095_ShowPenalty.showPenalty(calcWr);
        Test.stopTest();

        System.assert(wr.success == true);
    }
    
	
    @isTest static void showOptions() {
        
        List<Asset> a = [SELECT Id, NE__Status__c,NE__ProdId__c, NE__ProdId__r.Name, NE__Bundle__r.Name, NE__Activation_Date__c,
                                        XC_Address__r.XC_PricinRegion__c,
                                        (SELECT ID, name, NE__Value__c FROM NE__AssetItemAttributes__r 
                                        WHERE Name LIKE 'Modalidad de contratacion%' OR
                                              Name = 'Modelo de Pago'
                                        LIMIT 1) 
                                FROM Asset 
                                LIMIT 1];
        String assetId = a[0].Id;

        Test.startTest();
            XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper calcWr = XC_UTIL_PenaltyRefundCalculation.getCalculationInput(assetId, 'Accept Purchase Option - End Contract', Date.today());
        	XC_CM_DisconnectBillingMethod__mdt mtd = new XC_CM_DisconnectBillingMethod__mdt();
        	mtd.XC_BillingMethod__c = Label.XC_CL_DiscBillMethod_PurchaseOption;
        	calcWr.billingMethod = mtd;
            XC_UTIL_ResultWrapper wr = XC_LCC095_ShowPenalty.showPenalty(calcWr);
        Test.stopTest();

        System.assert(wr.success == true);
    }
    
    @isTest static void computeAmount() {
		//Map<Integer, AmountInfo> mapEndAmounts, Double months
		Map<Integer, List<XC_LCC095_ShowPenalty.AmountInfo>> mapEndAmounts = new Map<Integer, List<XC_LCC095_ShowPenalty.AmountInfo>>();
        XC_LCC095_ShowPenalty.AmountInfo am1 = new XC_LCC095_ShowPenalty.AmountInfo();
        am1.amountValue = '100';
        am1.amountKind = XC_LCC095_ShowPenalty.AmountB2wKind.PENALTY;
        mapEndAmounts.put(6,new List<XC_LCC095_ShowPenalty.AmountInfo>{am1});
        XC_LCC095_ShowPenalty.AmountInfo am2 = new XC_LCC095_ShowPenalty.AmountInfo();
        am2.amountValue = '50';
        am2.amountKind = XC_LCC095_ShowPenalty.AmountB2wKind.UNISTALL;
        mapEndAmounts.put(0,new List<XC_LCC095_ShowPenalty.AmountInfo>{am2});
        
        Test.startTest();
        	List<XC_LCC095_ShowPenalty.AmountResult> res = XC_LCC095_ShowPenalty.computeAmounts(mapEndAmounts, 6, XC_LCC095_ShowPenalty.UnistallmentCostsPolicy.WITH_UNISTALL);
        Test.stopTest();

        //System.assert(String.valueOf(res[0].totalAmount) == '150');
        System.assert(res != null);
    }
    
    /*@isTest static void showPenaltyTEST6() {
        List<Asset> a = [SELECT Id, NE__Status__c,NE__ProdId__c, NE__ProdId__r.Name, NE__Bundle__r.Name, NE__Activation_Date__c,
                                        XC_Address__r.XC_PricinRegion__c,
                                        (SELECT ID, name, NE__Value__c FROM NE__AssetItemAttributes__r 
                                        WHERE Name LIKE 'Modalidad de contratacion%' OR
                                              Name = 'Modelo de Pago'
                                        LIMIT 1) 
                                FROM Asset WHERE parentId != ''
                                LIMIT 1];
        String assetId = a[0].Id;
        //delete a;

        Test.startTest();
            XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper calcWr = XC_UTIL_PenaltyRefundCalculation.getCalculationInput(assetId, 'Rethinking', Date.today());
            XC_UTIL_ResultWrapper wr = XC_LCC095_ShowPenalty.showPenalty(calcWr);
        Test.stopTest();

        System.assert(wr.success == true);
    }*/
}