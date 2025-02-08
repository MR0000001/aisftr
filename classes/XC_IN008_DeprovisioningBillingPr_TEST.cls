/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 31/05/2019
* @date Modification dd/mm/yyyy
* @description  – XC_IN008_DeprovisioningBillingPr_TEST - Test class for XC_IN008_DeprovisioningBillingPr
*/ 
@isTest
public class XC_IN008_DeprovisioningBillingPr_TEST {
        /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation  31/05/2019 
    * @description insert records
    */ 
    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        
    }
    
    static testMethod void callExecutePaymentTEST(){      
        test.startTest();
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
        zQuote.zqu__Status__c = 'Sent to Z-Billing';
        zQuote.zqu__ZuoraSubscriptionID__c = '587125493261636';
        insert zQuote;
        
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(5);
        NE__OrderItem__c ordItFather = orderItemList[1];
        ordItFather.NE__Bundle_Configuration__c = null;
        ordItFather.NE__AssetItemEnterpriseId__c = astEnterprise.Id;
        insert ordItFather;
        test.stopTest();
        NE__OrderItem__c ordIt = orderItemList[0];
        ordIt.NE__OrderId__c = ordItFather.NE__OrderId__c;
        ordIt.NE__Bundle_Configuration__c = ordItFather.Id;
        ordIt.NE__AssetItemEnterpriseId__c = astEnterprise.Id;
        ordIt.NE__Parent_Order_Item__c = ordItFather.Id;
        ordIt.XC_ZQuoteId__c = zQuote.Id;
        insert ordIt;
        
       astEnterprise.XC_Configuration_Item__c = ordIt.Id;
        astEnterprise.XC_Original_Configuration_Item__c = ordIt.Id;
        update astEnterprise;
        NE__OrderItem__c ordItPenalty = orderItemList[2];
        ordItPenalty.NE__OrderId__c = ordItFather.NE__OrderId__c;
        ordItPenalty.NE__Bundle_Configuration__c = ordItFather.Id;
        ordItPenalty.NE__AssetItemEnterpriseId__c = astEnterprise.Id;
        ordItPenalty.NE__Parent_Order_Item__c = ordItFather.Id;
        ordItPenalty.NE__ProdId__c = product.Id; 
        insert ordItPenalty;

        
        
        NE__OrderItem__c ordItQuote = orderItemList[4];
        ordItQuote.XC_ZQuoteId__c = zQuote.Id;
        insert ordItQuote;
         
        
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep;
        
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c WHERE XC_Step_Order__c =1 LIMIT 1];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN008_DeprovisioningBillingProcess.InputWrapper inw = new XC_IN008_DeprovisioningBillingProcess.InputWrapper();
        List<XC_IN008_DeprovisioningBillingProcess.InputWrapper> inputWrapperList = new List<XC_IN008_DeprovisioningBillingProcess.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
         
        XC_IN008_DeprovisioningBillingProcess.billingProcess(inputWrapperList);
        
        System.assertEquals(1, stepsList.size());
    }
    
    static testMethod void callExecutePaymentRethinkingTEST(){   
        test.startTest(); 
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
        zQuote.zqu__Status__c = 'Sent to Z-Billing';
        zQuote.zqu__ZuoraSubscriptionID__c = '587125493261636';
        insert zQuote;
         
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(5);
        NE__OrderItem__c ordItFather = orderItemList[1];
        ordItFather.NE__Bundle_Configuration__c = null;
        ordItFather.NE__AssetItemEnterpriseId__c = astEnterprise.Id;
        insert ordItFather;
        test.stopTest();
        
        NE__OrderItem__c ordItRethinking = orderItemList[3];
        ordItRethinking.XC_ZQuoteId__c = zQuote.Id;
        NE__Order__c orderRet = new NE__Order__c(Id= ordItRethinking.NE__OrderId__c);
        orderRet.NE__Type__c = 'Disconnection';
        orderRet.XC_Subtype__c = 'Rethinking';
        update orderRet;
        insert ordItRethinking;
        
        
        Asset ast = astList[1];
        ast.XC_Configuration_Item__c = ordItRethinking.Id;
        ast.XC_Original_Configuration_Item__c = ordItRethinking.Id;
        insert ast;
        
        ordItRethinking.NE__AssetItemEnterpriseId__c = ast.Id;
        ordItRethinking.NE__Bundle_Configuration__c = ordItFather.Id;
        update ordItRethinking;
        
        
        XC_Provisioning_Step__c provisioningStep2 = new XC_Provisioning_Step__c();
        provisioningStep2.XC_Configuration_Item__c = ordItRethinking.id;
        provisioningStep2.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep2.XC_Step_Order__c = 2;
        insert provisioningStep2;
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c WHERE XC_Step_Order__c =2 LIMIT 1];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN008_DeprovisioningBillingProcess.InputWrapper inw = new XC_IN008_DeprovisioningBillingProcess.InputWrapper();
        List<XC_IN008_DeprovisioningBillingProcess.InputWrapper> inputWrapperList = new List<XC_IN008_DeprovisioningBillingProcess.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        XC_IN008_DeprovisioningBillingProcess.billingProcess(inputWrapperList);
       
        System.assertEquals(1, stepsList.size());
    }
    
    @isTest
    static void testLog(){
        insert new XC_CS001_InterfaceConfiguration__c(Name = Label.XC_CL_ResumeSubscription, XC_activeInterface__c = true, XC_URL_Required__c  = 'https://rest.sandbox.eu.zuora.com/v1/subscriptions/subscriptionId/resume');
        XC_REST_ResumeSubscription.WrapperRequest wrReqResume = new XC_REST_ResumeSubscription.WrapperRequest();
        wrReqResume.legalEntity = 'EndesaX';
        wrReqResume.stream = 'B2C';
        String subscriptionId = '';
        XC_REST_ResumeSubscription.WrapperResponse wrRespResume = new XC_REST_ResumeSubscription.WrapperResponse();
        XC_IN008_DeprovisioningBillingProcess_U.insertIntegrationLog(wrReqResume, subscriptionId, wrRespResume);
    }

    @isTest
    static void testCoverage(){
        
        List<XC_REST_ZuoraCancelSubscription_U.WrapperResponse> wrList = new List<XC_REST_ZuoraCancelSubscription_U.WrapperResponse>();
        XC_REST_ZuoraCancelSubscription_U.WrapperResponse wr = new XC_REST_ZuoraCancelSubscription_U.WrapperResponse();
        wrList.add(wr);
        
        List<XC_Provisioning_Step__c> provisioningStepsToUpdate = new List<XC_Provisioning_Step__c>();
        List<NE__OrderItem__c> orderItemsToUpdate = new List<NE__OrderItem__c>();
        
        XC_IN008_DeprovisioningBillingProcess_U.updateProvisioningStepsAndConfigurationItem(wrList, provisioningStepsToUpdate, orderItemsToUpdate);
        
        XC_REST_ZuoraCancelSubscription_U.WrapperResponse abc = XC_IN008_DeprovisioningBillingProcess_U.callRethinking('abcdefg', 'EnelXItalia', 'B2C');
        
        
        Map<String, Object> parameters = new Map<String, Object>();
        XC_Provisioning_Step__c step = new XC_Provisioning_Step__c();
        List<zqu__Quote__c> zquoteToUpdate = new List<zqu__Quote__c>();
        XC_REST_ZuoraCancelSubscription_U.WrapperResponse kgb = new XC_REST_ZuoraCancelSubscription_U.WrapperResponse();
        parameters.put('wrResponse',kgb);
        Map<Id, String> mapConfItemZQuote = new Map<Id, String>();
		parameters.put('mapConfItemZQuote',mapConfItemZQuote);        
        XC_IN008_DeprovisioningBillingProcess_U.setStepStatusB2B(parameters, step, zquoteToUpdate);
        
        XC_REST_Disconnection.WrapperRequest wrapperDisconnection = new XC_REST_Disconnection.WrapperRequest();
        XC_REST_Disconnection.WrapperResponse kfc = XC_IN008_DeprovisioningBillingProcess_U.callDisconnection(wrapperDisconnection);
    }
    
     static testMethod void testCoverage2(){   
         test.startTest(); 
         List<NE__Product__c> productList = XC_DF_Product.createProducts(1);
         NE__Product__c product = productList[0];
         product.XC_Product_Subtype__c = 'Boiler';
         product.XC_Product_Type__c = 'Equipment';
         product.Name = Label.XC_CL_Asset_Penalty;
         insert product;
         List<Account> accList = XC_DF_Account.insertPartnerAccounts(1,'');
         Zuora__CustomerAccount__c ca1 = new Zuora__CustomerAccount__c(Zuora__Account__c = accList[0].Id, Zuora__Zuora_Id__c = '123', Zuora__External_Id__c = '123');
         
          Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__OriginalId__c = '123',
                                                               Zuora__PreviousSubscriptionId__c = '123',
                                                               Zuora__External_Id__c = '123',
                                                                  Zuora__Status__c = 'Suspended',
                                                               Zuora__CustomerAccount__c = ca1.Id,
                                                               Zuora__SubscriptionNumber__c = 'SubName');
        insert sub;
         List<Asset> astList = XC_DF_Asset.createAssets(2);
         Asset astEnterprise = astList[0];
         astEnterprise.XC_SubscriptionName__c = 'SubName';
         astEnterprise.XC_Subscription__c = sub.Id;
         insert astEnterprise;
         
         
         zqu__Quote__c zQuote = new zqu__Quote__c();
         zQuote.zqu__Status__c = 'Suspended';
         zQuote.zqu__ZuoraSubscriptionID__c = '587125493261636';
         insert zQuote;
         
         List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(5);
         NE__OrderItem__c ordItFather = orderItemList[1];
         ordItFather.NE__Bundle_Configuration__c = null;
         ordItFather.NE__AssetItemEnterpriseId__c = astEnterprise.Id;
         insert ordItFather;
         test.stopTest();
         
         NE__OrderItem__c ordItRethinking = orderItemList[3];
         ordItRethinking.XC_ZQuoteId__c = zQuote.Id;
         
         NE__Order__c orderRet = new NE__Order__c(Id= ordItRethinking.NE__OrderId__c);
         orderRet.NE__Type__c = 'Disconnection';
         
         update orderRet;
         insert ordItRethinking;
         
         
         Asset ast = astList[1];
         ast.XC_Configuration_Item__c = ordItRethinking.Id;
         ast.XC_Original_Configuration_Item__c = ordItRethinking.Id;
          ast.XC_SubscriptionName__c = 'SubName';
         ast.XC_Subscription__c = sub.Id;
         insert ast;
         
         ordItRethinking.NE__AssetItemEnterpriseId__c = ast.Id;
         ordItRethinking.NE__Bundle_Configuration__c = ordItFather.Id;
         update ordItRethinking;
         
         
         XC_Provisioning_Step__c provisioningStep2 = new XC_Provisioning_Step__c();
         provisioningStep2.XC_Configuration_Item__c = ordItRethinking.id;
         provisioningStep2.XC_Status__c = Label.XC_CL_Completed_OK;
         provisioningStep2.XC_Step_Order__c = 2;
         insert provisioningStep2;
         List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c WHERE XC_Step_Order__c =2 LIMIT 1];
         XC_Provisioning_Step__c step = stepsList[0];
         
         XC_IN008_DeprovisioningBillingProcess.InputWrapper inw = new XC_IN008_DeprovisioningBillingProcess.InputWrapper();
         List<XC_IN008_DeprovisioningBillingProcess.InputWrapper> inputWrapperList = new List<XC_IN008_DeprovisioningBillingProcess.InputWrapper>();
         inw.stepId = step.Id;
         inputWrapperList.add(inw);
         
         XC_IN008_DeprovisioningBillingProcess.billingProcess(inputWrapperList);
         
         System.assertEquals(1, stepsList.size());
    }
    
}