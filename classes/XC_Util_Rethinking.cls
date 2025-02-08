/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date Creation 13/12/2019
* @description XC_Util_Rethinking – Util Class for Rethinking days
*/
public with sharing class XC_Util_Rethinking {

  /**
     * @author Nicola Arrigo - narrigo@deloitte.it, Monica Cutillo - mcutillo@deloitte.it
     * @description getRethinkingDays - calculation of Rethinking days
     * @param a Asset 
     * @return  decimal 
    */   
    public static String getRethinkingDays(Asset a) {

        List<XC_CM_RethinkingDays__mdt> listCMRD = new List<XC_CM_RethinkingDays__mdt>();
        XC_CM_RethinkingDays__mdt  recordCMRDwithProd = new XC_CM_RethinkingDays__mdt();

        if(Schema.sObjectType.XC_CM_RethinkingDays__mdt.isAccessible()){
        
            listCMRD = [SELECT Id, XC_LegalEntity__c, XC_Days__c, XC_ProductLicName__c 
                        FROM XC_CM_RethinkingDays__mdt
                        WHERE XC_LegalEntity__c=:a.XC_LegalEntity__c AND XC_Stream__c =: a.XC_Segment__c];

            /* recordCMRDwithProd=[select id,XC_LegalEntity__c,	XC_Days__c,XC_ProductLicName__c 
                                    from XC_CM_RethinkingDays__mdt
                                    where XC_LegalEntity__c=:a.XC_LegalEntity__c and
                                        XC_ProductLicName__c=:a.NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c]; */  
        }
      
        for(XC_CM_RethinkingDays__mdt rd:listCMRD){
            /*if(rd.XC_ProductLicName__c==null){
                if(rd.XC_Days__c != null){
                    return String.valueOf(rd.XC_Days__c);
                }
            }else if(rd.XC_ProductLicName__c==a.NE__ProdId__r.XC_LIC_Product_Name__c){
                if(rd.XC_Days__c != null){
                    return String.valueOf(rd.XC_Days__c);
                }
            }*/

            if((rd.XC_ProductLicName__c==null || rd.XC_ProductLicName__c==a.NE__ProdId__r.XC_LIC_Product_Name__c) && rd.XC_Days__c != null) {
                return String.valueOf(rd.XC_Days__c);
            }
        }

        return Label.XC_CL_RethinkingDeafaultDays;
    }
}