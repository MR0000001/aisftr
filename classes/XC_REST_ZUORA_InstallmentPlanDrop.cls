/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
public with sharing class XC_REST_ZUORA_InstallmentPlanDrop {

    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @date 18/03/2019
     * @description Wrapper used by flow
     */
    public class InputWrapper{

        /** The String. */
        @Invocablevariable
        public String stepId;

        /** The String. */
        @Invocablevariable
        public String configurationItemId;
    }




    public class WrapperRequestInstallmentPlan{
        public String InvoiceNumber;
        public String InstallmentRate ;
        public String InstallmentType  ;
        public String CaseId;
    }
    @InvocableMethod
    public static void InstallmentPlanDrop(List<InputWrapper> inputWrapperList){
        String idConfItem = inputWrapperList[0].configurationItemId;
        XC_UTIL_RESTCallout.CSWrapper wrInterface = XC_UTIL_RESTCallout.checkActiveInterface2('ZuoraInstallmentPlanDropPPM_B2B');
        if(wrInterface.activeInterface) {

        }
        String legalEntity = 'EnelXItalia';
        String stream = 'B2B';
        String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, stream);
        ZuoraWebService zws = new ZuoraWebService(entityName);
        String url = wrInterface.url;
        List<Zuora__ZInvoice__c> listInvoices = retrieveInvoice(idConfItem);
        List<XC_Provisioning_Step__c> listProvStep = new List<XC_Provisioning_Step__c>();
        listProvStep = [select id, name, XC_Status__c, XC_ErrorMessage__c, XC_Configuration_Item__r.NE__OrderId__c, XC_Configuration_Item__r.NE__OrderId__r.XC_CaseId__c from XC_Provisioning_Step__c where id =:inputWrapperList[0].stepId];
        if(listInvoices.isEmpty()){
            listProvStep[0].XC_ErrorMessage__c = 'No Invoice Foud';
            listProvStep[0].XC_Status__c = 'Completed KO';
            update listProvStep;
            return ;
        }
        List<NE__OrderItem__c> listOrderItemToPlanUpdate = new List<NE__OrderItem__c>();
        listOrderItemToPlanUpdate = retrieveOrederItemNEW(idConfItem);



        WrapperRequestInstallmentPlan req = new WrapperRequestInstallmentPlan();
        req.InvoiceNumber=listInvoices[0].Name;
        req.InstallmentRate=listOrderItemToPlanUpdate[0].XC_InstallmentRate__c;
        req.InstallmentType=listOrderItemToPlanUpdate[0].XC_InstallmentPlanType__c;
        req.CaseId = listProvStep[0].XC_Configuration_Item__r.NE__OrderId__r.XC_CaseId__c;
        String body =  JSON.serialize(req, true);

        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('Content-Type','application/json');
        headerDefinitions.put('API-Token', zws.apiToken);

        XC_UTIL_IntegrationLog.LogWrapper lw = new XC_UTIL_IntegrationLog.LogWrapper();
        lw.insertLogging = true;
        HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
        manageRequestResponse(request,listProvStep);

    }

    private static void manageRequestResponse(HttpRequest req,List<XC_Provisioning_Step__c> listProvStep){
        XC_UTIL_IntegrationLog.LogWrapper lw = new XC_UTIL_IntegrationLog.LogWrapper();
        lw.logEndpoint = req.getEndpoint();
        lw.httpMethod = req.getMethod();
        lw.logIntegrationName = 'ZUORA_InstallmentDrop';
        lw.logTransactionID = '';
        lw.insertLogging = true;
        HttpResponse response = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(req,lw).response;
        listProvStep[0].XC_Status__c = 'Completed OK';
        update listProvStep;
    }

/*
    private static List<Zuora__InvoiceItem__c> retrieveInvoice(String configurationItemId){
        List<Zuora__InvoiceItem__c> listZuoraInvoiceItems = new List<Zuora__InvoiceItem__c>();
        if(Schema.sObjectType.Zuora__InvoiceItem__c.isAccessible()){
            listZuoraInvoiceItems = [select id, Name, Zuora__Invoice__r.Name, XC_SubscriptionNumber__c,Zuora__Invoice__r.Configuration_Item__r.XC_BillingModel__c,  Zuora__Subscription__c, Zuora__Subscription__r.XC_ProjectTaskId__c, Zuora__Subscription__r.XC_InstallmentRate__c,  LastModifiedDate, Zuora__Subscription__r.XC_InstallmentPlanType__c,  Zuora__Invoice__r.XC_ConfigurationItem__c, Zuora__Subscription__r.Zuora__QuoteNumber__c,Zuora__ServiceStartDate__c
            from Zuora__InvoiceItem__c where Zuora__Invoice__r.XC_ConfigurationItem__c = :configurationItemId order by LastModifiedDate];
        }
        return listZuoraInvoiceItems;

    }

 */

    private static List<Zuora__ZInvoice__c> retrieveInvoice(String configurationItemId){
        List<NE__OrderItem__c> listOrderItemOld = new List<NE__OrderItem__c>();
        listOrderItemOld = [select id,XC_InstallmentPlanType__c, InstallmentDivisionTax__c,XC_InstallmentFrequency__c,XC_InstallmentsNumber__c,XC_Interests_Index__c,XC_InstallmentRate__c, NE__OrderId__r.NE__OptyId__c, NE__ProdName__c from NE__OrderItem__c where id =:configurationItemId];

        List<NE__OrderItem__c>listOrderItemToPlanUpdate = new List<NE__OrderItem__c>();
        listOrderItemToPlanUpdate = [select id, XC_InstallmentPlanType__c, InstallmentDivisionTax__c,XC_InstallmentFrequency__c,XC_InstallmentsNumber__c,XC_Interests_Index__c,XC_InstallmentRate__c, NE__OrderId__r.NE__OptyId__c, Name, NE__ProdName__c, NE__OrderId__r.name,  NE__OrderId__r.RecordType.DeveloperName, NE__OrderId__r.NE__Type__c from NE__OrderItem__c
        where NE__OrderId__r.NE__OptyId__c = :listOrderItemOld[0].NE__OrderId__r.NE__OptyId__c  AND NE__OrderId__r.RecordType.DeveloperName = 'Order' AND NE__OrderId__r.NE__Type__c = 'InOrder' AND NE__ProdName__c = :listOrderItemOld[0].NE__ProdName__c];

        List<Zuora__ZInvoice__c > listInvoice = new List<Zuora__ZInvoice__c >();
        listInvoice = [select id, name, XC_ConfigurationItem__c from Zuora__ZInvoice__c where XC_ConfigurationItem__c =:listOrderItemToPlanUpdate[0].id order by CreatedDate desc limit 1];
        return listInvoice;

    }

    private static List<NE__OrderItem__c> retrieveOrederItemNEW(String configurationItemId){
        List<NE__OrderItem__c> listOrderItemOld = new List<NE__OrderItem__c>();
        listOrderItemOld = [select id,XC_InstallmentPlanType__c, InstallmentDivisionTax__c,XC_InstallmentFrequency__c,XC_InstallmentsNumber__c,XC_Interests_Index__c,XC_InstallmentRate__c, NE__OrderId__r.NE__OptyId__c, NE__ProdName__c from NE__OrderItem__c where id =:configurationItemId];
        return listOrderItemOld;


    }

    private static void retreiveAsset(String configuration){
        List<Asset> listAsset = new List<Asset>();
        listAsset = [select id, XC_Configuration_Item__c, XC_Original_Configuration_Item__c from Asset
        where  XC_Configuration_Item__r.NE__OrderId__c =:configuration and XC_Configuration_Item__r.NE__Root_Order_Item__c = null AND XC_Configuration_Item__r.XC_BillingModel__c = 'Recurring'];

        List<NE__OrderItem__c>listOrderItemToPlanUpdate = new List<NE__OrderItem__c>();
        listOrderItemToPlanUpdate = [select id, XC_InstallmentPlanType__c, InstallmentDivisionTax__c,XC_InstallmentFrequency__c,XC_InstallmentsNumber__c,XC_Interests_Index__c,XC_InstallmentRate__c, NE__OrderId__r.NE__OptyId__c, Name, NE__ProdName__c, NE__OrderId__r.name,  NE__OrderId__r.RecordType.DeveloperName, NE__OrderId__r.NE__Type__c from NE__OrderItem__c
        where Id = :listAsset[0].XC_Original_Configuration_Item__c ];
        

    }



}