/**
 * @author: Francesco Imperioli - fimperioli@deloitte.it
 * @description : manage utily methods for zipcode product blacklist requirement - NR0001 - Italy Adoption
 * @createdDate : 2020-03-19
 */
public without sharing class XC_UTIL_ZipCodeBlacklist {

    public class InputWrapper{
        public String productCategoryOfInterest {get;set;}
        public String subCategory {get;set;}
        public String zipCode {get;set;}

        public InputWrapper(String poiOrSubtype,String zipCode,String subCategory){
            this.productCategoryOfInterest = poiOrSubtype;
            this.zipCode = zipCode;
            this.subCategory = subCategory;
        }

        public InputWrapper(){
    
        }

        public Boolean equals(Object obj){
            if(obj instanceof InputWrapper){
                InputWrapper otherIw = (InputWrapper)obj;
                return
                (otherIw.productCategoryOfInterest==this.productCategoryOfInterest)
                && (otherIw.zipCode == this.zipCode) 
                && (otherIw.subCategory == this.subCategory);
            }
            return false;
        }

        public Integer hashCode (){
            Integer hash = 0;
            try{
                hash = 31*(Integer.valueOf(this.zipCode))^3;
            }catch(Exception e){
                hash = Integer.valueOf(Math.random());
            }
            return hash;
        }

    }

    /**
     * @author: Francesco Imperioli - fimperioli@deloitte.it
     * @description : NR0001 - Italy Adoption - check ZipCodeBlacklist MPR based on list of inputs
     * @createdDate : 2020-03-19
     */
    public static Map<InputWrapper,Boolean> checkZipBlacklist(List<InputWrapper> inputs, String legalEntity, String stream){

        Map<InputWrapper,Boolean> result = new Map<InputWrapper,Boolean>();
        Map<String,NE__Matrix_Parameter_Row__c> zipCodeRows = retrieveMatrixParametersRows(legalEntity, stream);
        Map<String,XC_ProductCategoryOfInterest__c> poiSubtypeMap = retrievePoiSubtypeMap(inputs);

        for(InputWrapper iw : inputs){
            if(zipCodeRows.containsKey(iw.zipCode)){
                System.Debug('ZIP CODE BLACKLIST ROW FOUND::: ' + iw);
                if(poiSubtypeMap.containsKey(iw.productCategoryOfInterest) && String.isNotBlank(poiSubtypeMap.get(iw.productCategoryOfInterest).XC_ProductSubType__c)){
                    
                    String excludedSubtypes = zipCodeRows.get(iw.ZipCode).XC_Value1__c;
                    String excludedSubCategory = zipCodeRows.get(iw.ZipCode).XC_Value3__c;

                    if(String.isBlank(iw.subCategory)){
                        System.Debug('EXCLUDED SUBTYPES::: ' + excludedSubtypes + ' SEARCH KEY : ' + poiSubtypeMap.get(iw.productCategoryOfInterest) + ' RESULT : ' + excludedSubtypes.containsIgnoreCase(poiSubtypeMap.get(iw.productCategoryOfInterest).XC_ProductSubType__c));
                        result.put(iw,excludedSubtypes.containsIgnoreCase(poiSubtypeMap.get(iw.productCategoryOfInterest).XC_ProductSubType__c));
                    }else{

                        String poiSubcategory = poiSubtypeMap.get(iw.productCategoryOfInterest).XC_SecondaryProductSubtype__c;
                        if(String.isBlank(poiSubcategory) || String.isBlank(excludedSubCategory)){
                            result.put(iw,excludedSubtypes.containsIgnoreCase(poiSubtypeMap.get(iw.productCategoryOfInterest).XC_ProductSubType__c));
                        }else{
                            Boolean blackListSubResult = excludedSubtypes.containsIgnoreCase(poiSubtypeMap.get(iw.productCategoryOfInterest).XC_ProductSubType__c) &&
                            excludedSubCategory.containsIgnoreCase(poiSubcategory);
                            result.put(iw,blackListSubResult);
                        }
                    }

                }else{
                    result.put(iw,false);
                }
            }else{
                result.put(iw,false);
            }
        }
        return result;
    }

    /**
     * @author: Francesco Imperioli - fimperioli@deloitte.it
     * @description : NR0001 - Italy Adoption - check ZipCodeBlacklist MPR based on list of inputs by product subtype
     * @createdDate : 2020-03-19
     */
    /*public static Map<InputWrapper,Boolean> checkZipBlacklistByProductSubtype(List<InputWrapper> inputs,String legalEntity){

        Map<InputWrapper,Boolean> result = new Map<InputWrapper,Boolean>();
        Map<String,NE__Matrix_Parameter_Row__c> zipCodeRows = retrieveMatrixParametersRows(legalEntity);
        // Map<String,String> poiSubtypeMap = retrievePoiSubtypeMap(inputs);

        for(InputWrapper iw : inputs){
            if(zipCodeRows.containsKey(iw.zipCode)){
                System.Debug('ZIP CODE BLACKLIST ROW FOUND::: ' + iw);
                String excludedSubtypes = zipCodeRows.get(iw.ZipCode).XC_Value1__c;
                result.put(iw,excludedSubtypes.containsIgnoreCase(iw.productCategoryOfInterest));
            }else{
                result.put(iw,false);
            }
        }
        return result;
    }*/


    /**
     * @author: Francesco Imperioli - fimperioli@deloitte.it
     * @description : NR0001 - Italy Adoption - check ZipCodeBlacklist MPR based on list of inputs by product subtype
     * @createdDate : 2020-03-19
     */
    public static Map<InputWrapper,Boolean> checkZipBlacklistByProductSubtype(List<InputWrapper> inputs, String legalEntity, String stream){

        Map<InputWrapper,Boolean> result = new Map<InputWrapper,Boolean>();
        Map<String,NE__Matrix_Parameter_Row__c> zipCodeRows = retrieveMatrixParametersRows(legalEntity, stream);
        // Map<String,String> poiSubtypeMap = retrievePoiSubtypeMap(inputs);

        for(InputWrapper iw : inputs){
            if(zipCodeRows.containsKey(iw.zipCode)){
                System.Debug('ZIP CODE BLACKLIST ROW FOUND::: ' + iw);
                String excludedSubtypes = zipCodeRows.get(iw.ZipCode).XC_Value1__c;
                String excludedSubCategories = zipCodeRows.get(iw.ZipCode).XC_Value3__c;


                if(String.isBlank(iw.subCategory)){
                    result.put(iw,excludedSubtypes.containsIgnoreCase(iw.productCategoryOfInterest));
                }else{

                    //TODO: check this, subcategory management on order
                    System.Debug('SUBCATEGORY FLOW ENTER');

                    String[] splittedSubcategory = iw.subCategory.split(';');
                    Set<String> subCategorySet = new set<String>();
                    subCategorySet.addAll(splittedSubcategory);
                    Boolean blacklistResult = false;
                    if(String.isNotBlank(excludedSubCategories)){
                        blacklistResult = subCategorySet.contains(excludedSubCategories) && excludedSubtypes.containsIgnoreCase(iw.productCategoryOfInterest);
                    }else{
                        blacklistResult = excludedSubtypes.containsIgnoreCase(iw.productCategoryOfInterest);
                    }
                    result.put(iw,blacklistResult);

                }

            }else{
                result.put(iw,false);
            }
        }
        return result;
    }
    
    /**
     * @author: Francesco Imperioli - fimperioli@deloitte.it
     * @description : NR0001 - Italy Adoption - retrieve zip code blacklist mpr based on legalEntity
     * @createdDate : 2020-03-19
     */
    public static Map<String,NE__Matrix_Parameter_Row__c> retrieveMatrixParametersRows(String legalEntity, String stream){
        String mprName = getMPRName(legalEntity, stream);
        Map<String,NE__Matrix_Parameter_Row__c> resultMapCapMPR = new Map<String,NE__Matrix_Parameter_Row__c>();
        if(String.isNotBlank(mprName)){
            //TODO: Add custom labels
            List<NE__Matrix_Parameter_Row__c> blacklistRows = [SELECT XC_Value2__c,XC_Value1__c,XC_Value3__c
            FROM NE__Matrix_Parameter_Row__c 
            WHERE XC_Matrix_Parameter_Name__c = :mprName 
            AND XC_Name2__c = 'CAP' 
            AND XC_Name1__c = 'ProductSubType' 
            AND NE__Active__c = TRUE 
            AND (NE__End_Date__c >= TODAY OR NE__End_Date__c = NULL)];

            for(NE__Matrix_Parameter_Row__c mpr : blacklistRows){
                resultMapCapMPR.put(mpr.XC_Value2__c,mpr);
            }
        }
        return resultMapCapMPR;
    }

    /**
     * @author: Francesco Imperioli - fimperioli@deloitte.it
     * @description : NR0001 - Italy Adoption - maps product category of interest with product subtype
     * @createdDate : 2020-03-19
     */
    private static Map<String,XC_ProductCategoryOfInterest__c> retrievePoiSubtypeMap(List<InputWrapper> inputs){
        Map<String,XC_ProductCategoryOfInterest__c> result = new Map<String,XC_ProductCategoryOfInterest__c>();
        Set<String> pois = new Set<String>();
        for(InputWrapper iw : inputs){
            pois.add(iw.productCategoryOfInterest);
        }
        for(XC_ProductCategoryOfInterest__c poi : [SELECT id,Name,XC_ProductSubType__c,XC_SecondaryProductSubtype__c FROM XC_ProductCategoryOfInterest__c WHERE Name IN : pois]){
            result.put(poi.Name,poi);
        }
        return result;
    }

    /**
     * @author: Francesco Imperioli - fimperioli@deloitte.it
     * @description : NR0001 - Italy Adoption - retrieve matrix parameter name for zipcode blacklist
     * @createdDate : 2020-03-19
     */
    /*public static String getMPRName (String legalEntity){
        XC_CM_LegalEntity_Configuration__mdt currentOrgConfiguration = [
            SELECT XC_ZipBlacklistMPR__c,XC_LegalEntity__c 
            FROM XC_CM_LegalEntity_Configuration__mdt 
            WHERE XC_LegalEntity__c = :legalEntity AND XC_OrgId__c = :UserInfo.getOrganizationId() 
            LIMIT 1];
        return currentOrgConfiguration.XC_ZipBlacklistMPR__c;
    }*/

    /**
     * @author: Francesco Imperioli - fimperioli@deloitte.it
     * @description : NR0001 - Italy Adoption - retrieve matrix parameter name for zipcode blacklist
     * @createdDate : 2020-03-19
     */
    public static String getMPRName (String legalEntity, String stream){
        XC_CM_LegalEntity_Configuration__mdt currentOrgConfiguration = [
            SELECT XC_ZipBlacklistMPR__c,XC_LegalEntity__c 
            FROM XC_CM_LegalEntity_Configuration__mdt 
            WHERE XC_LegalEntity__c = :legalEntity AND XC_Stream__c = :stream AND XC_OrgId__c = :UserInfo.getOrganizationId() 
            LIMIT 1];
        return currentOrgConfiguration.XC_ZipBlacklistMPR__c;
    }

    /**
     * @author: Francesco Imperioli - fimperioli@deloitte.it
     * @description : NR0001 - Italy Adoption - retrieve matrix parameter name for zipcode blacklist
     * @createdDate : 2020-03-19
     */
    /*public static Map<String,String> getMprNames (List<String> legalEntities){
        Map<String,String> result = new Map<String,String>();
        List<XC_CM_LegalEntity_Configuration__mdt> currentOrgConfigurations = [
            SELECT XC_ZipBlacklistMPR__c,XC_LegalEntity__c  
            FROM XC_CM_LegalEntity_Configuration__mdt 
            WHERE XC_LegalEntity__c IN :legalEntities AND XC_OrgId__c = :UserInfo.getOrganizationId()];

        for(XC_CM_LegalEntity_Configuration__mdt conf : currentOrgConfigurations){
            result.put(conf.XC_LegalEntity__c,conf.XC_ZipBlacklistMPR__c);
        }
        return result;
    }*/

    /**
     * @author: Francesco Imperioli - fimperioli@deloitte.it
     * @description : NR0001 - Italy Adoption - retrieve matrix parameter name for zipcode blacklist
     * @createdDate : 2020-03-19
     */
    public static Map<String,String> getMprNames (List<String> legalEntities, List<String> streams){
        Map<String,String> result = new Map<String,String>();
        List<XC_CM_LegalEntity_Configuration__mdt> currentOrgConfigurations = [
            SELECT XC_ZipBlacklistMPR__c, XC_LegalEntity__c, XC_Stream__c
            FROM XC_CM_LegalEntity_Configuration__mdt 
            WHERE XC_LegalEntity__c IN :legalEntities AND XC_Stream__c IN :streams AND XC_OrgId__c = :UserInfo.getOrganizationId()];

        for(XC_CM_LegalEntity_Configuration__mdt conf : currentOrgConfigurations){
            result.put(conf.XC_LegalEntity__c+conf.XC_Stream__c,conf.XC_ZipBlacklistMPR__c);
        }
        return result;
    }
    
}