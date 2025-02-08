/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
* @date Creation 27/11/2020
* @description XC_SC038_RecalculateWBE_TEST – Test Class for XC_SC038_RecalculateWBE
*/

@isTest
private class XC_SC038_RecalculateWBE_TEST {

    @isTest
    static void onExecute() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        NE__Order__c order = new NE__Order__c();
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(accountList);
        insert contList;
        List<XC_Address__c> address =  XC_DF_Address.createAddress(accountList);
        insert address;
        XC_ProductCategoryOfInterest__c prodCat = new XC_ProductCategoryOfInterest__c();
        prodCat.Name = 'Caldera';
        prodCat.XC_CommercialVisit__c = false;
        insert prodCat;
        List<Opportunity> o = new List<Opportunity>();
        for(Integer i = 0; i < contList.size(); i++) {
            Opportunity opportunityToInsert = new Opportunity();
            opportunityToInsert.Name = 'OP0000'+ i;
            opportunityToInsert.XC_Contact__c = contList[0].Id;
            opportunityToInsert.AccountId = contList[0].AccountId;
            opportunityToInsert.XC_ProductCategoryOfInterest__c = prodCat.Name;
            opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
            opportunityToInsert.StageName = 'Draft';
            opportunityToInsert.XC_Source__c = 'BLOG';
            opportunityToInsert.XC_ReceivingChannel__c = 'Web';
            opportunityToInsert.XC_Address__c = address[0].Id;
            opportunityToInsert.XC_LegalEntity__c = 'EndesaX';
            o.add(opportunityToInsert);
        }
        Test.startTest();
        insert o;
        order.NE__Type__c = 'Quote';
        order.NE__OptyId__c = o[0].Id;
        order.NE__AccountId__c = o[0].AccountId;
        order.XC_Country__c = 'Spain';
        order.XC_Segment__c = 'B2C';
        insert order;
        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
        item.NE__Account__c = accountList[0].Id;
        item.XC_Installation_Address__c = address[0].Id;
        insert item;
        order.NE__Type__c = 'InOrder';
        order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        update order;

        order.NE__Type__c = Label.XC_CL_Configuration_TypeChangeOrder;
        update order;
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(5);
        for(NE__OrderItem__c oi : listOrderItem) {
            oi.NE__OrderId__c = order.Id;
            oi.NE__Account__c = accountList[0].Id;
            oi.XC_Installation_Address__c = address[0].Id;
        }
        insert listOrderItem;
        order.XC_ForceWBERecalculation__c = true;
        update order;
        Database.executeBatch(new XC_SC038_RecalculateWBE());
    }

}