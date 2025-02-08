/**
* @author FirstName : Patrizia Arcidiacono - patrizia.arcidiacono@nttdata.com
* @date Creation 27/01/2020
* @date Modification dd/mm/yyyy
* @description Giic_ProductSerial_UTIL_TEST
*/

@isTest(SeeAllData=false)
public class Giic_ProductSerial_UTIL_TEST {

   
   // Methods for testing
   @isTest static void productSerialTest() {
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.productCreation();
  		gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c IN: Giic_UtilityClass_Test.lstProd Limit 1];
        objProdRef.gii__SerialControlled__c=true;
        objProdRef.giic_ProcurementType__c = 'Transfer';
        objProdRef.gii__PrimarySupplier__c = Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef.giic_AveragePrice__c = 1;
        update objProdRef;
       
        system.debug('@@@@ insert obj ProductReference'); 
       Test.startTest();
            Giic_UtilityClass_Test.objProductSerial= new gii__ProductSerial__c(Name = 'TUBE1234',gii__Product__c=objProdRef.id,gii__TransactionType__c='Shipment');
        	insert Giic_UtilityClass_Test.objProductSerial;
            Giic_UtilityClass_Test.objProductSerial.gii__Warehouse__c=Giic_UtilityClass_Test.lstWh[0].Id;
            update Giic_UtilityClass_Test.objProductSerial;
       		Giic_UtilityClass_Test.objProductSerial.Name = 'TUBE12345';
       		update Giic_UtilityClass_Test.objProductSerial;	
       		Giic_TR_Product2_UTIL.setValuesOnProductReference(Giic_UtilityClass_Test.lstProd);
       Giic_CommonWrapper.MediaMobileWrapper mmw = new Giic_CommonWrapper.MediaMobileWrapper();
        List<Giic_CommonWrapper.MediaMobileWrapper> mmwList = new List<Giic_CommonWrapper.MediaMobileWrapper>();
        mmw.productCode = objProdRef.gii__ProductCode__c;
        mmw.price = 7;
        mmw.inCurrency = 'USD';
        mmwList.add(mmw);
        Giic_ProductReference_UTIL.updateAveragePrice(mmwList);
       Test.stopTest();
		
   }
    
    @isTest static void productSerialTest2() {
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.productCreation();
  		gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c IN: Giic_UtilityClass_Test.lstProd Limit 1];
        objProdRef.gii__SerialControlled__c=true;
        objProdRef.giic_ProcurementType__c = 'Transfer';
        objProdRef.gii__PrimarySupplier__c = Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef.giic_AveragePrice__c = 1;
        update objProdRef;
        
        Giic_UtilityClass_Test.objProductSerial= new gii__ProductSerial__c(Name = 'TUBE1234',gii__Product__c=objProdRef.id,gii__TransactionType__c='Shipment');
       	insert Giic_UtilityClass_Test.objProductSerial;
        gii__Shipment__c objShipment = new gii__Shipment__c(giic_DeliveryDate__c = system.today(), giic_DeliveryDocumentID__c = '123', giic_RegistrationDate__c = system.today());
        insert objShipment;
        gii__ShipmentDetail__c objShipmentDetail = new gii__ShipmentDetail__c(gii__ProductSerial__c = Giic_UtilityClass_Test.objProductSerial.id, gii__Shipment__c = objShipment.Id );
        insert objShipmentDetail;
        List<gii__ShipmentDetail__c> shipDetailsList = New List<gii__ShipmentDetail__c>();
        shipDetailsList.add(objShipmentDetail);
        
        test.startTest();
        Giic_ProductSerial_UTIL.populateInstallationDate(shipDetailsList);
        test.stopTest();
    }
    
    @isTest static void productSerialTest3() {
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.productCreation();
  		gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c IN: Giic_UtilityClass_Test.lstProd Limit 1];
        objProdRef.gii__SerialControlled__c=true;
        objProdRef.giic_ProcurementType__c = 'Transfer';
        objProdRef.gii__PrimarySupplier__c = Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef.giic_AveragePrice__c = 1;
        update objProdRef;
        
        Giic_UtilityClass_Test.objProductSerial= new gii__ProductSerial__c(Name = 'TUBE1234',gii__Product__c=objProdRef.id,gii__TransactionType__c='Shipment', giic_FirstInstallationDate__c = system.today());
       	insert Giic_UtilityClass_Test.objProductSerial;
        gii__Shipment__c objShipment = new gii__Shipment__c(giic_DeliveryDate__c = system.today(), giic_DeliveryDocumentID__c = '123', giic_RegistrationDate__c = system.today());
        insert objShipment;
        gii__ShipmentDetail__c objShipmentDetail = new gii__ShipmentDetail__c(gii__ProductSerial__c = Giic_UtilityClass_Test.objProductSerial.id, gii__Shipment__c = objShipment.Id );
        insert objShipmentDetail;
        List<gii__ShipmentDetail__c> shipDetailsList = New List<gii__ShipmentDetail__c>();
        shipDetailsList.add(objShipmentDetail);
        
        test.startTest();
        Giic_ProductSerial_UTIL.populateInstallationDate(shipDetailsList);
        test.stopTest();
    }
    
    
    
    

 
}