public without sharing class XC_REST_GoodIssueTO {
    
    // INNER QUEABLE CLASS CREATE GI ON 3PL
    public class callSendCreateGI4PLQueuable implements Queueable, Database.AllowsCallouts{
        Id recordID ;
        
        public callSendCreateGI4PLQueuable(Id recordID){
            this.recordID = recordID;
        }
        
        public void execute(QueueableContext context) {
            sendCreateGoodIssue4PL(this.recordID);
            system.debug('ho chiamato sendCreateGoodIssue4PL');
        }
    }
    
    public static void callSendCreateGoodIssue4PL(Id recordID){ 
        System.enqueueJob(new callSendCreateGI4PLQueuable(recordID));    
    }
    
    public static void sendCreateGoodIssue4PL(Id recordID){
        XC_REST_GoodsIssue_U.GoodsIssueWrapper giWR = new XC_REST_GoodsIssue_U.GoodsIssueWrapper();
        List<XC_REST_GoodsIssue_U.ItemsWrapper> items = new List<XC_REST_GoodsIssue_U.ItemsWrapper>();
        
        List<gii__Shipment__c> Shipment = new List<gii__Shipment__c>([SELECT Id,giic_RegistrationDate__c,giic_DeliveryDate__c,giic_DeliveryDocumentID__c,giic_IntegrationStatus__c, gii__TransferOrder__r.Id,gii__TransferOrder__r.giic_PartnerGRGIF__c, gii__TransferOrder__r.Name, gii__TransferOrder__r.giic_LegalEntity__c,gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultReceivingLocation__r.name, gii__TransferOrder__r.gii__FromWarehouse__r.giic_WarehouseCode__c,gii__TransferOrder__r.gii__FromWarehouse__r.giic_WarehouseType__c,                                                                                  
                                                                      (SELECT Id ,gii__ShippedQuantity__c,
                                                                       gii__TransferOrderLine__r.Id,gii__TransferOrderLine__r.Name,gii__TransferOrderLine__r.gii__Product__r.gii__ProductCode__c, gii__TransferOrderLine__r.gii__Product__r.giic_SKUCode__c, gii__TransferOrderLine__r.gii__Product__r.giic_EANReference__c,gii__ProductSerial__c, gii__ProductSerial__r.name,gii__ProductLot__c, gii__ProductLot__r.name FROM gii__ShipmentDetails__r)
                                                                      FROM gii__Shipment__c where Id =:recordID AND gii__TransferOrder__c != Null AND gii__Status__c = 'Shipped']);
        
        if(Shipment.isEmpty()){
            return;
        }
        
        if(!(Shipment[0].gii__TransferOrder__r.gii__FromWarehouse__r.giic_WarehouseType__c=='Local' && Shipment[0].gii__TransferOrder__r.giic_PartnerGRGIF__c)) {
            return;
        }
        
        
        giWR.to_id = Shipment[0].gii__TransferOrder__r.Id ;
        giWR.to_number = Shipment[0].gii__TransferOrder__r.Name;
        giWR.registration_date = Shipment[0].giic_RegistrationDate__c ;
        giWR.document_date = Shipment[0].giic_DeliveryDate__c ;
        giWR.reference = Shipment[0].giic_DeliveryDocumentID__c ;
        
        for(gii__ShipmentDetail__c shdet : Shipment[0].gii__ShipmentDetails__r){
            XC_REST_GoodsIssue_U.ItemsWrapper it = new XC_REST_GoodsIssue_U.ItemsWrapper();
            it.to_line_id = shdet.gii__TransferOrderLine__r.Id;
			it.to_line_number = shdet.gii__TransferOrderLine__r.Name;
            it.qty = integer.valueOf(shdet.gii__ShippedQuantity__c);
            it.product_code = shdet.gii__TransferOrderLine__r.gii__Product__r.gii__ProductCode__c;
            it.ean_code = shdet.gii__TransferOrderLine__r.gii__Product__r.giic_EANReference__c;
            it.sku_code = shdet.gii__TransferOrderLine__r.gii__Product__r.giic_SKUCode__c;
            it.warehouse_code = Shipment[0].gii__TransferOrder__r.gii__FromWarehouse__r.giic_WarehouseCode__c;
            it.location_name = Shipment[0].gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultReceivingLocation__r.name;
            if(shdet.gii__ProductSerial__c != null){
                it.serial_numbers = new List<XC_REST_GoodsIssue_U.SerialNumbersWrapper>();
                XC_REST_GoodsIssue_U.SerialNumbersWrapper sn = new XC_REST_GoodsIssue_U.SerialNumbersWrapper();
                sn.serial_number = shdet.gii__ProductSerial__r.name;
                it.serial_numbers.add(sn);
            }
            if(shdet.gii__ProductLot__c != null){
                it.lot_numbers = new List<XC_REST_GoodsIssue_U.LotNumbersWrapper>();
                XC_REST_GoodsIssue_U.LotNumbersWrapper ln = new XC_REST_GoodsIssue_U.LotNumbersWrapper();
                ln.lot_number = shdet.gii__ProductLot__r.name;
                ln.quantity = integer.valueOf(shdet.gii__ShippedQuantity__c);
                it.lot_numbers.add(ln);
            }
            items.add(it);   
        }
        
        giWR.items = items;
        
        XC_REST_GoodsIssue_U.RequestWrapper wrReq = new XC_REST_GoodsIssue_U.RequestWrapper();
        wrReq.goods_issue = giWR;
        
        String serverSystem;
        /*giic_ConsoleIntegrationLP__c cs = giic_ConsoleIntegrationLP__c.getvalues(Shipment[0].gii__TransferOrder__r.giic_LegalEntity__c);
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
			if ((CSett.giic_LegalEntity__c == Shipment[0].gii__TransferOrder__r.giic_LegalEntity__c)&&(CSett.giic_ActiveConfiguration__c==TRUE)) {
				serverSystem=CSett.giic_SendPO__c;
				Break;
				}
		}
        system.debug('wrReq: '+ wrReq );
        // chiamata 
        XC_REST_GoodsIssue_U.ResponseWrapper response = XC_REST_GoodIssueTO_Outbound.callToPostGoodsIssue(wrReq,serverSystem);
        system.debug('response: '+ response);
        if(response.result.error_code == '0'){
            Shipment[0].giic_IntegrationStatus__c = Label.giic_IntegrationStatusSuccess; 
            XC_UTIL_Sobject.updateListRecords(Shipment);
        }else{
            giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
            errorLog.Name = Label.giic_ErrorLogIntegration;
            errorLog.giic_Process__c = 'Transfer Order GoodsIssue';
            errorLog.giic_Shipment__c = Shipment[0].Id;
            errorLog.giic_ErrorDescription__c = response.result.message;
            Shipment[0].giic_IntegrationStatus__c =Label.giic_IntegrationStatusFailure; 
            XC_UTIL_Sobject.insertRecord(errorLog); 
            XC_UTIL_Sobject.updateListRecords(Shipment);
        }     
        
    }
}