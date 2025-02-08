@isTest
private class XC_VFC007_ActivityPlanSchema_Test {
	
	@isTest static void getStepsByOrderItem() {
		

		Test.startTest();


			WorkOrder wo = new WorkOrder();
			insert wo;

			XC_VFC007_ActivityPlanSchema prova = new XC_VFC007_ActivityPlanSchema(new ApexPages.StandardController(wo));
			WorkOrderLineItem WoLi = new WorkOrderLineItem ();
			Woli.WorkOrderId= wo.Id;
			Woli.XC_OrderOfActivity__c =2;


			WorkOrderLineItem WoLi2 = new WorkOrderLineItem ();
			Woli2.WorkOrderId= wo.id;

			Woli2.XC_OrderOfActivity__c =2;

			insert Woli;
			insert Woli2;
			List<XC_VFC007_ActivityPlanSchema.Step> listSteps = prova.getStepsByOrderItem(wo.id);
			System.assertEquals(listSteps.size(),2);

		Test.stopTest();
	}
	

	
}