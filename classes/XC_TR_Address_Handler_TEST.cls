/**
* @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
* @date Creation  24/06/2019 
* @description XC_TR_Address_Handler_TEST – Test class for XC_TR_Address_Handler
*/ 
@isTest
public class XC_TR_Address_Handler_TEST {

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

        
    static testMethod void test1(){ 
        
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        XC_IN001_CallStockManagement.InputWrapper wr = new XC_IN001_CallStockManagement.InputWrapper();
        wr.stepId = step.Id; 
        List<XC_IN001_CallStockManagement.InputWrapper> inputWrapperList = new List<XC_IN001_CallStockManagement.InputWrapper>();
        inputWrapperList.add(wr);
        
        test.startTest();  
        XC_IN001_CallStockManagement.callStockManagement(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }
    
   	static testMethod void test2(){
        List<XC_Address__c> addList = [SELECT Id, name, XC_StreetNumber__c, XC_Address__c, XC_StreetType__c, XC_CategoryText__c FROM XC_Address__c ];
        XC_Address__c add = addList[0];
        add.XC_Address__c = 'test';
        add.XC_StreetNumber__c = '15';
        add.XC_StreetType__c = 'Square';

       update add;
       delete add;
    }
}