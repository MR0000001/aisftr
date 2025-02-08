/**
* @author Roberta Porrega - roberta.porrega@nttdata.com  
* @date Creation  29/04/2019 
* @date Modification 06/02/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_LCC003_NewAccount_TEST – Test class for XC_LCC003_NewAccount
*/

@isTest
private class XC_LCC003_NewAccount_TEST {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC003_NewAccount_TEST');
    
    @TestSetup
    static void setup(){
        String recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Soho').getRecordTypeId();

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
            'DocumentID' => '00533738',
            'Email' => 'test@te.it',
            'Mobile' => '',
            'Phone' => '',
            'XC_CountryLegalEntity__c' => 'Spain',
            'XC_MainLegalEntity__c' => 'EndesaX'
        }; 

        XC_ConsentDescription__c consDescr = new XC_ConsentDescription__c(
            XC_ConsentVersion__c = '1',
            XC_LegalEntity__c = 'EndesaX',
            XC_Country__c = 'Spain',
            XC_ConsentStatus__c = 'Active',
            XC_DescriptionMarketing__c = 'Test',
            XC_DescriptionProfiling__c = 'Test',
            XC_DescriptionThirdParties__c = 'Test',
            XC_DescriptionGiveDataToLE__c = 'Test'
        );
        insert consDescr;
        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.developerName = 'EndesaX';
        leWrapper.label = 'EndesaX';
        leWrapper.legalEntity = 'EndesaX';
        leWrapper.country = 'Spain';
        leWrapper.companyCode = 'Test';
        leWrapper.consentVersion = 'Test';
        leWrapper.thirdPartyLabel = 'Test';
        leWrapper.profilingLabel = 'Test';
        leWrapper.marketingLabel = 'Test';
        leWrapper.descriptionThirdParties = 'Test';
        leWrapper.descriptionProfiling = 'Test';
        leWrapper.descriptionMarketing = 'Test';
        leWrapper.descriptionGiveData = 'Test';
        leWrapper.marketingValue = 'Test';
        leWrapper.profilingValue = 'Test';
        leWrapper.thirdPartyValue = 'YES';
        leWrapper.legalEntityConsentId = 'EndesaX';
        leWrapper.consentDescriptionLookup = consDescr.Id;
        leWrapper.isExisting = false;
        leWrapper.confirmationByTheCustomer = true;
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
            'thirdPartiesCheck' => 'YES',
            'consentsWrapper' => JSON.serialize(leWrapperList)
        }; 

        Test.startTest();
        String mapAccountString = JSON.serialize(mapAccountByComponent);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ SETUP: mapAccountString -> ' + mapAccountString);
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk = XC_LCC003_NewAccount.createRecord(mapAccountString);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ SETUP: wrOk -> ' + wrOk);
        Contact secConSoho = XC_DF_Contact.createSohoContacts(new List<Account>{new Account(Id=wrOk.recordId)})[0];
        secConSoho.XC_PrimaryContact__c = false;
        insert secConSoho;
        Test.stopTest();
    }

    @IsTest
    static void testSohoSameSecondaryContact(){        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Soho').getRecordTypeId();
        String recordTypeIdString = recordTypeId;
            
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
            'Phone' => '',
            'XC_CountryLegalEntity__c' => 'Spain',
            'XC_MainLegalEntity__c' => 'EndesaX'
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

        Test.startTest();    
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk = XC_LCC003_NewAccount.createRecord(mapAccountString);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ wrOk ->' + wrOk);
        System.assertEquals(false, wrOk.success); 
        String  wrapperAccount = XC_LCC003_NewAccount.retrieveData(wrOk.recordId, recordTypeIdString);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ wrapperAccount -> ' + wrapperAccount);
        Map<String, Object> mapwrapperAccount = (Map<String, Object>) JSON.deserializeUntyped(wrapperAccount);
        System.assert(mapwrapperAccount.get('recordTypeName') == 'XC_GLO_Account_Soho'); 
        Test.stopTest();   
    }


    /*static testMethod void createRecordResidential() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();
        String recordTypeIdString = recordTypeId;
             
        Map<String, String> mapAccountFields = new Map<String, String>{
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
            'DocumentID' => 'TEST',
            'Email' => '',
            'Mobile' => '',
            'Phone' => '',
            'XC_CountryLegalEntity__c' => 'Spain',
            'XC_MainLegalEntity__c' => 'EndesaX'
        }; 

        XC_ConsentDescription__c consDescr = new XC_ConsentDescription__c(
            XC_ConsentVersion__c = '1',
            XC_LegalEntity__c = 'EndesaX',
            XC_Country__c = 'Spain',
            XC_ConsentStatus__c = 'Active',
            XC_DescriptionMarketing__c = 'Test',
            XC_DescriptionProfiling__c = 'Test',
            XC_DescriptionThirdParties__c = 'Test',
            XC_DescriptionGiveDataToLE__c = 'Test'
        );
        insert consDescr;
        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.developerName = 'EndesaX';
        leWrapper.label = 'EndesaX';
        leWrapper.legalEntity = 'EndesaX';
        leWrapper.country = 'Spain';
        leWrapper.companyCode = 'Test';
        leWrapper.consentVersion = 'Test';
        leWrapper.thirdPartyLabel = 'Test';
        leWrapper.profilingLabel = 'Test';
        leWrapper.marketingLabel = 'Test';
        leWrapper.descriptionThirdParties = 'Test';
        leWrapper.descriptionProfiling = 'Test';
        leWrapper.descriptionMarketing = 'Test';
        leWrapper.descriptionGiveData = 'Test';
        leWrapper.marketingValue = 'Test';
        leWrapper.profilingValue = 'Test';
        leWrapper.thirdPartyValue = 'YES';
        leWrapper.legalEntityConsentId = 'Test';
        leWrapper.consentDescriptionLookup = consDescr.Id;
        leWrapper.isExisting = false;
        leWrapper.confirmationByTheCustomer = true;
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

        Account prevAcc = new Account(
            XC_FirstName__c = 'test',
            XC_LastName__c = 'test',
            XC_AccountPhonePrefix__c = '',
            XC_AccountPhone__c = null,
            XC_MainPhonePrefix__c = '',
            XC_AccountMainPhone__c = null,
            PrimaryEmail__c = 'test@te.it',
            XC_BirthDate__c = null,
            XC_Preference_Language__c = '',
            XC_AccountNationality__c = '',
            XC_Notes__c = null,
            IdentityType__c = 'Passport',
            IdentityNumber__c = 'testtesttesttest',
            XC_NIE_expedition_date__c = Date.valueOf('2019-01-01'),
            XC_NIE_expiration_date__c = Date.valueOf('2030-12-30'),
            XC_DocumentCountry__c = 'Spain',
            XC_ReceivingChannel__c = 'Email',
            OwnerId = UserInfo.getUserId()
        );
        insert prevAcc;
        
        Test.startTest();   
        String mapAccountString = JSON.serialize(mapAccountByComponent);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createRecordResidential mapAccountString ' + mapAccountString);
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk = XC_LCC003_NewAccount.createRecord(mapAccountString);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ wrOk-->  '+ wrOk);
        System.assertEquals(true, wrOk.success); 
        String  wrapperAccount = XC_LCC003_NewAccount.retrieveData(wrOk.recordId, recordTypeIdString);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ wrapperAccount-->  '+ wrapperAccount);
        Map<String, Object> mapwrapperAccount = (Map<String, Object>) JSON.deserializeUntyped(wrapperAccount);
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk2 = XC_LCC003_NewAccount.createRecord(mapAccountString);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ wrOk2-->  '+ wrOk2);
        System.assert(mapwrapperAccount.get('recordTypeName') == 'XC_GLO_Account_Residential'); 
        Test.stopTest();
    } */
    
    @isTest
    static void createRecordCondominium() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Condominium').getRecordTypeId();
        String recordTypeIdString = recordTypeId;
        Test.startTest();        
        
        Map<String, Object> mapAccountFields = new Map<String, Object>{
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
                    
        Map<String, Object> mapContactFields = new Map<String, Object>{
            'FirstName' => 'Test',
            'LastName' => 'Contact',
            'DocumentCountry' => 'Spain',
            'DocumentType' => 'Passport',
            'DocumentID' => 'Z0682891A',
            'Email' => 'test@contact.it',
            'Mobile' => '',
            'Phone' => '',
            'XC_CountryLegalEntity__c' => 'Spain',
            'XC_MainLegalEntity__c' => 'EndesaX'
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
            'consentsLE' => JSON.serialize(leConsents)
        }; 
        String mapAccountString = JSON.serialize(mapAccountByComponent);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createRecordCondominium mapAccountString ' + mapAccountString);
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk = XC_LCC003_NewAccount.createRecord(mapAccountString);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ wrOk-->  '+ wrOk);
        System.assertEquals(false, wrOk.success); 
        String  wrapperAccount = XC_LCC003_NewAccount.retrieveData(wrOk.recordId, recordTypeIdString);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ wrapperAccount-->  '+ wrapperAccount);
        Map<String, Object> mapwrapperAccount = (Map<String, Object>) JSON.deserializeUntyped(wrapperAccount);
        System.assert(mapwrapperAccount.get('recordTypeName') == 'XC_GLO_Account_Condominium');
        Test.stopTest();
    }
    
    @isTest
    static void createRecordSoho() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Soho').getRecordTypeId();
        String recordTypeIdString = recordTypeId;
        Test.startTest();        
        
        Map<String, String> mapAccountFields = new Map<String, String>{
            
            'Company__c' => 'test',
            'PrimaryEmail__c' => 'test@te.it', 
            'XC_AccountPhonePrefix__c' => '',
            'XC_AccountPhone__c' => null,
            'XC_MainPhonePrefix__c' => '',
            'XC_AccountMainPhone__c' => null,
            'IdentityType__c'=> 'NIF',
            'IdentityNumber__c'=> '60633939M',
            'XC_NIE_expedition_date__c'=> '2019-01-01',
            'XC_NIE_expiration_date__c'=> '2088-01-01',
            'XC_Preference_Language__c' => '',                
            'XC_Nationality__c' => '',
            'XC_Notes__c' => null,
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
            'XC_RobinsonCustomer__c' => true,
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_GiveDataTo__c' => 'Yes',
            'XC_KeepMeUpdateOnProducts__c' => 'Yes',
            'XC_GiveConsentToDataProcessing__c' => 'Yes'
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);
                  
        Map<String, Object> mapContactFields = new Map<String, Object>{
            'FirstName' => 'Test',
            'LastName' => 'Contact',
            'DocumentCountry' => 'Spain',
            'DocumentType' => 'Passport',
            'DocumentID' => '666666666',
            'Email' => 'test@contact.it',
            'Mobile' => '',
            'Phone' => '',
            'XC_CountryLegalEntity__c' => 'Spain',
            'XC_MainLegalEntity__c' => 'EndesaX'
        }; 
                              
        Map<String, Object> mapAccountByComponent = new Map<String, Object>{
            'addressFields' => JSON.serialize(mapAddressFields),
            'assignRecord' => false,
            'contactFields' => JSON.serialize(mapContactFields),
            'fieldMapStringAccount' => JSON.serialize(mapAccountFields),
            'existingAccountId' => null,
            'robinsonCustomer' => true,
            'recordTypeId' => recordTypeId,
            'isCommunity' => false,
            'thirdPartiesCheck' => 'YES',
            'consentsLE' => JSON.serialize(leConsents)
        }; 
        String mapAccountString = JSON.serialize(mapAccountByComponent);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createRecordSoho mapAccountString ' + mapAccountString);
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk = XC_LCC003_NewAccount.createRecord(mapAccountString);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ wrOk-->  '+ wrOk);
        System.assertEquals(false, wrOk.success); 
        String  wrapperAccount = XC_LCC003_NewAccount.retrieveData(wrOk.recordId, recordTypeIdString);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ wrapperAccount-->  '+ wrapperAccount);
        Map<String, Object> mapwrapperAccount = (Map<String, Object>) JSON.deserializeUntyped(wrapperAccount);

        XC_TR_Account_U_CheckDuplicates.ResultWrapper inputWrapperNewLEC = new XC_TR_Account_U_CheckDuplicates.ResultWrapper();
        String query = XC_UTIL_Sobject.selectAllFieldsGetSelect('Contact') + ' FROM Contact LIMIT 1';
        inputWrapperNewLEC.existingContact = (Contact) Database.query(query)[0];
        XC_LCC003_NewAccount_W.AccountInputDataWrapper inputDataNewLEC = new XC_LCC003_NewAccount_W.AccountInputDataWrapper();
        XC_ConsentDescription__c consDescr = new XC_ConsentDescription__c(
            XC_ConsentVersion__c = '1',
            XC_LegalEntity__c = 'EnelXItalia',
            XC_Country__c = 'Italy',
            XC_ConsentStatus__c = 'Active',
            XC_DescriptionMarketing__c = 'Test',
            XC_DescriptionProfiling__c = 'Test',
            XC_DescriptionThirdParties__c = 'Test',
            XC_DescriptionGiveDataToLE__c = 'Test'
        );
        insert consDescr;
        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.developerName = 'EnelXItalia';
        leWrapper.label = 'EnelXItalia';
        leWrapper.legalEntity = 'EnelXItalia';
        leWrapper.country = 'Italy';
        leWrapper.companyCode = 'Test';
        leWrapper.consentVersion = 'Test';
        leWrapper.thirdPartyLabel = 'Test';
        leWrapper.profilingLabel = 'Test';
        leWrapper.marketingLabel = 'Test';
        leWrapper.descriptionThirdParties = 'Test';
        leWrapper.descriptionProfiling = 'Test';
        leWrapper.descriptionMarketing = 'Test';
        leWrapper.descriptionGiveData = 'Test';
        leWrapper.marketingValue = 'Test';
        leWrapper.profilingValue = 'Test';
        leWrapper.thirdPartyValue = 'YES';
        leWrapper.legalEntityConsentId = 'EnelXItalia';
        leWrapper.consentDescriptionLookup = consDescr.Id;
        leWrapper.isExisting = false;
        leWrapper.confirmationByTheCustomer = true;
        leWrapperList.add(leWrapper);
        inputDataNewLEC.consentsWrapper = JSON.serialize(leWrapperList);
        XC_LCC003_NewAccount.createConsensForExistingAccount(inputWrapperNewLEC, inputDataNewLEC);
        Test.stopTest();
    } 

    @isTest
    static void createRecordB2B() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_GLOB2B).getRecordTypeId();
        String recordTypeIdString = recordTypeId;
        Test.startTest();        
        
        Map<String, String> mapAccountFields = new Map<String, String>{
            'XC_ConfirmationByCustomer__c' => 'true',
            'Company__c' => 'test',
            'PrimaryEmail__c' => 'test@te.it', 
            'XC_AccountPhonePrefix__c' => '',
            'XC_AccountPhone__c' => null,
            'XC_MainPhonePrefix__c' => '',
            'XC_AccountMainPhone__c' => null,
            'IdentityType__c'=> 'NIF',
            'IdentityNumber__c'=> '60633939M',
            'XC_NIE_expedition_date__c'=> '2019-01-01',
            'XC_NIE_expiration_date__c'=> '2088-01-01',
            'XC_Preference_Language__c' => '',                
            'XC_Nationality__c' => '',
            'XC_Notes__c' => null,
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
            'XC_RobinsonCustomer__c' => true,
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_GiveDataTo__c' => 'Yes',
            'XC_KeepMeUpdateOnProducts__c' => 'Yes',
            'XC_GiveConsentToDataProcessing__c' => 'Yes'
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);
                  
        Map<String, Object> mapContactFields = new Map<String, Object>{
            'FirstName' => 'Test',
            'LastName' => 'Contact',
            'DocumentCountry' => 'Spain',
            'DocumentType' => 'Passport',
            'DocumentID' => '666666666',
            'Email' => 'test@contact.it',
            'Mobile' => '',
            'Phone' => '',
            'XC_CountryLegalEntity__c' => 'Spain',
            'XC_MainLegalEntity__c' => 'EndesaX'
        }; 

        XC_ConsentDescription__c consDescr = new XC_ConsentDescription__c(
            XC_ConsentVersion__c = '1',
            XC_LegalEntity__c = 'EndesaX',
            XC_Country__c = 'Spain',
            XC_ConsentStatus__c = 'Active',
            XC_DescriptionMarketing__c = 'Test',
            XC_DescriptionProfiling__c = 'Test',
            XC_DescriptionThirdParties__c = 'Test',
            XC_DescriptionGiveDataToLE__c = 'Test'
        );
        insert consDescr;
        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.developerName = 'EndesaX';
        leWrapper.label = 'EndesaX';
        leWrapper.legalEntity = 'EndesaX';
        leWrapper.country = 'Spain';
        leWrapper.companyCode = 'Test';
        leWrapper.consentVersion = 'Test';
        leWrapper.thirdPartyLabel = 'Test';
        leWrapper.profilingLabel = 'Test';
        leWrapper.marketingLabel = 'Test';
        leWrapper.descriptionThirdParties = 'Test';
        leWrapper.descriptionProfiling = 'Test';
        leWrapper.descriptionMarketing = 'Test';
        leWrapper.descriptionGiveData = 'Test';
        leWrapper.marketingValue = 'Test';
        leWrapper.profilingValue = 'Test';
        leWrapper.thirdPartyValue = 'YES';
        leWrapper.legalEntityConsentId = 'EndesaX';
        leWrapper.consentDescriptionLookup = consDescr.Id;
        leWrapper.isExisting = false;
        leWrapper.confirmationByTheCustomer = true;
        leWrapperList.add(leWrapper);
                              
        Map<String, Object> mapAccountByComponent = new Map<String, Object>{
            'addressFields' => JSON.serialize(mapAddressFields),
            'assignRecord' => false,
            'contactFields' => JSON.serialize(mapContactFields),
            'fieldMapStringAccount' => JSON.serialize(mapAccountFields),
            'existingAccountId' => null,
            'robinsonCustomer' => true,
            'recordTypeId' => recordTypeId,
            'isCommunity' => false,
            'thirdPartiesCheck' => 'YES',
            'consentsLE' => JSON.serialize(leConsents),
            'consentsWrapper' => JSON.serialize(leWrapperList)
        }; 
        String mapAccountString = JSON.serialize(mapAccountByComponent);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createRecordSoho mapAccountString ' + mapAccountString);
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk = XC_LCC003_NewAccount.createRecord(mapAccountString);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ wrOk-->  '+ wrOk);
        String  wrapperAccount = XC_LCC003_NewAccount.retrieveData(wrOk.recordId, recordTypeIdString);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ wrapperAccount-->  '+ wrapperAccount);
        Map<String, Object> mapwrapperAccount = (Map<String, Object>) JSON.deserializeUntyped(wrapperAccount);
        Test.stopTest();
    } 

    @isTest
    static void createRecordB2G() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_GLOB2G).getRecordTypeId();
        String recordTypeIdString = recordTypeId;
        Test.startTest();        
        
        Map<String, String> mapAccountFields = new Map<String, String>{
            'XC_ConfirmationByCustomer__c' => 'true',
            'Company__c' => 'test',
            'PrimaryEmail__c' => 'test@te.it', 
            'XC_AccountPhonePrefix__c' => '',
            'XC_AccountPhone__c' => null,
            'XC_MainPhonePrefix__c' => '',
            'XC_AccountMainPhone__c' => null,
            'IdentityType__c'=> 'NIF',
            'IdentityNumber__c'=> '60633939M',
            'XC_NIE_expedition_date__c'=> '2019-01-01',
            'XC_NIE_expiration_date__c'=> '2088-01-01',
            'XC_Preference_Language__c' => '',                
            'XC_Nationality__c' => '',
            'XC_Notes__c' => null,
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
            'XC_RobinsonCustomer__c' => true,
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_GiveDataTo__c' => 'Yes',
            'XC_KeepMeUpdateOnProducts__c' => 'Yes',
            'XC_GiveConsentToDataProcessing__c' => 'Yes'
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);
                  
        Map<String, Object> mapContactFields = new Map<String, Object>{
            'FirstName' => 'Test',
            'LastName' => 'Contact',
            'DocumentCountry' => 'Spain',
            'DocumentType' => 'Passport',
            'DocumentID' => '666666666',
            'Email' => 'test@contact.it',
            'Mobile' => '',
            'Phone' => '',
            'XC_CountryLegalEntity__c' => 'Spain',
            'XC_MainLegalEntity__c' => 'EndesaX'
        }; 

        XC_ConsentDescription__c consDescr = new XC_ConsentDescription__c(
            XC_ConsentVersion__c = '1',
            XC_LegalEntity__c = 'EndesaX',
            XC_Country__c = 'Spain',
            XC_ConsentStatus__c = 'Active',
            XC_DescriptionMarketing__c = 'Test',
            XC_DescriptionProfiling__c = 'Test',
            XC_DescriptionThirdParties__c = 'Test',
            XC_DescriptionGiveDataToLE__c = 'Test'
        );
        insert consDescr;
        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.developerName = 'EndesaX';
        leWrapper.label = 'EndesaX';
        leWrapper.legalEntity = 'EndesaX';
        leWrapper.country = 'Spain';
        leWrapper.companyCode = 'Test';
        leWrapper.consentVersion = 'Test';
        leWrapper.thirdPartyLabel = 'Test';
        leWrapper.profilingLabel = 'Test';
        leWrapper.marketingLabel = 'Test';
        leWrapper.descriptionThirdParties = 'Test';
        leWrapper.descriptionProfiling = 'Test';
        leWrapper.descriptionMarketing = 'Test';
        leWrapper.descriptionGiveData = 'Test';
        leWrapper.marketingValue = 'Test';
        leWrapper.profilingValue = 'Test';
        leWrapper.thirdPartyValue = 'YES';
        leWrapper.legalEntityConsentId = 'EndesaX';
        leWrapper.consentDescriptionLookup = consDescr.Id;
        leWrapper.isExisting = false;
        leWrapper.confirmationByTheCustomer = true;
        leWrapperList.add(leWrapper);
                              
        Map<String, Object> mapAccountByComponent = new Map<String, Object>{
            'addressFields' => JSON.serialize(mapAddressFields),
            'assignRecord' => false,
            'contactFields' => JSON.serialize(mapContactFields),
            'fieldMapStringAccount' => JSON.serialize(mapAccountFields),
            'existingAccountId' => null,
            'robinsonCustomer' => true,
            'recordTypeId' => recordTypeId,
            'isCommunity' => false,
            'thirdPartiesCheck' => 'YES',
            'consentsLE' => JSON.serialize(leConsents),
            'consentsWrapper' => JSON.serialize(leWrapperList)
        }; 
        String mapAccountString = JSON.serialize(mapAccountByComponent);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createRecordSoho mapAccountString ' + mapAccountString);
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk = XC_LCC003_NewAccount.createRecord(mapAccountString);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ wrOk-->  '+ wrOk);
        String  wrapperAccount = XC_LCC003_NewAccount.retrieveData(wrOk.recordId, recordTypeIdString);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ wrapperAccount-->  '+ wrapperAccount);
        Map<String, Object> mapwrapperAccount = (Map<String, Object>) JSON.deserializeUntyped(wrapperAccount);
        Test.stopTest();
    } 

    @isTest
    static void createRecordSFM() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_ESP_Account_SFM').getRecordTypeId();
        String recordTypeIdString = recordTypeId;
        Test.startTest();        
        
        Map<String, String> mapAccountFields = new Map<String, String>{
            'XC_ConfirmationByCustomer__c' => 'true',
            'Company__c' => 'test',
            'PrimaryEmail__c' => 'test@te.it', 
            'XC_AccountPhonePrefix__c' => '',
            'XC_AccountPhone__c' => null,
            'XC_MainPhonePrefix__c' => '',
            'XC_AccountMainPhone__c' => null,
            'IdentityType__c'=> 'NIF',
            'IdentityNumber__c'=> '60633939M',
            'XC_NIE_expedition_date__c'=> '2019-01-01',
            'XC_NIE_expiration_date__c'=> '2088-01-01',
            'XC_Preference_Language__c' => '',                
            'XC_Nationality__c' => '',
            'XC_Notes__c' => null,
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
            'XC_RobinsonCustomer__c' => true,
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_GiveDataTo__c' => 'Yes',
            'XC_KeepMeUpdateOnProducts__c' => 'Yes',
            'XC_GiveConsentToDataProcessing__c' => 'Yes'
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);
                  
        Map<String, Object> mapContactFields = new Map<String, Object>{
            'FirstName' => 'Test',
            'LastName' => 'Contact',
            'DocumentCountry' => 'Spain',
            'DocumentType' => 'Passport',
            'DocumentID' => '666666666',
            'Email' => 'test@contact.it',
            'Mobile' => '',
            'Phone' => '',
            'XC_CountryLegalEntity__c' => 'Spain',
            'XC_MainLegalEntity__c' => 'EndesaX'
        }; 

        XC_ConsentDescription__c consDescr = new XC_ConsentDescription__c(
            XC_ConsentVersion__c = '1',
            XC_LegalEntity__c = 'EndesaX',
            XC_Country__c = 'Spain',
            XC_ConsentStatus__c = 'Active',
            XC_DescriptionMarketing__c = 'Test',
            XC_DescriptionProfiling__c = 'Test',
            XC_DescriptionThirdParties__c = 'Test',
            XC_DescriptionGiveDataToLE__c = 'Test'
        );
        insert consDescr;
        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.developerName = 'EndesaX';
        leWrapper.label = 'EndesaX';
        leWrapper.legalEntity = 'EndesaX';
        leWrapper.country = 'Spain';
        leWrapper.companyCode = 'Test';
        leWrapper.consentVersion = 'Test';
        leWrapper.thirdPartyLabel = 'Test';
        leWrapper.profilingLabel = 'Test';
        leWrapper.marketingLabel = 'Test';
        leWrapper.descriptionThirdParties = 'Test';
        leWrapper.descriptionProfiling = 'Test';
        leWrapper.descriptionMarketing = 'Test';
        leWrapper.descriptionGiveData = 'Test';
        leWrapper.marketingValue = 'Test';
        leWrapper.profilingValue = 'Test';
        leWrapper.thirdPartyValue = 'YES';
        leWrapper.legalEntityConsentId = 'EndesaX';
        leWrapper.consentDescriptionLookup = consDescr.Id;
        leWrapper.isExisting = false;
        leWrapper.confirmationByTheCustomer = true;
        leWrapperList.add(leWrapper);
                              
        Map<String, Object> mapAccountByComponent = new Map<String, Object>{
            'addressFields' => JSON.serialize(mapAddressFields),
            'assignRecord' => false,
            'contactFields' => JSON.serialize(mapContactFields),
            'fieldMapStringAccount' => JSON.serialize(mapAccountFields),
            'existingAccountId' => null,
            'robinsonCustomer' => true,
            'recordTypeId' => recordTypeId,
            'isCommunity' => false,
            'thirdPartiesCheck' => 'YES',
            'consentsLE' => JSON.serialize(leConsents),
            'consentsWrapper' => JSON.serialize(leWrapperList)
        }; 
        String mapAccountString = JSON.serialize(mapAccountByComponent);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createRecordSoho mapAccountString ' + mapAccountString);
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk = XC_LCC003_NewAccount.createRecord(mapAccountString);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ wrOk-->  '+ wrOk);
        System.assertEquals(false, wrOk.success); 
        String  wrapperAccount = XC_LCC003_NewAccount.retrieveData(wrOk.recordId, recordTypeIdString);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ wrapperAccount-->  '+ wrapperAccount);
        Map<String, Object> mapwrapperAccount = (Map<String, Object>) JSON.deserializeUntyped(wrapperAccount);
        Test.stopTest();
    } 
    
    @isTest
    static void updateAccountTEST() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        insert XC_DF_OperatingHours.createOperatingHours(Label.XC_CL_DefaultOperatingHours);
        List<Account> newAccount = XC_DF_Account.createResidentialAccounts(1);
        insert newAccount;
        newAccount[0].PrimaryEmail__c='testets@tes.com';
        Test.startTest(); 
            XC_UTIL_Sobject.WrapperResult wr = XC_LCC003_NewAccount_U.updateAccount(newAccount[0]);
        System.assert(wr!=null);
        Test.stopTest();
    }
    
    @isTest
    static void createRecordPartner() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        insert XC_DF_OperatingHours.createOperatingHours(Label.XC_CL_DefaultOperatingHours);
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
        String recordTypeIdString = recordTypeId;
        Test.startTest();        
        
        Map<String, String> mapAccountFields = new Map<String, String>{ 
            'XC_PartnerType__c' => 'Sales',
            'XC_CommercialCode__c' => 'test', 
            'XC_InternalCommercialCode__c' => 'test',
            'XC_FirstName__c' => 'Sales',
            'XC_LastName__c' => 'test', 
            'PrimaryEmail__c' => 'test@partnertest.com',
            'XC_AccountPhonePrefix__c' => '',
            'XC_AccountPhone__c' => null,
            'XC_MainPhonePrefix__c' => '',
            'XC_AccountMainPhone__c' => null,
            'IdentityType__c'=> 'Passport',
            'IdentityNumber__c'=> 'test1234',
            'XC_ReceivingChannel__c'=> 'Email',  
            'XC_DocumentCountry__c' => '',                
            'XC_Nationality__c' => '', 
            'XC_PhonePrefix__c'=> '',
            'XC_MobilePrefix__c'=> '',
            'XC_ContactPhone__c'=> null,
            'XC_ContactMobile__c'=> null 
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
            'validate' => true,
            'pointOfSales' => true,
            'warehouse'=> true,
            'pickupPoint'=> true
        };

        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LeCountry__c' => 'Spain',
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_RobinsonCustomer__c' => true,
            'XC_GiveDataTo__c' => 'Yes',
            'XC_KeepMeUpdateOnProducts__c' => 'Yes',
            'XC_GiveConsentToDataProcessing__c' => 'Yes'
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);
                  
        Map<String, Object> mapContactFields = new Map<String, Object>{
            'FirstName' => 'Test',
            'LastName' => 'Contact',
            'DocumentType' => '',
            'DocumentID' => '',
            'Email' => 'test@contact.it',
            'Mobile' => '',
            'Phone' => '',
            'XC_CountryLegalEntity__c' => 'Spain',
            'XC_MainLegalEntity__c' => 'EndesaX'
        }; 
                              
        Map<String, Object> mapAccountByComponent = new Map<String, Object>{
            'addressFields' => JSON.serialize(mapAddressFields),
            'assignRecord' => false,
            'contactFields' => JSON.serialize(mapContactFields),
            'fieldMapStringAccount' => JSON.serialize(mapAccountFields),
            'existingAccountId' => null,
            'recordTypeId' => recordTypeId,
            'isCommunity' => false,
            'thirdPartiesCheck' => true,
            'consentsLE' => JSON.serialize(leConsents)
        }; 
        String mapAccountString = JSON.serialize(mapAccountByComponent);
       
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk = XC_LCC003_NewAccount.createRecord(mapAccountString);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ wrOk-->  '+ wrOk);
        System.assertEquals(false, wrOk.success); 
        String  wrapperAccount = XC_LCC003_NewAccount.retrieveData(wrOk.recordId, recordTypeIdString);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ wrapperAccount-->  '+ wrapperAccount);
        Map<String, Object> mapwrapperAccount = (Map<String, Object>) JSON.deserializeUntyped(wrapperAccount);
        System.assert(mapwrapperAccount.get('recordTypeName') == 'XC_Account_Partner');
        Test.stopTest();
    } 
    
    @isTest
    static void getListView() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();        
        ListView listView = XC_LCC003_NewAccount.getListViews();
        System.assertEquals('Recently Viewed Accounts', listView.Name); 
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk = XC_LCC003_NewAccount.createRecord('');
        System.assertEquals(false, wrOk.success);
        Test.stopTest();
    } 
    
    @isTest
    static void insertDuplicatedAccount() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        insert XC_DF_Account.createResidentialAccounts(1);
        Test.startTest();
        try{
            insert XC_DF_Account.createResidentialAccounts(1);
        } catch (Exception e){
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    static void onUtility() {
        List<XC_CM_CountryLegalEntityAssociation__mdt> cm = new List<XC_CM_CountryLegalEntityAssociation__mdt>([
            SELECT XC_Country__c, XC_Category__c
            FROM XC_CM_CountryLegalEntityAssociation__mdt
            WHERE XC_Country__c = 'Spain' AND XC_Category__c = 'B2C'
            LIMIT 1
        ]);
        XC_CM_CountryLegalEntityAssociation__mdt cmDump = new XC_CM_CountryLegalEntityAssociation__mdt(
            XC_Country__c = 'Spain',
            XC_Category__c = 'B2C'
        );
        Individual ind = new Individual(LastName = 'Test');
        insert ind;
        List<Account> listAcc = XC_DF_Account.createResidentialAccounts(1);
        insert listAcc;
        List<Contact> listCont = XC_DF_Contact.createResidentialContacts(new List<Account>{new Account(Id=listAcc[0].Id)});
        insert listCont;
        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LeCountry__c' => 'Spain',
            'XC_RobinsonCustomer__c' => true,
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_GiveDataTo__c' => 'Yes',
            'XC_KeepMeUpdateOnProducts__c' => 'Yes',
            'XC_GiveConsentToDataProcessing__c' => 'Yes'
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);
        XC_TR_Account_U_CheckDuplicates.ResultWrapper duplWrapper = new XC_TR_Account_U_CheckDuplicates.ResultWrapper();
        duplWrapper.ac = listAcc[0];
        duplWrapper.accountID = listAcc[0].Id;
        duplWrapper.success = true;
        duplWrapper.successConsent = true;
        duplWrapper.existingContact = listCont[0];
        XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData = new XC_LCC003_NewAccount_W.AccountInputDataWrapper();
        inputData.accountCheckDuplicateRes = duplWrapper;
        inputData.consentsLE = JSON.serialize(leConsents);

        Map<String, String> leObject = new Map<String, String>{
            'XC_LeCountry__c' => 'Spain',
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_GiveDataTonew__c' => 'YES',
            'XC_UpdateAboutProducts__c' => 'YES',
            'XC_ConsentToDataProcessing__c' => 'YES'
        }; 
        List<Map<String, String>> listObj = new List<Map<String, String>>();
        listObj.add(leObject);
        String mapAccountString = JSON.serialize(listObj);

        Test.startTest();
        XC_LCC003_NewAccount.populateWrapperPartner(new XC_LCC003_NewAccount.FieldSetWrapper(), cm[0]);
        XC_LCC003_NewAccount.populateWrapperGlobalB2G(new XC_LCC003_NewAccount.FieldSetWrapper(), cm[0]);
        //XC_LCC003_NewAccount.populateWrapperPartner(new XC_LCC003_NewAccount.FieldSetWrapper(), cmDump);
        XC_LCC003_NewAccount.populateWrapperSupplier(new XC_LCC003_NewAccount.FieldSetWrapper(), cm[0]);
        //XC_LCC003_NewAccount.populateWrapperSupplier(new XC_LCC003_NewAccount.FieldSetWrapper(), cmDump);
        //XC_LCC003_NewAccount.populateWrapperCondominium(new XC_LCC003_NewAccount.FieldSetWrapper(), cm[0]);
        //XC_LCC003_NewAccount.populateWrapperCondominium(new XC_LCC003_NewAccount.FieldSetWrapper(), cmDump);
        XC_LCC003_NewAccount.populateWrapperResidential(new XC_LCC003_NewAccount.FieldSetWrapper(), cm[0]);
        //XC_LCC003_NewAccount.populateWrapperResidential(new XC_LCC003_NewAccount.FieldSetWrapper(), cmDump);
        //XC_LCC003_NewAccount.populateWrapperSoho(new XC_LCC003_NewAccount.FieldSetWrapper(), cm[0]);
        //XC_LCC003_NewAccount.populateWrapperSoho(new XC_LCC003_NewAccount.FieldSetWrapper(), cmDump);
        XC_LCC003_NewAccount.getListViews();
        XC_LCC003_NewAccount_Related.updateAccountToPrimary(listAcc[0], inputData, Database.setSavepoint());
        XC_LCC003_NewAccount_Related.updateIndividual(ind.Id, inputData);
        XC_LCC003_NewAccount_Related.populateLEWrapper(mapAccountString);
        XC_LCC003_NewAccount.populateWrapperSFM(new XC_LCC003_NewAccount.FieldSetWrapper(), 'XC_ESP_Account_SFM');
        XC_LCC003_NewAccount.isSpain();
        System.assertNotEquals(null, cm);
        Test.stopTest();
    }

}