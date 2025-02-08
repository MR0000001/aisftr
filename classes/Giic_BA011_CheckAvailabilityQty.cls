public class Giic_BA011_CheckAvailabilityQty implements Database.batchable<Sobject>, Schedulable {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_BA011_CheckAvailabilityQty');
    
    
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        List<XC_CM_CountryTimeZone__mdt> mdtList = [SELECT Country__c, From__c,To__c FROM XC_CM_CountryTimeZone__mdt];
        System.debug('mdtList = '+mdtList);
        
        List<String> CountryList = new List<String>();
        Decimal Hour;
        
        if (Test.isRunningTest()) Hour = 0;
        else Hour = DateTime.Now().hourGmt();
        
        System.debug('Hour = '+Hour);
        
        for(XC_CM_CountryTimeZone__mdt mdt : mdtList){
            if(Hour >= mdt.From__c && Hour < mdt.To__c) CountryList.add(mdt.Country__c);
        }        
        System.debug('CountryList = '+ CountryList);
        
        String query;
        
        
        //query='SELECT Id FROM gii__ProductInventory__c WHERE gii__Warehouse__r.giic_WarehouseType__c = \'Central\' AND gii__Warehouse__r.Main__c = TRUE';
        
        If (CountryList.size() > 0) {      
            query='SELECT Id FROM gii__ProductInventory__c WHERE gii__Warehouse__r.giic_WarehouseType__c = \'Central\' AND gii__Warehouse__r.giic_WareHouseCountryPick__c IN: CountryList AND gii__Warehouse__r.Main__c = TRUE';
        }
        else {
            query='SELECT Id FROM gii__ProductInventory__c WHERE gii__Warehouse__r.giic_WarehouseType__c = \'Central\' AND gii__Warehouse__r.giic_WareHouseCountryPick__c = \'XXXX\' AND gii__Warehouse__r.Main__c = TRUE';
        }
        return Database.getQueryLocator(query);
    } 
    
    public void execute(Database.BatchableContext bc, List<gii__ProductInventory__c> scope){
        
        giic_CheckAvailabilityQty.checkAvailability(scope);
        
    } 
    
    
    
    
    public void execute(SchedulableContext ctx){
        Database.executebatch(new Giic_BA011_CheckAvailabilityQty(), 200);  
    }  
    
    
    public void finish(Database.BatchableContext bc){
        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Finished');
    } 
    
}