/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/


public with sharing class XC_TR_Opportunity_U_Create_Annual_Rev {
    

    /**
     * @author Donato Lombardi Giulia Sciammarella
     * @description Method to create Annual Revenue
     * @param mapNew - Map<Id,Opportunity>
    **/
    public static void createARonAfterInsert(Map<Id,Opportunity>mapNew ){
        Map<Id,Opportunity> mapOppAnnualReven = new Map<Id,Opportunity>();
       // mapOppAnnualReven = checkOppAnnualRev(mapNew);
        mapOppAnnualReven = checkSkipPipeline(mapNew);
        Map<Id,Opportunity> mapOppFromAfterInsert = new Map<Id,Opportunity>();
        mapOppFromAfterInsert = checkLeadExisiting(mapOppAnnualReven);
     //   Map<Id,Opportunity> mapOppB2B_B2G = new Map<Id,opportunity>();
     //   mapOppB2B_B2G=segment(mapOppAnnualReven);
        if(mapOppAnnualReven.isEmpty()){
            return ;
        }
            createAnnualRevenue(mapOppAnnualReven);
           
        }


    private static Map<Id,Opportunity> checkSkipPipeline(Map<Id,Opportunity> mapNew){
        Map<Id,Opportunity> mapOppSkipLegalEntity = new Map<Id,Opportunity>();
        Set<String> legalEntities = new Set<String>();
        Set<String> streams = new Set<String>();
        for(Opportunity op : mapNew.values()){
            legalEntities.add(op.XC_LegalEntity__c);
            streams.add(op.XC_Segment__c);
        }

        Map<Id,XC_CM_CountryLegalEntityAssociation__mdt> legalEntityCategory = new Map<Id,XC_CM_CountryLegalEntityAssociation__mdt>([SELECT ID, XC_Skip_Pipeline__c, DeveloperName, XC_LegalEntity__c, XC_Category__c
        FROM XC_CM_CountryLegalEntityAssociation__mdt
        WHERE XC_LegalEntity__c IN :legalEntities AND XC_Category__c IN :streams]);

        for(Opportunity op : mapNew.values()){
            if(op.RecordTypeId != null){
                String oppRecordTypeName = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(op.RecordTypeId).    getDeveloperName();
                if(oppRecordTypeName.contains('SFM')){
                    mapOppSkipLegalEntity.put(op.id,op);
                    continue;
                }
            }
            for(XC_CM_CountryLegalEntityAssociation__mdt cm :legalEntityCategory.values()){
                if(op.XC_LegalEntity__c == cm.XC_LegalEntity__c && op.XC_Segment__c == cm.XC_Category__c && !cm.XC_Skip_Pipeline__c /*&& op.XC_BusinessLine__c != 'eMobility'*/){
                   mapOppSkipLegalEntity.put(op.id,op);
                }
            }
        }

        return mapOppSkipLegalEntity;
    }


    private static Map<Id,Opportunity> checkLeadExisiting (Map<Id,Opportunity> mapNew){
        Map<Id,Opportunity> mapOpportuWithoutLead = new Map<Id,Opportunity>();
        for(Opportunity op : mapNew.values()){
            if(op.XC_Lead__c== NULL){
                mapOpportuWithoutLead.put(op.id,op);
            }
        }
        return mapOpportuWithoutLead;
    }


    /**
     * @author Donato Lombardi Giulia Sciammarella
     * @description Method to create Annual Revenue
     * @param mapAnnRev - Map<Id,Opportunity>
    **/
    public static void createAnnualRevenue(Map<Id,Opportunity> mapAnnRev){
        Map<Id,Integer> mapIdOppNumOfYears = new Map<Id,Integer>();
        mapIdOppNumOfYears = getNumberOfYears(mapAnnRev.values());
        Map<Id,List<XC_AnnualValue__c>> mapAnnualValuesToInsert = new Map<Id,List<XC_AnnualValue__c>>();
        Map<String, Integer> decimalPlaces =  retrieveDecimalPlacesOfCurrency(mapAnnRev.values());
        for(Opportunity op : mapAnnRev.values()){
            List<XC_AnnualValue__c> listAnnVa = new List<XC_AnnualValue__c>();
            Decimal revenueTot = 0;
            Decimal industrialKPITot = 0;
            Decimal industrialKPIValue2Tot = 0;
            Decimal industrialKPIValue3Tot = 0;
            Decimal industrialKPIValue4Tot = 0;
            Decimal industrialKPIValue5Tot = 0;
            Decimal industrialKPIValue6Tot = 0;
            Decimal industrialKPIValue7Tot = 0;
            Decimal grossMarginTot =0;
            Decimal capexTot = 0;
            for(Integer i = 0; i<= mapIdOppNumOfYears.get(op.id);i++){
                Integer totalNumberOfDays = op.XC_ContractualRevenueStartDate__c.daysBetween(op.XC_ContractualRevenueEndDate__c) +1;
                Integer daysOfTheYear = 365;
                if( i == 0 ){
                    daysOfTheYear = calculateDaysOfFirstYeas(op.XC_ContractualRevenueStartDate__c);
                }
                XC_AnnualValue__c annualRev = new XC_AnnualValue__c();
                annualRev.XC_Opportunity__c = op.id; 
                annualRev.XC_Year__c = String.valueOf(op.XC_ContractualRevenueStartDate__c.addYears(i).year());
                if(i != mapIdOppNumOfYears.get(op.id)){
                    annualRev.XC_Revenue__c = returnAnnualValues(op.XC_RevenueFullLife__c, totalNumberOfDays, daysOfTheYear, decimalPlaces.get(op.CurrencyIsoCode) );
                    revenueTot = calculateTotal(annualRev.XC_Revenue__c, revenueTot);
                }else if(op.XC_RevenueFullLife__c != null){
                    annualRev.XC_Revenue__c = op.XC_RevenueFullLife__c - revenueTot;
                }
                
                annualRev.XC_IndustrialKPIUOM__c = op.XC_KPIUOM__c;
                if(op.XC_BusinessLine__c == 'eCity'){

                    if(op.XC_IndustrialKPIfullLife__c != null){
                        annualRev.XC_IndustrialKPIValue__c = op.XC_IndustrialKPIfullLife__c;
                    }else {
                        annualRev.XC_IndustrialKPIValue__c = 0;
                    }
                    annualRev.XC_IndustrialKPIValue2__c = op.XC_IndustrialKPIFullLife2__c;
                    annualRev.XC_IndustrialKPIValue3__c = op.XC_IndustrialKPIFullLife3__c;
                    annualRev.XC_IndustrialKPIValue4__c = op.XC_IndustrialKPIFullLife4__c;
                    annualRev.XC_IndustrialKPIValue5__c = op.XC_IndustrialKPIFullLife5__c;
                    annualRev.XC_IndustrialKPIValue6__c = op.XC_IndustrialKPIFullLife6__c;
                    annualRev.XC_IndustrialKPIValue7__c = op.XC_IndustrialKPIFullLife7__c;
                    }
                else if(op.XC_BusinessLine__c == 'eIndustry'){
                    if(op.XC_IndustrialKPIfullLife__c != null){
                        if(i != mapIdOppNumOfYears.get(op.id)){
                            annualRev.XC_IndustrialKPIValue__c = returnAnnualValues(op.XC_IndustrialKPIfullLife__c, totalNumberOfDays, daysOfTheYear, 2);
                            industrialKPITot += annualRev.XC_IndustrialKPIValue__c;
                        }else {
                            annualRev.XC_IndustrialKPIValue__c = op.XC_IndustrialKPIfullLife__c - industrialKPITot;
                        }
                    }else{
                        annualRev.XC_IndustrialKPIValue__c = 0;
                    }
                    if(i != mapIdOppNumOfYears.get(op.id)){
                        annualRev.XC_IndustrialKPIValue2__c = returnAnnualValues(op.XC_IndustrialKPIFullLife2__c, totalNumberOfDays, daysOfTheYear, 2);
                        industrialKPIValue2Tot =  calculateTotal(annualRev.XC_IndustrialKPIValue2__c, industrialKPIValue2Tot);
                        annualRev.XC_IndustrialKPIValue3__c = returnAnnualValues(op.XC_IndustrialKPIFullLife3__c, totalNumberOfDays, daysOfTheYear, 2);
                        industrialKPIValue3Tot =  calculateTotal(annualRev.XC_IndustrialKPIValue3__c, industrialKPIValue3Tot);
                        annualRev.XC_IndustrialKPIValue4__c = returnAnnualValues(op.XC_IndustrialKPIFullLife4__c, totalNumberOfDays, daysOfTheYear, 2);
                        industrialKPIValue4Tot =  calculateTotal(annualRev.XC_IndustrialKPIValue4__c, industrialKPIValue4Tot);
                        annualRev.XC_IndustrialKPIValue5__c = returnAnnualValues(op.XC_IndustrialKPIFullLife5__c, totalNumberOfDays, daysOfTheYear, 2);
                        industrialKPIValue5Tot =  calculateTotal(annualRev.XC_IndustrialKPIValue5__c, industrialKPIValue5Tot);
                        annualRev.XC_IndustrialKPIValue6__c = returnAnnualValues(op.XC_IndustrialKPIFullLife6__c, totalNumberOfDays, daysOfTheYear, 2);
                        industrialKPIValue6Tot =  calculateTotal(annualRev.XC_IndustrialKPIValue6__c, industrialKPIValue6Tot);
                        annualRev.XC_IndustrialKPIValue7__c = returnAnnualValues(op.XC_IndustrialKPIFullLife7__c, totalNumberOfDays, daysOfTheYear, 2);
                        industrialKPIValue7Tot =  calculateTotal(annualRev.XC_IndustrialKPIValue7__c, industrialKPIValue7Tot);
                    }else{
                        if(op.XC_IndustrialKPIFullLife2__c != null){
                            annualRev.XC_IndustrialKPIValue2__c = op.XC_IndustrialKPIFullLife2__c - industrialKPIValue2Tot;
                        }
                        if(op.XC_IndustrialKPIFullLife3__c != null){
                            annualRev.XC_IndustrialKPIValue3__c = op.XC_IndustrialKPIFullLife3__c - industrialKPIValue3Tot;
                        }
                        if(op.XC_IndustrialKPIFullLife4__c != null){
                            annualRev.XC_IndustrialKPIValue4__c = op.XC_IndustrialKPIFullLife4__c - industrialKPIValue4Tot;
                        }
                        if(op.XC_IndustrialKPIFullLife5__c != null){
                            annualRev.XC_IndustrialKPIValue5__c = op.XC_IndustrialKPIFullLife5__c - industrialKPIValue5Tot;
                        }
                        if(op.XC_IndustrialKPIFullLife6__c != null){
                            annualRev.XC_IndustrialKPIValue6__c = op.XC_IndustrialKPIFullLife6__c - industrialKPIValue6Tot;
                        }
                        if(op.XC_IndustrialKPIFullLife7__c != null){
                            annualRev.XC_IndustrialKPIValue7__c = op.XC_IndustrialKPIFullLife7__c - industrialKPIValue7Tot;
                        }
                    }
                }
                //returnAnnualValues(op.XC_IndustrialKPIfullLife__c,mapIdOppNumOfYears.get(op.Id));
                
                if(i != mapIdOppNumOfYears.get(op.id)){
                    annualRev.XC_GrossMargin__c = returnAnnualValues(op.XC_GrossMarginFullLife__c, totalNumberOfDays, daysOfTheYear, decimalPlaces.get(op.CurrencyIsoCode));
                    grossMarginTot = calculateTotal(annualRev.XC_GrossMargin__c, grossMarginTot);
                }else if(op.XC_GrossMarginFullLife__c != null){
                    annualRev.XC_GrossMargin__c = op.XC_GrossMarginFullLife__c - grossMarginTot;
                }
                if(i != mapIdOppNumOfYears.get(op.id) && op.XC_CapexFullLife__c != null){
                    annualRev.XC_Capex__c = returnAnnualValues(op.XC_CapexFullLife__c, totalNumberOfDays, daysOfTheYear, decimalPlaces.get(op.CurrencyIsoCode));
                    capexTot = calculateTotal(annualRev.XC_Capex__c, capexTot);
                }else if(op.XC_CapexFullLife__c != null) {
                    annualRev.XC_Capex__c = op.XC_CapexFullLife__c - capexTot;
                }
                annualRev.XC_ProductCluster__c = op.XC_ProductCategoryOfInterest__c;
                annualRev.XC_BusinessModel__c = op.XC_BusinessModel__c;
                annualRev.CurrencyIsoCode = op.CurrencyIsoCode;
                System.debug('DL-->annualvalueRecord'+annualRev);
                listAnnVa.add(annualRev);
            }
            mapAnnualValuesToInsert.put(op.id,listAnnVa);
        }
        insertRecprdAnnualRev(mapAnnualValuesToInsert);
    }


    private static Map<Id,Integer> getNumberOfYears(list<Opportunity> listAnnRev){
        Map<Id,Integer> mapIdOppNumOfYears = new Map<Id,Integer>();
        for(Opportunity op : listAnnRev){
            if(op.XC_ContractualRevenueEndDate__c != Null && op.XC_ContractualRevenueStartDate__c!= null){
                //Integer annualRev = op.XC_ContractualRevenueStartDate__c.monthsBetween(op.XC_ContractualRevenueEndDate__c)/12;
                Integer annualRev = op.XC_ContractualRevenueEndDate__c.year() - op.XC_ContractualRevenueStartDate__c.year();
                System.debug('DL annualRev-->'+annualRev);
                mapIdOppNumOfYears.put(op.id,annualRev);
            }
        }
        return mapIdOppNumOfYears;
    }


    private static void insertRecprdAnnualRev(Map<Id,List<XC_AnnualValue__c>> mapAnnualValuesToInsert){
        List<XC_AnnualValue__c> listToInsert = new List<XC_AnnualValue__c>();
        for(Id i : mapAnnualValuesToInsert.keySet()){
            System.debug('DL-->mapAnn'+mapAnnualValuesToInsert.get(i));
            for(XC_AnnualValue__c xcAn : mapAnnualValuesToInsert.get(i)){
                listToInsert.add(xcAn);
            }

        }
        if(Schema.sObjectType.XC_AnnualValue__c.isCreateable()){
            Insert listToInsert;
        }
    }


    /**
     * @author Donato Lombardi Giulia Sciammarella
     * @description Method to create Annual Revenue
     * @param mapNews - Map<Id,Opportunity>
     * @param mapOld - Map<Id,Opportunity>
    **/
    public static void createARonAfterUpdate(Map<Id,Opportunity> mapNews, Map<Id,Opportunity>mapOld){
        Map<Id,Opportunity> mapOppB2B = New Map<Id,Opportunity>();
        //mapOppB2B = checkOppAnnualRevAfterUpdate(mapNews);
        mapOppB2B = checkSkipPipeline(mapNews);
        if(mapOppB2B.isEmpty()){
        return ;
        }
        Map<Id,Opportunity> mapOppIsChange = new Map<Id,Opportunity>();
        mapOppIsChange = checkAnnualRevIsFilled(mapOppB2B,mapOld);
        List<XC_AnnualValue__c> listAnnualValuesExsisting = new List<XC_AnnualValue__c>();
        listAnnualValuesExsisting = checkExsistingAnnualRev(mapNews);
        if(mapOppIsChange.isEmpty()){
            return ;
        }

        createAnnualRevenue(mapOppIsChange);
    }


    private static Map<Id,Opportunity> checkAnnualRevIsFilled(Map<Id,Opportunity> mapNew, Map<Id,Opportunity> mapOld){
        Map<Id,Opportunity> mapAnnaRevIsChange = new Map<Id,Opportunity>();
        for(Opportunity opNew : mapNew.values()){
            for(Opportunity opOld : mapOld.values()){
                if(opOld.XC_ContractualRevenueStartDate__c == Null && opOld.XC_ContractualRevenueEndDate__c==Null){
                    if(opNew.XC_ContractualRevenueStartDate__c != Null && opNew.XC_ContractualRevenueEndDate__c != Null){
                        mapAnnaRevIsChange.put(opNew.id,opNew);
                    }
                }
            }
        }

        return mapAnnaRevIsChange;
    }


    private static Decimal returnAnnualValues (Decimal valueToApply, Integer totalNumberOfDays, Integer daysOfTheYear, Integer decimalPlaces){
        if(valueToApply!=Null && decimalPlaces != Null){
            return  (valueToApply * daysOfTheYear).divide(totalNumberOfDays, decimalPlaces);
        }
        return null;
    }


    private static List<XC_AnnualValue__c> checkExsistingAnnualRev(Map<Id,Opportunity> mapNew){
        List<XC_AnnualValue__c> listAnnualValuesExsisting = [SELECT ID, XC_Opportunity__c FROM XC_AnnualValue__c WHERE XC_Opportunity__c IN :mapNew.keySet()];
                return listAnnualValuesExsisting;
    }


    private static Integer calculateDaysOfFirstYeas(Date startDate){
        Date finalDate = Date.newinstance(startDate.year(), 12, 31);
        return startDate.daysBetween(finalDate) + 1;
    }

    private static Map<String, Integer> retrieveDecimalPlacesOfCurrency(List<Opportunity> oppList){
        List<String> currencies = XC_UTIL_Sobject.getListFieldValues(oppList, 'CurrencyIsoCode');
        List<CurrencyType> currencyList = new List<CurrencyType>();
        Map<String, Integer> mapCurrencyDecimalPlaces = new Map<String, Integer>();
        if(Schema.sObjectType.CurrencyType.isAccessible()){
            currencyList = [Select IsoCode, DecimalPlaces from CurrencyType where IsoCode  IN : currencies];
        }    
        for(CurrencyType curr : currencyList){
            mapCurrencyDecimalPlaces.put(curr.IsoCode, curr.DecimalPlaces);
        }
        return mapCurrencyDecimalPlaces;

    }

    private static Decimal calculateTotal(Decimal value, Decimal tot){
        if(value != null){
            return value + tot;
        }
        else{
            return 0;
        }
    }
  /*  private static Map<Id,Opportunity> segment (Map<Id,Opportunity> mapOp){
        Map<Id,Opportunity> mapOppB2B_B2G = new Map<Id,Opportunity>();       
        for(Opportunity op : mapOp.values()){
            if(op.XC_Segment__c != 'B2C'){
                mapOppB2B_B2G.put(op.Id,op);
            }
        }
           
        return mapOppB2B_B2G;
    }*/
}