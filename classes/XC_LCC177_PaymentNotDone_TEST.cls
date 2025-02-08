/**
 * The Class XC_LCC177_PaymentNotDone_TEST.
 *
 * @author Domenico Del Prete domenico.delprete@nttadata.com
 * @date Creation 02/03/2020 
 * @description XC_LCC177_PaymentNotDone_TEST – Test class for XC_LCP177_PaymentNotDone Component
 */
@isTest
public without sharing class XC_LCC177_PaymentNotDone_TEST {
    
    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }


    @isTest
    static void paymentNotDoneSuccess(){
        List <NE__OrderItem__c> listOfOrderItem =  XC_DF_OrderItem.createOrderItems(1);
        insert listOfOrderItem;
        List<NE__Order__c> orderList = new List<NE__Order__c>([SELECT Id FROM NE__Order__c WHERE Id =:listOfOrderItem[0].NE__OrderId__c]);
        orderList[0].XC_LegalEntity__c = 'EndesaX';
        update orderList;
        XC_Provisioning_Step__c step = new XC_Provisioning_Step__c();
        step.XC_StepLabel__c = 'Payment Check';
        step.XC_Status__c = 'Not Started';
        step.XC_Configuration_Item__c = listOfOrderItem[0].Id;
        insert step;
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Commercial Visit - Boiler', 'Commercial Visit');
        listOfWo[0].XC_Configuration_Item__c = listOfOrderItem[0].Id;
        listOfWo[0].XC_LegalEntity__c = 'EndesaX';
        insert listOfWo;
        List<ServiceAppointment> listOfSa = XC_DF_ServiceAppointment.createServiceAppointment(listOfWo);
        listOfSa[0].XC_LegalEntity__c = 'EndesaX';
        listOfSa[0].XC_WorkTypeCategory__c = 'Commercial Visit';
        listOfSa[0].PostalCode ='28016';
        insert listOfSa;
        XC_LCC177_PaymentNotDone.ResultWrapper rw = XC_LCC177_PaymentNotDone.paymentNotDone(step.Id);
        //system.assertEquals(true, rw.success);
    }

    @isTest
    static void paymentNotDoneNoPaymentCheck(){
        List <NE__OrderItem__c> listOfOrderItem =  XC_DF_OrderItem.createOrderItems(1);
        insert listOfOrderItem;
        XC_Provisioning_Step__c step = new XC_Provisioning_Step__c();
        step.XC_StepLabel__c = 'Book Appointment';
        step.XC_Status__c = 'Not Started';
        step.XC_Configuration_Item__c = listOfOrderItem[0].Id;
        insert step;
        XC_LCC177_PaymentNotDone.ResultWrapper rw = XC_LCC177_PaymentNotDone.paymentNotDone(step.Id);
        //system.assertEquals(false, rw.success);
    }

    @isTest
    static void paymentNotDoneCompletedKO(){
        List <NE__OrderItem__c> listOfOrderItem =  XC_DF_OrderItem.createOrderItems(1);
        insert listOfOrderItem;
        XC_Provisioning_Step__c step = new XC_Provisioning_Step__c();
        step.XC_StepLabel__c = 'Payment Check';
        step.XC_Status__c = 'Completed KO';
        step.XC_Configuration_Item__c = listOfOrderItem[0].Id;
        insert step;
        XC_LCC177_PaymentNotDone.ResultWrapper rw = XC_LCC177_PaymentNotDone.paymentNotDone(step.Id);
        //system.assertEquals(false, rw.success);
    }

}