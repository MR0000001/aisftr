@isTest
public class XC_TR_Asset_U_CareManagement_TEST {

    @TestSetup
    static void makeData() {
      	OneOrg__c org            = new OneOrg__c(); 
	    org.Name                 = 'OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
	    insert org;
    }

    @isTest
    static void caseCreationForPhotovoltaicRefund() {
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        accountList[0].XC_Segment__c = 'B2C';
        accountList[0].XC_GiveDataTo_EnelXItalia__c = true;
        insert accountList;
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(accountList);
        contList[0].XC_CountryLegalEntity__c = 'ITALY';
        contList[0].XC_MainLegalEntity__c = 'EnelXItalia';
        insert contList;
        
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        listAsset[0].Name = 'MyTestAsset';
        listAsset[0].AccountId = accountList[0].Id;
        listAsset[0].ContactId = contList[0].Id;
        listAsset[0].NE__Status__c = 'Active';
        listAsset[0].XC_LegalEntity__c = 'EnelXItalia';
        listAsset[0].XC_Segment__c = 'B2C';
        insert listAsset;
        
        Test.startTest();
            listAsset[0].XC_ElectricalConnectionDate__c = Date.today();
            update listAsset;
            Case caso = [SELECT Id FROM Case WHERE AssetId =: listAsset[0].Id];
            System.assert(Caso != null);
        Test.stopTest();
    }
}