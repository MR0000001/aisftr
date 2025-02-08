/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation 21/05/2019 
* @description XC_LCC098_ShowPurchaseCost_TEST – Test class for XC_LCC098_ShowPurchaseCost
*/
@isTest
public class XC_LCC098_ShowPurchaseCost_TEST {
    //Test Method showCost
  /*  static testMethod void showCost(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
       
        
        List<Asset> lista = XC_DF_Asset.createAssets(1);
        insert lista;
        
        Test.startTest();
        XC_UTIL_ResultWrapper rw = XC_LCC098_ShowPurchaseCost.showCost(lista[0].Id);
        System.assertEquals(true, rw!=null);
        Test.stopTest();
    }*/
    
    @TestSetup
    private static void setup(){
        List<NE__Bundle__c> listBundle = XC_DF_Bundle.createBundleRecords(1);
        insert listBundle;

        List<NE__Product__c> listProducts = XC_DF_Product.createProducts(1);
        listProducts[0].XC_Product_SubType__c = 'Bundle';
        listProducts[0].XC_Product_Type__c = 'Bundle';
        insert listProducts;
        
        List<Account> listAccount = XC_DF_Account.createResidentialAccounts(1);
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

    static testMethod void showCostA(){
        insert XC_DF_OneOrg.createOneOrg('Spain');

        List<Asset> lista = XC_DF_Asset.createAssets(1);
        insert lista;
        lista[0].Status = 'Active';
        update lista;
        
        Test.startTest();
        XC_UTIL_ResultWrapper rw = XC_LCC098_ShowPurchaseCost.showCost(lista[0].Id);
        System.assertEquals(true, rw!=null);
        Test.stopTest();
    }
        //lista[0].XC_ActivationDate__c = Date.today();
       /* lista[0].Status = 'Active';
        update lista;
        
        rw = XC_LCC098_ShowPurchaseCost.showCost(lista[0].Id);
        
        NE__Matrix_Parameter__c matrixPara = new NE__Matrix_Parameter__c();
        insert matrixPara;
        
        List<NE__Matrix_Parameter_Row__c> listmat = new List<NE__Matrix_Parameter_Row__c>();
        NE__Matrix_Parameter_Row__c mat = new NE__Matrix_Parameter_Row__c();
        mat.XC_Offline_Name_01__c= 'test';
        mat.XC_Value1__c ='Bandoleiro';
        mat.Product_LIC_Name__c = 'Soluciones Caldera';
        mat.XC_Payment_Model__c= 'Credit Card';
        mat.XC_Region__c= 'Las Palmas';
        mat.NE__Matrix_Parameter__c = matrixPara.Id;
        mat.XC_Rule_type__c = 'DomainElegibility';
        //mat.XC_Offline_Name_01__c= 'Otp_7Y_6M (€)';
        //mat.XC_Offline_Name_02__c= 'Otp_7Y_6M_12M (€)';
        //mat.XC_Offline_Name_03__c= 'Otp_7Y_12M_18M (€)';
        listmat.add(mat);
        
        insert listmat;
        
        rw = XC_LCC098_ShowPurchaseCost.showCost(lista[0].Id);
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    //Test Method showCost2 insert 
   /* static testMethod void showCost2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');

        List<NE__Product__c> proList = XC_DF_Product.createProducts(1);
        proList[0].XC_Product_Subtype__c ='Wallbox';
        proList[0].XC_Product_Type__c= 'Equipment';
        insert proList;
        
        List<NE__Bundle__c> bundle = XC_DF_Bundle.createBundleRecords(1);
        bundle[0].Name ='Soluciones Caldera';
        insert bundle;
        
        List<XC_Address__c> address = XC_DF_Address.createAddress(1);
        address[0].XC_AddressProvince__c = 'Las Palmas';
        
        insert address;
        
        List<Contact> listcont = XC_DF_Contact.createResidentialContacts(1);
        insert listcont;
        
        List<Asset> lista = XC_DF_Asset.createAssetWithBundleRecords(proList,bundle[0],address[0]);
        lista[0].Name ='TEST';
        lista[0].XC_ActivationDate__c = Date.today();
        lista[0].NE__Bundle__c = bundle[0].Id;
        lista[0].ContactId = listcont[0].Id;
        insert lista;
        
        NE__AssetItemAttribute__c AssetItem = new NE__AssetItemAttribute__c();
        AssetItem.NE__Value__c='One shot'; 
        AssetItem.NE__Asset__c =lista[0].Id;
        insert AssetItem;
        
        lista[0].Status = 'Active';
        update lista;
        
        NE__Matrix_Parameter__c matrixPara = new NE__Matrix_Parameter__c();
        insert matrixPara;
        List<NE__Matrix_Parameter_Row__c> listmat = new List<NE__Matrix_Parameter_Row__c>();
        NE__Matrix_Parameter_Row__c mat = new NE__Matrix_Parameter_Row__c();
        mat.XC_Offline_Name_01__c= 'test';
        mat.XC_Value1__c ='Bandoleiro';
        mat.Product_LIC_Name__c = 'TEST';
        mat.XC_Payment_Model__c= 'One shot';
        mat.XC_Region__c= 'Canarias';
        mat.NE__Matrix_Parameter__c = matrixPara.Id;
        mat.XC_Rule_type__c = 'DomainElegibility';
        listmat.add(mat);
        
        insert listmat;
        
        //system.debug('megatest: '+lista[0].NE__AssetItemAttributes__r[0].NE__Value__c);
        
        Test.startTest();
        XC_UTIL_ResultWrapper rw = XC_LCC098_ShowPurchaseCost.showCost(lista[0].Id);
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }*/
  //////////////////////// divisione insert /////////////////////////////////////////////   
   
        //lista[0].XC_ActivationDate__c = Date.today();
       /* lista[0].Status = 'Active';
        update lista;
        
        rw = XC_LCC098_ShowPurchaseCost.showCost(lista[0].Id);
        
        NE__Matrix_Parameter__c matrixPara = new NE__Matrix_Parameter__c();
        insert matrixPara;
        
        List<NE__Matrix_Parameter_Row__c> listmat = new List<NE__Matrix_Parameter_Row__c>();
        NE__Matrix_Parameter_Row__c mat = new NE__Matrix_Parameter_Row__c();
        mat.XC_Offline_Name_01__c= 'test';
        mat.XC_Value1__c ='Bandoleiro';
        mat.Product_LIC_Name__c = 'TEST';
        mat.XC_Payment_Model__c= 'One shot';
        mat.XC_Region__c= 'Canarias';
        mat.NE__Matrix_Parameter__c = matrixPara.Id;
        mat.XC_Rule_type__c = 'DomainElegibility';
        //mat.XC_Offline_Name_01__c= 'Otp_7Y_6M (€)';
        //mat.XC_Offline_Name_02__c= 'Otp_7Y_6M_12M (€)';
        //mat.XC_Offline_Name_03__c= 'Otp_7Y_12M_18M (€)';
        listmat.add(mat);
        
        insert listmat;
        system.debug('@@@@@@@@@@@@@'+ [SELECT Id, XC_Value1__c, Product_LIC_Name__c, XC_Payment_Model__c,
                                       XC_Region__c
                                       
                                       FROM NE__Matrix_Parameter_Row__c ]);
        
        rw = XC_LCC098_ShowPurchaseCost.showCost(lista[0].Id);
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }*/
    
    //Test Method showCost1
    static testMethod void showCost1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        
        NE__Bundle__c bun = new NE__Bundle__c();
        bun.Name = 'test';
        bun.NE__RecurringChargeFrequency__c='Monthly';
        bun.NE__BaseRecurringCharge__c=0;
        bun.NE__Start_Date__c= Date.today();
        
        insert bun;
        
        List<Asset> lista = XC_DF_Asset.createAssets(1);
        lista[0].NE__Bundle__c = bun.Id;
        insert lista;
        
        NE__AssetItemAttribute__c aia = new NE__AssetItemAttribute__c();
        aia.Name = 'Modelo de Pago';
        aia.NE__Value__c='One shot';
        aia.NE__Asset__c= lista[0].Id;
        insert aia;
        
        update lista;
        
        /*NE__Matrix_Parameter_Row__c mpr = new NE__Matrix_Parameter_Row__c();
mpr.XC_Value1__c ='test';
mpr.Product_LIC_Name__c =

System.assertEquals(true, rw!=null);*/
        
        Test.startTest();
        XC_UTIL_ResultWrapper rw = XC_LCC098_ShowPurchaseCost.showCost(lista[0].Id);
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
    
    //Test Method computePenalties
    static testMethod void computePenalties(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Map<Integer, String> maps = new Map<Integer, String>();
        maps.put(2,'2');
        
        Test.startTest();
        Integer inte = XC_LCC098_ShowPurchaseCost.computePenalties(maps,2);
        System.assertEquals(true, inte!=null);
        Test.stopTest();
        
    }
    
    //Test Method createListMapPenalties
    static testMethod void createListMapPenalties(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        
        List<NE__Matrix_Parameter_Row__c> listmat = new List<NE__Matrix_Parameter_Row__c>();
        NE__Matrix_Parameter_Row__c mat = new NE__Matrix_Parameter_Row__c();
        mat.XC_Offline_Name_01__c= 'test';
        //mat.XC_Offline_Name_01__c= 'Otp_7Y_6M (€)';
        //mat.XC_Offline_Name_02__c= 'Otp_7Y_6M_12M (€)';
        //mat.XC_Offline_Name_03__c= 'Otp_7Y_12M_18M (€)';
        listmat.add(mat);
        
        Test.startTest();
        List<Map<Integer, String>> listmap = XC_LCC098_ShowPurchaseCost.createListMapPenalties(listmat);
        System.assertEquals(true, listmap!=null);
        Test.stopTest();
        
    }
    //Test Method createListMapPenalties
    /*static testMethod void createListMapPenalties1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        
        List<NE__Matrix_Parameter_Row__c> listmat = new List<NE__Matrix_Parameter_Row__c>();
        NE__Matrix_Parameter_Row__c mat = new NE__Matrix_Parameter_Row__c();
        // mat.XC_Offline_Name_01__c= 'test';
        mat.XC_Offline_Name_01__c= 'Otp_7Y_6M (€)';
        //mat.XC_Offline_Name_02__c= 'Otp_7Y_6M_12M (€)';
        //mat.XC_Offline_Name_03__c= 'Otp_7Y_12M_18M (€)';
        listmat.add(mat);
        
        Test.startTest();
        List<Map<Integer, String>> listmap = XC_LCC098_ShowPurchaseCost.createListMapPenalties(listmat);
        try{
            listmap = XC_LCC098_ShowPurchaseCost.createListMapPenalties(listmat);
        }catch(exception e ){
            
            System.assert(e!=null);
        }
        
        System.assertEquals(true, listmap!=null);
        Test.stopTest();
        
    }*/
    
    @isTest
    private static void computeCostTEST() {
        	
		Asset a = [SELECT Id, NE__Status__c,NE__ProdId__c, NE__ProdId__r.Name, NE__Bundle__r.Name, NE__Activation_Date__c,
                                            XC_Address__r.XC_PricinRegion__c,
                                            (SELECT ID, name, NE__Value__c FROM NE__AssetItemAttributes__r 
                                            WHERE Name LIKE 'Modalidad de contratacion%' OR
                                                  Name = 'Modelo de Pago'
                                            LIMIT 1) 
                                    FROM Asset 
                                    LIMIT 1];
        a.Status = 'Active';
        update a;

        Test.startTest();
        	XC_UTIL_ResultWrapper wr = XC_LCC098_ShowPurchaseCost.showCost(a.Id);
        Test.stopTest();

        //System.assert(wr.success == false);
    }
    
}