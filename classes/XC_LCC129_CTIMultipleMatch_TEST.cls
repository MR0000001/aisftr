/**
*@Author: Francesco Imperioli fimperioli@deloitte.it
*@Date creation: 09-07-2019
*@Description: TEST CLASS for XC_LCC129_CTIMultipleMatch
**/

@isTest
private class XC_LCC129_CTIMultipleMatch_TEST {
	
	@TestSetup
	static void setupData(){

		List<Contact> testContacts = XC_DF_Contact.createResidentialContacts(1);
		testContacts[0].Phone='340338201';
		insert testContacts;
	  
	}

	@isTest 
	static void lookUpByPhoneTEST() {
		Test.startTest();
			XC_LCC129_CTIMultipleMatch.lookUpByPhone('340338201');
		Test.stopTest();
	}

	@IsTest
	static void getVisibleRecordTypeTest(){
		Test.startTest();
			XC_LCC129_CTIMultipleMatch.getVisibleRecordType('Account');
		Test.stopTest();
	}


	
	
}