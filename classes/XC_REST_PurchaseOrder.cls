/**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 30/08/2019
* @description Class of future methods for asynchronous calls about Purchase Order
*/
public without sharing class XC_REST_PurchaseOrder {
    
    public class PoFinallyWrapper{
        map<id,gii__PurchaseOrder__c> poMap = new map<id,gii__PurchaseOrder__c>();
        map<id,gii__PurchaseOrderLine__c> poLineMap = new Map<id, gii__PurchaseOrderLine__c>();
        List<giic_ErrorLog__c> errorLogList = new List<giic_ErrorLog__c>();
        List<XC_Integration_Log__c> integrationLogList = new List<XC_Integration_Log__c>();
    }
    
    
    // INNER QUEABLE CLASS CREATE PO ON SAP
    public class callSendCreatePOQueuable implements Queueable, Database.AllowsCallouts{
        Id recordID ;
        
        public callSendCreatePOQueuable(Id recordID){
            this.recordID = recordID;
        }
        
        
        public void execute(QueueableContext context) {
            PoFinallyWrapper pfw1 = sendCreatePurchaseOrderSAP(this.recordID);
            PoFinallyWrapper pfw2 = sendCreatePurchaseOrder3PL(this.recordID, pfw1);
            
            map<id,gii__PurchaseOrder__c> poMap = pfw2.poMap;
            map<id,gii__PurchaseOrderLine__c> poLineMap = pfw2.poLineMap;
            List<giic_ErrorLog__c> errorLogList = pfw2.errorLogList;
            List<XC_Integration_Log__c> integrationLogList = pfw2.integrationLogList;
            update poMap.values();
            if(!Test.isRunningTest()){
                update poLineMap.values();
            }
            insert errorLogList;
            insert integrationLogList;
                
        }
        
    }
    /**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 30/08/2019
* @description method for sending a Purchase Order to SAP Procurement System
* @param recordID is the Id of the Object
*/  
    public static void callSendCreatePurchaseOrder(Id recordID){ 
        System.enqueueJob(new callSendCreatePOQueuable(recordID));    
    }
   
    
    
    
    // INNER QUEABLE CLASS UPDATE PO ON SAP
    public class callSendUpdatePOQueuable implements Queueable, Database.AllowsCallouts{
        Id recordID ;
        
        public callSendUpdatePOQueuable(Id recordID){
            this.recordID = recordID;
        }
        
        public void execute(QueueableContext context) {
            PoFinallyWrapper pfw1 = sendUpdatePurchaseOrderSAP(this.recordID);
            PoFinallyWrapper pfw2 = sendUpdatePurchaseOrder3PL(this.recordID, pfw1);
            map<id,gii__PurchaseOrder__c> poMap = pfw2.poMap;
            map<id,gii__PurchaseOrderLine__c> poLineMap = pfw2.poLineMap;
            List<giic_ErrorLog__c> errorLogList = pfw2.errorLogList;
            List<XC_Integration_Log__c> integrationLogList = pfw2.integrationLogList;
            update poMap.values();
            update poLineMap.values();
            insert errorLogList;
            insert integrationLogList;
        }
    }
    /**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 30/08/2019
* @description method for sending a Purchase Order to SAP Procurement System
* @param recordID is the Id of the Object
*/  
    public static void callSendUpdatePurchaseOrder(Id recordID){ 
        System.enqueueJob(new callSendUpdatePOQueuable(recordID));    
    }
    /**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 30/08/2019
* @description method for sending a cancellation of Purchase Order to SAP Procurement System
* @param recordID is the Id of the Object
*/
    //@future(callout=true)
    public static PoFinallyWrapper sendUpdatePurchaseOrderSAP(Id recordID){
        System.debug('In sendUpdatePurchaseOrderSAP');
        
        PoFinallyWrapper SAPUpdateWrapper = new PoFinallyWrapper();
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper poWR = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper(); 
        //NR1923  add to query giic_NewDeliveryDate__c,giic_TrackingSubstate__c,giic_DeliveryTracking__c, giic_CarrierName__c,giic_NewPickupDate__c
        List<gii__PurchaseOrder__c> purchaseOrder = new List<gii__PurchaseOrder__c>([SELECT Id,giic_MultiTargetSystem__c,giic_Contract__r.XC_IDSYSSAP__c,
                                                                                     giic_POCode__c, giic_NewDeliveryDate__c,giic_TrackingSubstate__c,
                                                                                     giic_DeliveryTracking__c, giic_CarrierName__c,giic_NewPickupDate__c,
                                                                                     giic_Status_SAP_integration__c
                                                                                     FROM gii__PurchaseOrder__c 
                                                                                     WHERE Id =:recordID 
                                                                                     AND giic_POCode__c != null ]);
        
        if(purchaseOrder.isEmpty() || !(purchaseOrder[0].giic_MultiTargetSystem__c).contains('SAP')){ 
            System.debug('ESCO');
            return SAPUpdateWrapper; 
        }
        if(String.isBlank(purchaseOrder[0].giic_POCode__c)){
            
            giic_ErrorLog__c objErr= new giic_ErrorLog__c(
            Name =  'Error on Object: Purchase Order',
            giic_PurchaseOrder__c=purchaseOrder[0].Id,
            giic_ClassMessage__c = 'XC_REST_PurchaseOrder',
            giic_Process__c   = 'sendUpdatePurchaseOrderSAP',
            giic_IntegrationWrapper__c = '',
            giic_ErrorDescription__c = 'POCode is Blank');
            insert objErr;
            return SAPUpdateWrapper;
        }
        poWR.po_number =  purchaseOrder[0].giic_POCode__c;
        poWR.sfdc_id =  purchaseOrder[0].Id;
        poWR.source_system = 'XCustomerB2C' ;
        poWR.target_system = purchaseOrder[0].giic_Contract__r.XC_IDSYSSAP__c;
        //NR1923
        poWR.New_Delivery_Date= purchaseOrder[0].giic_NewDeliveryDate__c;
        poWR.Tracking_Substate=purchaseOrder[0].giic_TrackingSubstate__c;
        poWR.URL_Delivery_Tracking=purchaseOrder[0].giic_DeliveryTracking__c;
        poWR.Carrier_Name=purchaseOrder[0].giic_CarrierName__c;
        poWR.New_Pickup_Date=purchaseOrder[0].giic_NewPickupDate__c;
        
        //fix ST
        XC_REST_PurchaseOrder_Inbound_U.RequestWrapper wrReq = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
        wrReq.purchase_order = poWR;
        //
        String serverSystem = poWR.target_system != null ? poWR.target_system.substring(0,1) + '4P' : 'S4P';
        
        // chiamata Outbound
        XC_REST_PurchaseOrder_Outbound.PurchaseOrderInboundResponseWrapper purchaseOrderResponse = XC_REST_PurchaseOrder_Outbound.callToPutPurchaseOrder(wrReq , serverSystem);
        XC_REST_PurchaseOrder_Inbound_U.ResponseWrapper response = purchaseOrderResponse.result;
        SAPUpdateWrapper.integrationLogList.addAll(purchaseOrderResponse.integrationLog);
        
        if(response.result.error_code == '0'){purchaseOrder[0].giic_IntegrationStatus__c = Label.giic_IntegrationStatusSuccess;purchaseOrder[0].giic_Status_SAP_integration__c = false;SAPUpdateWrapper.poMap.put(purchaseOrder[0].Id, purchaseOrder[0]);}
        else{
            purchaseOrder[0].giic_IntegrationStatus__c =Label.giic_IntegrationStatusFailure;
           purchaseOrder[0].giic_Status_SAP_integration__c = true;//NR1923
            SAPUpdateWrapper.poMap.put(purchaseOrder[0].Id, purchaseOrder[0]);
            giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
            errorLog.Name = Label.giic_ErrorLogIntegration + ' [Update]';
            errorLog.giic_PurchaseOrder__c = purchaseOrder[0].Id;
            errorLog.giic_Process__c =  'Integration SAP';//Label.giic_ErrorLogIntegration;
            errorLog.giic_ErrorDescription__c = response.result.message;  
            SAPUpdateWrapper.errorLogList.add(errorLog);
            
        } 
        
        return SAPUpdateWrapper;
    }
    
    
   
    
    /**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 30/08/2019
* @description method for sending a cancellation of Purchase Order to SAP Procurement System
* @param recordID is the Id of the Object
*/
    //@future(callout=true)
    public static PoFinallyWrapper sendUpdatePurchaseOrder3PL(Id recordID, PoFinallyWrapper update3PLWrapper){
        System.debug('@@@@ In sendUpdatePurchaseOrder3PL');
        
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper poWR = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();  
        List<XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper>  itWR = new  List<XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper> ();
        //NR1923  add to query giic_NewDeliveryDate__c,giic_TrackingSubstate__c,giic_DeliveryTracking__c, giic_CarrierName__c,giic_NewPickupDate__c
        //gii__ShipTo__r.giic_ParentWarehouse__r.giic_ServerSystem__c,if wh is local,to retrieve server system parent
        //add in the condition local warehouse
         List<gii__PurchaseOrder__c> purchaseOrder = new List<gii__PurchaseOrder__c>([SELECT Id,giic_Status__c,gii__ShipTo__c,giic_MultiTargetSystem__c,
                                                                                     Name,gii__OrderDate__c,gii__RequiredDate__c,gii__ShipTo__r.giic_ServerSystem__c,
                                                                                     giic_NewDeliveryDate__c,giic_TrackingSubstate__c,giic_LegalEntity__c,gii__ShipTo__r.gii__WareHouseCountry__c,
                                                                                     gii__ShipTo__r.giic_ParentWarehouse__r.giic_ServerSystem__c,
                                                                                     giic_DeliveryTracking__c, giic_CarrierName__c,giic_NewPickupDate__c,giic_Status_4PL_integration__c,
                                                                                     (SELECT Id ,gii__Product__r.gii__ProductReference__r.XC_CodeSAP__c,gii__Product__r.gii__ProductReference__r.ProductCode,
                                                                                      gii__Product__r.giic_EANReference__c,gii__Product__r.gii__ProductReference__r.giic_UnitMeasure__c,
                                                                                      gii__Product__r.giic_Stream__c,
                                                                                      gii__ShipTo__r.gii__DefaultIssueLocation__r.Name,gii__ShipTo__r.giic_WarehouseCode__c,gii__Product__r.Name,
                                                                                      gii__OrderQuantity__c, Name,gii__Product__r.gii__Description__c,gii__Product__r.giic_SKUCode__c
                                                                                      FROM gii__Purchase_Order_Lines__r)
                                                                                     FROM gii__PurchaseOrder__c 
                                                                                     WHERE Id =:recordID
                                                                                     AND (gii__ShipTo__r.giic_WarehouseType__c = :Label.giic_WarehouseTypeCentral or gii__ShipTo__r.giic_WarehouseType__c ='Local') ]);
        
        if(purchaseOrder.isEmpty() || !(purchaseOrder[0].giic_MultiTargetSystem__c).contains('3PL')){ return update3PLWrapper;  }
        
        poWR.po_number =  purchaseOrder[0].Name;
        poWR.sfdc_id =  purchaseOrder[0].Id; 
        poWR.status = purchaseOrder[0].giic_Status__c; 
        poWR.source_system = 'XCustomerB2C' ;        
        poWR.target_system = purchaseOrder[0].gii__ShipTo__r.giic_ServerSystem__c ; 
        
        //NR1923 
        //read a custom setting in order to set server system which Logistic Partner to send PO
        /*giic_ConsoleIntegrationLP__c cs = giic_ConsoleIntegrationLP__c.getvalues(purchaseorder[0].giic_LegalEntity__c);
		if(cs!=null){if(cs.giic_ActiveConfiguration__c) {system.debug('@@@@ CS ' + cs);poWR.target_system=cs.giic_SendPO__c;system.debug('@@@@ sendPO :' + cs.giic_SendPO__c);}}*/
        
		//NR2097
		List<giic_ConsoleIntegrationLP__c> CS_CI = giic_ConsoleIntegrationLP__c.getAll().values();
		
		for (giic_ConsoleIntegrationLP__c CSett : CS_CI) {if ((CSett.giic_LegalEntity__c == purchaseorder[0].giic_LegalEntity__c)&&(CSett.giic_ActiveConfiguration__c==TRUE)) {poWR.target_system=CSett.giic_SendPO__c;Break;}}        
        
		// set new field on po json
        if(purchaseOrder[0].giic_Status__c == 'Approved'){
        	poWR.New_Delivery_Date= purchaseOrder[0].giic_NewDeliveryDate__c;
        	poWR.Tracking_Substate=purchaseOrder[0].giic_TrackingSubstate__c;
        	poWR.URL_Delivery_Tracking=purchaseOrder[0].giic_DeliveryTracking__c;
        	poWR.Carrier_Name=purchaseOrder[0].giic_CarrierName__c;
        	poWR.New_Pickup_Date=purchaseOrder[0].giic_NewPickupDate__c;
        }
        
        if(purchaseOrder[0].gii__ShipTo__r.giic_ParentWarehouse__r.giic_ServerSystem__c != null || purchaseOrder[0].gii__ShipTo__r.giic_ServerSystem__c != null ){ 
            //fix ST
            XC_REST_PurchaseOrder_Inbound_U.RequestWrapper wrReq = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
            wrReq.purchase_order = poWR; 
            //NR1923 in the json will not be included the line item PO
            for(gii__PurchaseOrderLine__c pol : purchaseOrder[0].gii__Purchase_Order_Lines__r){
                    XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper it = new  XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper ();    
                    it.material_code = pol.gii__Product__r.gii__ProductReference__r.ProductCode;
                    it.ean_code = pol.gii__Product__r.giic_EANReference__c; 
                    it.sku_code = pol.gii__Product__r.giic_SKUCode__c; // new NR0740
                    it.qty = pol.gii__OrderQuantity__c;
                    it.short_description = pol.gii__Product__r.Name.length() >= 40 ? pol.gii__Product__r.Name.substring(0, 40) : pol.gii__Product__r.Name; 
                    it.unit_of_measure = pol.gii__Product__r.gii__ProductReference__r.giic_UnitMeasure__c;
                    it.warehouse_code = pol.gii__ShipTo__r.giic_WarehouseCode__c;
                    it.sfdc_id = pol.id;
                    it.location_name = pol.gii__ShipTo__r.gii__DefaultIssueLocation__r.Name; 
                    itWR.add(it);   
                }
            poWR.items = itWR; 
            
            // chiamata oubound 
            XC_REST_PurchaseOrder_Outbound.PurchaseOrderInboundResponseWrapper purchaseOrderResponse = XC_REST_PurchaseOrder_Outbound.callToPutPurchaseOrder(wrReq, poWR.target_system );
            XC_REST_PurchaseOrder_Inbound_U.ResponseWrapper response = purchaseOrderResponse.result;
            update3PLWrapper.integrationLogList.addAll(purchaseOrderResponse.integrationLog);
            if(response.result.error_code == '0'){
                System.debug('3PL update success');
                if(update3PLWrapper.poMap.containsKey(purchaseOrder[0].Id) && update3PLWrapper.poMap.get(purchaseOrder[0].Id).giic_IntegrationStatus__c==Label.giic_IntegrationStatusFailure ){purchaseOrder[0].giic_IntegrationStatus__c = Label.giic_IntegrationStatusFailure;purchaseOrder[0].giic_Status_4PL_integration__c = true;}
                else{purchaseOrder[0].giic_IntegrationStatus__c =Label.giic_IntegrationStatusSuccess;purchaseOrder[0].giic_Status_4PL_integration__c = false;}
                update3PLWrapper.poMap.put(purchaseOrder[0].Id, purchaseOrder[0]);
                
            }else{
                
                purchaseOrder[0].giic_IntegrationStatus__c =Label.giic_IntegrationStatusFailure;
                purchaseOrder[0].giic_Status_4PL_integration__c = true; //NR1923
                update3PLWrapper.poMap.put(purchaseOrder[0].Id, purchaseOrder[0]);
                giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
                errorLog.Name = Label.giic_ErrorLogIntegration;
                errorLog.giic_PurchaseOrder__c = purchaseOrder[0].Id;
                errorLog.giic_Process__c =  'Integration 3PL';//Label.giic_ErrorLogIntegration;
                errorLog.giic_ErrorDescription__c = response.result.message;  
                update3PLWrapper.errorLogList.add(errorLog);
                
            }
        }else{
            purchaseOrder[0].giic_IntegrationStatus__c =Label.giic_IntegrationStatusFailure;
            purchaseOrder[0].giic_Status_4PL_integration__c = true;//NR1923
            giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
            errorLog.Name = Label.giic_ErrorLogIntegration;
            errorLog.giic_PurchaseOrder__c = purchaseOrder[0].Id;
            errorLog.giic_Process__c =  'Integration 3PL';//Label.giic_ErrorLogIntegration;
           
            String message = 'Integration Server System is not defined on Central Warehouse';
            errorLog.giic_ErrorDescription__c = 'Integration Error:  ' +  message;  
            update3PLWrapper.poMap.put(purchaseOrder[0].Id, purchaseOrder[0]);
            update3PLWrapper.errorLogList.add(errorLog);
            
        }
        
        return update3PLWrapper;
    }
    
     /**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 30/08/2019
* @description method for sending a Purchase Order to SAP Procurement System
* @param recordID is the Id of the Object
*/  
    
    public static PoFinallyWrapper sendCreatePurchaseOrderSAP(Id recordID){
        System.debug('In sendCreatePurchaseOrderSAP');
        PoFinallyWrapper createSAPWrapper = new PoFinallyWrapper();
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper poWR = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();
        List<XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper>  itWR = new  List<XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper> ();
        List<gii__PurchaseOrder__c> purchaseOrder = new List<gii__PurchaseOrder__c>();
        purchaseOrder = new List<gii__PurchaseOrder__c>([SELECT Id,giic_MultiTargetSystem__c,
                                                                                     giic_Contract__c,
                                                                                     giic_Contract__r.XC_IDSYSSAP__c, 
                                                                                     giic_Contract__r.XC_SupplierCode__c,
                                                                                     gii__OrderDate__c,
                                                                                     giic_PurchasingOrganization__c,
                                                                                     giic_PurchasingGroup__c,
                                                                                     giic_Contract__r.XC_CompanyCode__c,
                                                                                     giic_Contract__r.XC_PaymentTerm__c,
                                                                                     giic_Contract__r.XC_CurrencyKey__c,
                                                                                     giic_Contract__r.XC_CategoryRace__c,
                                                                                     giic_Contract__r.XC_ObjectSynthetic__c,
                                                                                     giic_Contract__r.XC_CIG__c,
                                                                                     giic_Contract__r.XC_CUP__c,
                                                                                     giic_CIG__c,
                                                                                     giic_CUP__c,
                                                                                     giic_Status_SAP_integration__c,
                                                                                     giic_Contract__r.XC_SolidalResponsability__c,
                                                                                     giic_Contract__r.XC_WarrantyReference__c,
                                                                                     giic_Contract__r.XC_ContractSAP__c ,
                                                                                     giic_Contract__r.XC_SupplierCodeIO__c,
                                                                                     giic_Contract__r.XC_SupplierCodeEF__c,
                                                                                     giic_Contract__r.XC_Language__c,
                                                                                     giic_Contract__r.Name, 
                                                                                     giic_PriceBookId__c,giic_IntegrationStatus__c,
                                                         							 giic_CapexOpexFormula__c, //GC_NR2628
                                                                                     (SELECT Id ,giic_POLPosition__c,
                                                                                      giic_AccountAssignmentCategory__c,
                                                                                      gii__OrderQuantity__c,gii__PromisedDate__c,
                                                                                      giic_Plant__c, gii__PurchaseOrder__c,
                                                                                      gii__PurchaseOrder__r.giic_Contract__r.XC_Language__c,
                                                                                      gii__PurchaseOrder__r.giic_Contract__r.Name,
                                                                                      gii__PurchaseOrder__r.giic_Contract__r.XC_ContractSAP__c,
                                                                                      gii__LineNetAmount__c,giic_UnitRequisitioner__c,
                                                                                      gii__UnitPrice__c,gii__Product__c,gii__ShipTo__c,
                                                                                      gii__Product__r.gii__ProductReference__r.XC_CompanyCode__c,
                                                                                      gii__Product__r.giic_ProductLine__c,
                                                                                      gii__Product__r.giic_ProductServiceType__c,
                                                                                      gii__Product__r.giic_Stream__c,
                                                                                      gii__Product__r.giic_CostCenter__c,
                                                                                      gii__Product__r.Name
                                                                                      FROM gii__Purchase_Order_Lines__r)
                                                                                      FROM gii__PurchaseOrder__c 
                                                                                      WHERE Id =:recordID AND giic_PurchaseOrderMaster__c = null AND giic_POCode__c = null
                                                                                      AND giic_MultiTargetSystem__c!=null ]);
        
        if(purchaseOrder.isEmpty() || !(purchaseOrder[0].giic_MultiTargetSystem__c).contains('SAP') ){ return createSAPWrapper; }
        
        Id priceBook = purchaseOrder[0].giic_PriceBookId__c;
        /* (1**) PA 27/05/2021 get only id product to use in next query pricebookentry to avoid too many query rows for pricebook with line more 200000*/
        List<gii__PurchaseOrderLine__c  > lstProductSOline = new List<gii__PurchaseOrderLine__c>();
        lstProductSOLine = purchaseOrder[0].gii__Purchase_Order_Lines__r;
        set<Id> onlyIdLine = new Set<Id>();
        for(gii__PurchaseOrderLine__c soLineNested : lstProductSOLine) onlyIdLine.add(soLineNested.gii__Product__c);
        system.debug('@@@ Final List Id POLine:'+ onlyIdLine);
            
        System.debug('@#@#'+priceBook);
        Map<Id, gii__PriceBookEntry__c> mapProductPbE = new Map<Id, gii__PriceBookEntry__c>();
        /* (1**) PA 27/05/21 add in WHERE condition <<and gii__Product__c in :onlyIdLine>> to retrieve only PBE line basing on POLine*/
        List<gii__PriceBookEntry__c> pbEntry = new List<gii__PriceBookEntry__c>([SELECT Id,
                                                                                 giic_CategoryPosition__c,
                                                                                 giic_AccountAssignmentCategory__c,
                                                                                 gii__Product__c,
                                                                                 gii__Product__r.gii__ProductReference__r.XC_CodeSAP__c,
                                                                                 giic_Description__c, 
                                                                                 giic_Plant__c,
                                                                                 giic_MaterialGroup__c,
                                                                                 giic_UnitRequisitioner__c,
                                                                                 giic_ContractPosition__c,
                                                                                 giic_UnitMeasure__c,
                                                                                 giic_Unit__c,
                                                                                 giic_CostCenter__c
                                                                                 FROM gii__PriceBookEntry__c
                                                                                 WHERE gii__PriceBook__c = :priceBook and gii__Product__c in :onlyIdLine]);
        system.debug('@@@ pbEntry SIZE:' + pbEntry.Size());
        for(gii__PriceBookEntry__c pbe : pbEntry){
            mapProductPbE.put(pbe.gii__Product__c, pbe) ;  
        }  
        system.debug('@@@ mapProductPbE:' + mapProductPbE);
        // cessionary
        poWR.cig = purchaseOrder[0].giic_CIG__c != null ? purchaseOrder[0].giic_CIG__c : purchaseOrder[0].giic_Contract__r.XC_CIG__c;
        poWR.cup  = purchaseOrder[0].giic_CUP__c != null ? purchaseOrder[0].giic_CUP__c : purchaseOrder[0].giic_Contract__r.XC_CUP__c;
        poWR.company = purchaseOrder[0].giic_Contract__r.XC_CompanyCode__c;
        poWR.contract_number = purchaseOrder[0].giic_Contract__r.XC_ContractSAP__c;
       // poWR.contract_supervisor = 'AE50889';
        poWR.partner_sap_id = purchaseOrder[0].giic_Contract__r.XC_SupplierCode__c;
        poWR.payment_condition =  purchaseOrder[0].giic_Contract__r.XC_PaymentTerm__c ;
        poWR.po_currency = purchaseOrder[0].giic_Contract__r.XC_CurrencyKey__c;
        poWR.purchase_order_date = purchaseOrder[0].gii__OrderDate__c;
        // purchase_order_type
        poWR.purchasing_group = purchaseOrder[0].giic_PurchasingGroup__c;
        poWR.purchasing_org = purchaseOrder[0].giic_PurchasingOrganization__c;
        poWR.sfdc_id =  purchaseOrder[0].Id;
        poWR.short_subject =  purchaseOrder[0].giic_Contract__r.XC_ObjectSynthetic__c;
        poWR.solidal_resp = purchaseOrder[0].giic_Contract__r.XC_SolidalResponsability__c ;
        poWR.source_system = 'XCustomerB2C' ;
        poWR.supplier_code_ef = purchaseOrder[0].giic_Contract__r.XC_SupplierCodeEF__c ;
        poWR.supplier_code_io = purchaseOrder[0].giic_Contract__r.XC_SupplierCodeIO__c ;
        poWR.target_system = purchaseOrder[0]. giic_Contract__r.XC_IDSYSSAP__c;
        poWR.tender_category = purchaseOrder[0].giic_Contract__r.XC_CategoryRace__c;      
        poWR.transfer_date = Date.today();
        //poWR.warranty_reference = purchaseOrder[0].giic_Contract__r.XC_WarrantyReference__c; 
        Integer posPOL = 0;
        for(gii__PurchaseOrderLine__c pol : purchaseOrder[0].gii__Purchase_Order_Lines__r){
            XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper it = new  XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper ();            
            it.accounting_category = pol.giic_AccountAssignmentCategory__c ;  // = 'P' wait approvazione
            it.applicant_unit = pol.giic_UnitRequisitioner__c;
            it.communication_language = pol.gii__PurchaseOrder__r.giic_Contract__r.XC_Language__c ;
            it.contract_number = pol.gii__PurchaseOrder__r.giic_Contract__r.XC_ContractSAP__c ;
            it.contract_pos_number = (Integer)mapProductPbE.get(pol.gii__Product__c).giic_ContractPosition__c ; 
            it.division = pol.giic_Plant__c;   
            it.goods_group  = mapProductPbE.get(pol.gii__Product__c).giic_MaterialGroup__c ;
            // it.iva_code
           //  it.material_code =  mapProductPbE.get(pol.gii__Product__c).gii__Product__r.gii__ProductReference__r.XC_CodeSAP__c;
            //it.net_price = pol.gii__LineNetAmount__c  ; 
            it.net_price = pol.gii__UnitPrice__c;
            it.price_unit = Integer.valueOf(mapProductPbE.get(pol.gii__Product__c).giic_Unit__c) != null && Integer.valueOf(mapProductPbE.get(pol.gii__Product__c).giic_Unit__c) != 0  ? Integer.valueOf(mapProductPbE.get(pol.gii__Product__c).giic_Unit__c) : 1;  
            it.qty = pol.gii__OrderQuantity__c;
            it.sap_pos_category = mapProductPbE.get(pol.gii__Product__c).giic_CategoryPosition__c ;
            posPol = posPOL + 10; 
            it.sap_pos_po = posPol;
            it.short_description = pol.gii__Product__r.Name.length() >= 40 ? pol.gii__Product__r.Name.substring(0, 40) : pol.gii__Product__r.Name; 
            it.unit_of_measure = mapProductPbE.get(pol.gii__Product__c).giic_UnitMeasure__c;
            it.cost_center = (it.accounting_category == 'K' &&  mapProductPbE.get(pol.gii__Product__c).giic_CostCenter__c!=null) ?  mapProductPbE.get(pol.gii__Product__c).giic_CostCenter__c :  pol.gii__Product__r.giic_CostCenter__c ;  
            
            /**NR2428 */
            //String digit = (purchaseOrder[0].giic_Contract__r.XC_CompanyCode__c == 'ES21' ||purchaseOrder[0].giic_Contract__r.XC_CompanyCode__c == 'ES5R') ? 'MP' : '00';
            String digit ='00';
            if(purchaseOrder[0].giic_Contract__r.XC_CompanyCode__c == 'ES5R' || purchaseOrder[0].giic_Contract__r.XC_CompanyCode__c == 'ES5B'){ 
               if(pol.gii__Product__r.giic_Stream__c == 'B2C' && pol.gii__Product__r.giic_ProductLine__c=='E500') digit ='MP';
               if(pol.gii__Product__r.giic_Stream__c == 'B2C' && (pol.gii__Product__r.giic_ProductLine__c=='E700' || pol.gii__Product__r.giic_ProductLine__c=='A000')) digit ='MR';
               if(pol.gii__Product__r.giic_Stream__c == 'B2BG' && (pol.gii__Product__r.giic_ProductLine__c=='E700' || pol.gii__Product__r.giic_ProductLine__c=='E600' || pol.gii__Product__r.giic_ProductLine__c=='E700' || pol.gii__Product__r.giic_ProductLine__c=='A000')) digit ='DZ';
              
            }
            /**NR2428 */
            
            String correctStreamChar = 'C';
            if(pol.gii__Product__r.giic_Stream__c == 'B2BG'){correctStreamChar  = 'S';}
            string capexopex=purchaseOrder[0].giic_CapexOpexFormula__c; //GC_NR2628
            string DigitCO = 'Y';//GC_NR2628
            String wbe;
            if (capexopex=='Capex' && pol.gii__Product__r.gii__ProductReference__r.XC_CompanyCode__c=='CO10' && pol.gii__Product__r.giic_ProductLine__c=='E400' ){
                DigitCO='W';
            	wbe = pol.gii__Product__r.gii__ProductReference__r.XC_CompanyCode__c + pol.gii__Product__r.giic_ProductLine__c + digit +DigitCO+correctStreamChar+ pol.gii__Product__r.giic_ProductServiceType__c +'3700001'; //GC_NR2628
            }else{ //GC_NR2628
            	wbe = pol.gii__Product__r.gii__ProductReference__r.XC_CompanyCode__c + pol.gii__Product__r.giic_ProductLine__c + digit +DigitCO+correctStreamChar+ pol.gii__Product__r.giic_ProductServiceType__c +'070'; //GC_NR2628
            }
            //String wbe = pol.gii__Product__r.gii__ProductReference__r.XC_CompanyCode__c + pol.gii__Product__r.giic_ProductLine__c + digit +'Y'+correctStreamChar+ pol.gii__Product__r.giic_ProductServiceType__c +'070' ;
            
            it.wbs_element = wbe ;
            
            pol.giic_POLPosition__c = posPol;
            itWR.add(it);   
        }
        
        poWR.items = itWR;
        
        //fix ST
        XC_REST_PurchaseOrder_Inbound_U.RequestWrapper wrReq = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
        wrReq.purchase_order = poWR;
        //
         String serverSystem =  poWR.target_system != null ? poWR.target_system.substring(0,1) + '4P' : 'S4P';
        /// chiamata outbound
        XC_REST_PurchaseOrder_Outbound.PurchaseOrderInboundResponseWrapper purchaseOrderResponse = XC_REST_PurchaseOrder_Outbound.callToPostPurchaseOrder(wrReq, serverSystem); //**fix ST */
        XC_REST_PurchaseOrder_Inbound_U.ResponseWrapper response = purchaseOrderResponse.result;
        createSAPWrapper.integrationLogList.addAll(purchaseOrderResponse.integrationLog);
        
        if(response.result.error_code == '0'){
            System.debug('sendCreatePurchaseOrderSAP error code 0');
            purchaseOrder[0].giic_IntegrationStatus__c = Label.giic_IntegrationStatusSuccess;
            purchaseOrder[0].giic_Status_SAP_integration__c=false; //NR1923
            createSAPWrapper.poMap.put(purchaseOrder[0].Id, purchaseOrder[0]);
            
            for(gii__PurchaseOrderLine__c pol : purchaseOrder[0].gii__Purchase_Order_Lines__r){
                createSAPWrapper.poLineMap.put(pol.Id,pol);
            }
            
           
          //  XC_UTIL_Sobject.updateListRecords(purchaseOrder);
          //  XC_UTIL_Sobject.updateListRecords(purchaseOrder[0].gii__Purchase_Order_Lines__r);
        }else{
            purchaseOrder[0].giic_IntegrationStatus__c =Label.giic_IntegrationStatusFailure;
            purchaseOrder[0].giic_Status_SAP_integration__c=true; //NR1923
            giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
            errorLog.Name = Label.giic_ErrorLogIntegration +' [Create]';
            errorLog.giic_PurchaseOrder__c = purchaseOrder[0].Id;
            errorLog.giic_Process__c = 'Integration SAP';//Label.giic_ErrorLogIntegration;
            errorLog.giic_ErrorDescription__c = poWR.target_system + '   Integration Error:  ' + response.result.message;  
            System.debug('Inserisco ErrorLog in Create');
            createSAPWrapper.poMap.put(purchaseOrder[0].Id, purchaseOrder[0]);
            for(gii__PurchaseOrderLine__c pol : purchaseOrder[0].gii__Purchase_Order_Lines__r){
                createSAPWrapper.poLineMap.put(pol.Id,pol);
            }
            createSAPWrapper.errorLogList.add(errorLog);
            /*
            XC_UTIL_Sobject.insertRecord(errorLog);
            XC_UTIL_Sobject.updateListRecords(purchaseOrder);
            XC_UTIL_Sobject.updateListRecords(purchaseOrder[0].gii__Purchase_Order_Lines__r);
            */
        } 
        
        
        return createSAPWrapper;
    }
    
     /**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 30/08/2019
* @description method for sending a cancellation of Purchase Order to SAP Procurement System
* @param recordID is the Id of the Object
*/
    //  @future(callout=true)
    public static PoFinallyWrapper sendCreatePurchaseOrder3PL(Id recordID, PoFinallyWrapper create3PLWrapper){
        
        System.debug('@@@@ In sendCreatePurchaseOrder3PL');
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper poWR = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();  
        List<XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper>  itWR = new  List<XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper> ();
        XC_REST_PurchaseOrder_Inbound_U.LocationWrapper locationWR = new  XC_REST_PurchaseOrder_Inbound_U.LocationWrapper();
        //NR1923
        XC_REST_PurchaseOrder_Inbound_U.AddressSupplierWrapper addressSuppl = new  XC_REST_PurchaseOrder_Inbound_U.AddressSupplierWrapper(); 
        List<XC_REST_PurchaseOrder_Inbound_U.AddressSupplierWrapper> addrSupp = new  List<XC_REST_PurchaseOrder_Inbound_U.AddressSupplierWrapper>();
        /* NR1923 add in the query new field for4PL */
        //giic_Delivery4PLRequired__c, giic_NewPickupDate__c,giic_PartnerGoodReceiptF__c,giic_ShipFromName__c,gii__Supplier__r.name,
        //giic_ShipFromAddress__c,giic_ShipFromProvince__c,giic_ShipFromZipCode__c,giic_ShipFromCity__c,giic_ShipFromCountry__c (object :XC_Address__c)
        //  gii__ShipTo__r.giic_ParentWarehouse__r.giic_ServerSystem__c to have , if wh is local, the server system parent
        List<gii__PurchaseOrder__c> purchaseOrder = new List<gii__PurchaseOrder__c>([SELECT Id,giic_Status__c,gii__ShipTo__c,gii__ShipTo__r.giic_WarehouseCode__c,gii__ShipTo__r.giic_ServerSystem__c,
                                                                                     Name,gii__OrderDate__c,gii__RequiredDate__c,gii__ShipTo__r.gii__Account__r.PrimaryEmail__c,giic_LegalEntity__c,
                                                                                     gii__ShipTo__r.gii__Account__r.Phone   ,gii__ShipToStreet__c,gii__ShipToZipPostalCode__c,gii__ShipToCity__c,
                                                                                     gii__ShipToCountry__c, gii__ShipTo__r.gii__DefaultIssueLocation__r.Name,giic_MultiTargetSystem__c, giic_Status_4PL_integration__c,
                                                                                     gii__ShipTo__r.giic_ParentWarehouse__r.giic_ServerSystem__c,
                                                                                     giic_Delivery4PLRequired__c, giic_PickupDate__c, giic_NewPickupDate__c,giic_PartnerGoodReceiptF__c,giic_ShipFromName__c,gii__Supplier__r.name,
                                                                                     giic_ShipFromAddress__c,giic_ShipFromProvince__c,giic_ShipFromZipCode__c,giic_ShipFromCity__c,giic_ShipFromCountry__c,
                                                                                     (SELECT Id ,gii__Product__r.gii__ProductReference__r.XC_CodeSAP__c,
                                                                                      gii__Product__r.giic_EANReference__c,gii__PromisedDate__c,gii__Product__r.giic_SKUCode__c,
                                                                                      gii__OrderQuantity__c, Name,gii__Product__r.gii__Description__c,
                                                                                      gii__Product__r.Name ,gii__Product__r.gii__ProductReference__r.ProductCode
                                                                                      FROM gii__Purchase_Order_Lines__r)
                                                                                      FROM gii__PurchaseOrder__c 
                                                                                      WHERE Id =:recordID
                                                                                      AND  (gii__ShipTo__r.giic_WarehouseType__c = :Label.giic_WarehouseTypeCentral or gii__ShipTo__r.giic_WarehouseType__c ='Local')
                                                                                      AND giic_MultiTargetSystem__c!=null]);
        
        if(purchaseOrder.isEmpty() || !(purchaseOrder[0].giic_MultiTargetSystem__c).contains('3PL')){return create3PLWrapper; }
        system.debug('@@@@ qui:' + purchaseOrder[0].gii__ShipTo__r.giic_ServerSystem__c);
        //NR1923 add condition for local in order to retrieve Server System from Parent
        //if purchaseOrder[0].gii__ShipTo__r.giic_ParentWarehouse__r.giic_ServerSystem__c != null
        if(purchaseOrder[0].gii__ShipTo__r.giic_ParentWarehouse__r.giic_ServerSystem__c != null || purchaseOrder[0].gii__ShipTo__r.giic_ServerSystem__c != null){   
             system.debug('@@@@ qui2');
            poWR.po_number =  purchaseOrder[0].Name;
            poWR.purchase_order_date = purchaseOrder[0].gii__OrderDate__c;
            poWR.po_required_date = purchaseOrder[0].gii__RequiredDate__c;
            poWR.sfdc_id =  purchaseOrder[0].Id; 
            poWR.source_system = 'XCustomerB2C' ;
            poWR.status = purchaseOrder[0].giic_Status__c; 
            poWR.target_system = purchaseOrder[0].gii__ShipTo__r.giic_ServerSystem__c ;
            poWR.warehouse_code = purchaseOrder[0].gii__ShipTo__r.giic_WarehouseCode__c;
            poWR.ship_email = purchaseOrder[0].gii__ShipTo__r.gii__Account__r.PrimaryEmail__c;
            poWR.ship_primary_phone = purchaseOrder[0].gii__ShipTo__r.gii__Account__r.Phone;
            
             //NR1923 
        	//read a custom setting in order to set server system which Logistic Partner to send PO
        	/*giic_ConsoleIntegrationLP__c cs = giic_ConsoleIntegrationLP__c.getvalues(purchaseorder[0].giic_LegalEntity__c);
             system.debug('@@@@ cs:'+cs);
            if(cs!=null){if(cs.giic_ActiveConfiguration__c) {system.debug('@@@@ CS ' + cs);poWR.target_system=cs.giic_SendPO__c;system.debug('@@@@ sendPO :' + cs.giic_SendPO__c);}}*/
            
			//NR2097
			List<giic_ConsoleIntegrationLP__c> CS_CI = giic_ConsoleIntegrationLP__c.getAll().values();
		
			for (giic_ConsoleIntegrationLP__c CSett : CS_CI) {if ((CSett.giic_LegalEntity__c == purchaseorder[0].giic_LegalEntity__c)&&(CSett.giic_ActiveConfiguration__c==TRUE)) {poWR.target_system=CSett.giic_SendPO__c;Break;}}
            //      poWR.ship_secondary_phone
            //fix ST
            XC_REST_PurchaseOrder_Inbound_U.RequestWrapper wrReq = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
                       
            wrReq.purchase_order = poWR;
            locationWR.location_name = purchaseOrder[0].gii__ShipTo__r.gii__DefaultIssueLocation__r.Name;
            locationWR.street_type = 'Street';
            locationWR.address = purchaseOrder[0].gii__ShipToStreet__c;
            locationWR.zip_code = purchaseOrder[0].gii__ShipToZipPostalCode__c;
            locationWR.city = purchaseOrder[0].gii__ShipToCity__c;
            locationWR.country = purchaseOrder[0].gii__ShipToCountry__c;  
            poWR.location = locationWR; 
             /** start NR1923 */
            poWR.Pickup_Date = purchaseOrder[0].giic_PickupDate__c;
            poWR.Delivery_4PL_Required= purchaseOrder[0].giic_Delivery4PLRequired__c;
            poWR.Partner_GR_Required = purchaseOrder[0].giic_PartnerGoodReceiptF__c;
                       
            addressSuppl.Ship_From_Name = purchaseOrder[0].gii__Supplier__r.Name;
            addressSuppl.Ship_From_address= purchaseOrder[0].giic_ShipFromAddress__c;
            addressSuppl.Ship_from_Province =purchaseOrder[0].giic_ShipFromProvince__c;
            addressSuppl.Ship_from_zip_code= purchaseOrder[0].giic_ShipFromZipCode__c;
            addressSuppl.Ship_from_City= purchaseOrder[0].giic_ShipFromCity__c;
            addressSuppl.Ship_from_Country= purchaseOrder[0].giic_ShipFromCountry__c;
            addrSupp.add(addressSuppl);
            poWR.ship_from= addrSupp;
             /** end  NR1923 */                 
            
            for(gii__PurchaseOrderLine__c pol : purchaseOrder[0].gii__Purchase_Order_Lines__r){
                XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper it = new  XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper ();    
                it.material_code = pol.gii__Product__r.gii__ProductReference__r.ProductCode;
                it.ean_code = pol.gii__Product__r.giic_EANReference__c;
                it.sku_code = pol.gii__Product__r.giic_SKUCode__c;  // new NR0740
                it.promise_date = pol.gii__PromisedDate__c  ;
                it.qty = pol.gii__OrderQuantity__c;
                it.sfdc_id = pol.id;
                it.pol_number = pol.Name;
                it.short_description = pol.gii__Product__r.Name.length() >= 40 ? pol.gii__Product__r.Name.substring(0, 40) : pol.gii__Product__r.Name;  
                itWR.add(it);   
            }
            poWR.items = itWR;       
            
            
            XC_REST_PurchaseOrder_Outbound.PurchaseOrderInboundResponseWrapper purchaseOrderResponse  = XC_REST_PurchaseOrder_Outbound.callToPostPurchaseOrder(wrReq, poWR.target_system);
            XC_REST_PurchaseOrder_Inbound_U.ResponseWrapper response = purchaseOrderResponse.result;
            create3PLWrapper.integrationLogList.addAll(purchaseOrderResponse.integrationLog);
            System.debug('XC_REST_PurchaseOrder_Inbound_U.ResponseWrapper RESPONSE = '+response);
            if(response.result.error_code == '0'){
                System.debug('3PL create success');
                if(create3PLWrapper.poMap.containsKey(purchaseOrder[0].Id) && create3PLWrapper.poMap.get(purchaseOrder[0].Id).giic_IntegrationStatus__c==Label.giic_IntegrationStatusFailure ){purchaseOrder[0].giic_IntegrationStatus__c = Label.giic_IntegrationStatusFailure;purchaseOrder[0].giic_Status_4PL_integration__c =true;}
                else{purchaseOrder[0].giic_IntegrationStatus__c =Label.giic_IntegrationStatusSuccess;purchaseOrder[0].giic_Status_4PL_integration__c =false;}
                create3PLWrapper.poMap.put(purchaseOrder[0].Id, purchaseOrder[0]); 
            }else{
                purchaseOrder[0].giic_IntegrationStatus__c =Label.giic_IntegrationStatusFailure;
                purchaseOrder[0].giic_Status_4PL_integration__c =true; //NR1923
                create3PLWrapper.poMap.put(purchaseOrder[0].Id, purchaseOrder[0]);
                giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
                errorLog.Name = Label.giic_ErrorLogIntegration + ' [Create]';
                errorLog.giic_PurchaseOrder__c = purchaseOrder[0].Id;
                errorLog.giic_Process__c =  'Integration 3PL';//Label.giic_ErrorLogIntegration;
                errorLog.giic_ErrorDescription__c = poWR.target_system + '   Integration Error:  ' +  response.result.message;  
                System.debug('Inserisco error log 1');
                create3PLWrapper.errorLogList.add(errorLog); 
            }  
        }else{
            giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
            errorLog.Name = Label.giic_ErrorLogIntegration;
            errorLog.giic_PurchaseOrder__c = purchaseOrder[0].Id;
            errorLog.giic_Process__c =  'Integration 3PL';//Label.giic_ErrorLogIntegration;
            purchaseOrder[0].giic_IntegrationStatus__c =Label.giic_IntegrationStatusFailure;
            purchaseOrder[0].giic_Status_4PL_integration__c =true; //NR1923
            create3PLWrapper.poMap.put(purchaseOrder[0].Id, purchaseOrder[0]);
            String message = 'Integration Server System is not defined on Central Warehouse';
            errorLog.giic_ErrorDescription__c = 'Integration Error:  ' +  message;  
            System.debug('Inserisco error log 2');
            create3PLWrapper.errorLogList.add(errorLog); 
        }
        
        return create3PLWrapper;
        
    }
    
    /**
* @author Alberto Pompei - alberto.pompei@nttdata.com 
* @date Creation 19/07/2021
* @description method for sending a Purchase Order to 3PL
* @param recordID is the Id of the Object
*/
    // INNER QUEABLE CLASS UPDATE PO ON 3PL
    public class callSendUpdatePO3PLQueuable implements Queueable, Database.AllowsCallouts{
        Id recordID ;
        
        public callSendUpdatePO3PLQueuable(Id recordID){
            this.recordID = recordID;
        }
        
        public void execute(QueueableContext context) {
            PoFinallyWrapper pfw1 = new PoFinallyWrapper();
            system.debug('pfw1: '+ pfw1);
            system.debug('sto chiamando sendUpdatePurchaseOrderOnly3PL');
            PoFinallyWrapper pfw2 = sendUpdatePurchaseOrderOnly3PL(this.recordID, pfw1);
            map<id,gii__PurchaseOrder__c> poMap = pfw2.poMap;
            map<id,gii__PurchaseOrderLine__c> poLineMap = pfw2.poLineMap;
            List<giic_ErrorLog__c> errorLogList = pfw2.errorLogList;
            List<XC_Integration_Log__c> integrationLogList = pfw2.integrationLogList;
            update poMap.values();
            update poLineMap.values();
            insert errorLogList;
            insert integrationLogList;
        }
    }
      
    public static void callSendUpdatePurchaseOrder3PL(Id recordID){
        system.debug('sto chiamando callSendUpdatePO3PLQueuable');
        System.enqueueJob(new callSendUpdatePO3PLQueuable(recordID));    
    }
    
    public static PoFinallyWrapper sendUpdatePurchaseOrderOnly3PL(Id recordID, PoFinallyWrapper update3PLWrapper){
        System.debug('In sendUpdatePurchaseOrderOnly3PL');
        
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper poWR = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();  
        List<XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper>  itWR = new  List<XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper> ();
        //NR1923  add to query giic_NewDeliveryDate__c,giic_TrackingSubstate__c,giic_DeliveryTracking__c, giic_CarrierName__c,giic_NewPickupDate__c
        //gii__ShipTo__r.giic_ParentWarehouse__r.giic_ServerSystem__c,if wh is local,to retrieve server system parent
        //add in the condition local warehouse
         List<gii__PurchaseOrder__c> purchaseOrder = new List<gii__PurchaseOrder__c>([SELECT Id,giic_Status__c,gii__ShipTo__c,giic_MultiTargetSystem__c,
                                                                                     Name,gii__OrderDate__c,gii__RequiredDate__c,gii__ShipTo__r.giic_ServerSystem__c,
                                                                                     giic_NewDeliveryDate__c,giic_TrackingSubstate__c,giic_LegalEntity__c,gii__ShipTo__r.gii__WareHouseCountry__c,
                                                                                     gii__ShipTo__r.giic_ParentWarehouse__r.giic_ServerSystem__c,giic_IntegrationStatus__c,
                                                                                     giic_DeliveryTracking__c, giic_CarrierName__c,giic_NewPickupDate__c,giic_Status_4PL_integration__c, gii__Approved__c,
                                                                                     (SELECT Id ,gii__Product__r.gii__ProductReference__r.XC_CodeSAP__c,gii__Product__r.gii__ProductReference__r.ProductCode,
                                                                                      gii__Product__r.giic_EANReference__c,gii__Product__r.gii__ProductReference__r.giic_UnitMeasure__c,
                                                                                      gii__Product__r.giic_Stream__c,
                                                                                      gii__ShipTo__r.gii__DefaultIssueLocation__r.Name,gii__ShipTo__r.giic_WarehouseCode__c,gii__Product__r.Name,
                                                                                      gii__OrderQuantity__c, Name,gii__Product__r.gii__Description__c,gii__Product__r.giic_SKUCode__c
                                                                                      FROM gii__Purchase_Order_Lines__r)
                                                                                     FROM gii__PurchaseOrder__c 
                                                                                     WHERE Id =:recordID
                                                                                     AND (gii__ShipTo__r.giic_WarehouseType__c = :Label.giic_WarehouseTypeCentral or gii__ShipTo__r.giic_WarehouseType__c ='Local') ]);
        
        if(purchaseOrder.isEmpty() || !(purchaseOrder[0].giic_MultiTargetSystem__c).contains('3PL')){ return update3PLWrapper;  }
      
        	poWR.po_number =  purchaseOrder[0].Name;
        	poWR.sfdc_id =  purchaseOrder[0].Id; 
        	poWR.status = purchaseOrder[0].giic_Status__c; 
        	poWR.source_system = 'XCustomerB2C' ;        
        	poWR.target_system = purchaseOrder[0].gii__ShipTo__r.giic_ServerSystem__c ; 
      
        //NR1923 
        //read a custom setting in order to set server system which Logistic Partner to send PO
        /*giic_ConsoleIntegrationLP__c cs = giic_ConsoleIntegrationLP__c.getvalues(purchaseorder[0].giic_LegalEntity__c);
		if(cs!=null){if(cs.giic_ActiveConfiguration__c) {system.debug('@@@@ CS ' + cs);poWR.target_system=cs.giic_SendPO__c;system.debug('@@@@ sendPO :' + cs.giic_SendPO__c);}}*/

		//NR2097
		List<giic_ConsoleIntegrationLP__c> CS_CI = giic_ConsoleIntegrationLP__c.getAll().values();
		
		for (giic_ConsoleIntegrationLP__c CSett : CS_CI) {if ((CSett.giic_LegalEntity__c == purchaseorder[0].giic_LegalEntity__c)&&(CSett.giic_ActiveConfiguration__c==TRUE)) {poWR.target_system=CSett.giic_SendPO__c;Break;}}        
        
		// set new field on po json
		if(purchaseOrder[0].gii__Approved__c == true){
        	poWR.New_Delivery_Date= purchaseOrder[0].giic_NewDeliveryDate__c;
        	poWR.Tracking_Substate=purchaseOrder[0].giic_TrackingSubstate__c;
        	poWR.URL_Delivery_Tracking=purchaseOrder[0].giic_DeliveryTracking__c;
        	poWR.Carrier_Name=purchaseOrder[0].giic_CarrierName__c;
        	poWR.New_Pickup_Date=purchaseOrder[0].giic_NewPickupDate__c;
        }
        if(purchaseOrder[0].gii__ShipTo__r.giic_ParentWarehouse__r.giic_ServerSystem__c != null || purchaseOrder[0].gii__ShipTo__r.giic_ServerSystem__c != null ){ 
            //fix ST
            XC_REST_PurchaseOrder_Inbound_U.RequestWrapper wrReq = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
            wrReq.purchase_order = poWR; 
            
            system.debug('@@@@ request update:' + wrReq);
            // chiamata oubound 
            XC_REST_PurchaseOrder_Outbound.PurchaseOrderInboundResponseWrapper purchaseOrderResponse = XC_REST_PurchaseOrder_Outbound.callToPutPurchaseOrder(wrReq, poWR.target_system );
            XC_REST_PurchaseOrder_Inbound_U.ResponseWrapper response = purchaseOrderResponse.result;
            update3PLWrapper.integrationLogList.addAll(purchaseOrderResponse.integrationLog);
            if(response.result.error_code == '0'){
                System.debug('3PL update success:' + purchaseOrder[0].giic_IntegrationStatus__c);
                if(update3PLWrapper.poMap.containsKey(purchaseOrder[0].Id) && update3PLWrapper.poMap.get(purchaseOrder[0].Id).giic_IntegrationStatus__c==Label.giic_IntegrationStatusFailure ){purchaseOrder[0].giic_IntegrationStatus__c = Label.giic_IntegrationStatusFailure;purchaseOrder[0].giic_Status_4PL_integration__c = true;}
                else {purchaseOrder[0].giic_IntegrationStatus__c =Label.giic_IntegrationStatusSuccess;purchaseOrder[0].giic_Status_4PL_integration__c = false;}
                update3PLWrapper.poMap.put(purchaseOrder[0].Id, purchaseOrder[0]);
                system.debug('@@@@ mappa:' + update3PLWrapper.poMap);
                 System.debug('3PL update success after:' + purchaseOrder[0].giic_IntegrationStatus__c);
                
            }else{
                
                purchaseOrder[0].giic_IntegrationStatus__c =Label.giic_IntegrationStatusFailure;
                purchaseOrder[0].giic_Status_4PL_integration__c = true; //NR1923
                update3PLWrapper.poMap.put(purchaseOrder[0].Id, purchaseOrder[0]);
                giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
                errorLog.Name = Label.giic_ErrorLogIntegration;
                errorLog.giic_PurchaseOrder__c = purchaseOrder[0].Id;
                errorLog.giic_Process__c =  'Integration 3PL';//Label.giic_ErrorLogIntegration;
                errorLog.giic_ErrorDescription__c = response.result.message;  
                update3PLWrapper.errorLogList.add(errorLog);
                
            }
        }else{
            purchaseOrder[0].giic_IntegrationStatus__c =Label.giic_IntegrationStatusFailure;
            purchaseOrder[0].giic_Status_4PL_integration__c = true;//NR1923
            giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
            errorLog.Name = Label.giic_ErrorLogIntegration;
            errorLog.giic_PurchaseOrder__c = purchaseOrder[0].Id;
            errorLog.giic_Process__c =  'Integration 3PL';//Label.giic_ErrorLogIntegration;
           
            String message = 'Integration Server System is not defined on Central Warehouse';
            errorLog.giic_ErrorDescription__c = 'Integration Error:  ' +  message;  
            update3PLWrapper.poMap.put(purchaseOrder[0].Id, purchaseOrder[0]);
            update3PLWrapper.errorLogList.add(errorLog);
            
        }
        
        return update3PLWrapper;
    }
        
}