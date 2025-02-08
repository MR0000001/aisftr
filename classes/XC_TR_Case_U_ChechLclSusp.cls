public with sharing class XC_TR_Case_U_ChechLclSusp {
public static void  checkCase(List<Case> newList){
system.debug('DL*** XC_TR_Case_U_ChechLclSusp');
        List<String> listWoli = XC_UTIL_Sobject.getListFieldValues(newList, 'XC_WorkOrderLineItem__c');
        List<Case> caseListRiactive = new List<Case>();
        caseListRiactive =[select Id,XC_WorkOrderLineItem__c
                                 from Case where XC_WorkOrderLineItem__c IN:listWoli and SubCause__c='ATCL116' 
                                  and XC_LcLsuspended__c =true];
        
        
        Map<Id,Case> caseMap = new Map<Id,Case>();
            if (caseListRiactive.isEmpty()){
            //for (Case caseR :caseListRiactive ){
            for (Case newCase : newList){
                if((newCase.xc_segment__c == 'B2B' ||newCase.xc_segment__c == 'B2G' ) && newCase.XC_Workorderlineitem__c != null && 
                newCase.SubCause__c=='ATCL115' ){
                caseMap.put(newCase.XC_Workorderlineitem__c, newCase);
                }
                
                if(!caseMap.isEmpty()){
                    manageWoli(caseMap);
                }
            }
            }
            //}
            
        }	
            
            
            
            private static void manageWoli(Map<Id,Case> caseMap){
            
            Map<Id, WorkOrderLineitem> woliMap = new Map<Id,WorkOrderLineitem>([select Id,(select id from Cases__r) 
                                                                                    from WorkOrderLineItem where id IN:caseMap.keyset()]);
                                                                                    
            for(WorkOrderLineitem woli : woliMap.values()){
                if(!woli.Cases__r.isEmpty()){
                    Case ca = caseMap.get(woli.Id);
                    ca.addError('A suspension case is already present under the woli ');
                }
            }
            }
}