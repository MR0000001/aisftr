/**
 * @description       : XC_REST_Payment_Platform test class
 * @author            : alag@deloitte.es
 * @group             : 
 * @last modified on  : 18-11-2021
 * @last modified by  : alag@deloitte.es
**/
@isTest
public class XC_REST_Payment_Platform_Test {
    @testSetup
    static void setup(){
        NE__Order__c order = XC_DF_Order.createOrder('Asset');
        
    	NE__OrderItem__c orderItem = XC_DF_OrderItem.createOrderItem(order);
        orderItem.XC_PaymentMethod__c = 'Credit Card';
        orderItem.XC_BillingModel__c = 'One Shot';
        orderItem.XC_PaymentMethod__c = 'Online';
        insert orderItem;
		
		List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        insert accounts;
        
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        insert contacts;
    }
    
	@isTest
    static void checkIfIsPaymentPlatformTest(){
        List<NE__OrderItem__c> ois = [SELECT Id, NE__OrderId__c FROM NE__OrderItem__c];
        String recordId = String.valueOf(ois[0].NE__OrderId__c);
        Test.startTest();
        Map<String, String> resultado = XC_REST_Payment_Platform.checkIfIsPaymentPlatform(recordId);
        System.assert(resultado!=null, 'No se ha rellenado el mapa');
        Test.stopTest();
    }
    
    @isTest
    static void initPaymentPlatformRequestTest(){
        List<NE__OrderItem__c> ois = [SELECT Id, NE__OrderId__c FROM NE__OrderItem__c];
        
        Test.startTest();
        XC_REST_Payment_Platform.ResponseWrapper wrapper = XC_REST_Payment_Platform.initPaymentPlatformRequest(ois[0]);
        System.assert(wrapper!=null, 'No se ha rellenado el wrapper');
        Test.stopTest();
    }
    
    @isTest
    static void generateHeaderRequestTest(){
        Test.startTest();
        Map<String, String> header = XC_REST_Payment_Platform.generateHeaderRequest();
        System.assert(header!=null, 'No se ha rellenado el mapa');
        Test.stopTest();
    }
    
    @isTest
    static void generatePaymentPlatformBodyRequestTest(){
        List<NE__OrderItem__c> ois = [SELECT Id, NE__OrderId__c, XC_BillingProfileLineItem__c, NE__OrderId__r.CurrencyIsoCode, XC_BillingModel__c, NE__OrderId__r.NE__One_Time_Fee_Total__c FROM NE__OrderItem__c];
        Test.startTest();
        String resultado = XC_REST_Payment_Platform.generatePaymentPlatformBodyRequest(ois[0]);
        System.assert(!String.isBlank(resultado), 'No se ha generado la request');
        Test.stopTest();
    }
    
    @isTest
    static void generateCustomerInteractionTest(){
        List<NE__OrderItem__c> ois = [SELECT Id, NE__OrderId__c, XC_BillingProfileLineItem__c, NE__OrderId__r.CurrencyIsoCode, XC_BillingModel__c, NE__OrderId__r.NE__One_Time_Fee_Total__c, NE__OrderId__r.XC_Segment__c FROM NE__OrderItem__c];
        List<Contact> contacts = [SELECT Id, Name, Email, AccountId, XC_Preferredlanguageofcontact__c FROM Contact];
        XC_REST_Payment_Platform.ResponseWrapper wrapper = new XC_REST_Payment_Platform.ResponseWrapper('', 'test.test', '');
        
        Test.startTest();
        XC_REST_Payment_Platform.generateCustomerInteraction(ois[0], contacts[0], wrapper);
        List<XC_Customer_Interaction__c> interactions = [SELECT Id FROM XC_Customer_Interaction__c];
        System.assert(!interactions.isEmpty(), 'No se han generado las Custom Interactions');
        Test.stopTest();
    }
}