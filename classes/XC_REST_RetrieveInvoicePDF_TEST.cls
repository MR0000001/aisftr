@isTest
public class XC_REST_RetrieveInvoicePDF_TEST {
    
    @TestSetup
	static void setup(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_RetrieveInvoicePDF;
        ic.XC_interfaceName__c = Label.XC_CL_RetrieveInvoicePDF;
        ic.XC_ServerSystem__c = 'CommoditySpainB2C';
        ic.XC_Country__c = 'Spain';
        insert ic;
    }
	
    static testMethod void callToRetrieveInvoiceActive(){
        Test.startTest();  
            XC_REST_RetrieveInvoicePDF.WrapperRetrieveInvoice inputWr = getWrapperRetrieveInvoice();
        	XC_REST_RetrieveInvoicePDF.WrapperResponse invPDFres = XC_REST_RetrieveInvoicePDF.callToRetrieveInvoice(inputWr);
            System.assert(invPDFres!=null);
        Test.stopTest();
    }
	
    static testMethod void callToRetrieveInvoiceActiveWithoutBusinessLine(){
        Test.startTest();  
            XC_REST_RetrieveInvoicePDF.WrapperRetrieveInvoice inputWr = getWrapperRetrieveInvoice();
        	inputWr.BusinessLine = '';
        	XC_REST_RetrieveInvoicePDF.WrapperResponse invPDFres = XC_REST_RetrieveInvoicePDF.callToRetrieveInvoice(inputWr);
            System.assert(invPDFres!=null);
        Test.stopTest();
    }
	
    static testMethod void callToRetrieveInvoiceActiveWithoutProcessDate(){
        Test.startTest();  
            XC_REST_RetrieveInvoicePDF.WrapperRetrieveInvoice inputWr = getWrapperRetrieveInvoice();
            inputWr.ProcessDate = null;
        	XC_REST_RetrieveInvoicePDF.WrapperResponse invPDFres = XC_REST_RetrieveInvoicePDF.callToRetrieveInvoice(inputWr);
            System.assert(invPDFres!=null);
        Test.stopTest();
    }
	
    static testMethod void callToRetrieveInvoiceActiveWithoutSystemDate(){
        Test.startTest();  
            XC_REST_RetrieveInvoicePDF.WrapperRetrieveInvoice inputWr = getWrapperRetrieveInvoice();
            inputWr.SystemDate = null;
        	XC_REST_RetrieveInvoicePDF.WrapperResponse invPDFres = XC_REST_RetrieveInvoicePDF.callToRetrieveInvoice(inputWr);
            System.assert(invPDFres!=null);
        Test.stopTest();
    }
    
    private static XC_REST_RetrieveInvoicePDF.WrapperRetrieveInvoice getWrapperRetrieveInvoice(){
        XC_REST_RetrieveInvoicePDF.WrapperRetrieveInvoice invWR = new XC_REST_RetrieveInvoicePDF.WrapperRetrieveInvoice();
        invWR.InvoiceID = 'CMF701N0048296'; //(String)invDataMap.get('InvoiceNumber'); //
        invWR.InvoiceSequential = '281';
        invWR.ContractID = '11111111'; //(String)invDataMap.get('ContractID'); //
        invWR.CompanyOwner = '70'; //(String)invDataMap.get('CompanyCode'); //
        invWR.BusinessLine = '123456789'; //(String)invDataMap.get('BusinessLine')
        invWR.ProcessDate = (Datetime.now()).format('yyyyMMdd'); //Date.today(); //
        invWR.PaymentGateway  = 'EE';
        invWR.ContractNumber = '22'; //(String)invDataMap.get('ContractNumber'); //
        invWR.InvoiceCode = '60009939037'; //(String)invDataMap.get('InvoiceReference'); //
        invWR.Market = 'ML';
        invWR.User = 'X-CUSTOMER';
        invWR.SystemDate = (Datetime.now()).format('yyyyMMdd'); //Date.today(); //
        invWR.UserID = 'X-CUSTOMER';
        invWR.Password = 'X-CUSTOMER';
        invWR.InvoiceType = '1'; //'04'; //
        invWR.DocumentType = '';
        invWR.OrigenSystem = '33'; //
        return invWR;
    }
}