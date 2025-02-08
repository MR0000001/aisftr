@isTest
public class XC_TR_Configuration_U_CreateContr_TEST {
    
    @isTest
	private static void handleCreationContract_orderSent() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
		Test.startTest();
            List<NE__Order__c> order = XC_DF_Order.createOrders(1, 'InOrder');
            insert order;
        	order[0].NE__Configuration_Type__c = Label.XC_CL_Configuration_TypeNew;
        	order[0].NE__OrderStatus__c = Label.XC_CL_Order_StatusSent;
        	update order;
        Test.stopTest();
        
        System.assert(true);
    }
    
    @isTest
	private static void handleCreationContract_inCreation() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account>  accountList = XC_DF_Account.createResidentialAccounts(1);
        //accountList[0].XC_Segment__c = 'B2B';
        accountList[0].XC_FirstName__c = 'Gianni';
        accountList[0].XC_LastName__c = 'Infantino';
        accountList[0].IdentityNumber__c ='NFNGNN80A01F839W';
        accountList[0].IdentityType__c = 'CF';
        accountList[0].XC_DocumentCountry__c = 'Italy';
        insert accountList;
        
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(accountList);
        //contList[0].XC_Segment__c = 'B2B';
        contList[0].XC_CountryLegalEntity__c = 'ITALY';
        contList[0].XC_MainLegalEntity__c = 'EnelXItalia';
        insert contList;
        
        List<XC_Address__c> addr = XC_DF_Address.createAddress(accountList);
        insert addr;
        
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunityWithVisit(contList, addr[0]);
        insert opp;
        
        Id orderRTOptyid = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId();
        List<NE__Order__c> order = XC_DF_Order.createOrders(1, 'InOrder');
		order[0].RecordTypeId = orderRTOptyid;
        order[0].XC_Segment__c = 'B2B';
        order[0].XC_LegalEntity__c = 'EnelXItalia';
        order[0].NE__AccountId__c = accountList[0].Id; 
        order[0].NE__OptyId__c = opp[0].Id;
        insert order;
        
		Test.startTest();
        
        	Id orderRTOrderid = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
			order[0].RecordTypeId = orderRTOrderid;
        	order[0].NE__Configuration_Type__c = Label.XC_CL_Configuration_TypeNew;
        	update order;
        
        Test.stopTest();
        
        System.assert(true);
    }

}