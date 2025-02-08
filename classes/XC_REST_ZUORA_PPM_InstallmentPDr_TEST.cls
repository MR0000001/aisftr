/**
 * Created by dolombardi on 20/12/2020.
 */

@IsTest
public with sharing class XC_REST_ZUORA_PPM_InstallmentPDr_TEST {
    static testMethod void InstallmentPlanDrop(){
        project_cloud__Project__c project = new project_cloud__Project__c();
        project.project_cloud__IsTemplate__c =true;
        project.project_cloud__Type__c='provisioning';
        project.XC_LegalEntity__c ='EnelXItalia';
        project.XC_Country__c ='Italy';

        insert project;
        project_cloud__Project_Phase__c phFace= new project_cloud__Project_Phase__c();
        phFace.project_cloud__Project__c =project.id;
        phFace.XC_billing_phase__c = true;
        insert phFace;
        project_cloud__Project_Task__c projectTask = new project_cloud__Project_Task__c();
        projectTask.project_cloud__Project_Phase__c = phFace.id;
        projectTask.project_cloud__Estimated_Hours__c = 1;
        projectTask.project_cloud__Units__c='Duration';
        insert projectTask;
        List<Id>listTaskId = new List<Id>();
        listTaskId.add(projectTask.id);
        XC_CS001_InterfaceConfiguration__c  interfaceConfiguration = new XC_CS001_InterfaceConfiguration__c ();
        interfaceConfiguration.Name = 'ZuoraInstallmentPlanDropPPM_B2B';
        interfaceConfiguration.XC_URL_Required__c = 'https://workflow.apps.zuora.com/api/v1/workflows/DropInstallment/run';
        interfaceConfiguration.XC_activeInterface__c = true;
        interfaceConfiguration.XC_interfaceName__c = 'ZuoraInstallmentPlanDropPPM_B2B';
        interfaceConfiguration.XC_Country__c = 'Italy';
        interfaceConfiguration.XC_Stream__c = 'B2G';
        interfaceConfiguration.XC_LegalEntity__c = 'EnelXItalia';
        Zuora__Subscription__c sub = new Zuora__Subscription__c();
        sub.XC_ProjectTaskId__c = projectTask.id;
        insert sub;
        Zuora__ZInvoice__c invoice =  new Zuora__ZInvoice__c();
        insert invoice;
        Zuora__InvoiceItem__c invoiceItem = new Zuora__InvoiceItem__c();
        invoiceItem.Zuora__Invoice__c = invoice.id;
        invoiceItem.Zuora__Subscription__c=sub.id;
        invoiceItem.Zuora__Charge_Date__c=Date.today();
        invoiceItem.Zuora__Charge_Amount2__c=50;
        insert invoiceItem;

        //sub.Zuora__Subscription__c = invoiceItem.id;


        insert interfaceConfiguration;
        Test.startTest();
        XC_REST_ZUORA_PPM_InstallmentPlanDrop.InstallmentPlanDrop(listTaskId);
        Test.stopTest();

    }
}