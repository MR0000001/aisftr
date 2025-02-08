/**
 * @description The Class XC_REST_InventoryAdjustment_U.
 * @author Simone Trenta - strenta@deloitte.it
 * @date Creation 07/10/2019 
 * @description REST Utility Class for PurchaseOrder Interface
 */ 
public without sharing class XC_REST_InventoryAdjustment_U {

    /**
     * @description wrapper class for request 
     */
    public class RequestWrapper{
        public List<WharehouseInventoriesWrapper> warehouse_inventories;
    }

    /**
     * @description wrapper class for request 
     */
    public class WharehouseInventoriesWrapper{
        public String warehouse_code;
        public Integer quantity;
        public String location;
        public String location_to;
        public String product_code;
        public String sku_code;
        public String ean_code;
        public String reason;

        public List<SerialNumbersWrapper> serial_numbers;
    }

    /**
     * @description wrapper class for request 
     */
    public class SerialNumbersWrapper{
        public String serial_number;
    }

    /**
     * @description wrapper class for response 
     */
    public class ResponseWrapper {
        public XC_UTIL_Integration.ResultSnakeCase result;
        
        /**
        * @description the constructor
        */
        public ResponseWrapper(){ 
            this.result = new XC_UTIL_Integration.ResultSnakeCase();
        }
    }


    /**
     * @description validate request
     * @param params the wrapper
     * @param header the header
     * @return the wrapper result
     */
    public static XC_UTIL_Integration.WrapperResult validatePutRequest(RequestWrapper params, Map<String,String> header){
        XC_UTIL_Integration.WrapperResult result = XC_UTIL_Integration.validateHeader(header);
        if(result.errorFlag) {
            return result; 
        }

        result = XC_UTIL_RESTInbound.checkObjectPermission('gii__TransferOrder__c', 'read'); //tbd what object
        if(result.errorFlag){
            return result; 
        } 

        
        if(params.warehouse_inventories == null || params.warehouse_inventories.isEmpty()){
            result.errorMessage = 'ERROR. Missing mandatory field: warehouse_inventories';
            result.errorFlag = true;
            return result; 
        }  

        for(WharehouseInventoriesWrapper wr:params.warehouse_inventories){
            result = validateWarehouseInventory(wr);
            if(result.errorFlag){
                return result; 
            }
        }

        return result;
    }

    private static XC_UTIL_Integration.WrapperResult validateWarehouseInventory(WharehouseInventoriesWrapper wr){
        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();

        Map<String,Object> allOfThis = new Map<String,Object>{
            'warehouse_code'=>wr.warehouse_code,
            'quantity'=>wr.quantity,
            'location'=>wr.location,
            'reason'=>wr.reason
        };    

        result = XC_UTIL_Integration.checkMandatory(allOfThis);
        if(result.errorFlag) {
            return result; 
        }

        if(String.isBlank(wr.product_code)&&String.isBlank(wr.ean_code)){
            result.errorMessage = 'ERROR. Missing one of this fields: warehouse_inventories.product_code, warehouse_inventories.ean_code';
            result.errorFlag = true;
            return result; 
        }

        if(wr.serial_numbers==null || wr.serial_numbers.isEmpty()){
            return result; 
        }

        for(SerialNumbersWrapper wrs:wr.serial_numbers){
            if(String.isBlank(wrs.serial_number)){
                result.errorMessage = 'ERROR. Missing mandatory field: serial_number';
                result.errorFlag = true;
                return result; 
            }
        }

        return result;
    }

    /**
    * @description validate request
    * @param params the wrapper
    * @return the wrapper result
    */
    public static ResponseWrapper inventoryAdjustment(RequestWrapper params){
        ResponseWrapper resultWR = new ResponseWrapper();
        //
        // GLOVIA FA COSE
        //
        List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper> inventoryWrappers = new List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper>();
        for(WharehouseInventoriesWrapper whReq : params.warehouse_inventories){
            giic_UTIL_CheckInventory.Giic_InputInventoryWrapper inventoryWR = new giic_UTIL_CheckInventory.Giic_InputInventoryWrapper ();
            inventoryWR.wareHouseCode = whReq.warehouse_code;
            inventoryWR.prod2Code =whReq.product_code;
            inventoryWR.sku_code = whReq.sku_code;
            inventoryWR.eanCode = whReq.ean_code;
            inventoryWR.quantity = whReq.quantity;
            inventoryWR.reason = whReq.reason;
            inventoryWR.location = whReq.location;
            inventoryWR.locationTo = whReq.location_to;
            List<String> serials = new List<String>();
            if(whReq.serial_numbers != null){
                for(SerialNumbersWrapper serial :  whReq.serial_numbers){
                    serials.add(serial.serial_number);
                }                
                inventoryWR.serials = serials;
            }
           
            inventoryWrappers.add(inventoryWR);
        }
        
        List<XC_UTIL_Sobject.WrapperResult> response = giic_UTIL_CheckInventory.checkInventory(inventoryWrappers);    
        for(XC_UTIL_Sobject.WrapperResult res : response){
            if(!res.success){ 
                resultWR.result.message = res.errorMessage;
                resultWR.result.error_code = '500';
            }else{
                resultWR.result.message = 'Operation completed successfully';
                resultWR.result.error_code = '0';   
            }
        } 
        return resultWR;
    }

}