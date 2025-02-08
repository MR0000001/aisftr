public without sharing class XC_TR_ECI_U {
    
    public static boolean skipTrigger(List<B2WExtCat__External_Catalog_Item__c> listNew){
        
        boolean skipTriggerCond = false;
        for(B2WExtCat__External_Catalog_Item__c eci: listNew){
            
            if (eci.migrationTool__c == false){
                
                skipTriggerCond = true;
                
            }
            
        }
        
        return skipTriggerCond;
        
    }
    
    public static void createJunction(Map<Id, SObject> mapNewSO){
        
        List<B2WExtCat__External_Catalog_Item__c> listNew = new List<B2WExtCat__External_Catalog_Item__c>();
        listNew = [SELECT Id,B2WExtCat__External_Catalog_Item_Name__c,B2WExtCat__External_Catalog_Item_Code__c FROM B2WExtCat__External_Catalog_Item__c WHERE Id IN: mapNewSO.keySet()];
        
        List<B2WZC__ECI_RatePlan_Junction__c> toInsert = new List<B2WZC__ECI_RatePlan_Junction__c>();
             
        
        for(Integer i=0; i<listNew.size(); i++){
            
            B2WZC__ECI_RatePlan_Junction__c junc = new B2WZC__ECI_RatePlan_Junction__c();
            
            junc.B2WZC__Name__c = listNew[i].B2WExtCat__External_Catalog_Item_Name__c + '-RatePlan';
            junc.B2WZC__ValueRatePlane__c = '8.0';
            junc.B2WZC__EciId__c = listNew[i].Id;
            junc.B2WZC__IdRatePlan__c = listNew[i].B2WExtCat__External_Catalog_Item_Code__c;
            toInsert.add(junc);
        }
        
        insert toInsert;
        
    }
    
        
    public static void manageFields(List<B2WExtCat__External_Catalog_Item__c> listNew){
        
		Id externalCatalogId = [SELECT Id FROM B2WExtCat__External_Catalog__c WHERE B2WExtCat__External_Catalog_Name__c = 'Billing Catalog'][0].Id;
		
        map<String, Id> recordTypes = new map<String, Id>();
        recordTypes.put('Standard',Schema.SObjectType.B2WExtCat__External_Catalog_Item__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId());
		recordTypes.put('ZuoraOneTime',Schema.SObjectType.B2WExtCat__External_Catalog_Item__c.getRecordTypeInfosByName().get('ZuoraOne-Time').getRecordTypeId());
		recordTypes.put('ZuoraRecurring',Schema.SObjectType.B2WExtCat__External_Catalog_Item__c.getRecordTypeInfosByName().get('ZuoraRecurring').getRecordTypeId());
		recordTypes.put('ZuoraUsage',Schema.SObjectType.B2WExtCat__External_Catalog_Item__c.getRecordTypeInfosByName().get('ZuoraUsage').getRecordTypeId());

    	List<String> legacyCodes = new List<String>();
        for(Integer i=0;i<listNew.size();i++){
        
            legacyCodes.add(listNew[i].legacyCode__c);
        
        }
        
    	//tutti i ProductRatePlan che mi interessano   
        List<zqu__ProductRatePlan__c> productRatePlans = [SELECT id, legacyId__c,zqu__Product__c FROM zqu__ProductRatePlan__c WHERE legacyId__c IN:legacyCodes];
        
        //scorro la lista degli ECI da inserire
    	for(Integer i=0; i<listNew.size(); i++){
        
            for(zqu__ProductRatePlan__c prp: productRatePlans){
                //cerco tra tutti i ProductRatePlan quello da collegare all'eci
                if(listNew[i].legacyCode__c == prp.legacyId__c){
                    //collego il RP all'ECI
                    listNew[i].B2WExtCat__External_Catalog_Item_Code__c = prp.id;
                    
                    //setto il recordType
                    System.debug('Provo a settare il recordType a' + String.valueof(listNew[i].RecordTypeName__c));
                    System.debug(recordTypes);
                    listNew[i].RecordTypeId = recordTypes.get(String.valueof(listNew[i].RecordTypeName__c));
                    //setto il riferimento all'ExternalCatalog EC-0000000
					listNew[i].B2WExtCat__External_Catalog__c = externalCatalogId;
                    
                }
                
            }
            
        }
    
    
    }
    
}