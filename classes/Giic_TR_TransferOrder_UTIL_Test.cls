/** 
* @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 29/10/2020
* @date Modification dd/mm/yyyy
* @description Giic_TR_TransferOrder_UTIL – Utility for Transfer Order                                 
*/  

@isTest
public   class Giic_TR_TransferOrder_UTIL_Test {
  @isTest
    public static  void setEmailFiled(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation(); 
       
        
        Test.startTest();
         Giic_UtilityClass_Test.insertTO();  
        Test.stopTest();
        
    }
    
    /** 
* @author FirstName : Alberto Pompei - alberto.pompei@nttdata.com
* @date Creation 19/11/2020
* @date Modification dd/mm/yyyy
* @description test method for setGoodsNotAvailable() of the class Giic_TR_TransferOrder_UTIL – Utility for Transfer Order                                 
*/
    @isTest
    public static void setGoodsNotAvailableTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreationTO();
        Giic_UtilityClass_Test.workTypeCreation();
        Giic_UtilityClass_Test.workOrderCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_WorkOrder__c = Giic_UtilityClass_Test.objWorkOrder.id;
        update Giic_UtilityClass_Test.objSalesOrder;
        Giic_UtilityClass_Test.transferOrderCreationWI();
        
        
        test.startTest();
        Giic_UtilityClass_Test.objTO.giic_SalesOrder__c = Giic_UtilityClass_Test.objSalesOrder.id;
        insert Giic_UtilityClass_Test.objTO;
        test.stopTest();
    }
    
}