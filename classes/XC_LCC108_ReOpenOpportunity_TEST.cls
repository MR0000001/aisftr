/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  14/05/2019 
* @description XC_LCC108_ReOpenOpportunity_TEST – Test class for XC_LCC108_ReOpenOpportunity
*/ 
@isTest
public class XC_LCC108_ReOpenOpportunity_TEST {
    //Test method getContactListFromAccount
    static testMethod void reOpenOpportunity(){
    	insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<Opportunity> listOpportunity = XC_DF_Opportunity.createOpportunity(1, true);
        insert listOpportunity;
        String oppId = listOpportunity[0].Id; 
        User u = XC_DF_User.createUserAdmin();
        insert u; 
        XC_UTIL_ResultWrapper rw = XC_LCC108_ReOpenOpportunity.reOpenOpportunity(oppId);
        System.assertEquals(false, rw.success);
        Test.stopTest();
    }
      
        //Test method getContactListFromAccount2
    static testMethod void reOpenOpportunity2(){
    	//insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
            
        List<Opportunity> listOpportunity = XC_DF_Opportunity.createOpportunity(1, true);
        listOpportunity[0].XC_LossReason__c = 'Busy';
        insert listOpportunity;
        String oppId = listOpportunity[0].Id;
        listOpportunity[0].StageName= Label.XC_CL_Opportunity_ClosedLost;
        update listOpportunity;
        User u = XC_DF_User.createUserAdmin();  
        insert u;  
        XC_UTIL_ResultWrapper rw = XC_LCC108_ReOpenOpportunity.reOpenOpportunity(oppId);
        System.assertEquals(true , rw.success);
        Test.stopTest(); 
    }

        //Test method getContactListFromAccount3
    static testMethod void reOpenOpportunity3(){
    	insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Test.startTest(); 
        User u = XC_DF_User.createUserAdmin();  
        insert u;
        List<Opportunity> listOpportunity = XC_DF_Opportunity.createOpportunity(1, true);
        listOpportunity[0].XC_ClosingUser__c = u.Id;
        insert listOpportunity;
        
        String oppId = listOpportunity[0].Id;   
        List<Account> listAccP = XC_DF_Account.insertPartnerAccounts(1);
        List<Contact> listContactP = XC_DF_Contact.createPartnerContacts(listAccP);
        insert listContactP;
        /*String roleName = listContactP[0].Account.Name + ' ' + 'Partner Manager';
        UserRole userRole = [SELECT Id FROM UserRole WHERE Name =: roleName LIMIT 1][0];
        Profile salesAgentPartnerProfile = [SELECT Id, Name FROM Profile WHERE Name = 'XC_ESP_SalesAgentPartner'][0];
		String firstName;
        String lastName;
        if(String.isNotBlank(listContactP[0].FirstName)) {
            firstName = listContactP[0].FirstName.deleteWhitespace();
            firstName = firstName.toLowerCase();
        }
        if(String.isNotBlank(listContactP[0].LastName)) {
            lastName = listContactP[0].LastName.deleteWhitespace();
            lastName = lastName.toLowerCase();
        }
                
        String username = firstname + '.' + lastName + '@enelxpartner.com';
              
       
        String nameOfContact = listContactP[0].Name;*/

        /*u.UserName = firstName + '.' + lastName + '@enelxpartner1.com';
        u.FirstName = listContactP[0].FirstName;
        u.LastName = listContactP[0].LastName;
        u.ContactId = listContactP[0].Id;
        u.XC_AccountId__c = listContactP[0].Account.Id;
        u.Email = listContactP[0].Email;
        u.CommunityNickname = listContactP[0].FirstName;
        u.Alias = listContactP[0].FirstName.substring(0,4); 
        u.ProfileId = salesAgentPartnerProfile.Id;
        u.LocaleSidKey = UserInfo.getLocale();
        u.TimeZoneSidKey = String.valueof(UserInfo.getTimeZone());
        u.LanguageLocaleKey = UserInfo.getLanguage();
        u.EmailEncodingKey = 'ISO-8859-1';
        u.Country__c = 'SPAIN';
        u.UserRole = userRole;
        u.IsActive = true;
        u.CompanyP__c = 'SPAIN';
        u.XC_X_Customer_User__c = true;*/

		//listOpportunity[0].XC_ClosingUser__r.XC_AccountId__c = listContactP[0].Account.Id;
        XC_UTIL_ResultWrapper rw = XC_LCC108_ReOpenOpportunity.reOpenOpportunity(oppId);
        
        //System.assertEquals(true , rw.success);
        Test.stopTest(); 
    }
 static testMethod void reOpenOpportunity4(){
    	//insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<Opportunity> listOpportunity = XC_DF_Opportunity.createOpportunity(1, true);
        insert listOpportunity;
        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'InOrder';
        order.NE__OptyId__c = listOpportunity[0].Id;
       // order.XC_Subtype__c = 'End of supply';
        order.NE__AccountId__c =listOpportunity[0].AccountId;
        order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByName().get('Order').getRecordTypeId();
        insert order;        
        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
        insert item;
        update order;
        String oppId = listOpportunity[0].Id;
        listOpportunity[0].StageName= Label.XC_CL_Opportunity_ClosedLost; 
     	listOpportunity[0].XC_LossReason__c = 'Busy';
        update listOpportunity;
        User u = XC_DF_User.createUserAdmin();  
        insert u;  
        XC_UTIL_ResultWrapper rw = XC_LCC108_ReOpenOpportunity.reOpenOpportunity(oppId);
        System.assertEquals(false , rw.success);
        Test.stopTest(); 
    }
}