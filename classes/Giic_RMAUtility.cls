/*
Name    : Giic_RMAUtility
Author  : Fujitsu Team (Manas)
Purpose : To generate RMA and RMA Lines in Enel-Logistics from Bit2Win System.
Created Date: 19 June 2019 d
*/
public without sharing class Giic_RMAUtility {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_RMAUtility');
    
    public class ResultWrapper{ 
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
       
    }
/**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date 19/08/2019
* @description To RMA, RMALine. Calling method to create PO & POLine , RMA Receipt, Disposition.
* @param List<Giic_CommonWrapper.RMAHeader> listRMAHeader
* @return List<Giic_CommonWrapper.RMAResponse>
*/
 Public static Giic_CommonWrapper.RMAResponse createRMAs(List<Giic_CommonWrapper.RMAHeader> listRMAHeader) {
        // Giic_CommonWrapper.RMAResponse objRMACreation=new Giic_CommonWrapper.RMAResponse();
        //Initialize return Variable
        Giic_CommonWrapper.RMAResponse objReturnResult = new Giic_CommonWrapper.RMAResponse();
        //Counter value for child insertion
        Integer counter=1;
        //Map for RMA: Parent
        map<Integer,gii__RMA__c> mapRMAOrder=new map<Integer,gii__RMA__c>();
        //Map for RMADetail: Child
        map<Integer,List<gii__RMADetail__c>> mapRMALine=new map<Integer,List<gii__RMADetail__c>> ();
        //Map for Error
         map<string, string> errorMap = new map<string, string>();
        List<Giic_CommonWrapper.RMAResponse> listRMAResponse=new List<Giic_CommonWrapper.RMAResponse>();
        List<Id> rmaIds = new List<Id>();
        try{
            for(Giic_CommonWrapper.RMAHeader objRMA : listRMAHeader){
                if(objRMA.warehouseId !=null){
                    gii__RMA__c rmaObj = new gii__RMA__c();
                    rmaObj.gii__Case__c = objRMA.caseId;
                    rmaObj.gii__Account__c = objRMA.accountId;
                    rmaObj.gii__Reason__c = objRMA.reason;
                    rmaObj.gii__Reference__c = objRMA.reference;
                    rmaObj.gii__RMADate__c = objRMA.rMADate;
                    rmaObj.gii__Shipment__c = objRMA.shipmentId;
                    rmaObj.gii__Warehouse__c = objRMA.warehouseId;
                    rmaObj.gii__DivisionCode__c = objRMA.divisionCodeId;
                    rmaObj.gii__AccountName__c = objRMA.accountName;
                    rmaObj.gii__StreetTextArea__c = objRMA.street;
                    rmaObj.gii__City__c = objRMA.city;
                    rmaObj.gii__StateProvince__c = objRMA.stateProvince;
                    rmaObj.gii__ZipPostalCode__c = objRMA.zipPostalCode;
                    rmaObj.gii__Country__c = objRMA.country;
                    rmaObj.gii__DocumentText__c = objRMA.documentText;
                    rmaObj.CurrencyIsoCode = objRMA.currencyIsoCode;
                    rmaObj.giic_WorkOrder__c= objRMA.workOrderId;
                    rmaObj.giic_CentralReturn__c = objRMA.centralReturn;
                    rmaObj.giic_WorkOrderLineItem__c =objRMA.workOrderLineItemId;
                    list<gii__RMADetail__c> lstRMADetail=new list<gii__RMADetail__c>();
                    for(Giic_CommonWrapper.RmaLine objRMALine : objRMA.RMALines){
                        gii__RMADetail__c rMALineObj = new gii__RMADetail__c();
                        RMALineObj.gii__ShipmentDetail__c = objRMALine.shipmentDetailId;
                        RMALineObj.gii__Product__c = objRMALine.productId;
                        RMALineObj.gii__RMAQuantity__c = objRMALine.rmaQuantity;
                        RMALineObj.gii__ProductSerial__c = objRMALine.productSerialId;
                        RMALineObj.gii__ProductLot__c = objRMALine.productLotId;
                        RMALineObj.gii__SellingUnitofMeasure__c = objRMALine.sellingUnitOfMeasureId;
                        RMALineObj.giic_UnderWarranty__c=objRMALine.underWarranty;
                        lstRMADetail.add(RMALineObj);
                    }
                    mapRMALine.put(counter,lstRMADetail);
                    mapRMAOrder.put(counter,rmaObj);
                    counter = counter + 1;
                }
                else {
                    objReturnResult.isSuccess=false;
                    errorMap.put('ErrorMsg', System.Label.giic_RMAwarehouseerror); 
                    objReturnResult.ErrorList.add(errorMap);
                } 
            }  
            if(mapRMAOrder == null || mapRMAOrder.Size() == 0){
               return objReturnResult;
            }
            //Insert Operation
            if(mapRMAOrder.Size() > 0){
               //Calling insertRMA method
               rmaIds=insertRMA(mapRMAOrder,mapRMALine);   
            }
            if(rmaIds != null && rmaIds.size() > 0 ){
                objReturnResult.RMAId = rmaIds[0] ; 
           }
            objReturnResult.isSuccess=True;
        }  
        catch(exception ex){
            objReturnResult.isSuccess=false;
            Giic_ErrorLogsUtility.insertGloviaErrorLog('Giic_RMAUtility',ex, JSON.serialize(listRMAHeader));    
            errorMap.put('ErrorMsg', ex.getMessage());
            objReturnResult.ErrorList.add(errorMap); 
            return objReturnResult;
        }
     // calling createPOFromRMA method 
     // createPOFromRMA(rmaIds);  RP - 18/03/2020 - non deve essere creato il PO
     // Calling createRMAReceiptANDDisposition
  
     createRMAReceiptANDDisposition(rmaIds);
   
     XC_UTIL_Debug.debug(DEBUGACTIVE, 'objReturnResult'+objReturnResult);
     return objReturnResult;
    } 

/**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date 13/08/2019
* @description To create RMA Receipt & Disposition.
* @param List<Id> listRMAs
*/     
    Public static void createRMAReceiptANDDisposition(List<Id> listRMAs) {
        List<gii__RMADetail__c> lstRMAL = new  List<gii__RMADetail__c>( [SELECT Id, gii__Product__c, gii__ProductSerial__c, gii__RMA__c,gii__RMA__r.gii__Account__c,gii__ProductSerial__r.Name,
                                                                         gii__RMA__r.gii__Warehouse__c,gii__Product__r.gii__SerialControlled__c,gii__Product__r.gii__PrimarySupplier__c,
                                                                         gii__ProductLot__c,gii__RMAQuantity__c,giic_UnderWarranty__c
                                                                         FROM gii__RMADetail__c WHERE gii__RMA__c IN:listRMAs and gii__RMA__r.giic_CentralReturn__c = false]);
        // RP - 18/03/2020 
        if(lstRMAL.isEmpty()){ return;  }
        List<gii.RMACreation.RMAReceipt> listRMAReceipts = new List<gii.RMACreation.RMAReceipt>();
        Giic_CommonWrapper.RMAReceiptResult rMAReceiptReturnResult = new Giic_CommonWrapper.RMAReceiptResult();
        for(gii__RMADetail__c objRMALine : lstRMAL){
            gii.RMACreation.RMAReceipt rMAR = new gii.RMACreation.RMAReceipt();
            rMAR.RMADetailId= objRMALine.Id;
            rMAR.ReceiptQuantity = objRMALine.gii__RMAQuantity__c;
            rMAR.ReceiptDate = System.Today();
            listRMAReceipts.add(rMAR);
        }                                        
        gii.RMACreation.RMAReceiptResult listRMAReceiptVal = gii.RMACreation.createRMAReceiptsforRMADetails(listRMAReceipts);
        rMAReceiptReturnResult.listRMAReceipts = listRMAReceiptVal.listRMAReceipts;
       List<giic_ErrorLog__c> errorList = new List<giic_ErrorLog__c>();
        if (listRMAReceiptVal.Exceptions != null) {
            if (listRMAReceiptVal.Exceptions.size() > 0) {
                List<String> errorMsgList = new List<String>();
                for(gii.RMACreation.GOMException e : listRMAReceiptVal.Exceptions) { 
                    giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
                    errorLog.giic_RMA__c =  listRMAs[0];
                    errorLog.giic_Process__c = 'Create RMA';
                    errorLog.Name = 'Create RMA Error';
                    errorLog.giic_ErrorDescription__c =e.getMessage();   
                     errorList.add(errorLog);
                    
                }
               // return null;
            }          
        } 
        XC_UTIL_Sobject.insertListRecords(errorList);  
        Set<Id> rmId=new Set<Id>();
        for(gii__RMAReceipt__c rm : rMAReceiptReturnResult.listRMAReceipts){
            rmId.add(rm.Id);
        }
        //Set for disposition id
       Set<Id> disId=new Set<Id>();
        List<gii__RMAReceipt__c> lstRec = new List<gii__RMAReceipt__c>();
        if(Schema.sObjectType.gii__RMAReceipt__c.isQueryable()){ 
            lstRec = [SELECT Id, gii__ReceiptQuantity__c,gii__RMALineDetail__c,gii__DispositionQuantity__c,gii__Warehouse__r.gii__DefaultReceivingLocation__c,gii__Warehouse__r.gii__DefaultRMADispositionLocation__c FROM gii__RMAReceipt__c WHERE Id IN:rmId];
        }
        //Giic_CommonWrapper.RMADispositionResult returnResult =giic_TR_RMA_UTIL.createRMADisposition(lstRec); 
        // return returnResult;
    }    
 

/**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date 03/09/2019
* @description To insert RMA & RMALine.
* @param map<Integer,gii__RMA__c> mapRMAOrder, map<Integer,List<gii__RMADetail__c>> mapRMALine
* @return List<Id>
*/ 
    public static List<Id> insertRMA(map<Integer,gii__RMA__c> mapRMAOrder, map<Integer,List<gii__RMADetail__c>> mapRMALine){
        Database.Insert(mapRMAOrder.values());
        list<gii__RMADetail__c> lstRMALinesToInsert=new list<gii__RMADetail__c>();
        List<Id> rmaIds = new List<Id>();
        for(Integer count : mapRMAOrder.keyset()){
            rmaIds.add(mapRMAOrder.get(count).Id);
            for(gii__RMADetail__c objRMADetail : mapRMALine.get(count)){
                objRMADetail.gii__RMA__c=mapRMAOrder.get(count).Id;
                lstRMALinesToInsert.add(objRMADetail);
            }
        }
       List<XC_UTIL_Sobject.WrapperResult> results =  XC_UTIL_Sobject.insertListRecords(lstRMALinesToInsert);
      	List<giic_ErrorLog__c> errorList = new List<giic_ErrorLog__c>();
        for(XC_UTIL_Sobject.WrapperResult res : results){
            if(!res.success){
                giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
                errorLog.giic_RMA__c =  rmaIds[0];
                errorLog.giic_Process__c = 'Create RMA';
                errorLog.Name = 'Create RMA Error';
                errorLog.giic_ErrorDescription__c = res.errorMessage;  
               errorList.add(errorLog);
            } 
        } 
        XC_UTIL_Sobject.insertListRecords(errorList);  
        return rmaIds;
    }
    
    /**
* @author FirstName : Patrizia Arcidiacono - Patrizia.Arcidiacono@nttdata.com
* @date 27/11/2019
* @description cancellation + inventory adjustment RMA / Return To Supplier .
* @param currentId string
* @return result boolean
*/ 
    @AuraEnabled
    public static ResultWrapper cancellation_RMA_RTS(string currentId){
        ResultWrapper rW = new ResultWrapper();
        string objectType = XC_UTIL_Sobject.getObjectType(currentId) == 'gii__RMA__c' ? 'RMA' : 'Return to supplier';
        rW.titleMessage = objectType + ' cancellation';
        rW.typeMessage ='Success';
        rW.Message = objectType + ' cancellation ' + rW.TypeMessage;
        rW.result = true;
        XC_UTIL_Debug.debug(DEBUGACTIVE,'###objectType' + objectType);
        try{
            if(objectType == 'RMA' )
				rW = queryForRMA(currentId, rW); 
             else
                rW = queryForRTS(currentId, rW);  
           }catch(Exception e){ 
            	rW.result = false;
            	rW.titleMessage = objectType + ' Cancellation exception';
            	rW.typeMessage = 'Error';
            	rW.message = objectType + ' Cancellation exception!!!:' + e.getMessage()+' at line: '+e.getLineNumber()+ ' stack trace: '+e.getStackTraceString();
           }   
           return rW;
   }     
    
  
/**
* @author FirstName : Patrizia Arcidiacono - Patrizia.Arcidiacono@nttdata.com
* @date 27/11/2019
* @description call inventory adjustment api
* @param objIA sObject
* @param reason string
* @param objectIA string
* @return ResultWrapper
*/ 
   /* private static ResultWrapper adjustmentInventoryCall(sObject objIA, string reason, string objectIA){ 
        List<XC_UTIL_Sobject.WrapperResult> rCI = new List<XC_UTIL_Sobject.WrapperResult>();
        ResultWrapper rW = new ResultWrapper();
        List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper> listWR = new List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper>();
        giic_UTIL_CheckInventory.Giic_InputInventoryWrapper wr = new giic_UTIL_CheckInventory.Giic_InputInventoryWrapper();
        try{     
        if(objectIA =='Disposition'){
        	wr.quantity = 0-Integer.ValueOf(objIA.get('gii__DispositionQuantity__c'));
			wr.wareHouseCode = (String) objIA.getSobject('gii__Warehouse__r').get('giic_WarehouseCode__c');
            wr.prod2Code =  (String) objIA.getSobject('gii__Product__r').get('gii__ProductCode__c'); 
        	wr.location=(String) objIA.getSobject('gii__DispositionLocation__r').get('Name');
        }else{
            wr.quantity = integer.ValueOf(objIA.get('gii__ShippedQuantity__c'));
        	wr.wareHouseCode = (String) objIA.getSobject('gii__ShipFrom__r').get('giic_WarehouseCode__c');
      		wr.prod2Code =  (String) objIA.getSobject('gii__ReturntoSupplierLine__r').getSobject('gii__Product__r').get('gii__ProductCode__c');
         	wr.location = (String) objIA.getSobject('gii__Location__r').get('Name');
            
        }
        wr.reason = reason;
        List<String> serials = new List<String> ();
        string x = (string) objIA.get('gii__ProductSerial__c');
        if(x!=null) serials.add((string)objIA.getSobject('gii__ProductSerial__r').get('Name'));
        wr.serials = serials;                     
        listWR.add(wr);
        rCI = giic_UTIL_CheckInventory.checkInventory(listWR);
        if(!rCI[0].success){
            rW.message = 'Inventory Adjustment';
            rW.result = false;   
            rW.message = 'Failed on ' + objectIA + ' - ' + rCI[0].errorMessage;
            rW.typeMessage ='Error';
        }else {
            rW.message = 'Inventory Adjustment disposition success:';
        }
      }catch(Exception e){
          Giic_ErrorLogsUtility.insertGloviaErrorLog('Giic_RMAUtility',e, '');  
          rW.message = 'Inventory Adjustment';
          rW.result = false;   // jsadbkjadkabdkj
          rW.message = 'Inventory Adjustment failed on ' + objectIA;
	  	  rW.typeMessage ='Error';
      } 
      return rW;   
    }  */  
    
        /**
* @author FirstName : Patrizia Arcidiacono - Patrizia.Arcidiacono@nttdata.com
* @date 27/11/2019
* @description call inventory adjustment api
* @param currentRMAId string
* @param rW ResultWrapper
* @return Giic_RMAUtility.ResultWrapper
*/ 
    public static Giic_RMAUtility.ResultWrapper queryForRMA(string currentRMAId, ResultWrapper rW){ 
       List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper> listWR = new List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper>();
        List<XC_UTIL_Sobject.WrapperResult> rCI = new List<XC_UTIL_Sobject.WrapperResult>();
        Map<String,gii__RMA__c> RMAMaptoUpdate = new Map<String,gii__RMA__c>();
        List<gii__RMAReceipt__c> receiptToDelete = new List<gii__RMAReceipt__c>();
        List<gii__RMAReceipt__c> rmaReceiptList = new List<gii__RMAReceipt__c>([SELECT Id,Name,gii__RMA__r.giic_status__c,gii__RMA__r.Giic_CancelledDate__c,
                                                                                     (SELECT Id,gii__ProductSerial__c, gii__RMAReceipt__r.gii__RMA__c, gii__Product__r.gii__ProductCode__c,
                                                                                      gii__DispositionLocation__r.Name, gii__Warehouse__r.giic_WarehouseCode__c, gii__ProductSerial__r.Name, 
                                                                                      gii__DispositionQuantity__c, gii__ProductInventoryQuantityDetail__c,gii__Product__r.gii__SerialControlled__c,
                                                                                      gii__Product__r.gii__LotControlled__c, gii__RMAReceipt__r.gii__RMA__r.giic_status__c,
                                                                                      gii__RMAReceipt__r.gii__RMA__r.Giic_CancelledDate__c,gii__ProductLot__c, gii__ProductLot__r.Name                                                                                    
                                                                                      FROM gii__ReceiptRMADisposition__r ),
                                                                                 	(SELECT Id, gii__LotName__c, gii__Quantity__c FROM gii__Lot_Details__r)
                                                                                     FROM gii__RMAReceipt__c 
                                                                                     WHERE gii__RMA__c =:currentRMAId]);
        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'###rmaReceiptList' + rmaReceiptList);
        if(rmaReceiptList.size() > 0){            
            for(gii__RMAReceipt__c rmaRec : rmaReceiptList){ 
                if(rmarec.gii__ReceiptRMADisposition__r.size() > 0){  
                    for(gii__RMADisposition__c rmaDisp : rmarec.gii__ReceiptRMADisposition__r){              
                        giic_UTIL_CheckInventory.Giic_InputInventoryWrapper wr = new giic_UTIL_CheckInventory.Giic_InputInventoryWrapper();
                        wr.quantity = 0-Integer.ValueOf(rmaDisp.gii__DispositionQuantity__c);
                        wr.wareHouseCode = (String) rmaDisp.gii__Warehouse__r.giic_WarehouseCode__c;
                        wr.prod2Code =  (String) rmaDisp.gii__Product__r.gii__ProductCode__c; 
                        wr.location=(String) rmaDisp.gii__DispositionLocation__r.Name;
                        wr.reason = 'RMA Cancellation';
                        if(rmaDisp.gii__Product__r.gii__SerialControlled__c){
                            List<String> serials = new List<String> ();
                            string serial = (string) rmaDisp.gii__ProductSerial__r.Name;
                            serials.add(serial);
                            wr.serials = serials;            
                        }else if(rmaDisp.gii__Product__r.gii__LotControlled__c){
                            Map<String, Integer> lots = new Map<String, Integer>();
                            lots.put(rmaDisp.gii__ProductLot__r.Name, (Integer)rmaDisp.gii__DispositionQuantity__c);
                            wr.lots = lots;
                        }
                        if(!RMAMaptoUpdate.containsKey(rmaDisp.gii__RMAReceipt__r.gii__RMA__c)){
                            gii__RMA__c rmatoUpd = new gii__RMA__c();
                            rmatoUpd.id = rmaDisp.gii__RMAReceipt__r.gii__RMA__c;
                            rmatoUpd.giic_status__c ='Cancelled';
                            rmatoUpd.Giic_CancelledDate__c = date.today();
                            RMAMaptoUpdate.put(rmaDisp.gii__RMAReceipt__r.gii__RMA__c, rmatoUpd);
                        }
                        
                        listWR.add(wr);                    
                    }
                }else{  receiptToDelete.add(rmaRec);  }
            }
        }
        if(!listWR.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'###listWR' + listWR);
            rCI = giic_UTIL_CheckInventory.checkInventory(listWR);
            boolean success = true;
            for(XC_UTIL_Sobject.WrapperResult response : rCI){
                if(!response.success){
                    rW.result = false;
                    success = false;
                    rW.message = 'Error ' + response.errorMessage;
                    rW.typeMessage ='Error';
                }else{ rW.message = 'Inventory Adjustment disposition success:'; }  
            }
            if(success){ XC_UTIL_Sobject.updateListRecords(RMAMaptoUpdate.values());  }   
        }      
        if(!receiptToDelete.isEmpty()){ XC_UTIL_Sobject.deleteListRecords(receiptToDelete);  }   
          return rW;
    }    
    
/**
* @author FirstName : Patrizia Arcidiacono - Patrizia.Arcidiacono@nttdata.com
* @date 27/11/2019
* @description query to retrieve value to pass on Iventory Adjustment
* @param currentRTSId string
* @param rW ResultWrapper
* @return ResultWrapper
*/ 
    private static ResultWrapper queryForRTS(string currentRTSId ,ResultWrapper rW){ 
        List<XC_UTIL_Sobject.WrapperResult> rCI = new List<XC_UTIL_Sobject.WrapperResult>();
        List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper> listWR = new List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper>();
        
        Map<String,gii__ReturntoSupplier__c> RTSMaptoUpdate = new Map<String,gii__ReturntoSupplier__c>();
        List<gii__ReturntoSupplierLineShipment__c> reTSuppShip = [SELECT Id,gii__Location__r.Name ,gii__ShipFrom__r.giic_WarehouseCode__c, gii__ProductSerial__r.Name,
                                                                  gii__ReturntoSupplierLine__r.gii__Product__r.gii__ProductCode__c, Name, gii__ShippedQuantity__c ,
                                                                  gii__ReturntoSupplierLine__r.gii__Product__r.gii__SerialControlled__c,gii__ReturntoSupplierLine__r.gii__Product__r.gii__LotControlled__c,
                                                                  gii__ProductLot__r.Name,gii__ReturntoSupplier__c
                                                                  FROM gii__ReturntoSupplierLineShipment__c 
                                                                  WHERE gii__ReturntoSupplier__c =:currentRTSId];
        XC_UTIL_Debug.debug(DEBUGACTIVE,'###reTSuppShip' + reTSuppShip);
        
        for(gii__ReturntoSupplierLineShipment__c rTSShip : reTSuppShip ){            
            giic_UTIL_CheckInventory.Giic_InputInventoryWrapper wr = new giic_UTIL_CheckInventory.Giic_InputInventoryWrapper();
            wr.quantity = integer.ValueOf(rTSShip.gii__ShippedQuantity__c);
            wr.wareHouseCode = (String) rTSShip.gii__ShipFrom__r.giic_WarehouseCode__c;
            wr.prod2Code =  (String) rTSShip.gii__ReturntoSupplierLine__r.gii__Product__r.gii__ProductCode__c;
            wr.location = (String) rTSShip.gii__Location__r.Name;            
            wr.reason = 'Return To Supplier Cancellation'; 
            if(rTSShip.gii__ReturntoSupplierLine__r.gii__Product__r.gii__SerialControlled__c){
                List<String> serials = new List<String> ();
                string serial = (string) rTSShip.gii__ProductSerial__r.Name;
                serials.add(serial);
                wr.serials = serials;            
            }else if(rTSShip.gii__ReturntoSupplierLine__r.gii__Product__r.gii__LotControlled__c){
                Map<String, Integer> lots = new Map<String, Integer>();
                lots.put(rTSShip.gii__ProductLot__r.Name, (Integer)rTSShip.gii__ShippedQuantity__c);
                wr.lots = lots;
            }
            if(!RTSMaptoUpdate.containsKey(rTSShip.gii__ReturntoSupplier__c)){
                gii__ReturntoSupplier__c rtstoUpd = new gii__ReturntoSupplier__c();
                rtstoUpd.id = rTSShip.gii__ReturntoSupplier__c;
                rtstoUpd.giic_status__c ='Cancelled';
                rtstoUpd.Giic_CancelledDate__c = date.today();
                RTSMaptoUpdate.put(rTSShip.gii__ReturntoSupplier__c, rtstoUpd);
            }
            listWR.add(wr);
        }    
        if(!listWR.isEmpty()){
            rCI = giic_UTIL_CheckInventory.checkInventory(listWR);
            boolean success = true;
            for(XC_UTIL_Sobject.WrapperResult response : rCI){
                if(!response.success){
                    rW.result = false;
                    success = false;
                    rW.message = 'Error ' + response.errorMessage;
                    rW.typeMessage ='Error';
                    return rW;
                }else{
                    rW.message = 'Inventory Adjustment disposition success:';
                }  
            }
            if(success){
                XC_UTIL_Sobject.updateListRecords(RTSMaptoUpdate.values());                
            } 
        }
        return rW;
    }    
}