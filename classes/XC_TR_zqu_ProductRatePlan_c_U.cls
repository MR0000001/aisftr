public class XC_TR_zqu_ProductRatePlan_c_U {


    
    public static boolean skipTrigger(List<zqu__ProductRatePlan__c> listNew){
        
        //se c'è almeno un record con migrationTool__c=false il trigger non fa nulla
        boolean skipTriggerCond = false;
        for(zqu__ProductRatePlan__c prp: listNew){
            
            if (prp.migrationTool__c == false){
                
                skipTriggerCond = true;
                
            }
            
        }
        
        return skipTriggerCond;
        
    }
    
    public static void manageFields(List<zqu__ProductRatePlan__c> listNew){
        
        
        //costruisco la lista di id di prodotti a cui dovranno essere collegati i rate plan
        //evitando di fare un SELECT di tutti i prodotti
        List<String> legacyIds = new List<String>();
        for(Integer i=0;i<listNew.size();i++){
        
            legacyIds.add(listNew[i].legacyProductId__c);
        	System.debug('inserted' + listNew[i].legacyProductId__c);
        }
        //tutti i Product che mi interessano    
        List<Product2> products = [SELECT id, legacyId__c,migrationTool__c FROM Product2 WHERE legacyId__c IN: legacyIds AND IsActive = true];
        System.debug('products size' + products.size());
        
        //costruisco la lista di id di prodotti per prendermi solo gli zProduct creati 
        List<String> zProductsList = new List<String>();
        for(Integer i=0;i<products.size();i++){
        
            zProductsList.add(products[i].id);
        
        }
        List<zqu__zproduct__c> zproducts = [SELECT id, zqu__Product__C FROM zqu__zproduct__c WHERE zqu__Product__C IN:zProductsList];
        
      
        //scorro la lista dei ProductRatePlan da inserire
        for(Integer i=0; i<listNew.size(); i++){
            
            listNew[i].migrationTool__c = false;
            listNew[i].id = null;
            listNew[i].zqU__CATALOG_SYNC_HISTORY__C = null;
            listNew[i].ZQU__SYNCMESSAGE__C = null;
            listNew[i].ZQU__SYNCSTATUS__C = null;
            listNew[i].ZQU__ZUORAID__C = null;

            
            
            for(Product2 p: products){
                //cerco tra tutti i prodotti quello che nella vecchia entity era collegato a questo rate plan     
                if(listNew[i].legacyProductId__c == p.legacyId__c){
                    
                    //setto a false il campo migrateTool sia sul RP che sto inserendo che sul prodotto a sistema
                    listNew[i].migrationTool__c = false;
                    
                    System.debug('legacyProductId__c: '+ listNew[i].legacyProductId__c+'\nlegacyId__c: '+ p.legacyId__c);
                    System.debug('Metto in listNew[i].zqu__Product__c l_id: ' + p.id);
                    listNew[i].zqu__Product__c = p.id;
                    
                    
                    //associo al ProductRatePlan lo zProduct legato al Product
                    for(zqu__zproduct__c zp: zproducts){
                        
                        if(zp.zqu__Product__c == p.id){
                            
                            System.debug('if '+ zp.zqu__Product__c +' == '+ p.id);
                            System.debug('Metto in listNew[i].zqu__ZProduct__c l_id: ' + zp.id);
                            listNew[i].zqu__ZProduct__c = zp.id;
                            
                        }
                        
                    }
                    
                }
                
            }
        }
        
    }
    
    
    
}