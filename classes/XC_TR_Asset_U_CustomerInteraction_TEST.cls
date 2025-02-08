@isTest
public class XC_TR_Asset_U_CustomerInteraction_TEST {
	@isTest
    static void manageCustomerInteraction(){
        List<Asset> asset = XC_DF_Asset.createAssets(2);
        asset[0].XC_Segment__c = 'B2B';
        asset[1].XC_Segment__c = 'B2B';
        asset[0].XC_Product_Type__c = 'Service';
        asset[1].XC_Product_Type__c = 'Service';
		asset[0].Status = 'Active';
        asset[1].Status = 'Purchased';
        insert asset;
		Map<Id, Asset> mapNew = new Map<Id, Asset>();
		mapNew.put(asset[0].id, asset[0]);
        Map<Id, Asset> mapOld = new Map<Id, Asset>();
        mapOld.put(asset[0].id, asset[1]);
        test.startTest();
        XC_TR_Asset_U_CustomerInteraction.manageCustomerInteraction(mapNew, mapOld);
        test.stopTest();
    }
}