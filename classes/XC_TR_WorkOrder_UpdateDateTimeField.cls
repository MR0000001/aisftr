public with sharing class XC_TR_WorkOrder_UpdateDateTimeField {
    
      public static void updateDateTime(List<WorkOrder> wo){
	 
	 System.debug('@@@Giulia --> entra nella class');
	  Map<Id,WorkOrder> m1 = new  Map<Id,WorkOrder>();
	  for (WorkOrder wMalf : wo){
          System.debug('@@@ Giulia WorktypeCategory -->' +wMalf.XC_WorkTypeCategory__c);
          System.debug('@@@ Giulia XC_Segment__c -->' +wMalf.XC_Segment__c);
	  	if (wMalf.XC_WorkTypeCategory__c == 'Malfunctioning' && wMalf.XC_Segment__c != 'B2C'){
	  		m1.put(wMalf.CaseId, wMalf);
	 	}
	  }
	  Set<Id> caseId = new Set<Id>();
	  
	  if(m1!=null){
	  	for (Id key: m1.keyset()){
	  		caseId.add(key);
	  	}
	  }
      List<Case> c2 = new List<Case>();
	  List<Case> c1 = [Select id ,XC_MalfunctioningWOCreation__c from case where id IN:caseId];
          System.debug('@@@Lista Case');
          if(c1!=null){
              for(Case cm: c1){
                  for (WorkOrder w3 : m1.values()){
                      System.debug('@@@GIulia -->' + cm.XC_MalfunctioningWOCreation__c);
              		if(cm.XC_MalfunctioningWOCreation__c == null){
                		cm.XC_MalfunctioningWOCreation__c= w3.CreatedDate;
                  		c2.add(cm);
              		}
                  }
              }
          }
	  
	  update(c2);
	  }

}