public without sharing class Giic_TR_Product2_UTIL {
    
     private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_TR_Product2_UTIL');
    
    
    
    public static void checkIfCompanyCodeChange(List<Product2> listNew, Map<Id, Product2> mapOld ,Map<Id, Product2> mapNew ){
     XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ IN checkIfCompanyCodeChange' ); 
     List<String> fieldToCheck = new List<String> {'XC_CompanyCode__c'};
     List<Product2> listP2Changed = XC_UTIL_Sobject.getListChanged(fieldTocheck, mapOld, mapNew);
     setLEOnP2(listP2Changed);
        
    }
    
    
    public static void checkIfLegalEntityChange(List<Product2> listNew, Map<Id, Product2> mapOld ,Map<Id, Product2> mapNew ){
     XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ IN checkIfLegalEntityChange' ); 
     List<String> fieldToCheck = new List<String> {'giic_LegalEntity__c'};
     List<Product2> listP2Changed = XC_UTIL_Sobject.getListChanged(fieldTocheck, mapOld, mapNew);
     p2DuplicationRule(listP2Changed);
     
        
    }
   
    
     public static void setLEOnP2(List<Product2> p2List){
        Id currentUserId = userInfo.getUserId();
        Boolean isMigrationUser = false;
        if(currentUserId!=null){
        	isMigrationUser = [SELECT XC_GloviaMigrationUser__c FROM User WHERE Id = :currentUserId LIMIT 1][0].XC_GloviaMigrationUser__c;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ IN setLEOnP2' ); 
        Map<String,String> mapCompanyCodeToLegalEntity = new Map<String,String>();
        Map<String,String> mapCompanyCodeToDEFAULTCurrency = new Map<String,String>();
        List<String> companyCode = XC_UTIL_SObject.getListFieldValues( p2List, 'XC_CompanyCode__c');
        
         
        List<XC_CM_LegalEntity_Configuration__mdt> mdtList = new List<XC_CM_LegalEntity_Configuration__mdt>([SELECT Id,XC_LegalEntity__c,XC_CompanyCode__c,XC_Currency__c
                                                                                                             FROM XC_CM_LegalEntity_Configuration__mdt
                                                                                                             WHERE XC_CompanyCode__c IN :companyCode AND 
                                                                                                             XC_isUsedByGlovia__c = true]);
        if(mdtList.isEmpty()){
            return;
        }
        
        for(XC_CM_LegalEntity_Configuration__mdt mdt : mdtList ){
            mapCompanyCodeToLegalEntity.put(mdt.XC_CompanyCode__c, mdt.XC_LegalEntity__c);
            mapCompanyCodeToDEFAULTCurrency.put(mdt.XC_CompanyCode__c,mdt.XC_Currency__c);
        }
         
        for(Product2 p : p2List){
            if(mapCompanyCodeToLegalEntity.containsKey(p.XC_CompanyCode__c)){
        		p.giic_LegalEntity__c = mapCompanyCodeToLegalEntity.get(p.XC_CompanyCode__c);
            }
            if(isMigrationUser && mapCompanyCodeToDEFAULTCurrency.containsKey(p.XC_CompanyCode__c)){
            	p.CurrencyIsoCode = mapCompanyCodeToDEFAULTCurrency.get(p.XC_CompanyCode__c);
            }
            
            System.debug('p.CurrencyIsoCode2 = '+ p.CurrencyIsoCode);
        }
         
         
    }
    
    
    
    
    
     public static void p2DuplicationRule(List<Product2> p2List){
          XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ IN p2DuplicationRule' ); 
        map<String,String> p2CodeToLegalEntity = new map<String,String>();
        for(Product2 p : p2List){
            p2CodeToLegalEntity.put(p.ProductCode, p.giic_LegalEntity__c );
        }
         XC_UTIL_Debug.debug(DEBUGACTIVE,'p2CodeToLegalEntity = '+p2CodeToLegalEntity ); 
        map<Id,Product2> p2Map = new map<Id,Product2>([SELECT Id,ProductCode,giic_LegalEntity__c FROM Product2 WHERE ProductCode IN: p2CodeToLegalEntity.keySet() AND giic_LegalEntity__c IN: p2CodeToLegalEntity.values()]);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'p2Map = '+p2Map); 
        if(!p2Map.values().isEmpty()){
              for(Product2 pOld : p2Map.values()){
                  for(Product2 pNew : p2List){
                      if(pNew.ProductCode == pOld.ProductCode && pNew.giic_LegalEntity__c == pOld.giic_LegalEntity__c){
                          pNew.addError(Label.giic_CL_DuplicateProductCode);
                      }
                      
                  }
                  
                 
             }
         }
         
        
    }



     public static void checkIfValuesToAlignChange(List<Product2> listNew, Map<Id, Product2> mapOld ,Map<Id, Product2> mapNew ){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ IN checkIfValuesToAlignChange' ); 
        List<String> fieldToCheck = new List<String> {'XC_External_ID__c', 'giic_LegalEntity__c','giic_LotControlled__c','giic_SerialControlled__c','CurrencyIsoCode'};
        List<Product2> listP2Changed = XC_UTIL_Sobject.getListChanged(fieldTocheck, mapOld, mapNew);
        setValuesOnProductReference(listP2Changed);
        
    }




     public static void setValuesOnProductReference(List<Product2> p2List){
         XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ IN setValuesOnProductReference' ); 
        
                List<gii__Product2Add__c> prodRefToUpdate = new List<gii__Product2Add__c>();
                Set<Id> productId = new  Set<Id>();
                for(Product2 p : p2List){
                    productId.add(p.Id);
                }
                map<Id,gii__Product2Add__c> p2map = new map<Id,gii__Product2Add__c>([SELECT Id,gii__ProductReference__c,giic_LegalEntity__c,gii__ProductReference__r.XC_External_ID__c, gii__ProductReference__r.giic_LegalEntity__c,
                                                                                     gii__ProductReference__r.giic_SerialControlled__c,gii__ProductReference__r.giic_LotControlled__c,
                                                                                     gii__ProductReference__r.CurrencyIsoCode
                                                                                     FROM gii__Product2Add__c 
                                                                                     WHERE gii__ProductReference__c IN: productId]);
                for(gii__Product2Add__c prodRef : p2map.values() ){
                    prodRef.giic_ExternalID__c = prodRef.gii__ProductReference__r.XC_External_ID__c;
                    prodRef.gii__SerialControlled__c = prodRef.gii__ProductReference__r.giic_SerialControlled__c;
                    prodRef.gii__LotControlled__c = prodRef.gii__ProductReference__r.giic_LotControlled__c;
                    prodRef.CurrencyIsoCode = prodRef.gii__ProductReference__r.CurrencyIsoCode;
                    prodRef.giic_LegalEntity__c = prodRef.gii__ProductReference__r.giic_LegalEntity__c;
                    
                    prodRefToUpdate.add(prodRef);
                }
         XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ END setExtIDOnProductReference' ); 
         XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ END setExtIDOnProductReference' ); 
         XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ END setExtIDOnProductReference' ); 
         XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ END setExtIDOnProductReference' ); 
                update prodRefToUpdate;


     }


    
    
     /**
* @author FirstName : Alberto Pompei alberto.pompei@nttadata.com
* @date Creation 05/05/2021
* @date Modification dd/mm/yyyy
* @description - Fill the field SAP type with 'Service' if the Material Group is 'SLPI0401'
* @param listNew -  List of Product2
*/
    
    public static void setSapTypeWithService(List<Product2> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN setSapTypeWithService');
        for(Product2 prod: listNew){
            if(prod.XC_MaterialGroup__c == 'SLPI0401'){ 
                prod.XC_SapType__c = 'Service';
            }
        } 
    }
    

}