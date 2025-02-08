/**
*@author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com 
*@date Creation 10/09/2019
*@date Modification dd/mm/yyyy
*@description controller for custom lightning component XC_LCP153_SelectAddressFromBpli
*/
public class XC_LCC153_SelectAddressFromBpli {
    
    
    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description getAccountId.
    *@param recordId the record id
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper getAccountId(String bpliId){
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        XC_BillingProfileLineItem__c b = [SELECT Id, XC_SoldToContactId__c, XC_SoldToContactId__r.AccountId
		FROM  XC_BillingProfileLineItem__c WHERE id =: bpliId];
        wr.fieldName = b.XC_SoldToContactId__r.AccountId;
        return wr;
    }

}