public with sharing class PurchaseOrderController {
    
    public String POCorrente {get; set;}
    
    public gii__PurchaseOrder__c PO {get;set;}
    public List<gii__PurchaseOrderLine__c> POLines {get; set;}
    
    public PurchaseOrderController(apexpages.standardcontroller stdcontroller) {
        
        POCorrente = ApexPages.currentPage().getParameters().get('id');
        
        If (POCorrente!=Null) {
            PO = [ Select Id,CurrencyIsoCode, giic_Status__c,gii__DeliveryTerms__c,gii__ShipToName__c, gii__SupplierName__c, gii__SupplierStreet__c, gii__SupplierCity__c, gii__SupplierStateProvince__c, gii__SupplierZipPostalcode__c, gii__SupplierCountry__c, Name, gii__PaymentTerms__c, gii__APPaymentTerms__r.name, gii__carrier__r.Name, gii__Buyer__r.Name, gii__SupplierContact__r.Name, gii__ShipToStreet__c, gii__ShipToCity__c, gii__ShipToStateProvince__c, gii__ShipToZipPostalCode__c, gii__ShipToCountry__c, gii__InvoiceToName__c, gii__InvoiceToStreet__c, gii__InvoiceToCity__c, gii__InvoiceToStateProvince__c, gii__InvoiceToZipPostalCode__c, gii__InvoiceToCountry__c, gii__GrossAmount__c, gii__SupplierDiscountAmount__c, gii__OrderAmount__c , gii__PrintDocumentText__c, gii__DocumentText__c, giic_POCode__c from gii__PurchaseOrder__c WHERE id=:POCorrente];       
            POLines = [Select Id,gii__PurchaseOrder__c,  Name,gii__Product__r.name,gii__Product__c, gii__LineDescription__c, gii__Product__r.gii__ProductCode__c, gii__Service__c, gii__ServiceStartDate__c, gii__ServiceEndDate__c, gii__StockUM__c, gii__BuyingUnitofMeasure__c, gii__BuyingUnitofMeasure__r.name, gii__Taxable__c, gii__OrderQuantity__c,gii__CancelReason__c, gii__UnitPrice__c, gii__LineNetAmount__c from gii__PurchaseOrderLine__c where gii__PurchaseOrder__c =:POCorrente];
        }
    }
    
}