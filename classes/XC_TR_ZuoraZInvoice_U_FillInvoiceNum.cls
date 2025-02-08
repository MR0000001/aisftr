/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 08-25-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   08-25-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
public without sharing class XC_TR_ZuoraZInvoice_U_FillInvoiceNum {


    /**
    * @description  populate zuora invoice numbers on orderitems as the invoice status is updated
    * @author Francesco Imperioli - fimperioli@deloitte.it | 08-25-2020 
    * @param listNew 
    * @param mapOld 
    * @param mapNew 
    **/
    public static void fillInvoiceNumberDateOnOIOnInsert (List<Zuora__ZInvoice__c> listNew){

        List<Zuora__ZInvoice__c> changedInvoicesPosted = new List<Zuora__ZInvoice__c>();
        Set<String> changedInvoicesPostedIds = new Set<String>();

        for(Zuora__ZInvoice__c zinv : listNew) {
            if(zinv.Zuora__Status__c == 'Posted'){
                changedInvoicesPosted.add(zInv);
                changedInvoicesPostedIds.add(zInv.Id);
            }
        }

        if(!changedInvoicesPostedIds.isEmpty()){
            List<Zuora__InvoiceItem__c> invoiceItems = getZuoraInvoiceItems(changedInvoicesPostedIds);
            XC_TR_ZuoraInvItem_U_FillInvoiceNum.fillInvoiceNumberDateOnOI(invoiceItems);
        }
    }


    /**
    * @description  populate zuora invoice numbers on orderitems as the invoice status is updated
    * @author Francesco Imperioli - fimperioli@deloitte.it | 08-25-2020 
    * @param listNew 
    * @param mapOld 
    * @param mapNew 
    **/
    public static void fillInvoiceNumberDateOnOI (List<Zuora__ZInvoice__c> listNew, Map<Id,Zuora__ZInvoice__c> mapOld,   Map<Id,Zuora__ZInvoice__c> mapNew){

        List<String> fieldList = new List<String>{'Zuora__Status__c'};
        List<Zuora__ZInvoice__c> invoicesChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);

        if(!invoicesChanged.isEmpty()){

            List<Zuora__ZInvoice__c> changedInvoicesPosted = new List<Zuora__ZInvoice__c>();
            Set<String> changedInvoicesPostedIds = new Set<String>();

            for(Zuora__ZInvoice__c zinv : invoicesChanged){
                if(zinv.Zuora__Status__c == 'Posted'){
                    changedInvoicesPosted.add(zInv);
                    changedInvoicesPostedIds.add(zInv.Id);
                }
            }

            if(!changedInvoicesPostedIds.isEmpty()){
                List<Zuora__InvoiceItem__c> invoiceItems = getZuoraInvoiceItems(changedInvoicesPostedIds);
                XC_TR_ZuoraInvItem_U_FillInvoiceNum.fillInvoiceNumberDateOnOI(invoiceItems);
            }

        }

    }

    /**
    * @description retrieves invoice items from invoice
    * @author Francesco Imperioli - fimperioli@deloitte.it | 08-25-2020 
    * @param zinvoiceIds 
    * @return List<Zuora__InvoiceItem__c> 
    **/
    private static List<Zuora__InvoiceItem__c> getZuoraInvoiceItems(Set<String> zinvoiceIds){
        return [
        SELECT Id,Zuora__Invoice__c,XC_SubscriptionNumber__c 
        FROM Zuora__InvoiceItem__c 
        WHERE Zuora__Invoice__c IN :zinvoiceIds
        ];
    }

}