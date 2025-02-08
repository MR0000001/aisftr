public with sharing class XC_LCC_EditBusinessData {

   public class Product2ContactLineItemWrapper{
 
     @AuraEnabled
     public String AccountId{get;set;}
 
     @AuraEnabled
     public String Name{get;set;}
     /** @description The record id. */
 
     @AuraEnabled
     public String RecordTypeId{get;set;}
 
     @AuraEnabled
     public String Id{get;set;}
     /** @description The Product2 id. */
 
     @AuraEnabled
     public Account account{get;set;}
 
     /**@AuraEnabled
     public String idProduct{get;set;}
     @AuraEnabled
     public String idGlProduct{get;set;}
     @AuraEnabled
     public String glBookEntryId{get;set;}
 
     @AuraEnabled
     public String workOrderId{get;set;}
 
     @AuraEnabled
     public String productCode{get;set;}
 
     @AuraEnabled
     public String type{get;set;}
 
     @AuraEnabled
     public String prodPrice{get;set;}
       
     @AuraEnabled
     public String isoCode{get;set;}
       
     @AuraEnabled
     public String contractId{get;set;}
     
     @AuraEnabled
     public string country{get;set;}
     
     @AuraEnabled
     public String quantity{get;set;}
      
     @AuraEnabled
     public String rtWoli{get;set;}*/
     
     @AuraEnabled
     public String segment{get;set;}
     
     @AuraEnabled
     public String legalEntity{get;set;}
 
    /* @AuraEnabled
     public String positionName{get;set;}
     @AuraEnabled
     public String positionCode{get;set;}*/
   }
 
   public class Account{
     @AuraEnabled
     public String Name{get;set;}
 
     @AuraEnabled
     public String Id{get;set;}
 
   }
 
   public class assetWrapper{
     @AuraEnabled
     public List<Asset> resultAsset{get;set;}
 
     @AuraEnabled
     public List<AssetExt__c> resultAssetExt{get;set;}
 
   }
 
     
     @AuraEnabled
     public static assetWrapper queryAsset(String recordId,String Contract){
     List<Asset> assetMap = new List<Asset>(
     [select Id, Account.Name, XC_Address__r.XC_AddressProvince__c, TAM_PartnerContract__r.ContractNumber, Name, TAM_AvailablePhone__c, TAM_AvailableEmail__c
     from Asset
     //where RecordType.Name = 'Network']);
     where RecordType.Name = 'Network' AND TAM_PartnerContract__r.XC_ContractSAP__c =: Contract]);
     System.debug('***' +assetMap);
 
     List<Id> assetId = new List<Id>() ;
     for(Asset a : assetMap){
        assetId.add(a.Id);
     }
 
     List<AssetExt__c> assetExtMap = new List<AssetExt__c>(
     [select XC_Asset__c, XC_ChangeDate__c, XC_NewTAMPartnerContract__c,
     XC_NewTAMPartnerContract__r.XC_ContractSAP__c,
     XC_NewTAMAvailablePhone__c, 
     XC_NewTAMAvailableEmail__c
     from AssetExt__c
     where XC_Asset__c =: assetId]);
     System.debug('***' +assetExtMap);   
       
  /*   List<assetWrapper> assetWrapperList = new List<assetWrapper>();
     for(Id a : assetMap.keySet()){
       assetWrapper assetWrap = new assetWrapper();
       assetWrap.resultAsset = assetMap.get(a);
      // assetWrap.resultAssetExt = assetExtMap.get(a);
     } */
     assetWrapper assetWrap = new assetWrapper();
     assetWrap.resultAsset = assetMap ;
     assetWrap.resultAssetExt = assetExtMap ;
 
     return assetWrap;
   }
     @AuraEnabled
     public static Boolean checkContract(String Contract){ 
 
       Contract cont = [select Id, XC_LegalEntity__c from Contract where Id =: Contract];
       if(cont.XC_LegalEntity__c.equals('EnelSole')){
          return true;
       }
       else {
         return false;  
       }
     }
     
     @AuraEnabled
     public static List<AssetExt__c> selectConferma(String newPartnerContract,String newAvailablePhone,String newAvailableEmail,Date newchangeDate,List<Product2ContactLineItemWrapper> SelectedRows,String CheckBox){
     System.debug('inside selectConferma');
     System.debug('@@@' + SelectedRows);
         
     List<AssetExt__c> assetList1 = new List<AssetExt__c>();
     List<asset> assetList2 = new List<asset>();
     List<AssetExt__c> assetExtUpsertList = new List<AssetExt__c>();
    /* assetList1[0].TAM_PartnerContract__c = NewPartnerContract;
     assetList1.TAM_AvailablePhone__c = NewAvailablePhone;
     assetList1.TAM_AvailableEmail__c = NewAvailableEmail;*/
     List<String> SelectIdList = new List<String>();
     for(Product2ContactLineItemWrapper prod : SelectedRows){
       SelectIdList.add(prod.Id);
       System.debug('***prod.id=>'+prod.Id);
     }
     if(CheckBox!= null && CheckBox.equals('Schedula')){
         System.debug('@@NewEmail'+newAvailableEmail);
 
     assetList2 = [select Id,
     TAM_PartnerContract__c,TAM_PartnerContract__r.XC_ContractSAP__c,AssetServicedById,
     TAM_AvailablePhone__c, 
     TAM_AvailableEmail__c
     from Asset //++
     where Id =:SelectIdList];
         //todo found a contract by asset id Map<Asset, Contract> 
     for(Asset assets : assetList2){
 
             assetList1 = [select XC_Asset__c,
                               XC_NewTAMPartnerContract__c,XC_NewTAMPartnerContract__r.XC_ContractSAP__c,
                               XC_NewTAMAvailablePhone__c, 
                               XC_NewTAMAvailableEmail__c,
                               XC_ChangeDate__c
                               from AssetExt__c //++
                               where XC_Asset__c =:assets.Id];
                AssetExt__c obj ;
                if(assetList1.isEmpty())
                   obj = new AssetExt__c(XC_Asset__c = assets.Id );
                else
                   obj = assetList1[0];

                //[START R1.2 CR762 12.07.2022 vaibhav.c.anand@accenture.com]
                if((String.isBlank(assets.TAM_AvailableEmail__c) && String.isBlank(newAvailableEmail)) || (String.isBlank(assets.TAM_AvailablePhone__c) && String.isBlank(newAvailablePhone)) || (String.isBlank(assets.TAM_PartnerContract__c) && String.isBlank(newPartnerContract))){
                  AuraHandledException e = new AuraHandledException('missing fields');
                  e.setMessage('missing fields');
                  throw e;
                  }
                //[END R1.2 CR762 12.07.2022 vaibhav.c.anand@accenture.com]
 
                if(obj.XC_ChangeDate__c != null){
                   AuraHandledException e = new AuraHandledException('already scheduled');
                   e.setMessage('already scheduled');
                   throw e;
                }
 
                if(!(newchangeDate == null))
                   obj.XC_ChangeDate__c = newchangeDate;
 
                if(!(String.isBlank(newPartnerContract))){
                   Contract cont = [Select Id,AccountId from Contract WHERE XC_ContractSAP__c =: newPartnerContract];
                   obj.XC_NewTAMPartnerContract__c = cont.Id; //removed to permetted deploy
                }
               
                if(!(String.isBlank(newAvailableEmail)))
                   obj.XC_NewTAMAvailableEmail__c = newAvailableEmail;
 
                if(!(String.isBlank(newAvailablePhone)))
                   obj.XC_NewTAMAvailablePhone__c = newAvailablePhone;
 
                assetExtUpsertList.add(obj) ;
            }
            upsert assetExtUpsertList;
 
            XC_SB_EditBusinessDataBatch Sth = new XC_SB_EditBusinessDataBatch();
 
 
            String sDay=String.valueof(assetExtUpsertList[0].XC_ChangeDate__c.day());        
            String sMonth=String.valueof(assetExtUpsertList[0].XC_ChangeDate__c.month());        
            String sYear=String.valueof(assetExtUpsertList[0].XC_ChangeDate__c.year());
            String strSchedule = '0 ' + '0' + ' ' + '0' + ' ' + sDay + ' ' + sMonth + ' ?' + ' ' + sYear;
 
           System.schedule(assetList2[0].Id, strSchedule, sth);
     }
 
     else if(CheckBox!= null && CheckBox.equals('AnnullaSchedulazione')) {
       List<Id> assetIdList = new List<Id>();
       assetList1 = [select XC_Asset__c,
     XC_NewTAMPartnerContract__c,
     XC_NewTAMAvailablePhone__c, 
     XC_NewTAMAvailableEmail__c
     from AssetExt__c 
     where XC_Asset__c =:SelectIdList ];
     for(AssetExt__c assets : assetList1){
         assets.XC_ChangeDate__c = null;
         assets.XC_NewTAMPartnerContract__c = null;
         assets.XC_NewTAMAvailablePhone__c = null;
         assets.XC_NewTAMAvailableEmail__c = null;
         assetExtUpsertList.add(assets) ;
         assetIdList.add(assets.XC_Asset__c);
     }
     upsert assetExtUpsertList;
     CronTrigger[] jobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name =:assetIdList];
    for(CronTrigger job: jobs) {
            System.abortJob(job.Id);
       }
     }
     else if(CheckBox!= null && CheckBox.equals('RimuoviContratto')) {
       
       assetList2 = [select Id,AssetServicedById,
       TAM_PartnerContract__c ,
       TAM_AvailablePhone__c, 
       TAM_AvailableEmail__c,
       TAM_NetworkNotes__c
     from Asset 
     where id =:SelectIdList ];
     for(asset assets : assetList2){
         assets.XC_Contract__c = null;
         assets.TAM_PartnerContract__c = null;
         assets.TAM_AvailablePhone__c = null;
         assets.TAM_AvailableEmail__c = null;    
         assets.TAM_NetworkNotes__c = null;
         assets.AssetServicedById = null; 
     }
     upsert assetList2;
     }
     else{
         System.debug('@@@'+newPartnerContract +newAvailablePhone + newAvailableEmail);
         System.debug('SelectIdList'+ SelectIdList);
         //[START R1.2 CR762 12.07.2022 vaibhav.c.anand@accenture.com]
         assetList2 = [select Id,AssetServicedById,
         TAM_PartnerContract__c,
         TAM_PartnerContract__r.AccountId,
         TAM_AvailablePhone__c, 
         TAM_AvailableEmail__c
         from Asset 
         where id =:SelectIdList ];
             
         for(asset assets : assetList2){
             System.debug('asset'+ assets);
             if(!(String.isBlank(newPartnerContract))){
                 Contract cont = [Select Id,AccountId from Contract WHERE XC_ContractSAP__c =: newPartnerContract LIMIT 1];
                 assets.TAM_PartnerContract__c = cont.Id;
                 if(cont != null){
                         assets.AssetServicedById  = cont.AccountId;
                     } 
                 
             }
             
             if((String.isBlank(newPartnerContract)) && String.isBlank(assets.AssetServicedById)){
                 assets.AssetServicedById = assets.TAM_PartnerContract__r.AccountId ;
             }
             
           if(!(String.isBlank(newAvailablePhone)))
           {System.debug('update');
             assets.TAM_AvailablePhone__c = newAvailablePhone;}
             
           if(!(String.isBlank(newAvailableEmail)))
             assets.TAM_AvailableEmail__c = newAvailableEmail;
     
           System.debug('asset ' + assets);
           System.debug('asset servicebyid ' + assets.AssetServicedById);
           
           if((String.isBlank(assets.TAM_AvailableEmail__c) && String.isBlank(newAvailableEmail)) || (String.isBlank(assets.TAM_AvailablePhone__c) && String.isBlank(newAvailablePhone)) || (String.isBlank(assets.TAM_PartnerContract__c) && String.isBlank(newPartnerContract))){
            AuraHandledException e = new AuraHandledException('missing fields');
            e.setMessage('missing fields');
            throw e;
         }
         //[END R1.2 CR762 12.07.2022 vaibhav.c.anand@accenture.com]
         }
           upsert assetList2;
     }
 
     return assetExtUpsertList;
  }
 
  @AuraEnabled
  public static List<Contract> getAccountContracts(String recordId, String contractSAP){
    System.debug('@@inside getAccountContracts =>'+contractSAP);
     //List<String> contractNumbers = new List<String>();
     List<Contract> contractList = [Select Id, AccountId from Contract WHERE Id =: recordId LIMIT 1];
     String searchText = contractSAP + '%';
     List<Contract> returnContractList = [Select Id, XC_ContractSAP__c from Contract WHERE 
                                           //XC_ContractSAP__c !=: contractSAP AND
                                           //AccountId =: contractList.get(0).AccountId AND
                                           XC_ContractSAP__c LIKE: searchText];
     //System.debug('@@inside returnContractList =>'+returnContractList);
     return returnContractList;
  }
   
     @AuraEnabled
  public static Contract getSAPContract(String Contract){
     Contract contList = [Select Id,XC_ContractSAP__c from Contract WHERE Id =: Contract LIMIT 1];
     //System.debug('@@inside getSAPContract =>'+getSAPContract);
     return contList;
  }
     
 }