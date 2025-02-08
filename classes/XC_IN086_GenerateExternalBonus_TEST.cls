/**
 * @author Nicola Mariniello nmariniello@deloitte.it
 * @date Creation 15/02/2022
 * @date Modification dd/mm/yyyy
 * @description – XC_IN086_GenerateExternalBonus_TEST -> Tect Class for XC_IN086_GenerateExternalBonus
 */

 
@isTest
public without sharing class XC_IN086_GenerateExternalBonus_TEST {

    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);
        NE__OrderItem__c ordIt = orderItemList[0];

        insert ordIt;
        
        List<NE__Product__c> lp = XC_DF_Product.createProducts(1);
        lp[0].Name = 'Bonus';
        insert lp;
        
        ordit.NE__ProdId__c = lp[0].id;
		update ordit;
        
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        Asset ast = assetList[0];
        ast.XC_Configuration_Item__c = ordIt.Id;
        insert ast;
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep;
    }
    
    static testMethod void createExternalBonusTEST(){
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN086_GenerateExternalBonus.InputWrapper inw = new XC_IN086_GenerateExternalBonus.InputWrapper();
        List<XC_IN086_GenerateExternalBonus.InputWrapper> inputWrapperList = new List<XC_IN086_GenerateExternalBonus.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN086_GenerateExternalBonus.createExternalBonus(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }

    static testMethod void createExternalBonusNoStepId(){
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN086_GenerateExternalBonus.InputWrapper inw = new XC_IN086_GenerateExternalBonus.InputWrapper();
        List<XC_IN086_GenerateExternalBonus.InputWrapper> inputWrapperList = new List<XC_IN086_GenerateExternalBonus.InputWrapper>();
        inw.stepId = null;
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN086_GenerateExternalBonus.createExternalBonus(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }

    static testMethod void createExternalBonusNoRecords(){
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN086_GenerateExternalBonus.InputWrapper inw = new XC_IN086_GenerateExternalBonus.InputWrapper();
        List<XC_IN086_GenerateExternalBonus.InputWrapper> inputWrapperList = new List<XC_IN086_GenerateExternalBonus.InputWrapper>();
        inw.stepId = 'AAA';
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN086_GenerateExternalBonus.createExternalBonus(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }
}