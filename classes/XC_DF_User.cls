/**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 06/05/2019
* @description XC_DF_User – Data Factory for User
*/
@isTest
public class XC_DF_User {

   /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com && Federica Tavera - federica.tavera@nttdata.com
     * @description Method to create User
     * @return  User to insert
    */
    public static User createUserAdmin() {
        User user = new User(); 
        user.Username = 'pablo123@gmail.com';  
        user.FirstName ='TestUser';
        user.LastName ='testUserProva';
        user.Email = 'pablo@test.com';
        user.Alias = 'TestTry'; 
        user.ProfileId = [SELECT Id, UserLicenseId FROM Profile WHERE Name = 'System Administrator' LIMIT 1][0].Id;
        user.LocaleSidKey = 'it_IT';
        user.TimeZoneSidKey = 'GMT';
        user.LanguageLocaleKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1'; 
        user.IsActive = true;
        user.Country__c = 'SPAIN';
        user.CompanyP__c = 'SPAIN';
        return user;
    }
    /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com 
     * @description Method to create N User
     * @param n Integer
     * @return List<User> to insert
    */
    public static List<User> generateMultipleUser(Integer n){
        List<User> users = new List<User>();
        for(Integer i=0; i<n; i++){
            User user = createUserAdmin();
            user.Alias += i;
            user.Lastname += i;
            user.Username = i + 'pablo@gmail.com';
            user.Email = i + 'pablo@gmail.com';
            users.add(user);
        }
        return users;
    }


    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 21/03/2019
    * @param contact - contact
    * @return User to insert
    * @description createCommunityUser() – Get Community User
    */
    public static User createCommunityUser(Contact contact) {
        List<Contact> contactList = new List<Contact>{contact};
        return createCommunityUsers(contactList)[0];
    }
    
    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com / Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 06/05/2019
    * @param contactList - list of contacts
    * @return userList - users to insert
    * @description createCommunityUsers() – Get Community Users
    */
    public static List<User> createCommunityUsers(List<Contact> contactList){
        
        return createCommunityUsers(contactList, false);
    }
    
    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com / Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 06/05/2019
    * @param contactList - list of contacts
    * @param automaticDeactivation - Boolean
    * @return List<User>
    * @description createCommunityUsers() – Get Community Users
    */
    public static List<User> createCommunityUsers(List<Contact> contactList, Boolean automaticDeactivation){
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'XC_ESP_SalesAgentPartner' LIMIT 1]; 
        List<User> userList = new List<User>();
        Integer i = 0;
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'Partner' LIMIT 1];
        for(Contact cont : contactList){
            User user = new User();
            user.Username = cont.FirstName.deleteWhitespace()+'_number_' + i +'@test.com';  
            user.FirstName = cont.FirstName;
            user.LastName = cont.LastName;
            user.ContactId = cont.Id;
            user.Email = cont.Email; 
            user.CommunityNickname = (cont.FirstName + '_number_' + i).length()>35 ? (cont.FirstName + '_number_' + i).subString(0,36) : (cont.FirstName + '_number_' + i);//
            user.Alias = cont.FirstName.substring(0,4); 
            user.ProfileId = profile.Id;
            user.LocaleSidKey = 'it_IT';
            user.TimeZoneSidKey = 'GMT';
            user.LanguageLocaleKey = 'en_US';
            user.EmailEncodingKey = 'ISO-8859-1'; 
            user.IsActive = true; 
            //user.UserRoleId = userRole.Id;
            user.Country__c = 'SPAIN';
            user.XC_AutomaticDeactivation__c = automaticDeactivation;
            userList.add(user);            
            i++;
        }
        return userList;
    }
    
    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com / Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 06/05/2019
    * @param contactList - list of contacts
    * @param automaticDeactivation - Boolean
    * @return List<User>
    * @description createCommunityUsers() – Get Community Users
    */
    public static List<User> createCommunityUserFSL(List<Contact> contactList, Boolean automaticDeactivation){
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'XC_ESP_SalesAgentPartner' LIMIT 1]; 
        List<User> userList = new List<User>();
        Integer i = 0;
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'Partner' LIMIT 1];
        for(Contact cont : contactList){
            User user = new User();
  	        user.Username = cont.FirstName.deleteWhitespace()+'_number_' + i +'@test.com';  
            user.FirstName = cont.FirstName;
            user.LastName = cont.LastName;
            user.ContactId = cont.Id;
            user.Email = cont.Email; 
            user.CommunityNickname = cont.FirstName + '_number_' + i;
            user.Alias = cont.FirstName.substring(0,4); 
            user.ProfileId = profile.Id;
            user.LocaleSidKey = 'it_IT';
            user.TimeZoneSidKey = 'GMT';
            user.LanguageLocaleKey = 'en_US';
            user.EmailEncodingKey = 'ISO-8859-1'; 
            user.IsActive = true; 
            //user.UserRoleId = userRole.Id;
            user.Country__c = 'SPAIN';
            user.XC_AutomaticDeactivation__c = automaticDeactivation;
            userList.add(user);            
            i++;
        }
        insert userList;
        
        List<PermissionSet> listPS = [SELECT Id FROM PermissionSet WHERE Name IN ('FSL_Resource_Permissions', 'FSL_Resource_License', 'FSL_Community_Self_Service_Permissions')];
        
        List<PermissionSetAssignment> listPSA = new List<PermissionSetAssignment>();
        PermissionSetAssignment psa;
        for(User u : userList) {
            for(PermissionSet ps : listPS) {
                psa = new PermissionSetAssignment();
                psa.PermissionSetId = ps.Id;
                psa.AssigneeId = u.Id;
            	listPSA.add(psa);
            }
        }
        insert listPSA;
        
        return userList;
    }

    public static List<User> createAutomotiveCommunityUsers(List<Contact> contactList, Boolean automaticDeactivation){
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'XC_ITA_AutomotiveAgent' LIMIT 1]; 
        List<User> userList = new List<User>();
        Integer i = 0;
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'Partner' LIMIT 1];
        for(Contact cont : contactList){
            User user = new User();
            user.Username = cont.FirstName.deleteWhitespace()+'_number_' + i +'@test.com';  
            user.FirstName = cont.FirstName;
            user.LastName = cont.LastName;
            user.ContactId = cont.Id;
            user.Email = cont.Email; 
            user.CommunityNickname = (cont.FirstName + '_number_' + i);//.subString(0,36)
            user.Alias = cont.FirstName.substring(0,4); 
            user.ProfileId = profile.Id;
            user.LocaleSidKey = 'it_IT';
            user.TimeZoneSidKey = 'GMT';
            user.LanguageLocaleKey = 'en_US';
            user.EmailEncodingKey = 'ISO-8859-1'; 
            user.IsActive = true; 
            //user.UserRoleId = userRole.Id;
            user.Country__c = 'ITALY';
            user.XC_AutomaticDeactivation__c = automaticDeactivation;
            userList.add(user);            
            i++;
        }
        return userList;
    }

}