/**
 * @author: Francesco Imperioli - fimperioli@deloitte.it
 * @description : check zip code blacklist on matrix parameter - Italy Adoption - NR0001
 * @createddate : 19-03-2020
 */
public without sharing class XC_TR_Opp_U_CheckZipBlackList {

    /**
     * @author: Francesco Imperioli - fimperioli@deloitte.it
     * @description : check zip code blacklist on matrix parameter - Italy Adoption - NR0001 - BEFORE INSERT
     * @createddate : 19-03-2020
     */
    public static void checkBlackListOnInsert(List<Opportunity> listNew){

        List<Opportunity> optyToCheck = new List<Opportunity>();
        List<String> legalEntities = new List<String>();
        List<String> streams = new List<String>();
        for(Opportunity o : listNew){
            legalEntities.add(o.XC_LegalEntity__c);
            streams.add(o.XC_Segment__c);
        }
        Map<String,String> checkLeMap = XC_UTIL_ZipCodeBlacklist.getMprNames(legalEntities, streams);

        for(Opportunity o : listNew){
            if(String.isNotBlank(o.XC_ProductCategoryOfInterest__c) 
                && String.isNotBlank(o.XC_Address__c) 
                && checkLeMap.containsKey(o.XC_LegalEntity__c+o.XC_Segment__c) 
                && String.isNotBlank(checkLeMap.get(o.XC_LegalEntity__c+o.XC_Segment__c))){
                
                    optyToCheck.add(o);
            }
        }

        if(!optyToCheck.isEmpty()){
            checkZip(optyToCheck);
        }


    }

    /**
     * @author: Francesco Imperioli - fimperioli@deloitte.it
     * @description : check zip code blacklist on matrix parameter - Italy Adoption - NR0001 - BEFORE UPDATE
     * @createddate : 19-03-2020
     */
    public static void checkBlackListOnUpdate(List<Opportunity> listNew,Map<Id,Opportunity> mapOld , Map<Id,Opportunity> mapNew){
        List<Opportunity> listOppChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_Address__c','XC_ProductCategoryOfInterest__c'}, mapOld, mapNew);

        if(!listOppChanged.isEmpty()){

            List<Opportunity> optyToCheck = new List<Opportunity>();
            List<String> legalEntities = new List<String>();
            List<String> streams = new List<String>();
            for(Opportunity o : listOppChanged){
                legalEntities.add(o.XC_LegalEntity__c);
                streams.add(o.XC_Segment__c);
            }
            Map<String,String> checkLeMap = XC_UTIL_ZipCodeBlacklist.getMprNames(legalEntities, streams);
        
            for(Opportunity o : listOppChanged){
                if(String.isNotBlank(o.XC_ProductCategoryOfInterest__c) 
                    && String.isNotBlank(o.XC_Address__c) 
                    && checkLeMap.containsKey(o.XC_LegalEntity__c+o.XC_Segment__c) 
                    && String.isNotBlank(checkLeMap.get(o.XC_LegalEntity__c+o.XC_Segment__c))){
                        
                        optyToCheck.add(o);
                }
            }

            if(!optyToCheck.isEmpty()){
                checkZip(optyToCheck);
            }

        }
    }



    /**
     * @author: Francesco Imperioli - fimperioli@deloitte.it
     * @description : check zip code blacklist on matrix parameter - Italy Adoption - NR0001 - BEFORE INSERT
     * @createddate : 19-03-2020
     */
    private static void checkZip(List<Opportunity> optyToCheck){

        Map<String,String> addressZipCodeMap = new Map<String,String>();
        Set<String> addressIds = new Set<String>();
        Set<String> poiNames = new Set<String>();
        List<XC_UTIL_ZipCodeBlacklist.InputWrapper> inputs = new List<XC_UTIL_ZipCodeBlacklist.InputWrapper>();


        for(Opportunity o : optyToCheck){
            addressIds.add(o.XC_Address__c);
            poiNames.add(o.XC_ProductCategoryOfInterest__c);
        }

        List<XC_ProductCategoryOfInterest__c> poiList = [SELECT id,Name,XC_ProductSubType__c,XC_SecondaryProductSubtype__c FROM XC_ProductCategoryOfInterest__c WHERE Name IN : poiNames];
        Map<String,XC_ProductCategoryOfInterest__c> poiNameMap = new Map<String,XC_ProductCategoryOfInterest__c>();
        for(XC_ProductCategoryOfInterest__c poi : poiList){
            poiNameMap.put(poi.Name,poi);
        }

        Map<Id,XC_Address__c> addressMap = new Map<Id,XC_Address__c>([SELECT Id,XC_PostalCode__c FROM XC_Address__c WHERE Id IN :addressIds]);
        
        for(Opportunity o : optyToCheck){
            XC_UTIL_ZipCodeBlacklist.InputWrapper iw = new XC_UTIL_ZipCodeBlacklist.InputWrapper();
            iw.productCategoryOfInterest = o.XC_ProductCategoryOfInterest__c;
            iw.zipCode = addressMap.get(o.XC_Address__c).XC_PostalCode__c;
            iw.subCategory = poiNameMap.containsKey(o.XC_ProductCategoryOfInterest__c) && String.isNotBlank(poiNameMap.get(o.XC_ProductCategoryOfInterest__c).XC_SecondaryProductSubtype__c) ? 
            poiNameMap.get(o.XC_ProductCategoryOfInterest__c).XC_SecondaryProductSubtype__c : '';
            inputs.add(iw);
        }

        //calling global method to check blacklist
        Map<XC_UTIL_ZipCodeBlacklist.InputWrapper,Boolean> blacklistZipCodeMap = XC_UTIL_ZipCodeBlacklist.checkZipBlacklist(inputs, optyToCheck[0].XC_LegalEntity__c, optyToCheck[0].XC_Segment__c);


        for(Opportunity o : optyToCheck){
            XC_UTIL_ZipCodeBlacklist.InputWrapper iw = new XC_UTIL_ZipCodeBlacklist.InputWrapper();
            iw.productCategoryOfInterest = o.XC_ProductCategoryOfInterest__c;
            iw.zipCode = addressMap.get(o.XC_Address__c).XC_PostalCode__c;
            iw.subCategory = poiNameMap.containsKey(o.XC_ProductCategoryOfInterest__c) && String.isNotBlank(poiNameMap.get(o.XC_ProductCategoryOfInterest__c).XC_SecondaryProductSubtype__c) ? 
            poiNameMap.get(o.XC_ProductCategoryOfInterest__c).XC_SecondaryProductSubtype__c : '';
            if(blacklistZipCodeMap.containsKey(iw) && blacklistZipCodeMap.get(iw)){
                // if(blacklistZipCodeMap.containsKey(iw)){
                    System.Debug('ZIP CODE BLACKLIST FOUND LT::: ' + blacklistZipCodeMap.get(iw));
                    o.addError(Label.XC_CL_LeadZipBlacklisted);
            }
        }

    }

}