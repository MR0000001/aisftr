/**
 * Created by dolombardi on 03/12/2020.
 */

public with sharing class XC_TR_Opportunity_U_updateContract {
    public static void updateContract(Map<Id,Opportunity> mapNews, Map<Id,Opportunity>mapOld){
        List<Opportunity> listOppB2B = new List<Opportunity>();
        listOppB2B = checkSegment(mapNews);
        if(listOppB2B.isEmpty()){
            return ;
        }
        List<Opportunity>listOppChange = new List<Opportunity>();
        listOppChange = checkValueIsChanged(mapNews,mapOld);
        if(listOppChange.isEmpty()){
            return;
        }
        Map<Id,Contract> mapIdContract = new Map<Id,Contract>();
        mapIdContract = findContract(listOppChange);
        if(mapIdContract.isEmpty()){
            return ;
        }
        updateContract(listOppChange,mapIdContract);


    }

    private static List<Opportunity> checkSegment(Map<Id,Opportunity> mapNews){
        List<Opportunity> listOppB2B = new List<Opportunity>();
        Set<String>streams = new Set<String>{'B2B','B2G'};
        for(Opportunity op : mapNews.values()){
            if(streams.contains(op.XC_Segment__c)){
                listOppB2B.add(op);
            }
        }
        return listOppB2B;
    }

    private static List<Opportunity> checkValueIsChanged(Map<Id,Opportunity> mapNews, Map<Id,Opportunity>mapOld){
        List<String> fieldList = New List<String>{'XC_InvoiceType__c','XC_ContractType__c'};
        List<Opportunity> listOppChange = new List<Opportunity>();
        listOppChange = XC_UTIL_Sobject.getListChanged(fieldList,mapOld,mapNews);
        return listOppChange;
    }
    private static Map<Id,Contract> findContract(List<Opportunity>listOpportunities){
        Set<Id> setOppId = new Set<Id>();
        setOppId = XC_UTIL_Sobject.getSetIds(listOpportunities);
        List<Contract> listContracts = new List<Contract>();
        Map<Id,Contract> mapIdContract = new Map<Id,Contract>([select id, Contract_Type__c, XC_InvoiceType__c, Opportunity__c from Contract
                    where Opportunity__c IN :setOppId]);

        return mapIdContract;
    }
    private static void updateContract(List<Opportunity>listOppChange, Map<Id,Contract> mapIdContract){
        List<Contract>contractToUpdate = new List<Contract>();
        for(Contract c : mapIdContract.values()){
            for(Opportunity o : listOppChange){
                if(c.Opportunity__c == o.id){
                    c.Contract_Type__c = o.XC_ContractType__c;
                    c.XC_InvoiceType__c = o.XC_InvoiceType__c;
                    contractToUpdate.add(c);
                }
            }
        }
        if(!contractToUpdate.isEmpty()){
            update contractToUpdate;
        } 
    }


}