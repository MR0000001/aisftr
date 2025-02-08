/**
* @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 17/06/2019
* @date Modification 18/08/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description giic_CommonWrapper – Common Wrapper class for all functionalities
*/

public class Giic_CommonWrapper {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_CommonWrapper');

    /**
     * @author Pradeep Kumar -  Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
     * @date 17/06/2019
     * @description SalesOrderHeader wrapper
     */
    public class SalesOrderHeader {
        public Id accountId{get;set;}
        public String billingCity {get;set;}
        public String billingCountry {get;set;}
        public String billingName {get;set;}
        public String billingStateProvince {get;set;}
        public String billingStreet {get;set;}
        public String billingZipPostalCode {get;set;}
        public Boolean fieldServiceOrder {get;set;}
        public String fSLWorkOrder {get;set;}
        public String workOrderId {get;set;}
        public String legalEntity {get;set;}
        public String segment {get;set;}
        public String cig {get;set;} // NEW per NR1058
        public String cup {get;set;} // NEW per NR1058
        public String fSLWorkOrderLineItem {get;set;}
        public String workOrderLineItemID {get;set;}
        public Date orderDate {get;set;}
        public Date requiredDate {get;set;}
        public List<giic_CommonWrapper.SalesOrderLine> salesOrderLineList {get;set;}
        public Date scheduledDate {get;set;}
        public String shipToCity {get;set;}
        public String shipToCountry {get;set;}
        public String shipToName {get;set;}
        public String shipToStateProvince {get;set;}
        public String shipToStreet {get;set;}
        public String shipToZipPostalCode {get;set;}
        public Id warehouseId {get;set;}
        public Id fromWarehouseId {get;set;} 
        public Boolean isDelivery {get;set;}
        public Boolean dropShip{get;set;}
        public Boolean DirectPurchaseOrder{get;set;}
        public SalesOrderHeader(){
            this.dropShip=false;
            this.DirectPurchaseOrder=false;
            this.isDelivery=false;
        }
    }

    /**
     * @author Pradeep Kumar -  Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
     * @date 17/06/2019
     * @description SalesOrderLine wrapper
     */
    public class SalesOrderLine {
        public String prReqID {get;set;}
        public String productRequiredID {get;set;}
        public Boolean ownedByEnelX {get;set;}
        public Decimal orderQuantity {get;set;}
        public Id productId {get;set;}
        public Date requiredDate {get;set;}
        public String batchNumber {get;set;}
        public String lineDescription {get;set;}
        public Decimal unitPrice {get;set;}
        public String wbElement{get;set;}
        public String costCenter{get;set;}
    }

    /**
     * @author Pradeep Kumar -  Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
     * @date 17/06/2019
     * @description Exception wrapper
     */
    public class GOMException extends Exception {
        public string message;
        public string orderKey;
    }

    /**
     * @author Pradeep Kumar -  Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
     * @date 17/06/2019
     * @description SalesOrderCreationResult wrapper
     */
    public class SalesOrderCreationResult {
        public List<GOMException> exceptions {get;set;}
        public List<Id> newSalesOrderIds {get;set;}
        public list<ProductAvailability> lstProductAvailability{get;set;}
        public map<string,date> mapProductReqIdWithDates {get;set;}
        public SalesOrderCreationResult() {
            this.mapProductReqIdWithDates=new map<string,date>();
        }
    }

    /** @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description Sales order creation data wrapper
    */
    public class OrderResponse {
        public string fSLWorkOrder {get;set;}
        public boolean salesOrderNotCreated = false;
        public string fSLWorkOrderLineItem {get;set;}
        public string status {get;set;}
        @auraEnabled
        public list<string> errorMessages {get;set;}
        public list<ProductAvailability> lstProductAvailability{get;set;}
        public OrderResponse(){
            errorMessages=new list<string>();
        }
        public List<Giic_CommonWrapper.ProductErrorWrapper> listProductErrors = new List<Giic_CommonWrapper.ProductErrorWrapper>();
        public List<Giic_CommonWrapper.ProductWrapper> listProduct = new List<Giic_CommonWrapper.ProductWrapper>();
    }

    /** @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description purchase order header data wrapper
    */
    public class ProductAvailability{
        public String productRequiredID {get;set;}
        public string errorMessage {get;set;}
        public Date availabilityDate {get;set;}     
        public Id productId {get;set;}
    }

    /** @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description POHeader wrapper
    */
    public class POHeader{   
        public String supplierId {get;set;} 
        public String status {get;set;}
        public String salesOrderId {get;set;}
        public String shipTo{get;set;}
        public Date orderDate{get;set;}
        public Date requiredDate{get;set;}
        public Boolean dropShip {get;set;} 
        public List<giic_CommonWrapper.PurchaseOrderLine> pOLineList {get;set;}
    }

    /** @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description PurchaseOrderLine wrapper
    */
    public class PurchaseOrderLine{
        public Id purchaseOrderId {get;set;} 
        public Id productId {get;set;}
        public Decimal orderQuantity {get;set;}
        public Decimal unitPrice {get;set;}
        public Boolean dropShip {get;set;}
        public String shipTo {get;set;}   
    }

    /** @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description PurchaseOrderCreationResult wrapper
    */
    public class PurchaseOrderCreationResult {
        public List<GOMException> exceptions {get;set;}
        public List<Id> newPurchaseOrderIds {get;set;}
    }   
    
    /** @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description RMAHeader wrapper
    */
    public class RMAHeader{
        public Boolean centralReturn = false;
        public String caseId {get;set;}
        public String workOrderId {get;set;}
        public String workOrderLineItemId {get;set;}
        public String reason {get;set;}
        public String reference {get;set;}
        public Date rMADate {get;set;}
        public String shipmentId {get;set;}
        public String warehouseId {get;set;}
        public String accountId {get;set;}
        public String divisionCodeId {get;set;}
        public String accountName {get;set;}
        public String street {get;set;}
        public String city {get;set;}
        public String stateProvince {get;set;}
        public String zipPostalCode {get;set;}
        public String country {get;set;}
        public String documentText {get;set;}
        public String currencyIsoCode {get;set;}
        public list<RmaLine> rMALines {get;set;}
    }

    /** @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
    * @date Creation 17/06/2019
    * @description RmaLine wrapper
    */
    public class RmaLine{
        public Id shipmentDetailId {get;set;}
        public Id productId {get;set;}
        public Decimal rmaQuantity {get;set;}
        public Id productSerialId {get;set;}
        public Id productLotId {get;set;}
        public Id sellingUnitOfMeasureId {get;set;}
        public Boolean underWarranty = false;
    }

    /** @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
    * @date Creation 17/06/2019
    * @description RMAResponse wrapper
    */
    public class RMAResponse{
        public Id rMAId; 
        public Boolean isSuccess;
        public List<map<string, string>> errorList  {get;set;} 
        public RMAResponse() {
            errorList  =  new List<map<string, string>>();
        }
    }

    /** @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
    * @date Creation 17/06/2019
    * @description RMAReceiptResult wrapper
    */
    public class RMAReceiptResult {
        public List<gii.RMACreation.GOMException> exceptions {get;set;}
        public List<gii__RMAReceipt__c> listRMAReceipts {get;set;}
    }

    /** @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
    * @date Creation 17/06/2019
    * @description RMADisposition wrapper
    */
    public class RMADisposition {
        public Date dispositionDate {get;set;}
        public Id dispositionLocationId {get;set;}
        public Decimal dispositionQuantity {get;set;}
        public Id rMAReceiptId {get;set;}       
    }

    /** @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description RMADispositionResult wrapper
    */
    public class RMADispositionResult {
        public List<gii.RMACreation.GOMException> exceptions {get;set;}
        public List<gii__RMADisposition__c> listRMADispositions {get;set;}
    }  
    
    /**
    * @date Creation 17/06/2019
    * @description MediaMobileWrapper wrapper
    */
    public class MediaMobileWrapper{
        public String productCode;
        public Decimal price;
        public String inCurrency;
        public String legalEntity;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 18/08/2021
     * @description Wrapper to capture product errors
     */
    public class ProductErrorWrapper {
        public String prodId = '';
        public String prodCode = '';
        public String warehouseIds = '';
        public Decimal warehouseQuantity;
    }
    
    public class ProductWrapper {
        public Decimal reservedQty = 0;
        public Decimal purchasedQty = 0;
        public String purchaseOrderStatus = '';
        public String productId = '';
        public String purchaseOrderNumber = '';
        public String warehouseAccountId = '';
    }
 
    /*----------------------------*/ 

    /*public class workOrderHeader{
        public String workOrderNumber {get;set;}
        public String workOrderLineItem {get;set;}
        public  List<workOrderLineWrapper> sOLineList {get;set;}   
    }*/
    
   /*public class workOrderLineWrapper{
        public String productRequiredId {get;set;}
        public String batchNumber {get;set;}    
        public Decimal quantity {get;set;}  
    }*/

}