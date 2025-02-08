/**
*@author Sara Miozza - sara.miozza@nttdata.com
*@date Creation 20/05/2019
*@date Modification dd/MM/yyyy
*@description XC_LCC091_NewZipCodeSkillTerritory test class for XC_LCC091_NewZipCodeSkillTerritory
*/


@isTest
public class XC_LCC091_NewZipCodeSkillTerritory_TEST {

    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        org.XC_Spain_ValidationRules__c =  true;
        insert org;
        OperatingHours opH = XC_DF_OperatingHours.createOperatingHours('TEST');
        insert opH;
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1);
        ServiceTerritory servTerr = new ServiceTerritory();
        servTerr.XC_AccountId__c = accList[0].Id;
        servTerr.XC_Country__c = 'Spain';
        servTerr.Name = 'TEST';
        servTerr.OperatingHoursId = opH.id;
        servTerr.IsActive = true; 
        insert servTerr;
        User u = XC_DF_User.createUserAdmin();
        insert u;

        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeSkill = new  XC_ZipCodeSkill_TerritoryAssociation__c(XC_Province__c = 'Madrid',
                                                                                                             XC_ServiceTerritoryId__c = servTerr.Id,
                                                                                                             XC_ListOfSkillNames__c = 'Commercial Visit;Planned Maintenance',
                                                                                                             XC_ZipCode__c = '28080' );
        insert zipCodeSkill;
        ServiceResource servRes = new ServiceResource(Name = 'Test', XC_Account__c = accList[0].Id, isCapacityBased = true,
                                                         RelatedRecordId = u.Id, isActive = true
                                                         );
        insert servRes;

        ServiceTerritoryMember servTerrMemb = new ServiceTerritoryMember(
            ServiceTerritoryId = servTerr.Id,
            ServiceResourceId = servRes.Id,
            EffectiveStartDate = Date.Today()
        );
        insert servTerrMemb;

        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(1);
        insert contactList;
        
        
    }


    @isTest
    static void checkRootTerritoryForProfilesTest(){
        
        Test.startTest(); 
        ServiceTerritory servTerr = [SELECT Id FROM ServiceTerritory LIMIT 1];
        Id recordId = servTerr.Id;
        Boolean isRoot = XC_LCC091_NewZipCodeSkillTerritory.checkRootTerritoryForProfiles(recordId);
        System.assert(!isRoot); 
        
        Test.stopTest();
       
    }
    
    @isTest
    static void checkRootTerritoryTest(){
        Test.startTest(); 
        ServiceTerritory servTerr = [SELECT Id FROM ServiceTerritory LIMIT 1];
        Id recordId = servTerr.Id;
        Boolean isRoot = XC_LCC091_NewZipCodeSkillTerritory.checkRootTerritory(recordId);
        System.assert(isRoot);
        Test.stopTest(); 
    }

    @isTest
    static void getRootProvinceTest(){
        Test.startTest(); 
        ServiceTerritory servTerr = [SELECT Id FROM ServiceTerritory LIMIT 1];
        Id recordId = servTerr.Id;
        List<String> provinceList = XC_LCC091_NewZipCodeSkillTerritory.getRootProvince(recordId);
        System.assert(!provinceList.isEmpty());
        Test.stopTest(); 
    }

    @isTest
    static void getZipCodeFromRootTest(){
        Test.startTest(); 
        ServiceTerritory servTerr = [SELECT Id FROM ServiceTerritory LIMIT 1];
        Id recordId = servTerr.Id;
        String province = 'Madrid';
        List<String> zipCode = XC_LCC091_NewZipCodeSkillTerritory.getZipCodeFromRoot(recordId,province);
        System.assert(!zipCode.isEmpty());
        Test.stopTest(); 
    }

    @isTest
    static void getCountry1Test(){
        Test.startTest(); 
        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeSkill = [SELECT Id,XC_ServiceTerritoryId__c FROM XC_ZipCodeSkill_TerritoryAssociation__c LIMIT 1];
        Id recordId = zipCodeSkill.Id;
        String country = XC_LCC091_NewZipCodeSkillTerritory.getCountry(recordId);
        System.assert(!String.isBlank(country));
        Test.stopTest(); 
    }

    @isTest
    static void getCountry2Test(){
        Test.startTest(); 
        ServiceTerritory servTerr = [SELECT Id,XC_Country__c FROM ServiceTerritory LIMIT 1];
        Id recordId = servTerr.Id;
        String country = XC_LCC091_NewZipCodeSkillTerritory.getCountry(recordId);
        System.assert(!String.isBlank(country));
        Test.stopTest(); 
    }

    @isTest
    static void saveSkillTerritory1Test(){
        Test.startTest(); 
        XC_UTIL_ResultWrapper rw = XC_LCC091_NewZipCodeSkillTerritory.saveSkillTerritory('');
        System.assert(!rw.success);
        Test.stopTest(); 
    }

    @isTest
    static void saveSkillTerritory2Test(){
        Test.startTest(); 
        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeSkill = [SELECT Id,XC_ServiceTerritoryId__c,XC_Province__c,XC_ZipCode__c,XC_ListOfSkillNames__c FROM XC_ZipCodeSkill_TerritoryAssociation__c LIMIT 1];
        Id recordId = zipCodeSkill.XC_ServiceTerritoryId__c;
        Map<String,Object> skillMap = new Map<String,Object>();
        skillMap.put('recordId', recordId);
        skillMap.put('zipCode', zipCodeSkill.XC_ZipCode__c);
        skillMap.put('province', zipCodeSkill.XC_Province__c);
        skillMap.put('skillList', zipCodeSkill.XC_ListOfSkillNames__c);
        String skillMapString = JSON.serialize(skillMap);
        XC_UTIL_ResultWrapper rw = XC_LCC091_NewZipCodeSkillTerritory.saveSkillTerritory(skillMapString);  
        System.assert(rw.success);
        Test.stopTest(); 
    }

    @isTest
    static void setZipCodeValuesTest(){
        Test.startTest(); 
        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeSkill = [SELECT Id,XC_ServiceTerritoryId__c,XC_Province__c,XC_ZipCode__c,XC_ListOfSkillNames__c FROM XC_ZipCodeSkill_TerritoryAssociation__c LIMIT 1];
        String recordId = zipCodeSkill.Id;
        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeSkillTerr = XC_LCC091_NewZipCodeSkillTerritory.setZipCodeValues(recordId);
        System.assert(zipCodeSkill.XC_Province__c == 'Madrid');
        Test.stopTest(); 
    }

    @isTest
    static void getSkillForTerritoryTest(){
        Test.startTest(); 
        ServiceTerritory servTerr = [SELECT Id,XC_Country__c FROM ServiceTerritory LIMIT 1];
        Id recordId = servTerr.Id;
        List<String> skillList = XC_LCC091_NewZipCodeSkillTerritory.getSkillForTerritory(recordId);
        System.assert(skillList.isEmpty());
        Test.stopTest(); 
    }

    @isTest
    static void getSkillForTerritoryFromRootTest(){
        Test.startTest(); 
        ServiceTerritory servTerr = [SELECT Id,XC_Country__c FROM ServiceTerritory LIMIT 1];
        Id recordId = servTerr.Id;
        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeSkill = [SELECT Id,XC_ServiceTerritoryId__c,XC_Province__c,XC_ZipCode__c,XC_ListOfSkillNames__c FROM XC_ZipCodeSkill_TerritoryAssociation__c LIMIT 1];
        List<String> skillList = XC_LCC091_NewZipCodeSkillTerritory.getSkillForTerritoryFromRoot(recordId,zipCodeSkill.XC_Province__c,zipCodeSkill.XC_ZipCode__c);
        System.assert(!skillList.isEmpty());
        Test.stopTest(); 
    }
    
      static testMethod void canInsertTest(){
        XC_DF_Account.insertPartnerAccounts(1);
        List<Account> accList = [SELECT Id, Name FROM Account];
        List<ServiceTerritory> servTerrList = XC_DF_ServiceTerritory.createServiceTerritories(accList);
        servTerrList[0].Name = 'Test Territory'; 
        insert servTerrList[0];
        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeSkill = new  XC_ZipCodeSkill_TerritoryAssociation__c(XC_Province__c = 'Madrid',
                                                                                                             XC_ServiceTerritoryId__c = servTerrList[0].Id,
                                                                                                             XC_ListOfSkillNames__c = 'Commercial Visit;Planned Maintenance',
                                                                                                             XC_ZipCode__c = '28080' );
        insert zipCodeSkill;
        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeTerritoryAss = [SELECT Id, XC_Province__c, XC_ServiceTerritoryId__c, XC_ListOfSkillNames__c, XC_ZipCode__c FROM XC_ZipCodeSkill_TerritoryAssociation__c WHERE XC_ServiceTerritoryId__c =: servTerrList[0].Id ];
        Test.startTest();
        Boolean cannotInsert = XC_LCC091_NewZipCodeSkillTerritory.checkRootTerritoryForProfiles(servTerrList[0].Id);
        System.assertEquals(cannotInsert, false);
        Test.stopTest();
     }   

    
    


}