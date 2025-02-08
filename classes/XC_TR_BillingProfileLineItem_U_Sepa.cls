/**
 * The Class XC_TR_BillingProfileLineItem_U_Sepa
 *
 * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
 * @date Creation 06/08/2019
 * @date Modification dd/mm/yyyy
 * @description XC_TR_BillingProfileLineItem_U_Sepa – manage SEPA
 */

public without sharing class XC_TR_BillingProfileLineItem_U_Sepa { 
	
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_BillingProfileLineItem_U_Sepa');
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description rebaltLegalEntity on father.
     * @param listBpli the XC_BillingProfileLineItem__c list
     */
    public static void rebaltLegalEntity(List<XC_BillingProfileLineItem__c> listBpli) {
        List<NE__Billing_Profile__c> bpToUpdate = new List<NE__Billing_Profile__c>();
        for(XC_BillingProfileLineItem__c bpli : listBpli){
            if(bpli.XC_PaymentMethod__c == 'Direct Debt'){
                NE__Billing_Profile__c b = new NE__Billing_Profile__c(Id=bpli.XC_BillingProfile__c);
                b.XC_LegalEntity__c = bpli.XC_LegalEntity__c;
                bpToUpdate.add(b);
            }
            
        } XC_UTIL_Sobject.updateListRecords(bpToUpdate);
    
    }
    
}