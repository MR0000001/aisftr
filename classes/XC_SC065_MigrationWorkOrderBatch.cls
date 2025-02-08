/**
* @author Danilo Ortolani - dortolani@deloitte.it
* @date Creation 01/02/2021
* @description XC_SC065_MigrationWorkOrderBatch – Batch to create work order
*/ 
public without sharing class XC_SC065_MigrationWorkOrderBatch implements Database.Batchable<Sobject> {


    //private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC065_MigrationWorkOrderBatch');

    private List<Id> recordIds;
    
    public XC_SC065_MigrationWorkOrderBatch(List<Id> recordIds){
        this.recordIds = recordIds;
    }

    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        //XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_SC065_MigrationWorkOrderBatch.start');
    
        String query = 'SELECT Id, XC_Product_Type__c, XC_Product_SubType__c, Status, NE__Order_Config__c, NE__Bundle__c, NE__Root_Order_Item__c, NE__Bundle_Configuration__c, AccountId,'
                                   +' ContactId, Country__c, XC_LegalEntity__c, XC_Segment__c FROM Asset WHERE XC_Product_Type__c IN (\'Equipment\', \'Service\')';
        if(recordIds != null && !recordIds.isEmpty())
            query+=' AND Id IN :recordIds';

        System.Debug('>>> XC_SC065_MigrationWorkOrderBatch - query: '+query);
        return Database.getQueryLocator(query);
    }


    public void execute(Database.BatchableContext bc, List<Asset> scope) {

        //XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_SC065_MigrationWorkOrderBatch.execute');    
        Map<Id, String> mapId2Error = createWOFromAsset(null, scope);
        if(!mapId2Error.isEmpty())
            System.debug('ASSETS WITH ERRORS: '+JSON.serializePretty(mapId2Error));
     
    }

    public void finish(Database.BatchableContext bc) {
        //XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_SC065_MigrationWorkOrderBatch.finish');
    }
    
    
    
    public static Map<Id, String> createWOFromAsset(Id recordId, List<Asset> assts){
        Map<Id, String> mapId2Error = new Map<Id, String>();
        if(assts == null) assts = [SELECT Id, XC_Product_Type__c, XC_Product_SubType__c, Status, NE__Order_Config__c, NE__Bundle__c, NE__Root_Order_Item__c, NE__Bundle_Configuration__c, AccountId,
                                   ContactId, Country__c, XC_LegalEntity__c, XC_Segment__c, XC_Address__c FROM Asset WHERE Id =: recordId LIMIT 1];
        List<Asset> eqpmntAssts = new List<Asset>();
        List<Asset> serviceAssts = new List<Asset>();
        for(Asset asst: assts){
            if(asst.Status != 'Active'){ 
                mapId2Error.put(asst.Id, 'The asset is not active');
                continue;
            }
            switch on asst.XC_Product_Type__c{
                when 'Equipment' {
                    eqpmntAssts.add(asst);
                } when 'Service'{
                    serviceAssts.add(asst);
                }
            }
        }
        
        List<WorkOrder> wo2Insert = new List<WorkOrder>();
        
        //SERVICE ASSETS
        if(!serviceAssts.isEmpty()){
            Set<Id> serviceAsstsIds = new Set<Id>();
            for(Asset sa: serviceAssts)
                serviceAsstsIds.add(sa.Id);
            Map<Id, List<Asset>> mapChild2Father = new Map<Id, List<Asset>>();
            for(Asset ca: 
               [SELECT Id, XC_Product_Type__c, XC_Product_SubType__c, Status, NE__ProdID__c, NE__Root_Order_Item__c FROM Asset WHERE NE__Root_Order_Item__c IN :serviceAsstsIds AND Status = 'Active' AND XC_Product_Type__c = 'Coverage' AND XC_Product_SubType__c = 'Maintenance']){
                if(!mapChild2Father.containsKey(ca.NE__Root_Order_Item__c))
                    mapChild2Father.put(ca.NE__Root_Order_Item__c, new List<Asset>());   
                mapChild2Father.get(ca.NE__Root_Order_Item__c).add(ca);
            }

            
            Map<Id, List<WorkOrder>> mapSA2WO = new  Map<Id, List<WorkOrder>>();
            for(WorkOrder wo: 
                [SELECT Id, AssetId, XC_WorkTypeCategory__c, Status FROM WorkOrder WHERE AssetId IN :serviceAsstsIds AND 
                 				((XC_WorkTypeCategory__c = 'Diagnostic' AND (Status = 'Canceled' OR Status = 'Cannot Complete')) 
                                 	OR (XC_WorkTypeCategory__c = 'Planned Maintenance' AND XC_DueDate__c > :System.today()))]){
                if(!mapSA2WO.containsKey(wo.AssetId))
                    mapSA2WO.put(wo.AssetId, new List<WorkOrder>());   
                mapSA2WO.get(wo.AssetId).add(wo);
            }
            
            for(Integer i = serviceAssts.size() - 1; i >= 0; i--) {
                if(!mapChild2Father.containsKey(serviceAssts[i].Id)){
                    mapId2Error.put(serviceAssts[i].Id, 'There is no active coverage maintenance');
                    serviceAssts.remove(i);       
                }
                else if(mapSA2WO.containsKey(serviceAssts[i].Id)){
                    mapId2Error.put(serviceAssts[i].Id, 'There is a canceled diagnostic work order or a planned maintenance work order is already present');
                    serviceAssts.remove(i);         
                }
                else if(serviceAssts[i].XC_Product_SubType__c == null || serviceAssts[i] == null || serviceAssts[i].AccountId == null || serviceAssts[i].ContactId == null || serviceAssts[i].Country__c == null
                        || serviceAssts[i].XC_LegalEntity__c == null || serviceAssts[i].XC_Segment__c == null || serviceAssts[i].XC_Address__c == null ){
                            mapId2Error.put(serviceAssts[i].Id, 'Some required asset field is not properly filled (Product Subtype, AccountId, ContactId, Country, Legal Entity, Segment, Address)');
                            serviceAssts.remove(i);
                        }
            }
            
            for(Asset okAsst: serviceAssts)
                wo2Insert.add(new WorkOrder(XC_CreatedAutomaticallyBySystem__c=true, XC_ProductSubType__c=okAsst.XC_Product_SubType__c, XC_WorkTypeCategory__c='Planned Maintenance',
                                           AccountId=okAsst.AccountId, AssetId=okAsst.Id, ContactId=okAsst.ContactId, XC_Country__c=okAsst.Country__c, XC_CreateMaintenanceServiceAppointment__c=true, 
                                           XC_LegalEntity__c=okAsst.XC_LegalEntity__c, XC_Segment__c=okAsst.XC_Segment__c, XC_Address__c=okAsst.XC_Address__c));
            
            
        }
        
        //EQUIPEMENT ASSETS
        if(!eqpmntAssts.isEmpty()){
            Set<Id> eqpmntAsstsIds = new Set<Id>();
            Set<Id> eqpmntBundleIds = new Set<Id>();
            Map<Id,Asset> eqpmntMap = new Map<Id,Asset>();
            for(Asset ea: eqpmntAssts) {
                eqpmntAsstsIds.add(ea.Id);
                eqpmntBundleIds.add(ea.NE__Bundle_Configuration__c);
                eqpmntMap.put(ea.Id,ea);
            }
            Map<Id, List<Asset>> mapBrothers2Father = new Map<Id, List<Asset>>();
            Map<Id, List<Asset>> mapprodId2Brothers = new Map<Id, List<Asset>>();

            Set<Id> prodIds = new Set<Id>();
            Map<Id,Id> brothOrigMap = new Map<Id,Id>(); // AssetID (equipment) , AssetID (coverage)
            for(Asset ba:
                [SELECT Id, XC_Product_Type__c, XC_Product_SubType__c, Status, NE__ProdID__c, NE__Bundle_Configuration__c FROM Asset WHERE NE__Bundle_Configuration__c IN :eqpmntBundleIds AND Status = 'Active' AND XC_Product_Type__c = 'Coverage' AND XC_Product_SubType__c = 'Maintenance']){
                if(!mapBrothers2Father.containsKey(ba.NE__Bundle_Configuration__c))
                    mapBrothers2Father.put(ba.NE__Bundle_Configuration__c, new List<Asset>());   
                mapBrothers2Father.get(ba.NE__Bundle_Configuration__c).add(ba);
                if(!mapprodId2Brothers.containsKey(ba.NE__ProdID__c))
                    mapprodId2Brothers.put(ba.NE__ProdID__c, new List<Asset>());   
                mapprodId2Brothers.get(ba.NE__ProdID__c).add(ba);
                prodIds.add(ba.NE__ProdID__c);
                for (Asset bundleMapAsset: eqpmntMap.values()) {
                    if ( bundleMapAsset.NE__Bundle_Configuration__c == ba.NE__Bundle_Configuration__c ) {
                        brothOrigMap.put(bundleMapAsset.Id,ba.Id);
                    }
                }
                
            }
            
            Map<Id, List<NE__DocumentationCharacterist__c>> mapProd2DC = new Map<Id, List<NE__DocumentationCharacterist__c>>();
            for(NE__DocumentationCharacterist__c dc: 
                [SELECT Id, NE__Product__c, NE__Value__c FROM NE__DocumentationCharacterist__c WHERE NE__Product__c IN :prodIds AND Name = 'Coverage Type']){
                    if(!mapProd2DC.containsKey(dc.NE__Product__c))
                        mapProd2DC.put(dc.NE__Product__c, new List<NE__DocumentationCharacterist__c>());   
                    mapProd2DC.get(dc.NE__Product__c).add(dc);
                }
            
            Set<Id> toNotRemove = new Set<Id>();
            for(Id neProd: mapProd2DC.keySet()){
                if(mapprodId2Brothers.containsKey(neProd)){
                    for(Asset broth: mapprodId2Brothers.get(neProd)){
                        for(NE__DocumentationCharacterist__c dc: mapProd2DC.get(neProd)){

                            for(Id orAssetId: brothOrigMap.keySet()) {
                                if ( brothOrigMap.get(orAssetId) == broth.id ) {
                                    if(eqpmntMap.containsKey(orAssetId)){
                                        if ( dc.NE__Value__c.contains(eqpmntMap.get(orAssetId).XC_Product_SubType__c) ) {
                                            toNotRemove.add(orAssetId);
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                } 
            }
            
            Map<Id, List<WorkOrder>> mapSA2WO = new  Map<Id, List<WorkOrder>>();
            for(WorkOrder wo: 
                [SELECT Id, AssetId, XC_WorkTypeCategory__c, Status FROM WorkOrder WHERE AssetId IN :eqpmntAsstsIds AND 
                 (XC_WorkTypeCategory__c = 'Planned Maintenance' AND XC_DueDate__c > :System.today())]){
                     if(!mapSA2WO.containsKey(wo.AssetId))
                         mapSA2WO.put(wo.AssetId, new List<WorkOrder>());   
                     mapSA2WO.get(wo.AssetId).add(wo);
                 }
            
            for(Integer i = eqpmntAssts.size() - 1; i >= 0; i--) {
                if(!mapBrothers2Father.containsKey(eqpmntAssts[i].NE__Bundle_Configuration__c)){
                    mapId2Error.put(eqpmntAssts[i].Id, 'There is no active coverage maintenance');
                    eqpmntAssts.remove(i);
                }
                else if(!toNotRemove.contains(eqpmntAssts[i].Id)){
                    mapId2Error.put(eqpmntAssts[i].Id, 'There is no active coverage maintenance for this kind of product');
                    eqpmntAssts.remove(i);
                }
                else if(mapSA2WO.containsKey(eqpmntAssts[i].Id)){
                    mapId2Error.put(eqpmntAssts[i].Id, 'A planned maintenance work order is already present');
                    eqpmntAssts.remove(i); 
                }
                else if(eqpmntAssts[i].XC_Product_SubType__c == null || eqpmntAssts[i] == null || eqpmntAssts[i].AccountId == null || eqpmntAssts[i].ContactId == null || eqpmntAssts[i].Country__c == null
                        || eqpmntAssts[i].XC_LegalEntity__c == null || eqpmntAssts[i].XC_Segment__c == null || eqpmntAssts[i].XC_Address__c == null){
                            mapId2Error.put(eqpmntAssts[i].Id, 'Some required asset field is not properly filled (Product Subtype, AccountId, ContactId, Country, Legal Entity, Segment, Address)');                        
                            eqpmntAssts.remove(i);
                        }
            }
            
            for(Asset okAsst: eqpmntAssts)
                wo2Insert.add(new WorkOrder(XC_CreatedAutomaticallyBySystem__c=true, XC_ProductSubType__c=okAsst.XC_Product_SubType__c, XC_WorkTypeCategory__c='Planned Maintenance',
                                           AccountId=okAsst.AccountId, AssetId=okAsst.Id, ContactId=okAsst.ContactId, XC_Country__c=okAsst.Country__c, XC_CreateMaintenanceServiceAppointment__c=true, 
                                           XC_LegalEntity__c=okAsst.XC_LegalEntity__c, XC_Segment__c=okAsst.XC_Segment__c, XC_Address__c=okAsst.XC_Address__c));
            
            
        }
        
        if(!wo2Insert.isEmpty())
            insert wo2Insert;
        
        return mapId2Error;
    }

}