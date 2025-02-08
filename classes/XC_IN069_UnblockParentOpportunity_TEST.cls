/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 13/01/2021
* @date Modification dd/mm/yyyy
* @description  – XC_IN069_UnblockParentOpportunity_TEST - Test class for XC_IN069_UnblockParentOpportunity
*/ 
@isTest
public class XC_IN069_UnblockParentOpportunity_TEST {
        /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation  13/01/2021 
    * @description insert records
    */ 
    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(2);
        insert orderItemList;
        NE__OrderItem__c ordIt = orderItemList[0];
        NE__OrderItem__c ordIt2 = orderItemList[1];
        
        List<NE__Product__c> lp = XC_DF_Product.createProducts(1);
        lp[0].Name = 'RFID';
        insert lp;
        
        ordit.NE__ProdId__c = lp[0].id;
		update ordit;
        List<Opportunity> oppNewList = XC_DF_Opportunity.createOpportunity(2, false);
        Opportunity opp1 = oppNewList[0];
        Opportunity opp2 = oppNewList[1];
        insert opp1;
        insert opp2;
        List<NE__Order__c> orderList = new List<NE__Order__c>([SELECT Id FROM NE__Order__c]);
        orderList[0].NE__OptyId__c = opp2.Id;
        orderList[1].NE__OptyId__c = opp1.Id;
        update orderList;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        Asset ast = assetList[0];
        ast.XC_Configuration_Item__c = ordIt.Id;
        insert ast;
        List<XC_Provisioning_Step__c> stepList = new List<XC_Provisioning_Step__c>();
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        XC_Provisioning_Step__c provisioningStep2 = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
        provisioningStep.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningWaitOpportunityByCampaignCode_Flow;
        provisioningStep.XC_Step_Order__c = 1;
        provisioningStep2.XC_Configuration_Item__c = ordIt2.id;
        provisioningStep2.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
        provisioningStep2.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningWaitOpportunityByCampaignCode_Flow;
        provisioningStep2.XC_Step_Order__c = 1;
        stepList.add(provisioningStep);
        stepList.add(provisioningStep2);
        insert stepList;
        opp2.XC_CampaignCode__c= opp1.Id;
        opp2.StageName = 'In Progress';
        update opp2;
    }
    
    static testMethod void closeRelatedStepTEST(){
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN069_UnblockParentOpportunity.InputWrapper inw = new XC_IN069_UnblockParentOpportunity.InputWrapper();
        List<XC_IN069_UnblockParentOpportunity.InputWrapper> inputWrapperList = new List<XC_IN069_UnblockParentOpportunity.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN069_UnblockParentOpportunity.closeRelatedStep(inputWrapperList);
        test.stopTest();
        System.assertEquals(2, stepsList.size());
    }
}