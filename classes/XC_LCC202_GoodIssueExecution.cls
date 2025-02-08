/**
// dpalamides - 
* @date Creation 30/07/2019
* @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
* @description Send ENEL X Material To Logistic process
*/
public without sharing class XC_LCC202_GoodIssueExecution {
    /**
    * @author dpalamides - 
    * @date Creation 22/06/2019
    * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
    * @description // wrapper class with @AuraEnabled and {get;set;} properties 
    */
    public class ParamToGloviaSoli{
        /** @description param account to passa API create Sales Order Glovia */
        public String accountId;
        /** @description param product Id to pass API Glovia. */
        public String product2Id;
        /** @description The contract id. */
        public string unitPrice;
        /** @description The contract id. */
        public string quantity;
        /** @description The contract id. */
        public boolean ownedByEnelX;
        /** @description The contract id. */
        public String productRequiredId;
        /** @description The contract id. */

    }



    /*
  * @author dpalamides - 
  * @date Creation 22/06/2019
  * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
  * @description // wrapper class with @AuraEnabled and {get;set;} properties 
  */

    public class ResultOtherPA{
        /** @description result operation */
        @AuraEnabled
        public boolean result{get;set;}
        /** @description message operation */
        @AuraEnabled
        public String message{get;set;}
        /** @description type message operation success/error */
        @AuraEnabled
        public String typeMessage{get;set;}
        /** @description title modal message */
        @AuraEnabled
        public String titleMessage{get;set;}
        /** @description NE_OrderItem__c.XC_WBE__c on commercial item choose */
        @AuraEnabled
        public String wbeElement{get;set;}
        /** @description NE_OrderItem__c.XC_costCenter__c on commercial item choose  */
        @AuraEnabled
        public String costCenter{get;set;}
    }

    /*
  * @author dpalamides - 
  * @date Creation 22/06/2019
  * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
  * @description // wrapper class with @AuraEnabled and {get;set;} properties 
  */
    public class ParamToGloviaSO{
        /** @description The contract id. */
        public string accountId;
        /** @description The contract id. */
        public string fSLWorkOrder;
        /** @description The contract id. */
        public string warehouseId;
        /** @description The contract id. */
        public string shipToCity;
        /** @description The contract id. */
        public string shipToCountry;
        /** @description The contract id. */
        public string shipToStateProvince;
        /** @description The contract id. */
        public string shipToStreet;
        /** @description The contract id. */
        public string shipToZipPostalCode;
        /** @description The contract id. */
        public string fSLWorkOrderLineItem;
        /** @description The contract id. */
        public Datetime orderDate;
        /** @description The contract id. */
        public Boolean directPurchaseOrder;


    }

    /*
    * @author dpalamides - 
    * @date Creation 22/06/2019
    * @description // get Country ConfigurationItem 
    * @param workOrderLineItemId String
    * @return XC_NE_AddTechnicalItems_Controller.ResultAndMessage
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper getAllProductRequired(String workOrderLineItemId){

        List<WorkOrderLineItem> lstWOLI = (List<WorkOrderLineItem>) XC_UTIL_Sobject.selectAllFields(workOrderLineItemId);
        XC_UTIL_ResultWrapper rAndM = new XC_UTIL_ResultWrapper();

        if (!lstWOLI.isEmpty() && lstWOLI.get(0) != null ) {
            if (lstWOLI.get(0).XC_MaterialRequest__c == null) {
                rAndM.resultMessage = 'Please fill in the Material Request field';
                rAndM.success = false;
                rAndM.typeMessage ='Error';
                rAndM.titleMessage = Label.XC_CL_Error;
                return rAndM;
            }else if (lstWOLI.get(0).XC_WOLIType__c == 'Good Issue' && lstWOLI.get(0).Status == 'Completed') {
                rAndM.resultMessage = 'The ' + lstWOLI.get(0).XC_WOLIType__c +' has already been completed';
                rAndM.success = false;
                rAndM.typeMessage ='Error';
                rAndM.titleMessage = Label.XC_CL_Error;
                return rAndM;
            }
        }

        List<XC_ProductConsumed__c> relatedConsumeds = [SELECT Id, XC_WBE__c from XC_ProductConsumed__c where XC_WorkOrderLineItem__c =: workOrderLineItemId and XC_WBE__c = null];
        if (relatedConsumeds.size() > 0) {
            rAndM.resultMessage = Label.Fill_WBE_ProductConsumed;
            rAndM.success = false;
            rAndM.typeMessage ='Error';
            rAndM.titleMessage = Label.XC_CL_Error;
            return rAndM;
        }

        List<XC_UTIL_Sobject.WrapperResult> resWrapp = XC_UTIL_WOLICreateGoodIssue.createGoodIssueFromSalesOrder(lstWOLI);

        XC_UTIL_Debug.debug(false,'Donato'+ resWrapp[0].errorMessage);

        //String don = resWrapp[0].errorMessage.remove('ProductErrorWrapper:[').removeEnd('])');
        Map<String,String> mapErroreMessage = new Map<String,String>();
        //String a = JSON.serialize(soCreationResult.listProductErrors);
        List<Map<String,String>> listMap = new List<Map<String,String>>();
        listMap = convertMessage(resWrapp[0].errorMessage);
        String a = JSON.serialize(resWrapp[0].errorMessage);
        XC_UTIL_Debug.debug(false,'mapo a '+ a);
        String b = String.valueOf(JSON.deserializeUntyped(a));
        XC_UTIL_Debug.debug(false,'mapo b '+ b);
        XC_UTIL_Debug.debug(false,'Donato --> '+ mapErroreMessage);
        if(resWrapp != null && !resWrapp.isEmpty() && listMap.isEmpty()){
            rAndM.success = resWrapp[0].success;
            rAndM.resultMessage = resWrapp[0].errorMessage;
        }
        if(!listMap.isEmpty()){
            rAndM.success = false;
            rAndM.resultMessage = Label.Prod_Cons_Err_Msg;
            Set<String> setProductCode = new Set<String>();
            for(Map<String,String> mapo :listMap) {
                System.debug('mapo' + mapo);
                System.debug('mapo' + mapo.keySet());
                for(String s: mapo.keySet()){
                    System.debug('m'+s);
                }
                System.debug('mapo code ' + mapo.get('ProductErrorWrapper:{prodCode'));
                //System.debug('mapo' + mapo[0].keySet());
                if(mapo.get('ProductErrorWrapper:{prodCode')!=null){
                    setProductCode.add(mapo.get('ProductErrorWrapper:{prodCode'));
                }
            }
            System.debug('DDD'+ setProductCode);
            List<XC_ProductConsumed__c> productConsumedToUpdate = new List<XC_ProductConsumed__c>();
            productConsumedToUpdate = [SELECT id, XC_ProductCode__c, XC_ErrorMessage__c, XC_WorkOrderLineItem__c, XC_QuantityConsumed__c FROM XC_ProductConsumed__c where XC_ProductCode__c =:setProductCode];
            for (XC_ProductConsumed__c prd : productConsumedToUpdate) {
                for(Map<String, String> mapo : listMap){
                    //System.debug('*donato'+ prd.XC_ProductCode__c);
                    //System.debug('*donato'+  mapo.get('prodCode'));
                    if(prd.XC_ProductCode__c == mapo.get('ProductErrorWrapper:{prodCode')){
                        prd.XC_ErrorMessage__c = Label.ProdWarehouseQuantity + ' :' + mapo.get('warehouseQuantity').remove('}');
                        prd.XC_OriginalConsumedQuantity__c = prd.XC_QuantityConsumed__c;
                    }
                }

            }
            lstWOLI[0].XC_GoodIssueParziale__c = true;
            update lstWOLI;
            update productConsumedToUpdate;
        }

        if(rAndM.success){
            XC_FutureProductRequiredUpdate.updateProductRequired(workOrderLineItemId);
        }

        String checkIfErrors = chechErrorLogs(lstWOLI);
        XC_UTIL_Debug.debug(false,'error logs check: ' + checkIfErrors);
        return rAndM;

    }
    
    public static List<Map<String,String>> convertMessage(String errorMessage) {
        List<Map<String, String>> listMap = new List<Map<String, String>>();
        if(String.isBlank(errorMessage)){
            return listMap;
        }
        String remove = errorMessage.remove('(').remove(')');
        String rm = remove.replace('[','{').replace(']','}');
        List<String> listRemove = rm.split('},');
        for (String s : listRemove) {
            s = s.remove('{').remove('}');
        }
        List<List<String>> listAll = new List<List<String>>();
        for (String s : listRemove) {
            List<String> listF = new List<String>();
            listF = s.split(',');
            listAll.add(listF);
        }
        //List<Map<String, String>> listMap = new List<Map<String, String>>();
        for (List<String> ls : listAll) {
            Map<String, String> mapTes = new Map<String, String>();
            for (String s : ls) {
                if (String.isNotBlank(s)) {
                    mapTes.put(s.substringBefore('=').remove(' '), s.substringAfter('=').remove(' '));
                }
            }
            if(!mapTes.isEmpty()) {
                listMap.add(mapTes);
            }
        }
        XC_UTIL_Debug.debug(false,'Donato C' + listMap);
        return listMap;
    }

    /*
    public static Map<String,String> convertMessaggeError(String errorMessage) {
        Map<String, String> mapErroreMessage = new Map<String, String>();
        if (errorMessage.contains('ProductErrorWrapper:[')) {
        String don = errorMessage.remove('ProductErrorWrapper:[').removeEnd('])');
        List<String> s = don.split(',');
        System.debug('Donato Split 1' + s);
        for (String a : s) {
            List<String> b = a.split('=');
            mapErroreMessage.put(b[0], b[1]);
            System.debug('Donato for a' + b[0]);
            System.debug('Donato for b' + b[1]);

        }
            List<XC_ProductConsumed__c> productConsumedToUpdate = new List<XC_ProductConsumed__c>();
            productConsumedToUpdate = [SELECT id, XC_ProductCode__c, XC_ErrorMessage__c, XC_WorkOrderLineItem__c  FROM XC_ProductConsumed__c where XC_ProductCode__c =:mapErroreMessage.get('(prodCode')];
            for(XC_ProductConsumed__c pc : productConsumedToUpdate){
                pc.XC_ErrorMessage__c = 'For this product the warehouse quontity is :'+ mapErroreMessage.values()[3];
                try{
                    pc.XC_OriginalConsumedQuantity__c = Decimal.valueOf(mapErroreMessage.values()[3]);
                }catch(Exception e){
                    System.debug('Exception: ' + e);
                }
                System.debug('Donato Key' + mapErroreMessage.keySet());
                System.debug('Donato Value' + mapErroreMessage.values());
            }
            if(!productConsumedToUpdate.isEmpty()){
                update productConsumedToUpdate;
            }
    }
        System.debug('Donato --> '+ mapErroreMessage);
        return mapErroreMessage;

    }
    */


    /*
   * @author fangelini -
   * @date Creation 22/06/2021
   * @description // get sales orders error logs and delete wrong sales order lines
   * @param lstWOLI List<WorkOrderLineItem>
   * @return message String
   */
    public static String chechErrorLogs(List<WorkOrderLineItem> lstWOLI){
        List<String> productIdList = new List<String>();
        List<String> warehouseIdList = new List<String>();
        List<String> productRequiredIDList = new List<String>();
        List<String> wbeIdList = new List<String>();
        List<giic_ErrorLog__c> logsToDelete = new List<giic_ErrorLog__c>();
        String message = '';

        try{
            Map<Id,gii__SalesOrder__c> createdSalesOrders = new Map<id,gii__SalesOrder__c>([SELECT Id FROM gii__SalesOrder__c WHERE giic_WorkOrderLineItem__c =:lstWOLI.get(0).XC_MaterialRequest__c]);
            if(!createdSalesOrders.isEmpty()) {
                List<giic_ErrorLog__c> errorLogs = [SELECT Id, giic_IntegrationWrapper__c, giic_ErrorDescription__c FROM giic_ErrorLog__c WHERE giic_SalesOrder__c IN:createdSalesOrders.keySet()];
                System.debug('errorLogs size: ' + errorLogs.size());
                for (giic_ErrorLog__c err : errorLogs) {
                    if (err.giic_ErrorDescription__c.contains('No product inventory quantity')) {
                        logsToDelete.add(err);
                        //for (Object o : (List<Object>)JSON.deserializeUntyped(err.giic_IntegrationWrapper__c))
                        List<Object> arr = (List<Object>) JSON.deserializeUntyped(err.giic_IntegrationWrapper__c);
                        List<Object> arrSoItemList = ((List<Object>) ((Map<String, Object>) arr[0]).get('salesOrderLineList'));
                        Map<String, Object> listFields = (Map<String, Object>) arrSoItemList[0];

                        String productId = (String) listFields.get('product');
                        if(productId != null ) productIdList.add(productId);

                        String warehouseId = (String) listFields.get('warehouse');
                        if(warehouseId != null ) warehouseIdList.add(warehouseId);

                        String productRequiredID = (String) listFields.get('productRequiredID');
                        if(productRequiredID != null ) productRequiredIDList.add(productRequiredID);

                        String wbe = (String) listFields.get('wbe');
                        if(wbe != null ) wbeIdList.add(wbe);

                    }
                }
                if (!productIdList.isEmpty() || !warehouseIdList.isEmpty() || !productRequiredIDList.isEmpty() || !wbeIdList.isEmpty()) {

                    List<gii__SalesOrderLine__c> soItemList = [
                            SELECT id, gii__ConsumedQuantity__c, createddate
                            from gii__SalesOrderLine__c
                            Where gii__Product__c IN:productIdList AND giic_ProdRequired__c IN:productRequiredIDList AND gii__Warehouse__c IN:warehouseIdList
                            AND giic_WBElement__c IN:wbeIdList AND gii__SalesOrder__c IN: createdSalesOrders.keySet()
                    ];
                    System.debug('soItemList: ' + soItemList);
                    System.debug('soItemList.size(): ' + soItemList.size());
                    if (soItemList.size() == logsToDelete.size()) {
                        XC_UTIL_Sobject.deleteListRecords(soItemList);
                        XC_UTIL_Sobject.deleteListRecords(logsToDelete);
                        message = 'logs and Sales order Lines deleted';
                    }else{
                        message = 'Sales Order Line quantity does not match with error logs quantity';
                        return message;
                    }
                }
            }
        }catch (Exception e){
            System.debug( 'XC_LCC202_GoodIssueExecution - chechErrorLogs - Exception: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
            return e.getMessage();
        }
        return message;
    }


    /*
   * @author dpalamides - 
   * @date Creation 22/06/2019
   * @description // get Country ConfigurationItem 
   * @param fieldValue string
   * @param fieldName String
   * @param errorCheck boolean
   * @return string
   */

    public static string chechMandatoryField(string fieldValue, string fieldName, boolean errorCheck){
        system.debug('@@@@ chechMandatoryField - fieldValue:' + fieldValue);
        system.debug('@@@@ chechMandatoryField - fieldName:' + fieldName);
        system.debug('@@@@ chechMandatoryField - errorChecj:' + errorCheck);
        string message='';
        if(fieldValue =='' || fieldvalue == null){
            message = message + 'failed, missing ' + fieldName + ' Reference!';
            errorCheck = true;
        }
        system.debug('@@@@ chechMandatoryField - message:' + message);
        return message;
    }

    /*
    * @author dpalamides/2019
    * @date Creation 01/08/2019 
    * @description mapListConfItemTechnicalMaterial
    * @param woliId string 
    * @return XC_NE_AddTechnicalItems_Controller.ResultAndMessage
    
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkAddPr(string woliId){
        XC_UTIL_ResultWrapper rAndM = new XC_UTIL_ResultWrapper();
        system.debug('@@@@ checkAddPr:' + woliId);
        rAndM.titleMessage = 'Add new Order material';
        rAndM.resultMessage = 'Order material added success!!';
        rAndM.typeMessage ='Success';
        rAndM.success = true;
        List<ProductRequired> prodRes = new List<ProductRequired>();
        prodRes = [select id from ProductRequired where parentRecordId =:woliId];
        system.debug('@@@@ checkAddPr - prodRes' + prodRes);
        if(prodRes.size()>0){
            rAndM.resultMessage = 'Order material is freeze, already sent!!';
            rAndM.typeMessage ='Error';
            rAndM.success = false;
            system.debug('@@@@ checkAddPr:' + rAndM.resultMessage);
            return rAndM;
        }else{
            return rAndM; }
    }




    /*
     * @author dpalamides - 
     * @date Creation 22/06/2019
     * @description // get Country ConfigurationItem 
     * @param woliId string
     * @return List<NE__OrderItem__c>
     */

    @AuraEnabled
    public static List<NE__OrderItem__c> getCommercialItemList(Id woliId){
        Id workOrderDec = [select WorkOrder.RootWorkOrderId from workOrderLineItem WHERE Id = :woliId].workorder.RootWorkOrderId;
        system.debug('@@@@ getCommercialItemList - workOrderDec:' + workOrderDec);
        List<WorkOrder> woChildDEC = new List<WorkOrder>();
        if(Schema.sObjectType.WorkOrder.isAccessible()){
            woChildDEC = [select id, XC_Configuration_Item__c from WorkOrder where RootWorkOrderId =:workOrderDec];
        }

        system.debug('@@@@ getCommercialItemList - woChildDEC:' + woChildDEC);
        List<String> idCommCIIds = new List<String>();
        if(woChildDEC.size()>0){
            for(WorkOrder wo: woChildDEC){
                system.debug('@@@@ getCommercialItemList - wo.XC_Configuration_Item__c:' + wo.XC_Configuration_Item__c);
                idCommCIIds.add(wo.XC_Configuration_Item__c);

            }
        }
        system.debug('@@@@ getCommercialItemList - idCommCIIds:' + idCommCIIds);
        List<NE__OrderItem__c> commercialCI = new List<NE__OrderItem__c>();
        if(Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            commercialCI=  [select Id, name from NE__OrderItem__c where id in:idCommCIIds];
        }
        system.debug('@@@@ getCommercialItemList - commercialCI:' + commercialCI);
        return commercialCI;

    }

    /*
      * @author dpalamides - 
      * @date Creation 22/06/2019
      * @description // get Country ConfigurationItem 
      * @param confItemComm id
      * @return LParamToGloviaSoli
      */

    @AuraEnabled
    public static ResultOtherPA getParamToGlovia(Id confItemComm){

        ResultOtherPA  param = new ResultOtherPA();
        param.result = false;
        system.debug('@@@@ getParamToGlovia - confItemComm:' + confItemComm);
        List<NE__OrderItem__c> confComm = new List<NE__OrderItem__c>();
        if(Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            confComm=[SELECT XC_WBE__c, XC_CMCostCenter__c from NE__OrderItem__c where id=:confItemComm];
            system.debug('@@@@ getParamToGlovia - conComm:' + confComm);

            for(NE__OrderItem__c ci : confComm){
                param.costCenter = ci.XC_CMCostCenter__c;
                param.wbeElement = ci.XC_WBE__c;
                system.debug('@@@@ getParamToGlovia - param.costCenter:' + param.costCenter);
                system.debug('@@@@ getParamToGlovia - param.wbeElement:' + param.wbeElement);

                if(ci.XC_WBE__c =='' && ci.XC_CMCostCenter__c ==''){

                    param.result = false;
                    param.message ='Operation failed!!! WBE element or costCenter missing';
                    param.titleMessage = 'Order Material';
                    param.typeMessage = 'Error';

                }else

                        param.result = true;


            }
            system.debug('@@@@ getParamToGlovia - param.result:' + param.result);
        }

        return param;
    }




}