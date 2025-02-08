@istest
private class XC_LCC199_CreateContractFromOpp_test { 
        static testmethod void createContract(){
        OneOrg__c org            = new OneOrg__c(); 
	    org.Name                 = 'OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
	    insert org;
        test.startTest();
        List<Account> acc = XC_DF_Account.createCondominiumAccounts(1);
        insert acc; 
		List <Contact> cont = XC_DF_Contact.createCondominiumContacts(acc);
        cont[0].AccountId=acc.get(0).id; 
        acc[0].XC_ContactToNotify__c=cont[0].id;
        update acc;
        List<XC_Address__c> addr = XC_DF_Address.createAddress(acc);
        insert addr;
        
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, true);
        insert oppList;
     	Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B_Opportunity_Italy').getRecordTypeId();
        oppList[0].AccountId = acc[0].Id;
        oppList[0].XC_Address__c = addr[0].Id;
        oppList[0].XC_SalesNoNeeded__c=true;
        oppList[0].XC_Segment__c='B2B';
        oppList[0].XC_LegalEntity__c='EnelXItalia';
       	 Id rtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B_Opportunity_Italy').getRecordTypeId();
        oppList[0].RecordTypeId=rtId;
        update oppList;
    	Id recordId = oppList[0].id; 		       
        Map<String,String> mapStringId =  XC_LCC199_CreateContractFromOpportunity.createContract(recordId);
        mapStringId.put('Status','OK');
            mapStringId.put('Opportunity',oppList[0].id);
            mapStringId.put('Account',oppList[0].AccountId);
            mapStringId.put('RecordTypeId',rtId);
          //  mapStringId.put('legalntity',legalntity);
          //  mapStringId.put('segment',segment);
         XC_LCC199_CreateContractFromOpportunity.createContract(recordId);
        System.assertEquals(oppList.size(),1);    
        test.stopTest();

}
}