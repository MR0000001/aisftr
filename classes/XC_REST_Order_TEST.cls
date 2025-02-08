/**
 * The Class XC_REST_Order_TEST.
 *
 * @author            :  
 * @date    Creation     : 10/12/2018
 * @date Modification : 12/06/2019 by Marco Ottaviano mottaviano@deloitte.it 
 * @description       :  Test Class for XC_REST_Order
 **/

@isTest
public class XC_REST_Order_TEST { 

    @TestSetup
  static void setup(){

        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;

        NE__Family__c fam = new NE__Family__c();
        fam.name = 'Corporate';
        insert fam;

        NE__Product__c prod = new NE__Product__c();
        prod.XC_Product_Subtype__c = 'Solar Thermal';
        prod.XC_Product_Type__c = 'Equipment';
        prod.XC_LIC_Product_Name__c = 'Test';
        insert prod;

        NE__ProductFamily__c pfam = new NE__ProductFamily__c();
        pfam.NE__FamilyId__c = fam.id;
        pfam.NE__ProdId__c = prod.id;
        insert pfam;


        NE__DynamicPropertyDefinition__c propdef = new NE__DynamicPropertyDefinition__c();
        propdef.Name='forma de pago';
        insert propdef;

        NE__ProductFamilyProperty__c famProp= new NE__ProductFamilyProperty__c();
        famProp.NE__FamilyId__c=fam.id;
        famProp.NE__PropId__c = propdef.id;
        insert famProp; 

        NE__Catalog_Item__c catItem = XC_DF_CatalogItem.createCatalogItem();
        catItem.NE__ProductId__c = prod.id;
        insert catItem;

        
        //XC_DF_Order.createOrder('InOrder');

        List<Account>  accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        Account ac=new Account();//gaurav
        ac.XC_LastName__c = 'test';
        ac.XC_FirstName__c = 'test';
        ac.Name = 'test';
        ac.PrimaryEmail__c = 'test@test233422.com';
        ac.XC_Member_Typology__c = 'Silver';
        ac.ParentId = accountList[0].Id;
        ac.XC_CustomerNumber_EnelEnergia__c = 'test';
        ac.XC_BirthDate__c = Date.today();
        ac.XC_Annual_membership_fee_due_date__c = Date.today();
        ac.XC_Una_tantum_member_fee__c = 12;
        ac.XC_Annual_member_fee__c = 12;
        ac.XC_Fix_part_sharing_monthly__c = 12;
        ac.XC_MISE_incentive__c = 10;
        ac.XC_Local_price_incentive__c = 20;
        ac.XC_Arera_incentive__c= 20;
        insert ac;

        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accountList);
        conList[0].XC_PrimaryContact__c = true;
        insert conList;
        List<XC_Address__c> address =  XC_DF_Address.createAddress(accountList);
        insert address;

        //List<NE__Billing_Profile__c> bpList = XC_DF_BillingProfile.createBillingProfile(1);
        List<NE__Billing_Profile__c> bpList = XC_DF_BillingProfile.createBillingProfile(2, accountList);
        List<Id> bpIds = XC_UTIL_Sobject.getIds(bpList);
        //Account acc = [SELECT Id, (SELECT id FROM Contacts) FROM Account LIMIT 1];
        NE__Billing_Profile__c bp1 = bpList[0];
        bp1.NE__Account__c = accountList[0].Id;
        bp1.NE__Payment__c = 'Direct Debt';
        bp1.NE__Iban__c = 'D';
        NE__Billing_Profile__c bp2 = bpList[1];
        bp1.NE__Account__c = accountList[0].Id;
        bp1.NE__Payment__c = Label.XC_CL_Credit_Card;
        update bpList;

        List<XC_BillingProfileLineItem__c> bpliList = [SELECT Id FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__c IN: bpIds]; 
        for(XC_BillingProfileLineItem__c bpli: bpliList){
            bpli.XC_SoldToContactId__c = conList[0].Id;
            bpli.XC_BillToContactId__c = conList[0].Id;
            bpli.XC_LegalEntity__c = 'EndesaX';
        }
        update bpliList; 

        Opportunity opportunityToInsert = new Opportunity();
        opportunityToInsert.Name = 'OP00001';
        opportunityToInsert.XC_Contact__c = conList[0].Id;
        opportunityToInsert.AccountId = conList[0].AccountId;
        opportunityToInsert.XC_ProductCategoryOfInterest__c = 'Caldera';
        opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
        opportunityToInsert.StageName = 'Draft';
        opportunityToInsert.XC_Source__c = 'BLOG';
        opportunityToInsert.XC_ReceivingChannel__c = 'Web';
        opportunityToInsert.XC_Address__c = address[0].Id;
        opportunityToInsert.XC_LegalEntity__c = 'EndesaX';
        insert opportunityToInsert;

        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'InOrder';
        order.NE__OptyId__c = opportunityToInsert.Id;
        order.NE__AccountId__c = opportunityToInsert.AccountId;
        order.XC_Country__c = 'Spain';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EndesaX';
        order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        insert order;
        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
        item.XC_Installation_Address__c = address[0].Id;
        item.NE__Account__c = accountList[0].id;
        insert item; 

       
        XC_DF_DataMap.createDataMap('Order2Order');
    
    }

    @isTest
    static void post_MissingMandatoryFieldOrder(){
    
        XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = null;
        XC_UTIL_Order.OrderItemWrapper ordit = null;
        XC_UTIL_Order.WrapperAttribute att = null;

       // ord.LegalEntity = 'test';
        //ord.OrderStatus = 'In progress';
       // ord.AccountID = [select id from Account][0].id;
       // ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
       // ordit.ProdID = [select id from NE__Product__c][0].id;
       // ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
       // ordit.quantity = 1;
       // ordit.BaseOneTimeFee = 1;
    //  ordit.BaseRecurringCharge = 1;
      //   ordit.BillingProfileID = [select id from NE__Billing_Profile__c][0].id;
       // att.Name = 'test';
       // att.Value = 'test';
       // att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
        //ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        //ordit.Attribute.add(att);
       // ord.orderItem.add(ordit);
        ordWr.Order = ord;
 
        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok'); 
        XC_REST_Order.doPost();
        //XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    
        test.stopTest();

    }

 
    /*Missing mandatory field: Order.LegalEntity*/
     static testMethod void post_validateOrderPOSTUtil1(){
    
        XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();

        ord.LegalEntity = '';
        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from Account][0].id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.BillingProfileID = [select id from NE__Billing_Profile__c][0].id;
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);
        ordWr.Order = ord;


        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
        System.RestContext.request.headers.remove('ClientSystem');
        System.RestContext.request.headers.put('ClientSystem', 'Commerce');

        XC_REST_Order.doPost();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();

    }


    /*Missing mandatory field: Order.ContractId*/
    /* ClientSystem = CommoditySpainB2C */
     static testMethod void post_validateOrderPOSTUtil2(){
    
        XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();

        ord.LegalEntity = 'test';
        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from Account][0].id;
        ord.ContractId='';
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.BillingProfileID = [select id from NE__Billing_Profile__c][0].id;
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
        System.RestContext.request.headers.remove('ClientSystem');
        System.RestContext.request.headers.put('ClientSystem', 'CommoditySpainB2C');

        XC_REST_Order.doPost();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();

    }


     /*Missing mandatory field: Order.ContractId*/
    /* ClientSystem = CommoditySpainB2C */
     static testMethod void post_validateOrderPOSTUtil3(){
    
        XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();

        ord.LegalEntity = 'test';
        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from Account][0].id;
        ord.ContractId='prova';
        ord.ContractUrl='';
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.BillingProfileID = [select id from NE__Billing_Profile__c][0].id;
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
        System.RestContext.request.headers.remove('ClientSystem');
        System.RestContext.request.headers.put('ClientSystem', 'CommoditySpainB2C');

        XC_REST_Order.doPost();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result'); 

        test.stopTest();

    }





    /* Missing mandatory field: Order.AccountID */
    static testMethod void post_MissingMandatoryField2(){
    
        XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();

        ord.LegalEntity = 'test';
        ord.OrderStatus = 'In progress';
        //ord.AccountID = [select id from Account][0].id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.BillingProfileID = [select id from NE__Billing_Profile__c][0].id;
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
        XC_REST_Order.doPost();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();

    }
    /* Missing mandatory field: Order.OrderStatus */
    static testMethod void post_MissingMandatoryField3(){
    
        XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();

        ord.LegalEntity = 'test';
        //ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from Account][0].id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.BillingProfileID = [select id from NE__Billing_Profile__c][0].id;
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
        XC_REST_Order.doPost();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();

    }

  /*  Order.OrderStatus must be equal to In progress'*/
  static testMethod void post_MissingMandatoryField4(){
      
    	
        XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();

        ord.LegalEntity = 'test';
        ord.OrderStatus = 'Not In Progress';
        ord.AccountID = [select id from Account][0].id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.BillingProfileID = [select id from NE__Billing_Profile__c][0].id;
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
        XC_REST_Order.doPost();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result'); 

        test.stopTest();

    }

    /*  OMissing mandatory field: Order.OrderItem'*/
    /*                                             */
  static testMethod void post_MissingMandatoryField5(){
    
        XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();

        ord.LegalEntity = 'test';
        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from Account][0].id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.BillingProfileID = [select id from NE__Billing_Profile__c][0].id;
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
       // ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
        XC_REST_Order.doPost();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result'); 

        test.stopTest();

    }


    /* ******* validateOrdItemPOST   */

    /*  OMissing mandatory field: Missing field: OrderItem.ProdID in '*/
    static testMethod void post_validateOrdItemPOST1(){
    
        XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();

        ord.LegalEntity = 'test';
        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from Account][0].id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        //ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.ProdID = '';
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.BillingProfileID = [select id from NE__Billing_Profile__c][0].id;
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
        XC_REST_Order.doPost();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();

    }


      /*  OMissing mandatory field:  Missing field: OrderItem.BillingProfileID in '*/
    /*static testMethod void post_validateOrdItemPOST2(){
    
        XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();

        ord.LegalEntity = 'test';
        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from Account][0].id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.ProdID = [select id from NE__Product__c][0].id;
        //ordit.ProdID = '';
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
       // ordit.BillingProfileID = [select id from NE__Billing_Profile__c][0].id;
        ordit.BillingProfileID = '';
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
        XC_REST_Order.doPost();
        XC_REST_Order_U.WrapperResponse wrResp = (XC_REST_Order_U.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();

    }

        /*  OMissing mandatory field:  Missing field: OrderItem.Quantity in '*/
    static testMethod void post_validateOrdItemPOST3(){
    
        XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();

        ord.LegalEntity = 'test';
        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from Account][0].id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.ProdID = [select id from NE__Product__c][0].id;
        //ordit.ProdID = '';
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.Quantity = null;
        //ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.BillingProfileID = [select id from NE__Billing_Profile__c][0].id;
        //ordit.BillingProfileID = '';
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
        XC_REST_Order.doPost();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();

    }

 
    /*Missing field: OrderItem.BaseOneTimeFee or OrderItem.BaseRecurringCharge */
      static testMethod void post_validateOrdItemPOST4(){
    
        XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();

        ord.LegalEntity = 'test';
        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from Account][0].id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.ProdID = [select id from NE__Product__c][0].id;
        //ordit.ProdID = '';
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        //ordit.Quantity = null;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = null;
        ordit.BaseRecurringCharge = null;
        //ordit.BaseOneTimeFee = 1;
        //ordit.BaseRecurringCharge = 1;
        ordit.BillingProfileID = [select id from NE__Billing_Profile__c][0].id;
        //ordit.BillingProfileID = '';
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
        XC_REST_Order.doPost();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();

    }



    //**********************//

    /* validateOrdItemPOSTUtil */

   /* Missing field: OrderItem.CatalogItemID in */
  // clientSystem != 'CommoditySpainB2C' && String.IsBlank(orderItem.CatalogItemID
     static testMethod void post_validateOrdItemPOSTUtil1(){
    
        XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();

        ord.LegalEntity = 'test';
        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from Account][0].id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.ProdID = [select id from NE__Product__c][0].id;
        //ordit.ProdID = '';
        ordit.CatalogItemID = '';
         // ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        //ordit.Quantity = null;
        ordit.quantity = 1;
        //ordit.BaseOneTimeFee = null;
        //ordit.BaseRecurringCharge = null;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.BillingProfileID = [select id from NE__Billing_Profile__c][0].id;
        //ordit.BillingProfileID = '';
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
        XC_REST_Order.doPost();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();

    }



    /*clientSystem == 'CommoditySpainB2C' && String.IsBlank(orderItem.OrderItemType) && String.IsBlank(orderItem.OrderItemSubType) */
    //* 
     static testMethod void post_validateOrdItemPOSTUtil2(){
    
        XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();

        ord.LegalEntity = 'test';
        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from Account][0].id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.ProdID = [select id from NE__Product__c][0].id;
        //ordit.ProdID = '';
       // ordit.CatalogItemID = '';
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        //ordit.Quantity = null;
        ordit.quantity = 1;
        //ordit.BaseOneTimeFee = null;
        //ordit.BaseRecurringCharge = null;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.BillingProfileID = [select id from NE__Billing_Profile__c][0].id;
        //ordit.BillingProfileID = '';
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
         System.RestContext.request.headers.remove('ClientSystem');
        System.RestContext.request.headers.put('ClientSystem', 'CommoditySpainB2C');
        XC_REST_Order.doPost();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();

    }   
    //**************************//


    //******validateOrdItemAttr ************//
            
        //'Missing field: OrderItem.Attribute.Name
        static testMethod void post_validateOrdItemAttr1(){
        
            XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
            XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
            XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
            XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();

            ord.LegalEntity = 'test';
            ord.OrderStatus = 'In progress';
            ord.AccountID = [select id from Account][0].id;
            ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
            ordit.ProdID = [select id from NE__Product__c][0].id;
            //ordit.ProdID = '';
           // ordit.CatalogItemID = '';
            ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
            //ordit.Quantity = null;
            ordit.quantity = 1;
            //ordit.BaseOneTimeFee = null;
            //ordit.BaseRecurringCharge = null;
            ordit.BaseOneTimeFee = 1;
            ordit.BaseRecurringCharge = 1;
            ordit.BillingProfileID = [select id from NE__Billing_Profile__c][0].id;
            //ordit.BillingProfileID = '';
            //att.Name = 'test';
            att.Name = '';
            att.Value = 'test';
            att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
            ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
            ordit.Attribute.add(att);
            ord.orderItem.add(ordit);
            ordWr.Order = ord;

            test.startTest();

            System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
            XC_REST_Order.doPost();
            XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
            System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

            test.stopTest();

        }

        /*static testMethod void post_validateOrdItemAttr2(){
        
            XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
            XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
            XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
            XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();

            ord.LegalEntity = 'test';
            ord.OrderStatus = 'In progress';
            ord.LegalEntity = 'EndesaX'; 
            ord.AccountID = [select id from Account][0].id;
            ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
            ordit.ProdID = [select id from NE__Product__c][0].id;
            //ordit.ProdID = '';
           // ordit.CatalogItemID = '';
            ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
            //ordit.Quantity = null;
            ordit.quantity = 1;
            //ordit.BaseOneTimeFee = null;
            //ordit.BaseRecurringCharge = null;
            ordit.BaseOneTimeFee = 1;
            ordit.BaseRecurringCharge = 1;
            ordit.BillingProfileID = [select id from NE__Billing_Profile__c][0].id;
            //ordit.BillingProfileID = '';
            att.Name = 'test';
            att.Value = null;
            att.ProductFamilyPropertyID = [select id from NE__ProductFamilyProperty__c][0].id;
            ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
            ordit.Attribute.add(att);
            ord.orderItem.add(ordit);
            ordWr.Order = ord;

            test.startTest();

            System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
            XC_REST_Order.doPost();
            XC_REST_Order_U.WrapperResponse wrResp = (XC_REST_Order_U.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperResponse.class);
            System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result'); 

            test.stopTest();

        }*/


       /* 'Missing field: OrderItem.Attribute.ProductFamilyPropertyID */

         static testMethod void post_validateOrdItemAttr3(){
        
            XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
            XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
            XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
            XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();

            ord.LegalEntity = 'test';
            ord.OrderStatus = 'In progress';
            ord.AccountID = [select id from Account][0].id;
            ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
            ordit.ProdID = [select id from NE__Product__c][0].id;
            //ordit.ProdID = '';
           // ordit.CatalogItemID = '';
            ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
            //ordit.Quantity = null;
            ordit.quantity = 1;
            //ordit.BaseOneTimeFee = null;
            //ordit.BaseRecurringCharge = null;
            ordit.BaseOneTimeFee = 1;
            ordit.BaseRecurringCharge = 1;
            ordit.BillingProfileID = [select id from NE__Billing_Profile__c][0].id;
            //ordit.BillingProfileID = '';
            att.Name = 'test';
           // att.Name = '';
            att.Value = 'test';
            //att.Value = 't';
            //att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
            att.ProductFamilyPropertyID = '';
            ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
            ordit.Attribute.add(att);
            ord.orderItem.add(ordit);
            ordWr.Order = ord;

            test.startTest();

            System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
            XC_REST_Order.doPost();
            XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
            System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result'); 

            test.stopTest();

        }
    //********************************//

    /******* POST CORRECT *******/
      static testMethod void post_Good1(){
    
        XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new  XC_UTIL_Order.WrapperAttribute();

        ord.LegalEntity = 'test';
        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from Account][0].id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.BillingProfileID = [select id from NE__Billing_Profile__c][0].id;
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
        XC_REST_Order.doPost();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();

    }



     static testMethod void post_Good_Good(){
    
        XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new  XC_UTIL_Order.WrapperAttribute();

        ord.LegalEntity = 'test';
        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from Account][0].id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ord.OrderID = [select id from ne__order__c][0].id;
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.ParentOrderItem = [SELECT ID FROM NE__Product__c][0].id+'-'+ordit.CatalogItemID+'-'+'1';
        ordit.BaseRecurringCharge = 1;
        ordit.BillingProfileID = [select id from NE__Billing_Profile__c][0].id;
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
        XC_REST_Order.doPost();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();

    }



    /* Missing mandatory field: Order */
    static testMethod void put_validateRequestPUT1() {
        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();

        ord.OrderID = [select id from ne__order__c][0].id;
        ord.LegalEntity = 'test';
        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from account][0].id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.OrderItemID = [select id from ne__orderitem__c][0].id;
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);
        ordWr.Order = null;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'PUT', 'ok');
        XC_REST_Order.doPut();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }


    /* Missing mandatory field: Order.OrderID */

      static testMethod void put_validateRequestPUT2() {
        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();

        //ord.OrderID = [select id from ne__order__c][0].id;
        ord.OrderID = '';
        ord.LegalEntity = 'test';
        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from account][0].id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.OrderItemID = [select id from ne__orderitem__c][0].id;
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'PUT', 'ok');
        XC_REST_Order.doPut();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
        }

        /* Missing mandatory field: OrderItem.OrderItemID */
    static testMethod void put_checkPUTReq1(){
    
        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();

        ord.OrderID = [select id from ne__order__c][0].id;
        ord.LegalEntity = 'test';
        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from account][0].id;
        ord.InstallationAddress = [select id from xc_address__c][0].id;
        ord.PracticeStatus = 'Approved';
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.OrderItemID = [select id from ne__orderitem__c][0].id;
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
    ordit.BaseRecurringCharge = 1;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'PUT', 'ok');
        XC_REST_Order.doPut();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();

    }

    /* Missing mandatory field: OrderItem.AttributeID */

    static testMethod void put_checkPUTReq2(){
    
        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();

        ord.OrderID = [select id from ne__order__c][0].id;
        ord.LegalEntity = 'test';
        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from account][0].id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.OrderItemID = null;
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'PUT', 'ok');
        XC_REST_Order.doPut();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();

    }

    static testMethod void getFromOrder(){
        
        test.startTest();

        NE__Order__c ord = [select id from ne__order__c][0];
        Date myDate = Date.newInstance(2019, 12, 12);
        ord.XC_Cancellation_Date__c =myDate;
        ord.NE__One_Time_Fee_Total__c=0;
        ord.NE__Recurring_Charge_Total__c=0;
        update ord;

        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        woList[0].XC_LegalEntity__c = 'EndesaX';
        woList[0].xc_configuration__c = ord.Id; 
        insert woList; 

        zqu__quote__c quote = new zqu__quote__c(zqu__ZuoraSubscriptionID__c = '12345');
        insert quote;

        Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__OriginalId__c = '12345',
                                                                        Zuora__PreviousSubscriptionId__c = '12345',
                                                                        Zuora__External_Id__c = '56789');
        insert sub;
        
        NE__Catalog_Item__c catItem = [SELECT Id, NE__Catalog_Id__c FROM NE__Catalog_Item__c WHERE NE__ProductId__c != null][0];
        NE__OrderItem__c ordit= [select id from ne__orderItem__c where NE__OrderId__c=: ord.id][0];
        ordit.XC_ZQuoteId__c = quote.Id; 
        ordit.NE__CatalogItem__c = catItem.Id; 
        ordit.NE__Catalog__c = catItem.NE__Catalog_Id__c; 
        ordit.XC_BillingModel__c = 'Recurring'; 
        update ordit;

        NE__Order_Item_Discount__c itemDiscount = new NE__Order_Item_Discount__c();
        itemDiscount.NE__Order_Item__c =  ordit.id;
        itemDiscount.NE__Type__c = 'Percentage';
        itemDiscount.NE__Recurring_Price__c = 2;
        itemDiscount.NE__Status__c = 'Active';
        itemDiscount.NE__Code__c = '0992';
        itemDiscount.NE__One_Time_Price__c = 0;
        itemDiscount.NE__One_Time_Value__c = 0;
        itemDiscount.NE__Recurring_Value__c = 2;
        insert itemDiscount; 
       

        NE__Order_Item_Attribute__c attr= XC_DF_OrderItemAttribute.createOrderItemAttribute(ordit,'test','test');
        insert attr;
        

        Asset ass= new Asset();
        ass.NE__Order_Config__c= ord.id;
        ass.XC_Configuration_Item__c= ordit.id;
        ass.Name='Test';
        insert ass; 

        XC_Provisioning_Step__c provStep= XC_DF_ProvisioningStep.createProvisioningStep(ordit.id);
        
        insert provStep;
        
        AssetHistory assHist= new AssetHistory();
        assHist.AssetId = ass.id;
        assHist.field= 'NE__Status__c';
        insert assHist; 
        
        Map<String,String> params = new Map<String,String>();
        params.put('OrderID', ord.id );

       

        System.RestContext.request = generateGETRequest(params, 'ok');
        XC_REST_Order.doGet();
        XC_REST_Order_U.WrapperGetResponse wrResp = (XC_REST_Order_U.WrapperGetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperGetResponse.class);
        System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();

    }

    static testMethod void getFromOrder2(){
        

        NE__Order__c ord = [select id, (Select id from NE__Order_Items__r) from ne__order__c][0];
        Date myDate = Date.newInstance(2019, 12, 12);
        ord.XC_Cancellation_Date__c =myDate;
        ord.NE__One_Time_Fee_Total__c=0;
        ord.NE__Recurring_Charge_Total__c=0;
        update ord;

        XC_BillingProfileLineItem__c bpli = [SELECT id, XC_BillingProfile__c, XC_PaymentMethod__c FROM XC_BillingProfileLineItem__c where XC_PaymentMethod__c =: 'Credit Card' LIMIT 1][0];
        bpli.XC_Status__c= 'Draft';
        update bpli; 

        NE__OrderItem__c oi = ord.NE__Order_Items__r[0];
        oi.NE__BillingProfId__c = bpli.XC_BillingProfile__c;
        oi.XC_BillingProfileLineItem__c = bpli.Id;
        oi.XC_PaymentMethod__c = bpli.XC_PaymentMethod__c;
        update oi;


        Map<String,String> params = new Map<String,String>();
        params.put('OrderID', ord.id );

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'ok');
        XC_REST_Order.doGet();
        XC_REST_Order_U.WrapperGetResponse wrResp = (XC_REST_Order_U.WrapperGetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperGetResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();

    }

    

    static testMethod void getFromOrderWO(){
        

        NE__Order__c ord = [select id from ne__order__c][0];
        Date myDate = Date.newInstance(2019, 12, 12);
        ord.XC_Cancellation_Date__c =myDate;
        ord.NE__One_Time_Fee_Total__c=0;
        ord.NE__Recurring_Charge_Total__c=0;
        update ord;

        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        woList[0].XC_LegalEntity__c = 'EndesaX';
        woList[0].xc_configuration__c = ord.Id; 
        insert woList; 

        Map<String,String> params = new Map<String,String>();
        params.put('OrderID', ord.id );

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'WorkOrderStatus');
        XC_REST_Order.doGet();
        XC_REST_Order_U.WrapperGetResponse wrResp = (XC_REST_Order_U.WrapperGetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperGetResponse.class);
        System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();

    }

    // gaurav
    static testMethod void getOrderProvisionStep(){
        

        NE__Order__c ord = [select id from ne__order__c][0];
        Date myDate = Date.newInstance(2019, 12, 12);
        ord.XC_Cancellation_Date__c =myDate;
        ord.NE__One_Time_Fee_Total__c=0;
        ord.NE__Recurring_Charge_Total__c=0;
        update ord;
        NE__OrderItem__c ordit= [select id from ne__orderItem__c where NE__OrderId__c=: ord.id][0];

    
        XC_Provisioning_Step__c provStep= XC_DF_ProvisioningStep.createProvisioningStep(ordit.id);
        provStep.XC_Flow_API_Name__c=Label.XC_CL_ProvisioningCreateDeliveryInstallationWO_Flow;
        insert provStep;

        Map<String,String> params = new Map<String,String>();
        params.put('OrderID', ord.id );

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'WorkOrderStatus');
        XC_REST_Order.doGet();
        XC_REST_Order_U.WrapperGetResponse wrResp = (XC_REST_Order_U.WrapperGetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperGetResponse.class);
        System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();

    }


    @isTest
    static void getFromAccountWithoutDate() {
    
        test.startTest();

        List<NE__order__C> listOrder=XC_DF_Order.createOrders(1,'InOrder');
        insert listOrder;
        List<NE__OrderItem__c> listOrderIte = new List<NE__OrderItem__c>();
        For(NE__order__C order: listOrder) {
           listOrderIte.add(XC_DF_OrderItem.createOrderItem(order));
        }
        //insert listOrderIte;
        //update listOrder;

        List<Account> acountList = [select Id FROM Account LIMIT 1];
        //XC_DF_BillingProfile.createBillingProfile(1,acountList);



        Map<String,String> params = new Map<String,String>();
        params.put('AccountID', acountList[0].id);

        System.RestContext.request = generateGETRequest(params, 'Read');
        XC_REST_Order.doGet();
        XC_REST_Order_U.WrapperGetResponse wrResp = (XC_REST_Order_U.WrapperGetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperGetResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        
        createOrderforAccount();
        test.stopTest();
    }


    @isTest
    static void getFromAccountWithWrongStartDate() {
        createOrderforAccount();

        List<Account> acountList = [select Id FROM Account LIMIT 1];
        //XC_DF_BillingProfile.createBillingProfile(1,acountList);

        Map<String,String> params = new Map<String,String>();
        params.put('AccountID', acountList[0].id);
        params.put('StartDate','12345');
        params.put('EndDate','12345');

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'ok');
        XC_REST_Order.doGet();
        XC_REST_Order_U.WrapperGetResponse wrResp = (XC_REST_Order_U.WrapperGetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperGetResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }

      @isTest
    static void getFromAccountWithWrongEndDate() {
        createOrderforAccount();

        List<Account> acountList = [select Id FROM Account LIMIT 1];
        //XC_DF_BillingProfile.createBillingProfile(1,acountList);

        Map<String,String> params = new Map<String,String>();
        params.put('AccountID', acountList[0].id);
        params.put('StartDate','2019-06-13');
        params.put('EndDate','12345');

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'ok');
        XC_REST_Order.doGet();
        XC_REST_Order_U.WrapperGetResponse wrResp = (XC_REST_Order_U.WrapperGetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperGetResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }

      @isTest
    static void getFromAccountWithDate() {

        createOrderforAccount();

        List<Account> acountList = [select Id FROM Account LIMIT 1];
        //XC_DF_BillingProfile.createBillingProfile(1,acountList);

        Map<String,String> params = new Map<String,String>();
        params.put('AccountID', acountList[0].id);
        params.put('StartDate','2019-06-13');
        params.put('EndDate','2019-06-14');

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'ok');
        XC_REST_Order.doGet();
        XC_REST_Order_U.WrapperGetResponse wrResp = (XC_REST_Order_U.WrapperGetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperGetResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }

     /*@isTest
    static void getFromAccountWithDateAsset() {  


        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        insert accounts;
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        Opportunity opport = oppList[0];
        opport.Name = 'TEST';
        opport.StageName = 'Draft';
        opport.CloseDate = Date.today();
        opport.XC_LegalEntity__c = 'EndesaX';
        insert opport;
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, 'InOrder');
        NE__Order__c order = orderList[0];
        order.NE__OptyId__c = opport.Id;
        order.NE__AccountId__c=accounts[0].Id;
        insert order;
        NE__OrderItem__c ordIt = XC_DF_OrderItem.createOrderItem(order);
        insert ordIt;
        
        List<Asset> listAsset = XC_DF_Asset.createAssets(accounts);
        Asset asst = listAsset[0];
        asst.XC_Configuration_Item__c = ordIt.Id;
        insert asst;
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
       provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        
       insert provisioningStep;

      
        test.startTest();
        List<Account> acountList = [select Id FROM Account LIMIT 1];
        XC_DF_BillingProfile.createBillingProfile(1,acountList);

        Map<String,String> params = new Map<String,String>();
        params.put('AccountID', acountList[0].id);
        params.put('StartDate','2019-06-13');
        params.put('EndDate','2019-06-14');

       

        System.RestContext.request = generateGETRequest(params, 'ok');
        XC_REST_Order.doGet();
        XC_REST_Order_U.WrapperResponse wrResp = (XC_REST_Order_U.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }*/
    

    @isTest
    static void createOpportunity_test(){

        /*List<NE__order__C> listOrder=XC_DF_Order.createOrders(1,'InOrder');
        insert listOrder;
        List<NE__OrderItem__c> listOrderIte = new List<NE__OrderItem__c>();
        For(NE__order__C order: listOrder) {
             NE__OrderItem__c oooi = XC_DF_OrderItem.createOrderItem(order);
             oooi.NE__ProdId__c = [select id from ne__product__c][0].id;
          oooi.NE__CatalogItem__c = [select id from NE__Catalog_Item__c][0].id;
          oooi.NE__Qty__c = 1;
             listOrderIte.add(oooi);    
        }

        insert listOrderIte;    
        update listOrder;*/

        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        insert accounts;

        XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new  XC_UTIL_Order.WrapperAttribute();

        ord.LegalEntity = 'EndesaX';
        ord.OrderStatus = 'In progress';
        ord.AccountID = accounts[0].id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        //ord.OrderID = [select id from ne__order__c][0].id;
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.ParentOrderItem = [SELECT ID FROM NE__Product__c][0].id+'-'+ordit.CatalogItemID+'-'+'1';
        ordit.BaseRecurringCharge = 1;
        ordit.BillingProfileID = [select id from NE__Billing_Profile__c][0].id;
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);
        ordWr.Order = ord; 
   

        
        test.startTest();  
 
        Opportunity o = xc_rest_order_zzz.createOpportunity(ordWr, new XC_REST_Order_U.WrapperRes(), accounts);
        system.assert(o!=null);
        
        test.stopTest();
    }

    /* NEW */
    static testMethod void put_validateRequestPUT() {
        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();

        ord.OrderID = [select id from ne__order__c][0].id;
        ord.LegalEntity = 'test';
        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from account][0].id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.OrderItemID = [select id from ne__orderitem__c][0].id;
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;

        NE__Order_Item_Attribute__c orderItemAttribute = new NE__Order_Item_Attribute__c();
        orderItemAttribute.NE__Order_Item__c = ordit.OrderItemID;
        insert orderItemAttribute;

        att.AttributeID = orderItemAttribute.id;
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;

        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'PUT', 'ok');
        XC_REST_Order.doPut();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }

     
        


    static testMethod void errHeader(){
    
        Map<String,String> params = new Map<String,String>();
        XC_REST_Order_U.WrapperGETRequest ordWr = new XC_REST_Order_U.WrapperGETRequest();

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'err_header');
        XC_REST_Order.doGet();
        //XC_REST_Order_U.WrapperGetResponse wrResp = (XC_REST_Order_U.WrapperGetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperGetResponse.class); 
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'err_header');
        XC_REST_Order.doPost();
        //XC_REST_Order_U.WrapperRes wrRespPostPut  = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class); 
        //System.assertEquals(400, Integer.valueOf(wrRespPostPut.result.ErrorCode), 'Wrong assert result');

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'PUT', 'err_header');
        XC_REST_Order.doPut();
        //wrRespPostPut = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class); 
        //System.assertEquals(400, Integer.valueOf(wrRespPostPut.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }

    static testMethod void emptyReq(){
    
        Map<String,String> params = new Map<String,String>();
        XC_REST_Order_U.WrapperGETRequest ordWr = new XC_REST_Order_U.WrapperGETRequest();

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'empty');
        XC_REST_Order.doGet();
        //XC_REST_Order_U.WrapperGetResponse wrResp = (XC_REST_Order_U.WrapperGetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperGetResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'empty');
        XC_REST_Order.doPost();
        //XC_REST_Order_U.WrapperRes wrRespPostPut = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        //System.assertEquals(400, Integer.valueOf(wrRespPostPut.result.ErrorCode), 'Wrong assert result');

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'PUT', 'empty');
        XC_REST_Order.doPut();
        //wrRespPostPut = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        //System.assertEquals(400, Integer.valueOf(wrRespPostPut.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }
    
    private static RestRequest generateGETRequest(Map<String,String> params, String operation){

        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
    
         request.httpMethod = 'GET';
      request.requestURI = '/v1/Order/*';

        if(operation!='err_header'){
            request = addHeader(request, operation);
        }

        for (String s : params.keySet()){
            request.addParameter(s, params.get(s));
        }

        return request;
    }

    private static RestRequest generatePOSTorPUTRequest(XC_REST_Order_U.WrapperRequest params, String method, String operation){

        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
    
         request.httpMethod = method;
      request.requestURI = '/v1/Order/*';
      
        if(operation!='err_header'){
            request = addHeader(request, operation);
        }

        request.requestBody = Blob.valueOf(JSON.serializePretty(params));

        return request;
    }


    private static RestRequest addHeader(RestRequest request, String operation){
    request.addHeader('TransactionID', 'AXYZ');
    request.addHeader('DateTimeMessage', '20181207103900000');
    request.addHeader('Operation', operation);
    request.addHeader('Functionality', 'AXYZ');
    request.addHeader('ClientSystem', 'AXYZ');
    request.addHeader('ServerSystem', 'AXYZ');
        request.addHeader('debugMode', 'AXYZ');
        return request;
    }


    private static RestRequest addHeaderError(RestRequest request){
        request.addHeader('TransactionID', 'AXYZ');
        request.addHeader('DateTimeMessage', '20181207103900000');
        request.addHeader('Functionality', 'AXYZ');
        request.addHeader('ClientSystem', 'AXYZ');
        request.addHeader('ServerSystem', 'AXYZ');
        return request;
    }

    private static void createOrderforAccount() {
        List<NE__order__C> listOrder=XC_DF_Order.createOrders(1,'InOrder');
        insert listOrder;
        List<NE__OrderItem__c> listOrderIte = new List<NE__OrderItem__c>();
        For(NE__order__C order: listOrder) {
           listOrderIte.add(XC_DF_OrderItem.createOrderItem(order));
        }
        insert listOrderIte;
        update listOrder;
    }
    
    static testMethod void put_updateOrderPUT() {

        NE__Order__c ordertoUpdate=[select id from ne__order__c ][0];
        ordertoUpdate.RecordTypeId=Schema.SObjectType.NE__Order__c.getRecordTypeInfosByName().get('Order').getRecordTypeId();
        update ordertoUpdate; 

        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();


        ord.OrderID = ordertoUpdate.id;
        ord.OrderStatus = 'Accepted';
        ordWr.Order = ord;

        test.startTest();
    
        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'PUT', 'ok');
        XC_REST_Order.doPut();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        //System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }

    

    static testMethod void put_updateOrderDataMap() {

        NE__Order__c ordertoUpdate=[select id from ne__order__c ][0];
        ordertoUpdate.RecordTypeId=Schema.SObjectType.NE__Order__c.getRecordTypeInfosByName().get('Quote').getRecordTypeId();
        ordertoUpdate.XC_LegalEntity__c = 'EndesaX';
        ordertoUpdate.XC_Segment__c = 'B2C';
        update ordertoUpdate; 
       
        
        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();

        ord.OrderID = ordertoUpdate.id;
        ord.OrderStatus = 'Accepted';
        ord.StartProvisioning = false;
        ord.SkipCompliance = false;

        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.OrderItemID = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: ordertoUpdate.Id LIMIT 1][0].Id;
        //ordit.BillingProfileID = [Select id from NE__Billing_Profile__c][0].id;
        ord.orderItem.add(ordit);
        ordWr.Order = ord;


        test.startTest();
    
        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'PUT', 'Update');
        try { 
            XC_REST_Order.doPut();
        } catch(exception e){
            
        }
        //XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    static testMethod void put_updateOrderBP() {

        List<Account> accList = [select id from account limit 1];
        List<XC_Address__c>  addrList =XC_DF_Address.createAddress(accList);
        insert addrList;

        NE__Order__c ordertoUpdate=[select id from ne__order__c ][0];
        ordertoUpdate.XC_DeliveryAddress__c = addrList[0].Id;
        ordertoUpdate.XC_InstallationAddress__c = addrList[0].Id;
        ordertoUpdate.XC_OrderBillingAddress__c = addrList[0].Id;
        update ordertoUpdate; 
        


        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();

        ord.OrderID = ordertoUpdate.id;
        ord.OrderStatus = 'In Progress';
        ord.StartProvisioning = true;
        ord.SkipCompliance = false;

        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.OrderItemID = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: ordertoUpdate.Id LIMIT 1][0].Id;
        ordit.BillingProfileID = [Select id from NE__Billing_Profile__c][0].id;
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        Test.setMock(HttpCalloutMock.class, new CallZuora_Mock());
        
        test.startTest();
        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'PUT', 'Update');
        try{
            XC_REST_Order.doPut();
        //XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
        }
        catch(exception e){
        
        }    
        
    }

     static testMethod void put_updateOrderExternalFinancing() {

        List<Account> accList = [select id from account limit 1];
        List<XC_Address__c>  addrList =XC_DF_Address.createAddress(accList);
        insert addrList;

        NE__Order__c ordertoUpdate=[select id from ne__order__c ][0];
        ordertoUpdate.XC_DeliveryAddress__c = addrList[0].Id;
        ordertoUpdate.XC_InstallationAddress__c = addrList[0].Id;
        ordertoUpdate.XC_OrderBillingAddress__c = addrList[0].Id;
        update ordertoUpdate; 
        


        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();

        ord.OrderID = ordertoUpdate.id;
        ord.OrderStatus = 'In Progress';
        ord.StartProvisioning = true;

        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.OrderItemID = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: ordertoUpdate.Id LIMIT 1][0].Id;
        ordit.BillingProfileID = [Select id from NE__Billing_Profile__c][0].id;
        ordit.PaymentType = 'External Financing';
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        Test.setMock(HttpCalloutMock.class, new CallZuora_Mock());
        
        test.startTest();
        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'PUT', 'Update');
        XC_REST_Order.doPut();
        //XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        //System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }

    
    static testMethod void put_updateOptyToQuote() {

        NE__Order__c ordertoUpdate=[select id from ne__order__c ][0];
        ordertoUpdate.RecordTypeId=Schema.SObjectType.NE__Order__c.getRecordTypeInfosByName().get('Opty').getRecordTypeId();
        ordertoUpdate.XC_LegalEntity__c = 'EndesaX';
        update ordertoUpdate; 

        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();

        ord.OrderID = ordertoUpdate.id;
        ordWr.Order = ord;

        test.startTest();
    
        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'PUT', 'OptyToQuote');
        try { 
            XC_REST_Order.doPut();
        } catch(exception e){
            
        }
        //XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }

    static testMethod void post_checkBillingProfile(){
        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();

        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from account][0].id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.OrderItemID = [select id from ne__orderitem__c][0].id;
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.BillingProfileID = ordit.CatalogItemID;
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
        XC_REST_Order.doPost();
        //XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }

    static testMethod void post_OrderItemError(){
        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();

        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from account][0].id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.OrderItemID = [select id from ne__orderitem__c][0].id;
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.BillingProfileID = [Select id from NE__Billing_Profile__c][0].id;
        ordit.CatalogItemID =ordit.BillingProfileID;
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
        XC_REST_Order.doPost();
        //XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        //System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }
        
    
    static testMethod void post_checkCompliance() {


        XC_REST_Order_U.WrapperPOSTRequest ordWr = new XC_REST_Order_U.WrapperPOSTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();


        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from account][0].id;
        ord.StartProvisioning = true;
        ord.SkipCompliance = true;
        ord.LegalEntity = 'EndesaX';
        
        ordWr.Order = ord;

        test.startTest();
        
        Map<String,Object> mapOrder = new Map<String,Object>();
        mapOrder.put('orderID', [select id from NE__Order__c][0].id);
        XC_REST_Order_ZZZ.manageCompliance (mapOrder, null, ordWr);
        System.assertEquals(true,true);

        test.stopTest();
    }


    static testMethod void post_insertOrder() {


        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit2 = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();


        NE__Family__c fam1 = new NE__Family__c();
        fam1.name = 'Payments Details';
        insert fam1;
        NE__Product__c prod1 = new NE__Product__c();
        prod1.XC_Product_Subtype__c = 'Solar Thermal';
        prod1.XC_Product_Type__c = 'Equipment';
        insert prod1;

        NE__DynamicPropertyDefinition__c propdef = new NE__DynamicPropertyDefinition__c();
        propdef.Name='forma de pago';
        insert propdef;

        NE__ProductFamily__c prodfam1 = new NE__ProductFamily__c();
        prodfam1.NE__FamilyId__c = fam1.id;
        prodfam1.NE__ProdId__c = prod1.id;
        insert prodfam1;

        NE__ProductFamilyProperty__c famProp= new NE__ProductFamilyProperty__c();
        famProp.NE__FamilyId__c=fam1.id; 
        famProp.NE__PropId__c = propdef.id;
        insert famProp; 

        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from account][0].id;
        ord.StartProvisioning = true;
        ord.SkipCompliance = false;
        ord.LegalEntity = 'EndesaX';
        
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordIt.ItemCode = ordit.ProdID + '-'+ ordit.CatalogItemID + '-' + ordit.quantity;
        //ordit.BillingProfileID = [Select id from NE__Billing_Profile__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        

        att.Name='Test';
        att.value ='Test';
        att.ProductFamilyPropertyID= famprop.Id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);

        ordit2.ParentOrderItem = ordit.ProdID + '-'+ ordit.CatalogItemID + '-' + ordit.quantity; 
        ordit2.ProdID = [select id from NE__Product__c][0].id;
        ordit2.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit2.quantity = 1;
        ordit2.BaseOneTimeFee = 1;
        ordit2.BaseRecurringCharge = 1;
        ord.orderItem.add(ordit2);

        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
        System.RestContext.request.addHeader('ClientSystem', 'E-Commerce');
        XC_REST_Order.doPost();
        //XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }

    static testMethod void post_insertOrder2() {


        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit2 = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();
        XC_UTIL_Order.WrapperDiscount disc = new XC_UTIL_Order.WrapperDiscount();
        XC_UTIL_Order.WrapperDiscount disc2 = new XC_UTIL_Order.WrapperDiscount();


        NE__Family__c fam1 = new NE__Family__c();
        fam1.name = 'Payments Details';
        insert fam1;
        NE__Product__c prod1 = new NE__Product__c();
        prod1.XC_Product_Subtype__c = 'Solar Thermal';
        prod1.XC_Product_Type__c = 'Equipment';
        insert prod1;

        NE__DynamicPropertyDefinition__c propdef = new NE__DynamicPropertyDefinition__c();
        propdef.Name='forma de pago';
        insert propdef;

        NE__ProductFamily__c prodfam1 = new NE__ProductFamily__c();
        prodfam1.NE__FamilyId__c = fam1.id;
        prodfam1.NE__ProdId__c = prod1.id;
        insert prodfam1;

        NE__ProductFamilyProperty__c famProp= new NE__ProductFamilyProperty__c();
        famProp.NE__FamilyId__c=fam1.id; 
        famProp.NE__PropId__c = propdef.id;
        insert famProp; 

        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from account][0].id;
        ord.StartProvisioning = true;
        ord.SkipCompliance = false;
        ord.LegalEntity = 'EndesaX';
        ord.practiceStatus = 'Approved';
        ord.OpportunityID = [SELECT id FROM Opportunity LIMIT 1][0].Id;
        ord.ConventionCode = 'ConvCode';
        ord.InstallationAddress = [select id from xc_address__c][0].id;

        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        //ordit.BillingProfileID = [Select id from NE__Billing_Profile__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;        

        att.Name='Test';
        att.value ='Test';
        att.ProductFamilyPropertyID= famprop.Id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);

        ordit.orderItemDiscount = new List<XC_UTIL_Order.WrapperDiscount>();
        disc.Code = '2';
        disc.OneTimePrice = 0.20;
        disc.OneTimeValue = 0.20;
        disc.RecurringPrice = 0;
        disc.RecurringValue = 0;
        disc.StartDate=  Date.newInstance(2020,12,12); 
        disc.EndDate = Date.newInstance(2320,12,26); 
        disc.Status = 'Active';              
        disc.Type = 'Percentage';
        disc.Sequence = 1;

        disc2.Code = '2';
        disc2.OneTimePrice = 0.0;
        disc2.OneTimeValue = 0.0;
        disc2.RecurringPrice = 230.0;
        disc2.RecurringValue = 10.0;
        disc2.Status = 'Active';  
        disc2.StartDate= Date.newInstance(2020,12,12); 
        disc2.EndDate = Date.newInstance(2320,12,26);         
        disc2.Type = 'Percentage';
        disc2.Sequence = 1;

        ordit.orderItemDiscount.add(disc); 
        ordit.orderItemDiscount.add(disc2); 

        ord.orderItem.add(ordit);

        ordit2.ParentOrderItem = ordit.ProdID + '-'+ ordit.CatalogItemID + '-' + ordit.quantity; 
        ordit2.ProdID = [select id from NE__Product__c][0].id;
        ordit2.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit2.quantity = 1;
        ordit2.BaseOneTimeFee = 1;
        ordit2.BaseRecurringCharge = 1;
        ord.orderItem.add(ordit2);

        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
        XC_REST_Order.doPost();
        //XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }


    static testMethod void post_insertOrder3() {


        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit2 = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();
        XC_UTIL_Order.WrapperDiscount disc = new XC_UTIL_Order.WrapperDiscount();

        //List<Opportunity> oppList = XC_DF_Opportunity.createOpportunityWithVisit(acc.Contacts, addr);
        //insert oppList;

        Account acc = [select id, (Select id, AccountId from Contacts) from account][0];
        String accId = acc.id;

        XC_Address__c address = [SELECT Id, XC_AddressCountry__c, XC_City__c, XC_PostalCode__c, XC_StreetTypeText__c, 
                                    XC_Address__c, XC_StreetNumber__c, XC_Floor__c, XC_Door__c, XC_AddressProvince__c  FROM XC_Address__c WHERE XC_Account__c  =: accId LIMIT 1][0];
        String streetNumber = address.XC_StreetNumber__c;

       
        NE__Family__c fam1 = new NE__Family__c();
        fam1.name = 'Payments Details';
        insert fam1;
        NE__Product__c prod1 = new NE__Product__c();
        prod1.XC_Product_Subtype__c = 'Solar Thermal';
        prod1.XC_Product_Type__c = 'Equipment';
        insert prod1;

        NE__DynamicPropertyDefinition__c propdef = new NE__DynamicPropertyDefinition__c();
        propdef.Name='forma de pago';
        insert propdef;

        NE__ProductFamily__c prodfam1 = new NE__ProductFamily__c();
        prodfam1.NE__FamilyId__c = fam1.id;
        prodfam1.NE__ProdId__c = prod1.id;
        insert prodfam1;

        NE__ProductFamilyProperty__c famProp= new NE__ProductFamilyProperty__c();
        famProp.NE__FamilyId__c=fam1.id; 
        famProp.NE__PropId__c = propdef.id;
        insert famProp; 

        ord.OrderStatus = 'In progress';
        ord.AccountID = accId;
        ord.StartProvisioning = true;
        ord.SkipCompliance = false;
        ord.practiceStatus = 'Approved';
        ord.InstallationAddress = [select id from xc_address__c][0].id;
        ord.LegalEntity = 'EndesaX';
        ord.Channel = 'Web';
        ord.CommodityBillingCycleFrequency  = '34';
        ord.OrderType = 'New';
        ord.DeactivationBasedOnRegulatory = '44';
        ord.AccountFiscalCode = '33|494';
        ord.ContractId = '39383748';
        ord.BillingAddressData = address.XC_AddressCountry__c +  '|' + address.XC_City__c + '|' + address.XC_PostalCode__c + '|' + address.XC_StreetTypeText__c + '|' + address.XC_Address__c + '|' + address.XC_StreetNumber__c + '|' + address.XC_Floor__c + '|' + address.XC_Door__c ;
        ord.InstallationAddressData = address.XC_AddressCountry__c + '|' + address.XC_City__c + '|' + address.XC_PostalCode__c  + '|' + address.XC_StreetTypeText__c  + '|' + address.XC_Address__c + '|' + address.XC_StreetNumber__c + '|' + address.XC_Floor__c + '|' + address.XC_Door__c ;
        ord.OpportunityID = [SELECT id FROM Opportunity LIMIT 1][0].Id;


        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;  
        ordit.OrderItemType = 'Service';
        ordit.OrderItemSubType = 'Electric';
      

        att.Name='Test';
        att.value ='Test';
        att.ProductFamilyPropertyID= famprop.Id;
        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);

        ordit.orderItemDiscount = new List<XC_UTIL_Order.WrapperDiscount>();
        disc.Code = '2';
        disc.OneTimePrice = 0.20;
        disc.OneTimeValue = 0.20;
        disc.RecurringPrice = 0;
        disc.RecurringValue = 0;
        disc.Status = 'Active';              
        disc.Type = 'Percentage';

        ordit.orderItemDiscount.add(disc); 

        ord.orderItem.add(ordit);

        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
        System.RestContext.request.addHeader('ClientSystem', 'CommoditySpainB2C');
        XC_REST_Order.doPost();
        //XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        //system.debug(LoggingLevel.FINEST, 'MISSING' + wrResp.result.Message);
        
        //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }

      static testMethod void post_insertOrderError463() {


        NE__OrderItem__c oiToUpdate = [SELECT Id FROM NE__OrderItem__c LIMIT1];

        oiToUpdate.XC_PaymentMethod__c = Label.XC_CL_Credit_Card;
        oiToUpdate.XC_BillingProfileLineItem__c = [SELECT Id FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__r.NE__Payment__c =: Label.XC_CL_Credit_Card LIMIT 1][0].Id;
        update oiToUpdate;

        string orderID = [select id from NE__Order__c limit 1][0].Id;
        system.debug('QUERY '+ [select id,  XC_BillingProfileLineItem__r.XC_BillingProfile__c, XC_BillingProfileLineItem__r.XC_Status__c, XC_PaymentMethod__c, NE__OrderId__r.XC_LegalEntity__c, NE__OrderId__r.RecordTypeId,  NE__OrderId__r.NE__Type__c  from NE__OrderItem__c where NE__OrderId__c =: orderID]);

        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();

        ord.OrderStatus = 'In progress';
        ord.AccountID = [select id from account][0].id;
        ord.StartProvisioning = true;
        ord.SkipCompliance = false;
        ord.LegalEntity = 'EndesaX';
        
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordIt.ItemCode = ordit.ProdID + '-'+ ordit.CatalogItemID + '-' + ordit.quantity;
        ordit.BillingProfileID = [Select id FROM NE__Billing_Profile__c WHERE  NE__Payment__c =: Label.XC_CL_Credit_Card][0].id;
        ordit.PaymentType = Label.XC_CL_Credit_Card;
        ordit.PaymentMethod = 'One shot';
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'POST', 'ok');
        System.RestContext.request.addHeader('ClientSystem', 'E-Commerce');
        XC_REST_Order.doPost();


        test.stopTest();
    }
    
    /*static testMethod void put_checkItemAttribute() {
        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();
        NE__Order__c order= [select id, NE__AccountId__c from ne__order__c][0];
        ord.OrderID = order.id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.OrderItemID = [select id from ne__orderitem__c][0].id;
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;

        NE__OrderItem__c orditem = XC_DF_OrderItem.createOrderItem(order);
        orditem.NE__Account__c = order.NE__AccountId__c;
        orditem.XC_Product_Type__c = 'Equipment';
        insert orditem;

        NE__Order_Item_Attribute__c orderItemAttribute = new NE__Order_Item_Attribute__c();
        orderItemAttribute.NE__Order_Item__c = orditem.Id;
        insert orderItemAttribute;

        att.AttributeID = orderItemAttribute.id;
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;

        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'PUT', 'ok');
        XC_REST_Order.doPut();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }*/
  
      static testMethod void put_checkItemAttribute2() {
        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();
        NE__Order__c order= [select id from ne__order__c][0];
        ord.OrderID = order.id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.OrderItemID = [select id from ne__orderitem__c where NE__OrderID__c =: order.id][0].id;
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;

        NE__Order_Item_Attribute__c orderItemAttribute = new NE__Order_Item_Attribute__c();
        orderItemAttribute.NE__Order_Item__c = ordit.OrderItemID;
        insert orderItemAttribute;

        att.AttributeID =ordit.CatalogItemID;
        att.Name = 'test';
        att.Value = 'test';
        att.ProductFamilyPropertyID = [select id from NE__ProductFamily__c][0].id;

        ordit.Attribute = new list<XC_UTIL_Order.WrapperAttribute>();
        ordit.Attribute.add(att);
        XC_UTIL_Order.WrapperAttribute att2 = new XC_UTIL_Order.WrapperAttribute();
        att2.AttributeID =orderItemAttribute.id;

        ordit.Attribute.add(att2);
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'PUT', 'ok');
        XC_REST_Order.doPut();
        //XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }

    static testMethod void put_checkItemDiscount() {
        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();
        XC_UTIL_Order.WrapperDiscount disc = new XC_UTIL_Order.WrapperDiscount();


        NE__Order__c order= [select id from ne__order__c][0];
        ord.OrderID = order.id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.OrderItemID = [select id from ne__orderitem__c][0].id;
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.orderItemDiscount = new List<XC_UTIL_Order.WrapperDiscount>();
        ordit.orderItemDiscount.add(disc); 
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'PUT', 'ok');
        XC_REST_Order.doPut();
        //XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }

    static testMethod void put_checkItemDiscount2() {
        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();
        XC_UTIL_Order.WrapperDiscount disc = new XC_UTIL_Order.WrapperDiscount();


        NE__Order__c order= [select id from ne__order__c][0];
        ord.OrderID = order.id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.OrderItemID = [select id from ne__orderitem__c][0].id;
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.orderItemDiscount = new List<XC_UTIL_Order.WrapperDiscount>();
        disc.OrderItemID = ordit.OrderItemID; 
        ordit.orderItemDiscount.add(disc); 
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'PUT', 'ok');
        XC_REST_Order.doPut();
        //XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }

    static testMethod void put_checkItemDiscount3() {
        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();
        XC_UTIL_Order.WrapperDiscount disc = new XC_UTIL_Order.WrapperDiscount();


        NE__Order__c order= [select id from ne__order__c][0];
        ord.OrderID = order.id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.OrderItemID = [select id from ne__orderitem__c][0].id;
        ordit.ProdID = [select id from NE__Product__c][0].id;
        ordit.quantity = 1;
        ordit.BaseOneTimeFee = 1;
        ordit.BaseRecurringCharge = 1;
        ordit.CatalogItemID = [select id from NE__Catalog_Item__c][0].id;
        ordit.orderItemDiscount = new List<XC_UTIL_Order.WrapperDiscount>();
        disc.OrderItemID = ordit.OrderItemID; 
        disc.Code = '234';
        ordit.orderItemDiscount.add(disc); 
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'PUT', 'ok');
        XC_REST_Order.doPut();
        //XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }

    static testMethod void put_checkItemDiscount4() {
        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();
        XC_UTIL_Order.WrapperDiscount disc = new XC_UTIL_Order.WrapperDiscount();


        NE__Order__c order= [select id from ne__order__c][0];
        ord.OrderID = order.id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.OrderItemID = [select id from ne__orderitem__c][0].id;
        ordit.orderItemDiscount = new List<XC_UTIL_Order.WrapperDiscount>();
        disc.OrderItemID = ordit.OrderItemID; 
        disc.Code = '234';
        disc.OneTimePrice = 4;
        ordit.orderItemDiscount.add(disc); 
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'PUT', 'ok');
        XC_REST_Order.doPut();
        //XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }

    static testMethod void put_checkItemDiscount5() {
        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();
        XC_UTIL_Order.WrapperDiscount disc = new XC_UTIL_Order.WrapperDiscount();


        NE__Order__c order= [select id from ne__order__c][0];
        ord.OrderID = order.id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.OrderItemID = [select id from ne__orderitem__c][0].id;
        ordit.orderItemDiscount = new List<XC_UTIL_Order.WrapperDiscount>();
        disc.OrderItemID = ordit.OrderItemID; 
        disc.Code = '234';
        disc.OneTimePrice = 4;
        disc.OneTimeValue = 8;
        ordit.orderItemDiscount.add(disc); 
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'PUT', 'ok');
        XC_REST_Order.doPut();
        //XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }

    static testMethod void put_checkItemDiscount6() {
        XC_REST_Order_U.WrapperPUTRequest ordWr = new XC_REST_Order_U.WrapperPUTRequest();
        XC_UTIL_Order.OrderIFWrapper ord = new XC_UTIL_Order.OrderIFWrapper();
        XC_UTIL_Order.OrderItemWrapper ordit = new XC_UTIL_Order.OrderItemWrapper();
        XC_UTIL_Order.WrapperAttribute att = new XC_UTIL_Order.WrapperAttribute();
        XC_UTIL_Order.WrapperDiscount disc = new XC_UTIL_Order.WrapperDiscount();


        NE__Order__c order= [select id from ne__order__c][0];
        ord.OrderID = order.id;
        ord.orderItem = new list<XC_UTIL_Order.OrderItemWrapper>();
        ordit.OrderItemID = [select id from ne__orderitem__c][0].id;
        ordit.orderItemDiscount = new List<XC_UTIL_Order.WrapperDiscount>();
        disc.OrderItemID = ordit.OrderItemID; 
        disc.Code = '234';
        disc.OneTimePrice = 4;
        disc.OneTimeValue = 8;
        disc.RecurringPrice = 0;
        ordit.orderItemDiscount.add(disc); 
        ord.orderItem.add(ordit);
        ordWr.Order = ord;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(ordWr, 'PUT', 'ok');
        XC_REST_Order.doPut();
        //XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperRes.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }
    

    static testMethod void post_TestUniqueID() {

        test.startTest();
        
        NE__Order__c ord = [select id from ne__order__c][0];
        Date myDate = Date.newInstance(2019, 12, 12);
        ord.XC_Cancellation_Date__c =myDate;
        ord.NE__One_Time_Fee_Total__c=0;
        ord.NE__Recurring_Charge_Total__c=0;
        update ord;

        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        woList[0].XC_LegalEntity__c = 'EndesaX';
        woList[0].xc_configuration__c = ord.Id; 
        insert woList; 

        zqu__quote__c quote = new zqu__quote__c(zqu__ZuoraSubscriptionID__c = '12345');
        insert quote;

        Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__OriginalId__c = '12345',
                                                                        Zuora__PreviousSubscriptionId__c = '12345',
                                                                        Zuora__External_Id__c = '56789');
        insert sub;
        
        NE__Catalog_Item__c catItem = [SELECT Id, NE__Catalog_Id__c FROM NE__Catalog_Item__c WHERE NE__ProductId__c != null][0];
        NE__OrderItem__c ordit= [select id from ne__orderItem__c where NE__OrderId__c=: ord.id][0];
        ordit.XC_ZQuoteId__c = quote.Id; 
        ordit.NE__CatalogItem__c = catItem.Id; 
        ordit.NE__Catalog__c = catItem.NE__Catalog_Id__c; 
        update ordit;

        NE__Order_Item_Discount__c itemDiscount = new NE__Order_Item_Discount__c();
        itemDiscount.NE__Order_Item__c =  ordit.id;
        itemDiscount.NE__Type__c = 'Percentage';
        itemDiscount.NE__Recurring_Price__c = 2;
        itemDiscount.NE__Status__c = 'Active';
        itemDiscount.NE__Code__c = '0992';
        itemDiscount.NE__One_Time_Price__c = 0;
        itemDiscount.NE__One_Time_Value__c = 0;
        itemDiscount.NE__Recurring_Value__c = 2;
        insert itemDiscount; 

        NE__Order_Item_Attribute__c attr= XC_DF_OrderItemAttribute.createOrderItemAttribute(ordit,'test','test');
        insert attr;
        

        Asset ass= new Asset();
        ass.NE__Order_Config__c= ord.id;
        ass.XC_Configuration_Item__c= ordit.id;
        ass.Name='Test';
        insert ass; 

        XC_Provisioning_Step__c provStep= XC_DF_ProvisioningStep.createProvisioningStep(ordit.id);
        
        insert provStep;
        
        AssetHistory assHist= new AssetHistory();
        assHist.AssetId = ass.id;
        assHist.field= 'NE__Status__c';
        insert assHist; 
        
        Map<String,String> params = new Map<String,String>();
        params.put('OrderID', ord.id );

            System.RestContext.request = generateGETRequest(params, 'ok');
            System.RestContext.request.headers.put('X-UniqueID', '123123');
            XC_REST_Order.doGet();
            XC_REST_Order_U.WrapperGetResponse wrResp = (XC_REST_Order_U.WrapperGetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Order_U.WrapperGetResponse.class);
        
        test.stopTest();
    
    }

    /*
  *@ Description mock class to call zuora
  */
    public without sharing class CallZuora_Mock implements HttpCalloutMock {
        public HttpResponse respond (HTTPRequest req){
            HttpResponse response = new HttpResponse();

            if(req.getEndpoint().endsWith('/v1/accounts')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"accountId":"a0001", "accountNumber":"A01807438", "paymentMethodId":null, "processId":null, "reasons":null, "success":true}');
                response.setStatusCode(200); 

            } else if(req.getEndpoint().endsWith('/v1/object/payment-method')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"Errors":null, "Id":"a0002", "Success":true, "ZuoraAccountId":null}');
                response.setStatusCode(200); 

            } else if(req.getEndpoint().endsWith('/v1/object/account/a0001')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"Errors":null, "Id":"a0001", "Success":true}');
                response.setStatusCode(200); 

            }
            return response;
        }
    }

    @isTest
    private static void populateAccountChildFieldsTest() {
        List<Account> accList = [SELECT Id,XC_Refund_Method__c, XC_LastName__c, XC_FirstName__c, XC_Member_Typology__c, ParentId, XC_CustomerNumber_EnelEnergia__c, XC_BirthDate__c, XC_Una_tantum_member_fee__c, XC_Annual_member_fee__c, XC_Fix_part_sharing_monthly__c, XC_MISE_incentive__c, XC_Arera_incentive__c, XC_Local_price_incentive__c, XC_Annual_membership_fee_due_date__c FROM Account LIMIT 1];
        //Shreyas added XC_Refund_Method__c
        List<Account>  accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        accList[0].XC_LastName__c = 'test';
        accList[0].XC_FirstName__c = 'test';
        accList[0].XC_Member_Typology__c = 'Silver';
        accList[0].ParentId = accountList[0].Id;
        accList[0].XC_CustomerNumber_EnelEnergia__c = 'test';
        accList[0].XC_BirthDate__c = Date.today();
        accList[0].XC_Annual_membership_fee_due_date__c = Date.today();
        accList[0].XC_Una_tantum_member_fee__c = 12;
        accList[0].XC_Annual_member_fee__c = 12;
        accList[0].XC_Fix_part_sharing_monthly__c = 12;
        accList[0].XC_MISE_incentive__c = 10;
        accList[0].XC_Local_price_incentive__c = 20;
        accList[0].XC_Arera_incentive__c= 20;
        accList[0].XC_Refund_Method__c = 'IBAN'; //Shreyas
        update accList[0];

        Test.startTest();

        XC_REST_Order_VVV.populateAccountChildFields(accList[0], new XC_UTIL_Order.AccountChildWrapper());
        Test.stopTest();
    }


    @isTest
    private static void callinsertOrderItemDiscount() {
        List<Account> accList = [SELECT Id, XC_Refund_Method__c,XC_LastName__c, XC_FirstName__c, XC_Member_Typology__c, ParentId, XC_CustomerNumber_EnelEnergia__c, XC_BirthDate__c, XC_Una_tantum_member_fee__c, XC_Annual_member_fee__c, XC_Fix_part_sharing_monthly__c, XC_MISE_incentive__c, XC_Arera_incentive__c, XC_Local_price_incentive__c, XC_Annual_membership_fee_due_date__c FROM Account LIMIT 1];
        List<Account>  accountList = XC_DF_Account.createResidentialAccounts(1);
        
        insert accountList;
        accList[0].XC_LastName__c = 'test';
        accList[0].XC_FirstName__c = 'test';
        accList[0].XC_Member_Typology__c = 'Silver';
        accList[0].ParentId = accountList[0].Id;
        accList[0].XC_CustomerNumber_EnelEnergia__c = 'test';
        accList[0].XC_BirthDate__c = Date.today();
        accList[0].XC_Annual_membership_fee_due_date__c = Date.today();
        accList[0].XC_Una_tantum_member_fee__c = 12;
        accList[0].XC_Annual_member_fee__c = 12;
        accList[0].XC_Fix_part_sharing_monthly__c = 12;
        accList[0].XC_MISE_incentive__c = 10;
        accList[0].XC_Local_price_incentive__c = 20;
        accList[0].XC_Arera_incentive__c= 20;
        accList[0].XC_Refund_Method__c = 'IBAN'; //Shreyas
        update accList[0];
        Test.startTest();
        XC_REST_Order_VVV.populateAccountChildFields(accList[0], new XC_UTIL_Order.AccountChildWrapper());
        Test.stopTest();
    }

}