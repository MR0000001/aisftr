/**
 * @author            : Andrea Di Cicco
 * @date Creation     : 16/03/2020
 * @description       : Test Class for XC_TR_CustomerInteraction_setCC
 **/
@isTest
public class XC_TR_CustomerInteraction_setCC_TEST {
	
    static testMethod void setCCRecipient(){
        
        List<Account> accountList = XC_DF_Account.createSohoAccounts(1);
        accountList.get(0).XC_SohoType__c ='B2B';
		insert accountList;
        
        List<Contact> contactList = XC_DF_Contact.createSohoContacts(accountList);
        insert contactList;
        
        List<XC_Customer_Interaction__c> custInterList = XC_DF_CustomerInteraction.createCustomerInteraction(1);
        custInterList.get(0).XC_Communication_Type__c ='Internal_Notice_Of_Expiration';
        custInterList.get(0).XC_AccountId__c = accountList.get(0).id;
        custInterList.get(0).XC_ContactId__c = contactList.get(0).id;
        insert custInterList;
        
        Test.startTest();
        	XC_TR_CustomerInteraction_setCC.setCCRecipient(custInterList);
        Test.stopTest();
    }
    
}