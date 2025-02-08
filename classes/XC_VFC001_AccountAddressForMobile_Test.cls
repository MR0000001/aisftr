@isTest
private class XC_VFC001_AccountAddressForMobile_Test {
	
	@isTest static void test_method_one() {
		
		List<Account> accountlist=XC_DF_Account.createResidentialAccounts(1);
		insert accountlist;

		Test.startTest();

			ApexPages.StandardController cnt = new ApexPages.StandardController(accountlist.get(0));
			XC_VFC001_AccountAddressForMobile lrhpc = new XC_VFC001_AccountAddressForMobile(cnt);
			System.assertEquals(accountlist.size(),1);

		Test.stopTest();
	}
	
	
}