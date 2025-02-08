/**
 * @author: Francesco Imperioli - fimperioli@deloitte.it
 * @description : check zip code blacklist on matrix parameter - Italy Adoption - NR0001
 * @createddate : 19-03-2020
 */
public without sharing class XC_TR_Lead_U_CheckZipBlacklist {

    /**
     * @author: Francesco Imperioli - fimperioli@deloitte.it
     * @description : check zip code blacklist on matrix parameter - Italy Adoption - NR0001 - BEFORE INSERT
     * @createddate : 19-03-2020
     */
    public static void checkBlackListOnInsert(List<Lead> listNew){

        List<Lead> leadsToCheck = new List<Lead>();
        List<String> legalEntities = new List<String>();
        Map<Id, String> recordTypeIdStreamMap = new Map<Id, String>();
        for(Lead l : listNew){
            legalEntities.add(l.XC_MainLegalEntity__c);
            Lead defaultLead = (Lead) Lead.sObjectType.newSObject(/*recordTypeId*/ l.RecordTypeId, /*loadDefaultValues*/ true);
            recordTypeIdStreamMap.put(defaultLead.RecordTypeId, defaultLead.XC_Segment__c);
        }

        Map<String,String> checkLeMap = XC_UTIL_ZipCodeBlacklist.getMprNames(legalEntities, recordTypeIdStreamMap.values());


        for(Lead l : listNew){
            String stream = recordTypeIdStreamMap.get(l.RecordTypeId);
            l.XC_Segment__c = String.isBlank(l.XC_Segment__c) && String.isNotBlank(stream) ? stream : l.XC_Segment__c;
            if(String.isNotBlank(l.XC_GenericZipCode__c) && String.isNotBlank(l.XC_ZipCode__c) && l.XC_GenericZipCode__c != l.XC_ZipCode__c){
                l.addError(Label.XC_CL_LeadSameZipCode);
            }else if(String.isNotBlank(l.XC_ProductCategoryOfInterest__c) 
                && (String.isNotBlank(l.XC_GenericZipCode__c) || String.isNotBlank(l.XC_ZipCode__c)) 
                && checkLeMap.containsKey(l.XC_MainLegalEntity__c+stream) 
                && String.isNotBlank(checkLeMap.get(l.XC_MainLegalEntity__c+stream))){
                leadsToCheck.add(l);
            }
        }

        if(!leadsToCheck.isEmpty()){
            checkZip(leadsToCheck);
        }
    }

    /**
     * @author: Francesco Imperioli - fimperioli@deloitte.it
     * @description : check zip code blacklist on matrix parameter - Italy Adoption - NR0001 - BEFORE UPDATE
     * @createddate : 19-03-2020
     */
    public static void checkBlackListOnUpdate(List<Lead> listNew,Map<Id,Lead> mapOld,Map<Id,Lead> mapNew){

        List<Lead> changedLeads =   XC_UTIL_Sobject.getListChanged(new List<String>{'XC_ProductCategoryOfInterest__c','XC_GenericZipCode__c','XC_ZipCode__c'}, mapOld, mapNew);

        if(!changedLeads.isEmpty()){

            List<String> legalEntities = new List<String>();
            List<String> streams = new List<String>();
            for(Lead l : listNew){
                legalEntities.add(l.XC_MainLegalEntity__c);
                streams.add(l.XC_Segment__c);
            }
            Map<String,String> checkLeMap = XC_UTIL_ZipCodeBlacklist.getMprNames(legalEntities, streams);
            List<Lead> leadsToCheck = new List<Lead>();

            for(Lead l : changedLeads){

                if(String.isNotBlank(l.XC_GenericZipCode__c) && String.isNotBlank(l.XC_ZipCode__c) && l.XC_GenericZipCode__c != l.XC_ZipCode__c){
                    l.addError(Label.XC_CL_LeadSameZipCode);
                }else if(String.isNotBlank(l.XC_ProductCategoryOfInterest__c) 
                    && (String.isNotBlank(l.XC_GenericZipCode__c) || String.isNotBlank(l.XC_ZipCode__c)) 
                    && checkLeMap.containsKey(l.XC_MainLegalEntity__c+l.XC_Segment__c) 
                    && String.isNotBlank(checkLeMap.get(l.XC_MainLegalEntity__c+l.XC_Segment__c))){
                    leadsToCheck.add(l);
                }
            }

            if(!leadsToCheck.isEmpty()){
                checkZip(leadsToCheck);
            }

        }


    }


    /**
     * @author: Francesco Imperioli - fimperioli@deloitte.it
     * @description : check zip code blacklist on matrix parameter - Italy Adoption - NR0001 - BEFORE INSERT
     * @createddate : 19-03-2020
     */
    private static void checkZip(List<Lead> leadsToProcess){

        List<XC_UTIL_ZipCodeBlacklist.InputWrapper> inputs = new List<XC_UTIL_ZipCodeBlacklist.InputWrapper>();
        Set<String> poiNames = new Set<String>();

        for(Lead l : leadsToProcess){
            poiNames.add(l.XC_ProductCategoryOfInterest__c);
        }

        List<XC_ProductCategoryOfInterest__c> poiList = [SELECT id,Name,XC_ProductSubType__c,XC_SecondaryProductSubtype__c FROM XC_ProductCategoryOfInterest__c WHERE Name IN : poiNames];
        Map<String,XC_ProductCategoryOfInterest__c> poiNameMap = new Map<String,XC_ProductCategoryOfInterest__c>();
        for(XC_ProductCategoryOfInterest__c poi : poiList){
            poiNameMap.put(poi.Name,poi);
        }


        for(Lead l : leadsToProcess){
            XC_UTIL_ZipCodeBlacklist.InputWrapper iw = new XC_UTIL_ZipCodeBlacklist.InputWrapper();
            iw.productCategoryOfInterest = l.XC_ProductCategoryOfInterest__c;
            iw.zipCode = String.isNotBlank(l.XC_GenericZipCode__c) ? l.XC_GenericZipCode__c : l.XC_ZipCode__c;
            iw.subCategory = poiNameMap.containsKey(l.XC_ProductCategoryOfInterest__c) && String.isNotBlank(poiNameMap.get(l.XC_ProductCategoryOfInterest__c).XC_SecondaryProductSubtype__c) ?
            poiNameMap.get(l.XC_ProductCategoryOfInterest__c).XC_SecondaryProductSubtype__c : '';
            inputs.add(iw);
        }
        
        Map<XC_UTIL_ZipCodeBlacklist.InputWrapper,Boolean> blacklistZipCodeMap = XC_UTIL_ZipCodeBlacklist.checkZipBlacklist(inputs, leadsToProcess[0].XC_MainLegalEntity__c, leadsToProcess[0].XC_Segment__c);

        for(Lead l : leadsToProcess){
            XC_UTIL_ZipCodeBlacklist.InputWrapper iw = new XC_UTIL_ZipCodeBlacklist.InputWrapper();
            iw.productCategoryOfInterest = l.XC_ProductCategoryOfInterest__c;
            iw.zipCode = String.isNotBlank(l.XC_GenericZipCode__c) ? l.XC_GenericZipCode__c : l.XC_ZipCode__c;
            iw.subCategory = poiNameMap.containsKey(l.XC_ProductCategoryOfInterest__c) && String.isNotBlank(poiNameMap.get(l.XC_ProductCategoryOfInterest__c).XC_SecondaryProductSubtype__c) ?
            poiNameMap.get(l.XC_ProductCategoryOfInterest__c).XC_SecondaryProductSubtype__c : '';

            if(blacklistZipCodeMap.containsKey(iw) && blacklistZipCodeMap.get(iw)){
            // if(blacklistZipCodeMap.containsKey(iw)){
                System.Debug('ZIP CODE BLACKLIST FOUND LT::: ' + blacklistZipCodeMap.get(iw));
                l.addError(Label.XC_CL_LeadZipBlacklisted);
            }

        }

    }


}