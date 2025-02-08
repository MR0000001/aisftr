public with sharing class XC_LCC_SummaryAssetSection {
    
        

    @AuraEnabled
    public static List<Asset> queryAsset(String recordId){ 
    
    List<Asset> assetList =
    [select Id,Name,XC_Contract__c,XC_Contract__r.StartDate,XC_Contract__r.EndDate,Status,TAM_PartnerContract__c,TAM_PartnerContract__r.AccountId,XC_Contract__r.ContractNumber,
    TAM_PartnerContract__r.XC_ContractSAP__c,
    TAM_PartnerContract__r.ContractNumber,
    TAM_PartnerContract__r.Account.Name
    from Asset 
    where AccountId =: recordId AND Recordtype.Name = 'Network' Order by Name LIMIT 10000];
    System.debug('***' +assetList);   
      
     return assetList;
 
    }


    @AuraEnabled
    public static List<Asset> queryAssetCommercial(String recordId){ 
    
    List<Asset> assetList1 =
    [select Id,Name, Quantity, NE__Activation_Date__c,XC_LegalEntity__c,Status,
    XC_ContractStartDate__c, XC_ContractEndDate__c,XC_Contract__c, XC_Contract__r.ContractNumber, XC_Contract__r.Opportunity__c,
    XC_Contract__r.Opportunity__r.Name
    from Asset 
    where AccountId =: recordId AND TAM_IsTechnical__c = false AND TAM_IsLogical__c = false Order by Name LIMIT 10000];
    System.debug('***' +assetList1);   
      
     return assetList1;
 
    }



    }