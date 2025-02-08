/**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@in.fujitsu.com
* @date Creation 01/07/2019
* @date Modification dd/mm/yyyy
* @description giic_CustomLookup_Test – To test Giic_CustomLookup.
*/ 

@isTest(SeeAllData=false)
public class Giic_CustomLookup_Test {        
    /**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@in.fujitsu.com
* @date 01/07/2019
* @description To validate searchDB method of giic_CustomLookup.
*/  
    
    static testMethod void validatecreateSalesOrders(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        List<gii__Warehouse__c> whList = [SELECT Id FROM gii__Warehouse__c];
        System.assertEquals(true, whList.size()>0);
        String objectName='gii__Location__c';
        String fldAPIText='gii__Warehouse__c';
        String fldAPIVal='Name';
        Integer lim=1;
        String fldAPISearch='Name';
        String searchText=giic_UtilityClass_Test.objLocationCentral.Name;
       
        string strReturnValue = Giic_CustomLookup.searchDB(objectName,fldAPIText,fldAPIVal, 
                                  lim,fldAPISearch,searchText);
           
		
    }
}