/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @date Creation 15/05/2019
* @date Modification 24/07/2019 monica.cutillo@nttdata.com
* @description XC_LCC005_AccountCallToCommodity_TEST 
*/  
@isTest
public class XC_LCC005_AccountCallToCommodity_TEST {
	
    static testMethod void callRetrieveIdentityNumber(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        account[0].IdentityNumber__c = '41550260R';
        account[0].IdentityType__c = 'NIF';
        insert account;
        
        List<Lead> lead = XC_DF_Lead.createResidentialLeads(1);
        lead[0].XC_DocumentNumber__c = '41550260R';
        lead[0].XC_DocumentType__c = 'NIF';
        lead[0].Country__c = 'SPAIN';
        lead[0].XC_DocumentCountry__c = 'Spain';
        insert lead;
        
        Test.startTest();
           	XC_LCC005_AccountCallToCommodity.IdentifyDataWrapper doc1 = XC_LCC005_AccountCallToCommodity.retrieveIdentityData(String.valueOf(account[0].id), 'Account');
           	XC_LCC005_AccountCallToCommodity.IdentifyDataWrapper doc2 = XC_LCC005_AccountCallToCommodity.retrieveIdentityData(String.valueOf(lead[0].id), 'Lead');
            System.assert(doc1!=null && doc2!=null);
        Test.stopTest();
    }
	
    static testMethod void callManageAccountCommodityResponse(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        account[0].IdentityNumber__c = '41550260R';
        account[0].IdentityType__c = 'NIF';
        insert account;
        Test.startTest();
           	HttpResponse responseFake = new HttpResponse();
        	responseFake.setBody(XC_LCC005_AccountCallToCommodity_TEST.getFakeCommodityResponse());
        	responseFake.setStatusCode(200);
            XC_LCC005_AccountCallToCommodity.MainResultWrapper mainRW = XC_LCC005_AccountCallToCommodity.manageAccountCommodityResponse(responseFake, account[0].id, 'Account');
            System.assert(mainRW.success);
        Test.stopTest();
    }
	
    static testMethod void callImportAddressFromCommodityFromAccount(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        account[0].IdentityNumber__c = '41550260R';
        account[0].IdentityType__c = 'NIF';
        insert account;
        
        Map<String,String> inputData = new Map<String,String> { 'recordId' => account[0].id, 'sobjecttype' => 'Account'};
        Map<String,Object> dataMap;
        List<Map<String,Object>> addressValues = new List<Map<String,Object>>();
        addressValues.add(new Map<String,Object> {'fieldKey'=>'Country','fieldLabel'=>'Country','fieldValue'=>'ESPAÑA'});
        addressValues.add(new Map<String,Object> {'fieldKey'=>'Address','fieldLabel'=>'Address','fieldValue'=>'SANT PAU'});
        addressValues.add(new Map<String,Object> {'fieldKey'=>'StreetNumber','fieldLabel'=>'Street Number','fieldValue'=>'70'});
        addressValues.add(new Map<String,Object> {'fieldKey'=>'Floor','fieldLabel'=>'Floor','fieldValue'=>'3º'});
        List<List<Map<String,Object>>> posValues = new List<List<Map<String,Object>>>();
        
        Test.startTest();
           	HttpResponse responseFake = new HttpResponse();
        	responseFake.setBody(XC_LCC005_AccountCallToCommodity_TEST.getFakeCommodityResponse());
        	responseFake.setStatusCode(200);
            XC_LCC005_AccountCallToCommodity.ResultWrapper rw = XC_LCC005_AccountCallToCommodity.importAddressFromCommodity(inputData, addressValues, posValues);
            System.assert(rw.success);
        Test.stopTest();
    }
	
    static testMethod void callImportAddressFromCommodityFromLead(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Lead> lead = XC_DF_Lead.createResidentialLeads(1);
        lead[0].XC_DocumentNumber__c = '41550260R';
        lead[0].XC_DocumentType__c = 'NIF';
        lead[0].Country__c = 'SPAIN';
        lead[0].XC_DocumentCountry__c = 'Spain';
        insert lead;
        
        Map<String,String> inputData = new Map<String,String> { 'recordId' => lead[0].id, 'sobjecttype' => 'Lead'};
        Map<String,Object> dataMap;
        List<Map<String,Object>> addressValues = new List<Map<String,Object>>();
        addressValues.add(new Map<String,Object> {'fieldKey'=>'Country','fieldLabel'=>'Country','fieldValue'=>'ESPAÑA'});
        addressValues.add(new Map<String,Object> {'fieldKey'=>'Address','fieldLabel'=>'Address','fieldValue'=>'SANT PAU'});
        addressValues.add(new Map<String,Object> {'fieldKey'=>'StreetNumber','fieldLabel'=>'Street Number','fieldValue'=>'70'});
        addressValues.add(new Map<String,Object> {'fieldKey'=>'Floor','fieldLabel'=>'Floor','fieldValue'=>'3º'});
        List<List<Map<String,Object>>> posValues = new List<List<Map<String,Object>>>();
        
        Test.startTest();
           	HttpResponse responseFake = new HttpResponse();
        	responseFake.setBody(XC_LCC005_AccountCallToCommodity_TEST.getFakeCommodityResponse());
        	responseFake.setStatusCode(200);
            XC_LCC005_AccountCallToCommodity.ResultWrapper rw = XC_LCC005_AccountCallToCommodity.importAddressFromCommodity(inputData, addressValues, posValues);
            System.assert(rw.success);
        Test.stopTest();
    }

 	/**
    * @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
    * @description  Method to test callCommodityNew method
    */
    /*static testMethod void callCommodityNewTestFake(){
    
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
            List<Account> bo = XC_DF_Account.createResidentialAccounts(1);
            List<Lead> leads = XC_DF_Lead.createCondominiumLeads(1);
            insert bo;
            insert leads;
            //XC_LCC005_AccountCallToCommodity.MainResultWrapper rw = XC_LCC005_AccountCallToCommodity.callCommodityNew(bo[0].id, 'Account');
            //rw = XC_LCC005_AccountCallToCommodity.callCommodityNew(bo[0].id, '');
            //rw = XC_LCC005_AccountCallToCommodity.callCommodityNew(leads[0].id, 'Lead');
            //System.assert(rw != null);
        Test.stopTest();
    }*/
    
    /**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description  Method to test callCommodityNew method
*/
   /* static testMethod void callCommodityNewTestReal(){

    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
            XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
            ic.XC_activeInterface__c = true;
            ic.Name = Label.XC_CL_Lead_CallToCommodityURL;
            ic.XC_interfaceName__c =Label.XC_CL_Lead_CallToCommodityURL; 
            insert ic;
        List<Account> bo = XC_DF_Account.createResidentialAccounts(1);
        insert bo;
        XC_LCC005_AccountCallToCommodity.ResultWrapper rw = XC_LCC005_AccountCallToCommodity.callCommodity(bo[0].id);
        System.assert(rw.success);
    Test.stopTest();
    
   
    }*/

    static testMethod void updateAccount(){
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        Account account = new Account();
        account = accountList.get(0);
        insert account;
        Test.startTest();
            XC_LCC005_AccountCallToCommodity.updateAccount('pino abete', 'First Name', account.id);
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
            XC_LCC005_AccountCallToCommodity.saveNameSurname('[{"Name":"start"}]',  account.id);
        Test.stopTest();

    }
    static testMethod void savePrimaryPhone(){
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        Account account = new Account();
        account = accountList.get(0);
        insert account;
        Test.startTest();
            XC_LCC005_AccountCallToCommodity.savePrimaryPhone('[{"MainPhonePrefix":"987463546", "MainPhone":"987353425"}]',  account.id);
        Test.stopTest();

    }

    static testMethod void saveSecondaryPhone(){
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        Account account = new Account();
        account = accountList.get(0);
        insert account;
        Test.startTest();
            XC_LCC005_AccountCallToCommodity.saveSecondaryPhone('[{"MainPhonePrefix":"987463546", "MainPhone":"987353425"}]',  account.id);
        Test.stopTest();

    }



    static testMethod void saveEmail(){
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        Account account = new Account();
        account = accountList.get(0);
        insert account;
        Test.startTest();
            XC_LCC005_AccountCallToCommodity.saveEmail('pinco@pallino.it',  account.id);
        Test.stopTest();

    }
    /**
     * @description Gets the commodity fake response.
     * @return the commodity fakeresponse
     */
    @TestVisible
    private static String getFakeCommodityResponse(){
        String account = XC_REST_ReadAccont.getCommodityFakeAccountResponse();
        account = account.removeStart('{');
        account = account.removeEnd('}');
        String fakeResult = '{'+
                            '"Result": {'+
                            '   "Message": "test"'+
                            '  }, '+
                            account+
                            ' }';
        return fakeResult;
    }
}