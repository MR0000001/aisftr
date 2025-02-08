/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
public with sharing class XC_REST_ZUORA_CreditMemo {
    public class WrapperRequestCreditMemo{
        public String InvoiceNumber;
        public Decimal Amount ;
        public String ActionType  ;
        public String CaseId;
        public String AutoTaxCalculation;
    }
    public static Map<Id,String> mapNewP = New Map<Id,String>();



    public static void sentToZuora(Map<Id,Case> mapNew,Map<Id,Case> mapOld){



        List<Case> listCaseIsChanged = new List<Case>();
        List<String> listName = new List<String>{'Approved__c'};
        listCaseIsChanged = XC_UTIL_Sobject.getListChanged(listName, mapOld, mapNew);
        if(listCaseIsChanged.isEmpty()){
            return ;
        }
        Map<Id,Case> mapCaseB2B = new Map<Id,Case>();
        for(Case c :listCaseIsChanged){
            mapCaseB2B.put(c.id,c);
        }

        Map<Id,Case> mapCaseCreditMemo = new Map<Id,Case>();
        Map<Id,Case> mapCaseReverse = new Map<Id,Case>();
        mapCaseCreditMemo = checkSubTypeCaseCreditMemo(mapCaseB2B);
        if(mapCaseCreditMemo.isEmpty()){
            return ;
        }
        Map<Id,Case> mapCaseRelatedInvoice = new Map<Id,Case>();
        Map<Id,String> mapCase = new Map<Id,String>();
        //mapCaseRelatedInvoice = retrieveInvoiceRelatedCase(mapCaseCreditMemo.keySet());
        retrieveInvoiceRelatedCase(mapCaseCreditMemo.keySet());



        /*for(Id i: mapNew.keySet()){
            if(mapNewP.get(i)!= null){
                if(mapNewP.get(i) =='OK'){
                    mapNew.get(i).XC_Resolution__c = 'R001';
                    mapNew.get(i).XC_Result__c = 'RS001';
                    mapNew.get(i).CaseRemarks__c = 'OK';
                }
                mapNew.get(i).XC_ErrorMessage__c = mapNewP.get(i);
            }
            mapNew.get(i).XC_ErrorMessage__c = 'KO';
        }*/

    }


    private static HttpResponse manageRequestResponse(HttpRequest req /*List<XC_Provisioning_Step__c> listProvStep*/){
        XC_UTIL_IntegrationLog.LogWrapper lw = new XC_UTIL_IntegrationLog.LogWrapper();
        lw.logEndpoint = req.getEndpoint();
        lw.httpMethod = req.getMethod();
        lw.logIntegrationName = 'ZUORA_Credit_Memo';
        lw.logTransactionID = '';
        lw.insertLogging = true;
        HttpResponse response = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(req,lw).response;
        System.debug('Response BODY-->DL '+ response.getBody());
        String jsonBody = response.getBody();
        Map<String,Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(jsonBody);

        System.debug('Response STATUS-->DL '+ response.getStatus());
        return response;
        //listProvStep[0].XC_Status__c = 'Completed OK';
        //update listProvStep;
    }



    private static Map<Id,Case> checkSubTypeCaseCreditMemo(Map<Id,Case> mapCaseB2B){
        Map<Id,Case> mapCaseCreditMemo = new Map<Id,Case>();
        for(Case caseCreditMemo : mapCaseB2B.values()){
            if(caseCreditMemo.XC_Subtype__c == 'XC267' || caseCreditMemo.XC_Subtype__c=='XC266'){
                mapCaseCreditMemo.put(caseCreditMemo.id,caseCreditMemo);
            }
        }
        return mapCaseCreditMemo;
    }
    @Future(callout=true)
    private static void retrieveInvoiceRelatedCase(Set<Id> setIdCase){
        Map<Id,Case> mapCaseRelatedInvoice = New Map<Id,Case>([select id, XC_Amount__c, XC_CreditMemo__c, XC_LegalEntity__c, XC_Segment__c,  XC_Subtype__c, XC_Invoice__r.Name from case where id IN :setIdCase]);
        //return mapCaseRelatedInvoice;
        List<Map<String,Object>> listRespnse = new List<Map<String,Object>>();
        List<HttpResponse> listRespnse1 = new List<HttpResponse>();
        Map<String,String>mapIdCaseOK = new Map<String,String>();
        Map<Id,String>mapIdCaseKO = new Map<Id,String>();
        XC_UTIL_RESTCallout.CSWrapper wrInterface = XC_UTIL_RESTCallout.checkActiveInterface2('XC_CS_Zuora_CreditMemo');
        if(wrInterface.activeInterface) {
        for(Id caseId :mapCaseRelatedInvoice.keySet()) {
            String legalEntity = mapCaseRelatedInvoice.get(caseId).XC_LegalEntity__c;
            String stream = mapCaseRelatedInvoice.get(caseId).XC_Segment__c;
            String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, stream);
            ZuoraWebService zws = new ZuoraWebService(entityName);
            String url = wrInterface.url;


            WrapperRequestCreditMemo req = new WrapperRequestCreditMemo();
            req.InvoiceNumber = mapCaseRelatedInvoice.get(caseId).XC_Invoice__r.Name;
            req.Amount = mapCaseRelatedInvoice.get(caseId).XC_CreditMemo__c;
            req.ActionType = mapCaseRelatedInvoice.get(caseId).XC_Subtype__c == 'XC267' ? 'Create CreditMemo' : 'Reverse';
            req.CaseId = caseId;
            req.AutoTaxCalculation = 'Y';
            String body = JSON.serialize(req, true);
            Map<String, String> headerDefinitions = new Map<String, String>();
            headerDefinitions.put('Content-Type', 'application/json');
            headerDefinitions.put('API-Token', zws.apiToken);

            XC_UTIL_IntegrationLog.LogWrapper lw = new XC_UTIL_IntegrationLog.LogWrapper();
            lw.insertLogging = true;
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            System.debug('Request DL-->' + request);
            listRespnse1.add(manageRequestResponse(request));
            }

            System.debug('listResponse 01' + listRespnse1);


            for(HttpResponse response :listRespnse1){
                String jsonBody = response.getBody();
                System.debug('jsonBODY' + jsonBody);
                Map<String,Object> objectMap = (Map<String,Object>) JSON.deserializeUntyped(jsonBody);
                //Map<String,Map<String,Object>> objectMap = (Map<String,Map<String,Object>>) JSON.deserializeUntyped(jsonBody);
                System.debug('objMAP'+objectMap);
                System.debug('objMAP'+objectMap.keySet());
                System.debug('objMAP'+objectMap.values());
                System.debug('objMAP'+objectMap.get('Workflow'));
                //Map<String,String> mapCase = new Map<String,String>(objectMap.get('Workflow'));
                //Map<String,Object> objectMapCase = (Map<String,Object>) JSON.deserializeUntyped(String.valueOf(objectMap.get('Workflow')));
                //System.debug('mapObjectCase'+objectMapCase);
                for(String i :objectMap.keySet()) {
                    if (response.getStatus() == 'OK') {
                        //mapIdCaseOK.put(String.valueOf(((Map<String, Object>) objectMap.get('Workflow')).get('CaseId')), 'OK');
                        mapIdCaseOK.put(String.valueOf(objectMap.get('CaseId')), 'OK');
                    } else {
                        if (objectMap.get('CaseId') != null) {
                            //if (((Map<String, Object>) objectMap.get('Workflow')).get('CaseId') != null) {
                                mapIdCaseOK.put(String.valueOf(objectMap.get('CaseId')),String.valueOf(objectMap.get('ErrorReason')));
                                //mapIdCaseOK.put(String.valueOf((Map<String, Object>) objectMap.get('CaseId')), String.valueOf(((Map<String, Object>) objectMap.get('ErrorReason'))));
                           // }
                        }

                    }
                }
            }
            Map<Id,Case> mapIdCaseTopdate = new Map<ID,Case>([SELECT ID, XC_Resolution__c,CaseRemarks__c, XC_Result__c,XC_ErrorMessage__c FROM CASE WHERE ID IN :setIdCase]);
            for(Id i: mapIdCaseTopdate.keySet()){
                if(mapIdCaseOK.get(i)!= null){
                    if(mapIdCaseOK.get(i) =='OK'){
                        mapIdCaseTopdate.get(i).XC_Resolution__c = 'R001';
                        mapIdCaseTopdate.get(i).XC_Result__c = 'RS003';
                        mapIdCaseTopdate.get(i).CaseRemarks__c = 'OK';
                    }else {
                        mapIdCaseTopdate.get(i).XC_Resolution__c = 'R002';
                        mapIdCaseTopdate.get(i).XC_Result__c = 'RS004';
                        mapIdCaseTopdate.get(i).CaseRemarks__c = 'KO';
                    }

                }else {
                    mapIdCaseTopdate.get(i).XC_ErrorMessage__c = 'KO';
                }
            }
            System.debug('update'+mapIdCaseTopdate);
            update mapIdCaseTopdate.values();



        }




    }



}