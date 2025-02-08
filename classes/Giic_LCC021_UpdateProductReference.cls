/**
* @author FirstName : Sara Miozza - sara.miozza@nttdata.com & Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 26/03/2020
* @date Modification dd/mm/yyyy
* @description - Class to update product reference from commercial catalog.
*/
public  without sharing  class Giic_LCC021_UpdateProductReference {	
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_LCC021_UpdateProductReference');
    
/**
* @author FirstName : Sara Miozza - sara.miozza@nttdata.com & Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 26/03/2020
* @date Modification dd/mm/yyyy
* @description - Class to update product reference from commercial catalog.
* @param prID
*/
    @AuraEnabled
    public static XC_UTIL_ResultWrapper updateProdReference(String prID){
        
        List<gii__Product2Add__c> prList = new List<gii__Product2Add__c>([SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c WHERE ID =: prID]);
        
		return updateProdReference(prList);        
    }
    
/**
* @author FirstName : Sara Miozza - sara.miozza@nttdata.com & Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 26/03/2020
* @date Modification dd/mm/yyyy
* @description - Class to update product reference from commercial catalog.
* @param prList
*/  
    public static XC_UTIL_ResultWrapper updateProdReference(List<gii__Product2Add__c> prList){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        List< XC_UTIL_ResultWrapper> rwList = new List<XC_UTIL_ResultWrapper>();
        Map<Id,Id> prod2ToProdRef = new Map<Id,Id>();
        for(gii__Product2Add__c prodRef : prList){
            prod2ToProdRef.put(prodRef.gii__ProductReference__c,prodRef.Id);
        }
        List<B2WExtCat__External_Catalog_Association__c> extCatList = new List<B2WExtCat__External_Catalog_Association__c>(
        																	   [SELECT Id,XC_TechnicalProduct__c, 
                                                                                    B2WExtCat__Commercial_Catalog_Item__r.XC_ProductServiceType__c, 
                                                                                    B2WExtCat__Commercial_Catalog_Item__r.XC_ProductLine__c ,
                                                                                	B2WExtCat__Commercial_Catalog_Item__r.XC_CostCenter__c 
                                                                                    from B2WExtCat__External_Catalog_Association__c 
                                                                                    where XC_TechnicalProduct__c IN:prod2ToProdRef.keySet()]);
        Map<Id,B2WExtCat__External_Catalog_Association__c> prod2ToExternalCat = new Map<Id,B2WExtCat__External_Catalog_Association__c>();
        if(extCatList.isEmpty()){ 
           rw.success = false;
           rw.resultMessage = 'There aren\'t External Catalog Associations for this product';
           return rw; 
        }
        for(B2WExtCat__External_Catalog_Association__c extCat : extCatList ){
            prod2ToExternalCat.put(extCat.XC_TechnicalProduct__c,extCat);
        }
        
        for(gii__Product2Add__c prodRef : prList){
            if(prod2ToExternalCat.containsKey(prodRef.gii__ProductReference__c) && prod2ToExternalCat.get(prodRef.gii__ProductReference__c).B2WExtCat__Commercial_Catalog_Item__c != null){
                prodRef.giic_ProductServiceType__c = prod2ToExternalCat.get(prodRef.gii__ProductReference__c).B2WExtCat__Commercial_Catalog_Item__r.XC_ProductServiceType__c;
                prodRef.giic_ProductLine__c = prod2ToExternalCat.get(prodRef.gii__ProductReference__c).B2WExtCat__Commercial_Catalog_Item__r.XC_ProductLine__c;
                prodRef.giic_CostCenter__c = prod2ToExternalCat.get(prodRef.gii__ProductReference__c).B2WExtCat__Commercial_Catalog_Item__r.XC_CostCenter__c;
              }    
        }
       	
        rwList = XC_UTIL_Glovia.updateRecords(prList);
        for(XC_UTIL_ResultWrapper rwrap : rwList){
            if(!rwrap.success){ return rwrap; }
        }
		return rw;        
    }
    
    
}