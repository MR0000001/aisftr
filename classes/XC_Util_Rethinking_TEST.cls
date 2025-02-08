/**
 *
 * @author :              Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation :       18/121/2019
 * @description :         XC_Util_Rethinking_TEST,Test class for XC_Util_Rethinking
 * 
 */

@isTest
public without sharing class XC_Util_Rethinking_TEST {
    
    @TestSetup
	static void setup(){ 

		OneOrg__c org            = new OneOrg__c(); 
	    org.Name                 = 'OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
	    insert org;
        
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].XC_LegalEntity__c = 'EndesaX';
        insert assetList;
        System.debug('assetId='+assetList[0].Id);
    }
    
    
    /*
	*@ Description test without product lic name
	*/
    @isTest
	static void testWithoutProductLicName(){

        test.startTest();
        Asset ass = [SELECT Id, XC_LegalEntity__c, XC_Segment__c FROM Asset LIMIT 1][0];
        List<XC_CM_RethinkingDays__mdt> mtd = [SELECT Id, XC_Days__c FROM XC_CM_RethinkingDays__mdt WHERE XC_LegalEntity__c=:ass.XC_LegalEntity__c ];
   		String rethinkingDays = !mtd.isEmpty() ? String.valueOf(mtd[0].XC_Days__c) : Label.XC_CL_RethinkingDeafaultDays;
		String result = XC_Util_Rethinking.getRethinkingDays(ass);
        System.assertEquals(result, rethinkingDays, 'Wrong assert result');
		test.stopTest();
	}

}