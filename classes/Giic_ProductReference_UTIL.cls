/**
* @author FirstName : Lorenzo Orlanducci
* @date Creation 6/12/2019
* @date Modification dd/mm/yyyy
* @description - 
*/
public without sharing class Giic_ProductReference_UTIL {


     private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_ProductReference_UTIL');
    
     public static void updateProcurementTypeOnProduct2InUpdate(List<gii__Product2Add__c> listNew,Map<Id,gii__Product2Add__c> mapOld, Map<Id,gii__Product2Add__c> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN updateProcurementTypeOnProduct2InUpdate');
        List<String> fieldList = new List<String>{'giic_ProcurementType__c','gii__PrimarySupplier__c'};
        List<gii__Product2Add__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        updateProcurementTypeOnProduct2(listChanged);
     }
    
    
    public static void  updateProcurementTypeOnProduct2(List<gii__Product2Add__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN updateProcurementTypeOnProduct2');
        List<Product2> product2ListToUpdate = new List<Product2>();
        for(gii__Product2Add__c p : listNew){
            if(p.gii__ProductReference__c != null && (p.gii__PrimarySupplier__c != null  || p.giic_ProcurementType__c != null) ){
            	Product2 p2 = new  Product2(Id = p.gii__ProductReference__c);
                if(p.giic_ProcurementType__c != null){
                    p2.giic_ProcurementType__c = p.giic_ProcurementType__c;
                }
                if(p.gii__PrimarySupplier__c != null){
                    p2.giic_PrimarySupplier__c = p.gii__PrimarySupplier__c;
                }
               
            	product2ListToUpdate.add(p2);
            }
            
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'END updateProcurementTypeOnProduct2');
        update product2ListToUpdate;
   
    }

    public static void  setCorrectValuesFromP2(List<gii__Product2Add__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN setCorrectValuesFromP2');
        List<Id> product2Id = new List<Id>();
         for(gii__Product2Add__c p : listNew){
             if(p.gii__ProductReference__c != null){
                    product2Id.add(p.gii__ProductReference__c);
             }
         }
         map<Id,Product2> p2map = new map<Id,Product2>([SELECT Id,giic_SerialControlled__c,giic_LotControlled__c, giic_LegalEntity__c, XC_External_ID__c,CurrencyIsoCode FROM Product2 WHERE Id IN: product2Id]);
         for(gii__Product2Add__c pRef : listNew){   
             for(Product2 p : p2map.values()){
                 if(pRef.gii__ProductReference__c == p.Id ){
                        pRef.giic_LegalEntity__c = p.giic_LegalEntity__c;
                        if(p.XC_External_ID__c != null){
                            pRef.giic_ExternalID__c = p.XC_External_ID__c;
                        }
                        pRef.CurrencyIsoCode  = p.CurrencyIsoCode;
                        pRef.gii__SerialControlled__c = p.giic_SerialControlled__c;  
                        pRef.gii__LotControlled__c = p.giic_LotControlled__c; 
                        
                 }
             }
            
        }
             

	XC_UTIL_Debug.debug(DEBUGACTIVE,'END setCorrectValuesFromP2');

    }
    
    
/**
* @author FirstName : Sara Miozza sara.miozza@nttadata.com
* @date Creation 9/12/2019
* @date Modification dd/mm/yyyy
* @description - Fill the field Service if the SAP type is 'Service'
* @param purchaseOdrLineList -  List of Product Reference
*/
    
    public static void updateServiceFlag(List<gii__Product2Add__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN updateServiceFlag');
        for(gii__Product2Add__c prodRef: listNew){
            if(prodRef.giic_SAPtype__c == 'Service'){ prodRef.gii__Service__c = true;  }
        } 
    } 
    
      /**
* @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 25/02/2021
* @date Modification dd/mm/yyyy
* @description - 
* @param listNew -  List of Product Reference
* @param mapOld -  map of old Product Reference
* @param mapNew -  map of Product Reference
*/
    public static void updateServiceFlagAndAVGPrice(List<gii__Product2Add__c> listNew,Map<Id,gii__Product2Add__c> mapOld, Map<Id,gii__Product2Add__c> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN updateProcurementTypeOnProduct2InUpdate');
        List<String> fieldList = new List<String>{'giic_SAPtype__c','CurrencyIsoCode','giic_AveragePrice__c'};
        List<gii__Product2Add__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        updateServiceFlag(listChanged);
        roundUpCurrency(listChanged);
        
    }
    
    /**
* @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 25/02/2021
* @date Modification dd/mm/yyyy
* @description - 
* @param listNew -  List of Product Reference
*/
    
    public static void roundUpCurrency(List<gii__Product2Add__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN roundUpCurrency');
        System.debug('IN roundUpCurrency');
        map<String,Boolean> isoCodeToNeedsRoundUp = new map<String,Boolean>();
        map<Id,Giic_GloviaCurrency__mdt> needsRoundUpMap = new map<Id,Giic_GloviaCurrency__mdt>([SELECT Id, DeveloperName, giic_NeedsRoundUp__c FROM Giic_GloviaCurrency__mdt WHERE giic_NeedsRoundUp__c = true]);
        for(Giic_GloviaCurrency__mdt md : needsRoundUpMap.values()){
            isoCodeToNeedsRoundUp.put(md.DeveloperName,md.giic_NeedsRoundUp__c);
        }
        System.debug('listNew = '+listNew);
        for(gii__Product2Add__c prodRef: listNew){
            if(prodRef.giic_AveragePrice__c!=null && prodRef.giic_AveragePrice__c!=0 && isoCodeToNeedsRoundUp.containsKey(prodRef.currencyIsoCode)){
                prodRef.giic_AveragePrice__c = (prodRef.giic_AveragePrice__c).round(System.RoundingMode.HALF_EVEN);
                System.debug('NEW AveragePrice__c= '+prodRef.giic_AveragePrice__c);
            }
        } 
    } 
    
    /*
    
    public static List<XC_UTIL_ResultWrapper> updateAveragePrice(map<String,Decimal> productCodeToCurrency){
        
        map<Id,gii__Product2Add__c> prodRefMap = new map<Id,gii__Product2Add__c>([SELECT Id, gii__ProductCode__c, giic_StockQuantity__c, giic_AveragePrice__c FROM gii__Product2Add__c 
                                                                                  WHERE gii__ProductCode__c IN: productCodeToCurrency.keySet() ]);
        
        for(gii__Product2Add__c productRef : prodRefMap.values()){
            if( productRef.giic_StockQuantity__c ==  null ){
             	productRef.giic_AveragePrice__c = (productRef.giic_AveragePrice__c*1 + productCodeToCurrency.get(productRef.gii__ProductCode__c) ) / 1;
             }else{
                productRef.giic_AveragePrice__c = (productRef.giic_AveragePrice__c*productRef.giic_StockQuantity__c+productCodeToCurrency.get(productRef.gii__ProductCode__c) ) / productRef.giic_StockQuantity__c;
             }
        }
        
        return  XC_UTIL_Glovia.updateRecords(prodRefMap.values());
        
    }
    
    
    */
    
    public static List<XC_UTIL_ResultWrapper> updateAveragePrice(List<Giic_CommonWrapper.MediaMobileWrapper> mediaMobileWrapList){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN updateAveragePrice');
        map<String,Decimal> productCodeToPrice = new map<String,Decimal>();
        map<String,String> productCodeToCurrency = new map<String,String>();
        Map<String, Double> currencyRates  =  new Map <String, Double>();
        Map<String,String> legalEntityMap = new Map<String,String>();
        
        for(CurrencyType cRates : [SELECT ISOCode, ConversionRate FROM CurrencyType WHERE IsActive=TRUE]) {
            currencyRates.put(cRates.IsoCode, cRates.ConversionRate);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'currencyRates = '+currencyRates);
        for(Giic_CommonWrapper.MediaMobileWrapper mmWrap : mediaMobileWrapList){
            productCodeToPrice.put(mmWrap.productCode, mmWrap.price);
            productCodeToCurrency.put(mmWrap.productCode, mmWrap.inCurrency);
            legalEntityMap.put(mmWrap.productCode, mmWrap.legalEntity);
        }
         map<Id,gii__Product2Add__c> prodRefMap = new map<Id,gii__Product2Add__c>([SELECT Id, gii__ProductCode__c, giic_StockQuantity__c, giic_AveragePrice__c,CurrencyIsoCode FROM gii__Product2Add__c 
                                                                                  WHERE gii__ProductCode__c IN: productCodeToCurrency.keySet() and giic_LegalEntity__c IN: legalEntityMap.values()]);
        
         for(gii__Product2Add__c productRef : prodRefMap.values()){
             Decimal newPriceConverted = 0.00;
             if(productCodeToCurrency.get(productRef.gii__ProductCode__c) != productRef.CurrencyIsoCode ){
            	 newPriceConverted = convertCurrency(productCodeToCurrency.get(productRef.gii__ProductCode__c), productRef.CurrencyIsoCode,productCodeToPrice.get(productRef.gii__ProductCode__c), currencyRates);
             }else{
                 newPriceConverted = productCodeToPrice.get(productRef.gii__ProductCode__c);        
             }
             if(productRef.giic_StockQuantity__c==null || productRef.giic_StockQuantity__c==0 ){
             	productRef.giic_AveragePrice__c = (productRef.giic_AveragePrice__c*1 + newPriceConverted) / 1;
             }else{
                productRef.giic_AveragePrice__c = (productRef.giic_AveragePrice__c*productRef.giic_StockQuantity__c+newPriceConverted) / productRef.giic_StockQuantity__c;
             }
             
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'END updateAveragePrice');
        return  XC_UTIL_Glovia.updateRecords(prodRefMap.values());
        
        
    }
    
    
    
    
    public static Decimal convertCurrency(String inCurrency, String outCurrency, Decimal inAmount,  Map<String, Double> currencyRates) {
            System.debug('IN convertCurrency');
            Decimal inCurrencyRate  = currencyRates.get(inCurrency);
            Decimal outCurrencyRate = currencyRates.get(outCurrency);
            
            Decimal amountInCorpCurr = inAmount/inCurrencyRate;
            Decimal outAmount = amountInCorpCurr *  outCurrencyRate;
            System.debug('valore convertito = '+outAmount);
            return outAmount;
    }
    
    
    
    
    

    
    
    
    
    

}