/**
* @author FSL Team - marco.rosa@nttdata.com
* @date Creation 22/03/2021
* @description – XC_UTIL_WOCreateSalesOrder_U  - Util class for XC_UTIL_WOCreateSalesOrder
*/ 
public without sharing class XC_UTIL_WOCreateSalesOrder_U {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_WOCreateSalesOrder');    
     
    /**
    * @author FSL Team - marco.rosa@nttdata.com
    * @date Creation 22/03/2021
    * @description Method to create new Product Required if child product2add exist
    * @param List<WorkOrder> listWo
    */ 
    
    public static void createExtraProductRequired(List<WorkOrder> listWo){
        List<Id> listProduct2Ids = new List<Id>();
        for(WorkOrder wo : listWo){
            if(!wo.ProductsRequired.IsEmpty()){
                for(ProductRequired pr : wo.ProductsRequired){
                    listProduct2Ids.add(pr.Product2Id);
                }
            }
        }
        Map<Id, gii__Product2Add__c> mapProductGlovia = new Map<Id, gii__Product2Add__c>([
            SELECT Id, gii__ProductReference__c, 
                (Select id, gii__ProductReference__c, gii__SerialControlled__c
                FROM gii__ProductStyleReferences__r) 
            FROM gii__Product2Add__c  
            WHERE gii__ProductReference__c IN: listProduct2Ids 
        ]); 
        Map<Id, Id> mapProd2ProdGlovia = new Map<Id, Id>();
        for(gii__Product2Add__c prGlovia : mapProductGlovia.values()){
            mapProd2ProdGlovia.put(prGlovia.gii__ProductReference__c, prGlovia.Id);
        } 
        
        List<ProductRequired> listProductRequiredToInsert = new List<ProductRequired>();
        List<ProductRequired> listProductRequiredToUpdate = new List<ProductRequired>(); 
        
        for(WorkOrder wo : listWo){
            if(wo.ProductsRequired.IsEmpty()){
                continue;
            }
            List<ProductRequired> listNewProdReq = new List<ProductRequired>(); 
            for(ProductRequired pr : wo.ProductsRequired){
                Id product2Id = pr.Product2Id;
                if(mapProd2ProdGlovia.containsKey(product2Id)){
                    Id prodGloviaId = mapProd2ProdGlovia.get(product2Id);
                    if(mapProductGlovia.containsKey(prodGloviaId)){
                        gii__Product2Add__c prodGlovia = mapProductGlovia.get(prodGloviaId);
                        List<gii__Product2Add__c> listChildPrGlovia = prodGlovia.gii__ProductStyleReferences__r;
                        for(gii__Product2Add__c prChildGlovia : listChildPrGlovia ){ 
                            ProductRequired prodReq = new ProductRequired();       
                            prodReq.ParentRecordId = wo.Id;
                            prodReq.Product2Id = prChildGlovia.gii__ProductReference__c;
                            prodReq.QuantityRequired = pr.QuantityRequired; 
                            prodReq.XC_Mode__c = 'Add';
                            prodReq.XC_SerialControlled__c = prChildGlovia.gii__SerialControlled__c;
                            prodReq.XC_Asset__c = pr.XC_Asset__c;
                            prodReq.XC_Concat_AssetId__c = pr.XC_Concat_AssetId__c;
                            prodReq.XC_ConcatenatedWBE__c = pr.XC_ConcatenatedWBE__c; 
                            prodReq.XC_ConcatenatedCostCenter__c = pr.XC_ConcatenatedCostCenter__c;  
                            listNewProdReq.add(prodReq); 
                        }
                    }
                }
            } 
            List<ProductRequired> esistingProdReq = wo.ProductsRequired;
            MergeWrapper wr = mergeProductRequired(esistingProdReq, listNewProdReq); 
            listProductRequiredToInsert.addAll(wr.listProdReqToInsert);
            listProductRequiredToUpdate.addAll(wr.listProdReqToUpdate);
        }
        XC_UTIL_Sobject.insertListRecords(listProductRequiredToInsert);
        XC_UTIL_Sobject.updateListRecords(listProductRequiredToUpdate);
    }
    
    public static MergeWrapper mergeProductRequired(List<ProductRequired> esistingProdReq, List<ProductRequired> listNewProdReq) {
        List<ProductRequired> listProdReqToInsert = new List<ProductRequired>();
        List<ProductRequired> listProdReqToUpdate = new List<ProductRequired>();
        // Create map WOId+ProdId -> List Product Required:
        Map<String, ProductRequired> mapExistingProdReq = new Map<String, ProductRequired>();
        Map<String, ProductRequired> mapNewProdReq = new Map<String, ProductRequired>();
        for(ProductRequired pr : esistingProdReq) { 
            mapExistingProdReq.put(pr.Product2Id, pr); 
        } 
        for(ProductRequired pr : listNewProdReq) { 
            mapNewProdReq.put(pr.Product2Id, pr);
        }
        // Merge product required for key:
        for(String key : mapNewProdReq.keySet()) {
            ProductRequired newPr = mapNewProdReq.get(key);
            if(!mapExistingProdReq.containsKey(key)){
                listProdReqToInsert.add(newPr);
            } else { 
                ProductRequired prToEdit = mapExistingProdReq.get(key);
                prToEdit.QuantityRequired += newPr.QuantityRequired ;
                prToEdit.XC_Concat_AssetId__c += ';' + newPr.XC_Concat_AssetId__c;
                prToEdit.XC_ConcatenatedWBE__c += ';' + newPr.XC_ConcatenatedWBE__c;
                prToEdit.XC_ConcatenatedCostCenter__c += ';' + newPr.XC_ConcatenatedCostCenter__c;
                listProdReqToUpdate.add(prToEdit);
            } 
        }
        MergeWrapper wr = new MergeWrapper();
        wr.listProdReqToInsert = listProdReqToInsert;
        wr.listProdReqToUpdate = listProdReqToUpdate;
        return wr;
    }
    
    public class MergeWrapper{
        List<ProductRequired> listProdReqToInsert = new List<ProductRequired>();
        List<ProductRequired> listProdReqToUpdate = new List<ProductRequired>();
    } 
}