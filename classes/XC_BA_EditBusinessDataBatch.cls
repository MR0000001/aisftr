global class XC_BA_EditBusinessDataBatch implements  Database.Batchable<sObject>, Database.Stateful{
    public static final string NETWORK = 'Network';
    public  Database.QueryLocator start(Database.BatchableContext BC){
        String query;  
       // query = 'select Account.Name,XC_Address__r.XC_AddressProvince__c,TAM_PartnerContract__r.XC_ContractSAP__c,Name,TAM_AvailablePhone__c,TAM_AvailableEmail__c,XC_ChangeDate__c,XC_NewTAMPartnerContract__c,XC_NewTAMAvailablePhone__c,XC_NewTAMAvailableEmail__c from Asset where RecordType.Name =:NETWORK AND XC_ChangeDate__c = TODAY limit 50000';
        query = 'Select Id,XC_Asset__c,XC_NewTAMPartnerContract__c,XC_NewTAMAvailablePhone__c,XC_NewTAMAvailableEmail__c,XC_ChangeDate__c from AssetExt__c WHERE XC_ChangeDate__c = TODAY';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<AssetExt__c> assetExtList){
        Set<String> assetSet = new Set<String>();
        Set<String> contractSet = new Set<String>();
        
        for(AssetExt__c eachAssetExt : assetExtList){
            String contract = eachAssetExt?.XC_NewTAMPartnerContract__c;
            String asset = eachAssetExt?.XC_Asset__c;
            if(contract != null){
                contractSet.add(contract);
            } 
            if(asset != null){
                assetSet.add(asset);
            }
         
        }
        List<Contract> contractList = [Select Id, AccountId from Contract WHERE Id IN :contractSet]; 
      //  List<AssetExt__c> assetExtList = [Select Id,XC_Asset__c,XC_NewAssetServicedById__c,XC_NewTAMPartnerContract__c,XC_NewTAMAvailablePhone__c,XC_NewTAMAvailableEmail__c,XC_ChangeDate__c from AssetExt__c WHERE XC_ChangeDate__c = TODAY AND XC_Asset__c IN :assetExtSet ]; 
        List<Asset> assetList = [Select AssetServicedById,Account.Name,XC_Address__r.XC_AddressProvince__c,TAM_PartnerContract__r.XC_ContractSAP__c,TAM_PartnerContract__r.AccountId,Name,TAM_AvailablePhone__c,TAM_AvailableEmail__c from Asset where id IN :assetSet];
        Map<Id,Id> conAccMap = new Map<Id,Id>();
        for(Contract eachCon : contractList){
            conAccMap.put(eachCon.id,eachCon.AccountId);
        }
        Map<Id,AssetExt__c> assExtMap = new Map<Id,AssetExt__c>();
        for(AssetExt__c eachassExt : assetExtList){
            assExtMap.put(eachassExt.XC_Asset__c,eachassExt);
        }
        List<AssetExt__c> assetExttoUpdate = new List<AssetExt__c>();
        for(asset eachAsset : assetList){
            String contract = assExtMap.get(eachAsset.Id)?.XC_NewTAMPartnerContract__c;
            if(String.isNotEmpty(assExtMap.get(eachAsset.Id).XC_NewTAMPartnerContract__c)){
                eachAsset.TAM_PartnerContract__c = assExtMap.get(eachAsset.Id).XC_NewTAMPartnerContract__c;
                assExtMap.get(eachAsset.Id).XC_NewTAMPartnerContract__c = null;
                if(contract != null){
                    eachAsset.AssetServicedById  = conAccMap.get(Id.valueOf(contract));
                } 
            }
            //[START R1.2 CR762 15.07.2022 vaibhav.c.anand@accenture.com]
            if(String.isEmpty(assExtMap.get(eachAsset.Id).XC_NewTAMPartnerContract__c) && String.isEmpty(eachAsset.AssetServicedById)){
                 eachAsset.AssetServicedById = eachAsset.TAM_PartnerContract__r.AccountId ;
            }
            //[END R1.2 CR762 15.07.2022 vaibhav.c.anand@accenture.com]
            if(String.isNotEmpty(assExtMap.get(eachAsset.Id).XC_NewTAMAvailablePhone__c)){
                eachAsset.TAM_AvailablePhone__c = assExtMap.get(eachAsset.Id).XC_NewTAMAvailablePhone__c;
                assExtMap.get(eachAsset.Id).XC_NewTAMAvailablePhone__c = null;
            }
            if(String.isNotEmpty(assExtMap.get(eachAsset.Id).XC_NewTAMAvailableEmail__c)){
                eachAsset.TAM_AvailableEmail__c = assExtMap.get(eachAsset.Id).XC_NewTAMAvailableEmail__c;
                assExtMap.get(eachAsset.Id).XC_NewTAMAvailableEmail__c = null;
            }  
            //[START CR753 19.07.2022 sooraji.sajan@accenture.com]
            if(String.isNotEmpty(assExtMap.get(eachAsset.Id).XC_Asset__c)){
              assExtMap.get(eachAsset.Id).XC_Asset__c = null;
            }
            //[END CR753 19.07.2022 sooraji.sajan@accenture.com] 
            assExtMap.get(eachAsset.Id).XC_ChangeDate__c = null;
            assetExttoUpdate.add(assExtMap.get(eachAsset.Id));
            System.debug('assetExttoUpdate '+assetExttoUpdate);
        }
        
        try{
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            Database.update(assetList,true); 
            Database.update(assetExttoUpdate,true);
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
            
        }
        catch(Exception e){}
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    
}