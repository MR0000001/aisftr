@isTest

private class gl_CustomCaseLookupController_Test {
	static testMethod void search_Test() {
		//Create Account test data
		gl_CustomCaseLookupController lookup = new gl_CustomCaseLookupController();
		Id [] fixedSearchResults = new Id[4];
        List<Case> listCase = XC_DF_Case.createCases(2);
        listCase[1].XC_IsCloned__c = true;
        insert listCase;
		
        fixedSearchResults[0] = listCase[0].AccountId;
        fixedSearchResults[1] = listCase[0].ContactId;
		
		fixedSearchResults[2] = listCase[0].Id;
		fixedSearchResults[3] = listCase[1].Id; 
		
		Test.setFixedSearchResults(fixedSearchResults);
		
		PageReference pageRef = Page.gl_CustomCaseLookup;	
	    pageRef.getParameters().put('lksrch','');
	    pageRef.getParameters().put('ixnId','2222222');
	    pageRef.getParameters().put('inServiceCloudConsole','false');
	    pageRef.getParameters().put('frm','');
	    pageRef.getParameters().put('txt','');
	    Test.setCurrentPage(pageRef);
				
		lookup.caseNumber = '12345678';
		lookup.Subject = 'test';    
		
		PageReference pr = lookup.search();
		System.assert(lookup.case_results.size() != 0);		
		
		lookup.caseNumber = '';
		lookup.Subject = 'subject444'; 
	}  
	
	static testMethod void loadSearchResults_Test() {
		//Create Account test data
		gl_CustomCaseLookupController lookup = new gl_CustomCaseLookupController();
		Id [] fixedSearchResults = new Id[4];
        List<Case> listCase = XC_DF_Case.createCases(2);
        listCase[1].XC_IsCloned__c = true;
        insert listCase;
		
        fixedSearchResults[0] = listCase[0].AccountId;
        fixedSearchResults[1] = listCase[0].ContactId;
		
		fixedSearchResults[2] = listCase[0].Id;
		fixedSearchResults[3] = listCase[1].Id; 
		
		Test.setFixedSearchResults(fixedSearchResults);	
					
		lookup.caseNumber = '12345678';
		lookup.Subject = 'test'; 
		
		lookup.searchString = '[{"Id":"0016A005TPTqQAO000","Contact.Name":"Jane Smith","Account.Phone":"5125", "CaseNumber":"12345678"}]';
		lookup.loadSearchResults(lookup.searchString);	
		System.assert(lookup.case_results.size() != 0);	
	}  
	
	static testMethod void performSearch_Test() {
		//Create Account test data
		gl_CustomCaseLookupController lookup = new gl_CustomCaseLookupController();
		Id [] fixedSearchResults = new Id[4];
        List<Case> listCase = XC_DF_Case.createCases(2);
        listCase[1].XC_IsCloned__c = true;
        insert listCase;
		
        fixedSearchResults[0] = listCase[0].AccountId;
        fixedSearchResults[1] = listCase[0].ContactId;
		
		fixedSearchResults[2] = listCase[0].Id;
		fixedSearchResults[3] = listCase[1].Id; 
		
		Test.setFixedSearchResults(fixedSearchResults);   		
				
		lookup.caseNumber = '12345678';
		lookup.Subject = 'test'; 
	
		lookup.performSearch();
		System.assert(lookup.case_results.size() != 0);		
		
		lookup.caseNumber = 'yyyyyyyyyyyyyyyyyyyyyy';
		lookup.Subject = ''; 
		lookup.performSearch();
		//System.assert(lookup.case_results.size() == 0);	
		
		lookup.caseNumber = '';
		lookup.Subject = ''; 
		lookup.search();
		System.assert(lookup.case_results.size() == 0);			
	} 
	
	static testMethod void getFormTag_Test() {
		gl_CustomCaseLookupController lookup = new gl_CustomCaseLookupController();
		lookup.getFormTag();
	}
	
	static testMethod void getTextBox_Test() {
		gl_CustomCaseLookupController lookup = new gl_CustomCaseLookupController();
		lookup.getTextBox();
	}
}