/**
 * @author            : Neeraj Saini(neeraj.saini@accenture.com)
 * @date Creation     : 23/03/2022
 * @description       : Test Class for XC_SC066_SwsMvp
 **/
@isTest
public class XC_SC066_SwsMvp_Test {

    @TestSetup
    static void setupData(){
        NE__Order__c order = new NE__Order__c();
        
        List<Opportunity> o = XC_DF_Opportunity.createOpportunity(1, false);
        insert o;

        order.NE__Type__c = Label.XC_CL_Configuration_TypeInOrder;
        order.NE__OptyId__c = o[0].Id;
        order.XC_DeliveryAddress__c = o[0].XC_Address__c;
        order.NE__AccountId__c = o[0].AccountId;
        order.XC_Country__c = 'Brazil';
        order.XC_Segment__c = 'B2C';
        order.XC_Status__c = 'In Progress';
        order.XC_AssetsCreated__c = false;
        order.NE__Description__c = 'OK';
        order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        insert order;
        System.debug(order);

        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
        item.NE__Account__c = o[0].AccountId;
        insert item;
        NE__OrderItem__c item1 = XC_DF_OrderItem.createOrderItem(order);
        item1.NE__Account__c = o[0].AccountId;
        item1.NE__Root_Order_Item__c = item.id;
        insert item1;
        System.debug(item);
        update order;
    }

    @isTest
    static void Test1() {
        Test.startTest();
        XC_SC066_SwsMvp swsMvp= new XC_SC066_SwsMvp();
        Id jobid= Database.executeBatch(SwsMvp,5);
        Test.stopTest();
    }

    @isTest
    static void Test2() {
        NE__Order__c order = [select id,NE__Description__c from NE__Order__c limit 1];
        order.NE__Description__c='KO';
        update order;
        Test.startTest();
        XC_SC066_SwsMvp swsMvp= new XC_SC066_SwsMvp();
        Id jobid= Database.executeBatch(SwsMvp,5);
        Test.stopTest();
    }
    @isTest
    static void Test3() {
        Test.startTest();
        XC_SC066_SwsMvp swsMvp= new XC_SC066_SwsMvp();
        swsMvp.execute(null);
        Test.stopTest();
    }
}