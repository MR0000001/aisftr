public class XC_TR_Contract_UpdateSubscriptions {
        
    
	public static void updateSubscriptions(Map<Id, Contract> mapOld, Map<Id, Contract> mapNew) {
        List<String> fieldList = new List<String>{'XC_CIG__c', 'XC_CUP__c','XC_ContractHeader__c','XC_AdditionalDescription__c','XC_Determina__c'};
        List<Contract> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        Set<Id> changedB2BG = new Set<Id>();
		for(Contract con : listChanged) {
            if(con.XC_Segment__c == 'B2B' || con.XC_Segment__c == 'B2G') {
                changedB2BG.add(con.Id);
                //callZuoraFromContract(JSON.serialize(New List<Contract>{con}));
            }
		}
        if(!changedB2BG.isEmpty()) 
        {
            Database.executeBatch(new XC_SC043_UpdateSubscriptionBatch(changedB2BG),1);
        }
    }
    
   
}