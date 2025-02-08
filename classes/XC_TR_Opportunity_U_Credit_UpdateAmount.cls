/**
 * Created by dolombardi on 20/04/2021.
 */

public with sharing class XC_TR_Opportunity_U_Credit_UpdateAmount {
    public static void updateAmount(Map<id,Opportunity> mapNew,Map<Id,Opportunity>mapOld){
        Map<String,Map<Id,Decimal>> mapOpportunityIsChange = new Map<String,Map<Id,Decimal>>();
        mapOpportunityIsChange = checkIsChanged(mapNew,mapOld);
        if(mapOpportunityIsChange.isEmpty()){
            return ;
        }
        if(mapOpportunityIsChange.get('Revenue')!=null) {
                for (Id i : mapOpportunityIsChange.get('Revenue').keySet()) {
                    if (mapNew.get(i) != null) {
                            mapNew.get(i).XC_RevenueFullLife__c = mapOpportunityIsChange.get('Revenue').get(i);
                    }

                }

        }
        if(mapOpportunityIsChange.get('Capex')!= null) {
                for (Id i : mapOpportunityIsChange.get('Capex').keySet()) {
                    if (mapNew.get(i) != null) {
                            mapNew.get(i).XC_CapexFullLife__c = mapOpportunityIsChange.get('Capex').get(i);
                    }

                }

        }

    }

    private static Map<String,Map<Id,Decimal>> checkIsChanged(Map<id,Opportunity> mapNew,Map<Id,Opportunity>mapOld){
        Map<String,Map<Id,Decimal>> mapOpportunityIsChange = new Map<String,Map<Id,Decimal>>();
        Map<Id,Decimal> mapOpportunityIsChangeRevenue = new Map<Id,Decimal>();
        Map<Id,Decimal> mapOpportunityIsChangeCapex = new Map<Id,Decimal>();
        for(Opportunity opNew : mapNew.values()){
            for(Opportunity opOld : mapOld.values()){
                if(opNew.Amount != opOld.Amount && opNew.XC_Segment__c != 'B2C'){
                    if(opNew.XC_BusinessModel__c== 'Capex Intensive' ){
                        mapOpportunityIsChangeCapex.put(opNew.id,opNew.Amount);
                    }else{
                        mapOpportunityIsChangeRevenue.put(opNew.id,opNew.Amount);
                    }


                }
            }
            if(!mapOpportunityIsChangeCapex.isEmpty()){
                mapOpportunityIsChange.put('Capex',mapOpportunityIsChangeCapex);
            }
            if(!mapOpportunityIsChangeRevenue.isEmpty()){
                mapOpportunityIsChange.put('Revenue',mapOpportunityIsChangeRevenue);
            }
        }
        return mapOpportunityIsChange;

    }

}