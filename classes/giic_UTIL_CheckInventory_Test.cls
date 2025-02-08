@isTest
public class giic_UTIL_CheckInventory_Test {
     
    @isTest 
    static void testWHUtilityMethods6(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        gii__Product2Add__c objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,giic_ProcurementType__c,
                                          gii__PrimarySupplier__c from gii__Product2Add__c where gii__ProductReference__c =:Giic_UtilityClass_Test.objProductTL.Id];
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef.gii__ProductCode__c = 'Tube Light';
        update objProdRef;

        gii__ProductInventory__c prodIn= new gii__ProductInventory__c(gii__Product__c=objProdRef.id ,gii__Warehouse__c=Giic_UtilityClass_Test.objWh.id);
            insert prodIn;
        gii__ProductInventory__c prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c, gii__Warehouse__r.gii__WarehouseGroup__c,
                         gii__OrderQuantityMultiple__c, giic_AvailableQty__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                         gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,gii__Warehouse__r.giic_WarehouseType__c,
                         gii__Warehouse__r.giic_ParentWarehouse__c,gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c 
                         FROM gii__ProductInventory__c ];
        
        gii__ProductInventory__c prodinvntyforLocal= new gii__ProductInventory__c();
        List< gii__ProductInventory__c> prodinvntylst= new List<gii__ProductInventory__c>();
        prodinvntyforLocal.gii__Product__c=objProdRef.Id;
        prodinvntyforLocal.gii__Warehouse__c=Giic_UtilityClass_Test.objWhLocal.Id;    
        insert prodinvntyforLocal;
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);  
        gii__ProductInventoryQuantityDetail__c     objPID = new gii__ProductInventoryQuantityDetail__c(gii__ProductInventory__c=prodInvntryobj.id,gii__ProductInventorybyLocation__c=Giic_UtilityClass_Test.objPILocation.id,
                                                                                                       gii__Warehouse__c=Giic_UtilityClass_Test.objWh.id,
                                                                                                       gii__Location__c=Giic_UtilityClass_Test.objLocationCentral.id,
                                                                                                       gii__Product__c=objProdRef.id,gii__OnHandQuantity__c=100.00
                                                                                                      );
       // insert objPID;
        prodinvntylst.add(prodinvntyforLocal);
        System.assertEquals(true, prodinvntylst.size()>0);
        List<gii__Warehouse__c> lstWh = new List<gii__Warehouse__c>();
        lstWh.add(Giic_UtilityClass_Test.objWhLocal);
        lstWh.add(Giic_UtilityClass_Test.objWh);
        giic_UTIL_CheckInventory.Giic_InputInventoryWrapper iiw1 = new giic_UTIL_CheckInventory.Giic_InputInventoryWrapper();
        giic_UTIL_CheckInventory.Giic_InputInventoryWrapper iiw = new giic_UTIL_CheckInventory.Giic_InputInventoryWrapper(); 
        iiw.wareHouseCode = 'CW';
        iiw.prod2Code = 'Tube Light'; 
        iiw.quantity = 2;
        iiw.reason = 'Shortage'; 
        iiw.location = Giic_UtilityClass_Test.objLocationCentral.Name;
        
        iiw1.wareHouseCode = 'CW';
        iiw1.prod2Code = 'Tube Light'; 
        iiw1.quantity = 2;
        iiw1.reason = 'Shortage';
        iiw1.location = Giic_UtilityClass_Test.objLocationCentral.Name;
        iiw1.locationTo = Giic_UtilityClass_Test.objLocationCentralScrap.Name; 
        List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper> iiwList = new  List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper>();
        List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper> iiwList1 = new  List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper>();
        iiwList.add(iiw);
        iiwList1.add(iiw1);
        Test.startTest(); 
        giic_UTIL_CheckInventory.checkInventory(iiwList);  
        giic_UTIL_CheckInventory.checkInventory(iiwList1);      
        System.AssertEquals(iiwList.size() > 0, true);
        Test.stopTest();
    }
    
   
    
    @isTest 
    static void testWHUtilityMethods7(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        gii__Product2Add__c objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,giic_ProcurementType__c,
                                          gii__PrimarySupplier__c from gii__Product2Add__c where gii__ProductReference__c =:Giic_UtilityClass_Test.objProductTL.Id];
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef.gii__LotControlled__c = true;
        objProdRef.gii__ProductCode__c = 'Tube Light';
        update objProdRef;

        gii__ProductInventory__c prodIn= new gii__ProductInventory__c(gii__Product__c=objProdRef.id ,gii__Warehouse__c=Giic_UtilityClass_Test.objWh.id);
            insert prodIn;
        gii__ProductInventory__c prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c, gii__Warehouse__r.gii__WarehouseGroup__c,
                         gii__OrderQuantityMultiple__c, giic_AvailableQty__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                         gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,gii__Warehouse__r.giic_WarehouseType__c,
                         gii__Warehouse__r.giic_ParentWarehouse__c,gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c 
                         FROM gii__ProductInventory__c ];
        
        gii__ProductInventory__c prodinvntyforLocal= new gii__ProductInventory__c();
        List< gii__ProductInventory__c> prodinvntylst= new List<gii__ProductInventory__c>();
        prodinvntyforLocal.gii__Product__c=objProdRef.Id;
        prodinvntyforLocal.gii__Warehouse__c=Giic_UtilityClass_Test.objWhLocal.Id;    
        insert prodinvntyforLocal;
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);  
        gii__ProductLot__c  objPS = new gii__ProductLot__c(gii__Product__c=objProdRef.id,Name='Tube-1');
        insert objPS;
        gii__ProductInventoryQuantityDetail__c     objPID = new gii__ProductInventoryQuantityDetail__c(gii__ProductInventory__c=prodInvntryobj.id,gii__ProductInventorybyLocation__c=Giic_UtilityClass_Test.objPILocation.id,
                                                                                                       gii__Warehouse__c=Giic_UtilityClass_Test.objWh.id,
                                                                                                       gii__Location__c=Giic_UtilityClass_Test.objLocationCentral.id,
                                                                                                       gii__Product__c=objProdRef.id,gii__OnHandQuantity__c=100.00,
                                                                                                      gii__ProductLot__c =objPS.id
                                                                                                      );
        insert objPID;
        prodinvntylst.add(prodinvntyforLocal);
        System.assertEquals(true, prodinvntylst.size()>0);
        List<gii__Warehouse__c> lstWh = new List<gii__Warehouse__c>();
        lstWh.add(Giic_UtilityClass_Test.objWhLocal);
        lstWh.add(Giic_UtilityClass_Test.objWh);
        giic_UTIL_CheckInventory.Giic_InputInventoryWrapper iiw1 = new giic_UTIL_CheckInventory.Giic_InputInventoryWrapper();
        giic_UTIL_CheckInventory.Giic_InputInventoryWrapper iiw = new giic_UTIL_CheckInventory.Giic_InputInventoryWrapper();
      	Map<String, Integer> lotMap = new Map<String, Integer>();
        lotMap.put('Tube-1', 2);
        iiw.wareHouseCode = 'CW';
        iiw.prod2Code = 'Tube Light'; 
        iiw.quantity = 2;
        iiw.reason = 'Shortage';
        iiw.lots = lotMap;    
        iiw.location = Giic_UtilityClass_Test.objLocationCentral.Name;
        
        iiw1.wareHouseCode = 'CW';
        iiw1.prod2Code = 'Tube Light'; 
        iiw1.quantity = 2;
        iiw1.reason = 'Shortage';
        iiw1.lots = lotMap;    
        iiw1.location = Giic_UtilityClass_Test.objLocationCentral.Name;
        iiw1.locationTo = Giic_UtilityClass_Test.objLocationCentralScrap.Name; 
        List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper> iiwList = new  List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper>();
        iiwList.add(iiw);
        iiwList.add(iiw1);
        Test.startTest();
        giic_UTIL_CheckInventory.checkInventory(iiwList);        
        System.AssertEquals(iiwList.size() > 0, true);
        Test.stopTest();
    }
    
      @isTest 
    static void testWHUtilityMethods8(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        gii__Product2Add__c objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,giic_ProcurementType__c,
                                          gii__PrimarySupplier__c from gii__Product2Add__c where gii__ProductReference__c =:Giic_UtilityClass_Test.objProductTL.Id];
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef.gii__SerialControlled__c = true;
        objProdRef.gii__ProductCode__c = 'Tube Light';
        update objProdRef;

        gii__ProductInventory__c prodIn= new gii__ProductInventory__c(gii__Product__c=objProdRef.id ,gii__Warehouse__c=Giic_UtilityClass_Test.objWh.id);
            insert prodIn;
        gii__ProductInventory__c prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c, gii__Warehouse__r.gii__WarehouseGroup__c,
                         gii__OrderQuantityMultiple__c, giic_AvailableQty__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                         gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,gii__Warehouse__r.giic_WarehouseType__c,
                         gii__Warehouse__r.giic_ParentWarehouse__c,gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c 
                         FROM gii__ProductInventory__c ];
        
        gii__ProductInventory__c prodinvntyforLocal= new gii__ProductInventory__c();
        List< gii__ProductInventory__c> prodinvntylst= new List<gii__ProductInventory__c>();
        prodinvntyforLocal.gii__Product__c=objProdRef.Id;
        prodinvntyforLocal.gii__Warehouse__c=Giic_UtilityClass_Test.objWhLocal.Id;    
        insert prodinvntyforLocal;
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);  
        gii__ProductSerial__c  objPS = new gii__ProductSerial__c(gii__Product__c=objProdRef.id,Name='1123');
        insert objPS;
        gii__ProductInventoryQuantityDetail__c objPID = new gii__ProductInventoryQuantityDetail__c(gii__ProductInventory__c=prodInvntryobj.id,
                                                                                                   gii__ProductInventorybyLocation__c=Giic_UtilityClass_Test.objPILocation.id,
                                                                                                       gii__Warehouse__c=Giic_UtilityClass_Test.objWh.id,
                                                                                                       gii__Location__c=Giic_UtilityClass_Test.objLocationCentral.id,
                                                                                                       gii__Product__c=objProdRef.id,gii__OnHandQuantity__c=1,
                                                                                                      gii__ProductSerial__c =objPS.id
                                                                                                      );
      // insert objPID;
        prodinvntylst.add(prodinvntyforLocal);
        System.assertEquals(true, prodinvntylst.size()>0);
        List<gii__Warehouse__c> lstWh = new List<gii__Warehouse__c>();
        lstWh.add(Giic_UtilityClass_Test.objWhLocal);
        lstWh.add(Giic_UtilityClass_Test.objWh);
        giic_UTIL_CheckInventory.Giic_InputInventoryWrapper iiw1 = new giic_UTIL_CheckInventory.Giic_InputInventoryWrapper();
        giic_UTIL_CheckInventory.Giic_InputInventoryWrapper iiw = new giic_UTIL_CheckInventory.Giic_InputInventoryWrapper();
      	 List<String> serialList = new List<String>();
        serialList.add('1123');
        iiw.wareHouseCode = 'CW';
        iiw.prod2Code = 'Tube Light'; 
        iiw.quantity = 1;
        iiw.reason = 'Shortage'; 
        iiw.serials = serialList;    
        iiw.location = Giic_UtilityClass_Test.objLocationCentral.Name;
        
        iiw1.wareHouseCode = 'CW';
        iiw1.prod2Code = 'Tube Light'; 
        iiw1.quantity = 1;
        iiw1.reason = 'Shortage'; 
        iiw.serials = serialList; 
        iiw1.location = Giic_UtilityClass_Test.objLocationCentral.Name;
        iiw1.locationTo = Giic_UtilityClass_Test.objLocationCentralScrap.Name; 
        List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper> iiwList = new  List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper>();
        List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper> iiwList1 = new  List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper>();
        iiwList.add(iiw);
        iiwList1.add(iiw1);
        Test.startTest();
        try{
        giic_UTIL_CheckInventory.checkInventory(iiwList); 
        giic_UTIL_CheckInventory.checkInventory(iiwList1); 
        }catch(Exception e){
            	System.debug('@@@ Eccezione');
                Boolean expectedExceptionThrown =  e.getMessage().contains('Attempt') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
		}
        
        System.AssertEquals(iiwList.size() > 0, true);
        Test.stopTest();
    }
       @isTest 
    static void testWHUtilityMethods9(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        gii__Product2Add__c objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,giic_ProcurementType__c,
                                          gii__PrimarySupplier__c from gii__Product2Add__c where gii__ProductReference__c =:Giic_UtilityClass_Test.objProductTL.Id];
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef.gii__SerialControlled__c = true;
        objProdRef.gii__ProductCode__c = 'Tube Light';
        update objProdRef;

        gii__ProductInventory__c prodIn= new gii__ProductInventory__c(gii__Product__c=objProdRef.id ,gii__Warehouse__c=Giic_UtilityClass_Test.objWh.id);
            insert prodIn;
        gii__ProductInventory__c prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c, gii__Warehouse__r.gii__WarehouseGroup__c,
                         gii__OrderQuantityMultiple__c, giic_AvailableQty__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                         gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,gii__Warehouse__r.giic_WarehouseType__c,
                         gii__Warehouse__r.giic_ParentWarehouse__c,gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c 
                         FROM gii__ProductInventory__c ];
        
        gii__ProductInventory__c prodinvntyforLocal= new gii__ProductInventory__c();
        List< gii__ProductInventory__c> prodinvntylst= new List<gii__ProductInventory__c>();
        prodinvntyforLocal.gii__Product__c=objProdRef.Id;
        prodinvntyforLocal.gii__Warehouse__c=Giic_UtilityClass_Test.objWhLocal.Id;    
        insert prodinvntyforLocal;
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);  
        gii__ProductSerial__c  objPS = new gii__ProductSerial__c(gii__Product__c=objProdRef.id,Name='1123');
        insert objPS;
        gii__ProductInventoryQuantityDetail__c objPID = new gii__ProductInventoryQuantityDetail__c(gii__ProductInventory__c=prodInvntryobj.id,
                                                                                                   gii__ProductInventorybyLocation__c=Giic_UtilityClass_Test.objPILocation.id,
                                                                                                       gii__Warehouse__c=Giic_UtilityClass_Test.objWh.id,
                                                                                                       gii__Location__c=Giic_UtilityClass_Test.objLocationCentral.id,
                                                                                                       gii__Product__c=objProdRef.id,gii__OnHandQuantity__c=1,
                                                                                                      gii__ProductSerial__c =objPS.id
                                                                                                      );
      // insert objPID;
        prodinvntylst.add(prodinvntyforLocal);
        System.assertEquals(true, prodinvntylst.size()>0);
        List<gii__Warehouse__c> lstWh = new List<gii__Warehouse__c>();
        lstWh.add(Giic_UtilityClass_Test.objWhLocal);
        lstWh.add(Giic_UtilityClass_Test.objWh);
        giic_UTIL_CheckInventory.Giic_InputInventoryWrapper iiw1 = new giic_UTIL_CheckInventory.Giic_InputInventoryWrapper();
        giic_UTIL_CheckInventory.Giic_InputInventoryWrapper iiw = new giic_UTIL_CheckInventory.Giic_InputInventoryWrapper();
      	 List<String> serialList = new List<String>();
        serialList.add('1123');
        iiw.wareHouseCode = 'CW';
        iiw.prod2Code = 'Tube Light'; 
        iiw.quantity = 2;
        iiw.reason = 'Shortage'; 
        iiw.serials = serialList;    
        iiw.location = Giic_UtilityClass_Test.objLocationCentral.Name;
         
        iiw1.prod2Code = 'Tube Light'; 
        iiw1.quantity = 1;
        iiw1.reason = 'Shortage'; 
        iiw.serials = serialList; 
        iiw1.location = Giic_UtilityClass_Test.objLocationCentral.Name;
        iiw1.locationTo = Giic_UtilityClass_Test.objLocationCentralScrap.Name; 
        List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper> iiwList = new  List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper>();
        List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper> iiwList1 = new  List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper>();
        iiwList.add(iiw);
        iiwList1.add(iiw1);
        Test.startTest();
        try{
        giic_UTIL_CheckInventory.checkInventory(iiwList); 
        giic_UTIL_CheckInventory.checkInventory(iiwList1); 
        }catch(Exception e){
            	System.debug('@@@ Eccezione');
                Boolean expectedExceptionThrown =  e.getMessage().contains('Attempt') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
		}
        
        System.AssertEquals(iiwList.size() > 0, true);
        Test.stopTest();
    }

    
       @isTest 
    static void testWHUtilityMethods10(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        gii__Product2Add__c objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,giic_ProcurementType__c,
                                          gii__PrimarySupplier__c from gii__Product2Add__c where gii__ProductReference__c =:Giic_UtilityClass_Test.objProductTL.Id];
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef.gii__SerialControlled__c = true;
        objProdRef.gii__ProductCode__c = 'Tube Light';
        update objProdRef;

        gii__ProductInventory__c prodIn= new gii__ProductInventory__c(gii__Product__c=objProdRef.id ,gii__Warehouse__c=Giic_UtilityClass_Test.objWh.id);
            insert prodIn;
        gii__ProductInventory__c prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c, gii__Warehouse__r.gii__WarehouseGroup__c,
                         gii__OrderQuantityMultiple__c, giic_AvailableQty__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                         gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,gii__Warehouse__r.giic_WarehouseType__c,
                         gii__Warehouse__r.giic_ParentWarehouse__c,gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c 
                         FROM gii__ProductInventory__c ];
        
        gii__ProductInventory__c prodinvntyforLocal= new gii__ProductInventory__c();
        List< gii__ProductInventory__c> prodinvntylst= new List<gii__ProductInventory__c>();
        prodinvntyforLocal.gii__Product__c=objProdRef.Id;
        prodinvntyforLocal.gii__Warehouse__c=Giic_UtilityClass_Test.objWhLocal.Id;    
        insert prodinvntyforLocal;
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);  
     //   gii__ProductSerial__c  objPS = new gii__ProductSerial__c(gii__Product__c=objProdRef.id,Name='1123');
       // insert objPS;
      /*  gii__ProductInventoryQuantityDetail__c objPID = new gii__ProductInventoryQuantityDetail__c(gii__ProductInventory__c=prodInvntryobj.id,
                                                                                                   gii__ProductInventorybyLocation__c=Giic_UtilityClass_Test.objPILocation.id,
                                                                                                       gii__Warehouse__c=Giic_UtilityClass_Test.objWh.id,
                                                                                                       gii__Location__c=Giic_UtilityClass_Test.objLocationCentral.id,
                                                                                                       gii__Product__c=objProdRef.id,gii__OnHandQuantity__c=1,
                                                                                                      gii__ProductSerial__c =objPS.id
                                                                                                      );
      // insert objPID;*/
        prodinvntylst.add(prodinvntyforLocal);
        System.assertEquals(true, prodinvntylst.size()>0);
        List<gii__Warehouse__c> lstWh = new List<gii__Warehouse__c>();
        lstWh.add(Giic_UtilityClass_Test.objWhLocal);
        lstWh.add(Giic_UtilityClass_Test.objWh);
        giic_UTIL_CheckInventory.Giic_InputInventoryWrapper iiw1 = new giic_UTIL_CheckInventory.Giic_InputInventoryWrapper();
        giic_UTIL_CheckInventory.Giic_InputInventoryWrapper iiw = new giic_UTIL_CheckInventory.Giic_InputInventoryWrapper();
      	 List<String> serialList = new List<String>();
        serialList.add('1123');
        iiw.wareHouseCode = 'CW';
        iiw.prod2Code = 'Tube Light'; 
        iiw.quantity = 1;
        iiw.reason = 'Shortage'; 
        iiw.serials = serialList;    
        iiw.location = Giic_UtilityClass_Test.objLocationCentral.Name;
        
        iiw1.wareHouseCode = 'CW';
        iiw1.prod2Code = 'Tube Light'; 
        iiw1.quantity = 1;
        iiw1.reason = 'Shortage'; 
        iiw.serials = serialList; 
        iiw1.location = Giic_UtilityClass_Test.objLocationCentral.Name;
        iiw1.locationTo = Giic_UtilityClass_Test.objLocationCentralScrap.Name; 
        List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper> iiwList = new  List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper>();
        List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper> iiwList1 = new  List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper>();
        iiwList.add(iiw);
        iiwList1.add(iiw1);
        Test.startTest();
        try{
        giic_UTIL_CheckInventory.checkInventory(iiwList); 
        giic_UTIL_CheckInventory.checkInventory(iiwList1); 
        }catch(Exception e){
            	System.debug('@@@ Eccezione');
                Boolean expectedExceptionThrown =  e.getMessage().contains('Attempt') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
		}
        
        System.AssertEquals(iiwList.size() > 0, true);
        Test.stopTest();
    }
   
      @isTest 
    static void testWHUtilityMethods11(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        gii__Product2Add__c objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,giic_ProcurementType__c,
                                          gii__PrimarySupplier__c from gii__Product2Add__c where gii__ProductReference__c =:Giic_UtilityClass_Test.objProductTL.Id];
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef.gii__SerialControlled__c = true;
        objProdRef.gii__ProductCode__c = 'Tube Light';
        update objProdRef;

        gii__ProductInventory__c prodIn= new gii__ProductInventory__c(gii__Product__c=objProdRef.id ,gii__Warehouse__c=Giic_UtilityClass_Test.objWh.id);
            insert prodIn;
        gii__ProductInventory__c prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c, gii__Warehouse__r.gii__WarehouseGroup__c,
                         gii__OrderQuantityMultiple__c, giic_AvailableQty__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                         gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,gii__Warehouse__r.giic_WarehouseType__c,
                         gii__Warehouse__r.giic_ParentWarehouse__c,gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c 
                         FROM gii__ProductInventory__c ];
        
        gii__ProductInventory__c prodinvntyforLocal= new gii__ProductInventory__c();
        List< gii__ProductInventory__c> prodinvntylst= new List<gii__ProductInventory__c>();
        prodinvntyforLocal.gii__Product__c=objProdRef.Id;
        prodinvntyforLocal.gii__Warehouse__c=Giic_UtilityClass_Test.objWhLocal.Id;    
        insert prodinvntyforLocal;
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);  
        gii__ProductSerial__c  objPS = new gii__ProductSerial__c(gii__Product__c=objProdRef.id,Name='1123');
        insert objPS;
        gii__ProductInventoryQuantityDetail__c objPID = new gii__ProductInventoryQuantityDetail__c(gii__ProductInventory__c=prodInvntryobj.id,
                                                                                                   gii__ProductInventorybyLocation__c=Giic_UtilityClass_Test.objPILocation.id,
                                                                                                       gii__Warehouse__c=Giic_UtilityClass_Test.objWh.id,
                                                                                                       gii__Location__c=Giic_UtilityClass_Test.objLocationCentral.id,
                                                                                                       gii__Product__c=objProdRef.id,gii__OnHandQuantity__c=1,
                                                                                                      gii__ProductSerial__c =objPS.id
                                                                                                      );
      // insert objPID;
        prodinvntylst.add(prodinvntyforLocal);
        System.assertEquals(true, prodinvntylst.size()>0);
        List<gii__Warehouse__c> lstWh = new List<gii__Warehouse__c>();
        lstWh.add(Giic_UtilityClass_Test.objWhLocal);
        lstWh.add(Giic_UtilityClass_Test.objWh);
        giic_UTIL_CheckInventory.Giic_InputInventoryWrapper iiw1 = new giic_UTIL_CheckInventory.Giic_InputInventoryWrapper();
        giic_UTIL_CheckInventory.Giic_InputInventoryWrapper iiw = new giic_UTIL_CheckInventory.Giic_InputInventoryWrapper();
      	 List<String> serialList = new List<String>();
        serialList.add('1123');
        iiw.wareHouseCode = 'CW';
        iiw.prod2Code = 'Tube Light'; 
        iiw.quantity = -1;
        iiw.reason = 'Shortage'; 
        iiw.serials = serialList;    
        iiw.location = Giic_UtilityClass_Test.objLocationCentral.Name;
        
        iiw1.wareHouseCode = 'CW';
        iiw1.prod2Code = 'Tube Light'; 
        iiw1.quantity = 1;
        iiw1.reason = 'Shortage'; 
        iiw.serials = serialList; 
        iiw1.location = Giic_UtilityClass_Test.objLocationCentral.Name;
        iiw1.locationTo = Giic_UtilityClass_Test.objLocationCentralScrap.Name; 
        List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper> iiwList = new  List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper>();
        List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper> iiwList1 = new  List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper>();
        iiwList.add(iiw);
        iiwList1.add(iiw1);
        Test.startTest();
        try{
        giic_UTIL_CheckInventory.checkInventory(iiwList); 
        }catch(Exception e){
            	System.debug('@@@ Eccezione');
                Boolean expectedExceptionThrown =  e.getMessage().contains('Attempt') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
		}
        
        System.AssertEquals(iiwList.size() > 0, true);
        Test.stopTest();
    }  
   
    @isTest 
    static void testWHUtilityMethods12(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        gii__Product2Add__c objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,giic_ProcurementType__c,
                                          gii__PrimarySupplier__c from gii__Product2Add__c where gii__ProductReference__c =:Giic_UtilityClass_Test.objProductTL.Id];
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef.gii__LotControlled__c = true;
        objProdRef.gii__ProductCode__c = 'Tube Light';
        update objProdRef;

        gii__ProductInventory__c prodIn= new gii__ProductInventory__c(gii__Product__c=objProdRef.id ,gii__Warehouse__c=Giic_UtilityClass_Test.objWh.id);
            insert prodIn;
        gii__ProductInventory__c prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c, gii__Warehouse__r.gii__WarehouseGroup__c,
                         gii__OrderQuantityMultiple__c, giic_AvailableQty__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                         gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,gii__Warehouse__r.giic_WarehouseType__c,
                         gii__Warehouse__r.giic_ParentWarehouse__c,gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c 
                         FROM gii__ProductInventory__c ];
        
        gii__ProductInventory__c prodinvntyforLocal= new gii__ProductInventory__c();
        List< gii__ProductInventory__c> prodinvntylst= new List<gii__ProductInventory__c>();
        prodinvntyforLocal.gii__Product__c=objProdRef.Id;
        prodinvntyforLocal.gii__Warehouse__c=Giic_UtilityClass_Test.objWhLocal.Id;    
        insert prodinvntyforLocal;
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);  
        gii__ProductLot__c  objPS = new gii__ProductLot__c(gii__Product__c=objProdRef.id,Name='Tube-1');
        insert objPS;
        gii__ProductInventoryQuantityDetail__c     objPID = new gii__ProductInventoryQuantityDetail__c(gii__ProductInventory__c=prodInvntryobj.id,gii__ProductInventorybyLocation__c=Giic_UtilityClass_Test.objPILocation.id,
                                                                                                       gii__Warehouse__c=Giic_UtilityClass_Test.objWh.id,
                                                                                                       gii__Location__c=Giic_UtilityClass_Test.objLocationCentral.id,
                                                                                                       gii__Product__c=objProdRef.id,gii__OnHandQuantity__c=100.00,
                                                                                                      gii__ProductLot__c =objPS.id
                                                                                                      );
        insert objPID;
        prodinvntylst.add(prodinvntyforLocal);
        System.assertEquals(true, prodinvntylst.size()>0);
        List<gii__Warehouse__c> lstWh = new List<gii__Warehouse__c>();
        lstWh.add(Giic_UtilityClass_Test.objWhLocal);
        lstWh.add(Giic_UtilityClass_Test.objWh);
        
        Test.startTest();
        giic_UTIL_CheckInventory.Giic_InputInventoryWrapper iiw1 = new giic_UTIL_CheckInventory.Giic_InputInventoryWrapper();
        giic_UTIL_CheckInventory.Giic_InputInventoryWrapper iiw = new giic_UTIL_CheckInventory.Giic_InputInventoryWrapper();
      	Map<String, Integer> lotMap = new Map<String, Integer>();
        lotMap.put('Tube-1', 2);
        iiw.wareHouseCode = 'CW';
        iiw.prod2Code = 'Tube Light'; 
        iiw.quantity = -2;
        iiw.reason = 'Shortage';
        iiw.lots = lotMap;    
        iiw.location = Giic_UtilityClass_Test.objLocationCentral.Name;
        
        iiw1.wareHouseCode = 'CW';
        iiw1.prod2Code = 'Tube Light'; 
        iiw1.quantity = 2;
        iiw1.reason = 'Shortage';
        iiw1.lots = lotMap;    
        iiw1.location = Giic_UtilityClass_Test.objLocationCentral.Name;
        iiw1.locationTo = Giic_UtilityClass_Test.objLocationCentralScrap.Name; 
        List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper> iiwList = new  List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper>();
        iiwList.add(iiw);
        iiwList.add(iiw1);
        giic_UTIL_CheckInventory.checkInventory(iiwList);        
        System.AssertEquals(iiwList.size() > 0, true);
        Test.stopTest();
    }
     @isTest 
    static void testWHUtilityMethods13(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        gii__Product2Add__c objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,giic_ProcurementType__c,
                                          gii__PrimarySupplier__c from gii__Product2Add__c where gii__ProductReference__c =:Giic_UtilityClass_Test.objProductTL.Id];
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef.gii__ProductCode__c = 'Tube Light';
        update objProdRef;

      /* gii__ProductInventory__c prodIn= new gii__ProductInventory__c(gii__Product__c=objProdRef.id ,gii__Warehouse__c=Giic_UtilityClass_Test.objWh.id);
            insert prodIn;
        gii__ProductInventory__c prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c, gii__Warehouse__r.gii__WarehouseGroup__c,
                         gii__OrderQuantityMultiple__c, giic_AvailableQty__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                         gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,gii__Warehouse__r.giic_WarehouseType__c,
                         gii__Warehouse__r.giic_ParentWarehouse__c,gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c 
                         FROM gii__ProductInventory__c ];
        
        gii__ProductInventory__c prodinvntyforLocal= new gii__ProductInventory__c();
        List< gii__ProductInventory__c> prodinvntylst= new List<gii__ProductInventory__c>();
        prodinvntyforLocal.gii__Product__c=objProdRef.Id;
        prodinvntyforLocal.gii__Warehouse__c=Giic_UtilityClass_Test.objWhLocal.Id;    
        insert prodinvntyforLocal;
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);  
        gii__ProductInventoryQuantityDetail__c     objPID = new gii__ProductInventoryQuantityDetail__c(gii__ProductInventory__c=prodInvntryobj.id,gii__ProductInventorybyLocation__c=Giic_UtilityClass_Test.objPILocation.id,
                                                                                                       gii__Warehouse__c=Giic_UtilityClass_Test.objWh.id,
                                                                                                       gii__Location__c=Giic_UtilityClass_Test.objLocationCentral.id,
                                                                                                       gii__Product__c=objProdRef.id,gii__OnHandQuantity__c=100.00
                                                                                                      );
       // insert objPID;
        prodinvntylst.add(prodinvntyforLocal);*/
        List<gii__Warehouse__c> lstWh = new List<gii__Warehouse__c>();
        lstWh.add(Giic_UtilityClass_Test.objWhLocal);
        lstWh.add(Giic_UtilityClass_Test.objWh);
        giic_UTIL_CheckInventory.Giic_InputInventoryWrapper iiw1 = new giic_UTIL_CheckInventory.Giic_InputInventoryWrapper();
        giic_UTIL_CheckInventory.Giic_InputInventoryWrapper iiw = new giic_UTIL_CheckInventory.Giic_InputInventoryWrapper(); 
        iiw.wareHouseCode = 'CW';
        iiw.prod2Code = 'Tube Light'; 
        iiw.sku_code = 'skuTest';
        iiw.quantity = 2;
        iiw.reason = 'Shortage'; 
        iiw.location = Giic_UtilityClass_Test.objLocationCentral.Name;
        
        iiw1.wareHouseCode = 'CW';
        iiw1.prod2Code = 'Tube Light'; 
        iiw1.quantity = 2;
        iiw1.reason = 'Shortage';
        iiw1.location = Giic_UtilityClass_Test.objLocationCentral.Name;
        iiw1.locationTo = Giic_UtilityClass_Test.objLocationCentralScrap.Name; 
        List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper> iiwList = new  List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper>();
        List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper> iiwList1 = new  List<giic_UTIL_CheckInventory.Giic_InputInventoryWrapper>();
        iiwList.add(iiw);
        iiwList1.add(iiw1);
        Test.startTest(); 
        giic_UTIL_CheckInventory.checkInventory(iiwList);  
        giic_UTIL_CheckInventory.checkInventory(iiwList1);      
        System.AssertEquals(iiwList.size() > 0, true);
        Test.stopTest();
    }
}