/**
 * @author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com
 * @date Creation 16/04/2020
 * @date Modification dd/mm/yyyy 
 * @description giic_TR_CheckAvailabilityForSupplierProd -  class to set check availability time on MPR 
 */
public without sharing class giic_TR_CheckAvailabilityForSupplierProd {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('giic_TR_CheckAvailabilityForSupplierProd');   
    
    
      /**
    * @author Lorenzo Orlanducci
    * @date Creation 22/10/2019 
    * @description  Method to 
    * @param listNew List<gii__PriceBookEntry__c>
    * @param oldMap Map<Id, gii__PriceBookEntry__c>
    * @param newMap Map<Id, gii__PriceBookEntry__c>
    */
    
    public static void checkAvailabilityForSupplierProduct(List<gii__PriceBookEntry__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In checkAvailabilityForSupplierProduct----->>' );
        map<Id,gii__PriceBookEntry__c> priceBookEntries = new Map<Id,gii__PriceBookEntry__c>([SELECT Id,gii__Product__c,giic_Default__c,gii__Product__r.gii__productReference__c,gii__Product__r.gii__PrimarySupplier__c,gii__PriceBook__c,gii__PriceBook__r.giic_Contract__c, gii__PriceBook__r.giic_Contract__r.AccountId
                                                                                              FROM gii__PriceBookEntry__c WHERE Id IN: listNew AND giic_Default__c = true ]);
        map<Id,gii__PriceBookEntry__c> defaultPriceBook = new map<Id,gii__PriceBookEntry__c>();
        map<Id,Id> prodRefToPBE = new map<Id,Id>();
        map<Id,Id> prod2ToProdRef = new map<Id,Id>();
        map<Id,Id> prod2ToCommercialProduct = new map<Id,Id>();
        for(gii__PriceBookEntry__c pb : priceBookEntries.values()){
            if(pb.gii__Product__r.gii__PrimarySupplier__c == pb.gii__PriceBook__r.giic_Contract__r.AccountId){
                defaultPriceBook.put(pb.Id, pb);
                prodRefToPBE.put(pb.gii__Product__c, pb.Id);
                prod2ToProdRef.put( pb.gii__Product__r.gii__productReference__c, pb.gii__Product__c);
              
            }
            
        }
        
        Map<Id,B2WExtCat__External_Catalog_Association__c> extCatFromTechToComm = new Map<Id,B2WExtCat__External_Catalog_Association__c>([SELECT Id ,B2WExtCat__Commercial_Product__c, XC_TechnicalProduct__c,B2WExtCat__Commercial_Catalog_Item__c,B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__c FROM B2WExtCat__External_Catalog_Association__c     WHERE XC_TechnicalProduct__c IN: prod2ToProdRef.keySet()]);
        System.debug('@@@@ EXTCAT ' +extCatFromTechToComm);
        
        for(B2WExtCat__External_Catalog_Association__c ex : extCatFromTechToComm.values()){
        	prod2ToCommercialProduct.put(ex.XC_TechnicalProduct__c, getCommercialProduct(ex));
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'End checkAvailabilityForSupplierProduct----->>' );
        startParameterUpdate(defaultPriceBook,prodRefToPBE, prod2ToCommercialProduct);      
    }
    
     /**
    * @author Lorenzo Orlanducci
    * @date Creation 22/10/2019 
    * @description  Method to 
    * @param B2WExtCat__External_Catalog_Association__c ex
    */
    
    private static Id getCommercialProduct(B2WExtCat__External_Catalog_Association__c ex){
          XC_UTIL_Debug.debug(DEBUGACTIVE,'In getCommercialProduct----->>' );
          Id prodId = (ex.B2WExtCat__Commercial_Product__c !=null) ? ex.B2WExtCat__Commercial_Product__c : ex.B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__c;
          return prodId;
    }
    
      /**
    * @author Lorenzo Orlanducci
    * @date Creation 22/10/2019 
    * @description  Method to 
    * @param listNew List<gii__PriceBookEntry__c>
    * @param oldMap Map<Id, gii__PriceBookEntry__c>
    * @param newMap Map<Id, gii__PriceBookEntry__c>
    */
    
    public static void startParameterUpdate(map<Id,gii__PriceBookEntry__c> defaultPriceBook, map<Id,Id> prodRefToPBE ,   map<Id,Id> prod2ToCommercialProduct ){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In startParameterUpdate----->>' );
        map<String,Decimal> pNameToDays = new  map<String,Decimal> ();
                                                   
        
         map<Id,NE__Product__c> commercialProduct = new map<Id,NE__Product__c>([SELECT id, XC_LIC_Product_Name__c, 
                                                                               (select Id, XC_TechnicalProduct__c  FROM B2WExtCat__External_Catalog_Associations__r) FROM NE__Product__c
                                                                                WHERE Id IN: prod2ToCommercialProduct.values() ]);
        
        map<Id, B2WExtCat__External_Catalog_Association__c> exCatMap = new map<Id, B2WExtCat__External_Catalog_Association__c> ([SELECT Id ,B2WExtCat__Commercial_Product__c,B2WExtCat__Commercial_Product__r.XC_LIC_Product_Name__c,
                                                                                                                                 XC_TechnicalProduct__c,B2WExtCat__Commercial_Catalog_Item__c,
                                                                            B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__c ,B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__r.XC_LIC_Product_Name__c,B2WExtCat__Commercial_Catalog_Item__r.NE__Catalog_Id__r.Name
                                                                            FROM B2WExtCat__External_Catalog_Association__c    
                                                                            WHERE B2WExtCat__Commercial_Product__c IN: commercialProduct.keySet()
                                                                            OR B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__c IN: commercialProduct.keySet()]);
            
        map<String,String> product2ToCommercialName = new  map<String,String>();
        map<Id, String>  commercialIdToCatalogHName = new map<Id, String> ();
        for(B2WExtCat__External_Catalog_Association__c a : exCatMap.values()){
            Id prodId = (a.B2WExtCat__Commercial_Product__c !=null) ? a.B2WExtCat__Commercial_Product__c : a.B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__c;
            commercialIdToCatalogHName.put(prodId, a.B2WExtCat__Commercial_Catalog_Item__r.NE__Catalog_Id__r.Name);
            if(a.B2WExtCat__Commercial_Product__c!=null){
                product2ToCommercialName.put(a.XC_TechnicalProduct__c, a.B2WExtCat__Commercial_Product__r.XC_LIC_Product_Name__c);
            }else{ 
                product2ToCommercialName.put(a.XC_TechnicalProduct__c, a.B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__r.XC_LIC_Product_Name__c); }
            
        }
        
        System.debug('commercialProduct = '+commercialProduct);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In startParameterUpdate con '+commercialProduct );
        List<Id> p2List = new List<Id>();
        map<String, String> primarySuppliersToP2 = new map<String, String>();
        map<String, String> productReferenceToLICName = new map<String, String>();
        map<Id, Product2> allTecnicalProduct2 = giic_TR_CheckAvailability.getAllProduct2(exCatMap.values());
        System.debug('allTecnicalProduct2 = '+allTecnicalProduct2);
        map<String,String> pCommNameToId = new map<String,String>();
        List<String> supplierList = new List<String>();
        for(NE__Product__c p : commercialProduct.values()){
            p2List = giic_TR_CheckAvailability.getAllProduct2IdsForOneCommercialProduct(p, exCatMap.values());
            
            System.debug('p2List = '+p2List);
            pCommNameToId.put(p.XC_LIC_Product_Name__c, p.Id);
            system.debug('pCommNameToId = '+pCommNameToId);
            for(Id p2 : p2List){
                 if(allTecnicalProduct2.get(p2)!=null && allTecnicalProduct2.get(p2).giic_PrimarySupplier__c!=null){
                        supplierList.add(allTecnicalProduct2.get(p2).giic_PrimarySupplier__c);
                   		primarySuppliersToP2.put(allTecnicalProduct2.get(p2).giic_PrimarySupplier__c+''+p2 , p2);
                }
            }
        }
        System.debug('primarySuppliersToP2 = '+primarySuppliersToP2);
        map<Id, List<gii__PriceBookEntry__c>> prodRefToPriceBookEntries = new  map<Id,List<gii__PriceBookEntry__c>> ();
        map<Id,gii__Product2Add__c> prodRef = new  map<Id,gii__Product2Add__c>([SELECT Id,gii__ProductReference__c,gii__ProductReference__r.giic_ProcurementType__c FROM gii__Product2Add__c where 
                                                                                gii__ProductReference__c IN: primarySuppliersToP2.values() AND gii__ProductReference__r.giic_ProcurementType__c ='Purchase']);
        
        System.debug('prodRef Querate = '+prodRef);
        Set<String> allCountries = new Set<String>();
        map<Id,Id> prod2ToProdRef = new map<Id,Id>();
        map<String, Decimal> countryToSupplyTime = new map<String, Decimal>();
        
        System.debug('prodRef = '+prodRef.keySet() );
        map<Id,gii__PriceBookEntry__c> priceBookEntries = new Map<Id,gii__PriceBookEntry__c>([SELECT Id,gii__Product__c,gii__Product__r.gii__productReference__c,giic_Default__c,giic_AvgSupplyTime__c ,gii__Product__r.gii__PrimarySupplier__c,gii__PriceBook__c,gii__PriceBook__r.giic_Contract__c, gii__PriceBook__r.giic_Contract__r.AccountId, gii__PriceBook__r.giic_Contract__r.Account.XC_Country__c
                                                                                              FROM 
                                                                                              gii__PriceBookEntry__c WHERE gii__PriceBook__r.giic_Contract__r.AccountId IN:supplierList AND gii__Product__c IN: prodRef.keySet()  AND giic_Default__c = true ]);
        for(gii__PriceBookEntry__c e : priceBookEntries.values()){
            String finalCapitalize = (e.gii__PriceBook__r.giic_Contract__r.Account.XC_Country__c).toLowerCase();
            allCountries.add(finalCapitalize.capitalize());
            prod2ToProdRef.put( e.gii__Product__r.gii__productReference__c, e.gii__Product__c);
        }
         
        
        
        
        List<XC_CM_WarehouseSupplyFlow__mdt> mdtList = [SELECT XC_Country__c, XC_SupplierSupplyTime__c FROM XC_CM_WarehouseSupplyFlow__mdt WHERE XC_Country__c IN: allCountries];
        for(XC_CM_WarehouseSupplyFlow__mdt mdt : mdtList){
            countryToSupplyTime.put(mdt.XC_Country__c, mdt.XC_SupplierSupplyTime__c);
        }
        
        
        for(gii__Product2Add__c p : prodRef.values()){
            
             productReferenceToLICName.put(p.Id, product2ToCommercialName.get(p.gii__productReference__c) );
             List<gii__PriceBookEntry__c> pbeList = new list<gii__PriceBookEntry__c>();
             for(gii__PriceBookEntry__c pb : priceBookEntries.values()){
                 if(pb.gii__Product__c == p.Id){ pbeList.add(pb); }
               
             }  
             prodRefToPriceBookEntries.put(p.Id, pbeList);
            
        }
        
        
        System.debug('prodRefToPriceBookEntries = '+prodRefToPriceBookEntries);
        for(Id i : prodRefToPriceBookEntries.keySet()){
            Decimal maxValue = 0;
            List<gii__PriceBookEntry__c> pbeValues = prodRefToPriceBookEntries.get(i);
            for(gii__PriceBookEntry__c pbe : pbeValues){
                if(pbe.giic_AvgSupplyTime__c>maxValue){ maxValue=pbe.giic_AvgSupplyTime__c; }
            }
           
            if(maxValue==0 && !prodRefToPriceBookEntries.get(i).isEmpty() && (prodRefToPriceBookEntries.get(i))[0]!=null){
                String country = (prodRefToPriceBookEntries.get(i)[0].gii__PriceBook__r.giic_Contract__r.Account.XC_Country__c).toLowerCase();
                maxValue = countryToSupplyTime.get(country.capitalize());
                
                
            }
            
            pNameToDays.put(productReferenceToLICName.get(i) , maxValue );
            
        }
        
        System.debug('pNameToDays = '+pNameToDays );
        List<NE__Matrix_Parameter_Row__c> parameterRowToUpdate = new List<NE__Matrix_Parameter_Row__c>();
        List<NE__Matrix_Parameter_Row__c> mprList = [SELECT Id, name, NE__Active__c, Product_LIC_Name__c, XC_Region__c, XC_Name1__c, XC_Value1__c,XC_Name2__c, XC_Value2__c, XC_Name3__c, XC_Value3__c, XC_Payment_model__c, XC_Number_Of_Delivery_Days__c,NE__Matrix_Parameter__r.NE__Catalog_Header__r.Name FROM NE__Matrix_Parameter_Row__c where  Product_LIC_Name__c IN: pNameToDays.keySet() AND 
                                                     XC_Rule_type__c = 'Pricing' ];
        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'End startParameterUpdate----->>' );
        giic_TR_CheckAvailability.updateMPRs(mprList , pCommNameToId, null, commercialIdToCatalogHName, pNameToDays, true);
        
        
    }

}