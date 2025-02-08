/**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 30/08/2019
* @description Class of future methods for asynchronous calls about Goods Receipt
*/
public without sharing class XC_REST_GoodReceipt {
	
       // INNER QUEABLE CLASS CREATE GR ON SAP
    public class callSendCreateGRSAPQueuable implements Queueable, Database.AllowsCallouts{
        Id recordID ;
        
        public callSendCreateGRSAPQueuable(Id recordID){
            this.recordID = recordID;
        }
        
        public void execute(QueueableContext context) {
            sendCreateGoodReceiptSAP(this.recordID);
            system.debug('ho chiamato sendCreateGoodReceiptSAP');
        }
    }
      /**
    * @author Roberta Porrega - roberta.porrega@nttdata.com 
    * @date Creation 30/08/2019
    * @description method for sending a Purchase Order to SAP Procurement System
    * @param recordID is the Id of the Object
    */	
	public static void callSendCreateGoodReceiptSAP(Id recordID){ 
          System.enqueueJob(new callSendCreateGRSAPQueuable(recordID));    
    }
    
     /**
    * @author Roberta Porrega - roberta.porrega@nttdata.com 
    * @date Creation 30/08/2019
    * @description method for sending a Goods Receipt to SAP Procurement System
    * @param recordID is the id of the Object
    */	  
//    @future(callout=true)
    public static void sendCreateGoodReceiptSAP(Id recordID){
        XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper grWR = new XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper();
        List<XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper> items = new List<XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper>();
        List<gii__PurchaseOrderReceipt__c> purchaseOrderReceipt = new List<gii__PurchaseOrderReceipt__c>([SELECT Id,
                                                                                                          giic_DeliveryDate__c,giic_DeliveryDocumentID__c,
                                                                                                          gii__ReceiptDate__c,gii__PurchaseOrder__r.giic_Contract__r.XC_IDSYSSAP__c,
                                                                                                          gii__PurchaseOrder__r.giic_POCode__c,
                                                                                                          giic_IntegrationStatus__c,
                                                                                                          (SELECT Id ,gii__ReceivedQuantity__c,gii__OrderQuantity__c ,
                                                                                                           gii__PurchaseOrderReceipt__r.gii__PurchaseOrder__r.giic_POCode__c,
                                                                                                           gii__PurchaseOrderLine__r.giic_POLPosition__c,gii__Product__r.gii__ProductCode__c
                                                                                                           FROM gii__Purchase_Order_Receipt_Lines__r)
                                                                                                          FROM gii__PurchaseOrderReceipt__c 
                                                                                                          WHERE Id =:recordID 
                                                                                                         AND gii__PurchaseOrder__r.giic_POCode__c != null]);
        
        if(purchaseOrderReceipt.isEmpty()){
            return;
        } 
        
        grWR.source_system = 'XCustomerB2C';
        grWR.sfdc_id = purchaseOrderReceipt[0].Id ;
        grWR.target_system =  purchaseOrderReceipt[0].gii__PurchaseOrder__r.giic_Contract__r.XC_IDSYSSAP__c;
        grWR.document_date = purchaseOrderReceipt[0].giic_DeliveryDate__c;
        grWR.reference = purchaseOrderReceipt[0].giic_DeliveryDocumentID__c;
        grWR.registration_date = purchaseOrderReceipt[0].gii__ReceiptDate__c ;
        Map<String, Integer> mapProductVsQuantity = new  Map<String, Integer>();
        Map<String, gii__PurchaseOrderReceiptLine__c> mapProductVsPOR = new  Map<String, gii__PurchaseOrderReceiptLine__c>(); 
        for(gii__PurchaseOrderReceiptLine__c porl : purchaseOrderReceipt[0].gii__Purchase_Order_Receipt_Lines__r){
            if(!mapProductVsQuantity.containskey(porl.gii__Product__r.gii__ProductCode__c + porl.gii__purchaseOrderLine__r.giic_POLPosition__c)){
                mapProductVsQuantity.put(porl.gii__Product__r.gii__ProductCode__c + porl.gii__purchaseOrderLine__r.giic_POLPosition__c, 0);
                mapProductVsPOR.put(porl.gii__Product__r.gii__ProductCode__c + porl.gii__purchaseOrderLine__r.giic_POLPosition__c, porl);
            }
            Integer qty = mapProductVsQuantity.get(porl.gii__Product__r.gii__ProductCode__c + porl.gii__purchaseOrderLine__r.giic_POLPosition__c);
             mapProductVsQuantity.put(porl.gii__Product__r.gii__ProductCode__c + porl.gii__purchaseOrderLine__r.giic_POLPosition__c, qty + (Integer)porl.gii__ReceivedQuantity__c );
        }
        
        for(String porId : mapProductVsQuantity.keyset()){
            XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper it = new XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper();           
            it.po_number = mapProductVsPOR.get(porId).gii__PurchaseOrderReceipt__r.gii__PurchaseOrder__r.giic_POCode__c;
            it.qty =  mapProductVsQuantity.get(porId);
            it.sap_pos_po = (Integer) mapProductVsPOR.get(porId).gii__PurchaseOrderLine__r.giic_POLPosition__c ;            
            if((Decimal)mapProductVsQuantity.get(porId) == mapProductVsPOR.get(porId).gii__OrderQuantity__c ){
                it.last_request = 'X';
            }
           
			items.add(it);
        }
        
    	grWR.items = items;

        //fix ST
        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper wrReq = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
        wrReq.goods_receipt = grWR;
        //
		 String serverSystem =  grWR.target_system.substring(0,1) + '4P';
		// chiamata 
 		XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper response = XC_REST_GoodReceipt_Outbound.callToPostGoodsReceipt(wrReq,serverSystem);
        if(response.result.error_code == '0'){
            purchaseOrderReceipt[0].giic_IntegrationStatus__c = Label.giic_IntegrationStatusSuccess; 
            XC_UTIL_Sobject.updateListRecords(purchaseOrderReceipt);
        }else{
            purchaseOrderReceipt[0].giic_IntegrationStatus__c =Label.giic_IntegrationStatusFailure;
            giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
            errorLog.giic_Process__c = 'Purchase Order Receipt';
            errorLog.giic_PurchaseOrderReceipt__c = purchaseOrderReceipt[0].Id;
            errorLog.giic_ErrorDescription__c = response.result.message;  
            XC_UTIL_Sobject.insertRecord(errorLog); 
            XC_UTIL_Sobject.updateListRecords(purchaseOrderReceipt);
        }     
    }
    
         // INNER QUEABLE CLASS Update GR ON SAP
    public class callSendUpdateGRSAPQueuable implements Queueable, Database.AllowsCallouts{
        Id recordID ;
        
        public callSendUpdateGRSAPQueuable(Id recordID){
            this.recordID = recordID;
        }
        
        public void execute(QueueableContext context) {
            sendUpdateGoodReceiptSAP(this.recordID);
        }
    }
      /**
    * @author Roberta Porrega - roberta.porrega@nttdata.com 
    * @date Creation 30/08/2019
    * @description method for sending a Purchase Order to SAP Procurement System
    * @param recordID is the Id of the Object
    */	
	public static void callSendUpdateGoodReceiptSAP(Id recordID){ 
          System.enqueueJob(new callSendUpdateGRSAPQueuable(recordID));    
    }
    
     /**
    * @author Roberta Porrega - roberta.porrega@nttdata.com 
    * @date Creation 30/08/2019
    * @description method for sending a cancellation of Goods Receipt to SAP Procurement System
    * @param recordID is the id of the Object
    */	    
   // @future(callout=true)
    public static void sendUpdateGoodReceiptSAP(Id recordID){
        XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper grWR = new XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper();
        List<gii__PurchaseOrderReceiptStaging__c> purchaseOrderReceiptStaging = new List<gii__PurchaseOrderReceiptStaging__c>([SELECT Id,
                                                                                                                        giic_MaterialDocument__c,CreatedDate,
																														giic_YearDocument__c,
                                                                                                                        giic_ReceiptDate__c,
                                                                                                                        giic_PurchaseOrder__r.giic_Contract__r.XC_IDSYSSAP__c
                                                                                                                        FROM gii__PurchaseOrderReceiptStaging__c
                                                                                                                        WHERE Id = :recordID]);
        
        grWR.source_system = 'XCustomerB2C';
        grWR.sfdc_id = purchaseOrderReceiptStaging[0].Id ;
        grWR.target_system =  purchaseOrderReceiptStaging[0].giic_PurchaseOrder__r.giic_Contract__r.XC_IDSYSSAP__c;
        grWR.accounting_period = (Integer)purchaseOrderReceiptStaging[0].giic_YearDocument__c;             
        grWR.goods_receipt_number = purchaseOrderReceiptStaging[0].giic_MaterialDocument__c;     
		
        Date createdDate = Date.valueof(purchaseOrderReceiptStaging[0].CreatedDate);
        Date receiptDate = Date.valueof(purchaseOrderReceiptStaging[0].giic_ReceiptDate__c);
		Integer monthCreateDate = createdDate.month();
		Integer monthReceiptDate = receiptDate.month();
        if(monthCreateDate == monthReceiptDate){
             grWR.registration_date = receiptDate ; 
        }else{
             grWR.registration_date = createdDate ;    
        }
       
        //fix ST
        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper wrReq = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
        wrReq.goods_receipt = grWR;
        system.debug('grWR');
        //        
         String serverSystem =  grWR.target_system.substring(0,1) + '4P';     
 		XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper response = XC_REST_GoodReceipt_Outbound.callToPutGoodsReceipt(wrReq, serverSystem );
        if(response.result.error_code == '0'){
            purchaseOrderReceiptStaging[0].giic_IntegrationStatus__c = Label.giic_IntegrationStatusSuccess; 
            XC_UTIL_Sobject.updateListRecords(purchaseOrderReceiptStaging);
        }else{
            purchaseOrderReceiptStaging[0].giic_IntegrationStatus__c =Label.giic_IntegrationStatusFailure;
            giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
            errorLog.giic_Process__c = 'Purchase Order Receipt';
            errorLog.giic_PurchaseOrderReceiptStaging__c = purchaseOrderReceiptStaging[0].Id;
            errorLog.giic_ErrorDescription__c = response.result.message;  
            XC_UTIL_Sobject.insertRecord(errorLog); 
            XC_UTIL_Sobject.updateListRecords(purchaseOrderReceiptStaging);
        }
    }  
    
    // INNER QUEABLE CLASS CREATE GR ON 3PL
    public class callSendCreateGR3PLQueuable implements Queueable, Database.AllowsCallouts{
        Id recordID ;
        
        public callSendCreateGR3PLQueuable(Id recordID){
            this.recordID = recordID;
        }
        
        public void execute(QueueableContext context) {
            sendCreateGoodReceipt3PL(this.recordID);
            system.debug('ho chiamato sendCreateGoodReceipt3PL');
        }
    }
    
	public static void callSendCreateGoodReceipt3PL(Id recordID){ 
          System.enqueueJob(new callSendCreateGR3PLQueuable(recordID));    
    }
        /**
    * @author Alberto Pompei - alberto.pompei@nttdata.com 
    * @date Creation 15/07/2021
    * @description method for sending a Goods Receipt to 3PL
    * @param recordID is the id of the Object
    */	  

    //NR1923
    public static void sendCreateGoodReceipt3PL(Id recordID){
        XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper grWR = new XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper();
        List<XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper> items = new List<XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper>();
        List<gii__PurchaseOrderReceipt__c> purchaseOrderReceipt = new List<gii__PurchaseOrderReceipt__c>([SELECT Id,
                                                                                                          giic_DeliveryDate__c,giic_DeliveryDocumentID__c,
                                                                                                          gii__ReceiptDate__c, gii__PurchaseOrder__c, gii__PurchaseOrder__r.giic_Contract__r.XC_IDSYSSAP__c,
                                                                                                          gii__PurchaseOrder__r.giic_POCode__c, gii__PurchaseOrder__r.giic_LegalEntity__c, gii__PurchaseOrder__r.giic_PartnerGoodReceiptF__c,
                                                                                                          giic_IntegrationStatus__c, gii__ShipTo__r.giic_WarehouseCode__c, gii__ShipTo__r.gii__DefaultReceivingLocation__r.name,
                                                                                                          gii__ShipTo__r.giic_ParentWarehouse__c, gii__ShipTo__r.giic_ServerSystem__c, gii__ShipTo__r.giic_ParentWarehouse__r.giic_ServerSystem__c,
                                                                                                          gii__ShipTo__r.giic_WarehouseType__c, gii__PurchaseOrder__r.Name,
                                                                                                          (SELECT Id ,gii__ReceivedQuantity__c,gii__OrderQuantity__c ,
                                                                                                           gii__PurchaseOrderReceipt__r.gii__PurchaseOrder__r.giic_POCode__c,
                                                                                                           gii__PurchaseOrderLine__c, gii__PurchaseOrderLine__r.giic_POLPosition__c, 
                                                                                                           gii__Product__r.gii__ProductCode__c, gii__Product__r.giic_SKUCode__c, gii__Product__r.giic_EANReference__c,
                                                                                                           gii__ProductSerial__c, gii__ProductSerial__r.name, gii__ProductLot__r.name,
                                                                                                           gii__ShipTo__r.giic_WarehouseCode__c, gii__ShipTo__r.gii__DefaultReceivingLocation__r.name
                                                                                                           FROM gii__Purchase_Order_Receipt_Lines__r)
                                                                                                          FROM gii__PurchaseOrderReceipt__c 
                                                                                                          WHERE Id =:recordID 
                                                                                                          AND gii__PurchaseOrder__r.giic_PartnerGoodReceiptF__c = true
                                                                                                          AND gii__ShipTo__r.giic_WarehouseType__c = 'Local' /* 
                                                                                                         AND gii__PurchaseOrder__r.giic_POCode__c != null*/]);
        
        if(purchaseOrderReceipt.isEmpty()){
            return;
        } 
        
        //if(purchaseOrderReceipt[0].gii__ShipTo__r.giic_ParentWarehouse__r.giic_ServerSystem__c != null || purchaseOrderReceipt[0].gii__ShipTo__r.giic_ServerSystem__c != null){

            grWR.sfdc_id = purchaseOrderReceipt[0].Id ;
            grWR.document_date = purchaseOrderReceipt[0].giic_DeliveryDate__c;
            grWR.registration_date = purchaseOrderReceipt[0].gii__ReceiptDate__c;
            grWR.po_id = purchaseOrderReceipt[0].gii__PurchaseOrder__c;
        	grWR.po_number = purchaseOrderReceipt[0].gii__PurchaseOrder__r.Name;
            
            for(gii__PurchaseOrderReceiptLine__c porl : purchaseOrderReceipt[0].gii__Purchase_Order_Receipt_Lines__r){
                XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper it = new XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper();
                it.product_code = porl.gii__Product__r.gii__ProductCode__c;
                it.ean_code = porl.gii__Product__r.giic_EANReference__c;
                it.sku_code = porl.gii__Product__r.giic_SKUCode__c;
                it.pol_id = porl.gii__PurchaseOrderLine__c;
                it.warehouse_code = porl.gii__ShipTo__r.giic_WarehouseCode__c;
                it.location_name = porl.gii__ShipTo__r.gii__DefaultReceivingLocation__r.name;
                it.qty = integer.valueOf(porl.gii__ReceivedQuantity__c);
                if(porl.gii__ProductSerial__c != null){
                	it.serial_numbers = new List<XC_REST_GoodsReceipt_Inbound_U.SerialNumbersWrapper>();
                	XC_REST_GoodsReceipt_Inbound_U.SerialNumbersWrapper sn = new XC_REST_GoodsReceipt_Inbound_U.SerialNumbersWrapper();
                	sn.serial_number = porl.gii__ProductSerial__r.name;
                	it.serial_numbers.add(sn);
                }
                if(porl.gii__ProductLot__c != null){
                    it.lot_numbers = new List<XC_REST_GoodsReceipt_Inbound_U.LotNumbersWrapper>();
                    XC_REST_GoodsReceipt_Inbound_U.LotNumbersWrapper ln = new XC_REST_GoodsReceipt_Inbound_U.LotNumbersWrapper();
                    ln.lot_number = porl.gii__ProductLot__r.name;
                    ln.quantity = integer.valueOf(porl.gii__ReceivedQuantity__c) ;
                    it.lot_numbers.add(ln);
                }
                items.add(it);   
            }
            
            grWR.items = items;

            XC_REST_GoodsReceipt_Inbound_U.RequestWrapper wrReq = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
            wrReq.goods_receipt = grWR;
            
            //String serverSystem = purchaseOrderReceipt[0].gii__ShipTo__r.giic_ServerSystem__c;
            String serverSystem;
            /*giic_ConsoleIntegrationLP__c cs = giic_ConsoleIntegrationLP__c.getvalues(purchaseOrderReceipt[0].gii__PurchaseOrder__r.giic_LegalEntity__c);
                if(cs!=null){
                    if(cs.giic_ActiveConfiguration__c) {
                        system.debug('@@@@ CS ' + cs);                                    		
                        serverSystem=cs.giic_SendPO__c;
                        system.debug('@@@@ sendPO :' + cs.giic_SendPO__c);
                    }
                }*/
        
			//NR2097
			List<giic_ConsoleIntegrationLP__c> CS_CI = giic_ConsoleIntegrationLP__c.getAll().values();
		
			for (giic_ConsoleIntegrationLP__c CSett : CS_CI) {
				if ((CSett.giic_LegalEntity__c == purchaseOrderReceipt[0].gii__PurchaseOrder__r.giic_LegalEntity__c)&&(CSett.giic_ActiveConfiguration__c==TRUE)) {
					serverSystem=CSett.giic_SendPO__c;
					Break;
					}
			}        
			system.debug('wrReq: '+ wrReq );
            // chiamata 
            XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper response = new  XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper();
        if(!test.isRunningTest()){response = XC_REST_GoodReceipt_Outbound.callToPostGoodsReceipt(wrReq,serverSystem);}
            system.debug('response: '+ response);
            if(response.result.error_code == '0'){
                purchaseOrderReceipt[0].giic_IntegrationStatus__c = Label.giic_IntegrationStatusSuccess; 
                XC_UTIL_Sobject.updateListRecords(purchaseOrderReceipt);
            }else{
                giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
                errorLog.Name = Label.giic_ErrorLogIntegration;
                errorLog.giic_Process__c = 'Purchase Order Receipt';
                errorLog.giic_PurchaseOrderReceipt__c = purchaseOrderReceipt[0].Id;
                errorLog.giic_ErrorDescription__c = response.result.message;
                purchaseOrderReceipt[0].giic_IntegrationStatus__c =Label.giic_IntegrationStatusFailure; 
                XC_UTIL_Sobject.insertRecord(errorLog); 
                XC_UTIL_Sobject.updateListRecords(purchaseOrderReceipt);
            }     
        /*}
        else{
            giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
            errorLog.Name = Label.giic_ErrorLogIntegration;
            errorLog.giic_PurchaseOrderReceipt__c = purchaseOrderReceipt[0].Id;
            errorLog.giic_Process__c = 'Purchase Order Receipt';
            String message = 'Integration Server System is not defined on Central Warehouse';
            errorLog.giic_ErrorDescription__c = 'Integration Error:  ' +  message;
            purchaseOrderReceipt[0].giic_IntegrationStatus__c =Label.giic_IntegrationStatusFailure;
            XC_UTIL_Sobject.insertRecord(errorLog); 
            XC_UTIL_Sobject.updateListRecords(purchaseOrderReceipt);
        }*/
    }


    // INNER QUEABLE CLASS CREATE TO GR ON 3PL
    public class callSendCreateTOGR3PLQueuable implements Queueable, Database.AllowsCallouts{
        Id recordID ;
        
        public callSendCreateTOGR3PLQueuable(Id recordID){
            this.recordID = recordID;
        }
        
        public void execute(QueueableContext context) {
            sendCreateGoodReceipt3PLTO(this.recordID);
            
        }
    }
      /**
    * @author Alberto Pompei - alberto.pompei@nttdata.com 
    * @date Creation 23/07/2021
    * @description method for sending a TO Good Receipt to 3PL Procurement System
    * @param recordID is the Id of the Object
    */	
	public static void callSendCreateTOGoodReceipt3PL(Id recordID){ 
          System.enqueueJob(new callSendCreateTOGR3PLQueuable(recordID));    
    }


    public static void sendCreateGoodReceipt3PLTO(Id recordID){
        XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper grWR = new XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper();
        List<XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper> items = new List<XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper>();
        List<gii__Receipt__c> Receipt = new List<gii__Receipt__c>([SELECT id, gii__Warehouse__r.giic_WarehouseCode__c, gii__Warehouse__r.gii__DefaultReceivingLocation__r.name,
                                                                        gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ServerSystem__c,
                                                                        gii__TransferOrder__c, gii__TransferOrder__r.giic_PartnerGRGIF__c, gii__TransferOrder__r.giic_LegalEntity__c,
                                                                        gii__TransferOrder__r.gii__FromWarehouse__r.giic_WarehouseType__c, gii__TransferOrder__r.gii__FromWarehouse__r.giic_ServerSystem__c,
                                                                        gii__TransferOrderLine__c, gii__TransferOrderLine__r.gii__Product__c, gii__TransferOrderLine__r.gii__Product__r.giic_EANReference__c, gii__TransferOrderLine__r.gii__Product__r.gii__ProductCode__c,
                                                                        gii__TransferOrderLine__r.gii__Product__r.giic_SKUCode__c,
                                                                        gii__ProductSerial__c, gii__ProductSerial__r.name, gii__ProductLot__c, gii__ProductLot__r.name, gii__ReceiptQuantity__c, gii__ShippedDate__c, gii__ReceiptDate__c, gii__TransferOrder__r.Name
                                                                        FROM gii__Receipt__c
                                                                        WHERE id =: recordID
                                                                        AND gii__TransferOrder__r.giic_PartnerGRGIF__c = true
                                                                        AND gii__Warehouse__r.giic_WarehouseType__c = 'Local']);
        if(Receipt.isEmpty()){return;}

        grWR.sfdc_id = Receipt[0].Id ;
        grWR.document_date = Receipt[0].gii__ShippedDate__c;
        grWR.registration_date = Receipt[0].gii__ReceiptDate__c;
        grWR.to_id = Receipt[0].gii__TransferOrder__c;
        grWR.to_number = Receipt[0].gii__TransferOrder__r.Name;
        XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper it = new XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper();
        it.product_code = Receipt[0].gii__TransferOrderLine__r.gii__Product__r.gii__ProductCode__c;
        it.ean_code = Receipt[0].gii__TransferOrderLine__r.gii__Product__r.giic_EANReference__c;
        it.sku_code = Receipt[0].gii__TransferOrderLine__r.gii__Product__r.giic_SKUCode__c;
        it.tol_id = Receipt[0].gii__TransferOrderLine__c;
        it.warehouse_code = Receipt[0].gii__Warehouse__r.giic_WarehouseCode__c;
        it.location_name = Receipt[0].gii__Warehouse__r.gii__DefaultReceivingLocation__r.name;
        it.qty = Integer.valueOf(Receipt[0].gii__ReceiptQuantity__c);
        items.add(it);
        if(Receipt[0].gii__ProductSerial__c != null){
            it.serial_numbers = new List<XC_REST_GoodsReceipt_Inbound_U.SerialNumbersWrapper>();
            XC_REST_GoodsReceipt_Inbound_U.SerialNumbersWrapper sn = new XC_REST_GoodsReceipt_Inbound_U.SerialNumbersWrapper();
            sn.serial_number = Receipt[0].gii__ProductSerial__r.name;
            it.serial_numbers.add(sn);
        }
        if(Receipt[0].gii__ProductLot__c != null){
            it.lot_numbers = new List<XC_REST_GoodsReceipt_Inbound_U.LotNumbersWrapper>();
            XC_REST_GoodsReceipt_Inbound_U.LotNumbersWrapper ln = new XC_REST_GoodsReceipt_Inbound_U.LotNumbersWrapper();
            ln.lot_number = Receipt[0].gii__ProductLot__r.name;
            ln.quantity = integer.valueOf(Receipt[0].gii__ReceiptQuantity__c) ;
            it.lot_numbers.add(ln);
        }

        grWR.items = items;

        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper wrReq = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
        wrReq.goods_receipt = grWR;
        
        //String serverSystem = Receipt[0].gii__Warehouse__r.giic_ServerSystem__c;
        String serverSystem;
        /*giic_ConsoleIntegrationLP__c cs = giic_ConsoleIntegrationLP__c.getvalues(Receipt[0].gii__TransferOrder__r.giic_LegalEntity__c);
        if(cs!=null){
            if(cs.giic_ActiveConfiguration__c) {
                system.debug('@@@@ CS ' + cs);                                    		
                serverSystem=cs.giic_SendPO__c;
                system.debug('@@@@ sendPO :' + cs.giic_SendPO__c);
            }
        }*/
        
		//NR2097
		List<giic_ConsoleIntegrationLP__c> CS_CI = giic_ConsoleIntegrationLP__c.getAll().values();
		
		for (giic_ConsoleIntegrationLP__c CSett : CS_CI) {
			if ((CSett.giic_LegalEntity__c == Receipt[0].gii__TransferOrder__r.giic_LegalEntity__c)&&(CSett.giic_ActiveConfiguration__c==TRUE)) {
				serverSystem=CSett.giic_SendPO__c;
				Break;
				}
		}

        // chiamata 
        XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper response = new XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper();
        if(!test.isRunningTest()){response = XC_REST_GoodReceipt_Outbound.callToPostGoodsReceipt(wrReq,serverSystem);}
        system.debug('response: '+ response);
        if(response.result.error_code == '0'){
            Receipt[0].giic_IntegrationStatus__c = Label.giic_IntegrationStatusSuccess; 
            XC_UTIL_Sobject.updateListRecords(Receipt);
        }else{
            giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
            errorLog.Name = Label.giic_ErrorLogIntegration;
            errorLog.giic_Process__c = 'Transfer Order Receipt';
            errorLog.giic_Receipt__c = Receipt[0].Id;
            errorLog.giic_ErrorDescription__c = response.result.message;
            Receipt[0].giic_IntegrationStatus__c =Label.giic_IntegrationStatusFailure; 
            XC_UTIL_Sobject.insertRecord(errorLog); 
            XC_UTIL_Sobject.updateListRecords(Receipt);
        }
    }
}