/**
 * @author Monica Cutillo - mcutillo@deloitte.it
 * @date Creation 07/02/2020
 * @date Modification dd/mm/yyyy
 * @description XC_UTIL_LegalEntityConsents_TEST - test class for XC_UTIL_LegalEntityConsents.
 */
@isTest
public class XC_UTIL_LegalEntityConsents_TEST {

    private static Id createLe(){
        List<XC_CM_CountryLegalEntityAssociation__mdt> listCM = new List<XC_CM_CountryLegalEntityAssociation__mdt>([
                                                                SELECT XC_Country__c
                                                                FROM XC_CM_CountryLegalEntityAssociation__mdt
                                                                WHERE XC_LegalEntity__c ='EndesaX'
                                                                                                                ]);
        Individual individual = new Individual(
            LastName= 'Test',
            XC_GiveDataToThirdParties__c='Yes'
            );
        insert individual;
        XC_LegalEntityConsent__c lec= new XC_LegalEntityConsent__c(
            XC_LegalEntity__c='EndesaX',
            XC_Individual__c=individual.id,
            XC_IndividualId__c=individual.id,
            XC_LeCountry__c = listCM[0].XC_Country__c,
            XC_GiveDataToNew__c='Yes'
            );
        insert lec;
        return Individual.Id;
    }
    
    
    
    @isTest static void checkAvailableConsentForContact() {
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(2);
        accountList[0].XC_GiveDataTo_EndesaX__c = true;
        accountList[0].XC_GiveDataTo_JuicenetLimited__c = true;
        insert accountList;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accountList);
        insert contacts;
        
        Map<String,Object> data = new Map<String,Object>();
        data.put('XC_LegalEntity__c','EndesaX');
        data.put('XC_GiveDataToNew__c','Yes');
        data.put('XC_UpdateAboutProducts__c','Yes');
        data.put('XC_ConsentToDataProcessing__c','Yes');
        
        Id individualId1 = createLe();
        Id individualId2 = createLe();
        contacts[0].IndividualId = individualId1;
        contacts[1].IndividualId = individualId2;
        update contacts;
        
        Map<String,Object> dataNew = new Map<String,Object>();
        dataNew.put('XC_LegalEntity__c','Codensa');
        dataNew.put('XC_GiveDataToNew__c','Yes');
        dataNew.put('XC_UpdateAboutProducts__c','Yes');
        dataNew.put('XC_ConsentToDataProcessing__c','Yes');
        
       	XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData = new XC_LCC003_NewAccount_W.AccountInputDataWrapper();
		inputData.consentsLE = JSON.serialize(new List<Object>{dataNew});
        
        Test.startTest();
            XC_UTIL_LegalEntityConsents.checkAvailableConsentForContact(accountList[0], contacts[1], inputData);
        Test.stopTest();
        
        System.assert(inputData.consentsLE != null);
    }
    
    @isTest static void checkAvailableLegalEntityOnSecContact() {
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accountList);
        insert contacts;
        
        Map<String,Object> data = new Map<String,Object>();
        data.put('XC_LegalEntity__c','EndesaX');
        data.put('XC_GiveDataToNew__c','Yes');
        data.put('XC_UpdateAboutProducts__c','Yes');
        data.put('XC_ConsentToDataProcessing__c','Yes');
        data.put('XC_ConsentToDataProcessing__c','Yes');
        
        Id individualId = createLe();
        
        Map<Id,XC_LegalEntityConsent__c> LEdata = new Map<Id,XC_LegalEntityConsent__c>([
            SELECT Id, XC_Individual__c, XC_LegalEntity__c, XC_GiveDataToNew__c, XC_UpdateAboutProducts__c, XC_ConsentToDataProcessing__c, XC_LegalEntityConsent__c.XC_IndividualId__c
            FROM XC_LegalEntityConsent__c
            WHERE XC_Individual__c =: individualId
        ]);
        
        Test.startTest();
            Map<Id,XC_UTIL_ResultWrapper> wr = XC_UTIL_LegalEntityConsents.checkAvailableLegalEntityOnSecContact(LEdata.values());
        Test.stopTest();
        
        System.assert(wr != null);
    }
    
    @isTest static void checkAllConsentsOfPrimary() {
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        
        Map<String,Object> data = new Map<String,Object>();
        data.put('XC_LegalEntity__c','EndesaX');
        data.put('XC_GiveDataToNew__c','Yes');
        data.put('XC_UpdateAboutProducts__c','Yes');
        data.put('XC_ConsentToDataProcessing__c','Yes');
        data.put('XC_ConsentToDataProcessing__c','Yes');
        
        Id individualId = createLe();
        
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accountList);
        contacts[0].IndividualId = individualId;
        insert contacts;
        
        Test.startTest();
        	Map<Id,List<String>> wr = XC_UTIL_LegalEntityConsents.checkAllConsentsOfPrimary(contacts);
        Test.stopTest();
        
        System.assert(wr != null);
    }
}