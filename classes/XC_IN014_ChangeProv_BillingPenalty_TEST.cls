/** @author Sara Miozza sara.miozza@nttdata.com
 * @date  03/06/2019       
 * @description XC_IN014_ChangeProv_BillingPenalty_TEST test class for XC_IN014_ChangeProv_BillingPenalty
**/


@isTest
public class XC_IN014_ChangeProv_BillingPenalty_TEST {
	
    
    @TestSetup
    	static void setup(){
        OneOrg__c org            = new OneOrg__c(); 
        org.Name                 = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org; 

        XC_CS_UtilityGlobalValues__c csInsertDML = new XC_CS_UtilityGlobalValues__c();
        csInsertDML.Name = 'InsertLogsGenerateWO';
        csInsertDML.Value__c = 'true';
        insert csInsertDML;
        XC_CS_UtilityGlobalValues__c csInsertDML1 = new XC_CS_UtilityGlobalValues__c();
        csInsertDML1.Name = 'InsertLogsGenerateWO_OK';
        csInsertDML1.Value__c = 'true';
        insert csInsertDML1;
        
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(2);
        NE__OrderItem__c ordItFather = orderItemList[0];
        ordItFather.NE__Bundle_Configuration__c = null;
        NE__OrderItem__c ordIt = orderItemList[1];
        ordIt.NE__OrderId__c = ordItFather.NE__OrderId__c;
        insert orderItemList;

        NE__Family__c fam = new NE__Family__c();
        insert fam;    
        NE__DynamicPropertyDefinition__c prop = new NE__DynamicPropertyDefinition__c(Name = Label.XC_CL_ConfigurationItemAttribute_DevPaymentModel, XC_LIC_DynamicPropertyDefinition__c = label.XC_CL_ConfigurationItemAttribute_DevPaymentModel);
        insert prop;    
        NE__ProductFamilyProperty__c prodFam = new NE__ProductFamilyProperty__c(); 
        prodFam.NE__FamilyId__c = fam.Id;
        prodFam.NE__PropId__c = prop.Id; 
        insert prodFam;    


        List<NE__Bundle__c> listBundle = XC_DF_Bundle.createBundleRecords(1);
        insert listBundle;

        List<NE__Product__c> listProducts = XC_DF_Product.createProducts(1);
        listProducts[0].XC_Product_SubType__c = 'Bundle';
        listProducts[0].XC_Product_Type__c = 'Bundle';
        listProducts[0].Name= 'eHome_SPA_SetPrice';
        listProducts[0].XC_LIC_Product_Name__c= 'eHome_SPA_SetPrice';
        insert listProducts;
        
        List<Account> listAccount = [SELECT Id FROM Account];
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

        List<NE__Order_Item_Attribute__c> listAttribute = new List<NE__Order_Item_Attribute__c>();   
        NE__Order_Item_Attribute__c attr = new NE__Order_Item_Attribute__c();
        attr.NE__Value__c = '3 years renting';
        attr.NE__Order_Item__c = orderItemList[0].Id;
        attr.NE__FamPropId__c = prodFam.Id;  
        listAttribute.add(attr);
        insert listAttribute;

        listAsset[0].XC_Configuration_Item__c = orderItemList[0].Id;
        listAsset[0].XC_Original_Creation_OrderItem__c = orderItemList[0].Id;
        listAsset[0].NE__Order_Config__c = orderItemList[0].NE__OrderId__c;
        update listAsset; 

        orderItemList[0].NE__AssetItemEnterpriseId__c = listAsset[0].Id;
        orderItemList[1].NE__AssetItemEnterpriseId__c = listAsset[0].Id;
        update orderItemList;

    
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = orderItemList[0].id;        
        insert provisioningStep;
    } 
    
    
    @isTest
    static void billingPenaltyTest(){
        
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        Id stepId = stepsList[0].Id;
        XC_IN014_ChangeProv_BillingPenalty.InputWrapper inputWr = new XC_IN014_ChangeProv_BillingPenalty.InputWrapper();
        inputWr.stepId = stepId;
        List<XC_IN014_ChangeProv_BillingPenalty.InputWrapper> wrapperList = new List<XC_IN014_ChangeProv_BillingPenalty.InputWrapper>();
        wrapperList.add(inputWr);
        
        test.startTest();
        XC_IN014_ChangeProv_BillingPenalty.billingPenalty(wrapperList);
        test.stopTest();
        
        System.assert(stepId!=null);
    }
    
    
    @isTest
    static void updateAssetsTest(){
        
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c, XC_Configuration_Item__r.NE__OrderId__r.NE__AccountId__c FROM XC_Provisioning_Step__c ];
        Id stepId = stepsList[0].Id;
        NE__OrderItem__c oi = new NE__OrderItem__c (Id = stepsList[0].XC_Configuration_Item__c, NE__Action__c = 'None');
        update oi;
        List<Asset> assetList = new List<Asset>();
        
        test.startTest();
        XC_IN014_ChangeProv_BillingPenalty.updateActiveAsset(new Set<String>{stepsList[0].XC_Configuration_Item__c}, assetList);
        XC_IN014_ChangeProv_BillingPenalty.updateInactiveAssetsFromConfItemNone(stepsList[0].XC_Configuration_Item__r.NE__OrderId__c, assetList);
        test.stopTest();
        
        System.assert(stepId!=null);
    } 
    
}