/**
* @author Elisa Caldini -elisa.caldini@accenture.com
* @date Creation -25.03.2022
* @description  - XC_LCC_ConfItemHierController_Test TEST Class for XC_LCC_ConfItemHierController
*/

@isTest
public class XC_LCC_ConfItemHierController_Test {
    
    @TestSetup
    public static void setup() {
        Opportunity opp = new Opportunity();
        List<Account>  accountList = XC_DF_Account.createResidentialAccounts(1);
        accountList[0].RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        insert accountList;
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(accountList);
        contList[0].RecordTypeID = Schema.SObjectType.contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        insert contList;
        List<XC_Address__c> address =  XC_DF_Address.createAddress(accountList);
        insert address;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2G_Opportunity_Italy').getRecordTypeId();
        opp.Name ='Opportunity di Test';
        opp.XC_Contact__c = contList[0].Id;
        opp.AccountId = contList[0].AccountId;
        opp.XC_Address__c = address[0].Id;
        opp.CloseDate = Date.newInstance(2030, 12, 31);
        opp.XC_Segment__c = 'B2G';
        opp.XC_LegalEntity__c = 'EnelSole';
        opp.XC_BusinessLine__c='eCity';
        opp.XC_IndustrialKPI__c ='Work Contract';
        opp.XC_ProductCategoryOfInterest__c ='Architectural Lighting';
        opp.XC_ProductCategory__c='Optimize';
        opp.XC_BusinessModel__c = 'Spot Sale';
        opp.StageName ='Draft';
        opp.XC_Source__c ='Commodity';
        opp.XC_ReceivingChannel__c='KAM';
        opp.XC_CapexFullLife__c =6000;
        opp.XC_CustomerRequestDate__c= Date.newInstance(2022, 6, 3);
        insert opp;
        NE__Order__c orderB2G= new NE__Order__c();
        orderB2G.NE__Type__c ='InOrder';
        orderB2G.NE__OptyId__c = opp.Id; 
        orderB2G.XC_DeliveryAddress__c = opp.XC_Address__c; 
        orderB2G.NE__AccountId__c = opp.AccountId; 
        orderB2G.XC_Segment__c = 'B2G';
        insert orderB2G;
        List<NE__Order__c> listOrders = XC_DF_Order.createOrders(1,'InOrder');
        insert listOrders;
        NE__OrderItem__c  orderItemRoot= XC_DF_OrderItem.createOrderItem(listOrders[0]);
        insert orderItemRoot;
        NE__OrderItem__c  orderChild= XC_DF_OrderItem.createOrderItem(listOrders[0]);
        orderChild.NE__Parent_Order_Item__c=orderItemRoot.Id;
        insert orderChild;
        NE__OrderItem__c  orderTech= XC_DF_OrderItem.createOrderItem(listOrders[0]);
        orderTech.XC_ParentCommercialItem__c=orderChild.Id;
        insert orderTech;
    }

     static testMethod void getConfsTest(){
     
        Test.startTest();
            NE__Order__c order=[SELECT  Id FROM NE__Order__c WHERE XC_Segment__c='B2C'  LIMIT 1];
            List<NE__OrderItem__c> orderitems= [SELECT Id,NE__Parent_Order_Item__c,XC_ParentCommercialItem__c FROM  NE__OrderItem__c WHERE NE__OrderId__c = : order.Id];
            List<NE__OrderItem__c> orders=  XC_LCC_ConfItemHierController.getConfs(String.valueOf(order.Id));
            System.assertEquals(3, orders.size());
        Test.stopTest();
    }

    static testMethod void checkCommercialTest(){
     
        Test.startTest();
            NE__Order__c order=[SELECT Id,XC_Segment__c,NE__OptyId__r.XC_Commercial_Contract_Type__c FROM NE__Order__c  WHERE  XC_Segment__c ='B2G' LIMIT 1];
            Opportunity opp=[SELECT Id,XC_ProductCategoryOfInterest__c,XC_Commercial_Contract_Type__c FROM Opportunity WHERE Id = :order.NE__OptyId__c LIMIT 1];
            Integer  result=XC_LCC_ConfItemHierController.checkCommercial(String.valueOf(order.Id));
            System.assertEquals(0,result);
            opp.XC_Commercial_Contract_Type__c='Spot Sales works';
            update opp;
            Integer  result1=XC_LCC_ConfItemHierController.checkCommercial(String.valueOf(order.Id));
            System.assertEquals(1,result1);
            opp.XC_Commercial_Contract_Type__c='OM Projects without energy';
            update opp;
            Integer  result2=XC_LCC_ConfItemHierController.checkCommercial(String.valueOf(order.Id));
            System.assertEquals(2,result2);
        Test.stopTest();
    }
}