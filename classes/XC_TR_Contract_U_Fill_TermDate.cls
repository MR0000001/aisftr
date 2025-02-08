/**
 * Created by dolombardi on 25/03/2021.
 */

public with sharing class XC_TR_Contract_U_Fill_TermDate {
    public static void checkDate(List<Contract> contractList, Map<Id, Contract> mapOld, Map<Id, Contract> mapNew){
        List<String> fieldList = new List<String>{'StartDate','EndDate'};
        List<Contract> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        System.debug('List changed'+listChanged);
        if(listChanged.isEmpty()){  return;  }
        updateDate(listChanged);


    }

    private static void updateDate(List<Contract>listChanged){
        for(Contract c :listChanged){
            if(c.StartDate != null && c.EndDate != null && c.XC_Segment__c !='B2C'){
                Integer differenceDate = c.StartDate.monthsBetween(c.EndDate);
                if(differenceDate <= 0){ 
                    c.ContractTerm = 1;
                }else {
                    c.ContractTerm = c.StartDate.monthsBetween(c.EndDate)+1;
                }
                System.debug('Term'+c.ContractTerm);
            }
        }

    }

}