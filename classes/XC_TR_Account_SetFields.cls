public class XC_TR_Account_SetFields {
      /**
     * @author dpalamides
     * @date 18/01/2021
     * @description Set fields on before insert/update
     * @param listNew - List<Account>
    */
    public static void setFieldsBefore(List<Account> listNew) {
       
        for(Account account : listNew) {
            if(account.XC_IsBillingAgency__c == true) {
                account.XC_AccountType__c = 'Billing Agency';
            }
        }
       
    }

     /**
     * @author Marina Ciavarra - mciavarra@deloitte.it
     * @date 04/02/2021
     * @lastmodifiedby Nicola Arrigo - narrigo@deloitte.it
     * @lastmodifieddate 24/11/2021
     * @description Set picklist fields on before update
     * @param listNew - List<Account>
    */
    public static void setUpdateDocuments(List<Account> listNew,Map<Id, Account> mapOld) {
        for(Account newAccount : listNew) {       
            if(newAccount.XC_DocumentsUploadComplete__c &&
               !mapOld.get(newAccount.id).XC_DocumentsUploadComplete__c) {
                newAccount.XC_CompanyDocumentsStatus__c=Label.XC_CL_Account_UpdateDocuments;
                newAccount.XC_WorkerDocumentsStatus__c=Label.XC_CL_Account_UpdateDocuments;
            }
        } 
    }
}