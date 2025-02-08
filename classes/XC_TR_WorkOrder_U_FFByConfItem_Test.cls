/**
    * @author Nicola Arrigo
    * @date Creation  19/03/2020 
    * @description  XC_TR_WorkOrder_U_FillFieldByConfItem_Test – Test class for XC_TR_WorkOrder_U_FillFieldByConfItem
    */
@isTest
public class XC_TR_WorkOrder_U_FFByConfItem_Test {
   static testMethod void fillFieldsFromConfigurationItem(){
       List<XC_Address__c> addressList=XC_DF_Address.createAddress(1);
       insert addressList;
       NE__Order__c order=XC_DF_Order.createOrder('Order');
       order.NE__AccountId__c=addressList[0].XC_Account__c;
       //Account acc=order.NE__AccountId__r;
       order.XC_InstallationAddress__c=addressList[0].id;
       order.XC_DeliveryAddress__c=addressList[0].id;
       update order;
       // List<NE__OrderItem__c> items=XC_DF_OrderItem.createOrderItems(1);
       //items[0].NE__OrderId__c=order.id;
       //insert items;
       List<NE__OrderItem__c> confItem=[SELECT  Id, NE__Account__c, NE__OrderId__c, XC_Effective_Product_Availability_Date__c, XC_EffectiveDeliveryDate__c,  XC_DeliveryType__c,XC_CountryFormula__c,
                    XC_DurationInMinutes__c,NE__SerialNum__c,XC_Product_Reservation__c,XC_DeliveryId__c,NE__Qty__c, NE__OrderId__r.NE__OptyId__r.XC_Contact__c, XC_Delivery_Tracking_URL__c, 
                    XC_Courier_Partner__c, XC_PaymentMethod__c, NE__CatalogItem__r.NE__Product_Name__c, NE__OrderId__r.XC_InstallationAddress__c, NE__OrderId__r.XC_InstallationAddress__r.XC_Address__c, 
                    NE__OrderId__r.XC_InstallationAddress__r.XC_PostalCode__c,NE__OrderId__r.XC_InstallationAddress__r.XC_City__c, NE__OrderId__r.XC_InstallationAddress__r.XC_AddressCountry__c,  
                    NE__OrderId__r.NE__OptyId__c, NE__CatalogItem__r.NE__Catalog_Category_Name__c, NE__CatalogItem__c, NE__OrderId__r.XC_InstallationAddress__r.XC_StreetTypeText__c, NE__OrderId__r.XC_InstallationAddress__r.XC_StreetNumber__c,
                    (SELECT Id FROM Assets__r)
            FROM NE__OrderItem__c 
                      where NE__OrderId__c=:order.id  ];
       Asset asset1 = new Asset();
        asset1.Name= 'OKGas';
        asset1.Status = Label.XC_CL_Asset_StatusActive;
        asset1.XC_BillingModel__c='One Shot';
        asset1.XC_Configuration_Item__c=confItem[0].id;
       insert asset1;
       List<WorkOrder> woList=XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1,'Commercial Visit - Boiler', 'Delivery & Installation');
       woList[0].XC_Configuration_Item__c= confItem[0].id;
       woList[0].XC_NumberWorkOrdersDI__c=1;
       insert woList;
       confItem[0].NE__OrderId__r.XC_InstallationAddress__r.XC_Address__c='Address Name that have to pass the 80 charachter in order to cover the';
       confItem[0].NE__OrderId__r.XC_InstallationAddress__r.XC_PostalCode__c='28080';
        update confItem;        
       XC_TR_WorkOrder_U_FillFieldByConfItem.fillFieldsFromConfigurationItem(woList);
        system.debug('confItem Test'+' '+confItem[0]);
       system.debug('Test'+''+confItem[0].NE__OrderId__r.XC_InstallationAddress__r.XC_Address__c);
       system.debug('Test 2'+' '+confItem[0].NE__OrderId__r.XC_InstallationAddress__r.XC_PostalCode__c);
   }
}