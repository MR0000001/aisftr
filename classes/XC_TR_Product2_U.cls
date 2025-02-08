public without sharing class XC_TR_Product2_U {

    public static boolean skipTrigger(List<Product2> listNew){
        
        boolean skipTriggerCond = false;
        for(Product2 p: listNew){
            
            if (p.migrationTool__c == false){
                
                skipTriggerCond = true;
                
            }
            
        }
        
        return skipTriggerCond;
        
    }
    
    public static void manageFields(List<Product2> listNew){
        
    	for(Integer i=0;i<listNew.size();i++){
            
            //setto di nuovo a false il valore del campo e sbianco i campi che non mi servono
            listNew[i].migrationTool__c = false;
            
            //sbianco i campi del prodotto che non mi servono
            listNew[i].id = null;
            listNew[i].zqu__CATALOG_SYNC_HISTORY__C = null;
            listNew[i].zqu__SKU2__C = null;
            listNew[i].zqu__SYNCMESSAGE__C = null;
            listNew[i].zqu__SYNCSTATUS__C = null;
            listNew[i].zqu__ZUORAID__C = null;

        }
        
    }
    
}