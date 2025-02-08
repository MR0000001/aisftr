@isTest
public without sharing class XC_TR_Opportunity_U_ManageVoucher_TEST {

    @TestSetup
	static void setup(){ 

		OneOrg__c org            = new OneOrg__c(); 
	    org.Name                 = 'OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
	    insert org;

        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc; 

        List<XC_Address__c> addr = XC_DF_Address.createAddress(acc);
        insert addr;


        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, true);
        oppList[0].AccountId = acc[0].Id;
        oppList[0].XC_Address__c = addr[0].Id;
        insert oppList;

        List<NE__Order__c> order = XC_DF_Order.createOrders(1, 'InOrder'); 
        order[0].NE__OrderStatus__c= 'Active';
        order[0].RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Order_RecordTypeOpty).getRecordTypeId();
        order[0].NE__OptyId__c = oppList[0].Id; 
        order[0].XC_DeliveryAddress__c = addr[0].Id;
        order[0].XC_InstallationAddress__c = addr[0].Id;
        order[0].NE__AccountId__c = acc[0].Id;
        order[0].NE__Configuration_Type__c = Label.XC_CL_Configuration_TypeNew; 
        insert order;    

        
        List<NE__Product__c> pro = XC_DF_Product.createProducts(1);
        pro[0].XC_Product_Subtype__c ='Boiler';
        pro[0].XC_Product_Type__c ='Equipment';
        pro[0].XC_LIC_Product_Name__c = Label.XC_CL_CommercialProduct_Coupon;
        insert pro;     
        
        NE__OrderItem__c confitem = XC_DF_OrderItem.createOrderItem(order[0]);
        confitem.NE__ProdId__c= pro[0].Id;  
        confitem.NE__OrderId__c = order[0].id;
        insert confitem; 

        
        XC_Voucher__c vou = new XC_Voucher__c();
        vou.XC_Account__c = acc[0].Id;  
        vou.RecordTypeId = Schema.SObjectType.XC_Voucher__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Voucher_RtSingleUse).getRecordTypeId();
        vou.XC_Usage_Counter__c = 5; 
        vou.XC_Voucher_To_Be_Created__c=1;
        vou.XC_LegalEntity__c='EndesaX';
        insert vou;

        NE__Order_Item_Attribute__c cIattribute = new NE__Order_Item_Attribute__c();
        cIattribute.Name = Label.XC_CL_OrderItemAttribute_Coupon;
        cIattribute.NE__Order_Item__c = confitem.Id ; 
        cIattribute.NE__Value__c= [SELECT XC_VoucherCode__c FROM XC_Voucher__c][0].XC_VoucherCode__c;
        insert cIattribute; 

        XC_VoucherUtilization__c voutiliz = new XC_VoucherUtilization__c();
        voutiliz.XC_Voucher__c = vou.Id; 
        voutiliz.XC_Account__c = acc[0].Id; 
        insert voutiliz; 
        
        
    }


    @isTest
	static void testChangeOppStatus(){
        Opportunity opp = [SELECT id FROM Opportunity][0];

        test.startTest();
        opp.StageName = Label.XC_CL_Opportunity_ClosedLost;
        opp.XC_LossReason__c = 'Expired';
        update opp;
        test.stopTest();
        System.assertEquals(Label.XC_CL_Opportunity_ClosedLost, [SELECT StageName FROM Opportunity][0].StageName, 'Wrong assert result');
    }


}