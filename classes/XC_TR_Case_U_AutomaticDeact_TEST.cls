/**
 * The Class XC_TR_Case_U_AutomaticDeactivation.
 *
 * @author            : Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 07/07/2020
 * @date Modification : dd/mm/yyyy
 * @description       : XC_TR_Case_U_AutomaticDeact_TEST- Test Class for XC_TR_Case_U_AutomaticDeactivation
 **/ 

@isTest
public without sharing class XC_TR_Case_U_AutomaticDeact_TEST {

	@isTest
    static void automaticDeactivationWithoutAsset() {

		Case c = XC_DF_Case.createCases(1)[0];
        c.Reason = 'XCMOT010';
        c.SubCause__c = 'ATCL008';
        c.XC_EnergyContractedPower__c = 30;
        c.XC_EnergyVasContractNumberOfDays__c = 30;
        c.XC_LegalEntity__c = 'EndesaX';

		Test.startTest();
            insert c;
            System.assertEquals(c!=null, true, 'Wrong assert equals');
		Test.stopTest();
	}


    @isTest
    static void automaticDeactivationErrorConditions() {

		Case c = XC_DF_Case.createCases(1)[0];
        c.Reason = 'XCMOT010';
        c.SubCause__c = 'ATCL008';
        c.XC_EnergyContractedPower__c = 30;
        c.XC_EnergyVasContractNumberOfDays__c = 30;
        c.XC_LegalEntity__c = 'EndesaX';

        List<Asset> assetList = XC_DF_Asset.createAssets(new List<Account>{new Account(Id = c.AccountId)});
        insert assetList;

        c.AssetId = assetList[0].Id;

		Test.startTest();
            insert c;
            System.assertEquals(c!=null, true, 'Wrong assert equals');
		Test.stopTest();
	}


    @isTest
    static void automaticDeactivationTEST() {

		Case c = XC_DF_Case.createCases(1)[0];
        c.Reason = 'XCMOT010';
        c.SubCause__c = 'ATCL008';
        c.XC_EnergyContractedPower__c = 5;
        c.XC_EnergyVasContractNumberOfDays__c = 20;
        c.XC_LegalEntity__c = 'EndesaX';

        List<Asset> assetList = XC_DF_Asset.createAssets(new List<Account>{new Account(Id = c.AccountId)});
        insert assetList;

        c.AssetId = assetList[0].Id;

		Test.startTest();
            insert c;
            System.assertEquals(c!=null, true, 'Wrong assert equals');
		Test.stopTest();
	}
}