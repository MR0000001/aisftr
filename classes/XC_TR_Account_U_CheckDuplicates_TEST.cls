/**
* @author Valeria Martino valeria.martino@nttdata.com
* @date Creation 21/08/2019 
* @description XC_TR_Account_U_CheckDuplicates_TEST – Test class for XC_TR_Account_U_CheckDuplicates
*/

@isTest
public class XC_TR_Account_U_CheckDuplicates_TEST {
     @TestSetup
    static void setup(){
        Test.startTest();
        OneOrg__c org            = new OneOrg__c(); 
        org.Name                 = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org; 
        List<Account> listAccount = XC_DF_Account.createResidentialAccounts(2);
        insert listAccount;
        //update listAccount;
        Test.stopTest();
    }

    private static  XC_LCC003_NewAccount_W.InsertResultWrapper createAccount(string primaryEmail,String name, String identityNumber) {
        String recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();
        String recordTypeIdString = recordTypeId;

        Map<String, String> mapAccountFields = new Map<String, String>{
            'Name'=> name,
            'Company__c'=>'testSoho',
            'XC_FirstName__c' => 'test',
            'XC_LastName__c' => 'test',
            'XC_AccountPhonePrefix__c' => '',
            'XC_AccountPhone__c' => null,
            'XC_MainPhonePrefix__c' => '',
            'XC_AccountMainPhone__c' => null,
            'PrimaryEmail__c' => primaryEmail,
            'XC_BirthDate__c' => null,
            'XC_Preference_Language__c' => '',
            'XC_AccountNationality__c' => '',
            'XC_Notes__c' => null,
            'XC_DocumentCountry__c' => 'Spain',
            'IdentityType__c' => 'Passport',
 			'IdentityNumber__c' => identityNumber,
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
        System.debug('setup  mapAccountString ' + mapAccountString);
        XC_LCC003_NewAccount_W.InsertResultWrapper wrOk = XC_LCC003_NewAccount.createRecord(mapAccountString);
        System.debug('@@@@@ setup wrOk-->  '+ wrOk);
        return wrOk;
    }
    @isTest
    static void checkDuplicated(){
        List<Account> existingAccounts = new List<Account>([
                SELECT Id, XC_isGuestUser__c, RecordTypeId, Name, XC_RecordTypeDeveloperName__c, PrimaryEmail__c, IdentityType__c, IdentityNumber__c, XC_DocumentCountry__c
                FROM Account LIMIT 2]);
        
        existingAccounts[0].PrimaryEmail__c = existingAccounts[1].PrimaryEmail__c;
        update existingAccounts;  

        createAccount(existingAccounts[0].PrimaryEmail__c, existingAccounts[0].Name, existingAccounts[0].IdentityNumber__c);
        XC_TR_Account_U_CheckDuplicates.checkSingleAccountDuplicated(existingAccounts[0], existingAccounts[1]);
        Test.startTest();
        XC_UTIL_AccountDuplication_W.CheckFieldWrapper checkFieldWrapper = new XC_UTIL_AccountDuplication_W.CheckFieldWrapper();
        for(Account acc : existingAccounts) {
            checkFieldWrapper.setId.add(acc.id);
            checkFieldWrapper.setEmail.add(acc.PrimaryEmail__c);
            checkFieldWrapper.setDocumentType.add(acc.IdentityType__c);
            checkFieldWrapper.setDocumentNumber.add(acc.IdentityNumber__c);
        }
        List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper> results = XC_TR_Account_U_CheckDuplicates.checkErrorDuplicates(existingAccounts, existingAccounts, checkFieldWrapper);
        Test.stopTest();
        System.assert(results != NULL);
		
		XC_TR_Account_U_CheckDuplicates_D.getAccountInFiscalCodeList(existingAccounts);
		XC_TR_Account_U_CheckDuplicates_D.getAccountInEmailList(existingAccounts);
    }
}