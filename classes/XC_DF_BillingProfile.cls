/**
* @author Federico Amici - federico.amici@nttdata.com
* @description Data factory for the Billing profile object
*/
@isTest
public class XC_DF_BillingProfile {
   
        /**
	* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
	* @description Creates the billing profile
	* @return the list of billing profiles created
	* @param n Number of billing profiles to create
	*/
    public static List<NE__Billing_Profile__c> createBillingProfileBankTrans(Integer n){  
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<XC_Address__c> addList= XC_DF_Address.createAddress(accList);
        insert addList;
        List<NE__Billing_Profile__c> listBilling = new List<NE__Billing_Profile__c>();
        List<XC_BillingProfileLineItem__c> listBillingProfileLineItem = new List<XC_BillingProfileLineItem__c>();
        for (Integer i=0; i<n; i++){
            NE__Billing_Profile__c billingToInsert = new NE__Billing_Profile__c(NE__Account__c=addList[0].XC_Account__c, NE__Payment__c='Bank Transfer');
            listBilling.add(billingToInsert);
           
        }
        insert listBilling;

		for(NE__Billing_Profile__c bp : listBilling) {
			XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(XC_BillingProfile__c=bp.id, XC_SoldToAddress__c=addList[0].Id,XC_BillToAddress__c=addList[0].Id, XC_Account__c=addList[0].XC_Account__c);
            listBillingProfileLineItem.add(bpli);
		}
		 
        insert listBillingProfileLineItem;
        
        return listBilling;
           
    }
    
    
    /**
	* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
	* @description Creates the billing profile
	* @return the list of billing profiles created
	* @param n Number of billing profiles to create
	*/
    public static List<NE__Billing_Profile__c> createBillingProfile(Integer n){  
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<XC_Address__c> addList= XC_DF_Address.createAddress(accList);
        insert addList;
        List<NE__Billing_Profile__c> listBilling = new List<NE__Billing_Profile__c>();
        List<XC_BillingProfileLineItem__c> listBillingProfileLineItem = new List<XC_BillingProfileLineItem__c>();
        for (Integer i=0; i<n; i++){
            NE__Billing_Profile__c billingToInsert = new NE__Billing_Profile__c(NE__Account__c=addList[0].XC_Account__c);
            listBilling.add(billingToInsert);
           
        }
        insert listBilling;

		for(NE__Billing_Profile__c bp : listBilling) {
			XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(XC_BillingProfile__c=bp.id, XC_SoldToAddress__c=addList[0].Id,XC_BillToAddress__c=addList[0].Id, XC_Account__c=addList[0].XC_Account__c);
            listBillingProfileLineItem.add(bpli);
		}
		 
        insert listBillingProfileLineItem;
        
        return listBilling;
           
    }
    
	/**
	* @author Federico Amici - federico.amici@nttdata.com
	* @description Creates the billing profile
	* @return the list of billing profiles created
	* @param n Number of billing profiles to create
	* @param accList the list of account
	*/
	public static List<NE__Billing_Profile__c> createBillingProfile(Integer n, List<Account> accList){
        List<XC_Address__c> addList= XC_DF_Address.createAddress(accList);
        insert addList;  
        List<NE__Billing_Profile__c> listBilling = new List<NE__Billing_Profile__c>();
        List<XC_BillingProfileLineItem__c> listBillingProfileLineItem = new List<XC_BillingProfileLineItem__c>();
        for (Integer i=0; i<n; i++){
            NE__Billing_Profile__c billingToInsert = new NE__Billing_Profile__c(NE__Account__c=addList[0].XC_Account__c);
            listBilling.add(billingToInsert);
        }
        insert listBilling;
		
        Integer i = 1;
		for(NE__Billing_Profile__c bp : listBilling) {
			XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(XC_BillingProfile__c=bp.id,XC_SoldToAddress__c=addList[0].Id,XC_BillToAddress__c=addList[0].Id, XC_Account__c=addList[0].XC_Account__c);
            bpli.XC_ExternalKey__c = '1235' + i;
            listBillingProfileLineItem.add(bpli);
		} 
        insert listBillingProfileLineItem;
        
        return listBilling;
           
    }
    

}