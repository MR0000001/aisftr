@isTest
private class giic_LCC002_ProcessDropShip_TEST {
    
    @TestSetup
    static void onSetup() {
      giic_GloviaLogisticSetting__c settings = giic_GloviaLogisticSetting__c.getOrgDefaults();
      settings.giic_DisableVRTestClasses__c = true;
      upsert settings custSettings__c.Id;
    }
	
    
        @isTest static void createCaseFromPOTest(){ 
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);    
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation(prodRefObj);
        WorkOrder workOrder = XC_DF_WorkOrder.createWorkOrders(1,'Delivery')[0];
        insert workOrder;
        gii__SalesOrder__c salesOrder = Giic_DF_Glovia.createSalesOrder();
        salesOrder.gii__Status__c = 'Shipped';
        salesOrder.giic_IsDelivery__c = true;
        salesOrder.giic_WorkOrder__c = workOrder.Id; 
        insert salesOrder;
        List<gii__PurchaseOrderLine__c> pOline = [SELECT Id FROM gii__PurchaseOrderLine__c ];
        List<String> purchaseOrderLineIds = new  List<String>();
        Map<String, String>  mapPolIdToQuantity = new  Map<String, String>();
             Map<String, List<String>> mapPolToSerialList = new  Map<String, List<String>> ();
            Map<String, String>  mapReceivedPolId = new Map<String, String> (); 
            for (gii__PurchaseOrderLine__c pol : pOline){
                purchaseOrderLineIds.add(pol.id);
                mapPolIdToQuantity.put(pol.id ,'1' );
                mapReceivedPolId.put(pol.id ,'1' );
            }
          
            Map<String, Object> jsonMap = new Map<String, Object>();
            jsonMap.put('deliveryDate', date.today());
            jsonMap.put('deliveryDoc', 'DELIVERYDATE');
            jsonMap.put('receiptDate', date.today());
            jsonMap.put('arrivalMaterial', date.today());
            
            String options = JSON.serialize(jsonMap);
            //Giic_UtilityClass_Test.objPO.giic_TargetSystem__c = System.Label.giic_TargetSystemGlovia;
         Giic_UtilityClass_Test.objPO.gii__DropShip__c = true;
         Giic_UtilityClass_Test.objPO.gii__SalesOrder__c = salesOrder.id;
            Test.startTest();
        	update Giic_UtilityClass_Test.objPO;
        	Giic_LCC002_ProcessDropShip.getPurchaseOrderLine( Giic_UtilityClass_Test.objPO.id);
            Giic_LCC002_ProcessDropShip.checkIfCanPress( Giic_UtilityClass_Test.objPO.id);
            Giic_LCC002_ProcessDropShip.manageCreatePorError('Open Quantity + Receiving Over Tolerance Quantity');
     		Giic_LCC002_ProcessDropShip.updatePoLine(mapReceivedPolId);
            Test.stopTest();    
         
     }
    
      @isTest static void createPOReceiptandLineSerialized(){ 
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        prodRefObj.gii__SerialControlled__c = true;
        update prodRefObj;
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);    
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation(prodRefObj);
        WorkOrder workOrder = XC_DF_WorkOrder.createWorkOrders(1,'Delivery')[0];
        insert workOrder;
        gii__SalesOrder__c salesOrder = Giic_DF_Glovia.createSalesOrder();
        salesOrder.gii__Status__c = 'Shipped';
        salesOrder.giic_IsDelivery__c = true;
        salesOrder.giic_WorkOrder__c = workOrder.Id; 
        insert salesOrder;
        List<gii__PurchaseOrderLine__c> pOline = [SELECT Id FROM gii__PurchaseOrderLine__c ];
        List<String> purchaseOrderLineIds = new  List<String>();
        Map<String, String>  mapPolIdToQuantity = new  Map<String, String>();
             Map<String, List<String>> mapPolToSerialList = new  Map<String, List<String>> ();
          Map<String,map<String,Integer>> idPOLToLotMap = new Map<String,map<String,Integer>>(); 
          
            Map<String, String>  mapReceivedPolId = new Map<String, String> (); 
            for (gii__PurchaseOrderLine__c pol : pOline){
                purchaseOrderLineIds.add(pol.id);
                mapPolIdToQuantity.put(pol.id ,'1' );
                mapReceivedPolId.put(pol.id ,'1' );
            }
          
            Map<String, Object> jsonMap = new Map<String, Object>();
            jsonMap.put('deliveryDate', date.today());
            jsonMap.put('deliveryDoc', 'DELIVERYDATE');
            jsonMap.put('receiptDate', date.today());
            jsonMap.put('arrivalMaterial', date.today());
            String options = JSON.serialize(jsonMap);
            //Giic_UtilityClass_Test.objPO.giic_TargetSystem__c = System.Label.giic_TargetSystemGlovia;
         Giic_UtilityClass_Test.objPO.gii__DropShip__c = true;
         Giic_UtilityClass_Test.objPO.gii__SalesOrder__c = salesOrder.id;
        
            Test.startTest();
        	update Giic_UtilityClass_Test.objPO;

        	Giic_LCC002_ProcessDropShip.createPOReceiptandLine(Giic_UtilityClass_Test.objPO.id , purchaseOrderLineIds, options, mapPolIdToQuantity, mapPolToSerialList,idPOLToLotMap);
     		
           
            Test.stopTest();    
         
     }
    
    
      @isTest static void createPOReceiptandLineNotSerialized(){ 
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
          
          giic_UtilityClass_Test.objProductTL2.XC_MaterialGroup__c = 'SLPI0401';
        update giic_UtilityClass_Test.objProductTL2;
        
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__Service__c, gii__ProductReference__c FROM gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id ];
          gii__Product2Add__c prodRefObj2 = [SELECT Id, gii__Service__c, gii__ProductReference__c FROM gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL2.Id];
          prodRefObj2.gii__Service__c = true;
          update prodRefObj2;
          
         list<gii__Product2Add__c> listProdRef = new list<gii__Product2Add__c>();
          listProdRef.add(prodRefObj);
          listProdRef.add(prodRefObj2);
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);    
          Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj2);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation(prodRefObj);
          Giic_UtilityClass_Test.purchaseOrderLineCreationOneQty(prodRefObj2);
          system.debug('isPRef2Service: '+ prodRefObj2.gii__Service__c);
        Test.startTest();
        WorkOrder workOrder = XC_DF_WorkOrder.createWorkOrders(1,'Delivery')[0];
        insert workOrder;
          //Test.startTest();
        gii__SalesOrder__c salesOrder = Giic_DF_Glovia.createSalesOrder();
        salesOrder.gii__Status__c = 'Shipped';
        salesOrder.giic_IsDelivery__c = true;
        salesOrder.giic_WorkOrder__c = workOrder.Id; 
        insert salesOrder;
        List<gii__PurchaseOrderLine__c> pOline = [SELECT Id, gii__Service__c FROM gii__PurchaseOrderLine__c where gii__Product__c IN: listProdRef];
        List<String> purchaseOrderLineIds = new  List<String>();
        Map<String, String>  mapPolIdToQuantity = new  Map<String, String>();
             Map<String, List<String>> mapPolToSerialList = new  Map<String, List<String>> ();
            Map<String, String>  mapReceivedPolId = new Map<String, String> (); 
          Map<String,map<String,Integer>> idPOLToLotMap = new Map<String,map<String,Integer>>(); 
            for (gii__PurchaseOrderLine__c pol : pOline){
                purchaseOrderLineIds.add(pol.id);
                mapPolIdToQuantity.put(pol.id ,'1' );
                mapReceivedPolId.put(pol.id ,'1' );
                system.debug('Service: '+ pol.gii__service__c);
            }
          
            Map<String, Object> jsonMap = new Map<String, Object>();
            jsonMap.put('deliveryDate', date.today());
            jsonMap.put('deliveryDoc', 'DELIVERYDATE');
            jsonMap.put('receiptDate', date.today());
            jsonMap.put('arrivalMaterial', date.today());

            String options = JSON.serialize(jsonMap);
            //Giic_UtilityClass_Test.objPO.giic_TargetSystem__c = System.Label.giic_TargetSystemGlovia;
         Giic_UtilityClass_Test.objPO.gii__DropShip__c = true;
         Giic_UtilityClass_Test.objPO.gii__SalesOrder__c = salesOrder.id;
                    
        	update Giic_UtilityClass_Test.objPO;

 
            Giic_LCC002_ProcessDropShip.createPOReceiptandLine(Giic_UtilityClass_Test.objPO.id , purchaseOrderLineIds, options, mapPolIdToQuantity, mapPolToSerialList,idPOLToLotMap);

           
            Test.stopTest();    
         
     }
    
    
    
    
      @isTest static void createPOReceiptandLineLottized(){
        giic_enable_NR2246__c  CS = new giic_enable_NR2246__c ();
	    	CS.Name='1';
	    	CS.giic_isActive__c = true;
	    	CS.giic_endMonth__c = 1;
	    	CS.giic_startMonth__c = 1;
        CS.LegalEntity__c = 'EnelSole';
		    insert CS;
          
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        prodRefObj.gii__LotControlled__c = true;
        update prodRefObj;
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);    
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation(prodRefObj);
        WorkOrder workOrder = XC_DF_WorkOrder.createWorkOrders(1,'Delivery')[0];
        insert workOrder;
        gii__SalesOrder__c salesOrder = Giic_DF_Glovia.createSalesOrder();
        salesOrder.gii__Status__c = 'Shipped';
        salesOrder.giic_IsDelivery__c = true;
        salesOrder.giic_WorkOrder__c = workOrder.Id; 
        insert salesOrder;
        List<gii__PurchaseOrderLine__c> pOline = [SELECT Id FROM gii__PurchaseOrderLine__c ];
        List<String> purchaseOrderLineIds = new  List<String>();
        Map<String, String>  mapPolIdToQuantity = new  Map<String, String>();
        Map<String, Integer>  mapPolIdToNumber = new  Map<String, Integer>();
        Map<String, List<String>> mapPolToSerialList = new  Map<String, List<String>> ();
        Map<String,map<String,Integer>> idPOLToLotMap = new Map<String,map<String,Integer>>(); 
          
            Map<String, String>  mapReceivedPolId = new Map<String, String> (); 
            for (gii__PurchaseOrderLine__c pol : pOline){
                purchaseOrderLineIds.add(pol.id);
                mapPolIdToQuantity.put(pol.id ,'1' );
                mapReceivedPolId.put(pol.id ,'1' );
                mapPolIdToNumber.put(pol.id , 1);
                idPOLToLotMap.put(pol.Id,mapPolIdToNumber);
            }
          
            Map<String, Object> jsonMap = new Map<String, Object>();
            jsonMap.put('deliveryDate', date.today());
            jsonMap.put('deliveryDoc', 'DELIVERYDATE');
            jsonMap.put('receiptDate', date.today());           
            jsonMap.put('qualityNoteRequire', 'qualityNoteRequire');
            jsonMap.put('qualityNote', 'qualityNote');
            jsonMap.put('arrivalMaterial', date.today());
            jsonMap.put('qualityCheckFail', 'qualityCheckFail');
          
            
            String options = JSON.serialize(jsonMap);
            //Giic_UtilityClass_Test.objPO.giic_TargetSystem__c = System.Label.giic_TargetSystemGlovia;
         Giic_UtilityClass_Test.objPO.gii__DropShip__c = true;
         Giic_UtilityClass_Test.objPO.gii__SalesOrder__c = salesOrder.id;
          Giic_UtilityClass_Test.objPO.giic_LegalEntity__c = 'EnelSole';
            Test.startTest();
        	update Giic_UtilityClass_Test.objPO;
        	Giic_LCC002_ProcessDropShip.createPOReceiptandLine(Giic_UtilityClass_Test.objPO.id , purchaseOrderLineIds, options, mapPolIdToQuantity, mapPolToSerialList,idPOLToLotMap);
     		
           
            Test.stopTest();    
         
     }
    
      
}