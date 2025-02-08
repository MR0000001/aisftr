/**
* @author Marco Ottaviano mottaviano@deloitte.it
* @date Creation  11/06/2019 
* @description XC_REST_Contract_DAO_Test – Test class for XC_REST_Contract_DAO
*/



@isTest
private class XC_REST_Contract_DAO_Test {

	@TestSetup
	static void setup(){

        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
 
    }
	
	@isTest static void test_method_one() {
		// Implement test code
		List<Account> accoutInfo = XC_DF_Account.createResidentialAccounts(1);

		for(Integer i=0;i<accoutInfo.size(); i++) {
			accoutInfo.get(i).UniqueIdentifier__c='123Uniq'+String.valueOf(i);
			accoutInfo.get(i).IdentityNumber__c = '1234Doc'+String.valueOf(i);
			accoutInfo.get(i).IdentityType__c='NIT';
		}
        insert accoutInfo;

        List<XC_Address__c> addr = XC_DF_Address.createAddress(accoutInfo);
        insert addr;

        List<Contract> contractList=XC_DF_Contract.createCondominiumContract(accoutInfo);
        insert contractList;

        List<Asset> a = XC_DF_Asset.createAssetsFromContract(contractList);
        insert a;


        String idacc=accoutInfo.get(0).Id;
        XC_UTIL_Account.AccountIFWrapper waAcc = new XC_UTIL_Account.AccountIFWrapper();
        waAcc.AccountID=idacc;

        XC_UTIL_Account.AccountIFWrapper waAccUniq = new XC_UTIL_Account.AccountIFWrapper();
        waAccUniq.UniqueID=accoutInfo.get(0).UniqueIdentifier__c;

        XC_UTIL_Account.AccountIFWrapper waAccEmail = new XC_UTIL_Account.AccountIFWrapper();
        waAccEmail.PrimaryEmail=accoutInfo.get(0).PrimaryEmail__c;

        XC_UTIL_Account.AccountIFWrapper waAccDocum = new XC_UTIL_Account.AccountIFWrapper();
        waAccDocum.IdentityNumber=accoutInfo.get(0).IdentityNumber__c;

        XC_UTIL_Address.AddressWrapper waAddress = new XC_UTIL_Address.AddressWrapper();
        waAddress.AddressID=addr.get(0).Id;

        XC_UTIL_Address.AddressWrapper waAddress2 = new XC_UTIL_Address.AddressWrapper();
        waAddress2.StreetType=addr.get(0).XC_StreetType__c;
        waAddress2.Address=addr.get(0).XC_Address__c;
        waAddress2.StreetNumber=addr.get(0).XC_StreetNumber__c;
        waAddress2.ZipCode=addr.get(0).XC_PostalCode__c;
        waAddress2.City=addr.get(0).XC_City__c;
        waAddress2.Country=addr.get(0).XC_AddressCountry__c;



        Test.startTest();
        	XC_REST_Contract_DAO.getContractFromAccount(waAcc);
        	XC_REST_Contract_DAO.getContractFromAccount(waAccUniq);
        	XC_REST_Contract_DAO.getContractFromAccount(waAccEmail);
        	XC_REST_Contract_DAO.getContractFromAccount(waAccDocum);
        	XC_REST_Contract_DAO.getContractFromAddress(waAddress);
        	XC_REST_Contract_DAO.getContractFromAddress(waAddress2);
        	XC_REST_Contract_DAO.getContractFromAsset(a.get(0).Id);
            System.assertEquals(accoutInfo.size(),1);
        Test.stopTest();

	}
	

}