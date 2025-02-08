/**
* @author Nicola Arrigo - narrigo@deloitte.it  
* @date Creation  10/04/2020 
* @description  XC_TR_ZuoraInvItem_U_FillSubNum_Test – Test class for  XC_TR_ZuoraInvItem_U_FillSubscriptionNum
*/
@isTest
public class XC_TR_ZuoraInvItem_U_FillSubNum_Test {
     public static testMethod void fillSubscriptionNum(){
                OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        Zuora__ZInvoice__c zuoraZInvoice = new Zuora__ZInvoice__c();
        zuoraZInvoice.Zuora__Balance2__c = 3;
        insert zuoraZInvoice;
         zqu__quote__c quote = new zqu__quote__c(zqu__ZuoraSubscriptionID__c = '12345');
        insert quote;    
          Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__OriginalId__c = '12345',
                                                                        Zuora__PreviousSubscriptionId__c = '12345',
                                                                        Zuora__External_Id__c = '56789');
        insert sub;
         List<Zuora__InvoiceItem__c> zList=new List<Zuora__InvoiceItem__c>();
         Zuora__InvoiceItem__c z = new Zuora__InvoiceItem__c();
         z.name='test';
         z.Zuora__Subscription__c=sub.id;
         z.Zuora__Invoice__c=zuoraZInvoice.id;
         insert z;
         zList.add(z);
         Map<Id, Zuora__InvoiceItem__c> mapOld=new  Map<Id, Zuora__InvoiceItem__c>([select id,Zuora__Invoice__c,Zuora__Subscription__c, XC_SubscriptionNumber__c from Zuora__InvoiceItem__c]);
         test.startTest();
         XC_TR_ZuoraInvItem_U_FillSubscriptionNum.onBeforeInsert(zList);
         Map<Id, Zuora__InvoiceItem__c> mapNew=new  Map<Id, Zuora__InvoiceItem__c>([select id,Zuora__Invoice__c,Zuora__Subscription__c, XC_SubscriptionNumber__c from Zuora__InvoiceItem__c]);
         mapNew.values()[0].Zuora__Subscription__c = null;
         XC_TR_ZuoraInvItem_U_FillSubscriptionNum.onBeforeUpdate(mapOld,mapNew);
         XC_TR_ZuoraInvItem_U_FillSubscriptionNum.updateRelatedRecordsOnUpdate(mapOld,mapNew);
         test.stopTest();
  }
}