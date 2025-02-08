/**
 * Created by dolombardi on 16/12/2020.
 */
@isTest
public with sharing class XC_REST_ZUORA_PPM_Disconnect_TEST {
    static testMethod void submitTest(){
        XC_CS001_InterfaceConfiguration__c  interfaceConfiguration = new XC_CS001_InterfaceConfiguration__c ();
        interfaceConfiguration.Name = 'ZuoraDisconnectionPPM_B2B';
        interfaceConfiguration.XC_URL_Required__c = 'https://workflow.apps.zuora.com/api/v1/workflows/DropInstallment/run';
        interfaceConfiguration.XC_activeInterface__c = true;
        interfaceConfiguration.XC_interfaceName__c = 'ZuoraDisconnectionPPM_B2B';
        interfaceConfiguration.XC_Country__c = 'Italy';
        interfaceConfiguration.XC_Stream__c = 'B2G';
        interfaceConfiguration.XC_LegalEntity__c = 'EnelXItalia';
        insert interfaceConfiguration;
        NE__Order__c ord = XC_DF_Order.createOrder('test');
        ord.XC_Segment__c ='B2G';
        ord.XC_LegalEntity__c = 'EnelXItalia';
        update ord;
        NE__OrderItem__c ordItem =  XC_DF_OrderItem.createOrderItem(ord);
        ordItem.XC_BillingModel__c='Recurring';
        insert ordItem;
        List<Asset> a = XC_DF_Asset.createAssets(1);
        insert a;
        a[0].XC_Configuration_Item__c = ordItem.id;
        a[0].XC_Original_Configuration_Item__c = ordItem.id;
        List<Asset> listAss = [select id, XC_Configuration_Item__c, XC_Original_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c from Asset where id = :a[0].id];
        //listAss[0].XC_Configuration_Item__r.NE__OrderId__c = ord.id;
        update a;

        zqu__Quote__c zQuote = new zqu__Quote__c();
        zQuote.zqu__ZuoraSubscriptionID__c = '587125493261636';
        zQuote.XC_ConfigurationItem__c = ordItem.id;
        insert zQuote;
        //insert ord;
        project_cloud__Project__c project = new project_cloud__Project__c();
        project.project_cloud__IsTemplate__c =true;
        project.project_cloud__Type__c='provisioning';
        project.XC_LegalEntity__c ='EnelXItalia';
        project.XC_Country__c ='Italy';
        project.XC_Configuration__c=ord.id;
        insert project;
        project_cloud__Project_Phase__c phFace= new project_cloud__Project_Phase__c();
        phFace.project_cloud__Project__c =project.id;
        phFace.XC_billing_phase__c = true;
        insert phFace;
        project_cloud__Project_Task__c projectTask = new project_cloud__Project_Task__c();
        projectTask.project_cloud__Project_Phase__c = phFace.id;
        projectTask.project_cloud__Estimated_Hours__c = 1;
        projectTask.project_cloud__Units__c='Duration';
        projectTask.XC_Configuration__c=ord.Id;
        insert projectTask;
        List<Id>listIdTask = new List<Id>{projectTask.id};
        XC_REST_ZUORA_PPM_Disconnect.Disconnection(listIdTask);
    }

}