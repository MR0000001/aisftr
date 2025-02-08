public with sharing class XC_TR_DocumentType_LoiStatus {
   public static void loiStatus(list<XC_DocumentType__c> listNew){
    list<id> oppListId=new list<id>();   
    for(XC_DocumentType__c doc:listNew){
           if(doc.Category__c=='SF_LOI_SIGNED' &&
               doc.opportunity__c!=null){
               oppListId.add(doc.opportunity__c);      
            }
        }
        list<Opportunity> listOpps=[select id,XC_LOI_Status_GB__c 
                                     from Opportunity
                                     where id IN:oppListId];
        for(Opportunity opp:listOpps){
            opp.XC_LOI_Status_GB__c='Accepted';
       }      
       update listOpps;  
    }
}