/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @date Creation 15/05/2019
* @date Modification 24/07/2019 monica.cutillo@nttdata.com
* @description XC_LCC005_AccountCallToCommodity_TEST 
*/  
@isTest
public class XC_LCC005_AccountCallToCommodity_U_TEST {

    static testMethod void importAddressFromCommodity(){

        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        account[0].IdentityNumber__c = '41550260R';
        account[0].IdentityType__c = 'NIF';
        insert account;
        
        Map<String,Object> inputDataToSave = new Map<String,Object>();
        inputDataToSave.put('recordId', account[0].id);
        inputDataToSave.put('sobjecttype', 'Account');

        Map<String,Object> address = new Map<String,Object>();
        address.put('fieldKey', 'Country');
        address.put('fieldValue', 'España');
        address.put('fieldLabel', 'Country');
        List<Map<String,Object>> addressList = new List<Map<String,Object>>();

        addressList.add(address);

        Map<String, Object> pod = new Map<String, Object>();
        pod.put( 'POSType', 'GAS');
        pod.put('POS', '1234567890');
        pod.put('Country', 'Spain');
        List<Lead> lead = XC_DF_Lead.createResidentialLeads(1);
        insert lead;
       
        List<Map<String, Object>> cupList = new List<Map<String, Object>>();
        cupList.add(pod);
        List<List<Map<String, Object>>>cupListList = new List<List<Map<String, Object>>>();
        Test.startTest();
        XC_LCC005_AccountCallToCommodity_U.importAddressFromCommodity(inputDataToSave,addressList, cupListList );
        inputDataToSave.put('sobjecttype', 'Lead');
       
        inputDataToSave.put('recordId', lead.get(0).id);
        XC_LCC005_AccountCallToCommodity_U.importAddressFromCommodity(inputDataToSave,addressList, cupListList );

        Test.stopTest();
    }

    static testMethod void inputDataMappingContact(){

        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        account[0].IdentityNumber__c = '41550260R';
        account[0].IdentityType__c = 'NIF';
        insert account;
        
        List<Contact> contactPr = XC_DF_Contact.createResidentialContacts(account);
        contactPr[0].XC_PrimaryContact__c = true;
        insert contactPr;
        
        Map<String,Object> inputDataToSave = new Map<String,Object>();
        inputDataToSave.put('recordId', account[0].id);
        inputDataToSave.put('sobjecttype', 'Account');
        Map<String,Object> contact = new Map<String,Object>();
        List<Map<String,Object>> contactValues = new List<Map<String,Object>>();
        contactValues.add(contact);


        Test.startTest();
        XC_LCC005_AccountCallToCommodity_U.importContactFromCommodity(inputDataToSave,contactValues);
        Test.stopTest();
    }

    static testMethod void savePrimaryPhone(){
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        Account account = new Account();
        account = accountList.get(0);
        insert account;
        Test.startTest();
            XC_LCC005_AccountCallToCommodity_U.savePrimaryPhone('[{"MainPhonePrefix":"987463546", "MainPhone":"987353425"}]',  account.id);
        Test.stopTest();

    }
    
    static testMethod void saveSecondaryPhone(){
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        Account account = new Account();
        account = accountList.get(0);
        insert account;
        Test.startTest();
            XC_LCC005_AccountCallToCommodity_U.saveSecondaryPhone('[{"MainPhonePrefix":"987463546", "MainPhone":"987353425"}]',  account.id);
        Test.stopTest();

    }

    static testMethod void saveNameSurname(){
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        Account account = new Account();
        account = accountList.get(0);
        insert account;
        List<Contact> contactList =  XC_DF_Contact.createResidentialContacts(accountList);
        Contact c = contactList.get(0);
        c.XC_PrimaryContact__c = true;
        insert c;
        Test.startTest();
            XC_LCC005_AccountCallToCommodity_U.saveNameSurname('[{"Name":"start"}]',  account.id);
        Test.stopTest();

    }

    static testMethod void updateAccount(){
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        Account account = new Account();
        account = accountList.get(0);
        insert account;
        Test.startTest();
            XC_LCC005_AccountCallToCommodity_U.updateAccount('pino abete', 'First Name', account.id);
        Test.stopTest();

    }
}