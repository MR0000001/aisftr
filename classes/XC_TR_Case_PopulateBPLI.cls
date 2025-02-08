/**
* @author dpalamides
* @date 23/12/2020
* @description classes.XC_TR_Case_PopulateBPLI
*/


public without sharing class XC_TR_Case_PopulateBPLI {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Case_U_PopulateFields');

    public static void setBillingProfileLineItem(List<Case> listNew)
    {
        List<String> invoiceIdList = XC_UTIL_Sobject.getListFieldValues(listNew,'XC_Invoice__c');
        if(invoiceIdList==null || invoiceIdList.isEmpty()){
            return;
        }

        Map<Id,Zuora__ZInvoice__c> zInvoices = new Map<Id,Zuora__ZInvoice__c>([select Id, Zuora__BillingAccount__r.XC_BillingProfLineItem_LookUp__c
                                                                                from Zuora__ZInvoice__c
                                                                                where Id in :invoiceIdList]);

        for(Case c : listNew){
            Zuora__ZInvoice__c zInvoicenv = zInvoices.get(c.XC_Invoice__c);
            if(zInvoicenv!=null) {
                c.XC_Billing_Profile_Line_Item__c = zInvoicenv.Zuora__BillingAccount__r.XC_BillingProfLineItem_LookUp__c;
            }
        }

    }

}