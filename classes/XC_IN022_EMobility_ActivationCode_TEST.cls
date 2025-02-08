/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 31/05/2019
* @date Modification dd/mm/yyyy
* @description  – XC_IN022_EMobility_ActivationCode_TEST
*/ 
@isTest
public class XC_IN022_EMobility_ActivationCode_TEST {
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
        
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);
        NE__OrderItem__c ordIt = orderItemList[0];

        insert ordIt;
        
        List<NE__Product__c> lp = XC_DF_Product.createProducts(1);
        lp[0].Name = 'RFID';
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
    
    static testMethod void emailForUserCreationTEST(){
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN022_EMobility_ActivationCode.InputWrapper inw = new XC_IN022_EMobility_ActivationCode.InputWrapper();
        List<XC_IN022_EMobility_ActivationCode.InputWrapper> inputWrapperList = new List<XC_IN022_EMobility_ActivationCode.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN022_EMobility_ActivationCode.emailForUserCreation(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }
    
    static testMethod void emailForUserCreationTEST2(){
        List<NE__Product__c> lp = [SELECT Id FROM NE__Product__c];
        lp[0].Name = 'Open Charge';
        update lp;
        
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN022_EMobility_ActivationCode.InputWrapper inw = new XC_IN022_EMobility_ActivationCode.InputWrapper();
        List<XC_IN022_EMobility_ActivationCode.InputWrapper> inputWrapperList = new List<XC_IN022_EMobility_ActivationCode.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN022_EMobility_ActivationCode.emailForUserCreation(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }
}