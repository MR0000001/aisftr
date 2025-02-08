@isTest
public class XC_REST_ZUORA_InstallmentPlanDrop_TEST {
    static testMethod void InstallmentPlanDrop(){
        XC_REST_ZUORA_InstallmentPlanDrop.InputWrapper wrapper = new XC_REST_ZUORA_InstallmentPlanDrop.InputWrapper();
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);
        insert orderItemList;
        XC_Provisioning_Step__c step = XC_DF_ProvisioningStep.createProvisioningStep(orderItemList[0].id);
        step.XC_Step_Order__c = 1;
        insert step;
        wrapper.stepId = step.id;
        wrapper.configurationItemId = orderItemList[0].id;
        Zuora__ZInvoice__c invoice =  new Zuora__ZInvoice__c();
        invoice.XC_ConfigurationItem__c = orderItemList[0].id;
        insert invoice;
        Zuora__InvoiceItem__c invoiceItem = new Zuora__InvoiceItem__c();
        invoiceItem.Zuora__Invoice__c = invoice.id;
        insert invoiceItem;
        List<XC_REST_ZUORA_InstallmentPlanDrop.InputWrapper> inputWrapperList = new List<XC_REST_ZUORA_InstallmentPlanDrop.InputWrapper>();
        inputWrapperList.add(wrapper);
        XC_CS001_InterfaceConfiguration__c  interfaceConfiguration = new XC_CS001_InterfaceConfiguration__c ();
        interfaceConfiguration.Name = 'ZuoraInstallmentPlanDropPPM_B2B';
        interfaceConfiguration.XC_URL_Required__c = 'https://workflow.apps.zuora.com/api/v1/workflows/DropInstallment/run';
       	interfaceConfiguration.XC_activeInterface__c = true;
            interfaceConfiguration.XC_interfaceName__c = 'ZuoraInstallmentPlanDropPPM_B2B';
            interfaceConfiguration.XC_Country__c = 'Italy';	
            interfaceConfiguration.XC_Stream__c = 'B2G';
        interfaceConfiguration.XC_LegalEntity__c = 'EnelXItalia';
        insert interfaceConfiguration;
            
        Test.startTest();
        	XC_REST_ZUORA_InstallmentPlanDrop.InstallmentPlanDrop(inputWrapperList);
        Test.stopTest();
    }
}