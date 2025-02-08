@isTest
private class XC_VFC006_ProvisioningTempSc_Test {
	
	@isTest static void test_method_one() {
		// Implement test code
		
        NE__Order__c ord = new NE__Order__c();
        insert ord;
        
		NE__OrderItem__c noi = new NE__OrderItem__c();
        noi.NE__OrderId__c = ord.id;
        noi.NE__Qty__c = 2;
		insert noi;
        
        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(noi.id);
        insert ps;

		Test.startTest();
			XC_VFC006_ProvisioningTemplateSchema pts = new XC_VFC006_ProvisioningTemplateSchema(new ApexPages.StandardController(noi));
        	System.assertEquals(noi.NE__Qty__c,2);
		Test.stopTest();
	}
	
}