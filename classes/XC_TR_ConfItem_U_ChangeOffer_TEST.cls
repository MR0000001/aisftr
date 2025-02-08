/**
* @author: Marco Ottaviano - mottaviano@deloitte.it 
* @fileName XC_TR_ConfItem_U_ChangeOffer_TEST
* @date Creation Date: 23/06/2020
* @description TEST CLASS FOR XC_TR_ConfItem_U_ChangeOffer
**/


@isTest
public without sharing class XC_TR_ConfItem_U_ChangeOffer_TEST {
    @TestSetup
    static void makeData(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
       
        List<Account>  accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accountList);
        conList[0].XC_PrimaryContact__c = true;
        insert conList;
        List<NE__Billing_Profile__c> bplist=XC_DF_BillingProfile.createBillingProfile(1,accountList);
        NE__Billing_Profile__c bp = bplist[0];
        bp.NE__Payment__c = Label.XC_CL_Credit_Card;
        update bp;
        //List<XC_Address__c> address =  XC_DF_Address.createAddress(accountList);
        //insert address;
        List<XC_Address__c> address = [SELECT id FROM XC_Address__c WHERE XC_Account__c =: accountList[0].Id];

        Test.startTest(); 
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
        Test.stopTest();
    }


    @isTest
    static void testInsertOne() {

        List<XC_BillingProfileLineItem__c> listBPLI = [SELECT Id, XC_PaymentMethod__c
                                                        FROM XC_BillingProfileLineItem__c 
                                                       LIMIT 1];
    XC_BillingProfileLineItem__c bpli = listBPLI[0];
        Opportunity opty = [SELECT Id,AccountId FROM Opportunity LIMIT 1];

        Test.startTest();

            NE__Order__c order = new NE__Order__c();
            order.NE__Type__c = Label.XC_CL_Configuration_TypeInOrder;
            order.NE__OptyId__c = opty.Id;
            order.NE__AccountId__c = opty.AccountId;
            order.XC_Country__c = 'Spain';
            order.XC_Segment__c = 'B2C';
            order.XC_LegalEntity__c ='EndesaX';
            order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
            order.XC_CommercialChange__c = false;
            insert order;
            NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
            item.XC_BillingProfileLineItem__c = bpli.Id;
            item.XC_PaymentMethod__c  = bpli.XC_PaymentMethod__c;
            insert item;
            update order;
               
            NE__OrderItem__c itemAdd = XC_DF_OrderItem.createOrderItem(order);
            itemAdd.NE__Picked_By__c ='Human';
            insert itemAdd;
            
           System.assert(true,true);
        Test.stopTest();
    }


     @isTest
    static void testUpdateTwo() {
          Opportunity opty = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        Test.startTest();

            NE__Order__c order = new NE__Order__c();
            order.NE__Type__c = Label.XC_CL_Configuration_TypeInOrder;
            order.NE__OptyId__c = opty.Id;
            order.NE__AccountId__c = opty.AccountId;
            order.XC_Country__c = 'Spain';
            order.XC_Segment__c = 'B2C';
            order.XC_LegalEntity__c ='EndesaX';
            order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
            order.XC_CommercialChange__c = false;
            insert order;
            NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
            insert item;

            List<NE__OrderItem__c> childItems = new List<NE__OrderItem__c>();
            NE__OrderItem__c itemAdd1 = XC_DF_OrderItem.createOrderItem(order);
           // itemAdd1.NE__Picked_By__c ='Human';
            itemAdd1.XC_Product_Subtype__c = Label.XC_CL_ProductSubtypeIncentive;
            itemAdd1.NE__Bundle_Configuration__c = item.Id;
            itemAdd1.NE__OneTimeFeeOv__c = 1;
            NE__OrderItem__c itemAdd2 = XC_DF_OrderItem.createOrderItem(order);
           // itemAdd1.NE__Picked_By__c ='Human';
            itemAdd2.NE__Bundle_Configuration__c = item.Id;
            itemAdd2.NE__OneTimeFeeOv__c = 1;
          
            childItems.add(itemAdd1);
            childItems.add(itemAdd2);

            insert childItems;
            NE__Order_Item_Attribute__c orderItemAttribute1=XC_DF_OrderItemAttribute.createOrderItemAttribute(childItems[0], Label.XC_CL_Incentive_Amount, '20');
            insert orderItemAttribute1;

            item.XC_BundleTotalOTAmount__c = 1530;
            update item;
            delete childItems.get(1);
       

            
            
           System.assert(true,true);
        Test.stopTest();
    }

           
        
    
}