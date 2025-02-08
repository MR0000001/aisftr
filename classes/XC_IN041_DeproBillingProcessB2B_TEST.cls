/**
* @author Daniele Lico - dlico@deloitte.it
* @date Creation 05/02/2020
* @date Modification dd/mm/yyyy
* @description  – XC_IN041_DeproBillingProcessB2B_TEST 
*/ 
@isTest
public class XC_IN041_DeproBillingProcessB2B_TEST {

    /**
    * @author Daniele Lico - dlico@deloitte.it
    * @date Creation  05/02/2020 
    * @description insert records
    */ 
    @TestSetup
    static void setup(){
      
        List<NE__Product__c> productList = XC_DF_Product.createProducts(1);
        NE__Product__c product = productList[0];
        product.XC_Product_Subtype__c = 'Boiler';
        product.XC_Product_Type__c = 'Equipment';
        product.Name = Label.XC_CL_Asset_Penalty;
        insert product;
        List<Asset> astList = XC_DF_Asset.createAssets(2);
        Asset astEnterprise = astList[0];
        insert astEnterprise;
        
        zqu__Quote__c zQuote = new zqu__Quote__c();
        zQuote.zqu__ZuoraSubscriptionID__c = '587125493261636';
        insert zQuote;
        
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(5);
        NE__OrderItem__c ordItFather = orderItemList[1];
        ordItFather.NE__AssetItemEnterpriseId__c = astEnterprise.Id;
        insert ordItFather;
        
        NE__OrderItem__c ordIt = orderItemList[0];
        ordIt.NE__Bundle_Configuration__c = ordItFather.Id;
        ordIt.NE__AssetItemEnterpriseId__c = astEnterprise.Id;
        ordIt.NE__Parent_Order_Item__c = ordItFather.Id;
        ordIt.XC_ZQuoteId__c = zQuote.Id;
        insert ordIt;
        
        astEnterprise.XC_Configuration_Item__c = ordIt.Id;
        astEnterprise.XC_Original_Configuration_Item__c = ordIt.Id;
        update astEnterprise;
        
        NE__OrderItem__c ordItPenalty = orderItemList[2];
        ordItPenalty.NE__Bundle_Configuration__c = ordItFather.Id;
        ordItPenalty.NE__AssetItemEnterpriseId__c = astEnterprise.Id;
        ordItPenalty.NE__Parent_Order_Item__c = ordItFather.Id;
        ordItPenalty.NE__ProdId__c = product.Id; 
        insert ordItPenalty;
        
        NE__OrderItem__c ordItRethinking = orderItemList[3];
        ordItRethinking.XC_ZQuoteId__c = zQuote.Id;
        NE__Order__c orderRet = new NE__Order__c(Id= ordItRethinking.NE__OrderId__c);
        orderRet.NE__Type__c = 'Disconnection';
        orderRet.XC_Subtype__c = 'Rethinking';
        update orderRet;
        insert ordItRethinking;
        
        NE__OrderItem__c ordItQuote = orderItemList[4];
        ordItQuote.XC_ZQuoteId__c = zQuote.Id;
        insert ordItQuote;
        
        Asset ast = astList[1];
        ast.XC_Configuration_Item__c = ordItRethinking.Id;
        ast.XC_Original_Configuration_Item__c = ordItRethinking.Id;
        insert ast;
        
        ordItRethinking.NE__AssetItemEnterpriseId__c = ast.Id;
        update ordItRethinking;
        
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep;
        
        XC_Provisioning_Step__c provisioningStep2 = new XC_Provisioning_Step__c();
        provisioningStep2.XC_Configuration_Item__c = ordItRethinking.id;
        provisioningStep2.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep2.XC_Step_Order__c = 2;
        insert provisioningStep2;
    }
    
    static testMethod void callExecutePaymentTEST(){        
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c WHERE XC_Step_Order__c =1];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN041_DeprovisioningBillingProcessB2B.InputWrapper inw = new XC_IN041_DeprovisioningBillingProcessB2B.InputWrapper();
        List<XC_IN041_DeprovisioningBillingProcessB2B.InputWrapper> inputWrapperList = new List<XC_IN041_DeprovisioningBillingProcessB2B.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN041_DeprovisioningBillingProcessB2B.billingProcess(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }
    
	static testMethod void callExecutePaymentRethinkingTEST(){        
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c WHERE XC_Step_Order__c =2];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN041_DeprovisioningBillingProcessB2B.InputWrapper inw = new XC_IN041_DeprovisioningBillingProcessB2B.InputWrapper();
        List<XC_IN041_DeprovisioningBillingProcessB2B.InputWrapper> inputWrapperList = new List<XC_IN041_DeprovisioningBillingProcessB2B.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN041_DeprovisioningBillingProcessB2B.billingProcess(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }

}