/**
* @author Dimitris Karnavas
* @date Creation 08/06/2021
* @description XC_TR_Account_U_VATGroupManage – Util class for Account Trigger
*/
public without sharing class XC_TR_Account_U_VATGroupManage {

    /**
    * @author Dimitris Karnavas
    * @date Creation 08/06/2021
    * @description checkAccountVATGroup – confirms Account VAT Group is Gruppo IVA Enel by searching
    *               in the XC_AccountVatGroup__c custom object
    */
    private static void checkAccountVATGroup(List<Account> triggerNew, String groupVat){

        Map<String,String> compFiscalCodeMap = new Map<String,String>();
        Map<String,String> docNumberMap = new Map<String,String>();

        for(XC_AccountVatGroup__c record: [SELECT CompanyFiscalCode__c, IdentityNumber__c,VatGroupType__c FROM XC_AccountVatGroup__c WHERE VatGroupType__c =: groupVat]) {
            compFiscalCodeMap.put(record.CompanyFiscalCode__c,record.VatGroupType__c);
            docNumberMap.put(record.IdentityNumber__c,record.VatGroupType__c);
        }

        for(Account acc: triggerNew){

            //if fiscal code or doc number exist in given VAT group but Vat group type is different => give error
            if(((compFiscalCodeMap.containsKey(acc.XC_CompanyFiscalCode__c) && compFiscalCodeMap.get(acc.XC_CompanyFiscalCode__c) == groupVat) &&
                (docNumberMap.containsKey(acc.IdentityNumber__c) && docNumberMap.get(acc.IdentityNumber__c) == groupVat)) && 
                acc.XC_VatGroupType__c != groupVat){ 
                    acc.addError('The current account is included in '+ groupVat +'. Please insert '+ groupVat +' in the VAT Group Type field.');
            }
            //if fiscal code and doc number don't exist in given VAT group  => give error
            else if((compFiscalCodeMap.containsKey(acc.XC_CompanyFiscalCode__c) || docNumberMap.containsKey(acc.IdentityNumber__c)) &&
                    acc.XC_VatGroupType__c != groupVat){
                        acc.addError('The current Company Fiscal Code or Document Number is included in Gruppo Iva Enel. Please use a different Company Fiscal Code/Document Number.');
            }
            //if fiscal code and doc number don't exist in given VAT group  => give error
            else if((!compFiscalCodeMap.containsKey(acc.XC_CompanyFiscalCode__c) || !docNumberMap.containsKey(acc.IdentityNumber__c)) &&
                    acc.XC_VatGroupType__c == groupVat){
                        acc.addError('The current account is not included in '+ groupVat +'. Please insert another value for the VAT Group Type field.');
            }
        } 
    }

    /**
    * @author Dimitris Karnavas
    * @date Creation 08/06/2021
    * @description grouppoIvaEnelCheckFields – validates data on the Account inserted/updated that is included
    *               in the Gruppo IVA Enel
    */
    public static void grouppoIvaEnelCheckFields(List<Account> triggerNew){
        //holds only B2B/B2G accounts
        List<Account> enelGroupVatList = new List<Account>();
        
        for(Account acc : triggerNew){
            if(acc.XC_Segment__c == 'B2B' || acc.XC_Segment__c == 'B2G'){
                enelGroupVatList.add(acc);
            }
        }

        if(enelGroupVatList.size()>0){
            //holds accounts with no errors
            List<Account> accountsChecked = new List<Account>();

            for(Account acc : enelGroupVatList){
                if(acc.XC_VatGroupType__c == 'Gruppo IVA Enel' || acc.XC_VatGroupType__c == 'Gruppo IVA societario'){
                    //check doc number or comp fiscal code if empty
                    if(String.isBlank(acc.IdentityNumber__c) || String.isBlank(acc.XC_CompanyFiscalCode__c)){
                        acc.addError(Label.XC_CL_Account_Doc_FiscalCode_Required);
                    }
                    //if length not 11
                    else if(acc.IdentityNumber__c.length() != 11){
                        acc.IdentityNumber__c.addError(Label.XC_CL_Account_Values_Length);
                    }
                    else if(!String.isBlank(acc.XC_IdentityNumber2__c) && acc.XC_IdentityNumber2__c.length() != 11){
                        acc.XC_IdentityNumber2__c.addError(Label.XC_CL_Account_Values_Length);
                    }
                    else if(acc.XC_CompanyFiscalCode__c.length() != 11){
                        acc.XC_CompanyFiscalCode__c.addError(Label.XC_CL_Account_Values_Length);
                    }
                    //only grouppo iva enel trading partner check
                    else if(acc.XC_VatGroupType__c == 'Gruppo IVA Enel' && String.isBlank(acc.XC_TradingPartner__c)){
                        acc.XC_TradingPartner__c.addError(Label.XC_CL_Account_TradingPartnerRequired);
                    }
                    //check if doc type is not CF
                    else if(acc.IdentityType__c != 'CF'){
                        acc.IdentityType__c.addError(Label.XC_CL_Account_DocTypeCFRequired);
                    }
                    //check if doc type is CF but doc number and comp fiscal code are the same
                    else if(acc.IdentityType__c == 'CF' && acc.IdentityNumber__c == acc.XC_CompanyFiscalCode__c){
                        acc.addError(Label.XC_CL_Account_DocFiscalCodeNotEqual);
                    }
                }
                accountsChecked.add(acc);
            }
            checkAccountVATGroup(accountsChecked,'Gruppo IVA Enel');
        }
    }

}