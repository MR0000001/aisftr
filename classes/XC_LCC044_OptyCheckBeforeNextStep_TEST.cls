/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com
* @Creation 20/05/2019
* @description Test Class for XC_LCC044_OptyCheckBeforeNextStep
*/
@isTest
private class XC_LCC044_OptyCheckBeforeNextStep_TEST {
    @IsTest
    static void test1(){
        
        insert XC_DF_Lead.createResidentialLead();
        insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
        XC_ProductCategoryOfInterest__c prInserted = [SELECT Id, Name FROM XC_ProductCategoryOfInterest__c];
        insert XC_DF_ProductCategoryOfInterest.productSkillRequired(prInserted);
        insert XC_DF_Account.createResidentialAccounts(1);
        List<Account> accList = [SELECT Id FROM Account];
        insert XC_DF_Address.createAddress(accList);
        List<XC_Address__c> listAddress = [SELECT Id FROM XC_Address__c];
        insert XC_DF_Contact.createResidentialContacts(accList);
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        List<Opportunity> oppInserted = XC_DF_Opportunity.createOpportunityWithVisit(contactList,listAddress[0]);
        oppInserted[0].XC_CommercialVisitStarted__c = false;
        oppInserted[0].XC_CommercialVisitRequired__c = true;
        insert oppInserted;
        Test.startTest();
        List<Opportunity> oppInserted2 = [SELECT Id,XC_CommercialVisitRequired__c, CloseDate,XC_CommercialVisitStarted__c FROM Opportunity];
        List<WorkOrder> woListWithOpp = new List<WorkOrder>();
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_CommercialVisit);
        for(Opportunity op: oppInserted2){
            for (WorkOrder wo : woList){
                wo.XC_Opportunity__c = op.Id; 
    
                woListWithOpp.add(wo);
            }
        }
        
        
        NE__Order__c order = XC_DF_Order.createOrder('Quote');
        order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        order.XC_Status__c = Label.XC_CL_Configuration_QuoteDraft ;
        order.NE__OptyId__c = oppInserted2[0].Id;
        order.XC_Country__c = 'Italy';
        order.XC_Segment__c='B2B';
        update order;
        List<NE__OrderItem__c> items = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: order.Id];
        items[0].XC_PaymentMethod__c=null;
        items[0].XC_IsAProduct__c = true;
        update items;
        XC_Voucher__c voucher = XC_DF_Voucher.generatePromotionalVoucher(1)[0];
        voucher.XC_Uses__c=10;
        voucher.XC_LegalEntity__c='EndesaX';
        voucher.RecordTypeId=Schema.SObjectType.XC_Voucher__c.getRecordTypeInfosByDeveloperName().get('XC_Voucher_General').getRecordTypeId();
        insert voucher;
        XC_Voucher__c voucherIns=[SELECT XC_VoucherCode__c FROM XC_Voucher__c LIMIT 1][0];
        NE__Order_Item_Attribute__c oia = XC_DF_OrderItemAttribute.createOrderItemAttribute(items[0],'Codigo cupon',voucherIns.XC_VoucherCode__c);
        oia.Name='Number of installments';
        oia.NE__Value__c = '12';
        insert oia;
        NE__Order_Item_Attribute__c oia1 = XC_DF_OrderItemAttribute.createOrderItemAttribute(items[0],'Codigo cupon',voucherIns.XC_VoucherCode__c);
        oia1.Name='Number of installments';
        oia1.NE__Value__c = '14';
        insert oia1;
        String orderId = order.Id;
        String recordId = oppInserted[0].Id; //Opportunity ID

        
        XC_UTIL_ResultWrapper wr =  new XC_UTIL_ResultWrapper();
        
        wr = XC_LCC044_OptyCheckBeforeNextStep.checkOptyCreation(orderId);
        String getVisual = XC_LCC044_OptyCheckBeforeNextStep.getVisualforceRelativeURL();
        items[0].XC_BillingModel__c = 'Installment Plan';
        items[0].XC_InstallmentsNumber__c='12';
        update items;
        
        XC_UTIL_Order.optyCheckBeforeNextWrapper optyCheckBeforeNextWrapper = XC_LCC044_OptyCheckBeforeNextStep.isInCommunity(orderId);
        Boolean community=optyCheckBeforeNextWrapper.isInCommunity;

        System.assert(!String.isBlank(getVisual));
        System.assertEquals(false,community);
        System.assert(true,wr.success);

        
        Test.stopTest();
    }
    
      @IsTest
    static void test2(){

        insert XC_DF_Lead.createResidentialLead();
        insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
        XC_ProductCategoryOfInterest__c prInserted = [SELECT Id, Name FROM XC_ProductCategoryOfInterest__c];
        insert XC_DF_ProductCategoryOfInterest.productSkillRequired(prInserted);
        insert XC_DF_Account.createResidentialAccounts(1);
        List<Account> accList = [SELECT Id FROM Account];
        insert XC_DF_Address.createAddress(accList);
        List<XC_Address__c> listAddress = [SELECT Id FROM XC_Address__c];
        insert XC_DF_Contact.createResidentialContacts(accList);
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        List<Opportunity> oppInserted = XC_DF_Opportunity.createOpportunityWithVisit(contactList,listAddress[0]);
        oppInserted[0].XC_CommercialVisitStarted__c = false;
        oppInserted[0].XC_CommercialVisitRequired__c = true;
        insert oppInserted;
        Test.startTest();
        List<Opportunity> oppInserted2 = [SELECT Id,XC_CommercialVisitRequired__c, CloseDate,XC_CommercialVisitStarted__c FROM Opportunity];
        List<WorkOrder> woListWithOpp = new List<WorkOrder>();
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_CommercialVisit);
        for(Opportunity op: oppInserted2){
            for (WorkOrder wo : woList){
                wo.XC_Opportunity__c = op.Id;

                woListWithOpp.add(wo);
            }
        }


        NE__Order__c order = XC_DF_Order.createOrder(Label.XC_CL_Configuration_TypeInOrder);
        order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        order.XC_Status__c = Label.XC_CL_Configuration_QuoteDraft ;
        order.NE__OptyId__c = oppInserted2[0].Id;
        order.NE__Recurring_Charge_Total__c = 0;
        order.NE__One_Time_Fee_Total__c = 0;
        update order;
        List<NE__OrderItem__c> items = [SELECT Id, NE__Recurring_Charge_Total__c, NE__One_Time_Fee_Total__c  FROM NE__OrderItem__c WHERE NE__OrderId__c =: order.Id];
        items[0].XC_PaymentMethod__c=null;
        items[0].XC_IsAProduct__c = true;
        items[0].NE__Recurring_Charge_Total__c = 0;
        items[0].NE__One_Time_Fee_Total__c = 0;

        update items;
        String orderId = order.Id;
        String recordId = oppInserted[0].Id; //Opportunity ID

        XC_UTIL_ResultWrapper wr =  new XC_UTIL_ResultWrapper();
        wr = XC_LCC044_OptyCheckBeforeNextStep.checkOrderCreation(orderId);


        //System.assert(wr.success);

        Test.stopTest();
    }

    @IsTest
    static void test3(){

        insert XC_DF_Lead.createResidentialLead();
        insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
        XC_ProductCategoryOfInterest__c prInserted = [SELECT Id, Name FROM XC_ProductCategoryOfInterest__c];
        insert XC_DF_ProductCategoryOfInterest.productSkillRequired(prInserted);
        insert XC_DF_Account.createResidentialAccounts(1);
        List<Account> accList = [SELECT Id FROM Account];
        insert XC_DF_Address.createAddress(accList);
        List<XC_Address__c> listAddress = [SELECT Id FROM XC_Address__c];
        insert XC_DF_Contact.createResidentialContacts(accList);
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        List<Opportunity> oppInserted = XC_DF_Opportunity.createOpportunityWithVisit(contactList,listAddress[0]);
        oppInserted[0].XC_CommercialVisitStarted__c = false;
        oppInserted[0].XC_CommercialVisitRequired__c = true;
        insert oppInserted;
        Test.startTest();
        List<Opportunity> oppInserted2 = [SELECT Id,XC_CommercialVisitRequired__c, CloseDate,XC_CommercialVisitStarted__c FROM Opportunity];
        List<WorkOrder> woListWithOpp = new List<WorkOrder>();
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_CommercialVisit);
        for(Opportunity op: oppInserted2){
            for (WorkOrder wo : woList){
                wo.XC_Opportunity__c = op.Id;

                woListWithOpp.add(wo);
            }
        }


        NE__Order__c order = XC_DF_Order.createOrder('Quote');
        order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        order.XC_Status__c = Label.XC_CL_Configuration_QuoteDraft ;
        order.NE__OptyId__c = oppInserted2[0].Id;
        order.NE__Recurring_Charge_Total__c = 0;
        order.NE__One_Time_Fee_Total__c = 0;
        update order;
        List<NE__OrderItem__c> items = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: order.Id];
        items[0].XC_PaymentMethod__c=null;
        items[0].XC_IsAProduct__c = true;
        update items;
        String orderId = order.Id;
        String recordId = oppInserted[0].Id; //Opportunity ID

        XC_UTIL_ResultWrapper wr =  new XC_UTIL_ResultWrapper();
        wr = XC_LCC044_OptyCheckBeforeNextStep.checkOrderCreation(orderId);


        //System.assertEquals(true,wr.success);

        Test.stopTest();
    }

    @isTest
    static void test4(){
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accList);
        insert conList;
        List<XC_Address__c> addresses = XC_DF_Address.createAddress(accList);
        insert addresses;
        List<Opportunity> optys = XC_DF_Opportunity.createOpportunityWithoutVisit(conList, addresses[0]);
        insert optys;
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        order.NE__OptyId__c = optys[0].Id;
        update order;

        Map<String,Object> paramsMap = new Map<String,Object>();
        paramsMap.put('phoneNumber','725758766');
        paramsMap.put('phonePrefix','+34');

        Test.startTest();
            XC_LCC044_OptyCheckBeforeNextStep.newPhone(order.Id, JSON.serialize(paramsMap));
        Test.stopTest();
    }

    @isTest
    static void test5(){
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accList);
        insert conList;
        List<XC_Address__c> addresses = XC_DF_Address.createAddress(accList);
        insert addresses;
        Opportunity opportunityToInsert = new Opportunity();
        opportunityToInsert.Name = 'OP00001';
        opportunityToInsert.XC_Contact__c = conList[0].Id;
        opportunityToInsert.AccountId = conList[0].AccountId;
        opportunityToInsert.XC_ProductCategoryOfInterest__c = 'Caldera';
        opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
        opportunityToInsert.StageName = 'Draft';
        opportunityToInsert.XC_Source__c = 'BLOG';
        opportunityToInsert.XC_ReceivingChannel__c = 'Web';
        opportunityToInsert.XC_Address__c = addresses[0].Id;
        opportunityToInsert.XC_LegalEntity__c = 'EndesaX';
        insert opportunityToInsert;

        //b2w objects
        NE__Family__c fam = new NE__Family__c(Name= 'Coupon',XC_LIC_Family_Name__c='Coupon');
        insert fam;
        NE__DynamicPropertyDefinition__c prop = new NE__DynamicPropertyDefinition__c(XC_LIC_DynamicPropertyDefinition__c  = 'Coupon code',Name='Coupon code');
        insert prop;
        NE__ProductFamilyProperty__c famProp = new NE__ProductFamilyProperty__c(NE__FamilyId__c = fam.Id,NE__PropId__c = prop.Id);
        insert famProp;
        List<NE__Product__c> product = XC_DF_Product.createProducts(1);
        product[0].XC_LIC_Product_Name__c = Label.XC_CL_CommercialProduct_Coupon;
        insert product[0];


        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'Order';
        order.NE__OptyId__c = opportunityToInsert.Id;
        order.NE__AccountId__c = opportunityToInsert.AccountId;
        order.XC_Country__c = 'Spain';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c ='EndesaX';
         order.NE__Configuration_Type__c =  Label.XC_CL_Configuration_TypeNew;
        insert order;
        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
        insert item;
        update order;


        NE__OrderItem__c oi = XC_DF_OrderItem.createOrderItem(order);
        insert oi;
        NE__OrderItem__c oiCoupon = XC_DF_OrderItem.createOrderItem(order);
        oiCoupon.NE__ProdId__c = product[0].Id;
        insert oiCoupon;

        XC_Voucher__c voucher = XC_DF_Voucher.generatePromotionalVoucher(1)[0];
        voucher.XC_Uses__c=10;
        voucher.XC_LegalEntity__c='EndesaX';
        voucher.RecordTypeId=Schema.SObjectType.XC_Voucher__c.getRecordTypeInfosByDeveloperName().get('XC_Voucher_General').getRecordTypeId();
        insert voucher;
        XC_Voucher__c voucherIns=[SELECT XC_VoucherCode__c FROM XC_Voucher__c LIMIT 1][0];
        NE__Order_Item_Attribute__c oia = XC_DF_OrderItemAttribute.createOrderItemAttribute(oiCoupon,'Codigo cupon',voucherIns.XC_VoucherCode__c);
        oia.NE__FamPropId__c = famProp.Id;
        insert oia;

        Test.startTest();
            XC_LCC044_OptyCheckBeforeNextStep.checkVoucherUtilization(order.Id);
        Test.stopTest();


    }

    @isTest
    static void test6(){
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accList);
        insert conList;
        List<XC_Address__c> addresses = XC_DF_Address.createAddress(accList);
        insert addresses;

        XC_ConsipLot__c newLot = new XC_ConsipLot__c();
        newLot.name = 'lot lot';
        newLot.XC_LotNumber__c = '8 (SL4)';
        newLot.XC_TotalAmount__c = 1000;
        insert newLot;

        Opportunity opportunityToInsert = new Opportunity();
        opportunityToInsert.Name = 'OP00001';
        opportunityToInsert.XC_Contact__c = conList[0].Id;
        opportunityToInsert.AccountId = conList[0].AccountId;
        //opportunityToInsert.XC_ProductCategoryOfInterest__c = 'B2G - Smart Lighting';
        opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
        opportunityToInsert.StageName = 'Draft';
        //opportunityToInsert.XC_Source__c = 'BLOG';
        opportunityToInsert.XC_ReceivingChannel__c = 'Web';
        opportunityToInsert.XC_Address__c = addresses[0].Id;
        opportunityToInsert.XC_LegalEntity__c = 'EnelSole';
        opportunityToInsert.XC_Segment__c = 'B2G';
        opportunityToInsert.XC_CreditCheck_GB__c = 'OK';
        //opportunityToInsert.XC_ModeOfEngagement__c = 'Consip 3';
        opportunityToInsert.XC_ConsipLot__c = newLot.Id;
        opportunityToInsert.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2G_Opportunity_Italy').getRecordTypeId();
        insert opportunityToInsert;
opportunityToInsert.XC_Segment__c = 'B2G';
        update opportunityToInsert;
        //b2w objects
        NE__Family__c fam = new NE__Family__c(Name= 'Coupon',XC_LIC_Family_Name__c='Coupon');
        insert fam;
        NE__DynamicPropertyDefinition__c prop = new NE__DynamicPropertyDefinition__c(XC_LIC_DynamicPropertyDefinition__c  = 'Coupon code',Name='Coupon code');
        insert prop;
        NE__ProductFamilyProperty__c famProp = new NE__ProductFamilyProperty__c(NE__FamilyId__c = fam.Id,NE__PropId__c = prop.Id);
        insert famProp;
        List<NE__Product__c> product = XC_DF_Product.createProducts(1);
        product[0].XC_LIC_Product_Name__c = Label.XC_CL_CommercialProduct_Coupon;
        insert product[0];


        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'Opty';
        order.NE__OptyId__c = opportunityToInsert.Id;
        order.NE__AccountId__c = opportunityToInsert.AccountId;
        order.XC_Country__c = 'Italy';
        order.XC_Segment__c = 'B2G';
        order.XC_LegalEntity__c ='EnelSole';
         order.NE__Configuration_Type__c =  Label.XC_CL_Configuration_TypeNew;
        insert order;

        Test.startTest();
            XC_LCC044_OptyCheckBeforeNextStep.checkOptyConsipStatus(order.Id);
        Test.stopTest();


    }
        @isTest
    static void test7(){
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accList);
        insert conList;
        List<XC_Address__c> addresses = XC_DF_Address.createAddress(accList);
        insert addresses;

        XC_ConsipLot__c newLot = new XC_ConsipLot__c();
        newLot.name = 'lot lot';
        newLot.XC_LotNumber__c = '8 (SL4)';
        newLot.XC_TotalAmount__c = 1000;
        insert newLot;

        Opportunity opportunityToInsert = new Opportunity();
        opportunityToInsert.Name = 'OP00001';
        opportunityToInsert.XC_Contact__c = conList[0].Id;
        opportunityToInsert.AccountId = conList[0].AccountId;
        //opportunityToInsert.XC_ProductCategoryOfInterest__c = 'B2G - Smart Lighting';
        opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
        opportunityToInsert.StageName = 'Draft';
        //opportunityToInsert.XC_Source__c = 'BLOG';
        opportunityToInsert.XC_ReceivingChannel__c = 'Web';
        opportunityToInsert.XC_Address__c = addresses[0].Id;
        opportunityToInsert.XC_LegalEntity__c = 'EnelSole';
        opportunityToInsert.XC_Segment__c = 'B2G';
        opportunityToInsert.XC_CreditCheck_GB__c = 'OK';
        //opportunityToInsert.XC_ModeOfEngagement__c = 'Consip 3';
        opportunityToInsert.XC_ConsipLot__c = newLot.Id;
        opportunityToInsert.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2G_Opportunity_Italy').getRecordTypeId();
        insert opportunityToInsert;
opportunityToInsert.XC_Segment__c = 'B2G';
        update opportunityToInsert;
        //b2w objects
        NE__Family__c fam = new NE__Family__c(Name= 'Coupon',XC_LIC_Family_Name__c='Coupon');
        insert fam;
        NE__DynamicPropertyDefinition__c prop = new NE__DynamicPropertyDefinition__c(XC_LIC_DynamicPropertyDefinition__c  = 'Coupon code',Name='Coupon code');
        insert prop;
        NE__ProductFamilyProperty__c famProp = new NE__ProductFamilyProperty__c(NE__FamilyId__c = fam.Id,NE__PropId__c = prop.Id);
        insert famProp;
        List<NE__Product__c> product = XC_DF_Product.createProducts(1);
        product[0].XC_LIC_Product_Name__c = Label.XC_CL_CommercialProduct_Coupon;
        insert product[0];


        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'Opty';
        //order.NE__OptyId__c = opportunityToInsert.Id;
        order.NE__AccountId__c = opportunityToInsert.AccountId;
        order.XC_Country__c = 'Italy';
        order.XC_Segment__c = 'B2G';
        order.XC_LegalEntity__c ='EnelSole';
         order.NE__Configuration_Type__c =  Label.XC_CL_Configuration_TypeNew;
        insert order;

        Test.startTest();
            XC_LCC044_OptyCheckBeforeNextStep.checkPhoneRequiredOnConfItem(order.Id);
        Test.stopTest();


    }
      @isTest
    static void test8(){
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accList);
        insert conList;
        List<XC_Address__c> addresses = XC_DF_Address.createAddress(accList);
        insert addresses;

        XC_ConsipLot__c newLot = new XC_ConsipLot__c();
        newLot.name = 'lot lot';
        newLot.XC_LotNumber__c = '8 (SL4)';
        newLot.XC_TotalAmount__c = 1000;
        insert newLot;

        Opportunity opportunityToInsert = new Opportunity();
        opportunityToInsert.Name = 'OP00001';
        opportunityToInsert.XC_Contact__c = conList[0].Id;
        opportunityToInsert.AccountId = conList[0].AccountId;
        //opportunityToInsert.XC_ProductCategoryOfInterest__c = 'B2G - Smart Lighting';
        opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
        opportunityToInsert.StageName = 'Draft';
        //opportunityToInsert.XC_Source__c = 'BLOG';
        opportunityToInsert.XC_ReceivingChannel__c = 'Web';
        opportunityToInsert.XC_Address__c = addresses[0].Id;
        opportunityToInsert.XC_LegalEntity__c = 'EnelSole';
        opportunityToInsert.XC_Segment__c = 'B2G';
        opportunityToInsert.XC_CreditCheck_GB__c = 'OK';
        //opportunityToInsert.XC_ModeOfEngagement__c = 'Consip 3';
        opportunityToInsert.XC_ConsipLot__c = newLot.Id;
        opportunityToInsert.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2G_Opportunity_Italy').getRecordTypeId();
        insert opportunityToInsert;
opportunityToInsert.XC_Segment__c = 'B2G';
        update opportunityToInsert;
        //b2w objects
        NE__Family__c fam = new NE__Family__c(Name= 'Coupon',XC_LIC_Family_Name__c='Coupon');
        insert fam;
        NE__DynamicPropertyDefinition__c prop = new NE__DynamicPropertyDefinition__c(XC_LIC_DynamicPropertyDefinition__c  = 'Coupon code',Name='Coupon code');
        insert prop;
        NE__ProductFamilyProperty__c famProp = new NE__ProductFamilyProperty__c(NE__FamilyId__c = fam.Id,NE__PropId__c = prop.Id);
        insert famProp;
        List<NE__Product__c> product = XC_DF_Product.createProducts(1);
        product[0].XC_LIC_Product_Name__c = Label.XC_CL_CommercialProduct_Coupon;
        insert product[0];


        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'Opty';
        //order.NE__OptyId__c = opportunityToInsert.Id;
        order.NE__AccountId__c = opportunityToInsert.AccountId;
        order.XC_Country__c = 'Italy';
        order.XC_Segment__c = 'B2G';
        order.XC_LegalEntity__c ='EnelSole';
         order.NE__Configuration_Type__c =  Label.XC_CL_Configuration_TypeNew;
        insert order;

        Test.startTest();
            XC_LCC044_OptyCheckBeforeNextStep.checkOrderCreation(order.Id);
        Test.stopTest();


    }

}