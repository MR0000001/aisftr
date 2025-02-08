public without sharing class XC_TR_ECA_U {
    
    public static boolean skipTrigger(List<B2WExtCat__External_Catalog_Association__c> listNew){
        
        boolean skipTriggerCond = false;
        for(B2WExtCat__External_Catalog_Association__c eca: listNew){
            
            if (eca.migrationTool__c == false){
                
                skipTriggerCond = true;
                
            }
            
        }
        
        return skipTriggerCond;
        
    }
    
    public static void setSourceCommercialCatalogItemId(List<B2WExtCat__External_Catalog_Association__c> listNew){
        
        List<String> CIs = new List<String>();
        
        for(Integer i=0;i<listNew.size();i++){
        
            CIs.add(listNew[i].Id);
        
        }
        
       	List<NE__Catalog_Item__c> ci = [SELECT id, NE__Id__c FROM NE__Catalog_Item__c WHERE Id IN:CIs];
        for(Integer i=0; i<listNew.size(); i++){
            for(Integer j=0; j<ci.size(); j++){
                if(listNew[i].B2WExtCat__Commercial_Catalog_Item__c == ci[j].Id){
                    listNew[i].SourceCommercialCatalogItemId__c = ci[j].NE__Id__c;
                }
            	
            }
        }
        
    }
    
    
        
    public static void manageFields(List<B2WExtCat__External_Catalog_Association__c> listNew){
    
    	List<String> legacyECIs = new List<String>();
        for(Integer i=0;i<listNew.size();i++){
        
            legacyECIs.add(listNew[i].legacyECI__c);
        
        }
        
        List<String> legacyCIs = new List<String>();
        for(Integer i=0;i<listNew.size();i++){
        
            legacyCIs.add(listNew[i].SourceCommercialCatalogItemId__c);
        
        }
        
       	List<B2WExtCat__External_Catalog_Item__c> ecis = [SELECT Id,B2WExtCat__Source_External_Catalog_Item__c FROM B2WExtCat__External_Catalog_Item__c WHERE B2WExtCat__Source_External_Catalog_Item__c IN: legacyECIs];
        List<NE__Catalog_Item__c> cis = [SELECT Id,NE__Id__c FROM NE__Catalog_Item__c WHERE NE__Id__c IN: legacyCIs];

        for(Integer i=0; i<listNew.size(); i++){
            
            for(B2WExtCat__External_Catalog_Item__c eci: ecis){
                
                if(listNew[i].legacyECI__c == eci.B2WExtCat__Source_External_Catalog_Item__c){
                    
                    listNew[i].B2WExtCat__External_Catalog_Item__c = eci.Id;
                    
                    
                }
                
            }
            for(NE__Catalog_Item__c ci: cis){
                
                if(listNew[i].SourceCommercialCatalogItemId__c == ci.NE__Id__c){
                    
                    listNew[i].B2WExtCat__Commercial_Catalog_Item__c = ci.Id;
                    
                }
                
            }
            
        }
        
        
    }
    
}