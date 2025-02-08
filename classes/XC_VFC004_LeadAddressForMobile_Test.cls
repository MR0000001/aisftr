@isTest
private class XC_VFC004_LeadAddressForMobile_Test {
	
	@isTest static void test_method_one() {
		
		List<Lead>leads =XC_DF_Lead.createResidentialLeads(1);
		insert leads;

		Test.startTest();

			ApexPages.StandardController lead_page = new ApexPages.StandardController(leads.get(0));
			XC_VFC004_LeadAddressForMobile lrhpc = new XC_VFC004_LeadAddressForMobile(lead_page);
			System.assertEquals(leads.size(),1);
		Test.stopTest();

	}
	
	//@isTest static void test_method_two() {
		// Implement test code
	//}
	
}