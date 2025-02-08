/**
* @author dpalamides
* @date 29/10/2019
* @description classes.XC_UTIL_GDPR_TEST
*/
@isTest
public class XC_UTIL_GDPR_TEST {

    @TestSetup
    static void makeData(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        updateCurrUserLE('EndesaX');
        List<XC_CM_CountryLegalEntityAssociation__mdt> listLegalEntityCountry = [SELECT Id,XC_LegalEntity__c,XC_Country__c FROM XC_CM_CountryLegalEntityAssociation__mdt WHERE XC_LegalEntity__c NOT IN ('eMobilityUK','EndesaEnergia','EnelXSrl')];
        List<XC_ConsentDescription__c> listconsDescr = new List<XC_ConsentDescription__c>();
        if(!listLegalEntityCountry.isEmpty()) {
            for(XC_CM_CountryLegalEntityAssociation__mdt le :listLegalEntityCountry ) {
                listconsDescr.add(createConsentDescription(le.XC_LegalEntity__c, le.XC_Country__c));
            }
        }
      
        if(!listconsDescr.isEmpty()) {
            insert listconsDescr;
        }
       

        User u =[SELECT ID,XC_LegalEntity__c,XC_LEgalEntities__c FROM USER WHERE ID =: UserInfo.getUserId()];
        System.debug('CUrrent User:'+ u);
    }

    static testMethod void getLegalEntities(){
       
        Test.startTest();
        Lead theLead = XC_DF_Lead.createResidentialLeads(1)[0];
        theLead.Country__c = 'Spain';
     
        XC_LCC163_CreateConsents.getLegalEntities(theLead.Id,'Lead', JSON.serialize(theLead));

        Test.stopTest();
    }

    static testMethod void getCreateEntities(){
      
        Test.startTest();
        Lead theLead = XC_DF_Lead.createResidentialLeads(1)[0];
        theLead.Country__c = 'Spain';
     
       
        String leList = XC_LCC163_CreateConsents.getLegalEntities(theLead.Id,'Lead', JSON.serialize(theLead));
        System.debug('JSON response ;'+leList);
        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> responseDes = (List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>)JSON.deserialize(leList, List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>.class);
      // XC_LCC163_CreateConsents.GetLegalEntitiesResponse legResp =(XC_LCC163_CreateConsents.GetLegalEntitiesResponse) JSON.deserialize(leList, XC_LCC163_CreateConsents.GetLegalEntitiesResponse.class);
        XC_LCC163_CreateConsents.createLegalEntities(JSON.serialize(responseDes.get(0)));
		
        responseDes.get(0).consentsData.setConsentVersion(new XC_ConsentDescription__c());
        responseDes.get(0).consentsData.updateLegalEntityConsent(new XC_LegalEntityConsent__c());
        
        responseDes.get(0).consentsData.personalInfo.theContactIndividual = new Individual();
        responseDes.get(0).consentsData.updateExistingIndividual();
        Test.stopTest();
    }
    
    static testMethod void getCreateEntities2(){
      
        Test.startTest();
        List<Individual> listindiv = new List<Individual>();
        Individual indi = new Individual();
        indi.FirstName ='Test';
        indi.LastName = 'Testt';
        listindiv.add(indi);
        insert listindiv;
        
        List<Contact> listc = XC_DF_Contact.createResidentialContacts(1);
        List<Account> liAcc = XC_DF_Account.createResidentialAccounts(1);
        liAcc[0].XC_ConfirmationByCustomer__c = true;
        insert liAcc;
        listc[0].AccountId=liAcc[0].Id;
        listc[0].IndividualId = indi.Id;
        listc[0].FirstName ='Testc';
        insert listc;
       
        String leList = XC_LCC163_CreateConsents.getLegalEntities(liAcc[0].Id,'Account', JSON.serialize(liAcc[0]));
        System.debug('JSON response ;'+leList);
        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> responseDes = (List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>)JSON.deserialize(leList, List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>.class);
      // XC_LCC163_CreateConsents.GetLegalEntitiesResponse legResp =(XC_LCC163_CreateConsents.GetLegalEntitiesResponse) JSON.deserialize(leList, XC_LCC163_CreateConsents.GetLegalEntitiesResponse.class);
        XC_LCC163_CreateConsents.createLegalEntities(JSON.serialize(responseDes.get(0)));
        Map<Id, List<String>> mapExistingInd = XC_UTIL_GDPR_D.getExistingLegalEntities(new List<Id>{indi.Id});
        Map<Id, Map<String,XC_LegalEntityConsent__c>> mapExisitingIndLEC = XC_UTIL_GDPR_D.getExistingLegalEntitiesConsents(new List<Individual>{indi});
        Map<String, XC_ConsentDescription__c> mapConsentDescription = XC_UTIL_GDPR_D.getConsentDescriptionsByLegalEntity(new List<String>{'EndesaX'});
        Map<String, XC_ConsentDescription__c> mapConsentDescriptionWithVersion = XC_UTIL_GDPR_D.getConsentDescriptionsByCountryAndVersion(new List<String>{'EndesaX'});
        Map<Id, Contact> mapContact =  XC_UTIL_GDPR_D.getContacts(new List<Id>{liAcc[0].Id});
        Test.stopTest();
    }
    

    
    static testMethod void getLegalEntitiesOptions_test() {
        Test.startTest();
            Contact cont = XC_DF_Contact.createResidentialContacts(1)[0];
            Account acc = [SELECT Id,Name FROM Account];
            String res=XC_LCC163_CreateConsents.getLegalEntitiesOptions(acc.Id,'Account',Json.serialize(acc));
        Test.stopTest();
        System.assertEquals(true, String.isNotBlank(res));
    }

 
    static testMethod void getLegalEntitiesOptions_test2() {
        Test.startTest();
            Contact cont = XC_DF_Contact.createResidentialContacts(1)[0];
              insert cont;
            Account acc = [SELECT Id,Name FROM Account];
            String res=XC_LCC163_CreateConsents.getLegalEntitiesOptions(cont.Id,'Contact',Json.serialize(cont));
        Test.stopTest();
        System.assertEquals(true, String.isNotBlank(res));
    }

      
    static testMethod void getgetAccount_test1() {
        Test.startTest();
            Contact cont = XC_DF_Contact.createResidentialContacts(1)[0];
            Account acc = [SELECT Id,Name FROM Account];
            XC_LCC163_CreateConsents_U.getAccount(cont.Id,'Contact',Json.serialize(cont));
            XC_LCC163_CreateConsents_U.getPrimaryContact(cont.Id,'Contact',Json.serialize(cont));
            XC_LCC163_CreateConsents_U.getPrimaryContact(acc.Id,'Account',Json.serialize(acc));
        Test.stopTest();
        System.assertEquals(true, true);
    }

      
    static testMethod void getgetAccount_test2() {
        Test.startTest();
            Contact cont = XC_DF_Contact.createResidentialContacts(1)[0];
            insert cont;
            Account acc = [SELECT Id,Name FROM Account];
            XC_LCC163_CreateConsents_U.getAccount(cont.Id,'Contact',Json.serialize(cont));
            XC_LCC163_CreateConsents_U.getPrimaryContact(cont.Id,'Contact',Json.serialize(cont));
            XC_LCC163_CreateConsents_U.getPrimaryContact(acc.Id,'Account',Json.serialize(acc));
        Test.stopTest();
        System.assertEquals(true, true);
    }

    private static void updateCurrUserLE(String le){
        User u = (User) XC_UTIL_Sobject.selectAllFields(UserInfo.getUserId())[0];
        u.XC_LegalEntity__c = le;
        String legalEntities = le;
        u.XC_LegalEntities__c=legalEntities;
        XC_UTIL_Sobject.updateRecord(u);
    }

    private static XC_ConsentDescription__c createConsentDescription(String le, String country){
        XC_ConsentDescription__c ret = new XC_ConsentDescription__c();
        ret.XC_Country__c = country;
        ret.xc_LegalEntity__c = le;
        ret.XC_ConsentVersion__c = '1.0';
        ret.XC_ConsentStatus__c = 'Active';
        ret.XC_DescriptionThirdParties__c = 'xxxxxxxxxxxx';
        ret.XC_DescriptionMarketing__c = 'yyyyyyyyyy';
        ret.XC_DescriptionProfiling__c = 'zzzzzzzzzz';
        ret.XC_DescriptionLanguage__c='en_US';
        ret.XC_DescriptionGiveDataToLE__c='testtest';
        //insert ret;
        return ret;
    }
}