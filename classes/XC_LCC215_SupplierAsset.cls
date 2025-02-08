/**
* @author Domenico Del Prete - domenico.delprete@nttdata.com
* @date Creation  22/01/2021
* @description XC_LCC215_SupplierAsset – Controller class for XC_LCP215_SupplierAsset
*/ 
public without sharing class XC_LCC215_SupplierAsset {


    /**
    * @description The Class resultWrapper.
    */
    public class ResultWrapper {

        
        @AuraEnabled
        public Boolean success = true;
        @AuraEnabled
        public String  errorMessage = '';
        @AuraEnabled
        public String  supplierRepair = Label.XC_CL_NoSupplierRepair;
        @AuraEnabled
        public String  supplierInsurance = Label.XC_CL_NoSupplierInsurance;

    }

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 25/5/2020 
    * @param recordId 
    * @return Set<String> 
    **/
    @AuraEnabled        
    public static ResultWrapper getSupplier(String recordId){
        ResultWrapper rw = new ResultWrapper ();
        List<Asset> listOfAsset = new List<Asset>([SELECT Id, XC_Product_Name_LIC__c, XC_AnnualRenewalDate__c, XC_ContractStartDate__c 
                                                    FROM Asset 
                                                    WHERE Id =: recordId]);
        
        Asset assetToManage = listOfAsset[0];
        List<XC_CS007_SupplierAsset__c> listOfSupplier = new List<XC_CS007_SupplierAsset__c>([SELECT XC_TypeOfSupplier__c, XC_ContractStartDate__c, 
                                                                                                    XC_ContractEndDate__c,XC_NameOfSupplier__c, XC_TypeOfContract__c
                                                                                              FROM XC_CS007_SupplierAsset__c 
                                                                                              WHERE XC_ProductLicName__c =: assetToManage.XC_Product_Name_LIC__c]);
        if(listOfSupplier.isEmpty()){
            return rw;
        }
        List<XC_CS007_SupplierAsset__c> listOfSupplierInsurance = new List<XC_CS007_SupplierAsset__c>();
        List<XC_CS007_SupplierAsset__c> listOfSupplierRepair = new List<XC_CS007_SupplierAsset__c>();
        for(XC_CS007_SupplierAsset__c cs : listOfSupplier){
            if(cs.XC_TypeOfSupplier__c.equals('Insurance')){
                listOfSupplierInsurance.add(cs);
            }else if (cs.XC_TypeOfSupplier__c.equals('Repair')){
                listOfSupplierRepair.add(cs);
            }
        }
        rw.supplierInsurance = retrieveSupplier(assetToManage, listOfSupplierInsurance, rw.supplierInsurance);
        rw.supplierRepair = retrieveSupplier(assetToManage, listOfSupplierRepair, rw.supplierRepair);
        rw.success = true;
        return rw;
    }

    private static String retrieveSupplier(Asset asset, List<XC_CS007_SupplierAsset__c> listOfSupplier, String supplier){
        if(asset.XC_AnnualRenewalDate__c != null && asset.XC_AnnualRenewalDate__c <= Date.today()){
            for(XC_CS007_SupplierAsset__c cs : listOfSupplier){
                if(asset.XC_AnnualRenewalDate__c >= cs.XC_ContractStartDate__c && 
                    asset.XC_AnnualRenewalDate__c <= cs.XC_ContractEndDate__c && 
                    !String.isEmpty(cs.XC_TypeOfContract__c) &&
                    cs.XC_TypeOfContract__c.equals('Renewal')){
                        supplier = cs.XC_NameOfSupplier__c;  
                }
            }
        }else if (asset.XC_ContractStartDate__c != null){
            for(XC_CS007_SupplierAsset__c cs : listOfSupplier){
                if(asset.XC_ContractStartDate__c >= cs.XC_ContractStartDate__c && 
                    asset.XC_ContractStartDate__c <= cs.XC_ContractEndDate__c && 
                    !String.isEmpty(cs.XC_TypeOfContract__c) &&
                    cs.XC_TypeOfContract__c.equals('New Contract')){
                        supplier = cs.XC_NameOfSupplier__c;  
                }
            }
        }
        return supplier;
    }
    
}