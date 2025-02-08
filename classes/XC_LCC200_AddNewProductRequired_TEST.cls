@IsTest
private class XC_LCC200_AddNewProductRequired_TEST {
@IsTest
    static void getCommercialItemList(){
        	XC_LCC200_AddNewProductRequired.ResultOtherPA wrap = new XC_LCC200_AddNewProductRequired.ResultOtherPA();
        	wrap.message= 'aa';
        wrap.titleMessage= 'aa';
        wrap.typeMessage= 'aa';	
        	NE__Order__c order = new NE__Order__c();
        	Id woliId = order.Id;
        	WorkOrderLineItem woli = new WorkOrderLineItem();
        	woli.Status='New';
        	
        	List<NE__OrderItem__c> listOrd = XC_DF_OrderItem.createOrderItems(1); 
        listOrd[0].XC_WBE__c = '';
		 listOrd[0].XC_CMCostCenter__c = '';
        	insert listOrd;
        	WorkOrder wo = new WorkOrder();
        	wo.XC_Configuration__c= order.Id;
        	wo.XC_Configuration_Item__c = listOrd[0].Id;
        	insert wo;
        woli.WorkOrderId = wo.Id;
        insert woli;
        	 project_cloud__Project__c project = new project_cloud__Project__c();
            project.project_cloud__IsTemplate__c =true;
            project.project_cloud__Type__c='provisioning';
            project.XC_LegalEntity__c ='EnelX';
            project.XC_Country__c ='Chile';
            insert project;
               			listOrd.get(0).XC_Project_Template__c= project.id;
                        listOrd.get(0).XC_LegalEntity__c='EnelX';
                        listOrd.get(0).XC_Wbe__c='test';
                        listOrd.get(0).XC_WBE_Status__c='Approved';
       					//update listOrd;
                            project_cloud__Project_Phase__c phFace= new project_cloud__Project_Phase__c();
                            phFace.project_cloud__Project__c =project.id;
                            phFace.XC_billing_phase__c = true;
                            insert phFace;
                
           		project_cloud__Project_Task__c projectTask = new project_cloud__Project_Task__c();
        		projectTask.project_cloud__Project_Phase__c = phFace.id;
        		projectTask.project_cloud__Estimated_Hours__c = 1;
        		projectTask.project_cloud__Units__c='Duration';
                insert projectTask;
            XC_LCC200_AddNewProductRequired.getCommercialItemList(woli.Id); 

        XC_LCC200_AddNewProductRequired.getParamToGlovia(listOrd[0].Id); 
    }
}