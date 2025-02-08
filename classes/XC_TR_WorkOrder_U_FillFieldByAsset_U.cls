/**
* @author: Salvatore Scarpato - salvatore.scarpato@nttdata.com, Marco Rosa - marco.rosa@nttdata.com
* @date  : 14/05/2019
* @description Util Class for XC_TR_WorkOrder_U_FillFieldByAsset
*/
public class XC_TR_WorkOrder_U_FillFieldByAsset_U {
	
    /**
     * @description Mapping Fields On WorkOrder by the parent Asset
     * @param wo
     * @param a
     */  
    
    public static void fillFields(WorkOrder wo, Asset a,boolean isAssetModified){
           //Mapping Fields
        wo.AccountId                                  = a.AccountId;
        wo.ContactId                                  = a.ContactId;
        wo.XC_LegalEntity__c                          = (String.isBlank(wo.XC_LegalEntity__c)) ? a.XC_LegalEntity__c : wo.XC_LegalEntity__c;
		        if(!String.isBlank(a.XC_LegalEntity__c) &&
              isAssetModified==true ){
                wo.XC_LegalEntity__c=a.XC_LegalEntity__c;
        }
       if((String.isBlank(wo.XC_CatalogCategory__c) && !String.isBlank(a.NE__CatalogItem__r.NE__Catalog_Category_Name__c)) ||
           (!String.isBlank(a.NE__CatalogItem__r.NE__Catalog_Category_Name__c) && isAssetModified==true )){
            wo.XC_CatalogCategory__c                  = a.NE__CatalogItem__r.NE__Catalog_Category_Name__c;
        }
       if(String.isBlank(wo.XC_Product_Name__c)||
            (!String.isBlank(a.NE__CatalogItem__r.NE__Product_Name__c) && isAssetModified==true)
             ){
            wo.XC_Product_Name__c                      = a.NE__CatalogItem__r.NE__Product_Name__c;
        }
        if(String.isBlank(wo.XC_SerialNumber__c) ||
           (!String.isBlank(a.SerialNumber) && isAssetModified==true) ){
            wo.XC_SerialNumber__c                      = a.SerialNumber;
        }
       if(String.isBlank(wo.XC_CatalogItemId__c)||
           (!String.isBlank(a.NE__CatalogItem__c) && isAssetModified==true) ){
            wo.XC_CatalogItemId__c                      = a.NE__CatalogItem__c;
        }
       //na for project task 
       system.debug('project task'+' '+wo.XC_Project_Task__c);
       if( a.XC_Address__c !=  null &&
            String.isBlank(wo.XC_Project_Task__c)
        ){
              system.debug('enter if method');
               wo.Street                                 = a.XC_Address__r.XC_Address__c;
               wo.PostalCode                             = a.XC_Address__r.XC_PostalCode__c;
               wo.City                                   = a.XC_Address__r.XC_City__c;
               wo.Country                                = a.XC_Address__r.XC_AddressCountry__c;
               wo.State                                  = a.XC_Address__r.XC_AddressProvince__c;
               wo.XC_Address__c                          = a.XC_Address__c;
               wo.XC_Country__c                          = a.XC_Address__r.XC_AddressCountry__c;
           }
    }
    
}