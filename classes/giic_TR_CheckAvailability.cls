/**
 * @author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com
 * @date Creation 22/10/2019
 * @date Modification dd/mm/yyyy 
 * @description giic_TR_CheckAvailability -  class to set check availability time on MPR 
 */
public without sharing class giic_TR_CheckAvailability {
    
 private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('giic_TR_CheckAvailability');   
 public static boolean firstRun = true;
 public class Giic_AvailabilityWrapper {
  
  public Id tecnicalProductId;
  public String catalogHeaderName;
  public Id neCatalogItem;
  public gii__ProductInventory__c productInventory;
  public Decimal tempoWH = 0;
  public Decimal tempoProd = 0;
  public String countryWH = '';
   

   public Giic_AvailabilityWrapper(){
     System.debug('Giic_AvailabilityWrapper.Giic_AvailabilityWrapper');
   }
 }
    
    
   public static void filterInventoryForcheckAvailability(List<gii__ProductInventory__c> listNew){
        /*
         XC_UTIL_Debug.debug(DEBUGACTIVE,'In filterInventoryForcheckAvailability----->>' );
            List<gii__ProductInventory__c> listChanged = new List<gii__ProductInventory__c> ();
            for(Id pIId : mapOld.keyset()){
                if((mapOld.get(pIId).giic_SalesOnHand__c == 0 && mapNew.get(pIId).giic_SalesOnHand__c > 0) || 
                   (mapOld.get(pIId).giic_SalesOnHand__c > 0 && mapNew.get(pIId).giic_SalesOnHand__c == 0 )  ){
                       listChanged.add(mapNew.get(pIId));
                   }
            }
        //List<gii__ProductInventory__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        
        if(listChanged.isEmpty()){
            return;
        }*/
       if(!System.isQueueable() && !System.isFuture() && firstRun){
       		System.enqueueJob(new Giic_CheckAvailabilityAsync(listNew));
            firstRun = false;
       }
		
        
    }
   /**
    * @author Lorenzo Orlanducci
    * @date Creation 22/10/2019 
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
        
        for(B2WExtCat__External_Catalog_Association__c extCat : extCatFromCommToAllTech) {
            Id prodId = (extCat.B2WExtCat__Commercial_Product__c !=null) ? extCat.B2WExtCat__Commercial_Product__c : extCat.B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__c;
            commercialIdToCatalogHName.put(prodId, extCat.B2WExtCat__Commercial_Catalog_Item__r.NE__Catalog_Id__r.Name);
            if(!commToTec.containsKey(prodId)){  commToTec.put(prodId, new List<Id>()); } 
            commToTec.get(prodId).add(extCat.XC_TechnicalProduct__c); 
            commToNECatalogItem.put(prodId, extCat.B2WExtCat__Commercial_Catalog_Item__c);
            
        }
        List<Id> allTotalTecProd = new List<Id>();
        // MODIFICA 01-07-2020 ISSUE ON TEC
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
        ///////////////////////////////////////////
        for(Id commerciale : commToTec.keySet()){
            for(Id tecId : commToTec.get(commerciale)){ 
                allTotalTecProd.add(tecId); 
            }
        }
        system.debug('allTotalTecProd = '+allTotalTecProd);
         map<Id, Decimal> productReferenceIdToAvgTime = new map<Id, Decimal>();
         map<Id, gii__ProductInventory__c> productReferenceToProductInventory = new map<Id, gii__ProductInventory__c>();
         map<Id, gii__ProductInventory__c> tecAssetToProductInventory = new map<Id, gii__ProductInventory__c>();
         map<Id, gii__ProductInventory__c> productInventories = new map<Id, gii__ProductInventory__c>([SELECT Id,giic_LegalEntity__c,giic_OnHandNew__c,giic_SalesOnHand__c,giic_AvgTransferTime__c,gii__Product__c,gii__OnHandQuantity__c ,gii__Warehouse__r.giic_WarehouseType__c,gii__Product__r.gii__ProductReference__c,gii__Product__r.giic_ProcurementType__c, gii__Product__r.gii__PrimarySupplier__c,gii__Warehouse__c, gii__Warehouse__r.gii__WareHouseCountry__c,  gii__Warehouse__r.giic_wareHouseCountryPick__c, gii__Warehouse__r.giic_ParentWarehouse__c
                                                                                                   FROM gii__ProductInventory__c WHERE  gii__Product__r.gii__ProductReference__c IN: allTotalTecProd AND gii__Warehouse__r.giic_WarehouseType__c='Central' ]);
        System.debug('All productInventories = '+productInventories);
        for(gii__ProductInventory__c p : productInventories.values()){
             if(p.gii__Product__r!=null){
            		tecAssetToProductInventory.put(p.gii__Product__r.gii__ProductReference__c, p);
                    productReferenceToProductInventory.put(p.gii__Product__r.Id, p);
             }
        }
        map<Id, gii__PriceBookEntry__c> priceBookEntries = new map<Id, gii__PriceBookEntry__c>([SELECT Id,giic_Default__c, gii__Product__c,giic_AvgSupplyTime__c FROM gii__PriceBookEntry__c
        WHERE gii__Product__c IN: productReferenceToProductInventory.keySet() AND giic_Default__c = true]);
        for(gii__PriceBookEntry__c pbe : priceBookEntries.values()){ productReferenceIdToAvgTime.put(pbe.gii__Product__c, pbe.giic_AvgSupplyTime__c); }
        map<Id, List<Giic_AvailabilityWrapper>> idCommProductToListWrapper = new map<Id, List<Giic_AvailabilityWrapper> >(); 
        map<String, Decimal> countryToSupplyTime = new map<String, Decimal>();
        map<String, Decimal> countryToLogisticPartnerTime = new map<String, Decimal>();
        List<XC_CM_WarehouseSupplyFlow__mdt> mdtList = [SELECT XC_Country__c, XC_SupplierSupplyTime__c,XC_LogisticPartnerSupplyTime__c FROM XC_CM_WarehouseSupplyFlow__mdt];
        for(XC_CM_WarehouseSupplyFlow__mdt mdt : mdtList){
            countryToSupplyTime.put(mdt.XC_Country__c, mdt.XC_SupplierSupplyTime__c);
            System.debug('countryToSupplyTime = '+countryToSupplyTime);
            countryToLogisticPartnerTime.put(mdt.XC_Country__c, mdt.XC_LogisticPartnerSupplyTime__c);
        }
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
                    
                    aw.tempoWH = (tecAssetToProductInventory.get(tecId).giic_AvgTransferTime__c!=null && tecAssetToProductInventory.get(tecId).giic_AvgTransferTime__c!=0 ) ? tecAssetToProductInventory.get(tecId).giic_AvgTransferTime__c : countryToSupplyTime.get(aw.countryWH); 
                    system.debug(' aw.tempoWH = '+ aw.tempoWH);
                    aw.tempoProd = (productReferenceIdToAvgTime.get(tecAssetToProductInventory.get(tecId).gii__Product__c)) !=null ? productReferenceIdToAvgTime.get(tecAssetToProductInventory.get(tecId).gii__Product__c)  : countryToLogisticPartnerTime.get(aw.countryWH);
                    
                    awList.add(aw);
                }
            }    
            
            idCommProductToListWrapper.put(commercial, awList); 
        }
     
        checkWhenCommercialIsReady(idCommProductToListWrapper, neCatalogItemToEca, product2ToEca, tecAssetToProductInventory);
  }
    
    
    public static void checkWhenCommercialIsReady(map<Id, List<Giic_AvailabilityWrapper>> idCommProductToAvailabilytyWrappers, map<Id,List<B2WExtCat__External_Catalog_Association__c>> neCatalogItemToEca, map<Id,List<B2WExtCat__External_Catalog_Association__c>> product2ToEca, map<Id, gii__ProductInventory__c> tecAssetToProductInventory  ){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In checkWhenCommercialIsReady----->>' );
        map<Id, Decimal> commercialToTime = new map<Id, Decimal> ();
        map<Id, String>  commercialToCHName = new map<Id, String> ();
        List<String> legalEntityList = new List<String>();
        for(Id commercialProductId : idCommProductToAvailabilytyWrappers.keySet()){
            List<Decimal> tempList = new List<Decimal>();
            for(Giic_AvailabilityWrapper aw : idCommProductToAvailabilytyWrappers.get(commercialProductId)){
                commercialToCHName.put(commercialProductId, aw.catalogHeaderName);
                String procurementType  = aw.productInventory.gii__Product__r.giic_ProcurementType__c;
                Decimal temp = 0;
                if(aw.tempoWH==null){
                    aw.tempoWH = 0;
                }
                if(aw.tempoProd==null){
                    aw.tempoProd = 0;
                }
                if(procurementType!=null && procurementType=='Purchase'){ temp = aw.tempoProd;    //  nuovo tempo procebookEntry
                }else{
                   
                    if(aw.productInventory.giic_SalesOnHand__c > 0){ temp =  aw.tempoWH; }
                    else{   
                        System.debug(' aw.tempoWH = '+ aw.tempoWH);
                        System.debug(' aw.tempoProd;= '+ aw.tempoProd);
                        
                        temp =  aw.tempoWH +  aw.tempoProd;  }
                    
                }  
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
                        	tempList.add(pi.giic_AvgTransferTime__c);
                        }
                    }
                }
              
           }
            tempList.sort();
            System.debug('tempList = '+tempList);
			Decimal maxValue = tempList[tempList.size()-1];
            
            commercialToTime.put(commercialProductId, maxValue); 
            System.debug('Commercial Final temp = '+commercialToTime);
        }
        setCommercialTimeOnMPR(commercialToTime , commercialToCHName);
   }



    
    public static void setCommercialTimeOnMPR(map<Id, Decimal> commercialToTime,  map<Id, String>  commercialIdToCHName  ){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In setCommercialTimeOnMPR----->>' );
        List<NE__Product__c> product2s = [SELECT Id,Name,XC_LIC_Product_Name__c FROM NE__Product__c WHERE Id IN: commercialToTime.keySet()];
        map<String,String> p2NamesToId = new map<String,String>();
        for(NE__Product__c p : product2s){
            p2NamesToId.put(p.XC_LIC_Product_Name__c, p.Id);
        }
        System.debug('p2NamesToId = '+p2NamesToId);
        List<NE__Matrix_Parameter_Row__c> parameterRowToUpdate = new  List<NE__Matrix_Parameter_Row__c>();
        
        System.debug('Row Names = '+p2NamesToId.keySet());
        map<Id,NE__Matrix_Parameter_Row__c> mprList = new  map<Id,NE__Matrix_Parameter_Row__c>([SELECT Id,XC_CatalogHeaderName__c, Name, NE__Active__c, Product_LIC_Name__c, XC_Region__c, XC_Name1__c, XC_Value1__c,XC_Name2__c, 
                                                     NE__Matrix_Parameter__r.NE__Catalog_Header__r.Name, XC_Value2__c, XC_Name3__c, XC_Value3__c, XC_Payment_model__c, XC_Number_Of_Delivery_Days__c FROM
                                                     NE__Matrix_Parameter_Row__c where Product_LIC_Name__c IN: p2NamesToId.keySet() AND 
                                                     XC_Rule_type__c = 'Pricing' ]);


        
        updateMPRs(mprList.values(), p2NamesToId, commercialToTime, commercialIdToCHName, null, false);
                                                     
        

        
        
    }
    
    
   
    
    
    
    /**
    * @author Lorenzo Orlanducci
    * @date Creation 22/10/2019 
    * @description  Method to update dinamically MPR for all type of checkAvailability
    * @param mprQueried List<NE__Matrix_Parameter_Row__c>
    * @param pCommNameToId Map<String, String>
    * @param commercialToTime Map<Id, Decimal>
    * @param commercialIdToCHName Map<Id, String>
    * @param pNameToDays Map<String, Decimal>
    * @param forSupplierProductOrNot Boolean
    */
     public static void updateMPRs(List<NE__Matrix_Parameter_Row__c> mprQueried, map<String,String> pCommNameToId, map<Id, Decimal> commercialToTime, map<Id, String> commercialIdToCHName,  map<String,Decimal> pNameToDays, Boolean forSupplierProductOrNot){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In updateMPRs----->>' );
        List<NE__Matrix_Parameter_Row__c> parameterRowToUpdate = new  List<NE__Matrix_Parameter_Row__c>();
        for(NE__Matrix_Parameter_Row__c mp : mprQueried){
            if(!forSupplierProductOrNot){
            	if((pCommNameToId.keySet()).contains(mp.Product_LIC_Name__c) && mp.NE__Matrix_Parameter__r.NE__Catalog_Header__r.Name==commercialIdToCHName.get(pCommNameToId.get(mp.Product_LIC_Name__c))){
                	    System.debug('trovata una mp per agg product inventory'+ mp);
                    	mp.XC_Number_Of_Delivery_Days__c = commercialToTime.get(pCommNameToId.get(mp.Product_LIC_Name__c));
                    	parameterRowToUpdate.add(mp);
            	}
            }else{
                if((pNameToDays.keySet()).contains(mp.Product_LIC_Name__c) &&
                mp.NE__Matrix_Parameter__r.NE__Catalog_Header__r.Name == commercialIdToCHName.get(pCommNameToId.get(mp.Product_LIC_Name__c))  ){
                    System.debug('trovata una mp per agg pricebook Entry'+ mp);
                    mp.XC_Number_Of_Delivery_Days__c = pNameToDays.get(mp.Product_LIC_Name__c);
                    parameterRowToUpdate.add(mp);
                   
            }
                
            }
        }
         
        List<giic_ErrorLog__c> errorLogListToInsert = new List<giic_ErrorLog__c>(); 
		List<XC_UTIL_Sobject.WrapperResult> resultList = XC_UTIL_DML.updateRecords(parameterRowToUpdate, false);
        for(XC_UTIL_Sobject.WrapperResult w : resultList){
            if(!w.success){
                 giic_ErrorLog__c objErr = new giic_ErrorLog__c(
            	 Name =  'Error on Object: '+w.errorObjectId,
            	 giic_ClassMessage__c = 'giic_TR_CheckAvailability',
            	 giic_Process__c   = 'Check Availability for MPR: '+w.errorObjectId,
            	 giic_ErrorDescription__c = w.errorMessage );
                 errorLogListToInsert.add(objErr);
            }
        }
        insert errorLogListToInsert;
         
    } 
    
    
    
    
    public static List<Id> getAllProduct2IdsForOneCommercialProduct(NE__Product__c p, List<B2WExtCat__External_Catalog_Association__c> totalAssociation){
        List<Id> allTecnicalProdForOneCommercial = new  List<Id>();
        List<Id> allEcaId = new  List<Id>();
        map<Id,NE__Product__c> prodIdToCommProd = new map<id,NE__Product__c> ();
        prodIdToCommProd.put(p.Id,p);
        System.debug('prodIdToCommProd = '+prodIdToCommProd);
        for(B2WExtCat__External_Catalog_Association__c a : totalAssociation){
            
            if(a.B2WExtCat__Commercial_Product__c == p.Id || a.B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__c ==p.Id){
                allEcaId.add(a.Id);
            	allTecnicalProdForOneCommercial.add(a.XC_TechnicalProduct__c);
            }
        }
        System.debug('allEcaId = '+allEcaId);
        
        return allTecnicalProdForOneCommercial;
    }
    
    
    
    public static  map<Id,Product2>  getAllProduct2(List<B2WExtCat__External_Catalog_Association__c> pList){
        List<Id> allTecnicalProdForOneCommercial = new  List<Id>();
        for(B2WExtCat__External_Catalog_Association__c p : pList){
             allTecnicalProdForOneCommercial.add(p.XC_TechnicalProduct__c);
 		}
        map<Id,Product2> mapToReturn = new  map<Id,Product2>([SELECT Id, giic_PrimarySupplier__c FROM Product2 WHERE Id IN: allTecnicalProdForOneCommercial]);
        return mapToReturn;
        
    }
    
    
    
    
}