/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Domenico Del Prete - domenico.delprete@nttdata.com
* @date Creation 16/07/2019
* @description XC_LCC122_LeadConversion_CheckDocument – Check Personal Document for XC_LCP122_LeadConversion
*/ 

public without sharing class XC_LCC122_LeadConversion_CheckDocument {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC122_LeadConversion');

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Valeria Martino - valeria.martino@nttdata.com
                                                                & Domenico Del Prete - domenico.delprete@nttdata.com
    * @date Creation 02/07/2019
    * @description Method to upsert Personal Document for Resiential
    * @param contactLead - Contact
    * @param accountLead - Account
    * @param ld - Lead
    * @param List<XC_UTIL_Sobject.WrapperResult>
    * @return XC_UTIL_Sobject.WrapperResult
    */ 
    public static XC_UTIL_Sobject.WrapperResult checkPersonalDocumentResidential(Contact contactLead, Account accountLead, Lead ld) {
        if(String.isBlank(ld.XC_DocumentNumber__c) && String.isBlank(ld.XC_DocumentType__c)) {
            return null;
        }

        List<XC_PersonalDocument__c> listPersonalDocument = new List <XC_PersonalDocument__c> ([SELECT XC_DocumentType__c, XC_DocumentNumber__c, XC_Country__c 
                                                                                                FROM XC_PersonalDocument__c
                                                                                                WHERE XC_Account__c=:accountLead.id OR XC_Contact__c=:contactLead.id]);                                                                                   
        Boolean documentFound = false;
        for(XC_PersonalDocument__c documentContactAccount : listPersonalDocument) {
            if(documentContactAccount.XC_DocumentType__c == ld.XC_DocumentType__c && 
                documentContactAccount.XC_DocumentNumber__c == ld.XC_DocumentNumber__c && 
                documentContactAccount.XC_Country__c == ld.XC_DocumentCountry__c) {
                    documentFound = true;
                    break;
            }
        }
        if(!documentFound) {
            XC_PersonalDocument__c documentContactAccount = new XC_PersonalDocument__c();
            documentContactAccount.XC_Account__c = accountLead.Id; 
            documentContactAccount.XC_Contact__c = contactLead.Id;
            documentContactAccount.XC_DocumentType__c = ld.XC_DocumentType__c;
            documentContactAccount.XC_DocumentNumber__c = ld.XC_DocumentNumber__c;
            documentContactAccount.XC_Country__c = ld.XC_DocumentCountry__c;
            documentContactAccount.XC_ExpirationDate__c = ld.XC_NIE_expiration_date__c; 
            documentContactAccount.XC_ReleaseDate__c = ld.XC_NIE_expedition_date__c;
            if(listPersonalDocument.isEmpty()){
                documentContactAccount.XC_MainDocument__c = true;
            }
            return XC_UTIL_sObject.insertRecord(documentContactAccount);
        }
        return null;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Domenico Del Prete - domenico.delprete@nttdata.com
    * @date Creation 04/07/2019
    * @description Method to upsert Personal Document for Record Type Soho and Condominium
    * @param contactLead - Contact
    * @param accountLead - Account 
    * @param ld - Lead
    * @return List<XC_UTIL_Sobject.WrapperResult>
    */ 

    public static List<XC_UTIL_Sobject.WrapperResult> checkPersonalDocumentSohoCondominium(Contact contactLead, Account accountLead, Lead ld){
        if(String.isBlank(ld.XC_CDocNumber__c) && String.isBlank(ld.XC_CDocType__c)) {
            return null;
        }

        List<XC_PersonalDocument__c> listPersonalDocument = new List <XC_PersonalDocument__c> ([SELECT XC_DocumentType__c, XC_DocumentNumber__c, XC_Country__c, XC_Account__c 
                                                                                                FROM XC_PersonalDocument__c
                                                                                                WHERE XC_Account__c=:accountLead.id OR XC_Contact__c=:contactLead.id]);                                                                                   
         
        List<XC_PersonalDocument__c> listPersonalDocumentAccount = new List <XC_PersonalDocument__c>();
        List<XC_PersonalDocument__c> listPersonalDocumentContact = new List <XC_PersonalDocument__c>();
        for(XC_PersonalDocument__c document : listPersonalDocument) {
            if(document.XC_Account__c != null) {
                listPersonalDocumentAccount.add(document);
            } else {
                listPersonalDocumentContact.add(document);
            }
        }
        List<XC_PersonalDocument__c> listDocumentContactAccount = new List<XC_PersonalDocument__c>();
        
        // For Account:
        listDocumentContactAccount.addAll(checkDocumentForAccount(accountLead, listPersonalDocumentAccount, ld));

        // For Contact:
        listDocumentContactAccount.addAll(checkDocumentForContact(contactlead, listPersonalDocumentContact, ld));

        List<XC_UTIL_Sobject.WrapperResult> listDmlResult = XC_UTIL_Sobject.insertListRecords(listDocumentContactAccount);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@errorMessage:'+listDmlResult[0].errorMessage);
        return listDmlResult;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Domenico Del Prete - domenico.delprete@nttdata.com
    * @date Creation 04/07/2019
    * @description Method to check Personal Document for Record Type Soho and Condominium by Contact
    * @param contactLead - Contact
    * @param listPersonalDocumentContact - List<XC_PersonalDocument__c>
    * @param ld - Lead
    * @return List<XC_PersonalDocument__c>
    */ 
    private static List<XC_PersonalDocument__c> checkDocumentForContact(Contact contactLead, List<XC_PersonalDocument__c> listPersonalDocumentContact, Lead ld) {
        Boolean documentFound = false;
        List<XC_PersonalDocument__c> listDocumentContactAccount = new List<XC_PersonalDocument__c>();
        for(XC_PersonalDocument__c documentContact : listPersonalDocumentContact) {
            if(documentContact.XC_DocumentType__c == ld.XC_CDocType__c && 
                documentContact.XC_DocumentNumber__c == ld.XC_CDocNumber__c && 
                documentContact.XC_Country__c == ld.XC_CDocCountry__c) {
                    documentFound = true;
                    break;
            }
        } 
        if(!documentFound) {
            XC_PersonalDocument__c documentContact = new XC_PersonalDocument__c();
            documentContact.XC_Contact__c = contactLead.Id;
            documentContact.XC_DocumentType__c = ld.XC_CDocType__c; 
            documentContact.XC_DocumentNumber__c = ld.XC_CDocNumber__c;
            documentContact.XC_Country__c = ld.XC_CDocCountry__c;
            documentContact.XC_ExpirationDate__c = ld.XC_ContactDocumentExpirationDate__c; 
            documentContact.XC_ReleaseDate__c = ld.XC_ContacDocumentReleaseDate__c;
            if(listPersonalDocumentContact.isEmpty()){
                documentContact.XC_MainDocument__c = true;
            }
            listDocumentContactAccount.add(documentContact);
        }
        return listDocumentContactAccount;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Domenico Del Prete - domenico.delprete@nttdata.com
    * @date Creation 04/07/2019
    * @description Method to check Personal Document for Record Type Soho and Condominium by Account
    * @param accountLead - Account
    * @param listPersonalDocumentAccount - List<XC_PersonalDocument__c>
    * @param ld - Lead
    * @return List<XC_PersonalDocument__c>
    */ 
    private static List<XC_PersonalDocument__c> checkDocumentForAccount(Account accountLead, List<XC_PersonalDocument__c> listPersonalDocumentAccount, Lead ld) {
        Boolean documentFound = false;
        List<XC_PersonalDocument__c> listDocumentContactAccount = new List<XC_PersonalDocument__c>();
        for(XC_PersonalDocument__c documentAccount : listPersonalDocumentAccount) {
            if(documentAccount.XC_DocumentType__c == ld.XC_DocumentType__c && 
                documentAccount.XC_DocumentNumber__c == ld.XC_DocumentNumber__c && 
                documentAccount.XC_Country__c == ld.XC_DocumentCountry__c) {
                    documentFound = true;
                    break;
            }
        }
        if(!documentFound) {
            XC_PersonalDocument__c documentAccount = new XC_PersonalDocument__c();
            documentAccount.XC_Account__c = accountLead.Id; 
            documentAccount.XC_DocumentType__c = ld.XC_DocumentType__c;
            documentAccount.XC_DocumentNumber__c = ld.XC_DocumentNumber__c;
            documentAccount.XC_Country__c = ld.XC_DocumentCountry__c;
            documentAccount.XC_ExpirationDate__c = ld.XC_NIE_expiration_date__c; 
            documentAccount.XC_ReleaseDate__c = ld.XC_NIE_expedition_date__c;
            if(listPersonalDocumentAccount.isEmpty()){
                documentAccount.XC_MainDocument__c = true;
            }
            listDocumentContactAccount.add(documentAccount);
        }
        return listDocumentContactAccount;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 31/10/2019
    * @description Method to update Lead Document for converted Account
    * @param ld - Lead
    * @param accountLead - Account
    * @return List<XC_UTIL_Sobject.WrapperResult>
    */ 
    public static List<XC_UTIL_Sobject.WrapperResult> updateLeadDocument(Lead ld, Account accountLead) {
        List<XC_LeadDocument__c> listDocumentToUpdate = new List<XC_LeadDocument__c>();
        List<XC_LeadDocument__c> listDocuments = new List<XC_LeadDocument__c>([
            SELECT Id
            FROM XC_LeadDocument__c
            WHERE XC_LeadId__c = :ld.Id
        ]);

        for(XC_LeadDocument__c ldoc : listDocuments) {
            XC_LeadDocument__c leadDocumentToUpdate = new XC_LeadDocument__c(
                Id = ldoc.Id,
                XC_AccountId__c = accountLead.Id,
                XC_LeadId__c = null
            );
            listDocumentToUpdate.add(leadDocumentToUpdate);
        }

        return XC_UTIL_Sobject.updateListRecords(listDocumentToUpdate);
    }

}