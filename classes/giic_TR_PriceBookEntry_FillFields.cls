/**
 * @author Lorenzo Orlanducci
 * @date Creation 22/10/2019
 * @date Modification dd/mm/yyyy
 * @description giic_TR_PriceBookEntry_FillFields -  class to set partner account field on PriceBookEntry 
 */
public without sharing class giic_TR_PriceBookEntry_FillFields {
    
    /**
    * @author Lorenzo Orlanducci
    * @date Creation 12/11/2019 
    * @description  Method to populate AccountId on gii__PriceBookEntry__c
    * @param listNew List<gii__PriceBookEntry__c>
   
    */
    
    public static void fillAccountFields(List<gii__PriceBookEntry__c> listNew){
        List<gii__PriceBookEntry__c> priceBookEntryToUpdate = new List<gii__PriceBookEntry__c>();
        List<Id> priceBookIdList = new  List<Id> ();
        for(gii__PriceBookEntry__c pbentry :  listNew){
            priceBookIdList.add(pbentry.gii__PriceBook__c);
        }
        map<Id,gii__PriceBook__c> pBook = new map<Id,gii__PriceBook__c>([SELECT Id, giic_Contract__c,giic_Contract__r.AccountId FROM gii__PriceBook__c WHERE Id IN: priceBookIdList]);
        for(gii__PriceBook__c p : pBook.values()){
             for(gii__PriceBookEntry__c pbe :  listNew){
             	if(pbe.gii__PriceBook__c==p.Id && p.giic_Contract__c!=null){
            		pbe.giic_AccountPartner__c = p.giic_Contract__r.AccountId;
            	}
             }
        }
        
        
    }
    
     /**
    * @author Lorenzo Orlanducci
    * @date Creation 12/11/2019 
    * @description  Method to rebalt productId on a text Field
    * @param listNew List<gii__PriceBookEntry__c>
   
    */
    
    public static void fillProductFields(List<gii__PriceBookEntry__c> listNew){
         for(gii__PriceBookEntry__c pbe :  listNew){
             pbe.giic_O_ProductID__c = pbe.gii__Product__c; 
             //pbe.gii__UniquePriceBookEntry__c = pbe.giic_ExternalID__c ; 
             pbe.giic_O_Default__c = String.valueOf(pbe.giic_Default__c);
             pbe.CurrencyIsoCode = pbe.giic_CurrencyKey__c!= null? pbe.giic_CurrencyKey__c : pbe.CurrencyIsoCode; 
         }
        
        
    }
    
     /**
    * @author Lorenzo Orlanducci
    * @date Creation 12/11/2019 
    * @description  Method to rebalt productId on a text Field
    * @param listNew List<gii__PriceBookEntry__c>
   
    */
    
    public static void fillCurrencyFields(List<gii__PriceBook__c> listNew){
        List<String> contractList = XC_UTIL_SObject.getListFieldValues(listNew, 'giic_Contract__c');
        Map<Id,Contract> contracts = new Map<Id,Contract>([SELECT ID ,CurrencyIsoCode
                                                           FROM Contract
                                                           WHERE Id IN :contractList]);
         for(gii__PriceBook__c pb :  listNew){
             pb.CurrencyIsoCode = contracts.get(pb.giic_Contract__c).CurrencyIsoCode; 
         }
        
        
    }
    
      /** 
    * @description Method to manage Company information
    * @param contractList - List<Contract>
    * @param mapOld - Map<Id, Contract>
    * @param mapNew - Map<Id, Contract>
    */
    public static void getCompanyNameByCompanyCodeInUpdate(List<Contract> contractList, Map<Id, Contract> mapOld, Map<Id, Contract> mapNew){
        List<String> fieldList = new List<String>{'XC_CompanyCode__c','XC_CurrencyKey__c'};
        List<Contract> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){  return;  }
        getCompanyNameByCompanyCode(listChanged);
    }
         
    /** 
    * @description Method to manage Contract information
    * @param contractList - List<Contract>
    * @param mapOld - Map<Id, Contract>
    * @param mapNew - Map<Id, Contract>
    */  
    public static void getCompanyNameByCompanyCode( List<Contract> contractList){
        List<String> companyCodeList = new List<String>();
        for(Contract c : contractList){
              c.XC_CompanyCode__c = c.XC_CompanyCode__c == 'ES21' ? 'ES5R' : c.XC_CompanyCode__c;      
              companyCodeList.add(c.XC_CompanyCode__c);
        }
        if(companyCodeList.isEmpty()){
            return;
        }
        List<XC_CM_LegalEntity_Configuration__mdt> mdtList = new List<XC_CM_LegalEntity_Configuration__mdt>([
            SELECT Id,XC_LegalEntity__c,XC_CompanyCode__c
            FROM XC_CM_LegalEntity_Configuration__mdt
            WHERE XC_CompanyCode__c IN :companyCodeList AND XC_isUsedByGlovia__c = true ]);
        
        if(mdtList.isEmpty()){
            return;
        }
        Map<String,String> mapCompanyCodeCompanyName = new Map<String,String>();
        for(XC_CM_LegalEntity_Configuration__mdt mdt : mdtList ){
            mapCompanyCodeCompanyName.put(mdt.XC_CompanyCode__c, mdt.XC_LegalEntity__c);
        }
        for(Contract c : contractList){
            if(c.recordTypeId == Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_ContractPartner').getRecordTypeId()){             
                c.XC_CompanyName__c = mapCompanyCodeCompanyName.get(c.XC_CompanyCode__c);
                c.XC_LegalEntity__c = mapCompanyCodeCompanyName.get(c.XC_CompanyCode__c);
                c.CurrencyIsoCode = c.XC_CurrencyKey__c != null ? c.XC_CurrencyKey__c : c.CurrencyIsoCode;      
            }
        }
    }
    

}