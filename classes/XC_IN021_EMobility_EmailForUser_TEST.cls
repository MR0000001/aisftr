/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 31/05/2019
* @date Modification dd/mm/yyyy
* @description  – XC_IN021_EMobility_EmailForUser_TEST - Test class for XC_IN021_EMobility_EmailForUser
*/ 
@isTest
public class XC_IN021_EMobility_EmailForUser_TEST {
    /**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  17/05/2019 
* @description insert records
*/ 
    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<NE__Product__c> prodList = XC_DF_Product.createProducts(3);
        NE__Product__c product1 = prodList[0];
        product1.XC_LIC_Product_Name__c = 'Recharge';
        product1.XC_Product_Subtype__c = 'Solar Thermal';  	
        product1.XC_Product_Type__c = 'Equipment';
        NE__Product__c product2 = prodList[1];
        product2.XC_LIC_Product_Name__c = 'SABA';
        product2.XC_Product_Subtype__c = 'Solar Thermal';  	
        product2.XC_Product_Type__c = 'Equipment';
        NE__Product__c product3 = prodList[2];
        product3.XC_LIC_Product_Name__c = 'Rent';
       	product3.XC_Product_Subtype__c = 'Solar Thermal';  	
        product3.XC_Product_Type__c = 'Equipment';
        insert prodList;
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(3);
        NE__OrderItem__c ordIt1 = orderItemList[0];
        ordIt1.NE__ProdId__c = product1.Id;
        insert ordIt1;
        NE__OrderItem__c ordIt2 = orderItemList[1];
        ordIt2.NE__ProdId__c = product2.Id;
        insert ordIt2;
        NE__OrderItem__c ordIt3 = orderItemList[2];
        ordIt3.NE__ProdId__c = product3.Id;
        insert ordIt3;
        List<Asset> assetList = XC_DF_Asset.createAssets(3);
        Asset ast1 = assetList[0];
        ast1.XC_Configuration_Item__c = ordIt1.Id;
        insert ast1;
        Asset ast2 = assetList[1];
        ast2.XC_Configuration_Item__c = ordIt2.Id;
        insert ast2;
        Asset ast3 = assetList[2];
        ast3.XC_Configuration_Item__c = ordIt3.Id;
        insert ast3;
        XC_Provisioning_Step__c provisioningStep1 = new XC_Provisioning_Step__c();
        provisioningStep1.XC_Configuration_Item__c = ordIt1.id;
        provisioningStep1.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep1.XC_Step_Order__c = 1;
        insert provisioningStep1;
        
        XC_Provisioning_Step__c provisioningStep2 = new XC_Provisioning_Step__c();
        provisioningStep2.XC_Configuration_Item__c = ordIt2.id;
        provisioningStep2.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep2.XC_Step_Order__c = 2;
        insert provisioningStep2;
        
        XC_Provisioning_Step__c provisioningStep3 = new XC_Provisioning_Step__c();
        provisioningStep3.XC_Configuration_Item__c = ordIt3.id;
        provisioningStep3.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep3.XC_Step_Order__c = 3;
        insert provisioningStep3;
    }
    
    static testMethod void emailForUserCreationTEST(){        
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c WHERE XC_Step_Order__c = 1];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN021_EMobility_EmailForUserCreation.InputWrapper inw = new XC_IN021_EMobility_EmailForUserCreation.InputWrapper();
        List<XC_IN021_EMobility_EmailForUserCreation.InputWrapper> inputWrapperList = new List<XC_IN021_EMobility_EmailForUserCreation.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN021_EMobility_EmailForUserCreation.emailForUserCreation(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }
    
  	static testMethod void emailForUserCreationTEST2(){        
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c WHERE XC_Step_Order__c = 2];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN021_EMobility_EmailForUserCreation.InputWrapper inw = new XC_IN021_EMobility_EmailForUserCreation.InputWrapper();
        List<XC_IN021_EMobility_EmailForUserCreation.InputWrapper> inputWrapperList = new List<XC_IN021_EMobility_EmailForUserCreation.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN021_EMobility_EmailForUserCreation.emailForUserCreation(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }
    
  	static testMethod void emailForUserCreationTEST3(){        
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c WHERE XC_Step_Order__c = 3];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN021_EMobility_EmailForUserCreation.InputWrapper inw = new XC_IN021_EMobility_EmailForUserCreation.InputWrapper();
        List<XC_IN021_EMobility_EmailForUserCreation.InputWrapper> inputWrapperList = new List<XC_IN021_EMobility_EmailForUserCreation.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN021_EMobility_EmailForUserCreation.emailForUserCreation(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }
}