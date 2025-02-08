@isTest
public class XC_VATManagementController_Test {
    @isTest
    static void getOIsWrapper2Test(){
        List<XC_VATManagementController.XC_VATManagementOIsWrapper> wrappers;

        NE__Order__c order = XC_DF_Order.createOrder('Asset');
        order.XC_LegalEntity__c = 'EndesaX';
        order.XC_Segment__c = 'B2B';
        update order;

        NE__OrderItem__c oiPadre = XC_DF_OrderItem.createOrderItem(order);
        oiPadre.NE__OrderId__c = order.Id;
        oiPadre.XC_ApplyNormalTaxByDefault__c = false;
        oiPadre.XC_ProvisioningSpareParts__c = false;
        insert oiPadre;

        NE__OrderItem__c oiHijo = XC_DF_OrderItem.createOrderItem(order);
        oiHijo.NE__OrderId__c = order.Id;
        oiHijo.XC_ApplyNormalTaxByDefault__c = false;
        oiHijo.XC_ProvisioningSpareParts__c = false;
        oiHijo.NE__Parent_Order_Item__c = oiPadre.Id;
        insert oiHijo;
        
        User admin = XC_DF_User.createUserAdmin();
        admin.XC_LegalEntity__c = 'EndesaX';
        insert admin;

        Test.startTest();
        System.runAs(admin){
           wrappers = XC_VATManagementController.getOIsWrapper2(order.Id); 
        }
        
        System.assert(!wrappers.isEmpty(), 'No se rellenó correctamente la lista');
        Test.stopTest();
    }

    @isTest
    static void getTiposImpuestosTest(){
        List<NE__Billing_Profile__c> bps;
        XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c();
        NE__Order__c order;
        NE__OrderItem__c oiPadre;
        NE__OrderItem__c oiHijo;
        List<XC_VATManagementController.XC_VATManagementOIsWrapper> wrappers;
        List<XC_Address__c> addresses;
        Map<Id, String> tiposImpuestos;
        XC_VATManagementController.XC_VATManagementControllerWrapper wrapper;

        addresses = XC_DF_Address.createAddress(1);
        insert addresses;

        bps = XC_DF_BillingProfile.createBillingProfile(1);
        bps[0].NE__Payment__c = 'Credit Card';
        update bps;

        bpli.XC_SoldToAddress__c = addresses[0].Id;
        bpli.XC_BillingProfile__c = bps[0].Id;
        bpli.XC_Account__c = addresses[0].XC_Account__c;
        insert bpli;

        order = XC_DF_Order.createOrder('Asset');
        order.XC_LegalEntity__c = 'EndesaX';
        order.XC_Segment__c = 'B2B';
        update order;

        oiPadre = XC_DF_OrderItem.createOrderItem(order);
        oiPadre.NE__OrderId__c = order.Id;
        oiPadre.XC_ApplyNormalTaxByDefault__c = false;
        oiPadre.XC_ProvisioningSpareParts__c = false;
        oiPadre.XC_BillingProfileLineItem__c = bpli.Id;
        oiPadre.XC_PaymentMethod__c = 'Credit Card';
        insert oiPadre;

        oiHijo = XC_DF_OrderItem.createOrderItem(order);
        oiHijo.NE__OrderId__c = order.Id;
        oiHijo.XC_ApplyNormalTaxByDefault__c = false;
        oiHijo.XC_ProvisioningSpareParts__c = false;
        oiHijo.NE__Parent_Order_Item__c = oiPadre.Id;
        oiHijo.XC_BillingProfileLineItem__c = bpli.Id;
        oiHijo.XC_PaymentMethod__c = 'Credit Card';
        insert oiHijo;
        
        User admin = XC_DF_User.createUserAdmin();
        admin.XC_LegalEntity__c = 'EndesaX';
        insert admin;

        Test.startTest();
        System.runAs(admin){
            wrappers = XC_VATManagementController.getOIsWrapper2(order.Id);
            tiposImpuestos = XC_VATManagementController.getTiposImpuestos(wrappers);
            wrapper = XC_VATManagementController.wrapperMethod(order.Id);
        }
        System.assert(!tiposImpuestos.isEmpty(), 'No se rellenó correctamente el mapa');
        Test.stopTest();
    }

    @isTest
    static void saveTaxesTest(){
        List<NE__Billing_Profile__c> bps;
        XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c();
        NE__Order__c order;
        NE__OrderItem__c oiPadre;
        NE__OrderItem__c oiHijo;
        List<XC_VATManagementController.XC_VATManagementOIsWrapper> wrappers;
        List<XC_Address__c> addresses;
        Map<Id, String> tiposImpuestos;
        XC_VATManagementController.XC_VATManagementControllerWrapper wrapper;
        List<String> oisNames = new List<String>();

        addresses = XC_DF_Address.createAddress(1);
        insert addresses;

        bps = XC_DF_BillingProfile.createBillingProfile(1);
        bps[0].NE__Payment__c = 'Credit Card';
        update bps;

        bpli.XC_SoldToAddress__c = addresses[0].Id;
        bpli.XC_BillingProfile__c = bps[0].Id;
        bpli.XC_Account__c = addresses[0].XC_Account__c;
        insert bpli;

        order = XC_DF_Order.createOrder('Asset');
        order.XC_LegalEntity__c = 'EndesaX';
        order.XC_Segment__c = 'B2B';
        update order;

        oiPadre = XC_DF_OrderItem.createOrderItem(order);
        oiPadre.NE__OrderId__c = order.Id;
        oiPadre.XC_ApplyNormalTaxByDefault__c = false;
        oiPadre.XC_ProvisioningSpareParts__c = false;
        oiPadre.XC_BillingProfileLineItem__c = bpli.Id;
        oiPadre.XC_PaymentMethod__c = 'Credit Card';
        insert oiPadre;

        oiHijo = XC_DF_OrderItem.createOrderItem(order);
        oiHijo.NE__OrderId__c = order.Id;
        oiHijo.XC_ApplyNormalTaxByDefault__c = false;
        oiHijo.XC_ProvisioningSpareParts__c = false;
        oiHijo.NE__Parent_Order_Item__c = oiPadre.Id;
        oiHijo.XC_BillingProfileLineItem__c = bpli.Id;
        oiHijo.XC_PaymentMethod__c = 'Credit Card';
        insert oiHijo;


        oiPadre = [SELECT Id, Name, XC_Select_Tax_Completed__c, NE__Parent_Order_Item__c FROM NE__OrderItem__c WHERE Id=:oiPadre.Id];
        oiHijo = [SELECT Id, Name, XC_Select_Tax_Completed__c, NE__Parent_Order_Item__c FROM NE__OrderItem__c WHERE Id=:oiHijo.Id];
        oisNames.add(oiPadre.Name);
        oisNames.add(oiHijo.Name);
		
        User admin = XC_DF_User.createUserAdmin();
        admin.XC_LegalEntity__c = 'EndesaX';
        insert admin;
        
        Test.startTest();
        System.runAs(admin){
            XC_VATManagementController.saveTaxes(oisNames);
        }
        oiHijo = [SELECT Id, Name, XC_Select_Tax_Completed__c, NE__Parent_Order_Item__c FROM NE__OrderItem__c WHERE Id=:oiHijo.Id];
        System.assert(oiHijo.XC_Select_Tax_Completed__c, 'No se actualizó el campo XC_Select_Tax_Completed__c');
        Test.stopTest();
    }

    @isTest
    static void getOIsWrapper2Test2(){
        List<XC_VATManagementController.XC_VATManagementOIsWrapper> wrappers;

        NE__Order__c order = XC_DF_Order.createOrder('Asset');
        order.XC_LegalEntity__c = 'EndesaX';
        order.XC_Segment__c = 'B2B';
        update order;

        NE__OrderItem__c oiPadre = XC_DF_OrderItem.createOrderItem(order);
        oiPadre.NE__OrderId__c = order.Id;
        oiPadre.XC_ApplyNormalTaxByDefault__c = false;
        oiPadre.XC_ProvisioningSpareParts__c = false;
        insert oiPadre;

        /*NE__OrderItem__c oiHijo = XC_DF_OrderItem.createOrderItem(order);
        oiHijo.NE__OrderId__c = order.Id;
        oiHijo.XC_ApplyNormalTaxByDefault__c = false;
        oiHijo.XC_ProvisioningSpareParts__c = false;
        oiHijo.NE__Parent_Order_Item__c = oiPadre.Id;
        insert oiHijo;*/
        
        User admin = XC_DF_User.createUserAdmin();
        admin.XC_LegalEntity__c = 'EndesaX';
        insert admin;

        Test.startTest();
        System.runAs(admin){
           wrappers = XC_VATManagementController.getOIsWrapper2(order.Id); 
        }
        
        System.assert(!wrappers.isEmpty(), 'No se rellenó correctamente la lista');
        Test.stopTest();
    }
}