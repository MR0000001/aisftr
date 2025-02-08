/**
* @author Federico Amici - federico.amici@nttdata.com
* @description XC_UTIL_Lead_TEST - test class for the XC_UTIL_Lead class
*/
@isTest
private class XC_UTIL_Lead_TEST {

    @isTest
	private static void isSohoTEST() {

		String recordTypeId1 = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Soho').getRecordTypeId();
        String recordTypeId2 = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
    
		Test.startTest();
			Boolean ret1 = XC_UTIL_Lead.isSoho(recordTypeId1);
			Boolean ret2 = XC_UTIL_Lead.isSoho(recordTypeId2);
		Test.stopTest();

		System.assert(ret1 == true);
		System.assert(ret2 == false);

	}
    
    @isTest
	private static void isCondominiumTEST() {

		String recordTypeId1 = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Condominium').getRecordTypeId();
        String recordTypeId2 = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
    
		Test.startTest();
			Boolean ret1 = XC_UTIL_Lead.isCondominium(recordTypeId1);
			Boolean ret2 = XC_UTIL_Lead.isCondominium(recordTypeId2);
		Test.stopTest();

		System.assert(ret1 == true);
		System.assert(ret2 == false);

	}
    
    @isTest
	private static void isResidentialTEST() {

		String recordTypeId1 = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Condominium').getRecordTypeId();
        String recordTypeId2 = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
    
		Test.startTest();
			Boolean ret1 = XC_UTIL_Lead.isResidential(recordTypeId1);
			Boolean ret2 = XC_UTIL_Lead.isResidential(recordTypeId2);
		Test.stopTest();

		System.assert(ret1 == false);
		System.assert(ret2 == true);

	}
    
	@isTest
	private static void isSourceWebTEST() {

		Lead l1 = XC_DF_Lead.createResidentialLead();
		Lead l2 = XC_DF_Lead.createResidentialLead();
		
		l2.XC_Channel__c = Label.XC_CL_Web;
		
		Test.startTest();
			Boolean ret1 = XC_UTIL_Lead.isSourceWeb(l1);
			Boolean ret2 = XC_UTIL_Lead.isSourceWeb(l2);
		Test.stopTest();

		System.assert(ret1 != null);
		System.assert(ret2 != null);

	}
    
   	@isTest
	private static void isSourceDataLoaderTEST() {

		Lead l1 = XC_DF_Lead.createResidentialLead();
		
		l1.XC_MassivelyCreated__c = true;
		
		Test.startTest();
			Boolean ret1 = XC_UTIL_Lead.isSourceDataLoader(l1);
		Test.stopTest();

		System.assert(ret1 == true);

	}
    
     @isTest
	 private static void isGlobalB2BTEST() {
	 	
	 	 Test.startTest();
	 	 XC_UTIL_Lead.isGlobalB2B('a2O1i000004ddooEOO');
	 	 XC_UTIL_Lead.isGlobalB2G('a2O1i000004ddooEOO');
	 	 Test.stopTest();
	 	
	 }

}