/**
 * The Class XC_LCC169_AssignBrandAccount.
 *
 * @author Domenico Del Prete domenico.delprete@nttadata.com
 * @date Creation 05/11/2019
 * @description XC_LCC169_AssignBrandAccount – Controller for XC_LCP169_AssignBrandAccount Component
 */
public without sharing class XC_LCC169_AssignBrandAccount {

    /**
    * @description The Class resultWrapper.
    */
    public class ResultWrapper {
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String  message = 'Error'; 
    }

    /**
    * @description retrieve brand from NE__Catalog_Item__c
    * @author Del Prete Domenico | 6/11/2019 
    * @return List<String> 
    **/
    @AuraEnabled
    public static List<String> retrievePickListValue(){
        List<String> brands = new List<String>();
        List<AggregateResult> results = new List<AggregateResult>([SELECT XC_Brand__c from NE__Catalog_Item__c group by XC_Brand__c ]);
        brands.add('--None--');
        for (AggregateResult ar : results) {
            String brand = (String) ar.get('XC_Brand__c');
            if(!String.isBlank(brand)){
                brands.add(brand);
            }
        } 
           return brands;
    }


    /**
    * @description assign brand an account
    * @author Del Prete Domenico | 6/11/2019 
    * @param recordId 
    * @param typeSelected 
    * @return ResultWrapper 
    **/
    @AuraEnabled
    public static ResultWrapper assignBrand (String recordId, String typeSelected){
        ResultWrapper rw = new ResultWrapper();
        if(typeSelected.equals('--None--')){
            rw.message = Label.XC_CL_AssignBrand_SelectAtLeastOneValue;
            return rw;
        }
        Account a = new Account (Id = recordId);
        a.XC_Brand__c = typeSelected;
        XC_UTIL_Sobject.WrapperResult dmlResult = XC_UTIL_Sobject.updateRecord(a);
        if(!dmlResult.success){
            rw.success = dmlResult.success;
            rw.message = dmlResult.errorMessage;
            return rw;
        }
        rw.success = true;
        rw.message = Label.XC_CL_AssignBrand_UpdateComplete;
        return rw;
    }

}