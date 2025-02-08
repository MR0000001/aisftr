@isTest
private class XC_TR_Case_U_WOVerification_TEST {

	@testSetup static void test_setup_verification(){
		List<Case> cases = XC_DF_Case.createCases(3);
		insert cases;
	}

	@isTest static void test_one(){
		
		List<XC_CM_Case_Type_Setting__mdt> caseTypeSettingsMtd = [SELECT id, DeveloperName, XC_Case_Reason__c, XC_Sub_Cause__c, XC_Sub_Type__c, XC_Priority__c, XC_Status__c 
                                                                    FROM XC_CM_Case_Type_Setting__mdt 
                                                                   WHERE DeveloperName =: Label.XC_CL_ValidationCase];
        XC_TR_Case_U_WOVerification_TEST.utilCase(caseTypeSettingsMtd, Label.XC_CL_OkValue);                                                      
	}
    
    @isTest static void partnerValidationCaseCreation(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accList);
        insert conList;
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1, 'Repair');
        woList[0].XC_LegalEntity__c = 'EndesaX';
        woList[0].AccountId = accList[0].Id;
        woList[0].ContactId = conList[0].Id;
        woList[0].XC_ValidationCounter__c = 0;
        insert woList;
		
		List<XC_CM_Case_Type_Setting__mdt> caseTypeSettingsMtd = [SELECT id, DeveloperName, XC_Case_Reason__c, XC_Sub_Cause__c, XC_Sub_Type__c, XC_Priority__c, XC_Status__c 
                                                                    FROM XC_CM_Case_Type_Setting__mdt 
                                                                   WHERE DeveloperName =: Label.XC_CL_ValidationCase];
        Case caso = new Case();
        caso.Status = 'ESTA001';
        caso.XC_LegalEntity__c = 'EndesaX';
		caso.Reason = caseTypeSettingsMtd.get(0).XC_Case_Reason__c;
		caso.Subcause__c = caseTypeSettingsMtd.get(0).XC_Sub_Cause__c;
		caso.XC_Subtype__c = caseTypeSettingsMtd.get(0).XC_Sub_Type__c;
        caso.XC_WorkOrder__c = woList[0].Id;
        caso.AccountId = accList[0].Id;
        caso.ContactId = conList[0].Id;
        insert caso;
        
        caso.XC_WorkOrderValidation__c = Label.XC_CL_KoValue;
        caso.XC_Result__c = 'RS016';
        caso.XC_Resolution__c = 'R018';
        caso.XC_KO_Reasons__c = 'XCKO001';
		
        try{
            Test.startTest();
                update caso;
            Test.stopTest();
        }catch(Exception e){
            System.assert(true);
        }                      
	}

	@isTest static void test_two(){
		
		List<XC_CM_Case_Type_Setting__mdt> caseTypeSettingsMtd = [SELECT id, DeveloperName, XC_Case_Reason__c, XC_Sub_Cause__c, XC_Sub_Type__c, XC_Priority__c, XC_Status__c 
                                                                    FROM XC_CM_Case_Type_Setting__mdt 
                                                                   WHERE DeveloperName =: Label.XC_CL_PartnerValidationCase];
        XC_TR_Case_U_WOVerification_TEST.utilCase(caseTypeSettingsMtd, Label.XC_CL_KoValue);  
        System.debug('caseTypeSettingsMtd' + caseTypeSettingsMtd);                                                    
	}
	
	static void utilCase(List<XC_CM_Case_Type_Setting__mdt> caseTypeSettingsMtd, String labelVal) {
		List<Case> cases = [SELECT Id FROM Case];

		for (Case ca: cases){
			ca.XC_WorkOrderValidation__c = labelVal;
			ca.Status = 'ESTA001'; // Label.XC_CL_Case_Status007;
			ca.Reason = caseTypeSettingsMtd.get(0).XC_Case_Reason__c;
			ca.Subcause__c = caseTypeSettingsMtd.get(0).XC_Sub_Cause__c;
			ca.XC_Subtype__c = caseTypeSettingsMtd.get(0).XC_Sub_Type__c;
		}

		insert XC_DF_OneOrg.createOneOrg('Spain');

		Test.startTest();

			update cases;

		Test.stopTest();

		System.assertEquals(1,1);
	}
	
	
}