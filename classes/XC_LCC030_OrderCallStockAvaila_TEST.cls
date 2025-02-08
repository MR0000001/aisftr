/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  15/05/2019 
* @description XC_LCC030_OrderCallStockAvaila_TEST – Test class for XC_LCC030_OrderCallStockAvailability
*/
@isTest
public class XC_LCC030_OrderCallStockAvaila_TEST {
    //Test Method callStockAvailability
    static testMethod void callStockAvailability(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_LCC030_OrderCallStockAvailability.ResultWrapper rw = XC_LCC030_OrderCallStockAvailability.callStockAvailability('test');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = Label.XC_CL_Configuration_CallToStockAvailability;
        ic.XC_interfaceName__c = Label.XC_CL_Configuration_CallToStockAvailability;
        insert ic;
        
        try {
            rw = XC_LCC030_OrderCallStockAvailability.callStockAvailability('test');
        } catch (exception e) {
            System.assert(e!=null);
        }
        
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    //Test Method updateDeliveryDates
    static testMethod void updateDeliveryDates(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        
        NE__Order__c ord = new NE__Order__c();
        insert ord;
        
        NE__OrderItem__c o = new NE__OrderItem__c();
        o.NE__Delivery_Date__c = Date.today();
        o.NE__OrderId__c = ord.Id;
        o.NE__Qty__c = 1;
        
        insert o;
        
        Map<String,Object> m = new Map<String,Object>();
        m.put('Id',o.Id);
        m.put('NE__Delivery_Date__c',o.NE__Delivery_Date__c);
        
        List<Object> objList = new List<Object>();
        objList.add(m);
        String st = JSON.serialize(objList);
        
        
        XC_LCC030_OrderCallStockAvailability.ResultWrapper rw = XC_LCC030_OrderCallStockAvailability.updateDeliveryDates(st);
        System.assertEquals(true, rw!=null);
        Test.stopTest();
    }
    
    //Test Method callStockReservation
    static testMethod void callStockReservation(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        
        NE__Order__c o = new NE__Order__c();
        insert o; 
        
        NE__OrderItem__c oi = new NE__OrderItem__c();
        oi.NE__OrderId__c = o.Id;
        oi.NE__Qty__c = 1;
        oi.XC_Country__c='SPAIN';
        OI.NE__Country__c ='SPAIN';
        insert oi;
        
        
        Test.startTest();
        XC_LCC030_OrderCallStockAvailability.ResultReservationWrapper rw = XC_LCC030_OrderCallStockAvailability.callStockReservation(oi.Id);
        delete oi;
        undelete oi;
        System.assertEquals(true, rw!=null);
        Test.stopTest();
    }

    //Test Method callStockReservation1
    static testMethod void callStockReservation11(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        
        NE__Order__c o = new NE__Order__c();
        o.XC_IsStockReservationKO__c = true;
        insert o; 
        
        NE__OrderItem__c oi = new NE__OrderItem__c();
        oi.NE__OrderId__c = o.Id;
        oi.NE__Qty__c = 1;
        insert oi;
        
        XC_LCC030_OrderCallStockAvailability.ResultReservationWrapper rw = XC_LCC030_OrderCallStockAvailability.callStockReservation(oi.Id);
        System.assertEquals(true, rw!=null);
        Test.stopTest();
    }

    //Test Method callStockReservation1
    static testMethod void callStockReservation1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        
        NE__Order__c o = new NE__Order__c();
        insert o; 
        
        NE__OrderItem__c oi = new NE__OrderItem__c();
        oi.NE__OrderId__c = o.Id;
        oi.NE__Qty__c = 1;
        insert oi;
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = Label.XC_CL_Configuration_CallToStockReservation;
        ic.XC_interfaceName__c = Label.XC_CL_Configuration_CallToStockReservation;
        insert ic;
        
        Test.startTest();
        XC_LCC030_OrderCallStockAvailability.ResultReservationWrapper rw = XC_LCC030_OrderCallStockAvailability.callStockReservation(oi.Id);
        System.assertEquals(true, rw!=null);
        Test.stopTest();
    }
    
    //Test Method FieldWrapper
    static testMethod void FieldWrapper(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        
        XC_LCC030_OrderCallStockAvailability.FieldWrapper fw = new XC_LCC030_OrderCallStockAvailability.FieldWrapper('test','test');
        XC_LCC030_OrderCallStockAvailability.ResultReservationWrapper rrw = new XC_LCC030_OrderCallStockAvailability.ResultReservationWrapper();
        rrw.message='test';
        rrw.deliveryId='testid';
        rrw.courierPartnerName ='test2';
        rrw.trackingURL='test3';
        
       XC_LCC030_OrderCallStockAvailability.ResultWrapper pf = new XC_LCC030_OrderCallStockAvailability.ResultWrapper();
        pf.putField('test','test');
        
        System.assertEquals(true, fw!=null);
        Test.stopTest();
    }
    
}