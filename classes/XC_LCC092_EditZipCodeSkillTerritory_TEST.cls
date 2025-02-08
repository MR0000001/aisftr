/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_LCC092_EditZipCodeSkillTerritory_TEST – Test Class for XC_LCC092_EditZipCodeSkillTerritory
*/ 

@isTest
public class XC_LCC092_EditZipCodeSkillTerritory_TEST {
     @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        org.XC_Spain_ValidationRules__c =  true;
        insert org;
    }

     static testMethod void rootTerritoryTest(){
        XC_DF_Account.insertPartnerAccounts(1);
        List<Account> accList = [SELECT Id, Name FROM Account];
        insert XC_DF_ServiceTerritory.createServiceTerritories(accList);
        List<ServiceTerritory> servTerrList = [SELECT Id FROM ServiceTerritory];
        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeSkill = new  XC_ZipCodeSkill_TerritoryAssociation__c(XC_Province__c = 'Madrid',
                                                                                                             XC_ServiceTerritoryId__c = servTerrList[0].Id,
                                                                                                             XC_ListOfSkillNames__c = 'Commercial Visit;Planned Maintenance',
                                                                                                             XC_ZipCode__c = '28080' );
        insert zipCodeSkill;
        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeTerritoryAss = [SELECT Id, XC_Province__c, XC_ServiceTerritoryId__c, XC_ListOfSkillNames__c, XC_ZipCode__c FROM XC_ZipCodeSkill_TerritoryAssociation__c];
        Test.startTest();
        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeTerr = XC_LCC092_EditZipCodeSkillTerritory.setZipCodeValues(zipCodeTerritoryAss.Id);
        Boolean canInsert = XC_LCC092_EditZipCodeSkillTerritory.checkRootTerritoryForProfilesInEdit(zipCodeTerritoryAss.Id);
        Boolean isRoot = XC_LCC092_EditZipCodeSkillTerritory.checkRootTerritoryInEdit(zipCodeTerritoryAss.Id);
        System.assertEquals(isRoot , true);
        System.assertEquals(zipCodeTerr.XC_ServiceTerritoryId__c , servTerrList[0].Id);
        Test.stopTest();
     }   
    
    static testMethod void getCountryTest(){
        XC_DF_Account.insertPartnerAccounts(1);
        List<Account> accList = [SELECT Id, Name FROM Account];
        insert XC_DF_ServiceTerritory.createServiceTerritories(accList);
        List<ServiceTerritory> servTerrList = [SELECT Id FROM ServiceTerritory];
        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeSkill = new  XC_ZipCodeSkill_TerritoryAssociation__c(XC_Province__c = 'Madrid',
                                                                                                             XC_ServiceTerritoryId__c = servTerrList[0].Id,
                                                                                                             XC_ListOfSkillNames__c = 'Commercial Visit;Planned Maintenance',
                                                                                                             XC_ZipCode__c = '28080' );
        insert zipCodeSkill;
        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeTerritoryAss = [SELECT Id, XC_Province__c, XC_ServiceTerritoryId__c, XC_ListOfSkillNames__c, XC_ZipCode__c FROM XC_ZipCodeSkill_TerritoryAssociation__c];
        Test.startTest();
        String countryTerr = XC_LCC092_EditZipCodeSkillTerritory.getCountry(zipCodeTerritoryAss.Id);
        String countryAss = XC_LCC092_EditZipCodeSkillTerritory.getCountry(servTerrList[0].Id);
        System.assertEquals(countryTerr , 'SPAIN');
        System.assertEquals(countryAss , 'SPAIN');
        Test.stopTest();
     }  
    static testMethod void updateAssTest(){
        XC_DF_Account.insertPartnerAccounts(1);
        List<Account> accList = [SELECT Id, Name FROM Account];
        insert XC_DF_ServiceTerritory.createServiceTerritories(accList);
        List<ServiceTerritory> servTerrList = [SELECT Id FROM ServiceTerritory];
        List<ServiceTerritory> listTerr = XC_DF_ServiceTerritory.createServiceTerritories(accList);
        listTerr[0].ParentTerritoryId = servTerrList[0].Id;
        listTerr[0].Name ='Child';
        insert listTerr[0];
        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeSkill = new  XC_ZipCodeSkill_TerritoryAssociation__c(XC_Province__c = 'Madrid',
                                                                                                             XC_ServiceTerritoryId__c = servTerrList[0].Id,
                                                                                                             XC_ListOfSkillNames__c = 'Commercial Visit;Planned Maintenance',
                                                                                                             XC_ZipCode__c = '28080' );
        insert zipCodeSkill;
        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeSkill2 = new  XC_ZipCodeSkill_TerritoryAssociation__c(XC_Province__c = 'Madrid',
                                                                                                             XC_ServiceTerritoryId__c = listTerr[0].Id,
                                                                                                             XC_ListOfSkillNames__c = 'Commercial Visit;Planned Maintenance',
                                                                                                             XC_ZipCode__c = '28080' );
        insert zipCodeSkill2;
        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeTerritoryAss = [SELECT Id, XC_Province__c, XC_ServiceTerritoryId__c,XC_ListOfSkills__c, XC_ListOfSkillNames__c, XC_ZipCode__c FROM XC_ZipCodeSkill_TerritoryAssociation__c WHERE XC_ServiceTerritoryId__c =: servTerrList[0].Id ];
        Skill repairSkill = [SELECT Id, MasterLabel,DeveloperName FROM Skill WHERE MasterLabel = 'Repair'];
        Map<String, Object> mapToTest = new Map<String,Object>();
        mapToTest.put('recordId',zipCodeTerritoryAss.Id);
        mapToTest.put('zipCode',zipCodeTerritoryAss.XC_ZipCode__c);
        mapToTest.put('province', zipCodeTerritoryAss.XC_Province__c);
        mapToTest.put('skillList', repairSkill.Id);
        Test.startTest();
        XC_UTIL_ResultWrapper rw = XC_LCC092_EditZipCodeSkillTerritory.updateSkillTerritory(JSON.serialize(mapToTest));
        System.assertEquals(rw.success , true);
        Test.stopTest();
     }  
    
    static testMethod void getSkillForTerritoryInEditTest(){
        XC_DF_Account.insertPartnerAccounts(1);
        List<Account> accList = [SELECT Id, Name FROM Account];
        insert XC_DF_ServiceTerritory.createServiceTerritories(accList);
        List<ServiceTerritory> servTerrList = [SELECT Id FROM ServiceTerritory];
        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeSkill = new  XC_ZipCodeSkill_TerritoryAssociation__c(XC_Province__c = 'Madrid',
                                                                                                             XC_ServiceTerritoryId__c = servTerrList[0].Id,
                                                                                                             XC_ListOfSkillNames__c = 'Commercial Visit;Planned Maintenance',
                                                                                                             XC_ZipCode__c = '28080' );
        insert zipCodeSkill;
        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeTerritoryAss = [SELECT Id, XC_Province__c, XC_ServiceTerritoryId__c,XC_ListOfSkills__c, XC_ListOfSkillNames__c, XC_ZipCode__c FROM XC_ZipCodeSkill_TerritoryAssociation__c];
       	List<ServiceResource> servResList = XC_DF_Serviceresource.createServiceResourcesFromAccount(accList, true);
        insert XC_DF_Serviceresource.createServiceResourcesSkill(servResList[0]);
        OperatingHours opH = [SELECT Id, Name FROM OperatingHours WHERE Name = 'Gold Appointment Calendar'];
        ServiceTerritoryMember srtmemb = new ServiceTerritoryMember();
        srtmemb.ServiceTerritoryId = servTerrList[0].Id;
        srtmemb.ServiceResourceId = servResList[0].Id;
        srtmemb.EffectiveStartDate = DateTime.now();
        srtmemb.OperatingHoursId = opH.Id;
        insert srtmemb;
        Test.startTest();
        List<String> skills = XC_LCC092_EditZipCodeSkillTerritory.getSkillForTerritoryInEdit(zipCodeTerritoryAss.Id);
        System.assertEquals(skills.size() , 0);
        Test.stopTest();
     }  
    
    static testMethod void getInformationFromRootTest(){
        XC_DF_Account.insertPartnerAccounts(1);
        List<Account> accList = [SELECT Id, Name FROM Account];
        insert XC_DF_ServiceTerritory.createServiceTerritories(accList);
        List<ServiceTerritory> servTerrList = [SELECT Id FROM ServiceTerritory];
        List<ServiceTerritory> servTerrChildren = XC_DF_ServiceTerritory.createServiceTerritories(accList);
        servTerrChildren[0].ParentTerritoryId = servTerrList[0].Id;
        servTerrChildren[0].Name = 'Test Children';
        insert servTerrChildren[0];
        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeSkillParent = new  XC_ZipCodeSkill_TerritoryAssociation__c(XC_Province__c = 'Madrid',
                                                                                                             XC_ServiceTerritoryId__c = servTerrList[0].Id,
                                                                                                             XC_ListOfSkillNames__c = 'Commercial Visit;Planned Maintenance',
                                                                                                             XC_ZipCode__c = '28080' );
        insert zipCodeSkillParent;
        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeSkill = new  XC_ZipCodeSkill_TerritoryAssociation__c(XC_Province__c = 'Madrid',
                                                                                                             XC_ServiceTerritoryId__c = servTerrChildren[0].Id,
                                                                                                             XC_ListOfSkillNames__c = 'Commercial Visit;Planned Maintenance',
                                                                                                             XC_ZipCode__c = '28080' );
        insert zipCodeSkill;
        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeTerritoryAss = [SELECT Id, XC_Province__c, XC_ServiceTerritoryId__c,XC_ListOfSkills__c, XC_ListOfSkillNames__c, XC_ZipCode__c FROM XC_ZipCodeSkill_TerritoryAssociation__c WHERE XC_ServiceTerritoryId__c =: servTerrChildren[0].Id ];
       	List<ServiceResource> servResList = XC_DF_Serviceresource.createServiceResourcesFromAccount(accList, true);
        insert XC_DF_Serviceresource.createServiceResourcesSkill(servResList[0]);
        OperatingHours opH = [SELECT Id, Name FROM OperatingHours WHERE Name = 'Gold Appointment Calendar' LIMIT 1];
        ServiceTerritoryMember srtmemb = new ServiceTerritoryMember();
        srtmemb.ServiceTerritoryId = servTerrChildren[0].Id;
        srtmemb.ServiceResourceId = servResList[0].Id;
        srtmemb.EffectiveStartDate = DateTime.now();
        srtmemb.OperatingHoursId = opH.Id;
        insert srtmemb;
        String province = 'Madrid';
        String zipCode = '28080';
        Test.startTest();
        List<String> provinces = XC_LCC092_EditZipCodeSkillTerritory.getRootProvinceInEdit(zipCodeTerritoryAss.Id);
        List<String> zipCodes = XC_LCC092_EditZipCodeSkillTerritory.getZipCodeFromRootInEdit(zipCodeTerritoryAss.Id,province);
        List<String> skills = XC_LCC092_EditZipCodeSkillTerritory.getSkillForTerritoryFromRootInEdit(zipCodeTerritoryAss.Id,province, zipCode);
        System.assertEquals(provinces.size() , 1);
        Test.stopTest();
     }  

}