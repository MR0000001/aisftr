/**
  * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
  * @date 24/03/2021
  * @description XC_LCC246_DocumentManagement_TEST - Test Class for XC_LCC246_DocumentManagement
*/

@isTest
private class XC_LCC246_DocumentManagement_TEST {

    @isTest
    static void onDocuments() {
      NE__Order__c order = XC_DF_Order.createOrder(Label.XC_CL_Configuration_TypeInOrder);
      order.XC_Status__c = Label.XC_CL_Configuration_OrderInProgress;
      update order;
      List<NE__OrderItem__c> listOrderItems = new List<NE__OrderItem__c>([
        SELECT Id, NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c 
        FROM NE__OrderItem__c
        WHERE NE__OrderId__c = :order.Id
      ]);
      for(NE__OrderItem__c oi : listOrderItems) {
          oi.XC_PaymentMethod__c = 'Credit Card';
          oi.XC_Country__c = 'Italy';
      }
      update listOrderItems;

      XC_LCC246_DocumentManagement.ReturnWrapper retWr = XC_LCC246_DocumentManagement.getDocuments(order.NE__OptyId__c);

      List<User> listUser = new List<User>([
        SELECT Id, XC_Receiving_Channel__c
        FROM User
        WHERE Id = :UserInfo.getUserId()
      ]);

      XC_DocumentComplianceMaster__c dcm = new XC_DocumentComplianceMaster__c(
        XC_ComplianceType__c = 'C1',
        XC_Country__c = 'Italy',
        XC_PaymentMethod__c = 'Credit Card',
        XC_ProductCategory__c = listOrderItems[0].NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c,
        XC_ReceivingChannel__c = listUser[0].XC_Receiving_Channel__c,
        XC_DocumentType__c = 'SF_DNI'
      );
      insert dcm;

      retWr = XC_LCC246_DocumentManagement.getDocuments(order.NE__OptyId__c);
      XC_LCC246_DocumentManagement.updateOrder(order.Id, 'test1');
      XC_LCC246_DocumentManagement.updateOrder(order.Id, 'test2');
    }

    @isTest
    static void onDocuments2() {
      NE__Order__c order = XC_DF_Order.createOrder(Label.XC_CL_Configuration_TypeInOrder);
      order.XC_Status__c = Label.XC_CL_Configuration_OrderInProgress;
      update order;
      List<NE__OrderItem__c> listOrderItems = new List<NE__OrderItem__c>([
        SELECT Id, NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c 
        FROM NE__OrderItem__c
        WHERE NE__OrderId__c = :order.Id
      ]);
      for(NE__OrderItem__c oi : listOrderItems) {
          oi.XC_Country__c = 'Italy';
      }
      update listOrderItems;

      XC_LCC246_DocumentManagement.ReturnWrapper retWr = XC_LCC246_DocumentManagement.getDocuments(order.NE__OptyId__c);

      List<User> listUser = new List<User>([
        SELECT Id, XC_Receiving_Channel__c
        FROM User
        WHERE Id = :UserInfo.getUserId()
      ]);

      XC_DocumentComplianceMaster__c dcm = new XC_DocumentComplianceMaster__c(
        XC_ComplianceType__c = 'C1',
        XC_Country__c = 'Italy',
        XC_PaymentMethod__c = 'Credit Card',
        XC_ProductCategory__c = listOrderItems[0].NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c,
        XC_ReceivingChannel__c = listUser[0].XC_Receiving_Channel__c,
        XC_DocumentType__c = 'SF_DNI'
      );
      insert dcm;

      retWr = XC_LCC246_DocumentManagement.getDocuments(order.NE__OptyId__c);
      XC_LCC246_DocumentManagement.updateOrder(order.Id, 'test1');
      XC_LCC246_DocumentManagement.updateOrder(order.Id, 'test2');
    }
    
}