/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  12/08/2019 
* @description XC_TR_ConfigurationItem_U_CongaWF_TEST – Test class for XC_TR_ConfigurationItem_U_StartCongaWF
*/ 
@isTest
public class XC_TR_ConfigurationItem_U_CongaWF_TEST {
    @TestSetup
    static void insertRecords (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<NE__Product__c> productList = XC_DF_Product.createProducts(1);
        insert productList;
        APXTConga4__Conga_Template__c congaTrigger = new APXTConga4__Conga_Template__c();
        congaTrigger.APXTConga4__Name__c = 'Contrato Renting Andromeda Sin Energia1';
        congaTrigger.Country__c = 'SPAIN';
        insert congaTrigger;
        APXTConga4__Conga_Template__c congaTrigger2 = new APXTConga4__Conga_Template__c();
        congaTrigger2.APXTConga4__Name__c = 'Clausulado Contrato renting';
        congaTrigger2.Country__c = 'SPAIN';
        insert congaTrigger2;  
        APXTConga4__Conga_Template__c congaTrigger3 = new APXTConga4__Conga_Template__c();
        congaTrigger3.APXTConga4__Name__c = 'Contract SSI-One Shot';
        congaTrigger3.Country__c = 'SPAIN';
        insert congaTrigger3;
        APXTConga4__Conga_Template__c congaTrigger4 = new APXTConga4__Conga_Template__c();
        congaTrigger4.APXTConga4__Name__c = 'MODULO Incentivo e cessione credito';
        congaTrigger4.Country__c = 'Italy';
        insert congaTrigger4;                
        APXTConga4__Conga_Merge_Query__c congaQuery = new APXTConga4__Conga_Merge_Query__c();
        congaQuery.APXTConga4__Name__c = 'OrderItemInfo';
        insert congaQuery;
        List<NE__Billing_Profile__c>  billingProfileList = XC_DF_BillingProfile.createBillingProfile(2);
        List<NE__Billing_Profile__c>  updateBPList = new List<NE__Billing_Profile__c>();
        billingProfileList[0].NE__Payment__c  = Label.XC_CL_Credit_Card;
        billingProfileList[1].NE__Payment__c = Label.XC_CL_DirectDebt;
        updateBPList.add(billingProfileList[0]);
        updateBPList.add(billingProfileList[1]);
        update updateBPList;
        List<XC_BillingProfileLineItem__c> bpliList = new List<XC_BillingProfileLineItem__c>([SELECT Id FROM XC_BillingProfileLineItem__c]);
        for(XC_BillingProfileLineItem__c bpli : bpliList){
            bpli.XC_Status__c = 'Active';
        }
        update bpliList; 
        //List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(10);
        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'inOrder';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EndesaX';
        insert order;
        NE__OrderItem__c orItem = XC_DF_OrderItem.createOrderItem(order);
        //for(NE__OrderItem__c orItem : orderItems){
        orItem.XC_IsAProduct__c = true;
        orItem.XC_BillingModel__c = '3 years renting'; 
        orItem.XC_PaymentMethod__c  = Label.XC_CL_DirectDebt;
        orItem.XC_Product_Type__c  = Label.XC_CL_ProductTypeBundle;
        orItem.XC_Product_Subtype__c = Label.XC_CL_Boiler;
        orItem.NE__ProdId__c = productList[0].Id;
        //}
        insert orItem;
    }
    
    static testMethod void onUpdateBpli() {
        List<NE__OrderItem__c> orderlist = new List<NE__OrderItem__c>([SELECT Id, XC_LegalEntityFormula__c FROM NE__OrderItem__c ]);
        List<XC_BillingProfileLineItem__c> bpliList = new List<XC_BillingProfileLineItem__c>([SELECT Id FROM XC_BillingProfileLineItem__c WHERE XC_PaymentMethod__c =: Label.XC_CL_DirectDebt]); 
        Test.startTest();
        orderlist[0].XC_BillingProfileLineItem__c = bpliList[0].Id;
        update orderlist;
        Test.stopTest();
        System.assertEquals(1, orderlist.size());
    }
    
    static testMethod void onUpdateBillingModel() {
        List<NE__OrderItem__c> orderlist = new List<NE__OrderItem__c>([SELECT Id, XC_LegalEntityFormula__c FROM NE__OrderItem__c]);
        List<XC_BillingProfileLineItem__c> bpliList = new List<XC_BillingProfileLineItem__c>([SELECT Id FROM XC_BillingProfileLineItem__c WHERE XC_PaymentMethod__c =: Label.XC_CL_Credit_Card]);
        Test.startTest();
        orderlist[0].XC_BillingModel__c = Label.XC_CL_BillingModel_OneShot;
        orderlist[0].XC_PaymentMethod__c  = Label.XC_CL_Credit_Card;
        orderlist[0].XC_BillingProfileLineItem__c = bpliList[0].Id;
        update orderlist;
        Test.stopTest();
        System.assertEquals(1, orderlist.size());
    }
    
    static testMethod void onInsert() {
        List<NE__Product__c> prodList = new List<NE__Product__c>([SELECT Id FROM NE__Product__c LIMIT 1]);
        List<XC_BillingProfileLineItem__c> bpliList = new List<XC_BillingProfileLineItem__c>([SELECT Id FROM XC_BillingProfileLineItem__c WHERE XC_PaymentMethod__c =: Label.XC_CL_Credit_Card]);
        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'inOrder';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EnelXItalia';
        insert order;
        NE__OrderItem__c orItem = XC_DF_OrderItem.createOrderItem(order);
        //List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(1);
        //for(NE__OrderItem__c orItem : orderItems){
        orItem.XC_IsAProduct__c = true;
        orItem.XC_BillingModel__c = Label.XC_CL_BillingModel_OneShot; 
        orItem.XC_PaymentMethod__c  = Label.XC_CL_Credit_Card;
        orItem.XC_Product_Type__c  = Label.XC_CL_ProductTypeBundle;
        orItem.XC_Product_Subtype__c = Label.XC_CL_Boiler;
        orItem.XC_BillingProfileLineItem__c = bpliList[0].Id;
        orItem.NE__ProdId__c = prodList[0].Id;
        //}
        Test.startTest();
        insert orItem;
        Test.stopTest();
        //System.assertEquals(11, orderlist.size());
    }
    
    static testMethod void onPenalCheck() {
       	NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'inOrder';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EndesaX';
        insert order;
        
        List<NE__Product__c> productList = [SELECT Id FROM NE__Product__c LIMIT 1];
        List<XC_BillingProfileLineItem__c> bpliList = new List<XC_BillingProfileLineItem__c>([SELECT Id FROM XC_BillingProfileLineItem__c WHERE XC_PaymentMethod__c =: Label.XC_CL_DirectDebt]);
        List<NE__OrderItem__c> orderItems = new List<NE__OrderItem__c>();
        //List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(2);

        for(Integer i = 0; i < 2; i++){
            NE__OrderItem__c orItem = XC_DF_OrderItem.createOrderItem(order);
            orItem.XC_IsAProduct__c = true;
            orItem.XC_BillingModel__c = '3 years renting'; 
            orItem.XC_PaymentMethod__c  = Label.XC_CL_DirectDebt;
            orItem.XC_Product_Type__c  = Label.XC_CL_ProductTypeEquipment;
            orItem.XC_Product_Subtype__c = Label.XC_CL_Boiler;
            orItem.XC_BillingProfileLineItem__c = bpliList[0].Id;
            orItem.NE__ProdId__c = productList[0].Id;
            orderItems.add(orItem);
        }
        insert orderItems;
        orderItems[0].NE__Bundle_Configuration__c = orderItems[1].Id;
        orderItems[1].XC_BillingModel__c = 'One Shot';
        orderItems[1].XC_Product_Type__c  = Label.XC_CL_ProductTypeBundle;
        Test.startTest();
        update orderItems;
        Test.stopTest();
    }
    
    static testMethod void onUpdateCreditAssignment() {
        List<NE__OrderItem__c> orderItems = new List<NE__OrderItem__c>();
     	NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'inOrder';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EnelXItalia';
        insert order;
        
    	for(Integer i = 0; i < 2; i++){
            NE__OrderItem__c orItem = XC_DF_OrderItem.createOrderItem(order);
            orItem.XC_IsAProduct__c = true;
            orItem.XC_BillingModel__c = 'Recurring'; 
            orItem.XC_PaymentMethod__c  = 'Bank Transfer';
            orItem.XC_Product_Type__c  = Label.XC_CL_ProductTypeEquipment;
            orItem.XC_Product_Subtype__c = Label.XC_CL_ProductSubtypeIncentive;
            orItem.XC_CreditAssignmentAvailable__c = true;
            orItem.XC_CityCode__c = 'Test';
            orItem.XC_UrbanSection__c = 'Test';
            orItem.XC_Subordinate__c = 'Test';
            orItem.XC_HouseType__c = 'T-Catasto Terreni';
            orItem.XC_Sheet__c = 'Test';
            orderItems.add(orItem);
        }
        insert orderItems;
        
        orderItems[0].NE__Bundle_Configuration__c = orderItems[1].Id;
        orderItems[0].XC_Particle__c = 'Test';
        Test.startTest();
        update orderItems;
        Test.stopTest();
    }
    
 	static testMethod void onUpdateBillingModelPVItaly() {
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        for(NE__Order__c ord : orderList){
            ord.XC_LegalEntity__c = 'EnelXItalia';
            ord.NE__Type__c = Label.XC_CL_Configuration_TypeInOrder;
            ord.XC_CallType__c = 'Outbound Call';
        }
        update orderList;
        List<NE__OrderItem__c> orderItlist = new List<NE__OrderItem__c>([SELECT Id, XC_LegalEntityFormula__c FROM NE__OrderItem__c]);
        List<XC_BillingProfileLineItem__c> bpliList = new List<XC_BillingProfileLineItem__c>([SELECT Id FROM XC_BillingProfileLineItem__c WHERE XC_PaymentMethod__c =: Label.XC_CL_Credit_Card]);
        Test.startTest();
        orderItlist[0].XC_BillingModel__c = Label.XC_CL_BillingModel_OneShot;
        orderItlist[0].XC_PaymentMethod__c  = Label.XC_CL_Credit_Card;
        orderItlist[0].XC_BillingProfileLineItem__c = bpliList[0].Id;
        orderItlist[0].NE__OrderId__c = orderList[0].Id;
        orderItlist[0].XC_Product_Type__c  = Label.XC_CL_ProductTypeBundle;
        orderItlist[0].XC_Product_Subtype__c = Label.XC_CL_Subtype_Photovoltaic;
        update orderItlist;
        Test.stopTest();
        System.assertEquals(1, orderItlist.size());
    }
    
    
    static testMethod void onInsertCreditAssignment() {
        List<NE__OrderItem__c> orderItems = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> orderItlist = new List<NE__OrderItem__c>([SELECT Id, XC_LegalEntityFormula__c FROM NE__OrderItem__c LIMIT 1]);
     	NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'inOrder';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EnelXItalia';
        insert order;
       	for(Integer i = 0; i < 2; i++){
            NE__OrderItem__c orItem = XC_DF_OrderItem.createOrderItem(order);
            orItem.XC_IsAProduct__c = true;
            orItem.XC_BillingModel__c = 'Recurring'; 
            orItem.XC_PaymentMethod__c  = 'Bank Transfer';
            orItem.XC_Product_Type__c  = Label.XC_CL_ProductTypeEquipment;
            orItem.XC_Product_Subtype__c = Label.XC_CL_ProductSubtypeIncentive;
            orItem.XC_CreditAssignmentAvailable__c = true;
            orItem.XC_CityCode__c = 'Test';
            orItem.XC_UrbanSection__c = 'Test';
            orItem.XC_Subordinate__c = 'Test';
            orItem.XC_HouseType__c = 'T-Catasto Terreni';
            orItem.XC_Sheet__c = 'Test';
          	orItem.NE__Bundle_Configuration__c = orderItlist[0].Id;
        	orItem.XC_Particle__c = 'Test';
            orderItems.add(orItem);
        }
        Test.startTest();
        insert orderItems;
        Test.stopTest();
    }

    @isTest
    static void onUpdateCongaDynamicApi() {
        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'inOrder';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EnelXItalia';
        insert order;
        
        NE__OrderItem__c orItem = XC_DF_OrderItem.createOrderItem(order);
        XC_UTIL_Conga.UtilWrapper wrapper = new XC_UTIL_Conga.UtilWrapper();
        wrapper.templateId = 'Test';
        wrapper.congaQuery = 'Test';
        wrapper.fileName = Label.XC_CL_ContractValueForConga;
        wrapper.penaltyValue = 'test';
        wrapper.orderItemToBeUpdated = orItem;
        List<XC_UTIL_Conga.UtilWrapper> wrapperList = new List<XC_UTIL_Conga.UtilWrapper>();
        wrapperList.add(wrapper);
        XC_TR_ConfItem_U_StartCongaWF_PenalCheck.startingCongaWorkflowOnBundle(wrapperList);
    }

    @isTest
    static void getOrderInfoByCreditAssignmentTEST (){
    	List<NE__OrderItem__c> orderItems = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> orderItlist = new List<NE__OrderItem__c>([SELECT Id, XC_LegalEntityFormula__c FROM NE__OrderItem__c LIMIT 1]);
     	NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'inOrder';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EnelXItalia';
        insert order;
     	for(Integer i = 0; i < 2; i++){
            NE__OrderItem__c orItem = XC_DF_OrderItem.createOrderItem(order);
            orItem.XC_IsAProduct__c = true;
            orItem.XC_BillingModel__c = 'Recurring'; 
            orItem.XC_PaymentMethod__c  = 'Bank Transfer';
            orItem.XC_Product_Type__c  = Label.XC_CL_ProductTypeEquipment;
            orItem.XC_Product_Subtype__c = Label.XC_CL_ProductSubtypeIncentive;
            orItem.XC_CreditAssignmentAvailable__c = true;
            orItem.XC_CityCode__c = 'Test';
            orItem.XC_UrbanSection__c = 'Test';
            orItem.XC_Subordinate__c = 'Test';
            orItem.XC_HouseType__c = 'T-Catasto Terreni';
            orItem.XC_Sheet__c = 'Test';
          	orItem.NE__Bundle_Configuration__c = orderItlist[0].Id;
        	orItem.XC_Particle__c = 'Test';
            orderItems.add(orItem);
        }
        orderItems[0].NE__OrderId__c = orderItems[1].NE__OrderId__c;
        Test.startTest();
        insert orderItems;
        for (NE__OrderItem__c oi : orderItlist){
            oi.NE__OrderId__c = orderItems[0].NE__OrderId__c;
        }
        update orderItlist;
        XC_TR_ConfigurationItem_U_StartCongaWF.getOrderInfoByCreditAssignment(orderItems);
        Test.stopTest();
    }

    @isTest
    static void forChile (){
        Test.startTest();
       
		XC_TR_ConfItem_U_StartCongaWF_PenalCheck.forChile(new list<NE__OrderItem__c>());
        
        Test.stopTest();
    }
    
    @isTest
    static void populatePenaltyValueTEST(){
        List<NE__Matrix_Parameter__c> matrixParameterList = XC_DF_MatrixParameter.createMatrixParameter(1);
        NE__Matrix_Parameter__c matrixParameter= matrixParameterList[0];
        insert matrixParameter;
        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'inOrder';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EndesaX';
        insert order;
        
        List<NE__Product__c> productList = [SELECT Id FROM NE__Product__c LIMIT 1];
        List<NE__OrderItem__c> orderItems = new List<NE__OrderItem__c>();
        //List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(2);
        
        for(Integer i = 0; i < 2; i++){
            NE__OrderItem__c orItem = XC_DF_OrderItem.createOrderItem(order);
            orItem.XC_IsAProduct__c = true;
            orItem.XC_BillingModel__c = 'One Shot'; 
            orItem.XC_PaymentMethod__c  = Label.XC_CL_DirectDebt;
            orItem.XC_Product_Type__c  = Label.XC_CL_ProductTypeEquipment;
            orItem.XC_Product_Subtype__c = Label.XC_CL_Boiler;
            //orItem.XC_BillingProfileLineItem__c = bpliList[0].Id;
            orItem.NE__ProdId__c = productList[0].Id;
            orderItems.add(orItem);
        }
        insert orderItems;
		orderItems[0].NE__Bundle_Configuration__c = orderItems[1].Id;
        orderItems[0].NE__OrderId__c = order.Id;
        orderItems[1].XC_BillingModel__c = 'One Shot';
        orderItems[1].XC_Product_Type__c  = Label.XC_CL_ProductTypeBundle;
        orderItems[1].NE__OrderId__c = order.Id;
        update orderItems;
        NE__Matrix_Parameter_Row__c mpr = new NE__Matrix_Parameter_Row__c();
        mpr.Product_LIC_Name__c = orderItems[0].NE__ProdId__r.XC_LIC_Product_Name__c;
        mpr.XC_Payment_Model__c = orderItems[0].XC_BillingModel__c;
        mpr.XC_Region__c = orderItems[0].NE__OrderId__r.XC_InstallationAddress__r.XC_PricinRegion__c;
        mpr.NE__Start_Date__c = System.today().addDays(-5);
        mpr.XC_Offline_Name_01__c = 'Pen_Unistall';
        mpr.XC_Offline_Value_01__c = '100';
        mpr.XC_Rule_type__c = 'Pricing';
        mpr.NE__Matrix_Parameter__c = matrixParameter.Id;
        insert mpr;
        Test.startTest();
        List<NE__OrderItem__c> oiQueried = new List<NE__OrderItem__c>([SELECT Id,XC_LegalEntityFormula__c, NE__Bundle_Configuration__c,XC_BillingModel__c FROM NE__OrderItem__c]);
        XC_TR_ConfigurationItem_U_StartCongaWF.populatePenaltyValue(oiQueried, true);
        Test.stopTest();
    }
}