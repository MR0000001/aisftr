/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 23/05/2019
* @date  
* @description XC_IN006_CancelPreviousProvisioning_TEST – Test class for XC_IN006_CancelPreviousProvisioning
*/
@isTest
public class XC_IN006_CancelPreviousProvisioning_TEST {
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
        List<Asset> astList = XC_DF_Asset.createAssets(n);
        insert astList;
        for(Integer i = 0; i<n; i++){
            astList[i].XC_Original_Creation_OrderItem__c = orderItemList[i].Id;
            astList[i].NE__Order_Config__c = orderItemList[i].NE__OrderId__c;
        }
        update astList;
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
        XC_IN006_CancelPreviousProvisioning.InputWrapper inputWr = new XC_IN006_CancelPreviousProvisioning.InputWrapper();
        inputWr.stepId = step.Id;
        List<XC_IN006_CancelPreviousProvisioning.InputWrapper> wrapperList = new List<XC_IN006_CancelPreviousProvisioning.InputWrapper>();
        wrapperList.add(inputWr);
        
        test.startTest();
        //XC_IN006_CancelPreviousProvisioning.cancelServiceAppointments(listOrderItemId);
        XC_IN006_CancelPreviousProvisioning.cancelPreviousProvisioning(wrapperList);
        XC_IN006_CancelPreviousProvisioning.suspendOrderItems(listOrderItem);
        test.stopTest();
    }
}