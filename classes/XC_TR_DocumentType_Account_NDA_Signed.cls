public with sharing class XC_TR_DocumentType_Account_NDA_Signed {
    public static void ndaManagedStatus(list<XC_DocumentType__c> listNew){
        list<id> accListId=new list<id>();   
        for(XC_DocumentType__c doc:listNew){
               if(doc.Category__c=='SF_NDA_SIGNED' &&
                   doc.XC_Account__c!=null){
                   accListId.add(doc.opportunity__c);      
                }
            }
            list<Account> listAccs=[select id,XC_ManageNDADocument__c  
                                         from Account
                                         where id IN:accListId];
            for(Account acc:listAccs){
                acc.XC_ManageNDADocument__c ='Accepted';
           }      
           update listAccs;  
        }
}