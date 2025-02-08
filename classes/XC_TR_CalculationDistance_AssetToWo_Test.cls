/** 
* @author Greta Romei - greta.romei@accenture.com
* @date Creation 22/02/2022
* @description - XC_TR_CalculationDistance_AssetToWo_Test– Test class for XC_TR_CalculationDistance_AssetToWo
 */

@isTest
public class XC_TR_CalculationDistance_AssetToWo_Test {

    @isTest
    static void updateDistanceWoTest(){
        Double dist;
        Location loc1;
        Location loc2;

        Schema.Location loc=new Schema.Location();
        loc.name='test';
        loc.Latitude=39.7749295;
        loc.Longitude=-125.4194155;
        insert loc;

        List<Asset> assetList = XC_DF_Asset.createAssets(1);    
        assetList[0].LocationId=loc.id;
        insert assetList;

        List<WorkOrder> listOrd = XC_DF_WorkOrder.createWorkOrdersForLead(1);
        listOrd[0].XC_Segment__c= 'B2C';
        listOrd[0].XC_Country__c = 'Chile';
        listOrd[0].XC_LegalEntity__c = 'EnelX';
        listOrd[0].Status= Label.XC_CL_WorkOrder_Assigned;
        listOrd[0].Latitude=37.7749295;
        listOrd[0].Longitude=-122.4194155;
        listOrd[0].AssetId=assetList[0].id;
        insert listOrd;

        loc1 = Location.newInstance(loc.Latitude,loc.Longitude);
        loc2 = Location.newInstance(listOrd[0].Latitude,listOrd[0].Longitude);
        dist = Location.getDistance(loc1,loc2,'km');
        dist = listOrd[0].XC_Distance__c;
        
        Test.startTest();
        listOrd[0].XC_WorkTypeLabel__c='Commercial Visit - Air Conditioning';
        listOrd[0].Latitude=44.22222;   
        listOrd[0].XC_CheckInMobility__c = true; 
        update listOrd;
        Test.stopTest();
    
    }

}