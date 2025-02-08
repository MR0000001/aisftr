/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @date Creation 15/05/2019
* @date Modification 15/05/2019 Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description giic_LCC010_InventoryMovement_Test
*/  
@isTest
public class giic_LCC010_InventoryMovement_Test {

 /**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description  Method to test getRecordTypeIdByName
*/
    @isTest static void getPIinfoAndAllpiqdTest() {
	    Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.productCreation();
    Test.startTest();
        gii__Product2Add__c p = Giic_DF_Glovia.createProductReference();
        gii__ProductInventory__c pi = Giic_DF_Glovia.createProductInventory(Giic_UtilityClass_Test.objWh.Id ,p.Id);
        insert pi;
        System.debug('PI = '+pi.Id);
    	giic_LCC010_InventoryMovement.XC_UTIL_InventoryMovementWrapper w = giic_LCC010_InventoryMovement.getPIinfoAndAllpiqd(pi.Id);
        System.assert(w!=null);
    Test.stopTest();
    
   
    }
    
    
     @isTest static void getPiqdFilteredTest() {
	    Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.locationCreation();
    Test.startTest();
        gii__Product2Add__c p = Giic_DF_Glovia.createProductReference();
        gii__ProductInventory__c pi = Giic_DF_Glovia.createProductInventory(Giic_UtilityClass_Test.objWh.Id ,p.Id);
        insert pi;
        System.debug('PI = '+pi.Id);
    	giic_LCC010_InventoryMovement.getPiqdFiltered(pi.Id,'','','');
        
    Test.stopTest();
    }
    
     @isTest static void inventoryMovementTest() {
	    Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.productCreation();  
        List<gii__Product2Add__c> lstProdRef = [SELECT Id FROM gii__Product2Add__c];
        lstProdRef[0].gii__SerialControlled__c = true;
        update lstProdRef;
        Giic_UtilityClass_Test.productSerialCreation(lstProdRef[0].Id);       
        Giic_UtilityClass_Test.locationCreation();
        gii__ProductInventory__c pi = Giic_DF_Glovia.createProductInventory(Giic_UtilityClass_Test.objWh.Id, lstProdRef[0].Id);
        insert pi;
        Giic_UtilityClass_Test.creationPILocation(pi,lstProdRef[0]);
        Test.startTest();
        List<gii__Product2Add__c> p2List = new  List<gii__Product2Add__c>();
        List<gii__ProductInventory__c> pInvList = new  List<gii__ProductInventory__c>();    
        p2List.add(lstProdRef[0]);
        pInvList.add(pi); 
        map<String,String> mapIdToOnHand = new  map<String,String>();           
        map<String,String> mapIdPiqdToLocationFrom = new  map<String,String>();
        Giic_UtilityClass_Test.objPS.gii__AdjustmentSequence__c = 'rrr';
        update Giic_UtilityClass_Test.objPS;
         Giic_UtilityClass_Test.lstProd[0].XC_Brand__c = 'BAXI';
         update Giic_UtilityClass_Test.lstProd[0];
        Giic_UtilityClass_Test.creationPILocationDetail(pInvList[0],p2List[0]);
        mapIdToOnHand.put(Giic_UtilityClass_Test.objPID.Id, '3');
        giic_LCC010_InventoryMovement.inventoryMovement(pi.Id,Giic_UtilityClass_Test.objLocationlocal.Id,JSON.serialize(mapIdToOnHand),JSON.serialize(mapIdPiqdToLocationFrom));
        Giic_UtilityClass_Test.objPID.gii__OnHandQuantity__c = 0;
        update Giic_UtilityClass_Test.objPID;
        List<gii__ProductInventoryQuantityDetail__c> plisttt = [SELECT Id FROM gii__ProductInventoryQuantityDetail__c];
        for(gii__ProductInventoryQuantityDetail__c p : plisttt){
             p.gii__OnHandQuantity__c = 0;
        }
        update plisttt;
        delete plisttt;
        delete pInvList;
        List<gii__Product2Add__c> p2List2 = [SELECT Id FROM gii__Product2Add__c];
        delete p2List2;
       
        delete Giic_UtilityClass_Test.objPS;
       
        delete Giic_UtilityClass_Test.lstProd;    
         
    Test.stopTest();
    }
    
    
    
    
}