/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  17/05/2019 
* @description XC_IN003_CreditCardPreAuthorization_TEST – Test class for XC_IN003_CreditCardPreAuthorization
*/ 
@isTest
private class XC_IN003_CreditCardPreAuthorization_TEST {
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
        
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        Asset asst = listAsset[0];
        asst.XC_Configuration_Item__c = ordIt.Id;
        insert asst;
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        
        insert provisioningStep;
    }
    
    
    static testMethod void creditCardPreAuthorizationTEST(){        
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN003_CreditCardPreAuthorization.InputWrapper inw = new XC_IN003_CreditCardPreAuthorization.InputWrapper();
        List<XC_IN003_CreditCardPreAuthorization.InputWrapper> inputWrapperList = new List<XC_IN003_CreditCardPreAuthorization.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN003_CreditCardPreAuthorization.creditCardPreAuthorization(inputWrapperList);
        XC_IN003_CreditCardPreAuthorization.getKOInTest = true;
        XC_IN003_CreditCardPreAuthorization.creditCardPreAuthorization(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    } 
}