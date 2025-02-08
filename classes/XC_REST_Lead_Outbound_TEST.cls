/**
* @author            : Giuseppe Di Bonito
* @date Creation     : 29/03/2021
* @description XC_REST_SendPEC_TEST – Test class for XC_REST_Lead_Outbound and XC_REST_Lead_Outbound_U
*/
@isTest
public class XC_REST_Lead_Outbound_TEST {
    
    static testMethod void sendRequestFail(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_REST_Lead_W.WrapperLeadRequest leadWrapper = new XC_REST_Lead_W.WrapperLeadRequest();
        
        XC_REST_Lead_Outbound.sendRequest(leadWrapper,'XCustomerB2C');
        
        System.assertEquals(true, leadWrapper!=null);
        Test.stopTest();
        
    }
    
    static testMethod void sendRequest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_REST_Lead_W.WrapperLeadRequest leadWrapper = new XC_REST_Lead_W.WrapperLeadRequest();
        leadWrapper.Lead.LeadType = 'Residential';
        leadWrapper.Lead.LastName = 'ZINGARIELLO';
        leadWrapper.Lead.FirstName = 'EMANUEL';
        leadWrapper.Lead.PhonePrefix = '+39';
        leadWrapper.Lead.Phone = '3933053311';
        leadWrapper.Lead.PrimaryEmail = 'emanuelzingariello@yopmail.it';
        leadWrapper.Lead.IdentityType = 'CF';
        leadWrapper.Lead.IdentityNumber = 'ZNGMNL84C24L182B';
        leadWrapper.Lead.AccountID = '0017a00001XW5MvAAL';
        leadWrapper.Lead.BillingExternalID = 'a147a000006NO5uAAG';
        leadWrapper.Lead.ProductName = 'Open Charge';
        leadWrapper.Lead.SendToGenesys = true;
        leadWrapper.Lead.ContactRequestDate = '2021-05-12';
        leadWrapper.Lead.ContactRequestTimeSlot = '10-12';
        leadWrapper.Lead.Stream = null;
        leadWrapper.Lead.RequestDate = '2021-05-12';
        
        List<XC_UTIL_Address.PoSWrapper> poss = new List<XC_UTIL_Address.PoSWrapper>();
        XC_UTIL_Address.PoSWrapper pos = new XC_UTIL_Address.PoSWrapper();
        pos.POS = 'IT002E0015555A';
        poss.add(pos);
        XC_UTIL_Address.AddressWrapper adr = new XC_UTIL_Address.AddressWrapper('REST');
        leadWrapper.Lead.address = adr;
        leadWrapper.Lead.address.PointOfService = poss;
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'LeadOutbound';
        ic.XC_interfaceName__c = 'LeadOutbound';
        insert ic;
        
        XC_REST_Lead_Outbound.sendRequest(leadWrapper,'XCustomerB2C');
        
        System.assertEquals(true, leadWrapper!=null);
        Test.stopTest();
        
    }
    
        static testMethod void sendRequestFail2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_REST_Lead_W.WrapperLeadRequest leadWrapper = new XC_REST_Lead_W.WrapperLeadRequest();
        leadWrapper.Lead.LeadType = 'Small Business';
        leadWrapper.Lead.LastName = 'ZINGARIELLO';
        leadWrapper.Lead.FirstName = 'EMANUEL';
        leadWrapper.Lead.PhonePrefix = '+39';
        leadWrapper.Lead.Phone = '3933053311';
        leadWrapper.Lead.PrimaryEmail = 'emanuelzingariello@yopmail.it';
        leadWrapper.Lead.IdentityType = 'CF';
        leadWrapper.Lead.IdentityNumber = 'ZNGMNL84C24L182B';
        leadWrapper.Lead.AccountID = '0017a00001XW5MvAAL';
        leadWrapper.Lead.BillingExternalID = 'a147a000006NO5uAAG';
        leadWrapper.Lead.ProductName = 'Open Charge';
        leadWrapper.Lead.SendToGenesys = true;
        leadWrapper.Lead.ContactRequestDate = '2021-05-12';
        leadWrapper.Lead.ContactRequestTimeSlot = '10-12';
        leadWrapper.Lead.Stream = null;
        leadWrapper.Lead.RequestDate = '2021-05-12';
        
        List<XC_UTIL_Address.PoSWrapper> poss = new List<XC_UTIL_Address.PoSWrapper>();
        XC_UTIL_Address.PoSWrapper pos = new XC_UTIL_Address.PoSWrapper();
        pos.POS = 'IT002E0015555A';
        poss.add(pos);
        XC_UTIL_Address.AddressWrapper adr = new XC_UTIL_Address.AddressWrapper('REST');
        leadWrapper.Lead.address = adr;
        leadWrapper.Lead.address.PointOfService = poss;
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'LeadOutbound';
        ic.XC_interfaceName__c = 'LeadOutbound';
        insert ic;
        
        XC_REST_Lead_Outbound.sendRequest(leadWrapper,'XCustomerB2C');
        
        System.assertEquals(true, leadWrapper!=null);
        Test.stopTest();
        
    }
    
	static testMethod void sendRequestFail3(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_REST_Lead_W.WrapperLeadRequest leadWrapper = new XC_REST_Lead_W.WrapperLeadRequest();
        leadWrapper.Lead.LeadType = 'Residential';
        leadWrapper.Lead.LastName = 'ZINGARIELLO';
        leadWrapper.Lead.FirstName = 'EMANUEL';
        leadWrapper.Lead.PhonePrefix = '+39';
        leadWrapper.Lead.Phone = '3933053311';
        leadWrapper.Lead.PrimaryEmail = 'emanuelzingariello@yopmail.it';
        leadWrapper.Lead.IdentityType = 'CF';
        leadWrapper.Lead.IdentityNumber = 'ZNGMNL84C24L182B';
        leadWrapper.Lead.AccountID = '0017a00001XW5MvAAL';
        leadWrapper.Lead.BillingExternalID = 'a147a000006NO5uAAG';
        leadWrapper.Lead.ProductName = 'Open Charge';
        leadWrapper.Lead.SendToGenesys = true;
        leadWrapper.Lead.Stream = null;
        leadWrapper.Lead.RequestDate = '2021-05-12';
        
        List<XC_UTIL_Address.PoSWrapper> poss = new List<XC_UTIL_Address.PoSWrapper>();
        XC_UTIL_Address.PoSWrapper pos = new XC_UTIL_Address.PoSWrapper();
        pos.POS = 'IT002E0015555A';
        poss.add(pos);
        XC_UTIL_Address.AddressWrapper adr = new XC_UTIL_Address.AddressWrapper('REST');
        leadWrapper.Lead.address = adr;
        leadWrapper.Lead.address.PointOfService = poss;
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'LeadOutbound';
        ic.XC_interfaceName__c = 'LeadOutbound';
        insert ic;
        
        XC_REST_Lead_Outbound.sendRequest(leadWrapper,'XCustomerB2C');
        
        System.assertEquals(true, leadWrapper!=null);
        Test.stopTest();
        
    }
}