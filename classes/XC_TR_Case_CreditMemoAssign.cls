public class XC_TR_Case_CreditMemoAssign {
    
    public static void updateCredtiMemp(List<Case> caseList){
        Set<Id> idInvoiceSet = new Set<Id>();
  	   List<Case> caseToUpdate = new List<Case>();
        for(Case c:caseList){
            if(c.XC_Subtype__c =='XC266'){
                idInvoiceSet.add(c.XC_Invoice__c);
                caseToUpdate.add(c);
             }
            }
        if(caseToUpdate.isEmpty()){
            return;
        }
          Map<Id,Zuora__ZInvoice__c> map1= new Map<Id,Zuora__ZInvoice__c>([Select Id, Zuora__AmountWithoutTax__c from Zuora__ZInvoice__c where id IN:idInvoiceSet]);
         if(map1.isEmpty()){
             return;
         }
       	  for(Case ca:caseToUpdate) {
                         
            for(Zuora__ZInvoice__c o: map1.values()){
                
                if (ca.XC_Invoice__c ==o.id){
                    ca.XC_CreditMemo__c=o.Zuora__AmountWithoutTax__c;
                }
        	}        
          
          }  
    }
    
}