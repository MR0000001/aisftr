@isTest
public class XC_IN038_AdminTasksConciliacion_TEST {

         @TestSetup
    	static void setup(){

		Integer n = 1;
		List<XC_Provisioning_Step__c> provStepList = new List<XC_Provisioning_Step__c>();
		List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(n);
		insert orderItemList;
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
    static void methodTest(){
	List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
	Id stepId = stepsList[0].Id;
	XC_IN038_AdminTasksConciliacion.InputWrapper inputWr = new XC_IN038_AdminTasksConciliacion.InputWrapper();
	inputWr.stepId = stepId;
    inputWr.model = 'Basic';
	List<XC_IN038_AdminTasksConciliacion.InputWrapper> wrapperList = new List<XC_IN038_AdminTasksConciliacion.InputWrapper>();
	wrapperList.add(inputWr);

        test.startTest();
        XC_IN038_AdminTasksConciliacion.adminTasksConciliacion(wrapperList);
        test.stopTest();
        System.assert(stepId!=null);
            
    }

}