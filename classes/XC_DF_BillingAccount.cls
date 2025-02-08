/**
* @author Federico Amici - federico.amici@nttdata.com
* @description Data factory for the Billing account object
*/
@isTest
public with sharing class XC_DF_BillingAccount {

    /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @description Data factory for the Billing account object
    * @param listBPLI list of billing profile line items to link to the customer account
    */
    public static void createBillingAccount(List<XC_BillingProfileLineItem__c> listBPLI) {

        List<Zuora__CustomerAccount__c> listZuoraCA = new List<Zuora__CustomerAccount__c>();
        Zuora__CustomerAccount__c zuoraCA;
        Integer i = 0;

        for(XC_BillingProfileLineItem__c bpli : listBPLI) {
            zuoraCA = new Zuora__CustomerAccount__c();
            zuoraCA.Name = 'BillingAccountTEST ' + i;
            zuoraCA.Zuora__Zuora_Id__c = '8adcfb506ad3cb6f016ad55dabed7f1a';

            System.Debug('ACCOUNTID::: ' + bpli.XC_BillingProfile__r.NE__Account__c);

            zuoraCA.Zuora__Account__c = bpli.XC_BillingProfile__r.NE__Account__c;

            listZuoraCA.add(zuoraCA);
        }
        insert listZuoraCA;

        i = 0;
        for(XC_BillingProfileLineItem__c bpli : listBPLI) {
            bpli.XC_CustomerAccount__c = listZuoraCA.get(i).Id;
        }
        update listBPLI;
    }

}