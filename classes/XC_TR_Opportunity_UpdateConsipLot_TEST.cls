@isTest
public class XC_TR_Opportunity_UpdateConsipLot_TEST {
	
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;

        User u = XC_DF_User.createUserAdmin();
        u.XC_LegalEntity__c = 'EnelXItalia';
        insert u;
        
         insert XC_DF_Account.createResidentialAccounts(1);
        List<Account> accList = [SELECT Id FROM Account];
        insert XC_DF_Address.createAddress(accList);
        List<XC_Address__c> listAddress = [SELECT Id FROM XC_Address__c];
        insert XC_DF_Contact.createResidentialContacts(accList);
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
	
        XC_ConsipLot__c newLot = new XC_ConsipLot__c();
        newLot.name = 'lot lot';
        newLot.XC_LotNumber__c = '8 (SL4)';
        newLot.XC_TotalAmount__c = 1000;
        insert newLot;
        
        insert XC_DF_Opportunity.createOpportunityWithoutVisit(contactList,listAddress[0]);
        List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
        oppinserted[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2G_Opportunity_Italy').getRecordTypeId();
        oppinserted[0].XC_LegalEntity__c = 'EnelXItalia';
        oppinserted[0].XC_Segment__c = 'B2G';
        oppinserted[0].XC_Country__c = 'Italy';
        oppinserted[0].XC_ConsipLot__c = newLot.Id;
        oppinserted[0].XC_ModeOfEngagement__c = 'Consip 4';
        update oppinserted;
        
        List<Account> accs = [SELECT Id FROM Account];
        accs[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2G').getRecordTypeId();       
        accs[0].XC_CheckBlacklist__c = 'Customer not present in the blacklist';
        update accs;
       
    }
    
    static testMethod void onOpportunity() {
        List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
        
        Test.startTest();
        	oppinserted[0].XC_AdditionalAct__c = 100.0;
        	update oppinserted;
        
            oppinserted[0].StageName = 'Qualified Potential Opportunity';
        	oppinserted[0].XC_ContractualRevenueStartDate__c = Date.today();
            oppinserted[0].XC_ContractStartDate__c = Date.today();
        	oppinserted[0].XC_ContractualRevenueEndDate__c = Date.today();
            oppinserted[0].XC_ContractEndDate__c = Date.today();
        	update oppinserted;
        
        	oppinserted[0].StageName = 'In Progress';
        	update oppinserted;
        
        	oppinserted[0].StageName = 'Presented Proposal';
        	update oppinserted;
        
        	oppinserted[0].StageName = 'Accepted Proposal';
        	update oppinserted;
        Test.stopTest();
    }
    
     static testMethod void onOpportunityRPF() {
        List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
        List<NE__OrderItem__c > orderItemList = XC_DF_OrderItem.createOrderItems(1);
        insert orderItemList;
        List<NE__Order__c> orders = [SELECT Id FROM NE__Order__c];
        orders[0].NE__OptyId__c = oppinserted[0].Id;
        orders[0].RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId();
        orders[0].XC_Segment__c = 'B2G';
        update orders;
        Test.startTest();
        	oppinserted[0].XC_RPFVerification__c = 'Documentazione completa';
        	update oppinserted;
         
         	oppinserted[0].XC_RPFVerification__c = 'Lotto saturo';
        	update oppinserted;
        Test.stopTest();
    }
    
    static testMethod void onOrder() {
        List<NE__OrderItem__c > orderItemList = XC_DF_OrderItem.createOrderItems(1);
        insert orderItemList;
        List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
        List<NE__Order__c> orders = [SELECT Id FROM NE__Order__c];
        orders[0].NE__OptyId__c = oppinserted[0].Id;
        orders[0].RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        orders[0].XC_Segment__c = 'B2G';
        update orders;
          
        
        Test.startTest();
            orderItemList[0].XC_RecurringDuration__c = 10;
            orderItemList[0].NE__RecurringChargeOv__c = 10;
            update orderItemList;
        	orders[0].XC_SummaryQuoteAmount__c = 100.0;
        	update orders;
        Test.stopTest();
        
    }
    
    static testMethod void onOrder2() {
        List<NE__OrderItem__c > orderItemList = XC_DF_OrderItem.createOrderItems(1);
        insert orderItemList;
        List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
        List<NE__Order__c> orders = [SELECT Id FROM NE__Order__c];
        orders[0].NE__OptyId__c = oppinserted[0].Id;
        orders[0].RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        orders[0].XC_Segment__c = 'B2G';
        update orders;
          
        
        Test.startTest();
            orderItemList[0].XC_RecurringDuration__c = 10;
            orderItemList[0].NE__RecurringChargeOv__c = 10;
        	orderItemList[0].XC_RecurringPeriodType__c = 'Annual';
            update orderItemList;
        	orders[0].XC_SummaryQuoteAmount__c = 100.0;
        	update orders;
        Test.stopTest();
        
    }
    
    static testMethod void onOrder3() {
        List<NE__OrderItem__c > orderItemList = XC_DF_OrderItem.createOrderItems(1);
        insert orderItemList;
        List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
        List<NE__Order__c> orders = [SELECT Id FROM NE__Order__c];
        orders[0].NE__OptyId__c = oppinserted[0].Id;
        orders[0].RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        orders[0].XC_Segment__c = 'B2G';
        update orders;
          
        
        Test.startTest();
            orderItemList[0].XC_RecurringDuration__c = 10;
            orderItemList[0].NE__RecurringChargeOv__c = 10;
        	orderItemList[0].XC_RecurringPeriodType__c = 'Bi-Monthly';
            update orderItemList;
        	orders[0].XC_SummaryQuoteAmount__c = 100.0;
        	update orders;
        Test.stopTest();
        
    }
    
    static testMethod void onOrder4() {
        List<NE__OrderItem__c > orderItemList = XC_DF_OrderItem.createOrderItems(1);
        insert orderItemList;
        List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
        List<NE__Order__c> orders = [SELECT Id FROM NE__Order__c];
        orders[0].NE__OptyId__c = oppinserted[0].Id;
        orders[0].RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        orders[0].XC_Segment__c = 'B2G';
        update orders;
          
        
        Test.startTest();
            orderItemList[0].XC_RecurringDuration__c = 10;
            orderItemList[0].NE__RecurringChargeOv__c = 10;
        	orderItemList[0].XC_RecurringPeriodType__c = 'Four-Monthly';
            update orderItemList;
        	orders[0].XC_SummaryQuoteAmount__c = 100.0;
        	update orders;
        Test.stopTest();
        
    }
    
    static testMethod void onOrder5() {
        List<NE__OrderItem__c > orderItemList = XC_DF_OrderItem.createOrderItems(1);
        insert orderItemList;
        List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
        List<NE__Order__c> orders = [SELECT Id FROM NE__Order__c];
        orders[0].NE__OptyId__c = oppinserted[0].Id;
        orders[0].RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        orders[0].XC_Segment__c = 'B2G';
        update orders;
          
        
        Test.startTest();
            orderItemList[0].XC_RecurringDuration__c = 10;
            orderItemList[0].NE__RecurringChargeOv__c = 10;
        	orderItemList[0].XC_RecurringPeriodType__c = 'Biennial';
            update orderItemList;
        	orders[0].XC_SummaryQuoteAmount__c = 100.0;
        	update orders;
        Test.stopTest();
        
    }
    
    static testMethod void onOrder6() {
        List<NE__OrderItem__c > orderItemList = XC_DF_OrderItem.createOrderItems(1);
        insert orderItemList;
        List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
        List<NE__Order__c> orders = [SELECT Id FROM NE__Order__c];
        orders[0].NE__OptyId__c = oppinserted[0].Id;
        orders[0].RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        orders[0].XC_Segment__c = 'B2G';
        update orders;
          
        
        Test.startTest();
            orderItemList[0].XC_RecurringDuration__c = 10;
            orderItemList[0].NE__RecurringChargeOv__c = 10;
        	orderItemList[0].XC_RecurringPeriodType__c = 'Biannual';
            update orderItemList;
        	orders[0].XC_SummaryQuoteAmount__c = 100.0;
        	update orders;
        Test.stopTest();
        
    }
    
    static testMethod void onOrder7() {
        List<NE__OrderItem__c > orderItemList = XC_DF_OrderItem.createOrderItems(1);
        insert orderItemList;
        List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
        List<NE__Order__c> orders = [SELECT Id FROM NE__Order__c];
        orders[0].NE__OptyId__c = oppinserted[0].Id;
        orders[0].RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        orders[0].XC_Segment__c = 'B2G';
        update orders;
          
        
        Test.startTest();
            orderItemList[0].XC_RecurringDuration__c = 10;
            orderItemList[0].NE__RecurringChargeOv__c = 10;
        	orderItemList[0].XC_RecurringPeriodType__c = 'Quarter';
            update orderItemList;
        	orders[0].XC_SummaryQuoteAmount__c = 100.0;
        	update orders;
        Test.stopTest();
        
    }
    
    static testMethod void onOrder8() {
        List<NE__OrderItem__c > orderItemList = XC_DF_OrderItem.createOrderItems(1);
        insert orderItemList;
        List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
        List<NE__Order__c> orders = [SELECT Id FROM NE__Order__c];
        orders[0].NE__OptyId__c = oppinserted[0].Id;
        orders[0].RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        orders[0].XC_Segment__c = 'B2G';
        update orders;
          
        
        Test.startTest();
            orderItemList[0].XC_RecurringDuration__c = 10;
            orderItemList[0].NE__RecurringChargeOv__c = 10;
        	orderItemList[0].XC_RecurringPeriodType__c = 'Other';
            update orderItemList;
        	orders[0].XC_SummaryQuoteAmount__c = 100.0;
        	update orders;
        Test.stopTest();
        
    }
   
}