@istest
public class XC_TR_Account_U_CongaFromAccount_test {
    static testMethod  void XC_TR_Account_U_CongaFromAccount(){
    test.startTest();
    	User u = XC_DF_User.createUserAdmin();
       /* List<WorkOrder> listOrd = XC_DF_WorkOrder.createWorkOrdersForLead (1);
    	listOrd[0].XC_Segment__c= 'B2B';
        listOrd[0].XC_Country__c = 'Chile';
        //listOrd[0].XC_LegalEntity__c = 'EnelX';*/
        //insert listOrd; 
		List<Account> listNew = XC_DF_Account.createResidentialAccounts(1);
        listNew[0].XC_Segment__c = 'B2B';
        listNew[0].XC_Country__c='Italy';
        listNew[0].XC_NDADocumentNeeded__c=true;
        insert listNew;      
    	string tipo= listNew[0].XC_Segment__c;
    	string country=listNew[0].XC_Country__c;
        String staticApi = listNew[0].XC_CongaStaticAPI__c;
    	String concatenatedOrder=String.valueOf(listNew);
        concatenatedOrder = concatenatedOrder.removeEnd('}').removeStart('{');                            
        XC_CongaTemplateMapping__c cm = new XC_CongaTemplateMapping__c();
    	cm.XC_CongaIdTemplate__c='a4Z1w0000001X7wEAE';
    	cm.XC_AccountType__c=tipo;
        cm.XC_Country__c = country;     
        cm.XC_LegalEntity__c = 'EnelXItalia';
        cm.XC_Bundle__c= false;
        cm.XC_CongaIdTemplate__c = 'a4h1w0000004oAVAAY';
        cm.XC_CongaQuery__c = '[AccountType]a4Z9E00000057xgUAA,[AddressOrder]a4Z9E00000057xlUAA,[OrderQuery]a4Z1w0000001X7wEAE';  
    	cm.XC_LCL__c = false;
    	cm.XC_IsNDA__c=true;
        cm.XC_IsContract__c=false;
        
    	insert cm;
    	String dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  cm.XC_CongaQuery__c + '&TemplateId=' +  cm.XC_CongaIdTemplate__c + '&OFN= WorkOrderLineItem - LCL'+ '&DefaultPDF=0&qmode=SalesforceFile';
        listNew[0].XC_CongaDynamicAPI__c = staticApi + dynamicApi;
 		/*Map<Id,WorkOrder> woliMap= new Map <Id,WorkOrder>();
    	woliMap.put(listOrd[0].id,listOrd[0]);
        Map<Id,WorkOrder> Mapold= new Map <Id,WorkOrder>();
    	Mapold.put(listOrd[0].id,listOrd[0]);*/
		insert u;
        system.runAs(u)
        {
            XC_TR_Account_U_CongaFromAccount.congaTemplateIdForAccount(listNew);
        }
    	test.stopTest();
    }       
}