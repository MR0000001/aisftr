/**
* @author Sara Miozza sara.miozza@nttdata.com
* @date Creation 23/05/2019
* @date Modification dd/mm/yyyy
* @description  test class for XC_IN009_AdministrativeTasks
*/ 

@isTest
public class XC_IN009_AdministrativeTasks_TEST {

        @TestSetup
    	static void setup(){
        OneOrg__c org            = new OneOrg__c(); 
        org.Name                 = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        Integer n = 1;
        List<XC_Provisioning_Step__c> provStepList = new List<XC_Provisioning_Step__c>();
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(n);
        orderItemList[0].XC_LegalEntity__c = 'EndesaX';
        insert orderItemList;
        NE__Order__c ord = new NE__Order__c (Id = orderItemList[0].NE__OrderId__c);
        ord.XC_LegalEntity__c = 'EndesaX';
		ord.XC_Segment__c  = 'B2C';
        update ord;
        List<Asset> astList = XC_DF_Asset.createAssets(n);
        for(Integer i = 0; i<n; i++){
            astList[i].XC_Original_Creation_OrderItem__c = orderItemList[i].Id;
            astList[i].XC_Configuration_Item__c = orderItemList[i].Id;
            astList[i].NE__Order_Config__c = orderItemList[i].NE__OrderId__c;
            astList[i].XC_LegalEntity__c = 'EndesaX';
			astList[i].XC_Segment__c = 'B2C';
            System.debug('astList[' + i + ']: ' + astList[i]);
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
    static void methodTest(){
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        Id stepId = stepsList[0].Id;
        XC_IN009_AdministrativeTasks.InputWrapper inputWr = new XC_IN009_AdministrativeTasks.InputWrapper();
        inputWr.stepId = stepId;
        inputWr.model = 'Complex';
        List<XC_IN009_AdministrativeTasks.InputWrapper> wrapperList = new List<XC_IN009_AdministrativeTasks.InputWrapper>();
        wrapperList.add(inputWr);

        test.startTest();
        XC_IN009_AdministrativeTasks.administrativeTask(wrapperList);
        test.stopTest();
        System.assert(stepId!=null);
        
    
    }
    
     @isTest
    static void methodTest1(){
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        Id stepId = stepsList[0].Id;
        XC_IN009_AdministrativeTasks.InputWrapper inputWr = new XC_IN009_AdministrativeTasks.InputWrapper();
        inputWr.stepId = stepId;
        inputWr.model = 'Basic';
        List<XC_IN009_AdministrativeTasks.InputWrapper> wrapperList = new List<XC_IN009_AdministrativeTasks.InputWrapper>();
        wrapperList.add(inputWr);

        test.startTest();
        XC_IN009_AdministrativeTasks.administrativeTask(wrapperList);
        test.stopTest();
        System.assert(stepId!=null);
        
    
    }
}