public class XC_TR_zqu_ProductRatePlanCharge_U {

    public static boolean skipTrigger(List<zqu__ProductRatePlanCharge__c> listNew){
        
        boolean skipTriggerCond = false;

        for(zqu__ProductRatePlanCharge__c prpc: listNew){
            
            if (prpc.migrationTool__c == false){
                
                skipTriggerCond = true;
                
            }
            
        }
        
        return skipTriggerCond;
        
    }
    
    public static void manageFields(List<zqu__ProductRatePlanCharge__c> listNew){
        
        
        
        List<String> legacyIds = new List<String>();
        for(Integer i=0;i<listNew.size();i++){
        
            legacyIds.add(listNew[i].legacyProductRatePlanId__c);
        
        }
        
    	//tutti i ProductRatePlan che mi interessano   
        List<zqu__ProductRatePlan__c> productRatePlans = [SELECT id, legacyId__c,zqu__Product__c FROM zqu__ProductRatePlan__c WHERE legacyId__c IN:legacyIds];
        
        List<String> productsIds = new List<String>();
        for(Integer i=0;i<productRatePlans.size();i++){
            
            productsIds.add(productRatePlans[i].zqu__Product__c);
            
        }
        
        //i prodotti a cui sono collegati i RatePlan
        List<Product2> products = [SELECT id, zqu__BillingEntity__c FROM Product2 WHERE id IN:productsIds];
        
        //lista di unità di misura
        List<zqu__ZUnitOfMeasure__c> UOMs = [SELECT id, Name, zqu__BillingEntity__c FROM zqu__ZUnitOfMeasure__c];  
        
      
        //scorro la lista dei ProductRatePlanCharge da inserire
        for(Integer i=0; i<listNew.size(); i++){
            
            listNew[i].migrationTool__c = false;
            listNew[i].id = null;
            listNew[i].zqU__CATALOG_SYNC_HISTORY__C = null;
            listNew[i].ZQU__SYNCMESSAGE__C = null;
            listNew[i].ZQU__SYNCSTATUS__C = null;
            listNew[i].ZQU__ZUORAID__C = null;
            
			
            for(zqu__ProductRatePlan__c prp: productRatePlans){
            	//cerco tra tutti i prodotti quelli     
                if(listNew[i].legacyProductRatePlanId__c == prp.legacyId__c){
                    
                    //System.debug('legacyProductId__c: '+ listNew[i].legacyProductRatePlanId__c+'\nlegacyId__c: '+ prp.legacyId__c);
                    //System.debug('Metto in listNew[i].zqu__ProductRatePlan__c l_id: ' + prp.id);
                    
                    
                    //collego il RPC al RP
                    listNew[i].zqu__ProductRatePlan__c = prp.id;
                    
                    //inserisco la UOM se c'è (per i charge Usage)
                    //i charge usage hanno il campo zqu__UOM__c (text) valorizzato
                    if(listNew[i].zqu__UOM__c != '' || listNew[i].zqu__UOM__c != null || listNew[i].zqu__UOM__c != ' '){
                        
                        for(zqu__ZUnitOfMeasure__c iUOM: UOMs){
                            
                            if(iUOM.Name ==  listNew[i].zqu__UOM__c){
                                
                                for(Product2 ip : products){
                                    
                                    if(prp.zqu__Product__c == ip.id){
                                        
                                        if(ip.zqu__BillingEntity__c == iUOM.zqu__BillingEntity__c){
                                            
                                            listNew[i].zqu__ZUnitOfMeasure__c = iUOM.Id;
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                    

                    
                }
                
            }
    	}

        
    }
    
}