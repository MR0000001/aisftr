/**
* @author Simone Trenta - strenta@deloitte.it, Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation 29/01/2020
* @description REST INTERFACE : Invoice Object 
*/   
public without sharing class XC_REST_Invoice_U {

    /*
     * @description validateGetRequest invoice
     * @param mapHeader the header
     * @param requestParams the param
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     */
    public static XC_UTIL_Integration.WrapperResult validateGetRequest(Map<String, String> mapHeader, Map<String, String> requestParams){

        XC_UTIL_Integration.WrapperResult validateResult = XC_UTIL_RESTInbound.checkObjectPermission('Zuora__ZInvoice__c', 'read');
        if(validateResult.errorFlag) {
            return validateResult; 
        }

        // Validate Header
        validateResult = XC_UTIL_Integration.validateHeader(mapHeader);
        if(validateResult.errorFlag) {
            return validateResult; 
        }
        
        // Validate Query String Parameters
        if (String.isblank(requestParams.get('account_id')) && String.isblank(requestParams.get('order_item_id')) && String.isblank(requestParams.get('asset_id'))){
            validateResult.errorMessage = 'At least one of this fields is mandatory: account_id, order_item_id, asset_id';
            validateResult.errorFlag = true; 
        }  
        if (String.isblank(requestParams.get('start_date')) || String.isblank(requestParams.get('end_date'))) {
            validateResult.errorMessage = 'Missing one of this fields: start_date and end_date';
            validateResult.errorFlag = true; 
        }      

        return validateResult;
    }


    /*
     * @description getInvoiceResult getInvoiceResult
     * @param params the params
     * @author Simone Trenta - strenta@deloitte.it
     */
    public static List<XC_REST_Invoice_W.InvoiceInboundWrapper> getInvoiceResult(Map<String,String> params){
        List<XC_REST_Invoice_W.InvoiceInboundWrapper> result = new List<XC_REST_Invoice_W.InvoiceInboundWrapper>();

        List<Zuora__ZInvoice__c> invList = getInvoice(params);
        if(invList.isEmpty()){
            return result;
        }

        for(Zuora__ZInvoice__c i:invList){
            result.add(getInvoiceWrapper(i));
        }

        return result;
    }




    private static List<Zuora__ZInvoice__c> getInvoice(Map<String,String> params){
        List<Zuora__ZInvoice__c> res = new List<Zuora__ZInvoice__c>();

        String acid = params.get('account_id');
        String asid = params.get('asset_id');
        String orid = params.get('order_item_id');

        DateTime startDate = DateTime.valueOf(params.get('start_date')+' 00:00:00');
        DateTime endDate = DateTime.valueOf(params.get('end_date')+' 24:00:00');

        String status = 'Posted';
        String queryString =  
            'SELECT Name, Id, Zuora__BillingAccount__r.Zuora__PaymentMethodType__c, Zuora__BillingAccount__r.XC_BillingProfLineItem_LookUp__r.XC_BillingProfile__r.NE__Card_Type__c, '
            + 'Zuora__TotalAmount__c, Zuora__Balance2__c, Zuora__PaymentAmount__c, Zuora__CreatedDate__c, '
            + 'Zuora__BillingAccount__r.XC_BillingProfLineItem_LookUp__r.XC_BillingProfileName__c, CreatedDate, '
            + '(SELECT id, Zuora__Subscription__c, Zuora__ProductDescription__c, Zuora__Charge_Amount2__c FROM Zuora__Invoice_Items__r) '
            + 'FROM Zuora__ZInvoice__c WHERE Zuora__Status__c=:status AND CreatedDate>=:startDate AND CreatedDate<=:endDate AND Zuora__Account__c =: acid ';

        Map<String, Asset> assmap = new Map<String, Asset>();

        if(!String.isblank(acid)){
            return Database.query(String.escapeSingleQuotes(queryString));

        } else if(!String.isblank(asid)){
            assmap = new Map<String, Asset>([SELECT Id, XC_Subscription__c, XC_Subscription__r.Zuora__SubscriptionNumber__c, AccountID FROM Asset WHERE Id =: asid]);

        } else if(!String.isblank(orid)){
            assmap = new Map<String, Asset>([SELECT Id, XC_Subscription__c, XC_Subscription__r.Zuora__SubscriptionNumber__c, AccountID FROM Asset WHERE XC_Original_Configuration_Item__c =: orid]);
        }
        
        List<String> subid = new List<String>();
        List<String> subnum = new List<String>(); 
        for(Asset a : assmap.values()){
            subid.add(a.XC_Subscription__c);
            subnum.add(a.XC_Subscription__r.Zuora__SubscriptionNumber__c);
            acid = a.AccountID;
        }
        queryString += 'AND Id in (SELECT Zuora__Invoice__c FROM Zuora__InvoiceItem__c WHERE (Zuora__Subscription__c in: subid AND Zuora__Subscription__c != null) OR (XC_SubscriptionNumber__c in: subnum AND XC_SubscriptionNumber__c != null))';

        return Database.query(String.escapeSingleQuotes(queryString));
    }


	@TestVisible
    private static XC_REST_Invoice_W.InvoiceInboundWrapper getInvoiceWrapper(Zuora__ZInvoice__c invoice){
        XC_REST_Invoice_W.InvoiceInboundWrapper invWr = new XC_REST_Invoice_W.InvoiceInboundWrapper();

        invWr.invoice_number = invoice.Name;
        invWr.zuora_invoice_id = invoice.Id;
        invWr.payment_method = invoice.Zuora__BillingAccount__r.XC_BillingProfLineItem_LookUp__r.XC_BillingProfile__r.NE__Card_Type__c;
        invWr.invoice_amount = invoice.Zuora__TotalAmount__c==null?'':String.valueOf(invoice.Zuora__TotalAmount__c);
        invWr.invoice_balance = invoice.Zuora__Balance2__c==null?'':String.valueOf(invoice.Zuora__Balance2__c);
        invWr.invoice_paid_amount = invoice.Zuora__PaymentAmount__c==null?'':String.valueOf(invoice.Zuora__PaymentAmount__c);
        invWr.invoice_created_date = invoice.CreatedDate==null?null:Date.valueOf(invoice.CreatedDate);
        invWr.payment_method_information = invoice.Zuora__BillingAccount__r.XC_BillingProfLineItem_LookUp__r.XC_BillingProfileName__c;

        if(invoice.Zuora__Invoice_Items__r.isEmpty()){
            return invWr;
        }

        invWr.InvoiceItem = new List<XC_REST_Invoice_W.InvoiceItemInboundWrapper>();
        for(Zuora__InvoiceItem__c item:invoice.Zuora__Invoice_Items__r){
            XC_REST_Invoice_W.InvoiceItemInboundWrapper itemWr = new XC_REST_Invoice_W.InvoiceItemInboundWrapper();
            itemWr.single_item_amount = item.Zuora__Charge_Amount2__c==null?'':String.valueOf(item.Zuora__Charge_Amount2__c); //somma tax + amout 
            itemWr.product_description = item.Zuora__ProductDescription__c; //zuora charge
            /*
            Zuora__Charge_Amount2__c  + Zuora__TaxAmount2__c 
            Zuora__Charge_Name__c 
            */
            invWr.InvoiceItem.add(itemWr);
        }

        return invWr;
    }



}