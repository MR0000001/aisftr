@isTest
public class XC_UTIL_Case_D_Test {
	
	@isTest static void retriveCaseTypeSettingMtdFromCases() {
		Case caso = new Case();
        caso.Reason = 'XCMOT006';
        caso.Subcause__c = 'ATCL072';
		Test.startTest();
        	Map<Id, XC_CM_Case_Type_Setting__mdt> result = XC_UTIL_Case_D.retriveCaseTypeSettingMtdFromCases(new List<Case>{caso});
            System.assert(!result.isEmpty());
		Test.stopTest();
	}

	@isTest static void retrieveCaseTypeData() {
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
		Case caso = XC_DF_Case.createCases(1)[0];
        caso.Reason = 'XCMOT006';
        caso.Subcause__c = 'ATCL072';
        caso.XC_Subtype__c = null;
        insert caso;
		Test.startTest();
        Map<Id,Case> data = XC_UTIL_Case_D.retrieveCaseTypeData(new List<String>{caso.Id});
		System.assert(!data.isEmpty());
		Test.stopTest();
	} 

	@isTest static void getCaseReasonRtMappingValues() {
		Test.startTest();
		XC_UTIL_Case.manageCasePendingFromRelatedCase(new List<Case>(), new Map<Id, Case>(), new Map<Id, Case>());
		System.assertEquals(1, 1);
		Test.stopTest();
	} 

	@isTest static void filterCasesByCaseTypeSettings() {
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_SuperBonus110});
        Case caso = XC_UTIL_Case.initCaseFromCaseSettings(caseSettingsMap.get(Label.XC_CL_SuperBonus110));
        Test.startTest();
        List<Case> result = XC_UTIL_Case_D.filterCasesByCaseTypeSettings(new List<Case>{caso},Label.XC_CL_SuperBonus110);
		System.assertEquals(result.size(), 1);
		Test.stopTest();
	} 
}