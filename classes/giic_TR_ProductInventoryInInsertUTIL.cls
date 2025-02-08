/**
 * @author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com
 * @date Creation 25/11/2019
 * @date Modification dd/mm/yyyy
 * @description giic_TR_ProductInventoryInInsertUTIL -  class to set Account on PI
 */
public without sharing class giic_TR_ProductInventoryInInsertUTIL {
    
    
    public static void setAccountAndMailOnPI(List<gii__ProductInventory__c> listNew){
        List<String> wareHouseIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'gii__Warehouse__c');
        System.debug('wareHouseIds = '+wareHouseIds);
        map<Id,gii__Warehouse__c> waMaps = new  map<Id,gii__Warehouse__c> ([SELECT Id, gii__Account__c,gii__Account__r.PrimaryEmail__c FROM gii__Warehouse__c WHERE Id IN: wareHouseIds ]);
        System.debug('waMaps = '+waMaps.values());
        for(gii__ProductInventory__c p : listNew){
             for(gii__Warehouse__c w : waMaps.values()){
                 if(p.gii__Warehouse__c == w.Id && w.gii__Account__c!=null){
            		p.giic_AccountId__c = w.gii__Account__c;
                    p.giic_EmailAddress__c = w.gii__Account__r.PrimaryEmail__c;
                  
                 }
             }
            
        }
        
    }
    
    public static void setExtIdOnPI(List<gii__ProductInventory__c> listNew){
        for(gii__ProductInventory__c p : listNew){   
        	p.giic_ExternalID__c = p.gii__Product__c+' '+p.gii__Warehouse__c;
        }
        
    }
    
     public static void setLEOnPI(List<gii__ProductInventory__c> listNew){
        List<String> productIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'gii__Product__c');
        map<Id,gii__Product2Add__c> p2Maps = new  map<Id,gii__Product2Add__c> ([SELECT Id, gii__ProductReference__c,gii__ProductReference__r.giic_LegalEntity__c FROM gii__Product2Add__c WHERE Id IN: productIds ]);
        System.debug('p2Maps = '+p2Maps.values());
        for(gii__ProductInventory__c p : listNew){   
             for(gii__Product2Add__c w : p2Maps.values()){
                 if(p.gii__Product__c == w.Id && w.gii__ProductReference__c != null){
                    	p.giic_LegalEntity__c = w.gii__ProductReference__r.giic_LegalEntity__c;
                 }
             }
            
        }
        
    }
    
    
    
    public static void setCorrectAccountMailOnPOR(List<gii__PurchaseOrderReceipt__c> listNew){
        List<String> poIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'gii__PurchaseOrder__c');
        
        map<Id,gii__PurchaseOrder__c> poMaps = new  map<Id,gii__PurchaseOrder__c> ([SELECT Id, giic_AccountForSharing__c,giic_AccountForSharing__r.PrimaryEmail__c FROM gii__PurchaseOrder__c WHERE Id IN: poIds ]);
   
        for(gii__PurchaseOrderReceipt__c p : listNew){
             for(gii__PurchaseOrder__c po : poMaps.values()){
                 if(p.gii__PurchaseOrder__c == po.Id && po.giic_AccountForSharing__c!=null && p.giic_ParentOwnerEmail__c == null){
                    p.giic_ParentOwnerEmail__c = po.giic_AccountForSharing__r.PrimaryEmail__c;
                 }
             }
            
        }
        
    }
    
    
    
      public static void setLEOnPurchaseOrderReceipt(List<gii__PurchaseOrderReceipt__c> listNew){
        List<String> poIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'gii__PurchaseOrder__c');
        map<Id,gii__PurchaseOrder__c> p2Maps = new  map<Id,gii__PurchaseOrder__c> ([SELECT Id, giic_LegalEntity__c FROM gii__PurchaseOrder__c WHERE Id IN: poIds ]);
        System.debug('p2Maps = '+p2Maps.values());
        for(gii__PurchaseOrderReceipt__c por : listNew){   
             for(gii__PurchaseOrder__c w : p2Maps.values()){
                 if(por.gii__PurchaseOrder__c == w.Id && w.giic_LegalEntity__c != null){
                    	por.giic_LegalEntity__c = w.giic_LegalEntity__c;    
                 }
             }
            
        }
        
    }
    
    
    
    

}