/**
* @author Nicola Arrigo - narrigo@deloitte.it  
* @date Creation  02/04/2020 
* @description XC_Rest_TransferOrder_Test – Test class for XC_Rest_TransferOrder
*/
@isTest
public with sharing class XC_Rest_TransferOrder_Test {
    public static testMethod void sendCreateTransferOrder3PL(){
        OneOrg__c org=new OneOrg__c(); 
	    org.Name='OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
	    insert org;
  List<Id> recordID=new List<id>();
  // Local Warehouse creation
   Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.objWh.giic_ServerSystem__c='Redsla';
        update Giic_UtilityClass_Test.objWh;
  //TransferOrderCreation
  Giic_UtilityClass_Test.transferOrderCreation();
 //Product creation 
 Giic_UtilityClass_Test.productCreation();      
 //Query on Product
 gii__Product2Add__c[] objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,
                                            gii__PrimarySupplier__c from gii__Product2Add__c Limit 1
                                     ];
Giic_UtilityClass_Test.objTO.giic_Status__c='Open';
Giic_UtilityClass_Test.objTO.giic_Approved__c=true;
update Giic_UtilityClass_Test.objTO;
 //TOLine
Giic_UtilityClass_Test.tOLineCreation(objProdRef[0]);        
 List<gii__TransferOrder__c> trasferOrderList = new List<gii__TransferOrder__c>([SELECT Id, gii__Account__r.Name ,gii__FromWarehouse__r.giic_WarehouseCode__c,
                                                                                        gii__TransferToWarehouse__r.giic_WarehouseCode__c,gii__OrderDate__c,gii__RequiredDate__c,
                                                                                        gii__ShipToZipPostalCode__c,gii__ShipToStreet__c,gii__ShipToState__c,gii__ShipToName__c,
                                                                                        gii__ShipToCity__c,gii__ShipToCountry__c,Name,giic_status__c,giic_TransferOrderType__c,
                                                                                        gii__Account__r.Phone,gii__Account__r.PrimaryEmail__c, gii__FromWarehouse__r.giic_WarehouseType__c,
                                                                                        gii__FromWarehouse__r.giic_ServerSystem__c,
                                                                                        gii__FromWarehouse__r.giic_ParentWarehouse__r.giic_ServerSystem__c,
                                                                                        gii__TransferToWarehouse__r.giic_WarehouseType__c, 
                                                                                        (SELECT ID, gii__Quantity__c,gii__Product__r.gii__ProductReference__r.Name,
                                                                                         gii__Product__r.gii__ProductCode__c ,gii__RequiredDate__c,Name,
                                                                                         gii__Product__r.giic_EANReference__c         
                                                                                         FROM gii__TransferOrderLines__r)  
                                                                                        FROM gii__TransferOrder__c 
                                                                                       ]);
        for(gii__TransferOrder__c t:trasferOrderList){
           recordID.add(t.id);
        }
     test.startTest();
      XC_Rest_TransferOrder.sendCreateTransferOrder3PL(recordID);
   /*   XC_Rest_TransferOrder recordIdList=new XC_Rest_TransferOrder();  
      recordIdList.callSendCreateTO3PLQueuable(recordID); */ 
    test.stopTest();
    }
    
    
     public static testMethod void sendCreateTransferOrder3PL2(){
        OneOrg__c org=new OneOrg__c(); 
	    org.Name='OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
	    insert org;
  List<Id> recordID=new List<id>();
  // Local Warehouse creation
   Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
       /* Giic_UtilityClass_Test.objWh.giic_ServerSystem__c='Redsla';
        update Giic_UtilityClass_Test.objWh;*/
  //TransferOrderCreation
  Giic_UtilityClass_Test.transferOrderCreation();
 //Product creation 
 Giic_UtilityClass_Test.productCreation();      
 //Query on Product
 gii__Product2Add__c[] objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,
                                            gii__PrimarySupplier__c from gii__Product2Add__c Limit 1
                                     ];
//TOLine
Giic_UtilityClass_Test.tOLineCreation(objProdRef[0]);        
 List<gii__TransferOrder__c> trasferOrderList = new List<gii__TransferOrder__c>([SELECT Id, gii__Account__r.Name ,gii__FromWarehouse__r.giic_WarehouseCode__c,
                                                                                        gii__TransferToWarehouse__r.giic_WarehouseCode__c,gii__OrderDate__c,gii__RequiredDate__c,
                                                                                        gii__ShipToZipPostalCode__c,gii__ShipToStreet__c,gii__ShipToState__c,gii__ShipToName__c,
                                                                                        gii__ShipToCity__c,gii__ShipToCountry__c,Name,giic_status__c,giic_TransferOrderType__c,
                                                                                        gii__Account__r.Phone,gii__Account__r.PrimaryEmail__c, gii__FromWarehouse__r.giic_WarehouseType__c,
                                                                                        gii__FromWarehouse__r.giic_ServerSystem__c,
                                                                                        gii__FromWarehouse__r.giic_ParentWarehouse__r.giic_ServerSystem__c,
                                                                                        gii__TransferToWarehouse__r.giic_WarehouseType__c, 
                                                                                        (SELECT ID, gii__Quantity__c,gii__Product__r.gii__ProductReference__r.Name,
                                                                                         gii__Product__r.gii__ProductCode__c ,gii__RequiredDate__c,Name,
                                                                                         gii__Product__r.giic_EANReference__c         
                                                                                         FROM gii__TransferOrderLines__r)  
                                                                                        FROM gii__TransferOrder__c 
                                                                                       ]);
        for(gii__TransferOrder__c t:trasferOrderList){
           recordID.add(t.id);
        }
     test.startTest();
      XC_Rest_TransferOrder.sendCreateTransferOrder3PL(recordID);
   /*   XC_Rest_TransferOrder recordIdList=new XC_Rest_TransferOrder();  
      recordIdList.callSendCreateTO3PLQueuable(recordID); */ 
    test.stopTest();
    }   
    
    
    
    @isTest static  void populateErrorLogListTest() {
        OneOrg__c org=new OneOrg__c(); 
	    org.Name='OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
	    insert org;
  List<Id> recordID=new List<id>();
  // Local Warehouse creation
   Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
       /* Giic_UtilityClass_Test.objWh.giic_ServerSystem__c='Redsla';
        update Giic_UtilityClass_Test.objWh;*/
  //TransferOrderCreation
  Giic_UtilityClass_Test.transferOrderCreation();
 //Product creation 
 Giic_UtilityClass_Test.productCreation();      
 //Query on Product
 gii__Product2Add__c[] objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,
                                            gii__PrimarySupplier__c from gii__Product2Add__c Limit 1
                                     ];
//TOLine
Giic_UtilityClass_Test.tOLineCreation(objProdRef[0]);        
 List<gii__TransferOrder__c> trasferOrderList = new List<gii__TransferOrder__c>([SELECT Id, gii__Account__r.Name ,gii__FromWarehouse__r.giic_WarehouseCode__c,
                                                                                        gii__TransferToWarehouse__r.giic_WarehouseCode__c,gii__OrderDate__c,gii__RequiredDate__c,
                                                                                        gii__ShipToZipPostalCode__c,gii__ShipToStreet__c,gii__ShipToState__c,gii__ShipToName__c,
                                                                                        gii__ShipToCity__c,gii__ShipToCountry__c,Name,giic_status__c,giic_TransferOrderType__c,
                                                                                        gii__Account__r.Phone,gii__Account__r.PrimaryEmail__c, gii__FromWarehouse__r.giic_WarehouseType__c,
                                                                                        gii__FromWarehouse__r.giic_ServerSystem__c,
                                                                                        gii__FromWarehouse__r.giic_ParentWarehouse__r.giic_ServerSystem__c,
                                                                                        gii__TransferToWarehouse__r.giic_WarehouseType__c, 
                                                                                        (SELECT ID, gii__Quantity__c,gii__Product__r.gii__ProductReference__r.Name,
                                                                                         gii__Product__r.gii__ProductCode__c ,gii__RequiredDate__c,Name,
                                                                                         gii__Product__r.giic_EANReference__c         
                                                                                         FROM gii__TransferOrderLines__r)  
                                                                                        FROM gii__TransferOrder__c 
                                                                                       ]);
        for(gii__TransferOrder__c t:trasferOrderList){
           recordID.add(t.id);
        }
         List<giic_ErrorLog__c> errorLogList = new List<giic_ErrorLog__c>();
     test.startTest();
     XC_REST_TransferOrder.populateErrorLogList(trasferOrderList[0],errorLogList);
   
    test.stopTest();
    }   
    
    
    
    
    
}