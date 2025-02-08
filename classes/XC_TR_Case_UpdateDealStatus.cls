public class XC_TR_Case_UpdateDealStatus {
      
    public static void updateDealStatus(List<Case> c){
		
		
		List<Case> casePartner = new List<Case>();
		for(Case ca: c){
		if(ca.XC_Subtype__c == 'XC193' && (ca.XC_Resolution__c == 'R135' || ca.XC_Resolution__c == 'R136') && ca.XC_Opportunity__c!= null){
		casePartner.add(ca);
		}
		}
		if(casePartner.isEmpty()){
		return;
		}
		
		Map<Id,Opportunity> mapOp= new Map<Id,Opportunity>([Select Id, XC_DealRegistrationStatus__c from Opportunity where XC_DealRegistrationStatus__c != null and Id IN:XC_UTIL_Sobject.getSetIdsOnField(casePartner, 'XC_Opportunity__c') ]);
		if(mapOp.isEmpty()){
		return;
		}
		for(Opportunity o: mapOp.values()){
			for(Case cs: casePartner){
				if(cs.XC_Resolution__c == 'R135'){
					 o.XC_DealRegistrationStatus__c ='Approved';
				}
				if(cs.XC_Resolution__c == 'R136'){
					o.XC_DealRegistrationStatus__c ='Not Approved';
			   }
			} 
		}      
        update mapOp.values(); 
		}

}