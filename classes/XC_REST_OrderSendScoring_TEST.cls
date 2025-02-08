@isTest
public class XC_REST_OrderSendScoring_TEST {
    
    @isTest
    public static void callActive(){
    
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_SendScoring;
        ic.XC_interfaceName__c = Label.XC_CL_SendScoring;
        insert ic;
        
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, 'InOrder');
        
        test.setMock(HttpCalloutMock.class, new XC_REST_OrderSendScoring_MOCK());
        
        test.startTest();
        
        XC_REST_OrderSendScoring.sendScoring(orderList[0]);
            
        test.stopTest();
        
        
    }
    
     @isTest
    public static void callActive1(){
    
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_SendScoring;
        ic.XC_interfaceName__c = Label.XC_CL_SendScoring;
        insert ic;
        
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, 'InOrder');
        
        test.startTest();
        
        XC_REST_OrderSendScoring.sendScoring(orderList[0]);
            
        test.stopTest();
        
        
    }
    
    @isTest
    public static void callInActive(){
    
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_SendScoring;
        ic.XC_interfaceName__c = Label.XC_CL_SendScoring;
        insert ic;
        
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, 'InOrder');
        
        test.startTest();
        
        XC_REST_OrderSendScoring.sendScoring(orderList[0]);
            
        test.stopTest();
        
        
    }

}