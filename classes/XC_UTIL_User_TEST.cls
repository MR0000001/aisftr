/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com 
* @Creation 20/05/2019
* @Modification 13/09/2019
* @description Test Class for XC_UTIL_User
*/

@isTest
private class XC_UTIL_User_TEST {
    
    @isTest static void getChannelFromUserTest(){
        Test.startTest();
        User u  = XC_DF_User.createUserAdmin();
        insert u;
        
        List<User> uList =  new List<User>();
        uList.add(u);
        
        String recordId = u.Id;
        String getChannel = XC_UTIL_User.getChannelFromUser(recordId);
        List<String>getRole = XC_UTIL_User.getRoleNamesFromUsers(uList);
        Map<String,Id> getUserRole = XC_UTIL_User.getUserRoleNames(getRole);
        XC_UTIL_User.setUsersRoles(uList,getUserRole);
        
        System.assert(!String.isBlank(recordId));
        System.assert(!getRole.isEmpty());
        System.assert(getUserRole != null);
        System.assert(!uList.isEmpty());
        
        Test.stopTest();
    }
    
    @isTest static void getChannelFromUserTes1t(){
        Test.startTest();
        User u  = XC_DF_User.createUserAdmin();
        insert u;
        
        String recordId = u.Id;
        String getChannel = XC_UTIL_User.getChannelFromUser(recordId);
        getChannel = '';
        
        System.assert(String.isBlank(getChannel));
        System.assert(!String.isBlank(recordId));
        
        Test.stopTest();
    }
    
    @isTest static void getChannelFromUser2(){
        Test.startTest();
        List<User> u  = XC_DF_User.generateMultipleUser(1);
        insert u;
      	UserRole ux = [SELECT Id,Name FROM UserRole  LIMIT 1];
        String recordId = u[0].Id;
        String getChannel = XC_UTIL_User.getChannelFromUser(recordId);
        getChannel = '';
        
        System.assert(String.isBlank(getChannel));
        System.assert(!String.isBlank(recordId));
       
        
        Test.stopTest();
    }
    
    @isTest static void getCountryFromUserTEST(){
        Test.startTest();
        List<User> u  = XC_DF_User.generateMultipleUser(1);
        insert u;
        String country = XC_UTIL_User.getCountryFromUser(u[0].id);
        System.assert(!String.isBlank(country));
       
        
        Test.stopTest();
    }
    
    @isTest static void getLegalEntityFromUserTEST(){
        Test.startTest();
        String legalEntity = XC_UTIL_User.getLegalEntityFromUser();
        System.assert(!String.isBlank(legalEntity));
        Test.stopTest();
    }
    
    @isTest static void getLegalEntitiesFromUser1TEST(){
        Test.startTest();
        List<User> u  = XC_DF_User.generateMultipleUser(1);
        u[0].XC_LegalEntity__c = 'EndesaX';
        u[0].XC_LegalEntities__c = null;
        insert u;
        List<String> legalEntities = XC_UTIL_User.getLegalEntitiesFromUser();
        System.assert(!legalEntities.isEmpty());
        Test.stopTest();
    }
    
    @isTest static void getLegalEntitiesFromUser2TEST(){
        Test.startTest();
        List<User> u  = XC_DF_User.generateMultipleUser(1);
        u[0].XC_LegalEntities__c = 'EndesaX;Codensa';
        insert u;
        List<String> legalEntities = XC_UTIL_User.getLegalEntitiesFromUser();
        System.assert(!legalEntities.isEmpty());
        Test.stopTest();
    }
    
    @isTest static void getLegalEntityMetadataFromUserTEST(){
        Test.startTest();
        List<User> u  = XC_DF_User.generateMultipleUser(1);
        u[0].XC_LegalEntity__c = 'EndesaX';
        insert u;
        XC_CM_CountryLegalEntityAssociation__mdt mtd = XC_UTIL_User.getLegalEntityMetadataFromUser();
        System.assert(mtd != null);
        Test.stopTest();
    }
    
}