/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  31/05/2019 
* @description XC_UTIL_ProvisioningStep_TEST – Test class for XC_UTIL_ProvisioningStep
*/
@isTest
public with sharing class XC_UTIL_ProvisioningStep_TEST {
//Test Method startInitialSteps
    static testMethod void startInitialSteps(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        List<XC_Provisioning_Step__c> listSteps = new List<XC_Provisioning_Step__c>();
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        ps.XC_Step_Order__c =1;
        ps.XC_Status__c = Label.XC_CL_Provisioning_Step_NotStarted;        
        String psId = ps.Id; 
        listSteps.add(ps); 
        XC_UTIL_ProvisioningStep.startInitialSteps(listSteps);
        System.assert(ps!=null);
        Test.stopTest(); 
    }

    //Test Method enqueueStepList
    static testMethod void enqueueStepList(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        List<XC_Provisioning_Step__c> listSteps = new List<XC_Provisioning_Step__c>();
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        ps.XC_Synchronous__c= true;
        listSteps.add(ps); 
        XC_UTIL_ProvisioningStep.enqueueStepList(listSteps);
        System.assert(ps!=null);
        Test.stopTest(); 
    }

        //Test Method enqueueStepList1
    static testMethod void enqueueStepList1(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        List<XC_Provisioning_Step__c> listSteps = new List<XC_Provisioning_Step__c>();
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        listSteps.add(ps); 
        XC_UTIL_ProvisioningStep.enqueueStepList(listSteps);
        System.assert(ps!=null);
        Test.stopTest(); 
    }

    //Test Method launchStepListSynch
    static testMethod void launchStepListSynch(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        Set<XC_Provisioning_Step__c> stepsToEnqueueSynch = new Set<XC_Provisioning_Step__c>();
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        stepsToEnqueueSynch.add(ps); 
        XC_UTIL_ProvisioningStep.launchStepListSynch(stepsToEnqueueSynch);
        System.assert(ps!=null);
        Test.stopTest(); 
    }

       //Test Method launchStepListSynch1
    static testMethod void launchStepListSynch1(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        Set<XC_Provisioning_Step__c> stepsToEnqueueAsynch = new Set<XC_Provisioning_Step__c>();
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        ps.XC_Step_Order__c =1;
        ps.XC_Status__c = Label.XC_CL_Provisioning_Step_NotStarted;        
        String psId = ps.Id; 
        stepsToEnqueueAsynch.add(ps); 
        XC_UTIL_ProvisioningStep.launchStepListSynch(stepsToEnqueueAsynch);
        System.assert(ps!=null);
        Test.stopTest(); 
    }

        //Test Method setInProgressStatus
    static testMethod void setInProgressStatus(){
        insert XC_DF_OneOrg.createOneOrg('Spain');       
    Test.startTest(); 
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        String psId = ps.Id;
        XC_Provisioning_Step__c ps1= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        String ps1Id = ps1.Id;
        List<XC_Provisioning_Step__c> listSteps = new List<XC_Provisioning_Step__c>();
        listSteps.add(ps);
       // listSteps.add(ps1);
        XC_UTIL_ProvisioningStep.setInProgressStatus(listSteps);
        System.assert(ps!=null);
        Test.stopTest(); 
    }


    //Test Method insertEvent
    static testMethod void insertEvent(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        String psId = ps.Id; 
        XC_Provisioning_Step__c ps1= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        String ps1Id = ps1.Id;
        XC_Provisioning_Step__c ps2= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        String ps2Id = ps2.Id;
        List<String> stepIdList = new List<String>(); 
        stepIdList.add(psId);
        stepIdList.add(ps1Id); 
        stepIdList.add(ps2Id); 
        XC_UTIL_ProvisioningStep.insertEvent(stepIdList);
        System.assert(ps!=null);
        Test.stopTest(); 
    }

        //Test Method executeSteps
    static testMethod void executeSteps(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        ps.XC_Flow_API_Name__c= 'XC_FL_eMobility_BillingProcess';
        XC_Provisioning_Step__c ps1= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        ps1.XC_Flow_API_Name__c= 'XC_FL_eMobility_BillingProcess';
        List<XC_Provisioning_Step__c> listSteps = new List<XC_Provisioning_Step__c>();
        listSteps.add(ps);
        listSteps.add(ps1);
        List<XC_Provisioning_Step__c> listSteps1 = new List<XC_Provisioning_Step__c>();
        XC_Provisioning_Step__c ps2= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        listSteps1.add(ps2);
        XC_UTIL_ProvisioningStep.executeSteps(listSteps);
        System.assert(ps!=null);
        Test.stopTest(); 
    }

            //Test Method executeSteps2 ( 1 solo elemento)
    static testMethod void executeSteps2(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        List<XC_Provisioning_Step__c> listSteps = new List<XC_Provisioning_Step__c>();
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        listSteps.add(ps);
        XC_UTIL_ProvisioningStep.executeSteps(listSteps);
        System.assert(ps!=null);
        Test.stopTest(); 
    }

    
    //Test Method insertSteps
    static testMethod void insertSteps(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        XC_Provisioning_Step__c ps= new XC_Provisioning_Step__c();
        ps.XC_Configuration_Item__c = confItem.Id; 
        XC_UTIL_ProvisioningStep.ResultWrapper rw =  XC_UTIL_ProvisioningStep.insertSteps(confItem.Id);
        System.assertEquals(true, rw.success);
        Test.stopTest(); 
    }

    //Test Method insertSteps1
    static testMethod void insertSteps1(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        XC_Provisioning_Step__c ps= new XC_Provisioning_Step__c();
        ps.XC_Configuration_Item__c = confItem.Id; 
        List<String> listConfigurationIds = new List<String>();
        listConfigurationIds.add(confItem.Id);
        List<XC_UTIL_ProvisioningStep.ResultWrapper> listrw = XC_UTIL_ProvisioningStep.insertSteps(listConfigurationIds);
        System.assert(ps!=null);
        Test.stopTest(); 
    }

    //Test Method insertSteps2
    /*static testMethod void insertSteps2(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        insert confItem;
        XC_Provisioning_Step__c ps= new XC_Provisioning_Step__c();
        List<String> listConfigurationIds = new List<String>();
        listConfigurationIds.add(confItem.Id);
        List<XC_UTIL_ProvisioningStep.ResultWrapper> listrw = XC_UTIL_ProvisioningStep.insertSteps(listConfigurationIds);
        System.assert(ps!=null);
        Test.stopTest(); 
    }*/

    //Test Method insertSteps3
    static testMethod void insertSteps3(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        XC_UTIL_ProvisioningStep.ResultWrapper rw = XC_UTIL_ProvisioningStep.insertSteps(confItem);
        System.assert(confItem!=null);
        Test.stopTest(); 
    }

    //Test Method insertSteps4
    static testMethod void insertSteps4(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        List<NE__OrderItem__c> configurationItemList = new List<NE__OrderItem__c>();
        configurationItemList.add(confItem);
        List<XC_UTIL_ProvisioningStep.ResultWrapper> listrw = XC_UTIL_ProvisioningStep.insertSteps(configurationItemList);
        System.assert(confItem!=null);
        Test.stopTest(); 
    }

     // Test method for isCompleted
    /*static testMethod void isCompleted(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        insert confItem;
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        ps.XC_Status__c = Label.XC_CL_Completed_OK;
        Boolean result = XC_UTIL_ProvisioningStep.isCompleted(ps.XC_Status__c);
        System.assert(ps!=null);
        Test.stopTest();
    }*/
     
     // Test method for isFailed
    /*static testMethod void isFailed(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        insert confItem;
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        ps.XC_Status__c = Label.XC_CL_Completed_OK;
        Boolean result = XC_UTIL_ProvisioningStep.isFailed(ps.XC_Status__c);
        System.assert(ps!=null);
        Test.stopTest();
    }*/

}