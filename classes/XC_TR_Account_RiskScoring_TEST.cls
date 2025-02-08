@isTest
public class XC_TR_Account_RiskScoring_TEST {
	@isTest
    static void checkRiskScoring(){
        List<Account> listNew = XC_DF_Account.createResidentialAccounts(1);
        listNew[0].XC_Segment__c = 'B2B';
        listNew[0].XC_DocumentCountry__c = 'Italy';
        listNew[0].IdentityType__c = 'Partita IVA';
        listNew[0].IdentityNumber__c = 'AAABBB';
        
        XC_AccountBlacklistInformation__c abi = new XC_AccountBlacklistInformation__c();
        abi.Name= 'blackList';
        abi.XC_DocumentCountry__c='Italy';
        abi.XC_IdentityNumber__c='AAABBB';
        abi.XC_IdentityType__c='Partita IVA';  
        abi.XC_Segment__c = 'B2B';
        insert abi;
        Test.startTest();
        XC_TR_Account_RiskScoring.checkRiskScoring(listNew);
        Test.stopTest();
    }
}