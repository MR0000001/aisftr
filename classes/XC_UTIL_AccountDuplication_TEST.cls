/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 29/06/2019
* @date Modification dd/mm/yyyy
* @description  – XC_UTIL_AccountDuplication_TEST - Class test for XC_UTIL_AccountDuplication
*/
@isTest
private class XC_UTIL_AccountDuplication_TEST {
    @TestSetup
    static void insertRecords(){
        Test.startTest();
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org; 
        String recordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();
        List<Account> accountListToInsert = XC_DF_Account.createResidentialAccounts(1);
        Account exAccount = accountListToInsert[0];
        exAccount.RecordTypeId = recordTypeID;
        exAccount.PrimaryEmail__c = 'testtest@testaccount.it';
        exAccount.IdentityNumber__c = '98716216';
        exAccount.IdentityType__c = 'Passport';
        insert exAccount;
        
        List<Lead> leadListToInsert = XC_DF_Lead.createResidentialLeads(1);
        Lead exLead =leadListToInsert[0];
        exLead.XC_DocumentCountry__c = 'Spain';
        exLead.Email = 'testtest@testaccount.it';
        exLead.XC_DocumentType__c = 'Passport';
        exLead.XC_DocumentNumber__c = '98716216';
        exLead.XC_MainLegalEntity__c = 'EndesaX';
        exLead.FirstName = 'LeadTest';
        exLead.LastName= 'LeadTest';
        exLead.XC_PhonePrefix__c='+39';
        exLead.XC_LeadPhone__c= '0817898789';
        insert leadListToInsert;
        
        XC_ProductCategoryOfInterest__c prodCat = XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
        prodCat.Name = 'Caldera';
        insert prodCat; 
        //Test.stopTest();

        recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Soho').getRecordTypeId();
        String recordTypeIdString = recordTypeId;

        Map<String, String> mapAccountFields = new Map<String, String>{
            'Name'=>'testSoho',
            'Company__c'=>'testSoho',
            'XC_FirstName__c' => 'test',
            'XC_LastName__c' => 'test',
            'XC_AccountPhonePrefix__c' => '',
            'XC_AccountPhone__c' => null,
            'XC_MainPhonePrefix__c' => '',
            'XC_AccountMainPhone__c' => null,
            'PrimaryEmail__c' => 'test@tes.te',
            'XC_BirthDate__c' => null,
            'XC_Preference_Language__c' => '',
            'XC_AccountNationality__c' => '',
            'XC_Notes__c' => null,
            'XC_DocumentCountry__c' => 'Spain',
            'IdentityType__c' => 'NIF',
            'IdentityNumber__c' => '00533739R',
            'XC_NIE_expedition_date__c' => '2019-01-01',
            'XC_NIE_expiration_date__c' => '2030-12-30',
            'XC_DocumentCountry__c' => 'Spain',
            'XC_ReceivingChannel__c' => 'Email',
            'OwnerId' => UserInfo.getUserId()
        };
                    
        Map<String, Object> mapAddressFields = new Map<String, Object>{
            'country' => 'Spain',
            'streetType' => 'Access',
            'address' => 'test',
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'municipality' => 'test',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true
        };

        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LeCountry__c' => 'Spain',
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_GiveDataTo__c' => 'Yes',
            'XC_KeepMeUpdateOnProducts__c' => 'Yes',
            'XC_GiveConsentToDataProcessing__c' => 'Yes'
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);
                     
        Map<String, Object> mapContactFields = new Map<String, Object>{
            'FirstName' => 'a',
            'LastName' => 'b',
            'DocumentCountry' => 'Spain',
            'DocumentType' => 'Passport',
            'DocumentID' => '00533738',
            'Email' => 'test@test.email',
            'Mobile' => '',
            'Phone' => ''
        };

        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.legalEntity = 'EndesaX';
        leWrapper.country = 'Spain';
        leWrapperList.add(leWrapper);
                      
        Map<String, Object> mapAccountByComponent = new Map<String, Object>{
            'addressFields' => JSON.serialize(mapAddressFields),
            'assignRecord' => false,
            'contactFields' => JSON.serialize(mapContactFields),
            'fieldMapStringAccount' => JSON.serialize(mapAccountFields),
            'existingAccountId' => null,
            'recordTypeId' => recordTypeId,
            'isCommunity' => false,
            'robinsonCustomer' => true,
            'consentsLE' => JSON.serialize(leConsents),
            'withoutValidate' => false,
            'consentsWrapper' => JSON.serialize(leWrapperList)
        }; 
        String mapAccountString = JSON.serialize(mapAccountByComponent);
        System.debug('setup  mapAccountString ' + mapAccountString);
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk = XC_LCC003_NewAccount.createRecord(mapAccountString);
        System.debug('@@@@@ setup wrOk-->  '+ wrOk);
        Contact secConSoho = XC_DF_Contact.createSohoContacts(new List<Account>{new Account(Id=wrOk.recordId)})[0];
        secConSoho.XC_PrimaryContact__c = false;
        insert secConSoho;

        List<Account> accList = [SELECT ID, PrimaryEmail__c FROM ACCOUNT LIMIT 1];       
        accList[0].PrimaryEmail__c = 'test@te.it';
        update accList[0];
        XC_TR_Account_U_CheckDuplicates_D.getAccountInEmailList(new List<Account>{});
        XC_TR_Account_U_CheckDuplicates_D.getAccountInFiscalCodeList(new List<Account>{});
        Test.stopTest();
    }
    
    @isTest
    static void accountDuplicatedWithAddressAndProduct(){
        String recordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();
        List<Account> newAccountList = XC_DF_Account.createResidentialAccounts(1);
        Account newAccount =  newAccountList[0];
        newAccount.recordTypeID = recordTypeID;
        newAccount.PrimaryEmail__c = 'testtest@testaccount.it';
        newAccount.IdentityNumber__c = '98716216';
        newAccount.IdentityType__c = 'Passport';
        List<Account> newAccountListOk = new List<Account>();
        newAccountListOk.add(newAccount);
        Test.startTest();
        XC_UTIL_AccountDuplication.checkExistingAccount(newAccountListOk[0], 0);
        System.assert(newAccount != null);
        Test.stopTest(); 
    }
    
    @isTest
    static void accountAndContact(){
        List<Account> exAccount = [SELECT Id FROM Account LIMIT 1];
        String recordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();
        List<Contact> newContactList = XC_DF_Contact.createResidentialContacts(exAccount);
        String recordTypeIDcontact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Residential').getRecordTypeId();
        Contact cont = newContactList[0];
        cont.recordTypeId = recordTypeIDcontact;
        insert cont;
        List<Account> newAccountList = XC_DF_Account.createResidentialAccounts(1);
        Account newAccount =  newAccountList[0];
        newAccount.recordTypeID = recordTypeID;
        newAccount.PrimaryEmail__c = 'testtest@testaccount.it';
        newAccount.IdentityNumber__c = '98716216';
        newAccount.IdentityType__c = 'Passport';
        newAccount.XC_GiveDataTo_EndesaX__c = true;
        List<Account> newAccountListOk = new List<Account>();
        newAccountListOk.add(newAccount);
        Test.startTest();
        XC_UTIL_AccountDuplication.checkExistingAccounts(newAccountListOk, 0);
        insert newAccountListOk;
        XC_UTIL_AccountDuplication_U.getConsents('');
        Test.stopTest();
        System.assert(newAccount != null);
    } 

   /* @isTest
    static void troughLeadConversion(){
        List<Account> exAccount = [SELECT Id FROM Account LIMIT 2];
        List<Lead> leadListToInsert = XC_DF_Lead.createResidentialLeads(1);
        Lead newLead =leadListToInsert[0];
        newLead.XC_DocumentCountry__c = 'Spain';
        String recordTypeIDlead = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Lead_Residential).getRecordTypeId();
        newLead.recordTypeId  = recordTypeIDlead;
        newLead.Email = 'testtest@testlead.it';
        newLead.XC_DocumentType__c = 'Passport';
        newLead.XC_DocumentNumber__c = '987114126';
        newLead.XC_CDocCountry__c = 'Spain';
        newLead.XC_CDocType__c = 'Passport';
        newLead.XC_CDocNumber__c = '987114126';
        newLead.XC_MainLegalEntity__c = 'EndesaX';
        newLead.FirstName = 'LeadTestOk';
        newLead.LastName= 'LeadTestOk';
        newLead.XC_PhonePrefix__c='+39';
        newLead.XC_LeadPhone__c= '0817898781';
        newLead.Status = Label.XC_CL_Lead_CustomerContacted;
        newLead.XC_ProductCategoryOfInterest__c = 'Caldera';
        insert newLead;

        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(exAccount);
        Contact cont2 = contactList[0];
        String recordTypeIDcontact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Residential').getRecordTypeId();
        cont2.recordTypeId = recordTypeIDcontact;
        cont2.Email = 'testtest@testlead.it';
        cont2.XC_ContactDocumentCountry__c = 'Spain';
        cont2.XC_ContactDocumentType__c = 'Passport';
        cont2.XC_ContactDocumentNumber__c = '987114126';
        cont2.XC_MainLegalEntity__c = 'EndesaX';
        insert cont2;

        XC_UTIL_AccountDuplication_W.CheckFieldWrapper fieldWrapper = new XC_UTIL_AccountDuplication_W.CheckFieldWrapper();
        fieldWrapper.setEmail = new Set<String>{newLead.Email};
        fieldWrapper.setPrefix = new Set<String>{newLead.XC_PhonePrefix__c};
        fieldWrapper.setPhone = new Set<String>{newLead.XC_LeadPhone__c};
        fieldWrapper.setFirstName = new Set<String>{newLead.FirstName};
        fieldWrapper.setLastName = new Set<String>{newLead.LastName};
        fieldWrapper.setDocumentType = new Set<String>{newLead.XC_DocumentType__c};
        fieldWrapper.setDocumentNumber = new Set<String>{newLead.XC_DocumentNumber__c};
        fieldWrapper.setProductCategories = new Set<String>{newLead.XC_ProductCategoryOfInterest__c};
        fieldWrapper.setAddresses = new Set<String>{newLead.XC_Address__c};
        fieldWrapper.setLegalEntity = new Set<String>{newLead.XC_MainLegalEntity__c};
        fieldWrapper.setId = new Set<String>{newLead.Id}; 

        XC_UTIL_AccountDuplication_W.CheckAccountWrapper checkContactWrapper = XC_UTIL_AccountDuplication.checkExistingContact(fieldWrapper, XC_UTIL_AccountDuplication.LEAD_CONVERSION, recordTypeIdContact);
        Test.startTest(); 

        Account exAccount1 = new Account();
        exAccount1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();
        exAccount1.name = 'Test Test';
        exAccount1.PrimaryEmail__c = 'testtest@testaccount.it';
        exAccount1.IdentityNumber__c = '98716216';
        exAccount1.IdentityType__c = 'Passport';
        //insert exAccount1;

        XC_UTIL_AccountDuplication_W.CheckAccountWrapper checkExist= XC_UTIL_AccountDuplication.checkExistingAccount(exAccount1, 1);
        
        Test.stopTest();

        Contact cnt = [SELECT id, IndividualId from Contact where id = :cont2.id limit 1];
        XC_LegalEntityConsent__c legEnt = new XC_LegalEntityConsent__c();
        legEnt.XC_GiveDataToNew__c = 'Yes';
        legEnt.XC_LeCountry__c = 'Spain';
        legEnt.XC_LegalEntity__c = 'EndesaX';
        legEnt.XC_Individual__c = cnt.IndividualId;
        XC_UTIL_Sobject.WrapperResult wrapp= XC_UTIL_Sobject.insertRecord(legEnt);
        //insert legEnt;
        System.debug('wrapp =>' +wrapp);
        List<XC_LegalEntityConsent__c> listConsent = XC_UTIL_AccountDuplication_U.getConsents(cnt.IndividualId);
        XC_UTIL_AccountDuplication_W.CheckFieldWrapper checkfieldwr= XC_UTIL_AccountDuplication_U.populateCheckFieldWrapper(contactList);
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();

        Map<String, String> mapAccountFields = new Map<String, String>{
            'XC_CondominiumName__c' => 'test',
            'PrimaryEmail__c' => 'test@te.it', 
            'XC_AccountPhonePrefix__c' => '',
            'XC_AccountPhone__c' => null,
            'XC_MainPhonePrefix__c' => '',
            'XC_AccountMainPhone__c' => null,
            'b2ec__Birthdate__c' => null,
            'XC_Preference_Language__c' => '',
            'XC_Nationality__c' => '',
            'XC_Notes__c' => null,
            'XC_DocumentCountry__c' =>'',
            'IdentityType__c'=> 'NIF',
            'IdentityNumber__c'=> '60633939M',
            'XC_NIE_expedition_date__c'=> '2019-01-01',
            'XC_NIE_expiration_date__c'=> '2049-01-01',
            'XC_PhonePrefix__c'=> '',
            'XC_MobilePrefix__c'=> '',
            'XC_ContactPhone__c'=> null,
            'XC_ContactMobile__c'=> null,
            'XC_ReceivingChannel__c' => 'Email',
            'OwnerId' => UserInfo.getUserId()
        }; 
                    
        Map<String, Object> mapAddressFields = new Map<String, Object>{
            'country' => 'Spain',
            'streetType' => 'Access',
            'address' => 'test',
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'municipality' => 'test',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true
        };

        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LeCountry__c' => 'Spain',
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_GiveDataTo__c' => 'Yes',
            'XC_KeepMeUpdateOnProducts__c' => 'Yes',
            'XC_GiveConsentToDataProcessing__c' => 'Yes'
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);

        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.legalEntity = 'EndesaX';
        leWrapper.country = 'Spain';
        leWrapperList.add(leWrapper);
                    
        Map<String, Object> mapContactFields = new Map<String, Object>{
            'FirstName' => 'Test',
            'LastName' => 'Contact',
            'DocumentType' => 'Passport',
            'DocumentID' => 'Z0682891A',
            'Email' => 'test@contact.it',
            'Mobile' => '',
            'Phone' => ''
        }; 
                                
        Map<String, Object> mapAccountByComponent = new Map<String, Object>{
            'addressFields' => JSON.serialize(mapAddressFields),
            'assignRecord' => false,
            'contactFields' => JSON.serialize(mapContactFields),
            'fieldMapStringAccount' => JSON.serialize(mapAccountFields),
            'existingAccountId' => null,
            'recordTypeId' => recordTypeId,
            'robinsonCustomer' => true,
            'isCommunity' => false,
            'consentsLE' => JSON.serialize(leConsents),          
            'consentsWrapper' => JSON.serialize(leWrapperList)
        }; 
        String mapAccountString = JSON.serialize(mapAccountByComponent);
        System.debug(' mapAccountString ' + mapAccountString);
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk = XC_LCC003_NewAccount.createRecord(mapAccountString);
        System.debug('@@@@@ wrOk-->  '+ wrOk);
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk1 = XC_LCC003_NewAccount.createRecord(mapAccountString);
        System.assert(wrOk != null);
    }*/

    @IsTest
    static void test1(){
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();
        String recordTypeIdString = recordTypeId;
        Test.startTest();        
        Map<String, String> mapAccountFields = new Map<String, String>{
            'XC_FirstName__c' => 'test',
            'XC_LastName__c' => 'test',
            'XC_AccountPhonePrefix__c' => '',
            'XC_AccountPhone__c' => null,
            'XC_MainPhonePrefix__c' => '',
            'XC_AccountMainPhone__c' => null,
            'PrimaryEmail__c' => 'test1@te.it',
            'XC_BirthDate__c' => null,
            'XC_Preference_Language__c' => '',
            'XC_AccountNationality__c' => '',
            'XC_Notes__c' => null,
            'XC_DocumentCountry__c' => 'Andorra',
            'IdentityType__c' => 'Passport',
            'IdentityNumber__c' => 'testtesttesttest',
            'XC_NIE_expedition_date__c' => '2019-01-01',
            'XC_NIE_expiration_date__c' => '2030-12-30',
            'XC_DocumentCountry__c' => 'Spain',
            'XC_ReceivingChannel__c' => 'Email',
            'OwnerId' => UserInfo.getUserId()
        };
                    
        Map<String, Object> mapAddressFields = new Map<String, Object>{
            'country' => 'Spain',
            'streetType' => 'Access',
            'address' => 'test',
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'municipality' => 'test',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true
        };

        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LeCountry__c' => 'Spain',
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_GiveDataTo__c' => 'Yes',
            'XC_KeepMeUpdateOnProducts__c' => 'Yes',
            'XC_GiveConsentToDataProcessing__c' => 'Yes'
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);
                     
        Map<String, Object> mapContactFields = new Map<String, Object>{
            'FirstName' => 'a',
            'LastName' => 'b',
            'DocumentCountry' => 'Spain',
            'DocumentType' => 'Passport',
            'DocumentID' => '123654789',
            'Email' => '',
            'Mobile' => '',
            'Phone' => ''
        }; 
                      
        Map<String, Object> mapAccountByComponent = new Map<String, Object>{
            'addressFields' => JSON.serialize(mapAddressFields),
            'assignRecord' => false,
            'contactFields' => JSON.serialize(mapContactFields),
            'fieldMapStringAccount' => JSON.serialize(mapAccountFields),
            'existingAccountId' => null,
            'recordTypeId' => recordTypeId,
            'isCommunity' => false,
            'robinsonCustomer' => true,
            'consentsLE' => JSON.serialize(leConsents),
            'withoutValidate' => false
        }; 
        String mapAccountString = JSON.serialize(mapAccountByComponent);
        System.debug(' mapAccountString ' + mapAccountString);
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk = XC_LCC003_NewAccount.createRecord(mapAccountString);
        System.debug('@@@@@ wrOk-->  '+ wrOk);
        //System.assertEquals(true, wrOk.success); 
        String  wrapperAccount = XC_LCC003_NewAccount.retrieveData(wrOk.recordId, recordTypeIdString);
        System.debug('@@@@@ wrapperAccount-->  '+ wrapperAccount);
        Map<String, Object> mapwrapperAccount = (Map<String, Object>) JSON.deserializeUntyped(wrapperAccount);
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk2 = XC_LCC003_NewAccount.createRecord(mapAccountString);
        System.debug('@@@@@ wrOk2-->  '+ wrOk2);
        System.assert(mapwrapperAccount.get('recordTypeName') == 'XC_GLO_Account_Residential'); 
        Test.stopTest();
        
    }

    @IsTest
    static void testSohoSameAccountAndContact(){
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Soho').getRecordTypeId();
        String recordTypeIdString = recordTypeId;
        Test.startTest();        
        Map<String, String> mapAccountFields = new Map<String, String>{
            'Name'=>'testSoho',
            'Company__c'=>'testSoho',
            'XC_FirstName__c' => 'test',
            'XC_LastName__c' => 'test',
            'XC_AccountPhonePrefix__c' => '',
            'XC_AccountPhone__c' => null,
            'XC_MainPhonePrefix__c' => '',
            'XC_AccountMainPhone__c' => null,
            'PrimaryEmail__c' => 'test@te.it',
            'XC_BirthDate__c' => null,
            'XC_Preference_Language__c' => '',
            'XC_AccountNationality__c' => '',
            'XC_Notes__c' => null,
            'XC_DocumentCountry__c' => 'Spain',
            'IdentityType__c' => 'NIF',
            'IdentityNumber__c' => '00533739R',
            'XC_NIE_expedition_date__c' => '2019-01-01',
            'XC_NIE_expiration_date__c' => '2030-12-30',
            'XC_DocumentCountry__c' => 'Spain',
            'XC_ReceivingChannel__c' => 'Email',
            'OwnerId' => UserInfo.getUserId()
        };
                    
        Map<String, Object> mapAddressFields = new Map<String, Object>{
            'country' => 'Spain',
            'streetType' => 'Access',
            'address' => 'test',
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'municipality' => 'test',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true
        };

        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LeCountry__c' => 'Spain',
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_GiveDataTo__c' => 'Yes',
            'XC_KeepMeUpdateOnProducts__c' => 'Yes',
            'XC_GiveConsentToDataProcessing__c' => 'Yes'
        };

        Map<String, Object> mapLEFields2 = new Map<String, Object>{
            'XC_LeCountry__c' => 'Spain',
            'XC_LegalEntity__c' => 'JuicenetLimited',
            'XC_GiveDataTo__c' => 'Yes',
            'XC_KeepMeUpdateOnProducts__c' => 'Yes',
            'XC_GiveConsentToDataProcessing__c' => 'Yes'
        };

        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);
        leConsents.add(mapLEFields2);
                     
        Map<String, Object> mapContactFields = new Map<String, Object>{
            'FirstName' => 'a',
            'LastName' => 'b',
            'DocumentCountry' => 'Spain',
            'DocumentType' => 'Passport',
            'DocumentID' => '00533738',
            'Email' => '',
            'Mobile' => '',
            'Phone' => ''
        }; 
                      
        Map<String, Object> mapAccountByComponent = new Map<String, Object>{
            'addressFields' => JSON.serialize(mapAddressFields),
            'assignRecord' => false,
            'contactFields' => JSON.serialize(mapContactFields),
            'fieldMapStringAccount' => JSON.serialize(mapAccountFields),
            'existingAccountId' => null,
            'recordTypeId' => recordTypeId,
            'isCommunity' => false,
            'robinsonCustomer' => true,
            'consentsLE' => JSON.serialize(leConsents),
            'withoutValidate' => false
        }; 
        String mapAccountString = JSON.serialize(mapAccountByComponent);
        System.debug(' mapAccountString ' + mapAccountString);
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk = XC_LCC003_NewAccount.createRecord(mapAccountString);
        System.debug('@@@@@ wrOk-->  '+ wrOk);
        System.assertEquals(true, wrOk.success); 
        String  wrapperAccount = XC_LCC003_NewAccount.retrieveData(wrOk.recordId, recordTypeIdString);
        System.debug('@@@@@ wrapperAccount-->  '+ wrapperAccount);
        Map<String, Object> mapwrapperAccount = (Map<String, Object>) JSON.deserializeUntyped(wrapperAccount);
        System.assert(mapwrapperAccount.get('recordTypeName') == 'XC_GLO_Account_Soho'); 
        Test.stopTest();   
    }


    @IsTest
    static void testSohoSameContactDiffRecType(){
        List<Account> exAccount = [SELECT Id FROM Account WHERE RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId() LIMIT 1];
        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(exAccount);
        Contact cont = contactList[0];
        String recordTypeIDcontact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Residential').getRecordTypeId();
        cont.recordTypeId = recordTypeIDcontact;
        cont.Email = 'testtest@testdup.it';
        cont.XC_ContactDocumentCountry__c = 'Spain';
        cont.XC_ContactDocumentType__c = 'Passport';
        cont.XC_ContactDocumentNumber__c = '987114126';
        cont.XC_MainLegalEntity__c = 'EndesaX';
        insert cont;
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Soho').getRecordTypeId();
        String recordTypeIdString = recordTypeId;
        Test.startTest();        
        Map<String, String> mapAccountFields = new Map<String, String>{
            'Name'=>'testSoho',
            'Company__c'=>'testSoho',
            'XC_FirstName__c' => 'test',
            'XC_LastName__c' => 'test',
            'XC_AccountPhonePrefix__c' => '',
            'XC_AccountPhone__c' => null,
            'XC_MainPhonePrefix__c' => '',
            'XC_AccountMainPhone__c' => null,
            'PrimaryEmail__c' => 'test@te.it',
            'XC_BirthDate__c' => null,
            'XC_Preference_Language__c' => '',
            'XC_AccountNationality__c' => '',
            'XC_Notes__c' => null,
            'XC_DocumentCountry__c' => 'Spain',
            'IdentityType__c' => 'NIF',
            'IdentityNumber__c' => '00533739R',
            'XC_NIE_expedition_date__c' => '2019-01-01',
            'XC_NIE_expiration_date__c' => '2030-12-30',
            'XC_DocumentCountry__c' => 'Spain',
            'XC_ReceivingChannel__c' => 'Email',
            'OwnerId' => UserInfo.getUserId()
        };
                    
        Map<String, Object> mapAddressFields = new Map<String, Object>{
            'country' => 'Spain',
            'streetType' => 'Access',
            'address' => 'test',
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'municipality' => 'test',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true
        };

        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LeCountry__c' => 'Spain',
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_GiveDataTo__c' => 'Yes',
            'XC_KeepMeUpdateOnProducts__c' => 'Yes',
            'XC_GiveConsentToDataProcessing__c' => 'Yes'
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);
                     
        Map<String, Object> mapContactFields = new Map<String, Object>{
            'FirstName' => 'a',
            'LastName' => 'b',
            'DocumentCountry' => 'Spain',
            'DocumentType' => 'Passport',
            'DocumentID' => '987114126',
            'Email' => 'testtest@testdup.it',
            'Mobile' => '',
            'Phone' => ''
        }; 
                      
        Map<String, Object> mapAccountByComponent = new Map<String, Object>{
            'addressFields' => JSON.serialize(mapAddressFields),
            'assignRecord' => false,
            'contactFields' => JSON.serialize(mapContactFields),
            'fieldMapStringAccount' => JSON.serialize(mapAccountFields),
            'existingAccountId' => null,
            'recordTypeId' => recordTypeId,
            'isCommunity' => false,
            'robinsonCustomer' => true,
            'consentsLE' => JSON.serialize(leConsents),
            'withoutValidate' => false
        }; 
        String mapAccountString = JSON.serialize(mapAccountByComponent);
        System.debug(' mapAccountString ' + mapAccountString);
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk = XC_LCC003_NewAccount.createRecord(mapAccountString);
        System.debug('@@@@@ wrOk-->  '+ wrOk);
        System.assertEquals(false, wrOk.success); 
        String  wrapperAccount = XC_LCC003_NewAccount.retrieveData(wrOk.recordId, recordTypeIdString);
        System.debug('@@@@@ wrapperAccount-->  '+ wrapperAccount);
        Map<String, Object> mapwrapperAccount = (Map<String, Object>) JSON.deserializeUntyped(wrapperAccount);
        System.assert(mapwrapperAccount.get('recordTypeName') == 'XC_GLO_Account_Soho'); 
        Test.stopTest();   
    }

    @IsTest
    static void testSohoSameSecondaryContact(){        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Soho').getRecordTypeId();
        String recordTypeIdString = recordTypeId;
        Test.startTest();        
        Map<String, String> mapAccountFields = new Map<String, String>{
            'Name'=>'testSoho1',
            'Company__c'=>'testSoho1',
            'XC_FirstName__c' => 'test',
            'XC_LastName__c' => 'test',
            'XC_AccountPhonePrefix__c' => '',
            'XC_AccountPhone__c' => null,
            'XC_MainPhonePrefix__c' => '',
            'XC_AccountMainPhone__c' => null,
            'PrimaryEmail__c' => 'test@test.it',
            'XC_BirthDate__c' => null,
            'XC_Preference_Language__c' => '',
            'XC_AccountNationality__c' => '',
            'XC_Notes__c' => null,
            'XC_DocumentCountry__c' => 'Spain',
            'IdentityType__c' => 'NIF',
            'IdentityNumber__c' => '00533729R',
            'XC_NIE_expedition_date__c' => '2019-01-01',
            'XC_NIE_expiration_date__c' => '2030-12-30',
            'XC_DocumentCountry__c' => 'Spain',
            'XC_ReceivingChannel__c' => 'Email',
            'OwnerId' => UserInfo.getUserId()
        };
                    
        Map<String, Object> mapAddressFields = new Map<String, Object>{
            'country' => 'Spain',
            'streetType' => 'Access',
            'address' => 'test',
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'municipality' => 'test',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true
        };

        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LeCountry__c' => 'Spain',
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_GiveDataTo__c' => 'Yes',
            'XC_KeepMeUpdateOnProducts__c' => 'Yes',
            'XC_GiveConsentToDataProcessing__c' => 'Yes'
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);
                     
        Map<String, Object> mapContactFields = new Map<String, Object>{
            'FirstName' => 'a',
            'LastName' => 'b',
            'DocumentCountry' => 'Spain',
            'DocumentType' => 'Passport',
            'DocumentID' => '987114127',
            'Email' => 'test_soho@email.com',
            'Mobile' => '',
            'Phone' => ''
        }; 
                      
        Map<String, Object> mapAccountByComponent = new Map<String, Object>{
            'addressFields' => JSON.serialize(mapAddressFields),
            'assignRecord' => false,
            'contactFields' => JSON.serialize(mapContactFields),
            'fieldMapStringAccount' => JSON.serialize(mapAccountFields),
            'existingAccountId' => null,
            'recordTypeId' => recordTypeId,
            'isCommunity' => false,
            'robinsonCustomer' => true,
            'consentsLE' => JSON.serialize(leConsents),
            'withoutValidate' => false
        }; 
        String mapAccountString = JSON.serialize(mapAccountByComponent);
        System.debug(' mapAccountString ' + mapAccountString);
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk = XC_LCC003_NewAccount.createRecord(mapAccountString);
        System.debug('@@@@@ wrOk-->  '+ wrOk);
        System.assertEquals(false, wrOk.success); 
        String  wrapperAccount = XC_LCC003_NewAccount.retrieveData(wrOk.recordId, recordTypeIdString);
        System.debug('@@@@@ wrapperAccount-->  '+ wrapperAccount);
        Map<String, Object> mapwrapperAccount = (Map<String, Object>) JSON.deserializeUntyped(wrapperAccount);
        System.assert(mapwrapperAccount.get('recordTypeName') == 'XC_GLO_Account_Soho'); 
        Test.stopTest();   
    }

    @IsTest
    static void createSecCont(){
        
        Test.startTest();
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Soho').getRecordTypeId();
        String recordTypeIdString = recordTypeId;

        Map<String, String> mapAccountFields = new Map<String, String>{
            'Name'=>'testSoho',
            'Company__c'=>'testSoho',
            'XC_FirstName__c' => 'test',
            'XC_LastName__c' => 'test',
            'XC_AccountPhonePrefix__c' => '',
            'XC_AccountPhone__c' => null,
            'XC_MainPhonePrefix__c' => '',
            'XC_AccountMainPhone__c' => null,
            'PrimaryEmail__c' => 'test@te.it',
            'XC_BirthDate__c' => null,
            'XC_Preference_Language__c' => '',
            'XC_AccountNationality__c' => '',
            'XC_Notes__c' => null,
            'XC_DocumentCountry__c' => 'Spain',
            'IdentityType__c' => 'NIF',
            'IdentityNumber__c' => '00533739R',
            'XC_NIE_expedition_date__c' => '2019-01-01',
            'XC_NIE_expiration_date__c' => '2030-12-30',
            'XC_DocumentCountry__c' => 'Spain',
            'XC_ReceivingChannel__c' => 'Email',
            'OwnerId' => UserInfo.getUserId()
        };
                    
        Map<String, Object> mapAddressFields = new Map<String, Object>{
            'country' => 'Spain',
            'streetType' => 'Access',
            'address' => 'test',
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'municipality' => 'test',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true
        };

        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LeCountry__c' => 'Spain',
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_GiveDataTo__c' => 'Yes',
            'XC_KeepMeUpdateOnProducts__c' => 'Yes',
            'XC_GiveConsentToDataProcessing__c' => 'Yes'
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);
                     
        Map<String, Object> mapContactFields = new Map<String, Object>{
            'FirstName' => 'a',
            'LastName' => 'b',
            'DocumentCountry' => 'Spain',
            'DocumentType' => 'Passport',
            'DocumentID' => '10533738',
            'Email' => 'createSecCont@test.te',
            'Mobile' => '',
            'Phone' => ''
        }; 
                      
        Map<String, Object> mapAccountByComponent = new Map<String, Object>{
            'addressFields' => JSON.serialize(mapAddressFields),
            'assignRecord' => false,
            'contactFields' => JSON.serialize(mapContactFields),
            'fieldMapStringAccount' => JSON.serialize(mapAccountFields),
            'existingAccountId' => null,
            'recordTypeId' => recordTypeId,
            'isCommunity' => false,
            'robinsonCustomer' => true,
            'consentsLE' => JSON.serialize(leConsents),
            'withoutValidate' => false
        }; 
        String mapAccountString = JSON.serialize(mapAccountByComponent);
        System.debug(' mapAccountString ' + mapAccountString);
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk = XC_LCC003_NewAccount.createRecord(mapAccountString);
        System.debug('@@@@@ wrOk-->  '+ wrOk);
        System.assert(!wrOk.success);
        Test.stopTest();
        
    }

    @IsTest
    static void testAccNotExists(){
        
        Test.startTest();
        Account acc =  XC_DF_Account.createSohoAccounts(1)[0];
        acc.PrimaryEmail__c = 'primaryEmailNotExists@test.te';
        acc.XC_DocumentCountry__c = 'Spain';
        acc.IdentityType__c = 'NIF';
        acc.IdentityNumber__c = '22400283B';
        insert acc;

        List<Account> accList = new List<Account>();
        accList.add(acc);

        Contact c = XC_DF_Contact.createSohoContacts(accList)[0];
        c.Email = 'testAccNotExists@test.te';
        c.XC_ContactDocumentCountry__c = 'Spain';
        c.XC_ContactDocumentType__c = 'Passport';
        c.XC_ContactDocumentNumber__c = '15533739R';
        
        insert c;




        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Soho').getRecordTypeId();
        String recordTypeIdString = recordTypeId;

        Map<String, String> mapAccountFields = new Map<String, String>{
            'Name'=>'testSoho',
            'Company__c'=>'testSoho',
            'XC_FirstName__c' => 'test',
            'XC_LastName__c' => 'test',
            'XC_AccountPhonePrefix__c' => '',
            'XC_AccountPhone__c' => null,
            'XC_MainPhonePrefix__c' => '',
            'XC_AccountMainPhone__c' => null,
            'PrimaryEmail__c' => 'test@te.it',
            'XC_BirthDate__c' => null,
            'XC_Preference_Language__c' => '',
            'XC_AccountNationality__c' => '',
            'XC_Notes__c' => null,
            'XC_DocumentCountry__c' => 'Spain',
            'IdentityType__c' => 'NIF',
            'IdentityNumber__c' => '00533739R',
            'XC_NIE_expedition_date__c' => '2019-01-01',
            'XC_NIE_expiration_date__c' => '2030-12-30',
            'XC_DocumentCountry__c' => 'Spain',
            'XC_ReceivingChannel__c' => 'Email',
            'OwnerId' => UserInfo.getUserId()
        };
                    
        Map<String, Object> mapAddressFields = new Map<String, Object>{
            'country' => 'Spain',
            'streetType' => 'Access',
            'address' => 'test',
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'municipality' => 'test',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true
        };

        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LeCountry__c' => 'Spain',
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_GiveDataTo__c' => 'Yes',
            'XC_KeepMeUpdateOnProducts__c' => 'Yes',
            'XC_GiveConsentToDataProcessing__c' => 'Yes'
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);
                     
        Map<String, Object> mapContactFields = new Map<String, Object>{
            'FirstName' => 'a',
            'LastName' => 'b',
            'DocumentCountry' => 'Spain',
            'DocumentType' => 'NIF',
            'DocumentID' => '15533739R',
            'Email' => 'testAccNotExists@test.te',
            'Mobile' => '',
            'Phone' => ''
        }; 
                      
        Map<String, Object> mapAccountByComponent = new Map<String, Object>{
            'addressFields' => JSON.serialize(mapAddressFields),
            'assignRecord' => false,
            'contactFields' => JSON.serialize(mapContactFields),
            'fieldMapStringAccount' => JSON.serialize(mapAccountFields),
            'existingAccountId' => null,
            'recordTypeId' => recordTypeId,
            'isCommunity' => false,
            'robinsonCustomer' => true,
            'consentsLE' => JSON.serialize(leConsents),
            'withoutValidate' => false
        }; 
        String mapAccountString = JSON.serialize(mapAccountByComponent);
        System.debug(' mapAccountString ' + mapAccountString);
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk = XC_LCC003_NewAccount.createRecord(mapAccountString);
        System.debug('@@@@@ wrOk-->  '+ wrOk);
        System.assert(!wrOk.success);
        Test.stopTest();
        
    }

    @IsTest
    static void invokeSingleMethods(){
        Test.startTest();
        
        XC_UTIL_AccountDuplication_Z.ExistingContactWrapper inputWrapper = new XC_UTIL_AccountDuplication_Z.ExistingContactWrapper();
        XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper wrapper = new XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper();
        XC_UTIL_AccountDuplication_W.CheckAccountWrapper caWrapper = new XC_UTIL_AccountDuplication_W.CheckAccountWrapper();
        Contact contact = XC_DF_Contact.createCondominiumContacts(1)[0];
        contact.XC_ContactDocumentType__c = 'Passport';
        contact.XC_ContactDocumentNumber__c = '98716216';
        contact.XC_ContactDocumentCountry__c = 'Spain';
        insert contact;

        Contact newContact = contact.clone();
        wrapper.newContact = newContact;
        inputWrapper.wrapper = wrapper;
        inputWrapper.contact = [SELECT Id, XC_ContactDocumentType__c, XC_ContactDocumentNumber__c, XC_RecordTypeDeveloperName__c FROM Contact WHERE id = :contact.Id][0];
        System.assert(XC_UTIL_AccountDuplication_V.checkDocumentContact(inputWrapper));

        XC_UTIL_AccountDuplication_W.CheckAccountWrapper wr = XC_UTIL_AccountDuplication_Z.checkForContact(null, contact, null);
        System.assert(!wr.success);

        List<XC_UTIL_Sobject.WrapperResult> wrList = new List<XC_UTIL_Sobject.WrapperResult>();
        XC_UTIL_Sobject.WrapperResult wResult = new XC_UTIL_Sobject.WrapperResult();
        wrList.add(wResult);
        inputWrapper.wrapperOutput = caWrapper;
        XC_UTIL_AccountDuplication_Z.setErrorOnInputWrapper(inputWrapper, wrList);
        
        
        Test.stopTest();
        
    }

    @IsTest
    static void accExistsContactExistsDifferentRT(){
        Test.startTest();
        String recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Soho').getRecordTypeId();
        List<Account> residentialList = XC_DF_Account.createResidentialAccounts(1);
        insert residentialList;
        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(residentialList);
        Contact cnt = contactList[0];
        cnt.XC_ContactDocumentCountry__c = 'Spain';
        cnt.XC_ContactDocumentNumber__c = '03632694M';
        cnt.XC_ContactDocumentType__c = 'NIF';
        insert cnt;

        Account acc = residentialList[0];
        
        
        
        Map<String, Object> mapContactFields = new Map<String, Object>{
            'FirstName' => 'a',
            'LastName' => 'b',
            'DocumentCountry' => cnt.XC_ContactDocumentCountry__c,
            'DocumentType' => cnt.XC_ContactDocumentType__c,
            'DocumentID' => cnt.XC_ContactDocumentNumber__c,
            'Email' => '',
            'Mobile' => '',
            'Phone' => ''
        }; 

        Map<String, String> mapAccountFields = new Map<String, String>{
            'Name'=>'testSoho',
            'Company__c'=>'testSoho',
            'XC_FirstName__c' => 'test',
            'XC_LastName__c' => 'test',
            'XC_AccountPhonePrefix__c' => '',
            'XC_AccountPhone__c' => null,
            'XC_MainPhonePrefix__c' => '',
            'XC_AccountMainPhone__c' => null,
            'PrimaryEmail__c' => 'test@te.it',
            'XC_BirthDate__c' => null,
            'XC_Preference_Language__c' => '',
            'XC_AccountNationality__c' => '',
            'XC_Notes__c' => null,
            'XC_DocumentCountry__c' => 'Spain',
            'IdentityType__c' => 'NIF',
            'IdentityNumber__c' => '00533739R',
            'XC_NIE_expedition_date__c' => '2019-01-01',
            'XC_NIE_expiration_date__c' => '2030-12-30',
            'XC_DocumentCountry__c' => 'Spain',
            'XC_ReceivingChannel__c' => 'Email',
            'OwnerId' => UserInfo.getUserId()
        };
                    
        Map<String, Object> mapAddressFields = new Map<String, Object>{
            'country' => 'Spain',
            'streetType' => 'Access',
            'address' => 'test',
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'municipality' => 'test',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true
        };

        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LeCountry__c' => 'Spain',
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_GiveDataTo__c' => 'Yes',
            'XC_KeepMeUpdateOnProducts__c' => 'Yes',
            'XC_GiveConsentToDataProcessing__c' => 'Yes'
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);
                      
        Map<String, Object> mapAccountByComponent = new Map<String, Object>{
            'addressFields' => JSON.serialize(mapAddressFields),
            'assignRecord' => false,
            'contactFields' => JSON.serialize(mapContactFields),
            'fieldMapStringAccount' => JSON.serialize(mapAccountFields),
            'existingAccountId' => null,
            'recordTypeId' => recordTypeId,
            'isCommunity' => false,
            'robinsonCustomer' => true,
            'consentsLE' => JSON.serialize(leConsents),
            'withoutValidate' => false
        }; 
        String mapAccountString = JSON.serialize(mapAccountByComponent);
        System.debug('setup  mapAccountString ' + mapAccountString);
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk = XC_LCC003_NewAccount.createRecord(mapAccountString);
        System.assert(!wrOk.success);
        Test.stopTest();
        
    }

    @isTest
    static void checkExistingContactTest (){
        Test.startTest();
        XC_UTIL_AccountDuplication_W.CheckFieldWrapper wrap = new XC_UTIL_AccountDuplication_W.CheckFieldWrapper();
        List<Contact> listOfContact = XC_DF_Contact.createResidentialContacts(1);
        insert listOfContact;
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Residential').getRecordTypeId();
        Set<String> setEmail = new Set<String>();
        setEmail.add(listOfContact[0].Email);
        Set<String> setFirstName = new Set<String>();
        setFirstName.add(listOfContact[0].FirstName);
        Set<String> setLastName = new Set<String>();
        setLastName.add(listOfContact[0].LastName);
        Set<String> setLegalEntity = new Set<String>(); 
        setLegalEntity.add(listOfContact[0].XC_MainLegalEntity__c);
        wrap.setEmail = setEmail;
        wrap.setFirstName = setFirstName;
        wrap.setLastName = setLastName;
        wrap.setLegalEntity = setLegalEntity;
        XC_UTIL_AccountDuplication_W.CheckAccountWrapper newWrap = XC_UTIL_AccountDuplication.checkExistingContact(wrap, 1, recordTypeId);
        System.assert(wrap != null);
        Test.stopTest();
    }

    @isTest
    static void checkNotExistingAccountTest(){
        XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper wrapper = new XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper();
        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LeCountry__c' => 'Spain',
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_GiveDataTonew__c' => 'Yes',
            'XC_UpdateAboutProducts__c' => 'Yes',
            'XC_ConsentToDataProcessing__c' => 'Yes'
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);
        XC_LCC003_NewAccount.accountContactWrapper = new XC_LCC003_NewAccount_W.AccountInputDataWrapper();
        XC_LCC003_NewAccount.accountContactWrapper.consentsLE = JSON.serialize(leConsents);
        List<Contact> listOfContact = XC_DF_Contact.createResidentialContacts(1);
        insert listOfContact;
        List<Account> listOfAcc = new List<Account>([SELECT Id, XC_GiveDataTo_EndesaX__c FROM Account WHERE Id =:listOfContact[0].AccountId]);
        Account newAcc = new Account();
        newAcc = listOfAcc[0];
        wrapper.newAccount = newAcc;
        
        wrapper.listExistingContact = listOfContact;
        XC_UTIL_AccountDuplication_W.CheckAccountWrapper resultWrapper = XC_UTIL_AccountDuplication_V.notExistingAccount(wrapper);
        System.assert(!listOfContact.isEmpty());
    }

    
    @isTest
    static void createSecondaryContactOnExistingAccountTEST(){
        XC_UTIL_AccountDuplication_W.CheckAccountWrapper resultWrap = new XC_UTIL_AccountDuplication_W.CheckAccountWrapper();
        XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper wrapper = new XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper();
        XC_LCC003_NewAccount.accountContactWrapper = new XC_LCC003_NewAccount_W.AccountInputDataWrapper();
        String nullValue = null;
        XC_LCC003_NewAccount.accountContactWrapper.consentsLE = nullValue;   
        Map<String, Object> mapContactFields = new Map<String, Object>{
            'FirstName' => 'a',
            'LastName' => 'b',
            'DocumentCountry' => 'Spain',
            'DocumentType' => 'Passport',
            'DocumentID' => '00533738',
            'Email' => 'test@test.email',
            'Mobile' => '',
            'Phone' => ''
        };
        XC_LCC003_NewAccount.accountContactWrapper.contactFields = JSON.serialize(mapContactFields);
        List<Account> listOfAcc = XC_DF_Account.createResidentialAccounts(1);
        insert listOfAcc;
        wrapper.existingAccount = listOfAcc[0];


        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.legalEntity = 'EndesaX';
        leWrapper.country = 'Spain';
        leWrapperList.add(leWrapper);
        XC_LCC003_NewAccount.accountContactWrapper.consentsWrapper = JSON.serialize(leWrapperList);
        
        resultWrap = XC_UTIL_AccountDuplication_Z.createSecondaryContactOnExistingAccount(wrapper);
        System.assert(wrapper != null);
    }

    @isTest
    static void populateCheckFieldWrapperTEST(){
        List<Contact> listOfContact = XC_DF_Contact.createResidentialContacts(1);
        insert listOfContact;
        XC_UTIL_AccountDuplication_W.CheckFieldWrapper wrap = XC_UTIL_AccountDuplication_U.populateCheckFieldWrapper(listOfContact);
        System.assert(wrap != null);
    }

    //Mod PU.Task New005A_I 05/08/2021: added Test to check XC_RecordTypeName__c on XC_UTIL_AccountDuplication
    @isTest
    static void onContacts(){
        List<Contact> resContactList = XC_DF_Contact.createResidentialContacts(4);
        resContactList[0].XC_ContactDocumentCountry__c = 'Spain';
        resContactList[0].XC_ContactDocumentType__c = 'Passport';
        resContactList[0].XC_ContactDocumentNumber__c = 'Test';
        resContactList[2].XC_PrimaryContact__c = true;
		resContactList[3].Email = 'Test@test.com';
		resContactList[3].XC_RecordTypeName__c = 'Residential';
        insert resContactList;
		List<Account> accList = XC_DF_Account.createResidentialAccounts(2);
        insert accList;
        Contact newContact = new Contact(
            LastName = 'Test',
            XC_ContactDocumentCountry__c = 'Spain',
            XC_ContactDocumentType__c = 'Passport',
            XC_ContactDocumentNumber__c = 'Test',
            XC_PrimaryContact__c = true,
            AccountId = accList[0].Id
        );
        Contact newContact2 = new Contact(
            LastName = 'Test',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Residential').getRecordTypeId(),
            Email = resContactList[2].Email,
            AccountId = accList[0].Id
        );
		Contact newContact3 = new Contact(
            LastName = 'Test',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Residential').getRecordTypeId(),
            Email = resContactList[3].Email,
            AccountId = accList[1].Id,
			XC_RecordTypeName__c = resContactList[3].XC_RecordTypeName__c

        );
        List<Contact> listContact = new List<Contact>{
            newContact,
            XC_DF_Contact.createResidentialContacts(1)[0],
            resContactList[1],
            newContact2,
			newContact3
        };
        Map<String, Object> mapInputContact = new Map<String, Object>();
        Map<String, Object> mapExistingContact = new Map<String, Object>();
        mapInputContact.put('name','test');
        mapExistingContact.put('name','testreplace');

        Test.startTest();
        XC_UTIL_AccountDuplication.UpertedContactWrapper wrRes = XC_UTIL_AccountDuplication.upsertContacts(listContact, new List<String>{'Passport_42455','Passport_42475','Passport_42495', 'Passport_42477','Passport_42480'});
        XC_UTIL_AccountDuplication.checkInsertDuplicateField('Name', mapInputContact, mapExistingContact);
        XC_UTIL_AccountDuplication.upsertContacts(listContact, new List<String>{'Passport_42455','Passport_42475','Passport_42495', 'Passport_42477','Passport_42480'});
        System.assertNotEquals(wrRes, null);
        Test.stopTest();
    }

    
    
    @isTest
    static void accountAndContact2(){
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        acc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        acc[0].XC_Segment__c = 'B2B';
        insert acc;
        List<Contact> cont = XC_DF_Contact.createPartnerContacts(acc);
        cont[0].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        cont[0].XC_Segment__c = 'B2B';
        XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper wrapper = new XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper();
        wrapper.newContact = new Contact();
        wrapper.newContact = cont[0];
        wrapper.newContact.RecordTypeId = null;
        wrapper.newAccount = new Account();
        wrapper.newAccount = acc[0];
        wrapper.newAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
       	//wrapper.existingAccount = new Account();
        //wrapper.existingAccount = acc[0];
        wrapper.newAccount.PrimaryEmail__c = 'pippo@test.it';
        wrapper.listExistingContact.add(cont[0]);
		List<XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper> inputListWrapper = new List<XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper>();		
        inputListWrapper.add(wrapper);
        Test.startTest();
        XC_UTIL_AccountDuplication_Z.checkForSohoCondominium( inputListWrapper);
        Test.stopTest();
    } 

    @isTest
    static void checkContactMatchingTest(){
        List<Contact> listOfContact = XC_DF_Contact.createResidentialContacts(3);
        insert listOfContact;
        List<String> listOfDoc = new List<String>{'doc1','doc2'};
        Test.startTest();
        Boolean result = XC_UTIL_AccountDuplication.checkContactMatching(listOfContact[0], listOfContact[1], listOfDoc);
        System.assert(result != null);
        Test.stopTest();
    }
    
    @isTest
    static void checkContactMatchingTest2(){
        List<Contact> listOfContact = XC_DF_Contact.createResidentialContacts(3);
        insert listOfContact;
        List<String> listOfDoc = new List<String>{'doc1','doc2','doc3','doc4','doc5'};
        Test.startTest();
        Boolean result = XC_UTIL_AccountDuplication.checkContactMatching(listOfContact[0], listOfContact[1], listOfDoc);
        System.assert(result != null);
        Test.stopTest();
    }
}