/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  05/06/2019 
* @description XC_IN017_EarlyCanc_CancelSub_TEST – Test class for XC_IN017_EarlyCanc_CancelSubscription
*/ 
@isTest
public class XC_IN017_EarlyCanc_CancelSub_TEST {
    @TestSetup
    static void setup(){
        OneOrg__c org            = new OneOrg__c(); 
        org.Name                 = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        Integer n = 5;
        List<XC_Provisioning_Step__c> provStepList = new List<XC_Provisioning_Step__c>();
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(n);
        insert orderItemList;
       	List<Account> accList = [SELECT id, IdentityNumber__c FROM Account];
        for(Account acc: accList){
            acc.IdentityNumber__c= acc.IdentityNumber__c + Integer.valueOf(Math.random() * 100);
        }
        update accList;
        
        List<Asset> astList = XC_DF_Asset.createAssets(n);
        for(Integer i = 0; i<n; i++){
            astList[i].XC_Original_Creation_OrderItem__c = orderItemList[i].Id;
            astList[i].NE__Order_Config__c = orderItemList[i].NE__OrderId__c;
        }
        insert astList;
        for(Integer i = 0; i<n; i++){
            XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
            provisioningStep.XC_Configuration_Item__c = orderItemList[i].id;
            provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
            provisioningStep.XC_Step_Order__c = 1;
            provStepList.add(provisioningStep);
        }
        insert provStepList;
    }    
    @isTest
    static void methodsTest(){
        List<Id> listOrderItemId = new List<Id>();
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        List<NE__OrderItem__c> listOrderItem = [Select Id, NE__Status__c From NE__OrderItem__c];
        for(NE__OrderItem__c ord : listOrderItem){
            listOrderItemId.add(ord.Id);
        }
        XC_IN017_EarlyCanc_CancelSubscription.InputWrapper inputWr = new XC_IN017_EarlyCanc_CancelSubscription.InputWrapper();
        inputWr.stepId = step.Id;
        List<XC_IN017_EarlyCanc_CancelSubscription.InputWrapper> wrapperList = new List<XC_IN017_EarlyCanc_CancelSubscription.InputWrapper>();
        wrapperList.add(inputWr);
        
        test.startTest();
        XC_IN017_EarlyCanc_CancelSubscription.cancelSubscription(wrapperList);
        test.stopTest(); 
        System.assertEquals(5, stepsList.size());
    }
}