@isTest
public with sharing class XC_TR_ManageLicenseToAssign_Test {
     
     @isTest static void checkPermissionNeededTest(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            insert new XC_UserPermission__c(Name = 'Glovia',XC_LicenseRequired__c=true,XC_NamespacePrefix__c='gii');
            
            Test.startTest();
            User u = XC_DF_User.createUserAdmin();
            insert u;
            u.XC_isGloviaUser__c = true;
            update u;
            System.assert(u!=null);
            System.runas(u)
            {
                PermissionSet ps = new PermissionSet(Label = 'mockPs', Name = 'mockPs');
                insert ps;
            }
                
            Test.stopTest();
     }
     
      @isTest static void checkPermissionNeededTest1(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            insert new XC_UserPermission__c(Name = 'Glovia',XC_LicenseRequired__c=true,XC_NamespacePrefix__c='gii');
            Test.startTest();
            User u = XC_DF_User.createUserAdmin();
            u.XC_isGloviaUser__c = true;
            List<User> userList = new List<user>();
            userList.add(u);
            insert userList;
             XC_TR_ManageLicenseToAssign.checkPermissionNeeded(userList); // the method which you want to call 
            System.assert(u!=null);
            Test.stopTest();
     }
      
     @isTest static void checkIfAddOrRemoveGloviaLicenseTest(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            insert new XC_UserPermission__c(Name = 'Glovia',XC_LicenseRequired__c=true,XC_NamespacePrefix__c='gii');
            
            Test.startTest();
            User u = XC_DF_User.createUserAdmin();
            u.XC_isGloviaUser__c = true;
            insert u; 
            u.XC_isGloviaUser__c = false;
            update u;
            Test.stopTest();
     }

       @isTest static void checkPermissionNeededTestCloudCoach(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            insert new XC_UserPermission__c(Name = 'CloudCoach',XC_LicenseRequired__c=true,XC_NamespacePrefix__c='project_cloud');
            
            Test.startTest();
            User u = XC_DF_User.createUserAdmin();
            insert u; 
            u.XC_IsCloudCoachUser__c= true;
            update u;
            System.assert(u!=null);
            Test.stopTest();
     }
    
    
     @isTest static void checkIfAddOrRemoveCloudCoachLicenseTest(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            insert new XC_UserPermission__c(Name = 'CloudCoach',XC_LicenseRequired__c=true,XC_NamespacePrefix__c='project_cloud');
            
            Test.startTest();
            User u = XC_DF_User.createUserAdmin();
            u.XC_IsCloudCoachUser__c= true;
            insert u; 
            u.XC_IsCloudCoachUser__c= false;
            update u;
            Test.stopTest();
     }

}