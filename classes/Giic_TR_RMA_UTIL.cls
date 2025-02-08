/**  
* @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 26/11/2019
*/
public without sharing class Giic_TR_RMA_UTIL {
    
    /**  
* @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 26/11/2019
* @description To set legalEntity
* @param listNew -  List of RMA
*/
    public static void setLEOnRMA(List<gii__RMA__c> listNew){
        List<String> whIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'gii__Warehouse__c');
        map<Id,gii__Warehouse__c> p2Maps = new  map<Id,gii__Warehouse__c> ([SELECT Id, giic_LegalEntity__c FROM gii__Warehouse__c WHERE Id IN: whIds ]);
        System.debug('p2Maps = '+p2Maps.values());
        for(gii__RMA__c r : listNew){   
            for(gii__Warehouse__c w : p2Maps.values()){
                if(r.gii__Warehouse__c == w.Id && w.giic_LegalEntity__c != null){
                    r.giic_LegalEntity__c = w.giic_LegalEntity__c;
                }
            } 
        } 
    }
/**  
* @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 26/11/2019
* @description To set 
* @param listNew -  List of RMA
*/
  /**  public static  XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper createRMAReceiptAndDisposition(XC_REST_GoodsReceipt_Inbound_U.RequestWrapper reqWR){
        XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper result = new XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper();  
        result.result.message = 'Operation completed successfully';
        result.result.error_code = '200';
        List<giic_ErrorLog__c> errorList = new List<giic_ErrorLog__c>();
        List<String> locationName = new List<String>();
        String rmaId = reqWR.goods_receipt.rma_id;
        String rmaNumb = reqWR.goods_receipt.rma_number;
        Map<Id,gii__RMA__c> rmaMap = new Map<Id,gii__RMA__c>([
            SELECT Id, Name, (
                SELECT Id, Name, gii__Product__r.gii__ProductCode__c, gii__Product__r.giic_EANReference__c,gii__ProductSerial__r.Name,gii__Product__r.gii__SerialControlled__c
                FROM gii__RMALineDetails__r ) 
            FROM gii__RMA__c 
            WHERE Id =: rmaId OR Name =: rmaNumb ]);
        List<gii__RMA__c> rmaList = rmaMap.values();
        if(!rmaList.isEmpty()){ 
            gii__RMA__c rma = rmaList[0];
            List<gii.RMACreation.RMAReceipt> listRMAReceipts = new List<gii.RMACreation.RMAReceipt>();
            Giic_CommonWrapper.RMAReceiptResult rMAReceiptReturnResult = new Giic_CommonWrapper.RMAReceiptResult();
            for(gii__RMADetail__c rmaL : rma.gii__RMALineDetails__r){
                for(XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper rmaLine : reqWR.goods_receipt.items ){
                    if(rmaL.Id == rmaLine.rma_line_id && (rmaL.gii__Product__r.gii__ProductCode__c == rmaLine.product_code || rmaL.gii__Product__r.giic_EANReference__c == rmaLine.ean_code) ){
                        locationName.add(rmaLine.location_name);
                        gii.RMACreation.RMAReceipt rMAR = new gii.RMACreation.RMAReceipt();
                        if(rmaL.gii__Product__r.gii__SerialControlled__c && !rmaLine.serial_numbers.isEmpty()){
                            Boolean serialCheck = false;
                            for(XC_REST_GoodsReceipt_Inbound_U.SerialNumbersWrapper serialNum : rmaLine.serial_numbers){ 
                                if(serialNum.serial_number == rmaL.gii__ProductSerial__r.Name){
                                    rMAR.RMADetailId= rmaLine.rma_line_id;
                                    rMAR.ReceiptQuantity = rmaLine.qty;
                                    rMAR.ReceiptDate = reqWR.goods_receipt.registration_date;
                                    serialCheck = true;
                                    continue;
                                }
                            }
                            if(!serialCheck){
                                result.result.message = 'The serial is not correct';
                                result.result.error_code = '500';
                                return result; 
                            }
                        }else{   
                            rMAR.RMADetailId= rmaLine.rma_line_id;
                            rMAR.ReceiptQuantity = rmaLine.qty;
                            rMAR.ReceiptDate = reqWR.goods_receipt.registration_date;  
                        } 
                        listRMAReceipts.add(rMAR); 
                    }
                }
            }
            gii.RMACreation.RMAReceiptResult listRMAReceiptVal = gii.RMACreation.createRMAReceiptsforRMADetails(listRMAReceipts);
            rMAReceiptReturnResult.listRMAReceipts = listRMAReceiptVal.listRMAReceipts;
            if(listRMAReceiptVal.Exceptions != null) {
                if(listRMAReceiptVal.Exceptions.size() > 0) {
                    for(gii.RMACreation.GOMException e : listRMAReceiptVal.Exceptions) { 
                        giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
                        errorLog.giic_RMA__c =  rma.id;
                        errorLog.giic_Process__c = 'Create RMA';
                        errorLog.Name = 'Create RMA Error';
                        errorLog.giic_ErrorDescription__c =e.getMessage();   
                        errorList.add(errorLog);
                    }
                }
            }
            XC_UTIL_Sobject.insertListRecords(errorList);  
            if(!errorList.isEmpty()){
                result.result.message =errorList[0].giic_ErrorDescription__c;
                result.result.error_code = '500';
                return result;
            }
            Map<String,String> rmlineReceipt = new  Map<String,String> ();
            for(gii__RMAReceipt__c rm : rMAReceiptReturnResult.listRMAReceipts){ 
                rmlineReceipt.put(rm.gii__RMALineDetail__c,rm.Id);
            } 
            List<gii__Location__c> lstLocation = new List<gii__Location__c>([SELECT Id,Name
                                                                             FROM gii__Location__c
                                                                             WHERE Name IN:locationName]);
            Map<String, String> mapLocationNameID = new Map<String, String> ();
            if(!lstLocation.isEmpty()){
                for(gii__Location__c loc : lstLocation){
                    mapLocationNameID.put(loc.Name, loc.Id);  
                }    
            }  
            result = createRMADisposition(rmlineReceipt,mapLocationNameID,reqWR);
            gii__RMA__c rmaUpdate = new gii__RMA__c(Id = rma.id, 
                                                        giic_IntegrationOperation__c = Label.giic_IntegrationOperationUpdate,
                                                        giic_TargetSystem__c = Label.giic_TargetSystemGlovia
                                                       ); 

            if(result.result.error_code != '200'){
            	rmaUpdate.giic_IntegrationStatus__c = Label.giic_IntegrationStatusFailure;
            }else{
                rmaUpdate.giic_IntegrationStatus__c = Label.giic_IntegrationStatusSuccess;
            }
            XC_UTIL_Sobject.updateRecord(rmaUpdate);
        }else{
            result.result.message = 'No RMA was found';
            result.result.error_code = '500';
            return result;
        } 
        return result;
    }
    
    
    
    /**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date 13/08/2019
* @description To create RMA Disposition.
* @param List<gii__RMAReceipt__c> lstRec
* @return XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper
*/   
   /** public static XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper createRMADisposition(Map<String,String> rmlineReceipt,Map<String, String> mapLocationNameID,XC_REST_GoodsReceipt_Inbound_U.RequestWrapper reqWR){
        XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper result = new XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper();   
        result.result.message = 'Operation completed successfully';
        result.result.error_code = '200';
        List<giic_ErrorLog__c> errorList = new List<giic_ErrorLog__c>();
        Giic_CommonWrapper.RMADispositionResult rMADisReturnResult = new Giic_CommonWrapper.RMADispositionResult();
        List<gii.RMACreation.RMADisposition> listOfRMAD = new List<gii.RMACreation.RMADisposition>();
        
        for(XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper rmaLine : reqWR.goods_receipt.items){
            for(String rmRec : rmlineReceipt.keyset()){
                if(rmRec == rmaLine.rma_line_id){
                    gii.RMACreation.RMADisposition objRMAD = new gii.RMACreation.RMADisposition(); 
                    objRMAD.RMAReceiptId  = rmlineReceipt.get(rmRec);
                    objRMAD.DispositionQuantity  = rmaLine.qty;
                    objRMAD.DispositionDate   = reqWR.goods_receipt.registration_date;
                    objRMAD.DispositionLocationId  = mapLocationNameID.get(rmaLine.location_name); 
                    listOfRMAD.add(objRMAD);  
                }
            } 
        }
        gii.RMACreation.RMADispositionResult listRMADisVal = gii.RMACreation.createRMADispositionsforReceipts(listOfRMAD);
        rMADisReturnResult.listRMADispositions = listRMADisVal.listRMADispositions; 
        if(listRMADisVal.Exceptions != null) {
            if (listRMADisVal.Exceptions.size() > 0) {
                List<String> errorMsgList = new List<String>(); 
                for(gii.RMACreation.GOMException e : listRMADisVal.Exceptions) { 
                    giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
                    errorLog.giic_RMA__c = reqWR.goods_receipt.rma_id;
                    errorLog.giic_Process__c = 'Create RMA';
                    errorLog.Name = 'Create RMA Error';
                    errorLog.giic_ErrorDescription__c =e.getMessage();   
                    errorList.add(errorLog);                  
                } 
            } 
        }  
        XC_UTIL_Sobject.insertListRecords(errorList);  
        if(!errorList.isEmpty()){
            result.result.message =errorList[0].giic_ErrorDescription__c;
            result.result.error_code = '500';
            return result;
        }
        return result;
    }    
    
    
    
    /**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 30/08/2019
* @description method for sending a Purchase Order to SAP Procurement System
*/	
 /*   public class callSendCreateRMA3PLQueuable implements Queueable, Database.AllowsCallouts{
        List<Id> recordIDs = new List<Id>() ;
        
        public callSendCreateRMA3PLQueuable(List<Id> recordIDs){
            this.recordIDs = recordIDs;
        }
        
        public void execute(QueueableContext context) {
            sendCreateRMA3PL(this.recordIDs);
        }
    }
    
    /**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 30/08/2019
* @description method for sending a Purchase Order to SAP Procurement System
* @param recordID is the Id of the Object
*/	
  /*  public static void callSendCreateRMA3PL(List<Id> recordIDs){ 
        System.enqueueJob(new callSendCreateRMA3PLQueuable(recordIDs));    
    }
    
    /**
* sendCreateTransferOrder3PL
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 30/08/2019
* @description method for sending a Transfer Order to 3PL System
* @param recordID is the Id of the Object
*/	
  /**  public static void sendCreateRMA3PL(List<Id> recordID){ 
        List<giic_ErrorLog__c> errorLogList = new List<giic_ErrorLog__c>();
        List<gii__RMA__c> rmaList = new List<gii__RMA__c>([SELECT Id,gii__Warehouse__c,gii__Warehouse__r.giic_WarehouseCode__c, gii__Warehouse__r.giic_ServerSystem__c,
                                                           gii__Account__r.Name ,gii__RMADate__c,gii__Street__c,gii__ZipPostalCode__c,gii__StateProvince__c,giic_LegalEntity__c,
                                                           gii__Country__c,gii__City__c,gii__AccountName__c,Name,giic_Status__c,  gii__Account__r.Phone,gii__Account__r.PrimaryEmail__c,
                                                           (SELECT ID, gii__RMAQuantity__c,gii__Product__r.gii__ProductReference__r.Name,
                                                            gii__Product__r.gii__ProductCode__c ,Name,gii__RMA__r.gii__RMADate__c,
                                                            gii__Product__r.giic_EANReference__c         
                                                            FROM gii__RMALineDetails__r)  
                                                           FROM gii__RMA__c 
                                                           WHERE gii__Warehouse__r.giic_WarehouseType__c = 'Central'
                                                           AND Id IN :recordID]);
        
        if(rmaList.isEmpty()){return;}
        Map<String,String> mapVirtualLegalEntityWHCode = new  Map<String,String> ();
        List<gii__Warehouse__c> virtualWH = new List<gii__Warehouse__c>([SELECT Id ,giic_LegalEntity__c,giic_WarehouseCode__c
                                                                        FROM gii__Warehouse__c
                                                                        WHERE giic_WarehouseType__c = 'Virtual']);
        if(!virtualWH.isEmpty()){
            for(gii__Warehouse__c wh : virtualWH){
                mapVirtualLegalEntityWHCode.put(wh.giic_LegalEntity__c, wh.giic_WarehouseCode__c);
            }  
        }
        
        for(gii__RMA__c rma : rmaList){
            String serverSystem = rma.gii__Warehouse__r.giic_ServerSystem__c; 
            if(serverSystem == null ){
                rma.giic_IntegrationStatus__c =Label.giic_IntegrationStatusFailure;
                giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
                errorLog.Name = Label.giic_ErrorLogIntegration;
                errorLog.giic_RMA__c = rma.Id;
                errorLog.giic_Process__c = 'Integration 3PL';//Label.giic_ErrorLogIntegration;
                String message = 'Integration Server System is not defined';
                errorLog.giic_ErrorDescription__c = 'Integration Error:  ' +  message;  
                errorLogList.add(errorLog);
                continue; 
            }
            XC_REST_TransferOrder_Inbound_U.RequestWrapper requestWR = new XC_REST_TransferOrder_Inbound_U.RequestWrapper();
            XC_REST_TransferOrder_Inbound_U.TransferOrderWrapper transferWR = new XC_REST_TransferOrder_Inbound_U.TransferOrderWrapper(); 
            List<XC_REST_TransferOrder_Inbound_U.ItemsWrapper> transfeItemWR = new List<XC_REST_TransferOrder_Inbound_U.ItemsWrapper>();
            transferWR.account_name = rma.gii__Account__r.Name ;
            transferWR.from_warehouse_code = mapVirtualLegalEntityWHCode.get(rma.giic_LegalEntity__c) ;
            transferWR.to_warehouse_code = rma.gii__Warehouse__r.giic_WarehouseCode__c;
            transferWR.order_date = rma.gii__RMADate__c;
            transferWR.required_date =  rma.gii__RMADate__c;            
            transferWR.ship_postal_code =  rma.gii__ZipPostalCode__c;
            transferWR.ship_street = rma.gii__Street__c;
            transferWR.ship_state = rma.gii__StateProvince__c;
            transferWR.ship_name = rma.gii__AccountName__c;
            transferWR.ship_country = rma.gii__Country__c;
            transferWR.ship_city = rma.gii__City__c;
            transferWR.to_id = rma.ID;
            transferWR.to_number =  rma.Name;
            transferWR.status  =  rma.giic_Status__c;
            transferWR.transfer_order_type = 'Return';
            transferWR.ship_email =  rma.gii__Account__r.PrimaryEmail__c;
            transferWR.ship_primary_phone =  rma.gii__Account__r.Phone;
            // transferWR.ship_secondary_phone  =  trasferOrder[0].
            for(gii__RMADetail__c rmaDetail : rma.gii__RMALineDetails__r ){
                XC_REST_TransferOrder_Inbound_U.ItemsWrapper tolWR = new XC_REST_TransferOrder_Inbound_U.ItemsWrapper();
                tolWR.quantity = (Integer)rmaDetail.gii__RMAQuantity__c;
                tolWR.description = rmaDetail.gii__Product__r.gii__ProductReference__r.Name;
                tolWR.product_code = rmaDetail.gii__Product__r.gii__ProductCode__c  ;
                tolWR.required_date = rmaDetail.gii__RMA__r.gii__RMADate__c;
                tolWR.tol_id = rmaDetail.Id; 
                tolWR.tol_number = rmaDetail.Name; 
                tolWR.ean_code = rmaDetail.gii__Product__r.giic_EANReference__c;
                transfeItemWR.add(tolWR);
            }  
            
            transferWR.items = transfeItemWR;
            requestWR.transfer_order = transferWR;
            
            XC_REST_TransferOrder_Inbound_U.ResponseWrapper response = XC_REST_TransferOrder.createTransferOrderOutbound(requestWR,serverSystem );
            if(response.result!= null && response.result.error_code == '0'){
                rma.giic_IntegrationStatus__c = Label.giic_IntegrationStatusSuccess; 
            }else{
                rma.giic_IntegrationStatus__c =Label.giic_IntegrationStatusFailure;
                giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
                errorLog.Name = Label.giic_ErrorLogIntegration;
                errorLog.giic_RMA__c = rma.Id;
                errorLog.giic_Process__c = 'Integration 3PL';//Label.giic_ErrorLogIntegration;
                String message = response.result != null ? response.result.message : 'Error Integration';
                errorLog.giic_ErrorDescription__c = serverSystem + '   Integration Error:  ' +  message;  
                errorLogList.add(errorLog);
            }   
        } 
        XC_UTIL_Sobject.insertListRecords(errorLogList); 
        XC_UTIL_Sobject.updateListRecords(rmaList);
        
    }
    
 
/**  
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 26/11/2019
* @date Modification dd/mm/yyyy
* @description To check incoming 
* @param purchaseOdrLineList -  List of 
* @param isInsert -  to check if trigger is Insert type
* @param mapOldS -  List of old 
*/    
 /**   public static void closeReturnWO(List<gii__RMA__c> listNew){
        List<Id> rmaIds = XC_UTIL_SObject.getIds(listNew);
        Map<String,String> mapRMAToWO = new Map<String,String> ();
        Map<String,Decimal> mapRMAToDisposeQuantity = new Map<String,Decimal> ();
        Map<String,Decimal> mapRMAToLineQuantity = new Map<String,Decimal> ();
        Map<String,Decimal> mapRMALineToQuantity = new Map<String,Decimal> ();
        Map<String,List<String>> mapRMAToRMALine = new Map<String,List<String>> ();
        List<gii__RMADisposition__c> dispLines = [SELECT gii__DispositionQuantity__c,gii__RMAReceipt__r.gii__RMALineDetail__r.gii__RMAQuantity__c,
                                                 gii__RMAReceipt__r.gii__RMA__r.giic_WorkOrder__c
                                                 FROM gii__RMADisposition__c 
                                                 WHERE gii__RMAReceipt__r.gii__RMA__c IN : rmaIds
                                                 AND gii__RMAReceipt__r.gii__RMA__r.giic_CentralReturn__c = true
                                                 AND gii__RMAReceipt__r.gii__RMA__r.giic_WorkOrder__r.Status != 'Completed'] ;   
        if(dispLines.isEmpty()){return;}
        for(gii__RMADisposition__c disp : dispLines){
            mapRMAToWO.put(disp.gii__RMAReceipt__r.gii__RMA__c , disp.gii__RMAReceipt__r.gii__RMA__r.giic_WorkOrder__c); 
            if(!mapRMAToDisposeQuantity.containskey(disp.gii__RMAReceipt__r.gii__RMA__c)){
                mapRMAToDisposeQuantity.put(disp.gii__RMAReceipt__r.gii__RMA__c, 0);
            }            
            Decimal disposeQty = mapRMAToDisposeQuantity.get(disp.gii__RMAReceipt__r.gii__RMA__c);
            mapRMAToDisposeQuantity.put(disp.gii__RMAReceipt__r.gii__RMA__c, disposeQty + disp.gii__DispositionQuantity__c ); 
            
            if(!mapRMALineToQuantity.containskey(disp.gii__RMAReceipt__r.gii__RMALineDetail__c)){
                mapRMALineToQuantity.put(disp.gii__RMAReceipt__r.gii__RMALineDetail__c, disp.gii__RMAReceipt__r.gii__RMALineDetail__r.gii__RMAQuantity__c); 
            }
            
            if(!mapRMAToRMALine.containskey(disp.gii__RMAReceipt__r.gii__RMA__c)){
                mapRMAToRMALine.put(disp.gii__RMAReceipt__r.gii__RMA__c, new List<String>());
            }            
            mapRMAToRMALine.get(disp.gii__RMAReceipt__r.gii__RMA__c).add(disp.gii__RMAReceipt__r.gii__RMALineDetail__c); 
        }
        
        for(String rma : mapRMAToRMALine.keyset()){
            Decimal linequantity = 0;
            for(String rmaLine : mapRMAToRMALine.get(rma)){
               linequantity =  mapRMALineToQuantity.get(rmaLine);
            }
            mapRMAToLineQuantity.put(rma, linequantity);
        }
    
        List<WorkOrder> woList = new List<WorkOrder> ();
        for(String rma : mapRMAToWO.keyset()){
            if(mapRMAToLineQuantity.get(rma) == mapRMAToDisposeQuantity.get(rma)){
                WorkOrder wo = new WorkOrder();
                wo.id = mapRMAToWO.get(rma);
                wo.Status = Label.XC_CL_WorkOrder_Completed;
                wo.XC_EffectiveDeliveryDate__c = System.today();
                woList.add(wo);
            } 
        }
        XC_UTIL_SObject.updateListRecords(woList);
        
    }*/
}