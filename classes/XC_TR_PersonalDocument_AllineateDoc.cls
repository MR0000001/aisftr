/**
* @author Lorenzo Orlanducci lorenzo.orladucci@nttdata.com & Sara Miozza sara.miozza@nttdata.com
* @date Creation 03/07/2019
* @description XC_TR_PersonalDocument_AllineateDoc - Update the Document fields on Account, Primary Contact and Main Document
*/
public without sharing class XC_TR_PersonalDocument_AllineateDoc {

   /** 
    * @author Lorenzo Orlanducci lorenzo.orladucci@nttdata.com & Sara Miozza sara.miozza@nttdata.com
    * @date Creation 03/07/2019
    * @description Method to populate the Primary Contact fields or the Main Document fields when the Document Account fields are updated.
    * @param listNew - List<Account>
    * @param mapOld - Map<Id,Account> 
    * @param mapNew - Map<Id,Account> 
    */
     public static void populateAccountDocumentOnUpdate(List<Account> listNew, Map<Id,Account> mapOld, Map<Id,Account> mapNew) {
        List<String> fieldList = new List<String>{'IdentityNumber__c', 'IdentityType__c', 'XC_DocumentCountry__c', 'XC_NIE_expedition_date__c', 'XC_NIE_expiration_date__c'};
        List<Account> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        List<Account> residentialAcc = new List<Account>();
        if(!listChanged.isEmpty()){
             for(Account a : listChanged){
               if(XC_UTIL_Account.isResidential(a.RecordTypeId)){
                   residentialAcc.add(a);
               }
         }
        populateContactDocumentFromAccount(residentialAcc);
        populatePersonalDocumentFromAccount(residentialAcc);
        } 
        
    }
    
    /** 
    * @author Lorenzo Orlanducci lorenzo.orladucci@nttdata.com & Sara Miozza sara.miozza@nttdata.com
    * @date Creation 03/07/2019
    * @description Method to populate the Document primary contact fields from Account
    * @param accountList - List<Account>  
    */
    private static void populateContactDocumentFromAccount(List<Account> accountList){
        List<Contact> contactToUpdate = new List<Contact>();
        List<Id> accIds = XC_UTIL_Sobject.getIds(accountList);
        Map<Id,Account> contactIdToAccount = new Map<Id,Account>();
        List<Account> listAcc = [SELECT id,IdentityNumber__c,IdentityType__c,XC_DocumentCountry__c,XC_NIE_expiration_date__c,XC_NIE_expedition_date__c,
                                         (select id,XC_PrimaryContact__c from contacts WHERE XC_PrimaryContact__c = true limit 1) from account where id IN :  accIds];
        for(Account a : listAcc){
            if(!(a.contacts).isEmpty()){
            contactIdToAccount.put(a.contacts[0].Id,a);
            }
        } 
        for(Id i : contactIdToAccount.keySet()){
            Contact c = new Contact(Id = i);
            c.XC_ContactDocumentNumber__c = contactIdToAccount.get(i).IdentityNumber__c;
            c.XC_ContactDocumentType__c   = contactIdToAccount.get(i).IdentityType__c;
            c.XC_ContactDocumentCountry__c = contactIdToAccount.get(i).XC_DocumentCountry__c;
            c.XC_ContactDocExpirationDate__c = contactIdToAccount.get(i).XC_NIE_expiration_date__c;
            c.XC_ContactDocReleaseDate__c =  contactIdToAccount.get(i).XC_NIE_expedition_date__c; 
            contactToUpdate.add(c);
        }
        XC_UTIL_Sobject.updateListRecords(contactToUpdate);

    }

     /** 
    * @author Lorenzo Orlanducci lorenzo.orladucci@nttdata.com & Sara Miozza sara.miozza@nttdata.com
    * @date Creation 03/07/2019
    * @description Method to populate the Main Document fields from Account
    * @param accountList - List<Account>  
    */
     private static void populatePersonalDocumentFromAccount(List<Account> accountList){
         System.debug('Enter in populatePersonalDocumentFromAccount');
        List<XC_PersonalDocument__c> documentToUpdate = new List<XC_PersonalDocument__c>();
        List<Id> accIds = XC_UTIL_Sobject.getIds(accountList);
        Map<Id,Account> documentIdToAccount = new Map<Id,Account>();
        List<Account> listAcc = [SELECT id,IdentityNumber__c,IdentityType__c,XC_DocumentCountry__c,XC_NIE_expiration_date__c,XC_NIE_expedition_date__c,
                                         (SELECT id FROM Personal_Documents__r  WHERE XC_MainDocument__c = true limit 1) FROM account WHERE id IN :  accIds];
        for(Account a : listAcc){
            if(!(a.Personal_Documents__r).isEmpty()){
            documentIdToAccount.put(a.Personal_Documents__r[0].Id,a);
            }
        } 
        System.debug('MAIN PERSONAL DOC = '+documentIdToAccount);
        for(Id i : documentIdToAccount.keySet()){
            XC_PersonalDocument__c personalDoc = new XC_PersonalDocument__c(Id = i);
            personalDoc.XC_DocumentNumber__c = documentIdToAccount.get(i).IdentityNumber__c;
            personalDoc.XC_DocumentType__c   = documentIdToAccount.get(i).IdentityType__c;
            personalDoc.XC_Country__c = documentIdToAccount.get(i).XC_DocumentCountry__c;
            personalDoc.XC_ExpirationDate__c = documentIdToAccount.get(i).XC_NIE_expiration_date__c;
            personalDoc.XC_ReleaseDate__c =  documentIdToAccount.get(i).XC_NIE_expedition_date__c; 
            documentToUpdate.add(personalDoc);
        }
        XC_UTIL_Sobject.updateListRecords(documentToUpdate);

    }

    /** 
    * @author Lorenzo Orlanducci lorenzo.orladucci@nttdata.com & Sara Miozza sara.miozza@nttdata.com
    * @date Creation 03/07/2019
    * @description Method to populate the Account fields or the Main Document fields when the Document primary contact fields are updated.
    * @param listNew - List<Contact>
    * @param mapOld - Map<Id,Contact> 
    * @param mapNew - Map<Id,Contact> 
    */
    public static void populateContactDocumentOnUpdate(List<Contact> listNew, Map<Id,Contact> mapOld, Map<Id,Contact> mapNew) {
        System.debug('@@@Entrato in populateContactDocumentOnUpdate con ' +listNew); 
        List<String> fieldList = new List<String>{'XC_ContactDocumentNumber__c', 'XC_ContactDocumentType__c', 'XC_ContactDocumentCountry__c', 'XC_ContactDocExpirationDate__c', 'XC_ContactDocReleaseDate__c'};
        List<Contact> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        List<Contact> residentialCont = new List<Contact>();
        if(!listChanged.isEmpty()){
             for(Contact c : listChanged){
               if(checkResidentialContact(c)){
                   residentialCont.add(c);
               }
         }
        populateAccountFromContact(residentialCont);
        populatePersonalDocumentFromContact(residentialCont);
        } 
        
    }
    
    public static void checkIfAccountFieldNeedPop(List<XC_PersonalDocument__c> listNew){
        List<Account> accList = new   List<Account>();
            for(XC_PersonalDocument__c pd : listNew){
                if(pd.XC_AccountId__c!=null && pd.XC_MainDocument__c){
                    Account a = new Account(Id=pd.XC_AccountId__c);
                    a.IdentityNumber__c = pd.XC_DocumentNumber__c;
                    a.XC_DocumentCountry__c = pd.XC_Country__c;
                    a.XC_NIE_expiration_date__c = pd.XC_ExpirationDate__c;
                    a.XC_NIE_expedition_date__c = pd.XC_ReleaseDate__c;
                    a.IdentityType__c   = pd.XC_DocumentType__c;
                    accList.add(a);

                }
            }
            XC_UTIL_Sobject.updateListRecords(accList);
    }

     /** 
    * @author Lorenzo Orlanducci lorenzo.orladucci@nttdata.com & Sara Miozza sara.miozza@nttdata.com
    * @date Creation 03/07/2019
    * @description Method to populate the Main Document fields from Contact
    * @param contactList - List<Contact>  
    */
    private static void populatePersonalDocumentFromContact(List<Contact> contactList){
        List<XC_PersonalDocument__c> documentToUpdate = new List<XC_PersonalDocument__c>();
        List<Id> contIds = XC_UTIL_Sobject.getIds(contactList);
        Map<Id,Contact> documentIdToContact = new Map<Id,contact>();
        List<Contact> listCont = [SELECT id,XC_ContactDocumentNumber__c, XC_ContactDocumentType__c, XC_ContactDocumentCountry__c, XC_ContactDocExpirationDate__c, XC_ContactDocReleaseDate__c,
                                         (SELECT id FROM Personal_Documents__r  WHERE XC_MainDocument__c = true limit 1) FROM Contact WHERE id IN :  contIds];
        for(Contact c : listCont){
            if(!(c.Personal_Documents__r).isEmpty()){
            documentIdToContact.put(c.Personal_Documents__r[0].Id,c);
            }
        } 
        for(Id i : documentIdToContact.keySet()){
            XC_PersonalDocument__c personalDoc = new XC_PersonalDocument__c(Id = i);
            personalDoc.XC_DocumentNumber__c = documentIdToContact.get(i).XC_ContactDocumentNumber__c;
            personalDoc.XC_DocumentType__c   = documentIdToContact.get(i).XC_ContactDocumentType__c;
            personalDoc.XC_Country__c = documentIdToContact.get(i).XC_ContactDocumentCountry__c;
            personalDoc.XC_ExpirationDate__c = documentIdToContact.get(i).XC_ContactDocExpirationDate__c;
            personalDoc.XC_ReleaseDate__c =  documentIdToContact.get(i).XC_ContactDocReleaseDate__c; 
            documentToUpdate.add(personalDoc);
        }
        XC_UTIL_Sobject.updateListRecords(documentToUpdate);

    }

     /** 
    * @author Lorenzo Orlanducci lorenzo.orladucci@nttdata.com & Sara Miozza sara.miozza@nttdata.com
    * @date Creation 03/07/2019
    * @description Method to populate the Account fields from Contact
    * @param contactList - List<Contact>  
    */
    private static void populateAccountFromContact(List<Contact> contactList){
        List<Account> accountToUpdate = new List<Account>();
        List<Id> contIds = XC_UTIL_Sobject.getIds(contactList);
        List<Contact> listCont = [SELECT id,XC_PrimaryContact__c,XC_ContactDocumentNumber__c, XC_ContactDocumentType__c, XC_ContactDocumentCountry__c, XC_ContactDocExpirationDate__c, XC_ContactDocReleaseDate__c,AccountId
                                         FROM Contact WHERE id IN :  contIds AND XC_PrimaryContact__c = true];
       
        for(Contact c : listCont){
            Account acc = new Account(Id = c.AccountId);
            acc.IdentityNumber__c = c.XC_ContactDocumentNumber__c;
            acc.IdentityType__c   = c.XC_ContactDocumentType__c;
            acc.XC_DocumentCountry__c = c.XC_ContactDocumentCountry__c;
            acc.XC_NIE_expiration_date__c = c.XC_ContactDocExpirationDate__c;
            acc.XC_NIE_expedition_date__c =  c.XC_ContactDocReleaseDate__c; 
            accountToUpdate.add(acc);
        }
        XC_UTIL_Sobject.updateListRecords(accountToUpdate);
    }

     /** 
    * @author Lorenzo Orlanducci lorenzo.orladucci@nttdata.com & Sara Miozza sara.miozza@nttdata.com
    * @date Creation 03/07/2019
    * @description Method to populate the Account fields or the Primary Contact fields when the Main Personal Document fields are updated.
    * @param listNew - List<XC_PersonalDocument__c>
    * @param mapOld - Map<Id,XC_PersonalDocument__c> 
    * @param mapNew - Map<Id,XC_PersonalDocument__c> 
    */
    public static void populatePersonalDocumentOnUpdate(List<XC_PersonalDocument__c> listNew, Map<Id,XC_PersonalDocument__c> mapOld, Map<Id,XC_PersonalDocument__c> mapNew) {
        List<String> fieldList = new List<String>{'XC_DocumentNumber__c', 'XC_DocumentType__c', 'XC_Country__c', 'XC_ExpirationDate__c', 'XC_ReleaseDate__c'};
        List<XC_PersonalDocument__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        List<XC_PersonalDocument__c> mainDocuments = new List<XC_PersonalDocument__c>();
        if(!listChanged.isEmpty()){
             for(XC_PersonalDocument__c persDoc : listChanged){
               if(persDoc.XC_MainDocument__c){
                   mainDocuments.add(persDoc);
               }
         }
        populateAccountAndContatFromPersonalDocument(mainDocuments);
        } 
        
    }

    /** 
    * @author Lorenzo Orlanducci lorenzo.orladucci@nttdata.com & Sara Miozza sara.miozza@nttdata.com
    * @date Creation 03/07/2019
    * @description Method to populate the Account fields and the Contact fields from Personal Document
    * @param personalDocList - List<XC_PersonalDocument__c>  
    */
    private static void populateAccountAndContatFromPersonalDocument(List<XC_PersonalDocument__c> personalDocList){
        System.debug('@@@ Entrato in populateAccountAndContatFromPersonalDocument con '+personalDocList);
        Map<String, XC_PersonalDocument__c> accIdToPersonalDoc = new Map<String, XC_PersonalDocument__c>();
        List<Account> accountToUpdate = new List<Account>();
        List<Contact> contactToUpdate = new List<Contact>();
        for(XC_PersonalDocument__c persDoc : personalDocList){
                accIdToPersonalDoc.put(persDoc.XC_Account__c , persDoc);
        }
            List<Account> accountList = [SELECT Id, RecordTypeId, RecordType.DeveloperName,IdentityNumber__c, XC_DocumentCountry__c,XC_NIE_expiration_date__c,XC_NIE_expedition_date__c,IdentityType__c,
                                        (SELECT Id,XC_PrimaryContact__c FROM Contacts WHERE XC_PrimaryContact__c = true LIMIT 1)
                                        FROM Account WHERE Id IN: accIdToPersonalDoc.keySet()];
            for(Account a : accountList){
            System.debug('@@@@ Account Record type ' +a.RecordType.DeveloperName);
                if(a.RecordType.DeveloperName == 'XC_GLO_Account_Residential'){
                    a.IdentityNumber__c = accIdToPersonalDoc.get(a.Id).XC_DocumentNumber__c;
                    a.XC_DocumentCountry__c = accIdToPersonalDoc.get(a.Id).XC_Country__c;
                    a.XC_NIE_expiration_date__c = accIdToPersonalDoc.get(a.Id).XC_ExpirationDate__c;
                    a.XC_NIE_expedition_date__c = accIdToPersonalDoc.get(a.Id).XC_ReleaseDate__c;
                    a.IdentityType__c   = accIdToPersonalDoc.get(a.Id).XC_DocumentType__c;
                    accountToUpdate.add(a);
                    if(!a.Contacts.isEmpty()){
                        Contact con = new Contact(Id = accIdToPersonalDoc.get(a.Id).XC_Contact__c);
                        con.XC_ContactDocumentNumber__c = accIdToPersonalDoc.get(a.Id).XC_DocumentNumber__c;
                        con.XC_ContactDocumentType__c   = accIdToPersonalDoc.get(a.Id).XC_DocumentType__c;
                        con.XC_ContactDocumentCountry__c = accIdToPersonalDoc.get(a.Id).XC_Country__c;
                        con.XC_ContactDocExpirationDate__c = accIdToPersonalDoc.get(a.Id).XC_ExpirationDate__c;
                        con.XC_ContactDocReleaseDate__c =  accIdToPersonalDoc.get(a.Id).XC_ReleaseDate__c;
                        contactToUpdate.add(con); 
                    }

            }
        }
        XC_UTIL_Sobject.updateListRecords(accountToUpdate);
        XC_UTIL_Sobject.updateListRecords(contactToUpdate);
    }

    
    /** 
    * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
    * @date Creation 25/06/2020
    * @description Method to populate the Account fields or the Primary Contact fields when the Main Personal Document are inserted.
    * @param listNew - List<XC_PersonalDocument__c>
    */
    public static void populatePersonalDocumentOnInsert(List<XC_PersonalDocument__c> listNew) {

        List<XC_PersonalDocument__c> mainDocuments = new List<XC_PersonalDocument__c>();

        for(XC_PersonalDocument__c persDoc : listNew){
            if(persDoc.XC_MainDocument__c){
                mainDocuments.add(persDoc);
            }
        } 
        
        if(!mainDocuments.isEmpty()){
            populateAccountAndContatFromPersonalDocument(mainDocuments);
        }
    }


    /** 
    * @author Lorenzo Orlanducci lorenzo.orladucci@nttdata.com & Sara Miozza sara.miozza@nttdata.com
    * @date Creation 03/07/2019
    * @description Method to check if the contact record type is Residential
    * @param cont - Contact
    * @return isResidential - Boolean
    */
    private static Boolean checkResidentialContact(Contact cont){
        Boolean isResidential = false;
        if(Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Residential').getRecordTypeId()==cont.RecordTypeId){
            isResidential = true;
        }
        return isResidential;
    }

    /** 
    * @author Lorenzo Orlanducci lorenzo.orladucci@nttdata.com & Sara Miozza sara.miozza@nttdata.com
    * @date Creation 03/07/2019
    * @description Method to check the possibility to delete a Personal Document.
    * @param personalDocList - List<XC_PersonalDocument__c>
    * @param mapOld - Map<Id,XC_PersonalDocument__c> 
    */
    public static void checkPossibilityToDelete(List<XC_PersonalDocument__c> personalDocList, Map<Id, XC_PersonalDocument__c> mapOld){
        List<Account> accToUpdate = new List<Account>();
        List<Contact> conToUpdate = new List<Contact>();
        List<Id> docIds = XC_UTIL_Sobject.getIds(personalDocList);
        List<XC_PersonalDocument__c> listPersonalDoc = new List<XC_PersonalDocument__c>([SELECT Id,XC_MainDocument__c, XC_Account__c, XC_Contact__c,XC_Account__r.PrimaryEmail__c, 
                                                                                                    XC_Contact__r.Email,XC_Contact__r.XC_PrimaryContact__c, XC_Account__r.RecordTypeId
                                                                                        FROM XC_PersonalDocument__c WHERE Id IN : docIds]);
        for(XC_PersonalDocument__c doc : listPersonalDoc){
            if(XC_UTIL_Account.isResidential(doc.XC_Account__r.RecordTypeId) && doc.XC_MainDocument__c){
                if(doc.XC_Account__r.PrimaryEmail__c == null || doc.XC_Contact__r.Email == null){
                    XC_PersonalDocument__c persDoc = mapOld.get(doc.Id);
                    persDoc.addError(label.XC_CL_AccountAndContactMail);
                }else{
                    if(doc.XC_Contact__r.XC_PrimaryContact__c){
                    Account a = modifyAccountFields(doc.XC_Account__r.Id);
                    accToUpdate.add(a);
                    }
                    Contact c = modifyContactFields(doc.XC_Contact__r.Id);
                    conToUpdate.add(c);
                }
            }
        }
        XC_UTIL_Sobject.updateListRecords(accToUpdate);
        XC_UTIL_Sobject.updateListRecords(conToUpdate);
                                                                                         
    }

    /** 
    * @author Lorenzo Orlanducci lorenzo.orladucci@nttdata.com & Sara Miozza sara.miozza@nttdata.com
    * @date Creation 03/07/2019
    * @description Method to blank the document Account fields
    * @param accountId - String
    * @return acc - Account 
    */
    private static Account modifyAccountFields(String accountId){
        Account acc = new Account(Id=accountId, IdentityNumber__c = null, IdentityType__c = null, XC_DocumentCountry__c = null, XC_NIE_expiration_date__c = null, XC_NIE_expedition_date__c = null );
        return acc;
    }

     /** 
    * @author Lorenzo Orlanducci lorenzo.orladucci@nttdata.com & Sara Miozza sara.miozza@nttdata.com
    * @date Creation 03/07/2019
    * @description Method to blank the document Contact fields
    * @param contacttId - String
    * @return cont - Contact 
    */
    private static Contact modifyContactFields(String contactId){
        Contact cont = new Contact(Id=contactId, XC_ContactDocumentNumber__c = null, XC_ContactDocumentType__c = null, XC_ContactDocumentCountry__c = null, XC_ContactDocExpirationDate__c = null, XC_ContactDocReleaseDate__c = null );
        return cont;
    }

    /** 
    * @author Lorenzo Orlanducci lorenzo.orladucci@nttdata.com & Sara Miozza sara.miozza@nttdata.com
    * @date Creation 03/07/2019
    * @description Method to create a Personal Document from Account
    * @param listNew - List<Account>
    * @param mapOld - Map<Id,Account> 
    * @param mapNew - Map<Id,Account> 
    */
    public static void createDocumentInAccountEdit(List<Account> listNew, Map<Id,Account> mapOld,Map<Id,Account> mapNew){
        System.debug('@@@Entrato in createDocumentAccountEdit con ' +listNew);
        List<XC_PersonalDocument__c> persDocList = new List<XC_PersonalDocument__c>();
        for(Account a : listNew){
            if(XC_UTIL_Account.isResidential(a.RecordTypeId)){
                Boolean isNew = checkIfDocumentOnAccountIsNew(a,mapOld,mapNew);
                if(isNew){
                    XC_PersonalDocument__c persDoc = new XC_PersonalDocument__c(
                        XC_DocumentNumber__c = a.IdentityNumber__c,
                        XC_DocumentType__c   = a.IdentityType__c,
                        XC_Country__c = a.XC_DocumentCountry__c,
                        XC_ExpirationDate__c = a.XC_NIE_expiration_date__c,
                        XC_ReleaseDate__c =  a.XC_NIE_expedition_date__c,
                        XC_MainDocument__c = true,
                        XC_Account__c = a.Id
                    );
                    persDocList.add(persDoc);
            
                }
            }
        }
        XC_UTIL_Sobject.insertListRecords(persDocList);
    }

    /** 
    * @author Lorenzo Orlanducci lorenzo.orladucci@nttdata.com & Sara Miozza sara.miozza@nttdata.com
    * @date Creation 03/07/2019
    * @description Method to check if the Account has already a Personal Document
    * @param listNew - List<Account>
    * @param mapOld - Map<Id,Account> 
    * @param mapNew - Map<Id,Account> 
    * @return Boolean
    */
    private static Boolean checkIfDocumentOnAccountIsNew(Account a,Map<Id,Account> mapOld,Map<Id,Account> mapNew){
        if(mapOld.get(a.Id).XC_DocumentCountry__c == null && mapOld.get(a.Id).IdentityType__c == null && mapOld.get(a.Id).IdentityNumber__c == null
        && mapNew.get(a.Id).XC_DocumentCountry__c != null && mapNew.get(a.Id).IdentityType__c != null && mapNew.get(a.Id).IdentityNumber__c != null 
        && (a.Personal_Documents__r).isEmpty() ){
            return true;
        }else{
            return false;
        }
    }

    /** 
    * @author Lorenzo Orlanducci lorenzo.orladucci@nttdata.com & Sara Miozza sara.miozza@nttdata.com
    * @date Creation 03/07/2019
    * @description Method to create a Personal Document from Contact
    * @param listNew - List<Contact>
    * @param mapOld - Map<Id,Contact> 
    * @param mapNew - Map<Id,Contact> 
    */
    public static void createDocumentInContactEdit(List<Contact> listNew, Map<Id,Contact> mapOld,Map<Id,Contact> mapNew){
        System.debug('@@@Entrato in createDocumentInContactEdit con ' +listNew);
        List<XC_PersonalDocument__c> persDocList = new List<XC_PersonalDocument__c>();
        for(Contact c : listNew){
            if(checkResidentialContact(c) ){
                Boolean isNew = checkIfDocumentOnContactIsNew(c,mapOld,mapNew);
                if(isNew){
                    XC_PersonalDocument__c persDoc = new XC_PersonalDocument__c(
                        XC_DocumentNumber__c = c.XC_ContactDocumentNumber__c,
                        XC_DocumentType__c   = c.XC_ContactDocumentType__c,
                        XC_Country__c = c.XC_ContactDocumentCountry__c,
                        XC_ExpirationDate__c = c.XC_ContactDocExpirationDate__c,
                        XC_ReleaseDate__c =  c.XC_ContactDocReleaseDate__c,
                        XC_MainDocument__c = true,
                        XC_Contact__c = c.Id);

                        if(c.XC_PrimaryContact__c){
                            persDoc.XC_AccountId__c = c.AccountId;
                        }
                    
                    persDocList.add(persDoc);
            
                }
            }
        }
        XC_UTIL_Sobject.insertListRecords(persDocList);
    }

    /** 
    * @author Lorenzo Orlanducci lorenzo.orladucci@nttdata.com & Sara Miozza sara.miozza@nttdata.com
    * @date Creation 03/07/2019
    * @description Method to check if the Contact has already a Personal Document
    * @param listNew - List<Contact>
    * @param mapOld - Map<Id,Contact> 
    * @param mapNew - Map<Id,Contact> 
    * @return Boolean
    */
    private static Boolean checkIfDocumentOnContactIsNew(Contact cont, Map<Id,Contact> mapOld,Map<Id,Contact> mapNew){
        if(mapOld.get(cont.Id).XC_ContactDocumentCountry__c == null && mapOld.get(cont.Id).XC_ContactDocumentType__c == null && mapOld.get(cont.Id).XC_ContactDocumentNumber__c == null
        && mapNew.get(cont.Id).XC_ContactDocumentCountry__c != null && mapNew.get(cont.Id).XC_ContactDocumentType__c != null && mapNew.get(cont.Id).XC_ContactDocumentNumber__c != null){
            return true;
        }else{
            return false;
        }
    }

     /** 
    * @author Lorenzo Orlanducci lorenzo.orladucci@nttdata.com & Sara Miozza sara.miozza@nttdata.com
    * @date Creation 03/07/2019
    * @description Method to popultate the Personal Document lookup on Contact
    * @param listNew - List<XC_PersonalDocument__c>
    */
    public static void populateContactLookupOnMainDocument(List<XC_PersonalDocument__c> listNew){
        Map<Id,XC_PersonalDocument__c> accIdToPersonalDoc = new Map<Id,XC_PersonalDocument__c>();
        for(XC_PersonalDocument__c pd : listNew){
            accIdToPersonalDoc.put(pd.XC_Account__c,pd);
        }
        List<Account> accList = new List<Account>([SELECT Id,XC_RecordTypeDeveloperName__c, (SELECT Id,XC_PrimaryContact__c FROM Contacts WHERE XC_PrimaryContact__c = true LIMIT 1) 
                                                    FROM Account WHERE Id IN : accIdToPersonalDoc.keySet()]);
        for(Account acc : accList){
            if(/*accIdToPersonalDoc.get(acc.Id).XC_MainDocument__c &&*/ acc.XC_RecordTypeDeveloperName__c == 'XC_GLO_Account_Residential' && accIdToPersonalDoc.get(acc.Id).XC_Account__c!=null && accIdToPersonalDoc.get(acc.Id).XC_Contact__c == null){
                if(!acc.Contacts.isEmpty()){
                    accIdToPersonalDoc.get(acc.Id).XC_Contact__c = acc.Contacts[0].Id;
                }

            }
        }
    }

    
     /** 
    * @author Lorenzo Orlanducci lorenzo.orladucci@nttdata.com & Sara Miozza sara.miozza@nttdata.com
    * @date Creation 03/07/2019
    * @description Method to popultate the Personal Document lookup on Account
    * @param listNew - List<XC_PersonalDocument__c>
    */
    public static void populateAccountLookupOnMainDocument(List<XC_PersonalDocument__c> listNew){
        Map<Id,XC_PersonalDocument__c> contIdToPersonalDoc = new Map<Id,XC_PersonalDocument__c>();
        for(XC_PersonalDocument__c pd : listNew){
            contIdToPersonalDoc.put(pd.XC_Contact__c,pd);
        }
        List<Contact> contList = new List<Contact>([SELECT Id,XC_RecordTypeDeveloperName__c,AccountId, XC_PrimaryContact__c
                                                    FROM Contact WHERE Id IN : contIdToPersonalDoc.keySet() AND XC_PrimaryContact__c = true]);
        for(Contact cont : contList){
            if(/*contIdToPersonalDoc.get(cont.Id).XC_MainDocument__c &&*/ cont.XC_RecordTypeDeveloperName__c == 'XC_GLO_Contact_Residential' && contIdToPersonalDoc.get(cont.Id).XC_Account__c==null && contIdToPersonalDoc.get(cont.Id).XC_Contact__c != null){ 
                contIdToPersonalDoc.get(cont.Id).XC_Account__c = cont.AccountId;
            }
        }
    }
}