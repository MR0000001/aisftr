/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
public with sharing class XC_REST_ZUORA_PPM_InstallmentPlanDrop {
    public class WrapperRequestInstallmentPlan{
        public String InvoiceNumber;
        public String InstallmentRate ;
        public String InstallmentType  ;
    }
    @InvocableMethod
    public static void InstallmentPlanDrop(List<String> listProjectTaskId){
        String projectTaskId = listProjectTaskId[0];
        XC_UTIL_RESTCallout.CSWrapper wrInterface = XC_UTIL_RESTCallout.checkActiveInterface2('ZuoraInstallmentPlanDropPPM_B2B');
        if(wrInterface.activeInterface) {

        }
        String legalEntity = 'EnelXItalia';
        String stream = 'B2B';
        String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, stream);
        ZuoraWebService zws = new ZuoraWebService(entityName);
        String url = wrInterface.url;
        List<Zuora__InvoiceItem__c> listInvoiceItems = retrieveInvoice(projectTaskId);
        //if(listInvoiceItems.isEmpty()){
        //    return ;
        //}

        System.debug('ListInvoice--> '+listInvoiceItems);
        WrapperRequestInstallmentPlan req = new WrapperRequestInstallmentPlan();
        req.InvoiceNumber=listInvoiceItems[0].Zuora__Invoice__r.Name;
        req.InstallmentRate=listInvoiceItems[0].Zuora__Subscription__r.XC_InstallmentRate__c;
        req.InstallmentType=listInvoiceItems[0].Zuora__Subscription__r.XC_InstallmentPlanType__c;
        String body =  JSON.serialize(req, true);

        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('Content-Type','application/json');
        headerDefinitions.put('API-Token', zws.apiToken);

        XC_UTIL_IntegrationLog.LogWrapper lw = new XC_UTIL_IntegrationLog.LogWrapper();
        lw.insertLogging = true;
        HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
        manageRequestResponse(request);

    }

    private static void manageRequestResponse(HttpRequest req){
        XC_UTIL_IntegrationLog.LogWrapper lw = new XC_UTIL_IntegrationLog.LogWrapper();
        lw.logEndpoint = req.getEndpoint();
        lw.httpMethod = req.getMethod();
        lw.logIntegrationName = 'ZUORA_PPM_InstallmentDrop';
        lw.logTransactionID = '';
        lw.insertLogging = true;
        HttpResponse response = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(req,lw).response;
    }

    private static List<Zuora__Subscription__c> retrieveSubscription(String projectTaskId){
        List<Zuora__Subscription__c> listZuoraSubscriptions = new List<Zuora__Subscription__c>();
        if(Schema.sObjectType.Zuora__Subscription__c.isAccessible()){
            listZuoraSubscriptions = [select id, XC_ProjectTaskId__c, Zuora__External_Id__c, Zuora__InitialTerm__c from Zuora__Subscription__c where XC_ProjectTaskId__c =:projectTaskId];

        }
        return listZuoraSubscriptions;
    }


    private static List<Zuora__InvoiceItem__c> retrieveInvoice(String projectTaskId){
        List<Zuora__InvoiceItem__c> listZuoraInvoiceItems = new List<Zuora__InvoiceItem__c>();
        if(Schema.sObjectType.Zuora__InvoiceItem__c.isAccessible()){
            listZuoraInvoiceItems = [select id, Name, Zuora__Invoice__r.Name, XC_SubscriptionNumber__c, Zuora__Subscription__c, Zuora__Subscription__r.XC_ProjectTaskId__c, Zuora__Subscription__r.XC_InstallmentRate__c,  Zuora__Subscription__r.XC_InstallmentPlanType__c
            from Zuora__InvoiceItem__c where Zuora__Subscription__r.XC_ProjectTaskId__c = :projectTaskId];
        }
        return listZuoraInvoiceItems;

    }


}