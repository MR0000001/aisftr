@isTest
public class giic_LCC022_RTSFromRMA_TEST {
	
    public class RTSWrapper{
        /** @description The record id. */
         public String rmaId;
        /** @description The record id. */
        public String POonWH;
          /** @description The record id. */
        public string rows;
          /** @description The record id. */
        public String POFinalWH;
          /** @description The record id. */
        public String reason;
          /** @description The record id. */
        public String RTSFinalWH;
       
            /** @description The record id. */
        public String TOFinalWH;
           
        /** @description The record id. */
        public String ShipFrom;
         
		/** @description The record id. */
        public String warehouseFrom;
        /** @description The record id. */
        public String warehouseAccount;
         /** @description The record id. */
        public String resulTOCreation;
          /** @description The record id. */
        public String resulPOCreation;  
           /** @description The record id. */
        public map<Id,giic_RMADispositionLine__c> mapdispline;
      
      }		
      
      	@isTest static void loadDataGridDispositionTest(){
            RTSWrapper rw = new RTSWrapper();
            Giic_UtilityClass_Test.systemPolicyCreation();
            Giic_UtilityClass_Test.gloviaSystemSettingCreation();
            Giic_UtilityClass_Test.accountCreation();
            Giic_UtilityClass_Test.wareHouseGroupCreation(); 
            Giic_UtilityClass_Test.warehouseCreation(); 
            Giic_UtilityClass_Test.locationCreation();
            Giic_UtilityClass_Test.productCreation();
            Gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1];
            prodRefObj.gii__SerialControlled__c=true;
            prodRefObj.gii__PrimarySupplier__c = giic_UtilityClass_Test.objAccountSupplier.id;
            update prodRefObj;    
                
            Giic_UtilityClass_Test.productSerialCreation(string.valueOf(prodRefObj.id));    
            Giic_UtilityClass_Test.contractCreation();
            Giic_UtilityClass_Test.priceBookCreation();
            Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);    
            Giic_UtilityClass_Test.rmaCreation();
            Giic_UtilityClass_Test.rmaLineCreation(prodRefObj);
            Giic_UtilityClass_Test.rmaReceiptCreation(prodRefObj);
            Giic_UtilityClass_Test.rmaDispositionCreation(prodRefObj);
             
            system.debug('@@@ TEST - RMA Creation:' + Giic_UtilityClass_Test.ObjRMA);
            system.debug('@@@ TEST - RMA Line Creation:' + Giic_UtilityClass_Test.ObjRMALine);
            system.debug('@@@ TEST - RMA Receipt Creation:' + Giic_UtilityClass_Test.ObjRMAReceipt);
            system.debug('@@@ TEST - RMA Disposition Creation:' + Giic_UtilityClass_Test.ObjRMADisposition);    
            
            map<string, string> mapIdToQuantity = new map<string, string>();
            map<Id,giic_RMADispositionLine__c> idToDispositionLine = new map<Id,giic_RMADispositionLine__c>();    
            XC_UTIL_ResultWrapper rsw = new XC_UTIL_ResultWrapper();
                
            Test.startTest();
            Giic_LCC022_RTSFromRMA.checkWHRMa(Giic_UtilityClass_Test.objRMA.Id);
            Giic_LCC022_RTSFromRMA.checkOnRmaEntity(Giic_UtilityClass_Test.objRMA.Id); 
     
            Map<Id, gii__RMADisposition__c> rmaDisp = new Map<Id, gii__RMADisposition__c> ([
            Select id,gii__ProductSerial__r.gii__PurchaseOrder__r.gii__Supplier__c,gii__Warehouse__c,Name,giic_RTSQuantity__c, gii__DispositionQuantity__c,gii__ProductSerial__c,gii__ProductSerial__r.Name,gii__RMAReceipt__c,
            gii__Product__r.Name, gii__Product__r.gii__PrimarySupplier__c, gii__Warehouse__r.Name, gii__DispositionLocation__r.Name,
            gii__DispositionLocation__r.giic_LocationType__c,(SELECT id,giic_Disposition_Qty__c,giic_RMADisposition__c,giic_Quantity__c,
                                                              giic_DispositionQuantity__c FROM RMA_Disposition_Lines__r) FROM gii__RMADisposition__c 
            where id=: Giic_UtilityClass_Test.objRMADisposition.Id ]);
            system.debug('@@@@ TEST - rmaDisp/DispositionLine;' + rmaDisp);
            for(gii__RMADisposition__c rmdis : rmaDisp.values()){
            	
                idToDispositionLine.put(rmdis.id, rmdis.RMA_Disposition_Lines__r);
                mapIdToQuantity.put(rmdis.Id, '1');
            }  
            system.debug('@@@@ TEST - idToDispositionLine before;' + idToDispositionLine);
           
          	system.debug('@@@@ TEST - warehouse RTS/PO/TO;' + Giic_UtilityClass_Test.objRMA.gii__warehouse__c);
            system.debug('@@@@ TEST - Account WH:' +Giic_UtilityClass_Test.objRMA.gii__Account__c);
			system.debug('@@@@ TEST - RMA WH:' + Giic_UtilityClass_Test.objRMA.gii__warehouse__c);
            
            string mapDispLine = JSON.serialize(idToDispositionLine);
            system.debug('@@@@ TEST - mapDispLine:' +mapDispLine);
            //Map<Id, Object> mapDispLine1 = (Map<Id, Object>) JSON.deserializeUntyped(mapDispLine);
            system.debug('@@@@ TEST - rmaDisp.values():' + rmaDisp.values());
            string a = JSON.serialize(rmaDisp.values());
            set<Id> lista1 = new Set<Id>();
            for(string Key: rmaDisp.keyset()) lista1.add(key);
            
            system.debug('@@@@ TEST - Lista1:' + Lista1);
            rw.RmaId = giic_UtilityClass_Test.objRMA.id;
            rw.rows = JSON.serialize(Lista1);
            rw.reason='Damaged';
            rw.POFinalWH=Giic_UtilityClass_Test.objRMA.gii__warehouse__c;
            rw.RTSFinalWH =Giic_UtilityClass_Test.objRMA.gii__warehouse__c;
            rw.TOFinalWH=Giic_UtilityClass_Test.objRMA.gii__warehouse__c;
            rw.shipFrom = 'Central';
            rw.warehouseFrom=Giic_UtilityClass_Test.objRMA.gii__warehouse__c;
            rw.warehouseAccount=Giic_UtilityClass_Test.objRMA.gii__Account__c;
            
            string listParam = JSON.serialize(rw);
            system.debug('@@@@ TEST - ListParam;' + listParam);
           // system.debug('@@@@ TEST - mapDispLine1;' + mapDispLine1);
            system.debug('@@@@ TEST - mapIdToQuantity;' + mapIdToQuantity);
            rsw=giic_LCC022_RTSFromRMA.createRTS(listParam, mapIdToQuantity,idToDispositionLine);
            
            Test.stopTest();    
         
     }
    
      	@isTest static void Giic_SearchAddressSupplier(){
       		Giic_UtilityClass_Test.systemPolicyCreation();
        	Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        	Giic_UtilityClass_Test.accountCreation();
        	Giic_UtilityClass_Test.wareHouseGroupCreation();
        	Giic_UtilityClass_Test.warehouseCreation();
        	Giic_UtilityClass_Test.locationCreation();
        	Giic_UtilityClass_Test.productCreation();
        	Giic_UtilityClass_Test.contractCreation();
        	Giic_UtilityClass_Test.pricebookCreation();
        	Giic_UtilityClass_Test.purchaseOrderCreation();
            Gii__Product2Add__c prodRefObj = [SELECT Id,gii__PrimarySupplier__c, gii__ProductReference__c FROM gii__Product2Add__c limit 1];
            prodRefObj.gii__PrimarySupplier__c = giic_UtilityClass_Test.objAccountSupplier.id;
            update prodRefObj;    
			
			gii__purchaseorder__c objPo = [SELECT gii__Supplier__c, giic_ShipFromAddress__c,giic_ShipFromProvince__c,giic_ShipFromZipCode__c,giic_ShipFromCity__c,giic_ShipFromCountry__c from gii__PurchaseOrder__c  Limit 1];
			
			XC_Address__c objAccountAddr = new XC_Address__c(XC_AddressProvince__c='Firenze',XC_AddressCountry__c='Italy',XC_PostalCode__c='34567',XC_City__c='Prato', XC_Account__c = objPo.gii__Supplier__c );
			insert objAccountAddr;
			
			
			Test.startTest();
			Giic_LCC022_RTSFromRMA.searchAddressSupplier(objPo.Id);
			Giic_LCC022_RTSFromRMA.saveAddressOnPo(objPo.Id, objAccountAddr.Id);
			
			Test.stopTest();
			
		}
    
        
    
}