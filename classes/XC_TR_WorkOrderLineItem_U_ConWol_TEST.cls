@istest
public class XC_TR_WorkOrderLineItem_U_ConWol_TEST {
static testMethod  void congaTemplateIdForWolicongaTemplateIdForWoli (){
    	test.startTest();
    	User u = XC_DF_User.createUserAdmin();
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrdersForLead (1);
        wo[0].XC_Segment__c= 'B2B';
        wo[0].XC_Country__c = 'Italy';
        wo[0].XC_LegalEntity__c = 'EnelXItalia';
        insert wo; 
        System.debug('@@@wo'+wo);
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= wo[0].Id; 
    	insert woli;  
     System.debug('@@@woli'+woli);
        woli.Status='Approved';
        //woli.XC_WOLIType__c = 'Partner Engagement';
    	woli.XC_RequiredPurchaseOrderDocument__c=true; 
  		woli.XC_LCLDocument__c = 'LCL';
        update woli;
    	String staticApi = woli.XC_CongaStaticAPI__c; 
    	string tipo= wo[0].XC_Segment__c;
    	string country=wo[0].XC_Country__c;
    	String concatenatedOrder=String.valueOf(woli);
        concatenatedOrder = concatenatedOrder.removeEnd('}').removeStart('{');
    	XC_CongaTemplateMapping__c template = new XC_CongaTemplateMapping__c ();
    	template.Name='Partner engagment Document_B2G';
        template.XC_Country__c = country;
		template.XC_LegalEntity__c = 'EnelXItalia';
        template.XC_AccountType__c = 'B2C';
    	template.XC_Bundle__c= true;
        template.XC_IsNDA__c=false;
       	template.XC_PartnerEngagement__c= true;
    	template.XC_LCL__c = true;
        insert template;
        System.debug('@@@template'+template);
    	//ring dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  template.XC_CongaQuery__c + '&TemplateId=' +  template.XC_CongaIdTemplate__c
        //                      + '&OFN= WorkOrderLineItem' + Label.XC_CL_ModArt26 + 'LCL'
        //                      + '&DefaultPDF=0&qmode=SalesforceFile&WordStripIfs=1';
    	//].XC_CongaDynamicAPI__c = staticApi + dynamicApi;
    	
		list<WorkOrderLineItem>wolili= new list<WorkOrderLineItem>();
       
    	
        wolili.add(woli);
    	//insert wolili;
		insert u;
    	system.runAs(u){
        XC_TR_WorkOrderLineItem_U_CongaWOLI.congaTemplateIdForWoli(wolili);
    	XC_TR_WorkOrderLineItem_U_CongaWOLI.congaTemplateIdForWoliModArt26(wolili);
        }
    	test.stopTest();
        
}
    static testMethod  void congaTemplateIdForWoliModArt26 (){
        test.startTest();
		List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrdersForLead (1);
        wo[0].XC_Segment__c= 'B2B';
        wo[0].XC_Country__c = 'Italy';
        wo[0].XC_LegalEntity__c = 'EnelXItalia';
        insert wo; 
        WorkOrderLineItem woli = new WorkOrderLineItem();   		  	
        woli.WorkOrderId= wo[0].Id; 
    	insert woli;     
    	woli.XC_LCLDocument__c='ModArt26';
    	woli.XC_LCLDocumentRequired__c = true;
  		woli.Status = 'In Progress' ;
        woli.XC_OrderOfActivity__c=1;
        woli.XC_RequiredPurchaseOrderDocument__c=true;
        update woli;
        XC_CongaTemplateMapping__c cm = new XC_CongaTemplateMapping__c();
        cm.Name='Partner engagment Document';
        cm.XC_AccountType__c='B2B';
        cm.XC_Country__c = 'Italy' ;
        cm.XC_LegalEntity__c = 'EnelXItalia';
        //cm.XC_Bundle__c= true;
        //cm.XC_CongaIdTemplate__c = 'a4h0D000000bhA5QAI';
        //cm.XC_CongaQuery__c = '[WOLIqueryB2B]a4Z0D0000009kiJUAQ';  
    	cm.XC_LCL__c = false;
    	cm.XC_PartnerEngagement__c= true;
        cm.XC_IsNDA__c=false;
        insert cm;
        system.debug('mia conga' + cm);
        System.assert(wo!=null);
    	//XC_TR_WorkOrderLineItem_U_CongaWOLI.congaTemplateIdForWoliModArt26(listWoli);
    	test.stopTest();
}
    static testMethod  void congaTemplateIdForWoliChiusuraLavoriTest(){
        test.startTest();
        User u = XC_DF_User.createUserAdmin();
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrdersForLead (1);
        wo[0].XC_Segment__c= 'B2B';
        wo[0].XC_Country__c = 'Italy';
        wo[0].XC_LegalEntity__c = 'EnelXItalia';
        insert wo; 
        WorkOrderLineItem woli = new WorkOrderLineItem();   		  	
        woli.WorkOrderId= wo[0].Id; 
    	insert woli;
        
        woli.Status='Approved';
        woli.XC_WOLIType__c = 'Partner Engagement';
        woli.XC_RequiredPurchaseOrderDocument__c=true; 
        //[Start CR729]
		//woli.XC_NotesEndDate__c = 'note';
        //woli.XC_WorkEndDate__c = Date.today();
        //woli.XC_LCLDocument__c = 'Chiusura Lavori';
        woli.XC_LCLDocument__c = '';
        update woli;
        //[End CR729]
        String staticApi = woli.XC_CongaStaticAPI__c; 
        string tipo= wo[0].XC_Segment__c;
        string country=wo[0].XC_Country__c;
        String concatenatedOrder=String.valueOf(woli);
        concatenatedOrder = concatenatedOrder.removeEnd('}').removeStart('{');
        XC_CongaTemplateMapping__c template = new XC_CongaTemplateMapping__c ();
        template.XC_AccountType__c='B2C';
        template.Name='test';
    //mplate.XC_CongaIdTemplate__c='a4Z1w0000001X7wEAE';
    //	template.XC_CongaQuery__c = '[AccountType]a4Z9E00000057xgUAA,[AddressOrder]a4Z9E00000057xlUAA,[OrderQuery]a4Z1w0000001X7wEAE';
        template.XC_Country__c = country;
        template.XC_LegalEntity__c = 'EnelXItalia';
        //template.XC_AccountType__c = 'B2B';
        template.XC_Bundle__c= true;
        //template.XC_Country__c = 'Italy';
        template.XC_IsNDA__c=false;
        template.XC_PartnerEngagement__c= true;
        template.XC_LCL__c = false;
        template.XC_DocumentType__c = 'Chiusura Lavori';
        
        insert template; 
        list<WorkOrderLineItem>wolili= new list<WorkOrderLineItem>();
        wolili.add(woli);
        //insert wolili;
        insert u;
        system.runAs(u){
        XC_TR_WorkOrderLineItem_U_CongaWOLI.congaTemplateIdForWoliChiusuraLavori(wolili);
        }
        test.stopTest();
    }
    //[CR729 start sooraji.sajan@accenture.com 10.05.2022]
    static testMethod  void congaTemplateIdForWoliSospensioneTest(){
    test.startTest();
        User u = XC_DF_User.createUserAdmin();
		List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrdersForLead (1);
        wo[0].XC_Segment__c= 'B2B';
        wo[0].XC_Country__c = 'Italy';
        wo[0].XC_LegalEntity__c = 'EnelXItalia';
        insert wo; 
        WorkOrderLineItem woli = new WorkOrderLineItem();   		  	
        woli.WorkOrderId= wo[0].Id; 
    	insert woli;    
    	woli.Status='Approved';
        woli.XC_WOLIType__c = 'Partner Engagement';
        woli.XC_RequiredPurchaseOrderDocument__c=true; 
    
        
        String staticApi = woli.XC_CongaStaticAPI__c; 
        string tipo= wo[0].XC_Segment__c;
        string country=wo[0].XC_Country__c;
        String concatenatedOrder=String.valueOf(woli);
        concatenatedOrder = concatenatedOrder.removeEnd('}').removeStart('{');
        
        XC_CongaTemplateMapping__c template = new XC_CongaTemplateMapping__c ();
        template.XC_AccountType__c='B2C';
        template.Name='test';
        
    //template.XC_CongaIdTemplate__c='a4Z1w0000001X7wEAE';
    //template.XC_CongaQuery__c = '[AccountType]a4Z9E00000057xgUAA,[AddressOrder]a4Z9E00000057xlUAA,[OrderQuery]a4Z1w0000001X7wEAE';
        template.XC_Country__c = country;
        template.XC_LegalEntity__c = 'EnelXItalia';
        //template.XC_AccountType__c = 'B2B';
        template.XC_Bundle__c= true;
        //template.XC_Country__c = 'Italy';
        template.XC_IsNDA__c=false;
           template.XC_PartnerEngagement__c= true;
        //template.XC_LCL__c = false;
        template.XC_DocumentType__c = 'Sospensione';
        insert template;
        //ring dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  template.XC_CongaQuery__c + '&TemplateId=' +  template.XC_CongaIdTemplate__c
        //                      + '&OFN= WorkOrderLineItem' + Label.XC_CL_ModArt26 + 'LCL'
        //                      + '&DefaultPDF=0&qmode=SalesforceFile&WordStripIfs=1';
        //].XC_CongaDynamicAPI__c = staticApi + dynamicApi;
        list<WorkOrderLineItem>wolili= new list<WorkOrderLineItem>();
        wolili.add(woli);
        //insert wolili;
        insert u;
        system.runAs(u){
        XC_TR_WorkOrderLineItem_U_CongaWOLI.congaTemplateIdForWoliSospensione(wolili);
        
        }
        test.stopTest();
            
    }
    
    
    
        static testMethod  void congaTemplateIdForWoliRipresaTest(){
        test.startTest();
        User u = XC_DF_User.createUserAdmin();
        
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrdersForLead (1);
        wo[0].XC_Segment__c= 'B2B';
        wo[0].XC_Country__c = 'Italy';
        wo[0].XC_LegalEntity__c = 'EnelXItalia';
        insert wo; 
        WorkOrderLineItem woli = new WorkOrderLineItem();   		  	
        woli.WorkOrderId= wo[0].Id; 
    	insert woli;    
        woli.Status='Approved';
        woli.XC_WOLIType__c = 'Partner Engagement';
        woli.XC_RequiredPurchaseOrderDocument__c=true; 
    
        String staticApi = woli.XC_CongaStaticAPI__c; 
        string tipo= wo[0].XC_Segment__c;
        string country=wo[0].XC_Country__c;
        String concatenatedOrder=String.valueOf(woli);
        concatenatedOrder = concatenatedOrder.removeEnd('}').removeStart('{');
        XC_CongaTemplateMapping__c template = new XC_CongaTemplateMapping__c ();
        template.XC_AccountType__c='B2C';
        template.Name='test';
    //mplate.XC_CongaIdTemplate__c='a4Z1w0000001X7wEAE';
    //	template.XC_CongaQuery__c = '[AccountType]a4Z9E00000057xgUAA,[AddressOrder]a4Z9E00000057xlUAA,[OrderQuery]a4Z1w0000001X7wEAE';
        template.XC_Country__c = country;
        template.XC_LegalEntity__c = 'EnelXItalia';
        //template.XC_AccountType__c = 'B2B';
        template.XC_Bundle__c= true;
        template.XC_Country__c = 'Italy';
        template.XC_IsNDA__c=false;
           template.XC_PartnerEngagement__c= true;
        //template.XC_LCL__c = false;
        template.XC_DocumentType__c = 'Ripresa';
        insert template;
        //ring dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  template.XC_CongaQuery__c + '&TemplateId=' +  template.XC_CongaIdTemplate__c
        //                      + '&OFN= WorkOrderLineItem' + Label.XC_CL_ModArt26 + 'LCL'
        //                      + '&DefaultPDF=0&qmode=SalesforceFile&WordStripIfs=1';
        //].XC_CongaDynamicAPI__c = staticApi + dynamicApi;
        list<WorkOrderLineItem>wolili= new list<WorkOrderLineItem>();
        wolili.add(woli);
        //insert wolili;
        insert u;
        system.runAs(u){
        XC_TR_WorkOrderLineItem_U_CongaWOLI.congaTemplateIdForWoliRipresa(wolili);
        }
        test.stopTest();
    }
        static testMethod  void congaTemplateIdForWoliProrogaTest(){
        test.startTest();
        User u = XC_DF_User.createUserAdmin();
        
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrdersForLead (1);
        wo[0].XC_Segment__c= 'B2B';
        wo[0].XC_Country__c = 'Italy';
        wo[0].XC_LegalEntity__c = 'EnelXItalia';
        insert wo; 
        WorkOrderLineItem woli = new WorkOrderLineItem();   		  	
        woli.WorkOrderId= wo[0].Id; 
    	insert woli;    
        woli.Status='Approved';
        woli.XC_WOLIType__c = 'Partner Engagement';
        woli.XC_RequiredPurchaseOrderDocument__c=true; 
    
        String staticApi = woli.XC_CongaStaticAPI__c; 
        string tipo= wo[0].XC_Segment__c;
        string country=wo[0].XC_Country__c;
        String concatenatedOrder=String.valueOf(woli);
        concatenatedOrder = concatenatedOrder.removeEnd('}').removeStart('{');
        XC_CongaTemplateMapping__c template = new XC_CongaTemplateMapping__c ();
        template.XC_AccountType__c='B2C';
        template.Name='test';
    //mplate.XC_CongaIdTemplate__c='a4Z1w0000001X7wEAE';
    //	template.XC_CongaQuery__c = '[AccountType]a4Z9E00000057xgUAA,[AddressOrder]a4Z9E00000057xlUAA,[OrderQuery]a4Z1w0000001X7wEAE';
        template.XC_Country__c = country;
        template.XC_LegalEntity__c = 'EnelXItalia';
        //template.XC_AccountType__c = 'B2B';
        template.XC_Bundle__c= true;
        template.XC_Country__c = 'Italy';
        template.XC_IsNDA__c=false;
           template.XC_PartnerEngagement__c= true;
        //template.XC_LCL__c = false;
        template.XC_DocumentType__c = 'Proroga';
        insert template;
        //ring dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  template.XC_CongaQuery__c + '&TemplateId=' +  template.XC_CongaIdTemplate__c
        //                      + '&OFN= WorkOrderLineItem' + Label.XC_CL_ModArt26 + 'LCL'
        //                      + '&DefaultPDF=0&qmode=SalesforceFile&WordStripIfs=1';
        //].XC_CongaDynamicAPI__c = staticApi + dynamicApi;
        list<WorkOrderLineItem>wolili= new list<WorkOrderLineItem>();
        wolili.add(woli);
        //insert wolili;
        insert u;
        system.runAs(u){
        XC_TR_WorkOrderLineItem_U_CongaWOLI.congaTemplateIdForWoliProroga(wolili);
        }
        test.stopTest();
    }
        //[CR729 End sooraji.sajan@accenture.com 10.05.2022]
}