@isTest
public class XC_TR_Contract_U_CongaFromContract_TEST {
    static testMethod void congaTemplateIdForContract_Test(){ 
        User u = XC_DF_User.createUserAdmin();
        
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunity(1, true);
        //opp[0].recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('XC_Opportunity_Chile').getRecordTypeId(); 
        insert opp;      
        Account a =  [select id,XC_DocumentCountry__c ,XC_SohoType__c,XC_Country__c,XC_Segment__c from account where id = :opp[0].AccountId limit 1];       
        a.XC_Country__c='Italy';
        a.XC_Segment__c='B2B';
        a.XC_DocumentCountry__c='Italy'; 
        update a;
        NE__Order__c o = XC_DF_Order.createOrder('InOrder');
        o.NE__OptyId__c= opp[0].Id;
        o.XC_LegalEntity__c= 'EnelXItalia';
        o.XC_Country__c='Italy';
        o.XC_Segment__c='B2B';
        o.NE__AccountId__c= a.id;
        o.XC_DeliveryAddress__c=opp[0].XC_Address__c;    
        update o;
		test.startTest();
        //NA 0603 add field XC_Country__c
        List<NE__Order__c> listOrde = [select id,XC_GenerateQuoteDocument__c, XC_Segment__c, NE__AccountId__r.XC_SohoType__c,NE__AccountId__r.XC_Country__c, XC_LegalEntity__c,XC_Country__c from ne__order__c where id= :o.id
                                      and NE__Type__c='InOrder' ];
        
        
        
       
        a.XC_DocumentCountry__c ='Italy';
        a.XC_Segment__c = 'B2B';
        //listOrde[0].XC_GenerateQuoteDocument__c = true;
        a.XC_Country__c = 'Italy';
         update a;
        NE__Product__c prod = new NE__Product__c();
        insert prod;
        NE__OrderItem__c confitem = XC_DF_OrderItem.createOrderItem(o);
        confitem.NE__OrderId__c= listOrde[0].id;
        confitem.NE__ProdId__c=prod.Id;
        insert confitem;
        
       	List<Contract> contracts =XC_DF_Contract.createContracts(1);
        contracts[0].XC_Generate_Contract_Document__c = true;
        contracts[0].XC_Configurations__c=listOrde[0].id;
        contracts[0].AccountId = a.id;
        contracts[0].RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Contract').getRecordTypeId();
        //contracts[0].XC_LegalEntity__c='EnelXItalia';
        insert contracts;
        contracts[0].XC_LegalEntity__c='EnelXItalia';
        update contracts;
        String staticApi = contracts[0].XC_CongaStaticAPI__c; 
    	string tipo= contracts[0].XC_Segment__c;
        String concatenatedOrder=String.valueOf(contracts[0]);
        concatenatedOrder = concatenatedOrder.removeEnd('}').removeStart('{');

        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c();
        ct.APXTConga4__Name__c='Test';
        ct.Country__c='Chile';
        ct.APXTConga4__Template_Type__c='Document';
        insert ct;
        
        
        XC_CongaTemplateMapping__c  cm = new XC_CongaTemplateMapping__c ();
        cm.XC_AccountType__c= 'B2B';
        cm.XC_Country__c = 'Italy';
        cm.XC_LegalEntity__c = 'EnelXItalia';
        cm.XC_IsContract__c= true;
        cm.XC_CommercialProduct__c = confitem.NE__ProdId__c;
        cm.XC_CongaIdTemplate__c = ct.id;
        cm.XC_CongaQuery__c = '[AccountType]a4Z9E00000057xgUAA,[AddressOrder]a4Z9E00000057xlUAA,[OrderQuery]a4Z1w0000001X7wEAE';  
        insert cm;
        String dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  cm.XC_CongaQuery__c + '&TemplateId=' +  cm.XC_CongaIdTemplate__c
                                    + '&OFN=Contract - CONTRACT_TO_SIGN'
                                + '&DefaultPDF=0&qmode=SalesforceFile' + '&APDF= 1';
        contracts[0].XC_CongaDynamicAPI__c = staticApi + dynamicApi;
        Map<Id,Contract> woliMap= new Map <Id,Contract>();
    	woliMap.put(contracts[0].id,contracts[0]);
        insert u;
    	system.runAs(u){
       XC_TR_Contract_U_CongaFromContract.congaTemplateIdForContract(contracts);
        }
    	test.stopTest();
       	
    }
}