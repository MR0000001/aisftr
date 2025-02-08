/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  28/05/2019 
* @description XC_UTIL_ResultWrapper_TEST – Test class for XC_UTIL_ResultWrapper
*/
@isTest
public class XC_REST_RetrieveInvoice_TEST {
    
    
    //Test Method callToRetriveInvoice
    static testMethod void callToRetriveInvoice(){
        
        string serverSystem= 'test';
        XC_REST_RetrieveInvoice.InvoiceWrapper invoiceWr = new XC_REST_RetrieveInvoice.InvoiceWrapper();
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name =Label.XC_CL_RetriveInvoice;
        ic.XC_interfaceName__c = Label.XC_CL_RetriveInvoice;
        ic.XC_URL_Required__c = 'test';
        insert ic;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_RetrieveInvoice_MOCK());
        
        Test.startTest(); 
        XC_REST_RetrieveInvoice.callToRetriveInvoice( invoiceWr,  serverSystem);
        system.assertEquals(true, ic!=null);
        Test.stopTest();
        
        
        
    }
    
    //Test Method callToRetriveInvoice2
    static testMethod void callToRetriveInvoice2(){
        
        string serverSystem= 'test';
        XC_REST_RetrieveInvoice.InvoiceWrapper invoiceWr = new XC_REST_RetrieveInvoice.InvoiceWrapper();
        
        
        XC_REST_RetrieveInvoice.callToRetriveInvoice( invoiceWr,  serverSystem);
        system.assertEquals(true, invoiceWr!=null);
        
    }
    
    
   
   
    
   
}