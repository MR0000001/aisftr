@Istest
global class XC_REST_ZUORA_CreditMemo_TEST implements HttpCalloutMock {
	static testmethod void sentToZuora()
    {
        test.startTest();
        XC_CS001_InterfaceConfiguration__c  interfaceConfiguration = new XC_CS001_InterfaceConfiguration__c ();
        interfaceConfiguration.Name = 'XC_CS_Zuora_CreditMemo';
        interfaceConfiguration.XC_URL_Required__c = 'https://workflow.apps.zuora.com/api/v1/workflows/DropInstallment/run';
        interfaceConfiguration.XC_activeInterface__c = true;
        interfaceConfiguration.XC_interfaceName__c = 'XC_CS_Zuora_CreditMemo';
        interfaceConfiguration.XC_Country__c = 'Italy';
        interfaceConfiguration.XC_Stream__c = 'B2G';
        interfaceConfiguration.XC_LegalEntity__c = 'EnelXItalia';
        insert interfaceConfiguration;
        List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
   		insert accList;
    	List <Contact> cont = XC_DF_Contact.createCondominiumContacts(accList);
    	cont[0].AccountId=accList.get(0).id;
    	insert cont;    
        List<Case> caseToCreateWo = XC_DF_Case.createCases(1);
        caseToCreateWo[0].XC_Subtype__c = 'XC267';
        Zuora__ZInvoice__c zuo = new Zuora__ZInvoice__c();
        zuo.Name='test';
        insert zuo;
        //caseToCreateWo[0].reason='XCMOT002';
        //caseToCreateWo[0].SubCause__c='ATCL003';
		caseToCreateWo[0].AccountId=accList[0].id;
       	caseToCreateWo[0].ContactId=cont[0].id;
        caseToCreateWo[0].XC_LegalEntity__c='EnelXItalia';
        caseToCreateWo[0].XC_Resolution__c = 'R001';
        caseToCreateWo[0].XC_Result__c = 'RS003';
        caseToCreateWo[0].CaseRemarks__c = 'OK';        
        caseToCreateWo[0].XC_Segment__c='B2B';
        caseToCreateWo[0].XC_Amount__c=1;	
        caseToCreateWo[0].XC_CreditMemo__c=1;
        caseToCreateWo[0].XC_Invoice__c=zuo.Id;
        insert caseToCreateWo;  
        Map<id,Case> mapOld= new Map <id,Case>();
        mapOld.put(caseToCreateWo.get(0).id,caseToCreateWo.get(0));
        Map<id,Case> mapNew= new Map <id,Case>();
        mapNew.put(caseToCreateWo.get(0).id,caseToCreateWo.get(0));
        mapNew.values()[0].Approved__c=true;
        update mapNew.values();
        Test.setMock(HttpCalloutMock.class, new XC_REST_ZUORA_CreditMemo_Mock());
        XC_REST_ZUORA_CreditMemo.sentToZuora(mapNew,mapOld);
		test.stopTest();
    }
     global HttpResponse respond(HttpRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success"}');
        res.setStatusCode(200);
        return res; 
    }
}