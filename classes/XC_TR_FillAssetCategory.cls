/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date Creation 24/02/2021
* @description XC_TR_FillAssetCategory 
*/
public with sharing class XC_TR_FillAssetCategory {
     /**
* @author Nicola Arrigo - narrigo@deloitte.it
*@description classes. fillAssetCategoryonInsert
*/
    public static void fillAssetCategoryonInsert(List<case> listNew){
        List<case> caseList=new List<Case>();
        List<id> assetListId=new List<id>();
        for(case c:listNew){
            if(c.XC_TechnicalAsset__c!=null &&
                (c.XC_Segment__c=='B2B' || c.XC_Segment__c=='B2G') 
                ){
                caseList.add(c);
                assetListId.add(c.XC_TechnicalAsset__c);
            }
        }
        if(caseList.isEmpty()){
            return;
        }
        Map<id,Asset> mapAsset=new Map<id,Asset>([select id,TAM_Category__c 
                                                   from Asset
                                                   where (id IN:assetListId AND 
                                                           TAM_Category__c!=null )]);
        for(case c:caseList){
           if(mapAsset.get(c.XC_TechnicalAsset__c)!=null){
               c.XC_AssetCategory__c=mapAsset.get(c.XC_TechnicalAsset__c).TAM_Category__c;
           }
        }  
    }
       /**
* @author Nicola Arrigo - narrigo@deloitte.it
*@description classes. fillAssetCategoryonUpdate
*/
    public static void fillAssetCategoryonUpdate(List<Case> newCase,Map<id,Case> oldMapCase){
        List<case> listNew=new List<Case>();
        for(case c:newCase){ 
        if(c.XC_TechnicalAsset__c !=oldMapCase.get(c.id).XC_TechnicalAsset__c ){
            listNew.add(c);
           }
       }
       if(listNew.isEmpty()){
           return;
       }
       fillAssetCategoryonInsert(listNew);
    }

}