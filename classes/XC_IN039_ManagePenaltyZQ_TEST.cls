/**
*@author Francesco Imperioli - fimperioli@deloitte.it
*@description test class for XC_IN039_ManagePenaltyZQuote Class
*@creation 23/12/2019
*/
@isTest
public  class XC_IN039_ManagePenaltyZQ_TEST {

    @TestSetup
    static void setup(){

        NE__Order__c  ord = XC_DF_Order.createOrder('InOrder');
        

        NE__Product__c penaltyProd = XC_DF_Product.createProducts(1)[0];
        penaltyProd.Name = Label.XC_CL_Asset_Penalty;
        penaltyProd.XC_LIC_Product_Name__c = Label.XC_CL_Asset_Penalty;
        insert penaltyProd;

        NE__Catalog_Item__c catItem = XC_DF_CatalogItem.createCatalogItem();
        catItem.NE__ProductId__c = penaltyProd.Id;
        insert catItem;

        NE__OrderItem__c parentOi = XC_DF_OrderItem.createOrderItem(ord);
        parentOi.NE__OrderId__c = ord.Id;
        parentOi.XC_Wbe__c = '123456789101214151728242';
        insert parentOi;

        NE__OrderItem__c oiPenalty = XC_DF_OrderItem.createOrderItem(ord);
        oiPenalty.NE__CatalogItem__c = catItem.Id;
        oiPenalty.NE__Parent_Order_Item__c = parentOi.Id;
        oiPenalty.NE__OneTimeFeeOv__c = 350;
        oiPenalty.NE__OrderId__c = ord.Id;
        insert oiPenalty;

        Asset penaltyAsset = XC_DF_Asset.createAssets(1)[0];
        penaltyAsset.XC_Configuration_Item__c = oiPenalty.Id;
        penaltyAsset.NE__ProdId__c = penaltyProd.Id;
        penaltyAsset.NE__Order_Config__c = ord.Id;
        penaltyAsset.Name = Label.XC_CL_Asset_Penalty;

        XC_Provisioning_Step__c stepToInsert = XC_DF_ProvisioningStep.createProvisioningStep(parentOi.Id);
        insert stepToInsert;

    }

    @isTest
    static void managePenaltyZQuoteTest(){
        
        XC_Provisioning_Step__c provStep = [SELECT ID FROM XC_Provisioning_Step__c LIMIT 1];

        XC_IN039_ManagePenaltyZQuote.InputWrapper wrap =  new XC_IN039_ManagePenaltyZQuote.InputWrapper();
        wrap.stepId = provStep.Id;
        List<XC_IN039_ManagePenaltyZQuote.InputWrapper> inputList = new List<XC_IN039_ManagePenaltyZQuote.InputWrapper> {wrap};
        Test.startTest();
            XC_IN039_ManagePenaltyZQuote.managePenaltyZQuote(inputList);
        Test.stopTest();
    }




}