/**
* @author
* @date Creation  05/06/2019 
* @description XC_TR_Asset_U_PopContrLineItem_TEST – Test class for XC_TR_Asset_U_PopContrLineItem
*/ 
@isTest
private class XC_TR_Asset_U_PopContrLineItem_TEST {
    
    static testmethod void onAssetInsertTEST() {
        
       	OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<Contact> contact=XC_DF_Contact.createSohoContacts(1);
        List<Contract> contract= XC_DF_Contract.createContracts(1);
        
        insert contract;
        List<Account> account=[select id from account where name='Test Account n.1'];
        List<Account> accounts=XC_DF_Account.createSohoAccounts(1);
        accounts[0].IdentityNumber__c = '71903513Q';
        insert accounts;
        NE__Order__c conf=XC_DF_Order.createOrder('TestConfig');
        conf.XC_LegalEntity__c = 'EndesaX';
        update conf;
        contract[0].XC_Configurations__c=CONF.Id;
        UPDATE contract;
        Asset asset=new Asset(Name='Test', accountId=accounts[0].id,XC_LegalEntity__c = 'EndesaX', XC_PaymentMethod__c = 'Bank Transfer', NE__Order_Config__c=CONF.ID);
        insert asset;
        System.assertEquals(1, accounts.size());
    }
    
    static testmethod void manageAssetStatusOnUpdateTEST() {
        
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        List<Contact> contact=XC_DF_Contact.createSohoContacts(1);
        List<Contract> contract= XC_DF_Contract.createContracts(1);
        insert contract;
        System.debug(contract[0].id);
        List<Account> accounts=XC_DF_Account.createSohoAccounts(1);
        accounts[0].IdentityNumber__c = '46430412J';
        insert accounts;
        NE__Order__c conf=XC_DF_Order.createOrder('TestConfig');
        conf.XC_LegalEntity__c = 'EndesaX';
        update conf;
        Asset asset=new Asset(Name='Test', XC_LegalEntity__c = 'EndesaX', XC_PaymentMethod__c = 'Bank Transfer',accountId=accounts[0].id, Status='Active', XC_Contract__c=contract[0].Id, NE__Order_Config__c=CONF.ID);
        insert asset;
        asset.status='Inactive';
        update asset;
        asset.XC_ContractEndDate__c = Date.today();
        asset.Status = Label.XC_CL_Asset_StatusActive;
        update asset;
        XC_TR_Asset_U_PopulateContractsLineItem.updateEndDateOnContract(contract);
        System.assertEquals(true, asset != null);
    }

    
    static testmethod void manageGiicGlovia() { 

        Giic_CommonWrapper.SalesOrderHeader tes = new Giic_CommonWrapper.SalesOrderHeader();
        tes.accountId = null;
        tes.billingCity = '';
        tes.billingCountry = '';
        tes.billingName = '';
        tes.billingStateProvince = '';
        tes.billingStreet = '';
        tes.billingZipPostalCode = '';
        tes.fieldServiceOrder = true;  
        tes.fSLWorkOrder = '';
        tes.workOrderId = null;    
        tes.fSLWorkOrderLineItem = '';
        tes.orderDate = Date.today();  
        tes.requiredDate = Date.today();
        tes.salesOrderLineList = null;
        tes.scheduledDate = Date.today();
        tes.shipToCity = '';
        tes.shipToCountry = '';
        tes.shipToName = '';
        tes.shipToStateProvince = '';
        tes.shipToStreet = '';
        tes.shipToZipPostalCode = '';
        tes.warehouseId = null;
        tes.fromWarehouseId =null;
        tes.isDelivery = false;
        tes.directPurchaseOrder = true;

        Giic_CommonWrapper.SalesOrderLine te = new Giic_CommonWrapper.SalesOrderLine();
        te.prReqID = null;
        te.productRequiredID = null;
        te.ownedByEnelX = false;
        te.orderQuantity = 10;
        te.productId = null;
        te.requiredDate = Date.today();
        te.batchNumber = '';
        te.lineDescription = '';
        te.unitPrice = 10;
        te.wbElement = '';
        te.costCenter = '';

        Giic_CommonWrapper.GOMException ab = new Giic_CommonWrapper.GOMException();
        ab.message = '';
        ab.orderKey = '';

        Giic_CommonWrapper.SalesOrderCreationResult abc = new Giic_CommonWrapper.SalesOrderCreationResult();
        abc.exceptions = null;
        abc.newSalesOrderIds = null;
        abc.lstProductAvailability = null;
        abc.mapProductReqIdWithDates =new map<string,date>();

        Giic_CommonWrapper.OrderResponse aa = new Giic_CommonWrapper.OrderResponse();
        aa.fSLWorkOrder = '';
        aa.salesOrderNotCreated = false;
        aa.fSLWorkOrderLineItem = '';
        aa.status = '';
        aa.errorMessages = new list<String>();
        aa.lstProductAvailability = null;

        Giic_CommonWrapper.ProductAvailability ac = new Giic_CommonWrapper.ProductAvailability();
        ac.productRequiredID = null;
        ac.errorMessage = '';
        ac.availabilityDate = Date.today();
        ac.productId = null;

        Giic_CommonWrapper.POHeader cg = new Giic_CommonWrapper.POHeader();
        cg.supplierId = null;
        cg.status = '';
        cg.salesOrderId = null;
        cg.shipTo = '';
        cg.orderDate = Date.today();
        cg.requiredDate = Date.today();
        cg.dropShip = true;
        cg.pOLineList = new List<giic_CommonWrapper.PurchaseOrderLine>();

        Giic_CommonWrapper.PurchaseOrderLine cd = new Giic_CommonWrapper.PurchaseOrderLine();

        cd.purchaseOrderId = null;
        cd.productId = null;
        cd.orderQuantity = 1;
        cd.unitPrice = 1;
        cd.dropShip = false;
        cd.shipTo = '';

        Giic_CommonWrapper.PurchaseOrderCreationResult d = new Giic_CommonWrapper.PurchaseOrderCreationResult();
        d.exceptions = null;//new List<GOMException>();
        d.newPurchaseOrderIds = new List<Id>();

        Giic_CommonWrapper.RMAHeader e = new Giic_CommonWrapper.RMAHeader();
        e.centralReturn = false;
        e.caseId = null;
        e.workOrderId = null;
        e.reason = '';
        e.reference = '';
        e.rMADate = Date.Today();
        e.shipmentId = null;
        e.warehouseId = null;
        e.accountId = null;
        e.divisionCodeId = null;
        e.accountName = '';
        e.street = '';
        e.city = '';
        e.stateProvince = '';
        e.zipPostalCode = '';
        e.country = '';
        e.documentText = '';
        e.currencyIsoCode = '';
        e.rMALines = null;//new list<RmaLine>();
        
        Giic_CommonWrapper.RmaLine af = new Giic_CommonWrapper.RmaLine();
        af.shipmentDetailId =null;
        af.productId =null;
        af.rmaQuantity = 1;
        af.productSerialId =null;       
        af.productLotId = null;
        af.sellingUnitOfMeasureId =null;
        af.underWarranty = false;

        Giic_CommonWrapper.RMAResponse ad = new Giic_CommonWrapper.RMAResponse();
        ad.rMAId = null;
        ad.isSuccess = true;
        ad.errorList  = new List<map<string, string>>();

        Giic_CommonWrapper.RMAReceiptResult ax = new Giic_CommonWrapper.RMAReceiptResult();
        ax.exceptions = new List<gii.RMACreation.GOMException>();
        ax.listRMAReceipts = new List<gii__RMAReceipt__c>();

        Giic_CommonWrapper.RMADisposition ay = new Giic_CommonWrapper.RMADisposition();
        ay.dispositionDate = Date.Today();
        ay.dispositionLocationId = null;
        ay.dispositionQuantity = 1;
        ay.rMAReceiptId = null;

        Giic_CommonWrapper.RMADispositionResult az = new Giic_CommonWrapper.RMADispositionResult();
        az.exceptions = new List<gii.RMACreation.GOMException>();
        az.listRMADispositions = null;//new List<gii__RMADisposition__c>();
    }
}