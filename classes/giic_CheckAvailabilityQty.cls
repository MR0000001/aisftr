/**
* @author Milko Fatiga milko.fatiga@nttdata.com
* @date Creation 04/05/2021
* @date Modification dd/mm/yyyy 
* @description giic_CheckAvailabilityQty -  class to set check availability QTY on MPR 
*/
public without sharing class giic_CheckAvailabilityQty {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('giic_CheckAvailabilityQty');   
    public static boolean firstRun = true;
    public class Giic_AvailabilityWrapper {
        
        public Id tecnicalProductId;
        public String catalogHeaderName;
        public Id neCatalogItem;
        public gii__ProductInventory__c productInventory;
        public Decimal qtyPI = 0;
        public Decimal qtyEca = 0;
        public String countryWH = '';
        
        
        public Giic_AvailabilityWrapper(){
            System.debug('Giic_AvailabilityWrapper.Giic_AvailabilityWrapper');
        }
    }
    
    
    /**
* @author Milko Fatiga
* @date Creation 04/05/2021
* @description  Method to 
* @param listNew List<gii__ProductInventory__c>
* @param oldMap Map<Id, gii__ProductInventory__c>
* @param newMap Map<Id, gii__ProductInventory__c>
*/
    
    public static void checkAvailability(List<gii__ProductInventory__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In checkAvailability----->>' );
        List<Id> listNewIds = XC_UTIL_Sobject.getIds(listNew);
        map<Id, gii__ProductInventory__c> productInventoryList = new map<Id, gii__ProductInventory__c>([SELECT Id,gii__Product__c,gii__OnHandQuantity__c ,gii__Product__r.gii__ProductReference__c, gii__Warehouse__c,gii__Warehouse__r.giic_ParentWarehouse__c
                                                                                                        FROM gii__ProductInventory__c WHERE Id IN: listNewIds 
                                                                                                        AND  gii__Warehouse__r.giic_WarehouseType__c != 'Virtual']);
        if(productInventoryList.isEmpty()){ return; }
        map<Id,Id> tecnicalProdToPiId = new map<Id,Id>();
        
        List<gii__ProductInventory__c> piCentralW = new List<gii__ProductInventory__c>();
        for(gii__ProductInventory__c pii : productInventoryList.values()){
            if(pii.gii__Warehouse__r.giic_ParentWarehouse__c==null){
                tecnicalProdToPiId.put(pii.gii__Product__r.gii__ProductReference__c, pii.Id);
                piCentralW.add(pii);
            }
        }
        startCheckAvailability(piCentralW,tecnicalProdToPiId);
        
    }
    
    
    
    public static void startCheckAvailability(List<gii__ProductInventory__c> productInventoryList, map<Id,Id> tecnicalProdToPiId){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In startCheckAvailability----->>' );
        Map<Id,B2WExtCat__External_Catalog_Association__c> extCatFromTechToComm = new Map<Id,B2WExtCat__External_Catalog_Association__c>([SELECT Id , XC_TechnicalProduct__c,B2WExtCat__Commercial_Catalog_Item__c FROM B2WExtCat__External_Catalog_Association__c    
                                                                                                                                          WHERE XC_TechnicalProduct__c IN: tecnicalProdToPiId.keySet()]);
        
        System.debug('extCatFromTechToComm = '+extCatFromTechToComm);
        List<B2WExtCat__External_Catalog_Association__c> extCatFromCommToAllTech = [SELECT Id,  Name, XC_TechnicalProduct__c,XC_TechnicalProduct__r.ProductCode,XC_Quantity__c,B2WExtCat__Commercial_Catalog_Item__r.NE__Catalog_Id__r.Name, B2WExtCat__Commercial_Product__r.XC_LIC_Product_Name__c, B2WExtCat__Commercial_Product__c , B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__c, B2WExtCat__Commercial_Catalog_Item__c
                                                                                    FROM B2WExtCat__External_Catalog_Association__c  
                                                                                    WHERE Id IN :extCatFromTechToComm.keySet() ];
        System.debug('extCatFromCommToAllTech = '+extCatFromCommToAllTech);
        Map<Id, String> commercialIdToCatalogHName = new Map<Id, String>(); 
        Map<Id,List<Id>> commToTec = new Map<Id,List<Id>>(); 
        Map<Id,Id> commToNECatalogItem = new Map<Id,Id>(); 
        map<Id,List<B2WExtCat__External_Catalog_Association__c>> product2ToEca = new map<Id,List<B2WExtCat__External_Catalog_Association__c>>();
        
        map<Id,List<B2WExtCat__External_Catalog_Association__c>> product2ToEcaNew = new map<Id,List<B2WExtCat__External_Catalog_Association__c>>();
        
        for(B2WExtCat__External_Catalog_Association__c extCat : extCatFromCommToAllTech) {
            Id prodId = (extCat.B2WExtCat__Commercial_Product__c !=null) ? extCat.B2WExtCat__Commercial_Product__c : extCat.B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__c;
            commercialIdToCatalogHName.put(prodId, extCat.B2WExtCat__Commercial_Catalog_Item__r.NE__Catalog_Id__r.Name);
            if(!commToTec.containsKey(prodId)){  commToTec.put(prodId, new List<Id>()); } 
            commToTec.get(prodId).add(extCat.XC_TechnicalProduct__c); 
            commToNECatalogItem.put(prodId, extCat.B2WExtCat__Commercial_Catalog_Item__c);
            
            if(!product2ToEcaNew.containsKey(extCat.XC_TechnicalProduct__c)){  product2ToEcaNew.put(extCat.XC_TechnicalProduct__c, new List<B2WExtCat__External_Catalog_Association__c>()); } 
            product2ToEcaNew.get(extCat.XC_TechnicalProduct__c).add(extCat);             
        }
        List<Id> allTotalTecProd = new List<Id>();
        map<Id,List<B2WExtCat__External_Catalog_Association__c>> neCatalogItemToEca = new map<Id,List<B2WExtCat__External_Catalog_Association__c>>();
        map<Id,B2WExtCat__External_Catalog_Association__c> allPossibleBrothers = new map<Id,B2WExtCat__External_Catalog_Association__c>([SELECT Id,  Name, XC_TechnicalProduct__c,XC_TechnicalProduct__r.ProductCode,XC_Quantity__c,B2WExtCat__Commercial_Catalog_Item__r.NE__Catalog_Id__r.Name, B2WExtCat__Commercial_Product__r.XC_LIC_Product_Name__c, B2WExtCat__Commercial_Product__c , B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__c, B2WExtCat__Commercial_Catalog_Item__c
                                                                                                                                         FROM B2WExtCat__External_Catalog_Association__c
                                                                                                                                         WHERE B2WExtCat__Commercial_Catalog_Item__c IN: commToNECatalogItem.values() AND XC_TechnicalProduct__c!=null ]);
        
        for(B2WExtCat__External_Catalog_Association__c eca : allPossibleBrothers.values()){
            allTotalTecProd.add(eca.XC_TechnicalProduct__c);
            if(!neCatalogItemToEca.containsKey(eca.B2WExtCat__Commercial_Catalog_Item__c)){  neCatalogItemToEca.put(eca.B2WExtCat__Commercial_Catalog_Item__c, new List<B2WExtCat__External_Catalog_Association__c>()); } 
            neCatalogItemToEca.get(eca.B2WExtCat__Commercial_Catalog_Item__c).add(eca);
            if(!product2ToEca.containsKey(eca.XC_TechnicalProduct__c)){  product2ToEca.put(eca.XC_TechnicalProduct__c, new List<B2WExtCat__External_Catalog_Association__c>()); } 
            product2ToEca.get(eca.XC_TechnicalProduct__c).add(eca); 
        }

        for(Id commerciale : commToTec.keySet()){
            for(Id tecId : commToTec.get(commerciale)){ 
                allTotalTecProd.add(tecId); 
            }
        }
        system.debug('allTotalTecProd = '+allTotalTecProd);
        
        map<Id, gii__ProductInventory__c> tecAssetToProductInventory = new map<Id, gii__ProductInventory__c>();
        map<Id, gii__ProductInventory__c> productInventories = new map<Id, gii__ProductInventory__c>([SELECT Id,giic_LegalEntity__c,giic_OnHandNew__c,giic_SalesOnHand__c,giic_AvgTransferTime__c,gii__Product__c,gii__Product__r.gii__ProductReference__r.Id,gii__OnHandQuantity__c ,gii__Warehouse__r.giic_WarehouseType__c,gii__Product__r.gii__ProductReference__c,gii__Product__r.giic_ProcurementType__c, gii__Product__r.gii__PrimarySupplier__c,gii__Warehouse__c, gii__Warehouse__r.gii__WareHouseCountry__c,  gii__Warehouse__r.giic_wareHouseCountryPick__c, gii__Warehouse__r.giic_ParentWarehouse__c
                                                                                                      FROM gii__ProductInventory__c WHERE  gii__Product__r.gii__ProductReference__c IN: allTotalTecProd AND gii__Warehouse__r.giic_WarehouseType__c='Central' ]);
        System.debug('All productInventories = '+productInventories);
        for(gii__ProductInventory__c p : productInventories.values()){
            if(p.gii__Product__r!=null){
                tecAssetToProductInventory.put(p.gii__Product__r.gii__ProductReference__c, p);
            }
        }
        
        
        
        map<Id, List<Giic_AvailabilityWrapper>> idCommProductToListWrapper = new map<Id, List<Giic_AvailabilityWrapper> >();
        
        System.debug('commToTec = '+commToTec);
        for(Id commercial : commToTec.keySet()){
            List<Giic_AvailabilityWrapper> awList = new List<Giic_AvailabilityWrapper>();
            for(Id tecId : commToTec.get(commercial)){
                if(tecAssetToProductInventory.containsKey(tecId)){
                    Giic_AvailabilityWrapper aw = new Giic_AvailabilityWrapper();
                    aw.tecnicalProductId = tecId;  
                    aw.productInventory = tecAssetToProductInventory.get(tecId);
                    if(tecAssetToProductInventory.get(tecId).gii__Warehouse__c!=null && tecAssetToProductInventory.get(tecId).gii__Warehouse__r.giic_wareHouseCountryPick__c!=null){
                        aw.countryWH = tecAssetToProductInventory.get(tecId).gii__Warehouse__r.giic_wareHouseCountryPick__c;
                    }
                    aw.catalogHeaderName = commercialIdToCatalogHName.get(commercial);
                    aw.neCatalogItem = commToNECatalogItem.get(commercial);
                    System.debug('neCatalogItem = '+aw.neCatalogItem);
                    
                    
                    aw.qtyPI = tecAssetToProductInventory.get(tecId).giic_SalesOnHand__c;
                    system.debug(' aw.qtyPI = '+ aw.qtyPI);
                    
                    
                    List<B2WExtCat__External_Catalog_Association__c> ListEcaNew = new List<B2WExtCat__External_Catalog_Association__c>();
                    ListEcaNew = product2ToEcaNew.get(tecId);
                    for(B2WExtCat__External_Catalog_Association__c EC : ListEcaNew){
                        if((EC.B2WExtCat__Commercial_Catalog_Item__c == commToNECatalogItem.get(commercial)) || (EC.B2WExtCat__Commercial_Product__c == commercial)) aw.qtyEca =EC.XC_Quantity__c;
                    }
                    system.debug(' aw.qtyEca = '+ aw.qtyEca);
                    
                    system.debug(' product2ToEcaNew = '+ product2ToEcaNew.get(tecId));
                    
                    awList.add(aw);
                }
            }    
            
            idCommProductToListWrapper.put(commercial, awList); 
        }
        
        checkQty(idCommProductToListWrapper, neCatalogItemToEca, product2ToEca,product2ToEcaNew, tecAssetToProductInventory);
    }
    
    
    public static void checkQty(map<Id, List<Giic_AvailabilityWrapper>> idCommProductToAvailabilytyWrappers, map<Id,List<B2WExtCat__External_Catalog_Association__c>> neCatalogItemToEca, map<Id,List<B2WExtCat__External_Catalog_Association__c>> product2ToEca, map<Id,List<B2WExtCat__External_Catalog_Association__c>> product2ToEcaNew, map<Id, gii__ProductInventory__c> tecAssetToProductInventory  ){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In checkQty----->>' );
        map<Id, Decimal> commercialToQty = new map<Id, Decimal> ();
        map<Id, String>  commercialToCHName = new map<Id, String> ();
        List<String> legalEntityList = new List<String>();
        for(Id commercialProductId : idCommProductToAvailabilytyWrappers.keySet()){
            List<Decimal> tempList = new List<Decimal>();
            for(Giic_AvailabilityWrapper aw : idCommProductToAvailabilytyWrappers.get(commercialProductId)){
                commercialToCHName.put(commercialProductId, aw.catalogHeaderName);
                String procurementType  = aw.productInventory.gii__Product__r.giic_ProcurementType__c;
                Decimal temp = 0;
                if(aw.qtyPI==null){
                    aw.qtyPI = 0;
                }
                if(aw.qtyEca==null || aw.qtyEca==0){
                    aw.qtyEca = 1;
                }
                System.debug(' commercialProductId = '+ commercialProductId);
                System.debug(' gii__Product__c = '+ aw.productInventory.gii__Product__c);
                System.debug(' procurementType = '+ procurementType);
                System.debug(' aw.qtyPI = '+ aw.qtyPI);
                System.debug(' giic_SalesOnHand__c = '+ aw.productInventory.giic_SalesOnHand__c);
                System.debug(' aw.qtyEca = '+ aw.qtyEca);
                
                temp = (aw.qtyPI/aw.qtyEca).intValue();
                
                System.debug(' temp = '+ temp);
                
                
                tempList.add(temp);
                if(neCatalogItemToEca.containsKey(aw.neCatalogItem)){
                    List<gii__ProductInventory__c> possiblePIBrother = new List<gii__ProductInventory__c>();
                    List<B2WExtCat__External_Catalog_Association__c> possibleBrother = neCatalogItemToEca.get(aw.neCatalogItem);
                    for(B2WExtCat__External_Catalog_Association__c eca : possibleBrother){
                        possiblePIBrother.add(tecAssetToProductInventory.get(eca.XC_TechnicalProduct__c));
                    }
                    System.debug('possiblePIBrother = '+possiblePIBrother);
                    for(gii__ProductInventory__c pi : possiblePIBrother){
                        if(pi!=null){
                            Decimal temp1 = 0;
                            Decimal qtyPIBro = 0;
                            Decimal qtyEcaBro = 1;
                            
                            qtyPIBro = pi.giic_SalesOnHand__c;
                            System.debug(' qtyPIBro = '+ qtyPIBro);
                            System.debug('CatalogItem = '+aw.neCatalogItem);
                            List<B2WExtCat__External_Catalog_Association__c> ListEca = new List<B2WExtCat__External_Catalog_Association__c>();
                            ListEca = product2ToEca.get(pi.gii__Product__r.gii__ProductReference__r.Id);
                            for(B2WExtCat__External_Catalog_Association__c EC1 : ListEca){
                                if(EC1.B2WExtCat__Commercial_Catalog_Item__c == aw.neCatalogItem) qtyEcaBro =EC1.XC_Quantity__c;
                            }
                            System.debug(' qtyEcaBro = '+ qtyEcaBro);
                            system.debug(' product2ToEca  = '+ product2ToEca.get(pi.gii__Product__r.gii__ProductReference__r.Id));
                            
                            temp1 = (qtyPIBro/qtyEcaBro).intValue();
                            System.debug(' temp1 = '+ temp1);
                            
                            tempList.add(temp1);
                            
                            
                        }
                    }
                }
                
            }
            tempList.sort();
            System.debug('tempList = '+tempList);
            Decimal minValue = tempList[0];
            System.debug('minValue = '+minValue);
            if (minValue<0) minValue = 0;
            commercialToQty.put(commercialProductId, minValue); 
            System.debug('commercialToQty = '+commercialToQty);
        }
        setQtyOnMPR(commercialToQty , commercialToCHName);
    }
    
    
    
    
    public static void setQtyOnMPR(map<Id, Decimal> commercialToQty,  map<Id, String>  commercialIdToCHName  ){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In setQtyOnMPR----->>' );
        List<NE__Product__c> product2s = [SELECT Id,Name,XC_LIC_Product_Name__c FROM NE__Product__c WHERE Id IN: commercialToQty.keySet()];
        map<String,String> p2NamesToId = new map<String,String>();
        for(NE__Product__c p : product2s){
            p2NamesToId.put(p.XC_LIC_Product_Name__c, p.Id);
        }
        System.debug('p2NamesToId = '+p2NamesToId);
        List<NE__Matrix_Parameter_Row__c> parameterRowToUpdate = new  List<NE__Matrix_Parameter_Row__c>();
        
        System.debug('Row Names = '+p2NamesToId.keySet());
        map<Id,NE__Matrix_Parameter_Row__c> mprList = new  map<Id,NE__Matrix_Parameter_Row__c>([SELECT Id,XC_CatalogHeaderName__c, Name, NE__Active__c, Product_LIC_Name__c, XC_Region__c, XC_Name1__c, XC_Value1__c,XC_Name2__c, 
                                                                                                NE__Matrix_Parameter__r.NE__Catalog_Header__r.Name, XC_Value2__c, XC_Name3__c, XC_Value3__c, XC_Payment_model__c, XC_Number_Of_Delivery_Days__c,XC_valueReadOnly__c FROM
                                                                                                NE__Matrix_Parameter_Row__c where Product_LIC_Name__c IN: p2NamesToId.keySet() AND XC_ManagedBy__c = 'GLOVIA' AND 
                                                                                                XC_Rule_type__c = 'Pricing' ]);
        
        
        
        updateMPRs(mprList.values(), p2NamesToId, commercialToQty, commercialIdToCHName);
        
        
        
        
        
    }
    
    
    
    
    
    
    /**
* @author Milko Fatiga
* @date Creation 04/05/2021 
* @description  Method to update dinamically MPR
* @param mprQueried List<NE__Matrix_Parameter_Row__c>
* @param pCommNameToId Map<String, String>
* @param commercialToQty Map<Id, Decimal>
* @param commercialIdToCHName Map<Id, String>
*/
    public static void updateMPRs(List<NE__Matrix_Parameter_Row__c> mprQueried, map<String,String> pCommNameToId, map<Id, Decimal> commercialToQty, map<Id, String> commercialIdToCHName){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In updateMPRs----->>' );
        List<NE__Matrix_Parameter_Row__c> parameterRowToUpdate = new  List<NE__Matrix_Parameter_Row__c>();
        for(NE__Matrix_Parameter_Row__c mp : mprQueried){
            
            if((pCommNameToId.keySet()).contains(mp.Product_LIC_Name__c) && mp.NE__Matrix_Parameter__r.NE__Catalog_Header__r.Name==commercialIdToCHName.get(pCommNameToId.get(mp.Product_LIC_Name__c))){
                System.debug('trovata una mp per agg product inventory'+ mp);
                mp.XC_valueReadOnly__c = String.valueOf(commercialToQty.get(pCommNameToId.get(mp.Product_LIC_Name__c)));
                parameterRowToUpdate.add(mp);
            }
            
        }
        
        List<giic_ErrorLog__c> errorLogListToInsert = new List<giic_ErrorLog__c>(); 
        List<XC_UTIL_Sobject.WrapperResult> resultList = XC_UTIL_DML.updateRecords(parameterRowToUpdate, false);
        for(XC_UTIL_Sobject.WrapperResult w : resultList){
            if(!w.success){
                giic_ErrorLog__c objErr = new giic_ErrorLog__c(
                    Name =  'Error on Object: '+w.errorObjectId,
                    giic_ClassMessage__c = 'giic_CheckAvailabilityQty',
                    giic_Process__c   = 'Check Availability Qty for MPR: '+w.errorObjectId,
                    giic_ErrorDescription__c = w.errorMessage );
                errorLogListToInsert.add(objErr);
            }
        }
        insert errorLogListToInsert;
        
    } 
    
    
}