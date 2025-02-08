/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
public with sharing class XC_REST_ZUORA_PPM_Disconnect {
    public class WrapperRequestDisconnect{
        public String subscriptionId;
        public String cancellationDate;
        public String subType;
    }
    public class WrapperRequestInstallmentPlan{
        public String InvoiceNumber;
        public String InstallmentRate ;
        public String InstallmentType  ;
    }

    @InvocableMethod
    public static void Disconnection(List<String> ListprojectTaskId){
        DisconnectionFut(ListprojectTaskId);
        project_cloud__Project_Task__c task = retrieveTask(ListprojectTaskId[0]);
        task.XC_TaskStatus__c = 'Closed';
        task.project_cloud__Completed_Date__c = Date.today();
        update task;

    }



    @Future(callout=true)
    public static void DisconnectionFut(List<String> ListprojectTaskId){
        String projectTaskId = ListprojectTaskId[0];
        XC_UTIL_RESTCallout.CSWrapper wrInterface = XC_UTIL_RESTCallout.checkActiveInterface2('ZuoraDisconnectionPPM_B2B');
        if(wrInterface.activeInterface) {

        }

        project_cloud__Project_Task__c task = retrieveTask(projectTaskId);
        String legalEntity = task.XC_Configuration__r.XC_LegalEntity__c;
        String stream = task.XC_Configuration__r.XC_Segment__c;
        String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, stream);
        ZuoraWebService zws = new ZuoraWebService(entityName);
        String url = wrInterface.url;
        WrapperRequestDisconnect req = new WrapperRequestDisconnect();

        List<Asset> listAsset = retreiveAsset(task.XC_Configuration__c);

        List<zqu__Quote__c> listzQuote = retrieveZQuote(listAsset[0].XC_Original_Configuration_Item__c);

        req.subscriptionId = listzQuote[0].XC_LastSubscriptionId__c != Null ? listzQuote[0].XC_LastSubscriptionId__c : listzQuote[0].zqu__ZuoraSubscriptionID__c;
        req.subType = 'Rethinking';
        req.cancellationDate = String.valueOf(Date.today());

        String body =  JSON.serialize(req, true);

        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('Content-Type','application/json');
        headerDefinitions.put('API-Token', zws.apiToken);

        XC_UTIL_IntegrationLog.LogWrapper lw = new XC_UTIL_IntegrationLog.LogWrapper();
        lw.insertLogging = true;
        HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
        //task.XC_TaskStatus__c = 'Closed';
        //task.project_cloud__Completed_Date__c = Date.today();
        //update task;
        manageRequestResponse(request);

    }
    private static project_cloud__Project_Task__c retrieveTask(String taskId){
        project_cloud__Project_Task__c p  = [select id, XC_Configuration__c, XC_TaskStatus__c, project_cloud__Completed_Date__c, XC_Configuration__r.XC_LegalEntity__c, XC_Configuration__r.XC_Segment__c from project_cloud__Project_Task__c  where id =:taskId];
        return p;
    }
    private static List<Asset> retreiveAsset(String configuration){
        List<Asset> listAsset = new List<Asset>();
        listAsset = [select id, XC_Configuration_Item__c, XC_Original_Configuration_Item__c from Asset
        where  XC_Configuration_Item__r.NE__OrderId__c =:configuration and XC_Configuration_Item__r.NE__Root_Order_Item__c = null AND XC_Configuration_Item__r.XC_BillingModel__c = 'Recurring'];
        return listAsset;
    }
    private static List<zqu__quote__c> retrieveZQuote(String configurationToProvisiongID){
        List<zqu__quote__c> listzQuote = new List<zqu__quote__c>();
        listzQuote = [select id, XC_LastSubscriptionId__c, zqu__ZuoraSubscriptionID__c
        from zqu__quote__c
        where  XC_ConfigurationItem__c =: configurationToProvisiongID  order by CreatedDate desc];
        return listzQuote;
    }
    private static void manageRequestResponse(HttpRequest req){
        XC_UTIL_IntegrationLog.LogWrapper lw = new XC_UTIL_IntegrationLog.LogWrapper();
        lw.logEndpoint = req.getEndpoint();
        lw.httpMethod = req.getMethod();
        lw.logIntegrationName = 'ZUORA_PPM_Disconnect';
        lw.logTransactionID = '';
        lw.insertLogging = true;
        HttpResponse response = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(req,lw).response;
    }




    /*

    public static void InstallmentPlanDrop(String projectTaskId){
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

    private static project_cloud__Project_Task__c retrieveTask(String taskId){
        project_cloud__Project_Task__c p  = [select id, XC_Configuration__c, XC_TaskStatus__c, project_cloud__Completed_Date__c from project_cloud__Project_Task__c  where id =:taskId];
        return p;
    }
    private static List<Asset> retreiveAsset(String configuration){
        List<Asset> listAsset = new List<Asset>();
        listAsset = [select id, XC_Configuration_Item__c, XC_Original_Configuration_Item__c from Asset
        where  XC_Configuration_Item__r.NE__OrderId__c =:configuration and XC_Configuration_Item__r.NE__Root_Order_Item__c = null AND XC_Configuration_Item__r.XC_BillingModel__c = 'Recurring'];
        return listAsset;
    }

    private static List<zqu__quote__c> retrieveZQuote(String configurationToProvisiongID){
        List<zqu__quote__c> listzQuote = new List<zqu__quote__c>();
        listzQuote = [select id, XC_LastSubscriptionId__c, zqu__ZuoraSubscriptionID__c
        from zqu__quote__c
        where  XC_ConfigurationItem__c =: configurationToProvisiongID  order by CreatedDate desc];
        return listzQuote;
    }
*/






}